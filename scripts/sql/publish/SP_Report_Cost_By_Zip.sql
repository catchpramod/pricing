USE [NS_Publish]
GO

ALTER PROCEDURE SP_Report_Cost_By_Zip
	
AS
BEGIN
	--IF OBJECT_ID('ServiceCostByZip') IS NOT NULL DROP TABLE ServiceCostByZip

	--Create  TABLE ServiceCostByZip
	--(
	--	[ServiceCode]  VARCHAR(20) NULL,
		--[ServiceCodeType]  VARCHAR(20) NULL,
		--[ProviderEntityCode]  VARCHAR(5) NULL,
		--[ProviderZip]  VARCHAR(10) NULL,
		--[ProviderState]  VARCHAR(20) NULL,

		--[ClaimsAllowed]  DECIMAL(10,2) NULL,
		--[ClaimsCharged]  DECIMAL(10,2) NULL,

		--[MedicareAllowed]  DECIMAL(10,2) NULL,
		--[MedicareCharged]  DECIMAL(10,2) NULL,

		--[AvgAllowed]  DECIMAL(10,2) NULL,
		--[AvgMultiplier]  DECIMAL(10,2) NULL,
		--[Approximate]  Varchar(10) NULL,
		--[GenerateDate] DATE NULL,
		--[Source]  Varchar(50) NULL
		
	--)

	-- Step 1: Get pricing from claims, claims don't need multiplier, just use claims allowed amount, find pricing for remaining code+zip cost from CMS

	Insert into ServiceCostByZip
	Select cl.[ServiceCode], cl.[ServiceCodeType],cl.[ProviderEntityCode], cl.[ProviderZip], cl.[ProviderState], 
			avg(cl.AllowedAmount) ClaimsAllowed, avg(cl.ChargedAmount) ClaimsCharged,
			avg(pc.AllowedAmount) MedicareAllowed, avg(pc.ChargedAmount) MedicareCharged,
			avg(cl.AllowedAmount) as AvgAllowed, 1 as AvgMultiplier, 'No',
			cast(GETDATE() as date) GenerateDate,
			'Claims' as Source


	From [NS_Scrub].[dbo].[ClaimsCore] cl
	left join (
				select ipc.[ServiceCode], ipc.[ServiceCodeType],ipc.[ProviderEntityCode], ipc.[ProviderZip], ipc.[ProviderState], avg(ipc.AllowedAmount) AllowedAmount, avg(ipc.ChargedAmount) ChargedAmount
				from [NS_Scrub].[dbo].[PricingCore] ipc
				group by ipc.[ServiceCode], ipc.[ServiceCodeType],ipc.[ProviderEntityCode], ipc.[ProviderZip], ipc.[ProviderState]
			) pc
	on pc.[ServiceCode]=cl.[ServiceCode] and pc.[ServiceCodeType] =cl.[ServiceCodeType] and pc.[ProviderEntityCode]=cl.[ProviderEntityCode] and  pc.[ProviderZip]=cl.[ProviderZip] and  pc.[ProviderState]=cl.[ProviderState]  

	group by cl.[ServiceCode], cl.[ServiceCodeType],cl.[ProviderEntityCode], cl.[ProviderZip], cl.[ProviderState]

	
	
	
	-- Step 2: Get remaining pricing from PricingCore 

	INSERT INTO ServiceCostByZip
	  SELECT  pc.[ServiceCode], pc.[ServiceCodeType],pc.[ProviderEntityCode], pc.[ProviderZip], pc.[ProviderState], 
			avg(cl.AllowedAmount) ClaimsAllowed, avg(cl.ChargedAmount) ClaimsCharged,
			avg(pc.AllowedAmount) MedicareAllowed, avg(pc.ChargedAmount) MedicareCharged,
			avg(pc.AllowedAmount) as AvgAllowed,
			--IIF(avg(m.[Multiplier]) IS NOT NULL,avg(pc.AllowedAmount), avg(pc.ChargedAmount)*0.7 )  as AvgAllowed, 
			avg(m.[Multiplier]) as AvgMultiplier,
			'No',
			cast(GETDATE() as date) GenerateDate,
			IIF(avg(m.[Multiplier]) IS NOT NULL, 'CMS with multiplier match', 'CMS with no match(amount=0.7*Charged)') as Source

	  FROM [NS_Scrub].[dbo].[PricingCore] pc
	  left join 
			(
				select ipc.[ServiceCode], ipc.[ServiceCodeType],ipc.[ProviderEntityCode], ipc.[ProviderZip], ipc.[ProviderState], avg(ipc.AllowedAmount) AllowedAmount, avg(ipc.ChargedAmount) ChargedAmount
				from [NS_Scrub].[dbo].[ClaimsCore] ipc
				group by ipc.[ServiceCode], ipc.[ServiceCodeType],ipc.[ProviderEntityCode], ipc.[ProviderZip], ipc.[ProviderState]
			) cl
		on
		pc.[ServiceCode]=cl.[ServiceCode] and pc.[ServiceCodeType] =cl.[ServiceCodeType] and pc.[ProviderEntityCode]=cl.[ProviderEntityCode] and  pc.[ProviderZip]=cl.[ProviderZip] and  pc.[ProviderState]=cl.[ProviderState]  

	  left join [NS_Scrub].[dbo].[Multiplier] m
			on 
			m.[ProviderEntityCode]= pc.[ProviderEntityCode]
			and m.[ProviderZip] =pc.[ProviderZip]
			and m.[ServiceCode] =pc.[ServiceCode]
			and m.[ServiceCodeType] =pc.[ServiceCodeType]

	  where 
		NOT EXISTS ( 
						select top 1 1 from dbo.ServiceCostByZip cz
							where		cz.[ProviderEntityCode]= pc.[ProviderEntityCode]
									and cz.[ProviderZip] =pc.[ProviderZip]
									and cz.[ServiceCode] =pc.[ServiceCode]
									and cz.[ServiceCodeType] =pc.[ServiceCodeType]
						)
			
	  group by pc.[ServiceCode], pc.[ServiceCodeType],pc.[ProviderEntityCode], pc.[ProviderZip], pc.[ProviderState]
  





    -- Step 3: If multiplier is still not found, update by similar service code multiplier (4 digit match)

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes', Source='CMS with first 4 service code digit match'
	FROM dbo.ServiceCostByZip p
	inner join 
	( 
		select  substring(i.[ServiceCode],1,4) ServiceCode, i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		where not i.Multiplier IS NULL
		group by substring(i.[ServiceCode],1,4), i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip]
	) m
	on  
		m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderZip]=p.[ProviderZip]
		and substring(m.[ServiceCode],1,4) =substring(p.[ServiceCode],1,4)
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL




	 -- Step 4: If multiplier is still not found, update by similar service code multiplier (3 digit match)

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes', Source='CMS with first 3 service code digit match'
	FROM dbo.ServiceCostByZip p
	inner join 
	( 
		select  substring(i.[ServiceCode],1,3) ServiceCode, i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		where not i.Multiplier IS NULL
		group by substring(i.[ServiceCode],1,3), i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip]
	) m
	on  
		m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderZip]=p.[ProviderZip]
		and substring(m.[ServiceCode],1,3) =substring(p.[ServiceCode],1,3)
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL

	
	
	
	-- Step 5: If multiplier is still not found, update by area average for the service code

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes', Source='CMS with first 3 zip code digit match'
	FROM dbo.ServiceCostByZip p
	inner join 
	( 
		select  i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		group by i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode],  i.[ProviderZip]
	) m
	on  
		m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and  substring(m.[ProviderZip],1,3) =substring(p.[ProviderZip],1,3)
		and m.[ServiceCode] =p.[ServiceCode]
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL

	
	
	
	-- Step 6: If multiplier is still not found, update by state average for the service code

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes', Source='CMS with state match'
	FROM dbo.ServiceCostByZip p
	inner join 
	( 
		select  i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderState], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		group by i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderState]
	) m
	on  
		m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderState]=p.[ProviderState]
		and m.[ServiceCode] =p.[ServiceCode]
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL



END
GO
