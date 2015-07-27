USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_001_CMS_Provider_Util_Payment_2013]    Script Date: 7/23/2015 1:19:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SP_NS_001_CMS_Provider_Util_Payment_2013]
AS
BEGIN

	IF OBJECT_ID('PricingCore') IS NOT NULL DROP TABLE PricingCore
	CREATE TABLE PricingCore
	(
		[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
		[ProviderID] VARCHAR(80) NULL,
		[ProviderNPI]  VARCHAR(80) NULL,
		[ProviderLastName]  VARCHAR(250) NULL,
		[ProviderFirstName]  VARCHAR(80) NULL,
		[ProviderMiddleName]  VARCHAR(80) NULL,
		[ProviderEntityCode]  VARCHAR(20) NULL,
		[ProviderStreet1]  VARCHAR(256) NULL,
		[ProviderStreet2]  VARCHAR(256) NULL,
		[ProviderCty]  VARCHAR(80) NULL,
		[ProviderState]  VARCHAR(80) NULL,
		[ProviderZip]  VARCHAR(80) NULL,
		[ProviderCountry]  VARCHAR(80) NULL,
		[NetworkID] VARCHAR(80) NULL,
		[NetworkName]  VARCHAR(250) NULL,
		--[ProviderType]  VARCHAR(50) NULL,
		[ServiceCode]  VARCHAR(80) NULL,
		[ServiceCodeType]  VARCHAR(80) NULL,
		[ServiceCodeDesc]  VARCHAR(256) NULL,
		[ServiceUnits]  float,
		[ServiceDate]  VARCHAR(80) NULL,
		[PlaceOfService]  VARCHAR(80) NULL,
		[PrimaryModifier]  VARCHAR(80) NULL,
		[SecondaryModifier]  VARCHAR(80) NULL,
		[AllowedAmount]  DECIMAL(15,2) NULL,
		[ChargedAmount]   DECIMAL(15,2) NULL,
		[PaidAmount]   DECIMAL(15,2) NULL,
		[UDF1]  VARCHAR(80) NULL,
		[UDF2]  VARCHAR(80) NULL,
		[UDF3]  VARCHAR(80) NULL,
		[UDF4]  VARCHAR(80) NULL,
		[UDF5]  VARCHAR(80) NULL,
		[ImportedDate]  VARCHAR(80) NULL,
		[SourceFileName]  VARCHAR(80) NULL,
		[SourceType]  VARCHAR(80) NULL
	)


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
		cast('2013-06-30' as Date) service_date,
		m.place_of_service,
		m.average_Medicare_allowed_amt,
		m.average_submitted_chrg_amt,
		m.[AVERAGE_MEDICARE_PAYMENT_AMT],
		cast(GETDATE() as date) import_date,
		'Medicare_Provider_Util_Payment_PUF_CY2013' source_file_name,
		'CMS' source_type

	FROM 
		[dbo].[Medicare_Provider_Util_Payment_PUF_CY2013] m

END


