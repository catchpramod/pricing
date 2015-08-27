USE [NS_ETL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE SP_NS_Publish
	@report varchar(20) = Null -- options, 'ByZip[Z]'
AS
BEGIN
	
	IF @report IS NULL OR @report='Help' OR @report='H'		 
	BEGIN
		raiserror('Switch   : Action',0,1) with nowait 
		raiserror('-----------------------------------------',0,1) with nowait 
		raiserror('Help[H]  : Print this help message',0,1) with nowait 
		raiserror('ByZip[Z] : Publish report by zip codes',0,1) with nowait 
		raiserror('ByNPI[N] : Publish report by NPI ',0,1) with nowait 
		return
	END
	
	SET NOCOUNT ON;

	DECLARE @return_value int

	IF @report='ByZip' OR @report='Z'		 
	BEGIN
		
		IF OBJECT_ID('NS_Publish.dbo.ServiceCostByZip') IS NULL
		BEGIN
			raiserror('Creating publish table ServiceCostByZip',0,1) with nowait 
			Create  TABLE NS_Publish.dbo.ServiceCostByZip
			(
				[ServiceCode]  VARCHAR(20) NULL,
				[ServiceCodeType]  VARCHAR(20) NULL,
				[ProviderEntityCode]  VARCHAR(5) NULL,
				[ProviderZip]  VARCHAR(10) NULL,
				[ProviderState]  VARCHAR(20) NULL,

				[ClaimAllowed]  DECIMAL(10,2) NULL,
				[ClaimCharged]  DECIMAL(10,2) NULL,

				[MedicareAllowed]  DECIMAL(10,2) NULL,
				[MedicareCharged]  DECIMAL(10,2) NULL,

				[AvgAllowed]  DECIMAL(10,2) NULL,
				[AvgMultiplier]  DECIMAL(10,2) NULL,
				[Approximate]  Varchar(10) NULL,
				[GenerateDate] DATE NULL,
				[Source]  Varchar(50) NULL
			)
		END

		raiserror('Deleting previous records',0,1) with nowait 
		IF OBJECT_ID('NS_Publish.dbo.ServiceCostByZip') IS NOT NULL TRUNCATE TABLE NS_Publish.dbo.ServiceCostByZip

		raiserror('Publishing report by zip codes',0,1) with nowait 
		EXEC @return_value = NS_Publish.dbo.SP_Report_Cost_By_Zip

	END



	IF @report='ByNPI' OR @report='N'		 
	BEGIN
		
		IF OBJECT_ID('NS_Publish.dbo.ServiceCostByNPI') IS NULL
		BEGIN
			raiserror('Creating publish table ServiceCostByNPI',0,1) with nowait 
			Create  TABLE NS_Publish.dbo.ServiceCostByNPI
			(
				[ProviderNPI]  VARCHAR(20) NULL,
				[ProviderEntityCode]  VARCHAR(5) NULL,
				[ServiceCode]  VARCHAR(20) NULL,
				[ServiceCodeType]  VARCHAR(20) NULL,
				[ProviderZip]  VARCHAR(10) NULL,
				[ProviderState]  VARCHAR(20) NULL,
				[AvgAllowed]  DECIMAL(10,2) NULL,
				[AvgMultiplier]  DECIMAL(10,2) NULL,
				[Approximate]  Varchar(10) NULL
			)
		END

		raiserror('Deleting previous records',0,1) with nowait 
		IF OBJECT_ID('NS_Publish.dbo.ServiceCostByNPI') IS NOT NULL TRUNCATE TABLE NS_Publish.dbo.ServiceCostByNPI

		raiserror('Publishing report by NPI',0,1) with nowait 
		EXEC @return_value = NS_Publish.dbo.SP_Report_Cost_By_NPI

	END



END
GO
