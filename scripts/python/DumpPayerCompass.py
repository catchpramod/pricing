__author__ = 'pramod'
import requests
import json
import pypyodbc
import logging
from logging.handlers import TimedRotatingFileHandler
import time
import datetime


# Create table for the dump table

# CREATE TABLE [dbo].[Payer_Compass_Dump](
# 	[ID] [bigint] IDENTITY(1,1) NOT NULL,
# 	[ServiceCode] [varchar](20) NULL,
# 	[ServiceType] [varchar](50) NULL,
# 	[ServiceUnits] [varchar](20) NULL,
# 	[FacilityRate] [decimal](10, 2) NULL,
# 	[NonFacilityRate] [decimal](10, 2) NULL,
# 	[PostalCode] [varchar](10) NULL,
# 	[State] [varchar](20) NULL,
# 	[NPI] [varchar](20) NULL,
# 	[ServiceDate] [datetime] NULL,
# 	[DownloadDate] [datetime] NULL
# ) ON [PRIMARY]

state = "WI"
srvCodesQuery = """
select distinct Code, CodeType, Id from
  (
  select HospitalCode Code, [HospitalType] [CodeType], 'H' as Src FROM [Alithias_WellCare_V2].[dbo].[MD_ProcedureBundles]
  union
  select SurgeryCode Code, [SurgeryType] [CodeType], 'S' as Src FROM [Alithias_WellCare_V2].[dbo].[MD_ProcedureBundles]
  ) tmp

  left join
  [Alithias_WellCare_V2].[dbo].[MD_PayerCompassServiceTypes] pctype
  on tmp.CodeType=pctype.[Type]
  where Code!='NULL' and CodeType!='NULL'
"""

insertDumpQuery = """
INSERT INTO [dbo].[Payer_Compass_Dump]
           ([ServiceCode]
           ,[ServiceType]
           ,[ServiceUnits]
           ,[FacilityRate]
           ,[NonFacilityRate]
           ,[PostalCode]
           ,[NPI]
           ,[ServiceDate]
           ,[DownloadDate]
           ,[State])
     VALUES
           (?,?,?,?,?,?,?,?,?,?)
"""
zipCodeQuery = """
  SELECT [Zip]
  FROM [Alithias_Common].[dbo].[Cities_extended]
  where StateCode=?
 """

alreadyInsertedQuery = """
select count(id) as present  FROM [National_Pricing].[dbo].[Payer_Compass_Dump]
where ServiceCode=? and PostalCode=?
"""


def setupLogger():
    logger = logging.getLogger('simple_example')
    logger.setLevel(logging.DEBUG)
    wh = TimedRotatingFileHandler('wellcare\\wellcare.log', when='midnight')
    wh.setLevel(logging.CRITICAL)
    ah = TimedRotatingFileHandler('alithias\\alithias.log', when='midnight')
    ah.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter_long = logging.Formatter('%(asctime)s\t%(levelname)s \t%(filename)s:%(lineno)s :: %(message)s')
    formatter_basic = logging.Formatter('%(asctime)s :: %(message)s')
    ch.setFormatter(formatter_long)
    ah.setFormatter(formatter_basic)
    wh.setFormatter(formatter_basic)
    # add the handlers to logger
    logger.addHandler(ch)
    logger.addHandler(ah)
    logger.addHandler(wh)
    return logger


def getApiData(code, type, zip):
    url = "https://test02.payercompass.com/apps/pricer/services/v2/insight.aspx"
    headers = {"Authorization": "Basic YXBpLmFsaXRoaWFzLndlbGxjYXJlOlJKRXBkWThQ",
               "IsCompressed": "False", "Environment": "Sandbox", "Format": "JSON"}

    # url = " https://Visium.chart-tech.com/apps/pricer/services/v2/insight.aspx"
    # headers = {"Authorization": "Basic YXBpLmFsaXRoaWFzLndlbGxjYXJlOlJKRXBkWThQ",
    #            "IsCompressed": "False", "Environment": "Production", "Format": "JSON"}
    payload = {"BundleID": 1001, "ReturnDetail": True,
               "Components": [
                   {"PricingInfo": None, "ServiceUnits": 1, "Type": type, "Value": code}
               ],
               "PostalCode": zip}
    logger.critical("Sending Request, Payload -> " + str(payload))
    r = requests.post(url, headers=headers, data=json.dumps(payload, allow_nan=True))
    return r


logger = setupLogger()
logger.critical("***************Starting Test Sequence!!!****************")
logger.info("Getting DB connection")
wellcareConn = pypyodbc.connect(
    "driver={SQL Server};server=wellcare.arvixecloud.com;database=Alithias_WellCare_V2;uid=wellcaresqladmin;pwd=P@55w0rdNepal")
stagingConn = pypyodbc.connect(
    "driver={SQL Server};server=astaging.arvixecloud.com;database=National_Pricing;uid=stagingsqladmin;pwd=p@ssw0rd")
stagingConn1 = pypyodbc.connect(
    "driver={SQL Server};server=astaging.arvixecloud.com;database=National_Pricing;uid=stagingsqladmin;pwd=p@ssw0rd")
logger.info("DB connection successful")

wellcareCursor = wellcareConn.cursor()
wellcareCursor.execute(srvCodesQuery)
# serviceCodeList = wellcareCursor.fetchall()  # gets list of tuples, each row is a tuple
serviceCodeList = wellcareCursor.fetchall()
wellcareConn.close()

stagingCursor = stagingConn.cursor()
stagingCursor1 = stagingConn1.cursor()

zipListInput = ['WI']
stagingCursor.execute(zipCodeQuery, zipListInput)
# zipList = stagingCursor.fetchall()
zipList = stagingCursor.fetchmany(10)
zipCode = ''

for serviceCode in serviceCodeList:
    try:
        code = serviceCode[0]
        typeStr = serviceCode[1]
        typeVal = int(serviceCode[2])
        values = []
        for zipCodeTuple in zipList:
            zipCode = str(zipCodeTuple[0])
            serviceZipListInput = [code, zipCode]
            stagingCursor1.execute(alreadyInsertedQuery, serviceZipListInput)
            if not stagingCursor1.fetchone()[0]:
                response = getApiData(code, typeVal, zipCode)
                pricing = response.json()
                if pricing['Components'][0]['PricingInfo']:
                    logger.critical("Response with pricing info!")
                    for info in pricing['Components'][0]['PricingInfo']:
                        sd = pricing["ServiceDate"]
                        value = (
                            code,
                            typeStr,
                            str(pricing['Components'][0]['ServiceUnits']),
                            float(info['FacilityRate']),
                            float(info['NonFacilityRate']),
                            zipCode,
                            str(info['NPI']),
                            datetime.datetime(*time.localtime(int(sd[sd.find('(') + 1: sd.find(')')]) / 1000)[:7]),
                            datetime.datetime.now(),
                            state
                        )
                        values.append(value)
                else:
                    logger.critical("Response without pricing info! ")
                    logger.critical(response.text)
            else:
                logger.info("Records already present for : " + str(serviceZipListInput))
        if (len(values) > 0):
            logger.debug("Batch insert to database")
            logger.debug(values)
            stagingCursor.executemany(insertDumpQuery, values)
    except ValueError as e:
        logger.exception("Error while parsing JSON from response")
    except BaseException as e:
        logger.exception("BaseException")
        logger.info("Service Code: " + str(serviceCode))
        logger.info("Zip Code: " + str(zipCode))
    finally:
        stagingCursor.commit()

stagingConn.close()
stagingCursor1.close()
logger.critical("***************Test Sequence Completed!!!****************")
