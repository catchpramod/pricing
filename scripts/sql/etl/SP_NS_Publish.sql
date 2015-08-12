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
		return
	END
	
	SET NOCOUNT ON;

	DECLARE @return_value int

	IF @report='ByZip' OR @report='Z'		 
	BEGIN
		raiserror('Publishing report by zip codes',0,1) with nowait 

		--IF OBJECT_ID('NS_Publish.dbo.ServiceCostByZip') IS NOT NULL DROP TABLE NS_Publish.dbo.ServiceCostByZip
		--Create  TABLE NS_Publish.dbo.ServiceCostByZip
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

		raiserror('Deleting previous records',0,1) with nowait 
		IF OBJECT_ID('NS_Publish.dbo.ServiceCostByZip') IS NOT NULL TRUNCATE TABLE NS_Publish.dbo.ServiceCostByZip

		EXEC @return_value = NS_Publish.dbo.SP_Report_Cost_By_Zip

	END



END
GO
