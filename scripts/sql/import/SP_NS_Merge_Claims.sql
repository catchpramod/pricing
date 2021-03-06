USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Merge_Claims]    Script Date: 8/4/2015 2:37:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_NS_Merge_Claims]
@sourceTableName varchar(200)


AS
BEGIN
	
	--declare @sourceTableName varchar(200)='Alithias_Publish.dbo.AP_MedicalClaims_CYPRESS'
	declare @mergeSQL varchar(max)

	set @mergeSQL=
	'
		INSERT INTO ClaimsCore
		(
			 [ClaimKey]
			,[CompanyID]
			,[CompanyCode]
			,[CompanyName]
			,[NetworkID]
			,[NetworkCode]
			,[NetworkName]
			,[BillingProviderNPI]
			,[BillingProviderName]
			,[BillingProviderAddressLine1]
			,[BillingProviderCity]
			,[BillingProviderState]
			,[BillingProviderZip]
			,[RenderingProviderNPI]
			,[RenderingProviderName]
			,[RenderingProviderAddress1]
			,[RenderingProviderCity]
			,[RenderingProviderState]
			,[RenderingProviderZip]
			,[BeginingDateofService]
			,[PlaceOfService]
			,[HCPCSCPTCode]
			,[HCPCSCPTCodeDescription]
			,[Modifier1]
			,[Modifier2]      
			,[DRGCode]
			,[Units]
			,[BilledAmt]
			,[AllowedAmt]
			,[DeductibleAmt]
			,[SourceFile]
			,[SourceClient]
		)
		SELECT
			 [ClaimKey]
			,[CompanyID]
			,[CompanyCode]
			,[CompanyName]
			,[NetworkID]
			,[NetworkCode]
			,[NetworkName]
			,[BillingProviderNPI]
			,[BillingProviderName]
			,[BillingProviderAddressLine1]
			,[BillingProviderCity]
			,[BillingProviderState]
			,[BillingProviderZip]
			,[RenderingProviderNPI]
			,[RenderingProviderName]
			,[RenderingProviderAddress1]
			,[RenderingProviderCity]
			,[RenderingProviderState]
			,[RenderingProviderZip]
			,[BeginingDateofService]
			,[PlaceOfService]
			,[HCPCSCPTCode]
			,[HCPCSCPTCodeDescription]
			,[Modifier1]
			,[Modifier2]      
			,[DRGCode]
			,[Units]
			,[BilledAmt]
			,[AllowedAmt]
			,[DeductibleAmt]
			,[SourceFile]
			,[SourceClient]

		FROM 
			'+@sourceTableName+' m
		
		where 
			not Exists( select Top 1 1 from dbo.ClaimsCore cc where cc.SourceFile = m.SourceFile)

	'

	EXECUTE (@mergeSQL)
END


