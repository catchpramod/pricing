USE [NS_Import]
GO

EXECUTE ('EXEC [dbo].[SP_NS_001_CMS_Provider_Util_Payment_2013]')
EXECUTE ('EXEC [dbo].[SP_NS_002_CMS_Provider_Util_Payment_2012]')

EXECUTE ('EXEC [dbo].[SP_NS_003_CMS_Provider_Charge_Inpatient_2013]')
EXECUTE ('EXEC [dbo].[SP_NS_004_CMS_Provider_Charge_Inpatient_2012]')
EXECUTE ('EXEC [dbo].[SP_NS_005_CMS_Provider_Charge_Inpatient_2011]')

EXECUTE ('EXEC [dbo].[SP_NS_006_CMS_Provider_Charge_Outpatient_2013]')
EXECUTE ('EXEC [dbo].[SP_NS_007_CMS_Provider_Charge_Outpatient_2012]')
EXECUTE ('EXEC [dbo].[SP_NS_008_CMS_Provider_Charge_Outpatient_2011]')

