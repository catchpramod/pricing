USE [NS_Import]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_NS_Merge_PayerCompass]
@sourceFileName varchar(200),
@sourceTableName varchar(200)

AS
BEGIN
	declare @mergeSQL varchar(max)


	set @mergeSQL=
	'
		INSERT INTO PricingCore
		(
			[ProviderNPI],
			[ProviderEntityCode],
			[ProviderState],
			[ProviderZip],
			[ProviderCountry],
			[ServiceCode],
			[ServiceCodeType],
			[ServiceUnits],
			[ServiceDate],
			[AllowedAmount],
			[ImportedDate],
			[SourceFileName],
			[SourceType]
		)
		SELECT
			[NPI]
			,case when ([ServiceType] = ''DRG'' OR [ServiceType] = ''APC'' OR [ServiceType] = ''ASC'' )then  ''O'' else ''I'' end as providerType
			,[State]
			,[PostalCode]
			,''US''
			,[ServiceCode]
			,case when [ServiceType] = ''DRG'' then  ''DRG'' else ''HCPCS'' end as codeType
			,[ServiceUnits]
			,cast([ServiceDate] as date) 
			,[FacilityRate]
			,cast([DownloadDate] as date) 
			,'''+@sourceFileName+''' source_file_name
			,''PayerCompass''

		FROM 
			[dbo].['+@sourceTableName+'] m
		
		where FacilityRate > 0
	'

	EXECUTE (@mergeSQL)
END
