USE [NS_Scrub]
GO

ALTER PROCEDURE [dbo].[SP_NS_Scrub_Claims] 
AS
BEGIN

	--IF OBJECT_ID('ClaimsCore') IS NOT NULL DROP TABLE ClaimsCore
	--CREATE TABLE ClaimsCore
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


	INSERT INTO ClaimsCore
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
		[ServiceCode],
		[ServiceCodeType],
		[ServiceCodeDesc],
		[ServiceUnits],
		[ServiceDate],
		[PlaceOfService],
		[AllowedAmount],
		[ChargedAmount],
		[ImportedDate],
		[SourceFileName],
		[SourceType]
	)
	SELECT
	
		n.NPI,
		IIF( n.[Entity_Type_Code]='1', n.Last_Name, n.Organization_Name) ,
		IIF( n.[Entity_Type_Code]='1', n.First_Name, '' ) ,
		IIF( n.[Entity_Type_Code]='1', n.Middle_Name, '' ) ,
		IIF( n.[Entity_Type_Code]='1', 'I', 'O' ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_Address1, n.Mailing_Address1 ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_Address2, n.Mailing_Address2 ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_City, n.Mailing_City ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_State, n.Mailing_State ),
		Left(IIF( n.[Entity_Type_Code]='1', n.Practice_Postal, n.Mailing_Postal ),5),
		'US',
		code,
		code_type,
		code_description,
		imp.Units,
		imp.BeginingDateofService,
		imp.PlaceOfService,
		imp.AllowedAmt,
		imp.BilledAmt,
		cast(GETDATE() as date),
		imp.SourceFile,
		imp.SourceClient
			  
			  
		from NS_Import.dbo.ClaimsCore imp
		inner join Alithias_Common.dbo.MasterNPI n 
		on n.NPI = 
				CASE
					WHEN (imp.BillingProviderNPI = imp.RenderingProviderNPI OR imp.RenderingProviderNPI='0000000000')   THEN imp.BillingProviderNPI
					WHEN (imp.BillingProviderNPI != imp.RenderingProviderNPI AND imp.RenderingProviderNPI!='0000000000') 
					THEN 
						CASE WHEN imp.Modifier1 in ('26','25') THEN imp.RenderingProviderNPI
								ElSE imp.BillingProviderNPI
						END
                   
				END

		CROSS APPLY
			(
			VALUES (DRGCode,'DRG', DRGCode ),([HCPCSCPTCode],'HCPCS', HCPCSCPTCodeDescription )
			) CA (code, code_type, code_description)	
	
		where 
			not (code is Null  OR code='' OR code ='0' OR code='000') 
			and cast(BilledAmt as decimal) > 0
			and cast(AllowedAmt as decimal) > 0


END
GO
