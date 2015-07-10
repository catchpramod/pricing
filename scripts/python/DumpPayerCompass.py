__author__ = 'pramod'
import requests
import json
import pypyodbc
import logging
import time

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
insertLocalQuery = """
INSERT INTO pricetest (npi, rate) VALUES (?,?)
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


def setupLogger():
    logger = logging.getLogger('simple_example')
    logger.setLevel(logging.DEBUG)
    wh = logging.FileHandler('wellcare.log')
    wh.setLevel(logging.CRITICAL)
    ah = logging.FileHandler('alithias.log')
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
    payload = {"BundleID": 1001, "ReturnDetail": True,
               "Components": [
                   {"PricingInfo": None, "ServiceUnits": 1, "Type": type, "Value": code}
               ],
               "PostalCode": zip}
    logger.critical("Sending API request")
    logger.critical("Headers -> "+str(headers))
    logger.critical("Payload -> "+str(payload))
    r = requests.post(url, headers=headers, data=json.dumps(payload, allow_nan=True))
    logger.critical("Received response from API")
    logger.critical("Response Headers -> "+str(r.headers))
    logger.critical("Response Body -> "+str(r.text))
    return r


logger = setupLogger()
logger.critical("***************Starting Test Sequence!!!****************")
logger.info("Getting DB connection")
wellcareConn = pypyodbc.connect("driver={SQL Server};server=work-pc;database=test;uid=root;pwd=root")
stagingConn =pypyodbc.connect("driver={SQL Server};server=work-pc;database=test;uid=root;pwd=root")
logger.info("DB connection successful")

wellcareCursor = wellcareConn.cursor()
wellcareCursor.execute(srvCodesQuery)
# serviceCodeList = wellcareCursor.fetchall()  # gets list of tuples, each row is a tuple
serviceCodeList = wellcareCursor.fetchmany(2)
wellcareConn.close()

stagingCursor = stagingConn.cursor()
zipListInput = ['WI']
stagingCursor.execute(zipCodeQuery, zipListInput)
# zipList = stagingCursor.fetchall()
zipList = stagingCursor.fetchmany(10)

for serviceCode in serviceCodeList:
    code = serviceCode[0]
    typeStr = serviceCode[1]
    typeVal = int(serviceCode[2])
    values = []
    try:
        for zipCode in zipList:
            response = getApiData(code, typeVal, zipCode[0])
            pricing = response.json()
            if pricing['Components'][0]['PricingInfo']:
                for info in pricing['Components'][0]['PricingInfo']:
                    sd = pricing["ServiceDate"]
                    value = (
                        code,
                        typeStr,
                        str(pricing['Components'][0]['ServiceUnits']),
                        float(info['FacilityRate']),
                        float(info['NonFacilityRate']),
                        zipCode[0],
                        str(info['NPI']),
                        str(sd[sd.find('(') + 1: sd.find(')')]),
                        str(int(time.time()*1000)),
                        state
                    )
                    values.append(value)
        if (len(values) > 0):
            logger.debug("Batch insert to database")
            logger.debug(values)
            stagingCursor.executemany(insertDumpQuery, values)
    except ValueError as e:
        logger.exception("Error while parsing JSON from response")
    except BaseException as e:
        logger.exception("BaseException")
    finally:
        stagingCursor.commit()


stagingConn.close()
logger.critical("***************Test Sequence Completed!!!****************")
