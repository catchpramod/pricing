USE [NS_ETL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE SP_NS_Import_Core
	@fileType varchar(20), -- options, 'CMS-Util','CMS-DRG', 'CMS-APC', 'PayerCompass' 
	@sourceFileName varchar(200), -- this field is used to check if there already records present 
	@sourceTableName varchar(200), -- table name in the NS_Import DB
	@refresh varchar(20)=null, -- either, 'Table', 'File' or Null(this is the default value)
	@serviceDate varchar(15)=null, -- since the CMS files don't have service dates, specify date manually
	@importStep varchar(10) = 'Merge' -- either 'Bulkload' or 'Merge'(this is the default value)
AS
BEGIN
	
	raiserror('fileType: %s',0,1,@fileType) with nowait 
	raiserror('sourceFileName: %s',0,1,@sourceFileName) with nowait 
	raiserror('sourceTableName: %s',0,1,@sourceTableName) with nowait 
	raiserror('refresh: %s',0,1,@refresh) with nowait 
	raiserror('serviceDate: %s',0,1,@serviceDate) with nowait 
	raiserror('importStep: %s',0,1,@importStep) with nowait 


	
	SET NOCOUNT ON;

	DECLARE @return_value int

	IF @importStep='Bulkload'		 
	BEGIN
		select 'Only ''Merge'' step implemented at this time!'
	END


	IF @importStep='Merge' OR @importStep='Bulkload'		 
	BEGIN
		raiserror('Starting Merge step',0,1) with nowait 
		IF (OBJECT_ID('NS_IMPORT.dbo.PricingCore') IS NOT NULL) AND (@refresh IS NULL OR NOT(@refresh ='Table' OR @refresh ='File'))
		BEGIN
			IF exists (select 1 
				 from NS_IMPORT.dbo.PricingCore l
					where l.[SourceFileName] = @sourceFileName
				  )
			BEGIN
				print('Records from file '+@sourceFileName+' already exist in the merged table, use refresh=[Table/File] switch!')
				return
			END
		END


		IF (@refresh = 'Table' ) OR (OBJECT_ID('NS_IMPORT.dbo.PricingCore') IS NULL)
		BEGIN
			raiserror('Deleting table PricingCore, if it exists!',0,1) with nowait 
			IF OBJECT_ID('NS_IMPORT.dbo.PricingCore') IS NOT NULL DROP TABLE NS_IMPORT.dbo.PricingCore
			raiserror('Creating table PricingCore',0,1) with nowait 
			CREATE TABLE NS_IMPORT.dbo.PricingCore
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
				[ProviderCity]  VARCHAR(80) NULL,
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

		IF @refresh = 'File' 
		BEGIN
			raiserror('Deleting existing duplicate records from the input file!',0,1) with nowait 
			declare @deleteSQL varchar(max)

			set @deleteSQL=
			'
				DELETE FROM [NS_Import].[dbo].[PricingCore] where SourceFileName like '''+@sourceFileName+''' and SourceType = '''+@fileType+'''
			'
			EXECUTE (@deleteSQL)

		END


		IF @fileType='CMS-Util'
		BEGIN
			raiserror('Executing Provider util payment merge',0,1) with nowait 
			EXEC @return_value = NS_Import.dbo.SP_NS_Merge_ProviderUtilPayment @serviceDate, @sourceFileName, @sourceTableName
			print(@return_value)
		END

		ELSE IF @fileType='CMS-DRG'
		BEGIN
			raiserror('Executing Provider inpatient merge',0,1) with nowait 
			EXEC @return_value = NS_Import.dbo.SP_NS_Merge_ProviderChargeInpatient @serviceDate, @sourceFileName, @sourceTableName
		END

		ELSE IF @fileType='CMS-APC'
		BEGIN
			raiserror('Executing Provider outpatient merge',0,1) with nowait 
			EXEC @return_value = NS_Import.dbo.SP_NS_Merge_ProviderChargeOutpatient @serviceDate, @sourceFileName, @sourceTableName
		END

		ELSE IF @fileType='PayerCompass'
		BEGIN
			raiserror('Executing PayerCompass merge!',0,1) with nowait 
			EXEC @return_value = NS_Import.dbo.SP_NS_Merge_PayerCompass @sourceFileName, @sourceTableName
		END

	END 

  
END
GO
