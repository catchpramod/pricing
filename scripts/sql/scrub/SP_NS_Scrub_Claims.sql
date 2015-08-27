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
		IIF( n.[Entity_Type_Code]='1', n.First_Name, Null ) ,
		IIF( n.[Entity_Type_Code]='1', n.Middle_Name, Null ) ,
		IIF( n.[Entity_Type_Code]='1', 'I', 'O' ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_Address1, n.Mailing_Address1 ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_Address2, n.Mailing_Address2 ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_City, n.Mailing_City ),
		IIF( n.[Entity_Type_Code]='1', n.Practice_State, n.Mailing_State ),
		Left(IIF( n.[Entity_Type_Code]='1', n.Practice_Postal, n.Mailing_Postal ),5),
		'US',
		imp.[HCPCSCPTCode],
		'HCPCS',
		imp.HCPCSCPTCodeDescription,
		imp.Units,
		imp.BeginingDateofService,
		imp.PlaceOfService,
		imp.AllowedAmt,
		imp.BilledAmt,
		cast(GETDATE() as date),
		imp.SourceFile,
		imp.SourceClient
			  
			  
		from NS_Import.dbo.ClaimsCore imp
		left join Alithias_Common.dbo.MasterNPI n 
		on n.NPI = 
				CASE
					WHEN (imp.BillingProviderNPI = imp.RenderingProviderNPI OR imp.RenderingProviderNPI='0000000000')   THEN imp.BillingProviderNPI
					WHEN (imp.BillingProviderNPI != imp.RenderingProviderNPI AND imp.RenderingProviderNPI!='0000000000') 
					THEN 
						imp.RenderingProviderNPI
						--CASE WHEN imp.Modifier1 in ('26','25') THEN imp.RenderingProviderNPI
						--		ElSE imp.BillingProviderNPI
						--END
				END
		where 
			not (imp.[HCPCSCPTCode] is Null  OR imp.[HCPCSCPTCode]='') 
			and 
			cast(imp.BilledAmt as decimal) > 0
			and cast(imp.AllowedAmt as decimal) > 0



	Union


	SELECT distinct
		n.NPI,
		n.Organization_Name,
		Null,
		Null,
		'O',
		n.Mailing_Address1,
		n.Mailing_Address2,
		n.Mailing_City,
		n.Mailing_State,
		Left(n.Mailing_Postal,5),
		'US',
		imp.DRGCode,
		'DRG',
		imp.DRGCode,
		clk.Units,
		imp.BeginingDateofService,
		imp.PlaceOfService,
		clk.AllowedAmt,
		clk.BilledAmt,
		cast(GETDATE() as date),
		imp.SourceFile,
		imp.SourceClient

		from NS_Import.dbo.ClaimsCore imp
		inner join Alithias_Common.dbo.MasterNPI n 
		on n.NPI = imp.BillingProviderNPI
		inner join 
		(	SELECT
				ins.[ClaimKey],
				sum(ins.Units) units,
				sum(ins.AllowedAmt) AllowedAmt,
				sum(ins.BilledAmt) BilledAmt
		
				from NS_import.dbo.ClaimsCore ins
				where 
					not (ins.DRGCode is Null  OR ins.DRGCode='' OR ins.DRGCode ='0' OR ins.DRGCode='000') 
					and cast(ins.BilledAmt as decimal) > 0
					and cast(ins.AllowedAmt as decimal) > 0
				Group by 
				ins.[ClaimKey]
		) clk
		on imp.ClaimKey = clk.Claimkey
		where 
			not (imp.DRGCode is Null  OR imp.DRGCode='' OR imp.DRGCode ='0' OR imp.DRGCode='000') 
			and 
			cast(imp.BilledAmt as decimal) > 0
			and cast(imp.AllowedAmt as decimal) > 0
		





END
GO
