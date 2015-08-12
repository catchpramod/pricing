USE [NS_Scrub]
GO

ALTER PROCEDURE [dbo].[SP_NS_Scrub] 
AS
BEGIN

	--IF OBJECT_ID('PricingCore') IS NOT NULL DROP TABLE PricingCore
	--CREATE TABLE PricingCore
	--(
	--	[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
	--	[ProviderID] VARCHAR(80) NULL,
	--	[ProviderNPI]  VARCHAR(80) NULL,
	--	[ProviderLastName]  VARCHAR(250) NULL,
	--	[ProviderFirstName]  VARCHAR(80) NULL,
	--	[ProviderMiddleName]  VARCHAR(80) NULL,
	--	[ProviderEntityCode]  VARCHAR(20) NULL,
	--	[ProviderStreet1]  VARCHAR(256) NULL,
	--	[ProviderStreet2]  VARCHAR(256) NULL,
	--	[ProviderCty]  VARCHAR(80) NULL,
	--	[ProviderState]  VARCHAR(80) NULL,
	--	[ProviderZip]  VARCHAR(80) NULL,
	--	[ProviderCountry]  VARCHAR(80) NULL,
	--	[NetworkID] VARCHAR(80) NULL,
	--	[NetworkName]  VARCHAR(250) NULL,
	--	[ServiceCode]  VARCHAR(80) NULL,
	--	[ServiceCodeType]  VARCHAR(80) NULL,
	--	[ServiceCodeDesc]  VARCHAR(256) NULL,
	--	[ServiceUnits]  float,
	--	[ServiceDate]  VARCHAR(80) NULL,
	--	[PlaceOfService]  VARCHAR(80) NULL,
	--	[PrimaryModifier]  VARCHAR(80) NULL,
	--	[SecondaryModifier]  VARCHAR(80) NULL,
	--	[AllowedAmount]  DECIMAL(15,2) NULL,
	--	[ChargedAmount]   DECIMAL(15,2) NULL,
	--	[PaidAmount]   DECIMAL(15,2) NULL,
	--	[UDF1]  VARCHAR(80) NULL,
	--	[UDF2]  VARCHAR(80) NULL,
	--	[UDF3]  VARCHAR(80) NULL,
	--	[UDF4]  VARCHAR(80) NULL,
	--	[UDF5]  VARCHAR(80) NULL,
	--	[ImportedDate]  VARCHAR(80) NULL,
	--	[SourceFileName]  VARCHAR(80) NULL,
	--	[SourceType]  VARCHAR(80) NULL
	--)


	INSERT INTO PricingCore
	(
		[ProviderID],
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
		 imp.[ProviderID],
		 imp.[ProviderNPI],
		 imp.[ProviderLastName],
		 imp.[ProviderFirstName],
		 imp.[ProviderMiddleName],
		 imp.[ProviderEntityCode],
		 imp.[ProviderStreet1],
		 imp.[ProviderStreet2],
		 imp.[ProviderCity],
		 imp.[ProviderState],
		 imp.[ProviderZip],
		 imp.[ProviderCountry],
		 imp.[ServiceCode],
		 imp.[ServiceCodeType],
		 imp.[ServiceCodeDesc],
		 imp.[ServiceUnits],
		 imp.[ServiceDate],
		 imp.[PlaceOfService],
		 imp.[AllowedAmount],
		 imp.[ChargedAmount],
		 imp.[PaidAmount],
		 imp.[ImportedDate],
		 imp.[SourceFileName],
		 imp.[SourceType]
	From [NS_Import].dbo.PricingCore imp
	
	-- NPI Update, match provider id, update NPI
	update [dbo].[PricingCore]
	set ProviderNPI = n.ProviderNPI       
	from [dbo].[PricingCore] c
	left join
	 dbo.ProviderMapping n
	on
	 c.ProviderID = n.ProviderId
	where c.ProviderNPI IS NULL



	-- NPI update for remaining unmatched records, match organization name and zip code
	update [dbo].[PricingCore]
	set ProviderNPI = n.NPI       
	from [dbo].[PricingCore] c
	left join
	(
	 select  np.NPI,np.Organization_Name,np.Other_Organization_Name,np.Mailing_Postal from Alithias_Common.dbo.MasterNPI np
	 where np.First_Name is NULL
	)n
    on
	(
		(
			replace(c.ProviderLastName,'.''','')  = replace(n.Organization_Name,'.''','') 
			or 
			replace(c.ProviderLastName,'.''','')  = replace(n.Other_Organization_Name,'.''','')
		)
		and 
		c.ProviderZip = substring(n.Mailing_Postal,1,5)
	)
	where ProviderNPI IS NULL

END
GO
