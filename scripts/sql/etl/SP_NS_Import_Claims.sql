USE [NS_ETL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE SP_NS_Import_Claims
	@sourceTableName varchar(250), -- name of the table in Alithisa_Publish
	@refresh varchar(20)=null -- either, 'Table', 'File' or Null(this is the default value)
AS
BEGIN
	raiserror('sourceTableName: %s',0,1,@sourceTableName) with nowait 
	raiserror('refresh: %s',0,1,@refresh) with nowait 
	SET NOCOUNT ON;

	DECLARE @return_value int
	DECLARE @sourceFileName varchar(250)

	set @sourceTableName = 'Alithias_Publish.dbo.'+@sourceTableName

	print ('Starting Merge step')

	---- Get source file list
	--IF OBJECT_ID('TEMPDB.DBO.#FileName') IS NOT NULL DROP TABLE #FileName 
	
	--CREATE TABLE #FileName (Name VARCHAR(250))
	--Declare @sql1 nvarchar(200);
	--set @sql1 = 'Insert into #FileName select distinct [SourceFile] FROM ' +@sourceTableName
	--exec sp_executesql @sql1


	--IF (OBJECT_ID('NS_IMPORT.dbo.ClaimsCore') IS NOT NULL) AND (@refresh IS NULL OR NOT(@refresh ='Table' OR @refresh ='File'))
	--BEGIN
		
	--	Declare @sql nvarchar(200);
	--	set @sql = 'select  top 1  @x = [SourceFile] from '+@sourceTableName

	--	exec sp_executesql @sql, N'@x varchar(200) out', @sourceFileName out
	--	print 'Source Filename: '+@sourceFileName

	--	IF not exists (select 1 
	--			from #FileName f
	--			where f.name  not in (select distinct l.[SourceFile] from NS_IMPORT.dbo.ClaimsCore l)
	--		)

	--	--IF exists (select 1 
	--	--		from NS_IMPORT.dbo.ClaimsCore l
	--	--		where l.[SourceFile] = @sourceFileName
	--	--		)
	--	BEGIN
	--		print('All files from '+@sourceFileName+' already exist in the merged table, use refresh=[Table/File] switch!')
	--		return
	--	END
	--END


	IF (@refresh = 'Table' ) OR (OBJECT_ID('NS_IMPORT.dbo.ClaimsCore') IS NULL)
	BEGIN
		print ('Deleting table ClaimsCore, if it exists!')
		IF OBJECT_ID('NS_IMPORT.dbo.ClaimsCore') IS NOT NULL DROP TABLE NS_IMPORT.dbo.ClaimsCore
		print ('Creating table ClaimsCore')
		CREATE TABLE NS_IMPORT.dbo.ClaimsCore
		(
			[ID]  INTEGER IDENTITY(1,1) PRIMARY KEY,
			[ClaimKey] [nvarchar](200) NULL,
			[CompanyID] [int] NOT NULL,
			[CompanyCode] [nvarchar](200) NULL,
			[CompanyName] [nvarchar](200) NULL,
			[NetworkID] [int] NOT NULL,
			[NetworkCode] [nvarchar](200) NULL,
			[NetworkName] [nvarchar](200) NULL,
			[BillingProviderNPI] [nvarchar](10) NULL,
			[BillingProviderName] [nvarchar](200) NULL,
			[BillingProviderAddressLine1] [nvarchar](200) NULL,
			[BillingProviderCity] [nvarchar](200) NULL,
			[BillingProviderState] [nvarchar](2) NULL,
			[BillingProviderZip] [nvarchar](10) NULL,
			[RenderingProviderNPI] [nvarchar](10) NULL,
			[RenderingProviderName] [nvarchar](200) NULL,
			[RenderingProviderAddress1] [nvarchar](200) NULL,
			[RenderingProviderCity] [nvarchar](200) NULL,
			[RenderingProviderState] [nvarchar](2) NULL,
			[RenderingProviderZip] [nvarchar](10) NULL,
			[BeginingDateofService] [datetime] NULL,
			[PlaceOfService] [nvarchar](50) NULL,
			[HCPCSCPTCode] [nvarchar](200) NULL,
			[HCPCSCPTCodeDescription] [nvarchar](200) NULL,
			[Modifier1] [nvarchar](10) NULL,
			[Modifier2] [nvarchar](10) NULL,
			[DRGCode] [nvarchar](50) NULL,
			[Units] [int] NULL,
			[BilledAmt] [numeric](10, 2) NULL,
			[AllowedAmt] [numeric](10, 2) NULL,
			[DeductibleAmt] [numeric](10, 2) NULL,
			[SourceFile] [nvarchar](200) NULL,
			[SourceClient] [nvarchar](50) NULL
		)

	END

	IF @refresh = 'File' 
	BEGIN
		print ('Deleting existing duplicate records from the input file!')
		declare @deleteSQL varchar(max)

		set @deleteSQL=' DELETE FROM [NS_Import].[dbo].[ClaimsCore] where SourceFile like '''+@sourceFileName+''''
		EXECUTE (@deleteSQL)

	END


	print ('Executing Claims merge')
	EXEC @return_value = NS_Import.dbo.SP_NS_Merge_Claims @sourceTableName

  
END
GO
