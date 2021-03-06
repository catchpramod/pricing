USE [NS_Publish]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetProcedureCost]    Script Date: 8/19/2015 3:10:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_GetProcedureCost] 
	@procedureId int,
	@zipCode varchar(5)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--declare @procedureId int
	--set @procedureId = 1901	
	--declare @zipCode varchar(5)
	--set @zipCode = '53202'
	
	IF object_id('tempdb..#tmp_bundle') is not null drop table #tmp_bundle
	IF object_id('tempdb..#tmp_cost') is not null drop table #tmp_cost
	IF object_id('tempdb..#tmp_finalcost') is not null drop table #tmp_finalcost
			
	-- get bundle
	SELECT ProcedureID,
	      'H' as FacilityType,
		  HospitalCode as ServiceCode,		 		
		  ServiceGroup,
		  CASE WHEN IsPrimary = 'Yes'
			   THEN 1 
			   Else 0 
		  End as IsPrimary,
		  CASE WHEN  Units IS NULL
			   THEN 0
			   ELSE Units 
		  END as Units
	 into #tmp_bundle
	 FROM NS_ProcedureBundles as pb 	
	WHERE ProcedureID = @procedureId
	  AND HospitalCode is not null	
	
    INSERT INTO #tmp_bundle
	SELECT ProcedureID,
			'S' as FacilityType,
			SurgeryCode as ServiceCode,		 		 
			ServiceGroup,
			CASE WHEN IsPrimary = 'Yes'
				THEN 1 
				Else 0 
			End as IsPrimary,
			CASE WHEN  Units IS NULL
				THEN 0
				ELSE Units 
			END as Units
	  FROM NS_ProcedureBundles as pb 	
	 WHERE ProcedureID = @procedureId
	   AND SurgeryCode is not null
	    
	
  -- get pricing for facility
	SELECT b.FacilityType, 
	       b.ServiceCode, 
		   b.ServiceGroup,

		  -- case when b.ServiceGroup like 'Facility%'
		  --      then avg(scf.AvgAllowed * ISNULL(scf.AvgMultiplier,1))
				--else avg(sc.AvgAllowed * ISNULL(sc.AvgMultiplier,1))
		  -- end as AvgAllowed,
		   	
		  -- case when b.ServiceGroup like 'Facility%'
		  --      then avg(scf3.AvgAllowed * ISNULL(scf3.AvgMultiplier,1))
				--else avg(sc3.AvgAllowed * ISNULL(sc3.AvgMultiplier,1))
		  -- end as AvgAllowed3Zip		

		   case when b.ServiceGroup like 'Facility%'
		        then avg(scf.AvgAllowed * scf.AvgMultiplier)
				else avg(sc.AvgAllowed * sc.AvgMultiplier)
		   end as AvgAllowed,
		   	
		   case when b.ServiceGroup like 'Facility%'
		        then avg(scf3.AvgAllowed * scf3.AvgMultiplier)
				else avg(sc3.AvgAllowed * sc3.AvgMultiplier)
		   end as AvgAllowed3Zip		
	  INTO #tmp_cost 
	  FROM #tmp_bundle b
 LEFT JOIN NS_Publish.dbo.ServiceCostByZip scf
	    ON (b.ServiceCode = scf.ServiceCode and 
		    b.ServiceGroup like 'Facility%' and
		    scf.ProviderEntityCode = 'O' and 			
			scf.ProviderZip = @zipCode)
 LEFT JOIN NS_Publish.dbo.ServiceCostByZip sc
	    ON (b.ServiceCode = sc.ServiceCode and 
		    sc.ProviderEntityCode = 'I' and
			sc.ProviderZip = @zipCode)
 LEFT JOIN NS_Publish.dbo.ServiceCostByZip scf3
	    ON (b.ServiceCode = scf3.ServiceCode and 
		    b.ServiceGroup like 'Facility%' and
		    scf3.ProviderEntityCode = 'O' and 
			scf3.ProviderZip like substring(@zipCode,1,3) + '%')
 LEFT JOIN NS_Publish.dbo.ServiceCostByZip sc3
	    ON (b.ServiceCode = sc3.ServiceCode and 
		    sc3.ProviderEntityCode = 'I' and
			sc3.ProviderZip like substring(@zipCode,1,3) + '%')
  GROUP BY b.FacilityType, 
	       b.ServiceCode, 
		   b.ServiceGroup
  ORDER BY b.FacilityType

 
  --SELECT ServiceGroup,	
	 --      -- isNull(sum(AvgAllowed * AvgMultiplier), sum(AvgAllowed3Zip * AvgMultiplier3Zip)) as Cost
		--   --IIF(sum(AvgAllowed * AvgMultiplier) IS NULL OR (sum(AvgAllowed3Zip * AvgMultiplier3Zip)-sum(AvgAllowed * AvgMultiplier))/sum(AvgAllowed * AvgMultiplier) > 0.2 , sum(AvgAllowed3Zip * AvgMultiplier3Zip),sum(AvgAllowed * AvgMultiplier) ) as Cost
		--   IIF(sum(AvgAllowed) IS NULL OR abs((sum(AvgAllowed3Zip)-sum(AvgAllowed))/sum(AvgAllowed3Zip)) > 0.2 , 
		--       sum(AvgAllowed3Zip),sum(AvgAllowed) ) as Cost
	 -- FROM #tmp_cost tc
  --WHERE 
  --FacilityType = 'S' and 
  --ServiceGroup IS NOT NULL 
  --and (AvgAllowed IS NOT NULL OR AvgAllowed3Zip IS NOT NULL)
  --GROUP BY ServiceGroup, FacilityType
  --ORDER BY 1





  SELECT ServiceGroup,	FacilityType,
	       -- isNull(sum(AvgAllowed * AvgMultiplier), sum(AvgAllowed3Zip * AvgMultiplier3Zip)) as Cost
		   --IIF(sum(AvgAllowed * AvgMultiplier) IS NULL OR (sum(AvgAllowed3Zip * AvgMultiplier3Zip)-sum(AvgAllowed * AvgMultiplier))/sum(AvgAllowed * AvgMultiplier) > 0.2 , sum(AvgAllowed3Zip * AvgMultiplier3Zip),sum(AvgAllowed * AvgMultiplier) ) as Cost
		   IIF(sum(AvgAllowed) IS NULL OR abs((sum(AvgAllowed3Zip)-sum(AvgAllowed))/sum(AvgAllowed3Zip)) > 0.2 , 
		       sum(AvgAllowed3Zip),sum(AvgAllowed) ) as Cost
	  into #tmp_finalcost
	  FROM #tmp_cost tc
  WHERE 
  --FacilityType = 'S' and 
  ServiceGroup IS NOT NULL 
  and (AvgAllowed IS NOT NULL OR AvgAllowed3Zip IS NOT NULL)
  GROUP BY ServiceGroup, FacilityType
  --ORDER BY 1


  select * from #tmp_finalcost
  where FacilityType = (
		 select Top 1 FacilityType
		 from (select FacilityType , sum(Cost) cost from #tmp_finalcost group by FacilityType) t
		 where  t.cost = (select max(gp.cost) from ( select sum(Cost) cost from #tmp_finalcost group by FacilityType) as gp)
		 )
  ORDER BY 1

   
END
