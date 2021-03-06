/****** Script for SelectTopNRows command from SSMS  ******/
SELECT count( distinct serviceCode)
  FROM [NS_Import].[dbo].[PricingCore]
  where 
  SourceType like 'CMS%' 
  and ProviderState='WI'
  and ServiceCode in 
  (Select HospitalCode as code from NS_Publish.dbo.NS_ProcedureBundles Union Select SurgeryCode as code from NS_Publish.dbo.NS_ProcedureBundles)



  SELECT Count(distinct serviceCode)
  FROM [NS_Import].[dbo].[Payer_Compass_Dump]
  where State='WI'
  and ServiceCode in 
  (Select HospitalCode as code from NS_Publish.dbo.NS_ProcedureBundles Union Select SurgeryCode as code from NS_Publish.dbo.NS_ProcedureBundles)


