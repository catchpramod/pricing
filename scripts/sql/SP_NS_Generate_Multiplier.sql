USE [NS_Scrub]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Generate_Multiplier]    Script Date: 7/29/2015 11:54:07 AM ******/

CREATE PROCEDURE [dbo].[SP_NS_Generate_Multiplier]
	
AS
BEGIN
	IF OBJECT_ID('Multiplier') IS NOT NULL DROP TABLE Multiplier
	--NPI	Entity_Type	code	code_type	ProviderZip	ProviderState	AvgMedicareAllowed	AvgBilled	AvgAllowed	
	--Multiplier


	CREATE TABLE Multiplier
	(
		[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
		[ProviderNPI]  VARCHAR(20) NULL,
		[ProviderEntityCode]  VARCHAR(5) NULL,
		[ProviderState]  VARCHAR(20) NULL,
		[ProviderZip]  VARCHAR(10) NULL,
		[ServiceCode]  VARCHAR(20) NULL,
		[ServiceCodeType]  VARCHAR(20) NULL,
		[Multiplier]  DECIMAL(5,2) NULL,
		[Discount]   DECIMAL(5,2) NULL,
		[GenerateDate] DATE NULL,
		[Source] VARCHAR(20) NULL
	)


	INSERT INTO Multiplier
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
		 --avg(cast(pc.AllowedAmount as decimal))	AvgMedicareAllowed,avg(cast(cl.AMOUNT_BILLED as decimal))	AvgBilled,avg(cast(cl.AMOUNT_ALLOWED as decimal))	AvgAllowed,
		 avg(cast(cl.AMOUNT_ALLOWED as decimal))/avg(cast(pc.AllowedAmount as decimal))	Multiplier,
		 (1-avg(cast(cl.AMOUNT_ALLOWED as decimal))/avg(cast(cl.AMOUNT_BILLED as decimal)))*100	Discount,
		 cast(GETDATE() as date) gen_date,
		 'CLAIMS' src
		from (
				select 
					   code,code_type
					--  ,[PROCEDURE_CODE]
					  ,[AMOUNT_BILLED]
					  ,[PLACE_OF_SERVICE_CODE]
					  ,[DRG_CODE]
					  ,[AMOUNT_ALLOWED]
					  ,[MODIFIER_1]
					  ,[Group_Name]
					  ,[Network_Name]
					  ,n.NPI, IIF( n.[Entity_Type_Code]='1', 'I', 'O' ) Entity_Type
			  
			  
			  
				from Alithias_Import.dbo.AI_Claims_CYPRESS c 
				inner join Alithias_Common.dbo.MasterNPI n 
				on n.NPI = 
						CASE
							WHEN (c.BILLING_PROVIDER_NPI = c.TREATING_NPI OR c.TREATING_NPI='0000000000')   THEN c.BILLING_PROVIDER_NPI
							WHEN (c.BILLING_PROVIDER_NPI != c.TREATING_NPI AND c.TREATING_NPI!='0000000000') 
							THEN 
								CASE WHEN c.MODIFIER_1 in ('26','25') THEN c.TREATING_NPI
									 ElSE c.BILLING_PROVIDER_NPI
								END
                   
						END

				CROSS APPLY
				  (
					VALUES (DRG_CODE,'DRG'),([PROCEDURE_CODE],'HCPCS')
				  ) CA (code, code_type)	
	
				where 
				 not (code is Null  OR code='') 


			) cl
	
			Inner Join dbo.PricingCore pc
			on 
			pc.ProviderNPI = cl.NPI
			and pc.ServiceCode = cl.code
			and pc.ServiceCodeType = cl.code_type
			and pc.ProviderEntityCode=cl.Entity_Type
	
			where 
				cast(pc.AllowedAmount as decimal) > 0.0
				and
				cast(cl.AMOUNT_ALLOWED as decimal) > 0.0
	
			group by
			cl.NPI ,cl.Entity_Type,cl.code,cl.code_type,pc.ProviderZip,pc.ProviderState

	


END
