USE [NS_Scrub]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Generate_Multiplier]    Script Date: 8/11/2015 6:13:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_NS_Multiplier_Scrub]
	
AS
BEGIN
	--IF OBJECT_ID('MultiplierRaw') IS NOT NULL DROP TABLE MultiplierRaw

	--Create  TABLE MultiplierRaw
	--(
	--	[ProviderNPI]  VARCHAR(20) NULL,
	--	[ProviderEntityCode]  VARCHAR(5) NULL,
	--	[ProviderState]  VARCHAR(20) NULL,
	--	[ProviderZip]  VARCHAR(10) NULL,
	--	[ServiceCode]  VARCHAR(20) NULL,
	--	[ServiceCodeType]  VARCHAR(20) NULL,
	--	[Multiplier]  DECIMAL(10,2) NULL,
	--	[Discount]   DECIMAL(10,2) NULL,
	--	[GenerateDate] DATE NULL,
	--	[Source] VARCHAR(20) NULL
	--)


	INSERT INTO MultiplierRaw
	(
		[ProviderNPI],
		[ProviderEntityCode],
		[ProviderState],
		[ProviderZip],
		[ServiceCode],
		[ServiceCodeType],
		[Multiplier],
		[Discount],
		[GenerateDate],
		[Source]
	)

	
		select

			cl.[ProviderNPI],
			cl.[ProviderEntityCode],
			cl.[ProviderState],
			cl.[ProviderZip],
			cl.[ServiceCode],
			cl.[ServiceCodeType],
			(cl.AllowedAmount/pc.AllowedAmount) Multiplier,
			(1-cl.AllowedAmount/cl.ChargedAmount)*100 Discount,
			cast(GETDATE() as date) GenerateDate,
			'CLAIMS' Source
	
			From dbo.ClaimsCore cl
			Inner Join dbo.PricingCore pc

			on 
			pc.ProviderNPI = cl.[ProviderNPI]
			and pc.ServiceCode = cl.[ServiceCode]
			and pc.ServiceCodeType = cl.[ServiceCodeType]
			and pc.ProviderEntityCode=cl.[ProviderEntityCode]
	
			where 
				pc.AllowedAmount > 0.0
				and cl.AllowedAmount > pc.AllowedAmount 
				

END
