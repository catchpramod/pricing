USE [NS_Scrub]
GO

CREATE TABLE [dbo].[ProviderMapping](
	[ProviderId] [varchar](50) NULL,
	[ProviderName] [varchar](55) NULL,
	[ProviderAddress] [varchar](47) NULL,
	[ProviderCity] [varchar](16) NULL,
	[ProviderState] [varchar](2) NULL,
	[ProviderZip Code] [varchar](50) NULL,
	[ProviderNPI] [varchar](50) NULL
) 
GO

Insert into [dbo].[ProviderMapping](
	[ProviderId] ,
	[ProviderName] ,
	[ProviderAddress] ,
	[ProviderCity] ,
	[ProviderState],
	[ProviderZip Code] ,
	[ProviderNPI] 
)
select distinct p.*
from [NS_Import].[dbo].[NPI_MAPPED] p
inner join
(
	select [Provider Id],  min([Provider Name]+[Provider Address] + [Provider City] + [Provider Zip Code]+ [Provider NPI]) as mc 
	from [NS_Import].[dbo].[NPI_MAPPED]
	group by [Provider Id]
) i
on p.[Provider Name]+p.[Provider Address] + p.[Provider City] + p.[Provider Zip Code]+ p.[Provider NPI] = i.mc