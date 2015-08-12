USE [NS_Scrub]
GO
/****** Object:  StoredProcedure [dbo].[SP_NS_Generate_Multiplier]    Script Date: 7/29/2015 3:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_NS_Generate_Multiplier]
	
AS
BEGIN

-- Average and filter outliars
	IF OBJECT_ID('Multiplier') IS NOT NULL DROP TABLE Multiplier

	Create  TABLE Multiplier
	(
		[ProviderNPI]  VARCHAR(20) NULL,
		[ProviderEntityCode]  VARCHAR(5) NULL,
		[ProviderState]  VARCHAR(20) NULL,
		[ProviderZip]  VARCHAR(10) NULL,
		[ServiceCode]  VARCHAR(20) NULL,
		[ServiceCodeType]  VARCHAR(20) NULL,
		[Multiplier]  DECIMAL(10,2) NULL,
		[Discount]   DECIMAL(10,2) NULL,
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
		  tmo.[ProviderNPI],
		  tmo.[ProviderEntityCode],
		  tmo.[ProviderState],
		  tmo.[ProviderZip],
		  tmo.[ServiceCode],
		  tmo.[ServiceCodeType],
		  avg(tmo.[Multiplier]),
		  avg(tmo.[Discount]),
		  tmo.[GenerateDate],
		  tmo.[Source]
		
		from MultiplierRaw tmo

		inner join 
		(
			select tmi.[ProviderNPI],tmi.[ProviderEntityCode],tmi.[ProviderState],tmi.[ProviderZip],tmi.[ServiceCode], tmi.[ServiceCodeType],
			avg(tmi.[Multiplier]) am, STDEVP(tmi.[Multiplier]) sm
			--, avg(tmi.[Discount]) ad,  STDEVP(tmi.[Discount]) sd
			from MultiplierRaw tmi
			group by
			tmi.[ProviderNPI],tmi.[ProviderEntityCode],tmi.[ProviderState],tmi.[ProviderZip],tmi.[ServiceCode], tmi.[ServiceCodeType]

		) tmp
		on
		tmp.[ProviderNPI]=tmo.[ProviderNPI] and
		tmp.[ProviderEntityCode]=tmo.[ProviderEntityCode] and
		tmp.[ProviderState]=tmo.[ProviderState] and 
		tmp.[ProviderZip]=tmo.[ProviderZip] and 
		tmp.[ServiceCode] = tmo.[ServiceCode] and
		tmp.[ServiceCodeType] = tmo.[ServiceCodeType] and
		(tmo.[Multiplier] between (tmp.am - 2*tmp.sm) and (tmp.am + 2*tmp.sm)) 

		group by  
		tmo.[ProviderNPI],tmo.[ProviderEntityCode],tmo.[ProviderState],tmo.[ProviderZip],tmo.[ServiceCode], tmo.[ServiceCodeType],tmo.[GenerateDate],tmo.[Source]

		


	


END
