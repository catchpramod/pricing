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
		 cl.NPI, cl.Entity_Type, pc.ProviderState, pc.ProviderZip, cl.code, cl.code_type,
		 (cl.allowed/pc.AllowedAmount)	Multiplier, cl.discount, cast(GETDATE() as date) gen_date, 'CLAIMS' src
		from (
				select 
					   code,code_type
					  ,cast(BilledAmt as decimal) billed
					  ,[PlaceOfService]
					  ,[DRGCode]
					  ,cast(AllowedAmt as decimal) allowed
					  ,Modifier1
					  ,CompanyCode
					  ,[NetworkCode]
					  ,n.NPI, IIF( n.[Entity_Type_Code]='1', 'I', 'O' ) Entity_Type
					  ,(1-cast(AllowedAmt as decimal)/cast(BilledAmt as decimal))*100 discount
			  
			  
			  
				from NS_Import.dbo.ClaimsCore c 
				inner join Alithias_Common.dbo.MasterNPI n 
				on n.NPI = 
						CASE
							WHEN (c.BillingProviderNPI = c.RenderingProviderNPI OR c.RenderingProviderNPI='0000000000')   THEN c.BillingProviderNPI
							WHEN (c.BillingProviderNPI != c.RenderingProviderNPI AND c.RenderingProviderNPI!='0000000000') 
							THEN 
								CASE WHEN c.Modifier1 in ('26','25') THEN c.RenderingProviderNPI
									 ElSE c.BillingProviderNPI
								END
                   
						END

				CROSS APPLY
				  (
					VALUES (DRGCode,'DRG'),([HCPCSCPTCode],'HCPCS')
				  ) CA (code, code_type)	
	
				where 
				 not (code is Null  OR code='') 
				 and cast(BilledAmt as decimal) > 0
				 and cast(AllowedAmt as decimal) > 0

			) cl
	
			Inner Join dbo.PricingCore pc
			on 
			pc.ProviderNPI = cl.NPI
			and pc.ServiceCode = cl.code
			and pc.ServiceCodeType = cl.code_type
			and pc.ProviderEntityCode=cl.Entity_Type
	
			where 
				pc.AllowedAmount > 0.0
				

END
