USE [NS_Publish]
GO

ALTER PROCEDURE SP_Report_Cost_By_NPI
	
AS
BEGIN
	--IF OBJECT_ID('ServiceCostByNPI') IS NOT NULL DROP TABLE ServiceCostByNPI

	--Create  TABLE ServiceCostByNPI
	--(
	--	[ProviderNPI]  VARCHAR(20) NULL,
	--	[ProviderEntityCode]  VARCHAR(5) NULL,
	--	[ServiceCode]  VARCHAR(20) NULL,
	--	[ServiceCodeType]  VARCHAR(20) NULL,
	--	[ProviderZip]  VARCHAR(10) NULL,
	--	[ProviderState]  VARCHAR(20) NULL,
	--	[AvgAllowed]  DECIMAL(10,2) NULL,
	--	[AvgMultiplier]  DECIMAL(10,2) NULL,
	--	[Approximate]  Varchar(10) NULL
	--)

	--Get pricing from claims, claims don't need multiplier, just use claims allowed amount, find pricing for remaining code+zip cost from CMS

	Insert into ServiceCostByNPI
	Select ProviderNpi,[ProviderEntityCode], [ServiceCode], [ServiceCodeType], [ProviderZip], [ProviderState], 
		avg(AllowedAmount) as AvgAllowed, 1 as AvgMultiplier, 'No'
	From [NS_Scrub].[dbo].[ClaimsCore] cl
	group by ProviderNpi, [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState]


	-- Get remaining pricing from PricingCore 

	INSERT INTO ServiceCostByNPI
	  SELECT  ProviderNpi,[ProviderEntityCode], [ServiceCode], [ServiceCodeType], [ProviderZip], [ProviderState], 
		avg(AllowedAmount),
		(
			SELECT avg([Multiplier])
			FROM [NS_Scrub].[dbo].[Multiplier] m
			where 
			m.[ProviderNPI]= p.[ProviderNPI]
			and m.[ProviderEntityCode]= p.[ProviderEntityCode]
			and m.[ProviderState]=p.[ProviderState]
			and m.[ProviderZip] =p.[ProviderZip]
			and m.[ServiceCode] =p.[ServiceCode]
			and m.[ServiceCodeType] =p.[ServiceCodeType]
		) as AvgMultiplier,
		'No' Approx
	

	  FROM [NS_Scrub].[dbo].[PricingCore] p
	  where NOT EXISTS ( 
						select top 1 1 from dbo.ServiceCostByNPI cz
							where		
									cz.[ProviderNPI]= p.[ProviderNPI]
									and cz.[ProviderEntityCode]= p.[ProviderEntityCode]
									and cz.[ProviderState]=p.[ProviderState]
									and cz.[ProviderZip] =p.[ProviderZip]
									and cz.[ServiceCode] =p.[ServiceCode]
									and cz.[ServiceCodeType] =p.[ServiceCodeType]
						)
			and len(p.ProviderNPI)>0
	  group by [ProviderNPI], [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState]
  
    -- If multiplier is still not found, update by similar service code multiplier (4 digit match)

	Update dbo.ServiceCostByNPI set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
	FROM dbo.ServiceCostByNPI p
	inner join 
	( 
		select i.ProviderNPI, substring(i.[ServiceCode],1,4) ServiceCode, i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		where not i.Multiplier IS NULL
		group by i.ProviderNPI, substring(i.[ServiceCode],1,4), i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip]
	) m
	on  
		m.ProviderNPI= p.ProviderNPI
		and m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderZip]=p.[ProviderZip]
		and substring(m.[ServiceCode],1,4) =substring(p.[ServiceCode],1,4)
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL


	 -- If multiplier is still not found, update by similar service code multiplier (3 digit match)

	Update dbo.ServiceCostByNPI set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
	FROM dbo.ServiceCostByNPI p
	inner join 
	( 
		select i.ProviderNPI, substring(i.[ServiceCode],1,3) ServiceCode, i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		where not i.Multiplier IS NULL
		group by i.ProviderNPI, substring(i.[ServiceCode],1,3), i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip]
	) m
	on  m.ProviderNPI= p.ProviderNPI
		and m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderZip]=p.[ProviderZip]
		and substring(m.[ServiceCode],1,3) =substring(p.[ServiceCode],1,3)
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL


	-- If multiplier is still not found, update by zip average for the service code

	Update dbo.ServiceCostByNPI set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
	FROM dbo.ServiceCostByNPI p
	inner join 
	( 
		select  i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip], avg(i.Multiplier) AvgMultiplier
		from [NS_Scrub].[dbo].[Multiplier] i
		group by i.[ServiceCode], i.[ServiceCodeType],i.[ProviderEntityCode], i.[ProviderZip]
	) m
	on  
		m.[ProviderEntityCode]= p.[ProviderEntityCode]
		and m.[ProviderZip]=p.[ProviderZip]
		and m.[ServiceCode] =p.[ServiceCode]
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL

	 -- If multiplier is still not found, update by state average for the service code

	Update dbo.ServiceCostByNPI set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
	FROM dbo.ServiceCostByNPI p
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
