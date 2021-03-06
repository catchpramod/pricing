USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Merge_ProviderChargeInpatient]    Script Date: 8/3/2015 5:30:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_NS_Merge_ProviderChargeInpatient]
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
			[PaidAmount],
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
			SUBSTRING(i.[DRG Definition],1,CHARINDEX(''-'', i.[DRG Definition])-2),
			''DRG'' code_type,
			SUBSTRING(i.[DRG Definition],CHARINDEX(''-'', i.[DRG Definition])+2,LEN(i.[DRG Definition])),
			cast('''+@serviceDate+''' as Date) service_date,
			i.[Average Total Payments],
			i.[Average Covered Charges],
			i.[Average Medicare Payments],
			cast(GETDATE() as date) import_date,
			'''+@sourceFileName+''' source_file_name,
			''CMS-DRG'' source_type

		FROM 
			[dbo].['+@sourceTableName+']  i

	'

	EXECUTE (@mergeSQL)
END


