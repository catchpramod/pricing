USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Merge_ProviderChargeOutpatient]    Script Date: 8/3/2015 5:00:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_NS_Merge_ProviderChargeOutpatient]
@serviceDate varchar(15),
@sourceFileName varchar(200),
@sourceTableName varchar(200)


AS
BEGIN
	declare @mergeSQL varchar(max)

	set @mergeSQL=
	'
		INSERT INTO PricingCore
		(
			[ProviderID],
			[ProviderLastName],
			[ProviderEntityCode],
			[ProviderStreet1],
			[ProviderCity],
			[ProviderState],
			[ProviderZip],
			[ProviderCountry],
			[ServiceCode],
			[ServiceCodeType],
			[ServiceCodeDesc],
			[ServiceDate],
			[AllowedAmount],
			[ChargedAmount],
			[ImportedDate],
			[SourceFileName],
			[SourceType]
		)
		SELECT
			i.[Provider Id],
			i.[Provider Name],
			''O''  entity_code,
			i.[Provider Street Address],
			i.[Provider City],
			i.[Provider State],
			CASE WHEN LEN(i.[Provider Zip Code]) = 9 or LEN(i.[Provider Zip Code]) = 5  
				 THEN LEFT(i.[Provider Zip Code], 5)
				 ELSE LEFT(CONCAT(''0'', i.[Provider Zip Code]), 5) 
			END  As zip,
			''US'' country,
			SUBSTRING(i.[APC],1,CHARINDEX(''-'', i.[APC])-2),
			''APC'' code_type,
			SUBSTRING(i.[APC],CHARINDEX(''-'', i.[APC])+2,LEN(i.[APC])),
			cast('''+@serviceDate+''' as Date) service_date,
			i.[Average Total Payments],
			i.[Average  Estimated Submitted Charges],
			cast(GETDATE() as date) import_date,
			'''+@sourceFileName+''' source_file_name,
			''CMS-APC'' source_type

		FROM 
			[dbo].['+@sourceTableName+']  i

	'

	EXECUTE (@mergeSQL)
END


