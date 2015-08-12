USE [NS_Publish]
GO

ALTER PROCEDURE SP_Report_Cost_By_Zip
	
AS
BEGIN
	--IF OBJECT_ID('ServiceCostByZip') IS NOT NULL DROP TABLE ServiceCostByZip

	--Create  TABLE ServiceCostByZip
	--(
	--	[ServiceCode]  VARCHAR(20) NULL,
	--	[ServiceCodeType]  VARCHAR(20) NULL,
	--	[ProviderEntityCode]  VARCHAR(5) NULL,
	--	[ProviderZip]  VARCHAR(10) NULL,
	--	[ProviderState]  VARCHAR(20) NULL,
	--	[AvgAllowed]  DECIMAL(10,2) NULL,
	--	[AvgMultiplier]  DECIMAL(10,2) NULL,
	--	[Approximate]  Varchar(10) NULL
	--)

	--Get pricing from claims, claims don't need multiplier, just use claims allowed amount, find pricing for remaining code+zip cost from CMS

	Insert into ServiceCostByZip
	Select [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState], 
		avg(AllowedAmount) as AvgAllowed, 1 as AvgMultiplier, 'No'
	From [NS_Scrub].[dbo].[ClaimsCore] cl
	group by [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState]

	-- Get remaining pricing from PricingCore 

	INSERT INTO ServiceCostByZip
	  SELECT  [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState], 
		avg(AllowedAmount) as AvgAllowed, 
		(
			SELECT avg([Multiplier])
			FROM [NS_Scrub].[dbo].[Multiplier] m
			where 
			m.[ProviderEntityCode]= p.[ProviderEntityCode]
			and m.[ProviderState]=p.[ProviderState]
			and m.[ProviderZip] =p.[ProviderZip]
			and m.[ServiceCode] =p.[ServiceCode]
			and m.[ServiceCodeType] =p.[ServiceCodeType]
		) as AvgMultiplier,
		'No'
	

	  FROM [NS_Scrub].[dbo].[PricingCore] p
	  where NOT EXISTS ( 
						select top 1 1 from dbo.ServiceCostByZip cz
							where		cz.[ProviderEntityCode]= p.[ProviderEntityCode]
									and cz.[ProviderState]=p.[ProviderState]
									and cz.[ProviderZip] =p.[ProviderZip]
									and cz.[ServiceCode] =p.[ServiceCode]
									and cz.[ServiceCodeType] =p.[ServiceCodeType]
						)
	  group by [ServiceCode], [ServiceCodeType],[ProviderEntityCode], [ProviderZip], [ProviderState]
  
    -- If multiplier is still not found, update by similar service code multiplier (4 digit match)

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
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
		and substring(m.[ServiceCode],1,4) =p.[ServiceCode]
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL

  -- If multiplier is still not found, update by state average for the service code

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
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


	 -- If multiplier is still not found, update by similar service code multiplier (3 digit match)

	Update dbo.ServiceCostByZip set AvgMultiplier = m.AvgMultiplier, Approximate='Yes'
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
		and substring(m.[ServiceCode],1,4) =p.[ServiceCode]
		and m.[ServiceCodeType] =p.[ServiceCodeType] 
	where p.AvgMultiplier IS NULL




END
GO
