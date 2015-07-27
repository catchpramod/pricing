USE [NS_Import]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_007_CMS_Provider_Charge_Outpatient_2012]    Script Date: 7/23/2015 3:34:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SP_NS_007_CMS_Provider_Charge_Outpatient_2012]
AS
BEGIN

	INSERT INTO PricingCore
	(
		[ProviderID],
		[ProviderLastName],
		[ProviderEntityCode],
		[ProviderStreet1],
		[ProviderCty],
		[ProviderState],
		[ProviderZip],
		[ProviderCountry],
		--[ProviderType],
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
		'O'  entity_code,
		i.[Provider Street Address],
		i.[Provider City],
		i.[Provider State],
		CASE WHEN LEN(i.[Provider Zip Code]) = 9 or LEN(i.[Provider Zip Code]) = 5  
             THEN LEFT(i.[Provider Zip Code], 5)
             ELSE LEFT(CONCAT('0', i.[Provider Zip Code]), 5) 
        END  As zip,
		'US' country,
		--'Facility' as providerType,
		SUBSTRING(i.[APC],1,CHARINDEX('-', i.[APC])-2),
		'APC' code_type,
		SUBSTRING(i.[APC],CHARINDEX('-', i.[APC])+2,LEN(i.[APC])),
		cast('2012-06-30' as Date) service_date,
		i.[Average Total Payments],
		i.[Average  Estimated Submitted Charges],
		cast(GETDATE() as date) import_date,
		'Medicare_Provider_Charge_Outpatient_APC30_CY2012.csv' source_file_name,
		'CMS' source_type

	FROM 
		[dbo].[Medicare_Provider_Charge_Outpatient_APC30_CY2012]  i

END


