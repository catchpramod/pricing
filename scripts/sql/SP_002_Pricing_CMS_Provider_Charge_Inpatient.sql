SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_002_Pricing_CMS_Provider_Charge_Inpatient]
AS
BEGIN

	INSERT INTO NS_Pricing
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
		[AllowedAmount],
		[SubmittedAmount],
		[ImportedDate],
		[SourceFileName],
		[SourceType]
	)
	SELECT

		i.Provider_Id,
		i.Provider_Name,
		'O'  entity_code,
		i.Provider_Street_Address,
		i.Provider_City,
		i.Provider_State,
		CASE WHEN LEN(i.Provider_Zip_Code) = 9 or LEN(i.Provider_Zip_Code) = 5  
             THEN LEFT(i.Provider_Zip_Code, 5)
             ELSE LEFT(CONCAT('0', i.Provider_Zip_Code), 5) 
        END  As zip,
		'US' country,
		--'Facility' as providerType,
		i.DRG_Code,
		'DRG' code_type,
		i.DRG_Definition,
		i.Average_Total_Payments,
		i.Average_Covered_Charges,
		cast(GETDATE() as date) import_date,
		'Medicare_Provider_Charge_Inpatient_DRG100_FY2013.csv' soucre_file_name,
		'CMS' source_type

	FROM 
		[Alithias_ImportTest].[dbo].[Alithias_Drg] i

END


