USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_002_CMS_Provider_Util_Payment_2012]    Script Date: 7/23/2015 1:18:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SP_NS_002_CMS_Provider_Util_Payment_2012]
AS
BEGIN


	INSERT INTO PricingCore
	(
		[ProviderNPI],
		[ProviderLastName],
		[ProviderFirstName],
		[ProviderMiddleName],
		[ProviderEntityCode],
		[ProviderStreet1],
		[ProviderStreet2],
		[ProviderCty],
		[ProviderState],
		[ProviderZip],
		[ProviderCountry],
		--[ProviderType],
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
		case when m.NPPES_ENTITY_CODE = 'I' then  m.nppes_provider_mi else NULL end as middle_name,
		m.nppes_entity_code,
		m.nppes_provider_street1,
		m.nppes_provider_street2,
		m.nppes_provider_city,
		m.nppes_provider_state,
		CASE WHEN LEN(m.nppes_provider_zip) = 9 or LEN(m.nppes_provider_zip) = 5  
             THEN LEFT(m.nppes_provider_zip, 5)
             ELSE LEFT(CONCAT('0', m.nppes_provider_zip), 5) 
        END  As zip
		,
		m.nppes_provider_country,
		--case 
		--	when m.nppes_entity_code <> 'I' 
		--	then 'Facility'
			
		--	when (m.nppes_entity_code = 'I' AND (PROVIDER_TYPE like '%anesthesiolog%'))
		--	then 'Anesthesia'

		--	when (m.nppes_entity_code = 'I' AND (PROVIDER_TYPE like '%radiation%' OR PROVIDER_TYPE like '%radiology%'))
		--	then 'Radiology'

		--	else 'Physician'
		--end 
		--as ProviderType,

		m.hcpcs_code,
		'HCPCS' service_code_type,
		m.hcpcs_description,
		CAST(m.line_srvc_cnt as float),
		cast('2012-06-30' as Date) service_date,
		m.place_of_service,
		m.average_Medicare_allowed_amt,
		m.average_submitted_chrg_amt,
		m.[AVERAGE_MEDICARE_PAYMENT_AMT],
		cast(GETDATE() as date) import_date,
		'Medicare_Provider_Util_Payment_PUF_CY2012' source_file_name,
		'CMS' source_type

	FROM 
		[dbo].[Medicare_Provider_Util_Payment_PUF_CY2012] m

END


