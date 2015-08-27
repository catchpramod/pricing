USE [NS_ETL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE SP_NS_Scrub
	@fileType varchar(20), -- options, 'Core','Claims'
	@refresh varchar(20)=null -- either, 'Y', Null(this is the default value)
AS
BEGIN
	
	raiserror('fileType: %s',0,1,@fileType) with nowait 
	raiserror('refresh: %s',0,1,@refresh) with nowait 
	
	SET NOCOUNT ON;

	DECLARE @return_value int

	IF @fileType='Core'
	BEGIN
		raiserror('Executing core scrub',0,1) with nowait 

		IF (OBJECT_ID('NS_Scrub.[dbo].PricingCore') IS NULL)
		BEGIN
			raiserror('Creating table PricingCore!',0,1) with nowait 
			CREATE TABLE NS_Scrub.[dbo].PricingCore
			(
				[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
				[ProviderID] VARCHAR(80) NULL,
				[ProviderNPI]  VARCHAR(80) NULL,
				[ProviderLastName]  VARCHAR(250) NULL,
				[ProviderFirstName]  VARCHAR(80) NULL,
				[ProviderMiddleName]  VARCHAR(80) NULL,
				[ProviderEntityCode]  VARCHAR(20) NULL,
				[ProviderStreet1]  VARCHAR(256) NULL,
				[ProviderStreet2]  VARCHAR(256) NULL,
				[ProviderCty]  VARCHAR(80) NULL,
				[ProviderState]  VARCHAR(80) NULL,
				[ProviderZip]  VARCHAR(80) NULL,
				[ProviderCountry]  VARCHAR(80) NULL,
				[NetworkID] VARCHAR(80) NULL,
				[NetworkName]  VARCHAR(250) NULL,
				[ServiceCode]  VARCHAR(80) NULL,
				[ServiceCodeType]  VARCHAR(80) NULL,
				[ServiceCodeDesc]  VARCHAR(256) NULL,
				[ServiceUnits]  float,
				[ServiceDate]  VARCHAR(80) NULL,
				[PlaceOfService]  VARCHAR(80) NULL,
				[PrimaryModifier]  VARCHAR(80) NULL,
				[SecondaryModifier]  VARCHAR(80) NULL,
				[AllowedAmount]  DECIMAL(15,2) NULL,
				[ChargedAmount]   DECIMAL(15,2) NULL,
				[PaidAmount]   DECIMAL(15,2) NULL,
				[UDF1]  VARCHAR(80) NULL,
				[UDF2]  VARCHAR(80) NULL,
				[UDF3]  VARCHAR(80) NULL,
				[UDF4]  VARCHAR(80) NULL,
				[UDF5]  VARCHAR(80) NULL,
				[ImportedDate]  VARCHAR(80) NULL,
				[SourceFileName]  VARCHAR(80) NULL,
				[SourceType]  VARCHAR(80) NULL
			)

		END


		IF @refresh = 'Y' 
		BEGIN
			raiserror('Deleting existing records in destination!',0,1) with nowait 
			declare @deleteSQL varchar(max)
			set @deleteSQL=
						'DELETE FROM  NS_Scrub.[dbo].[PricingCore] where SourceFileName in (select distinct imp.[SourceFileName] from NS_IMPORT.dbo.PricingCore imp)'
			EXECUTE (@deleteSQL)

		END
		raiserror('Copying records to destination!',0,1) with nowait 
		EXEC @return_value = NS_Scrub.dbo.SP_NS_Scrub
	END









	IF @fileType='Claims'
	BEGIN
		raiserror('Executing claims scrub',0,1) with nowait 

		IF (OBJECT_ID('NS_Scrub.[dbo].ClaimsCore') IS NULL)
		BEGIN
			raiserror('Creating table ClaimsCore!',0,1) with nowait 
			CREATE TABLE NS_Scrub.[dbo].ClaimsCore
			(
				[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
				[ProviderID] VARCHAR(80) NULL,
				[ProviderNPI]  VARCHAR(80) NULL,
				[ProviderLastName]  VARCHAR(250) NULL,
				[ProviderFirstName]  VARCHAR(80) NULL,
				[ProviderMiddleName]  VARCHAR(80) NULL,
				[ProviderEntityCode]  VARCHAR(20) NULL,
				[ProviderStreet1]  VARCHAR(256) NULL,
				[ProviderStreet2]  VARCHAR(256) NULL,
				[ProviderCty]  VARCHAR(80) NULL,
				[ProviderState]  VARCHAR(80) NULL,
				[ProviderZip]  VARCHAR(80) NULL,
				[ProviderCountry]  VARCHAR(80) NULL,
				[NetworkID] VARCHAR(80) NULL,
				[NetworkName]  VARCHAR(250) NULL,
				[ServiceCode]  VARCHAR(80) NULL,
				[ServiceCodeType]  VARCHAR(80) NULL,
				[ServiceCodeDesc]  VARCHAR(256) NULL,
				[ServiceUnits]  float,
				[ServiceDate]  VARCHAR(80) NULL,
				[PlaceOfService]  VARCHAR(80) NULL,
				[PrimaryModifier]  VARCHAR(80) NULL,
				[SecondaryModifier]  VARCHAR(80) NULL,
				[AllowedAmount]  DECIMAL(15,2) NULL,
				[ChargedAmount]   DECIMAL(15,2) NULL,
				[PaidAmount]   DECIMAL(15,2) NULL,
				[UDF1]  VARCHAR(80) NULL,
				[UDF2]  VARCHAR(80) NULL,
				[UDF3]  VARCHAR(80) NULL,
				[UDF4]  VARCHAR(80) NULL,
				[UDF5]  VARCHAR(80) NULL,
				[ImportedDate]  VARCHAR(80) NULL,
				[SourceFileName]  VARCHAR(80) NULL,
				[SourceType]  VARCHAR(80) NULL
			)

		END


		IF @refresh = 'Y' 
		BEGIN
			raiserror('Deleting existing records in destination!',0,1) with nowait 
			set @deleteSQL=
						'DELETE FROM  NS_Scrub.[dbo].[ClaimsCore] where SourceFileName in (select distinct imp.[SourceFile] from NS_IMPORT.dbo.ClaimsCore imp)'
			EXECUTE (@deleteSQL)

		END
		raiserror('Copying records to destination!',0,1) with nowait 
		EXEC @return_value = NS_Scrub.dbo.SP_NS_Scrub_Claims
	END


	IF @fileType='Multiplier'
	BEGIN

		raiserror('Executing multipliar scrub',0,1) with nowait 

		IF (OBJECT_ID('NS_Scrub.[dbo].MultiplierRaw') IS NULL)
		BEGIN
			raiserror('Creating table MultiplierRaw!',0,1) with nowait 
			Create  TABLE NS_Scrub.[dbo].MultiplierRaw
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

		END
		
		
		IF @refresh = 'Y' 
		BEGIN
			raiserror('Deleting existing records in destination!',0,1) with nowait 
			set @deleteSQL=
						'Truncate table NS_Scrub.[dbo].[MultiplierRaw] '
			EXECUTE (@deleteSQL)

			set @deleteSQL=
						'Truncate table NS_Scrub.[dbo].[Multiplier]'

			EXECUTE (@deleteSQL)

		END

		raiserror('Copying records to destination!',0,1) with nowait 
		EXEC @return_value = NS_Scrub.dbo.[SP_NS_Multiplier_Scrub]

		raiserror('Generating multipliers!',0,1) with nowait 
		EXEC @return_value = NS_Scrub.dbo.[SP_NS_Generate_Multiplier]

	END
  
END
GO
