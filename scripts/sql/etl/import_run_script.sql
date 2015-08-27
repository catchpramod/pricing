--Load Util payment files
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-Util', 'Medicare_Provider_Util_Payment_PUF_CY2013.txt', 'Medicare_Provider_Util_Payment_PUF_CY2013', 'Table' ,'2013-06-30'
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-Util', 'Medicare_Provider_Util_Payment_PUF_CY2012.txt', 'Medicare_Provider_Util_Payment_PUF_CY2012', 'File' ,'2012-06-30'

--Load Inpatient files
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-DRG', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2013.csv', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2013', 'File' ,'2013-06-30'
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-DRG', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2012.csv', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2012', 'File' ,'2012-06-30'
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-DRG', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv', 'Medicare_Provider_Charge_Inpatient_DRG100_FY2013', 'File' ,'2011-06-30'

--Load Outpatient files
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-APC', 'Medicare_Provider_Charge_Outpatient_APC30_CY2013.csv', 'Medicare_Provider_Charge_Outpatient_APC30_CY2013', 'File' ,'2013-06-30'
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-APC', 'Medicare_Provider_Charge_Outpatient_APC30_CY2012.csv', 'Medicare_Provider_Charge_Outpatient_APC30_CY2012', 'File' ,'2012-06-30'
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'CMS-APC', 'Medicare_Provider_Charge_Outpatient_APC30_CY2011.csv', 'Medicare_Provider_Charge_Outpatient_APC30_CY2011', 'File' ,'2011-06-30'

--Load PayerCompass 
EXECUTE NS_ETL.dbo.SP_NS_Import_Core 'PayerCompass', 'Payer_Compass_Dump', 'Payer_Compass_Dump', 'File'

--Load Claims 
EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims_CYPRESS', 'Table'
EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims_EBSO', 'File'
EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims_Plank', 'File'
EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims_PSE', 'File'
EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims_Trilogy', 'File'


EXECUTE NS_ETL.dbo.SP_NS_Import_Claims 'AP_MedicalClaims'



--scrub core(CMS/PC)
EXECUTE NS_ETL.dbo.SP_NS_Scrub 'Core', 'Y' --'Y' is to refresh
--Scrub Claims
EXECUTE NS_ETL.dbo.SP_NS_Scrub 'Claims', 'Y'

--Generate multipliers
EXECUTE NS_ETL.dbo.SP_NS_Scrub 'Multiplier', 'Y'

--Publish cost by zip report
EXECUTE NS_ETL.dbo.SP_NS_Publish 'ByZip'