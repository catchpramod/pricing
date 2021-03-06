USE [NS_Import]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_NS_Merge_ProviderUtilPayment]
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
			[ProviderNPI],
			[ProviderLastName],
			[ProviderFirstName],
			[ProviderMiddleName],
			[ProviderEntityCode],
			[ProviderStreet1],
			[ProviderStreet2],
			[ProviderCity],
			[ProviderState],
			[ProviderZip],
			[ProviderCountry],
			[ServiceCode],
			[ServiceCodeType],
			[ServiceCodeDesc],
			[ServiceUnits],
			[ServiceDate],
			[PlaceOfService],
			[AllowedAmount],
			[ChargedAmount],
			[PaidAmount],
			[ImportedDate],
			[SourceFileName],
			[SourceType]
		)
		SELECT
			m.npi,
			m.nppes_provider_last_org_name,
			m.nppes_provider_first_name,
			case when m.NPPES_ENTITY_CODE = ''I'' then  m.nppes_provider_mi else NULL end as middle_name,
			m.nppes_entity_code,
			m.nppes_provider_street1,
			m.nppes_provider_street2,
			m.nppes_provider_city,
			m.nppes_provider_state,
			CASE WHEN LEN(m.nppes_provider_zip) = 9 or LEN(m.nppes_provider_zip) = 5  
				 THEN LEFT(m.nppes_provider_zip, 5)
				 ELSE LEFT(CONCAT(''0'', m.nppes_provider_zip), 5) 
			END  As zip
			,
			m.nppes_provider_country,
			m.hcpcs_code,
			''HCPCS'' service_code_type,
			m.hcpcs_description,
			CAST(m.line_srvc_cnt as float),
			cast('''+@serviceDate+''' as Date) service_date,
			m.place_of_service,
			m.average_Medicare_allowed_amt,
			m.average_submitted_chrg_amt,
			m.[AVERAGE_MEDICARE_PAYMENT_AMT],
			cast(GETDATE() as date) import_date,
			'''+@sourceFileName+''' source_file_name,
			''CMS-Util'' source_type

		FROM 
			[dbo].['+@sourceTableName+'] m
	'

	EXECUTE (@mergeSQL)
END


