SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[MigrateWellcareToAlithias]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		--select * from [wellcare.arvixecloud.com].[Alithias_Wellcare_V2].dbo.MD_ProcedureBundles
		--ProcedureID	PrimaryProcedureCategory	SecondaryProcedureCategory	Procedure	IsWellCare	HospitalCode 	HospitalType	
		--SurgeryCode	SurgeryType	Units	AccessHealthPrimary	UIDisplayText


		-- Generate Procedure
		Truncate table [Alithias_ImportTest].[dbo].[NS_Procedure]
		insert into [Alithias_ImportTest].[dbo].[NS_Procedure]
		select distinct [ProcedureID], [ProcedureName] from [wellcare.arvixecloud.com].[Alithias_Wellcare_V2].dbo.MD_ProcedureBundles

		select * FROM [Alithias_ImportTest].[dbo].[NS_Procedure]



		-- Generate Bundle
		Truncate table [Alithias_ImportTest].[dbo].[NS_Bundle]

		insert into [Alithias_ImportTest].[dbo].[NS_Bundle]
		select distinct BundleID,BundleName,	ProcedureID from 
		(SELECT concat(ProcedureID ,CAST(1 AS VARCHAR)) as BundleID, 'Hospital' as BundleName, ProcedureID, [HospitalCode] as ServiceCode
		  FROM [WELLCARE.ARVIXECLOUD.COM].[Alithias_WellCare_V2].[dbo].MD_ProcedureBundles pb1 

		UNION

		SELECT concat(ProcedureID ,CAST(2 AS VARCHAR)) as BundleID , 'Surgery' as BundleName, ProcedureID, SurgeryCode as ServiceCode
			  FROM [WELLCARE.ARVIXECLOUD.COM].[Alithias_WellCare_V2].[dbo].MD_ProcedureBundles pb2 
		) tmp 
		 where  ServiceCode!= 'NULL' 

		select * FROM [Alithias_ImportTest].[dbo].[NS_Bundle]


		--Generate service
		Truncate table [Alithias_ImportTest].[dbo].[NS_Service]

		insert into [Alithias_ImportTest].[dbo].[NS_Service] (BundleID,ServiceCode,ServiceType,ProviderType) 
		select BundleID, ServiceCode, 
		case
			when ServiceType != 'APC' and  ServiceType != 'DRG' Then 'HCPCS'
			Else ServiceType
		END
		, AlithiasType from (
		SELECT concat(ProcedureID ,CAST(1 AS VARCHAR)) as BundleID ,[HospitalCode] as ServiceCode, HospitalType as ServiceType,UIDisplayText+'Hospital' as UIDisplayText
			  FROM [WELLCARE.ARVIXECLOUD.COM].[Alithias_WellCare_V2].[dbo].MD_ProcedureBundles pb1 

		UNION

		SELECT concat(ProcedureID ,CAST(2 AS VARCHAR)) as BundleID ,SurgeryCode as ServiceCode, SurgeryType as ServiceType, UIDisplayText
			  FROM [WELLCARE.ARVIXECLOUD.COM].[Alithias_WellCare_V2].[dbo].MD_ProcedureBundles pb2 
		) tmp
		 left join [Alithias_ImportTest].[dbo].[NS_Wellcare_Alithias_Provider_Type] cw on cw.WellcareType = tmp.ServiceType
		 where  ServiceCode!= 'NULL'


		 select * FROM [Alithias_ImportTest].[dbo].[NS_Service]


END
