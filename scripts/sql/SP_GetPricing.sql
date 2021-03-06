SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetPricing]
	-- Add the parameters for the stored procedure here
	@BundleID int,
	@zipCode varchar(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Without multilevel pricing
	/*
	Select ServiceCode, Provider, avg(MedicareAmount) as MedicareAvg, avg(amount) as AverageAmt from (
		select 
		p.ServiceCode as ServiceCode,
		m.ProviderType as Provider,
		p.AllowedAmount as MedicareAmount,
		dbo.SP_GetMedicareMultiplier(p.ProviderState,P.ProviderZip,p.ServiceCode,p.ServiceCodeType,p.ProviderNPI,m.ProviderType) * p.AllowedAmount as amount
		from dbo.NS_Pricing p
		
		INNER JOIN dbo.NS_Service m
						ON p.ServiceCode = m.ServiceCode and p.ProviderEntityCode = case when m.ProviderType='Facility' then 'O' else 'I' end
		
		where m.BundleID = @BundleID
			and substring(p.ProviderZip, 1, 3) = substring(@zipCode, 1, 3)
	) tmp
	Group by tmp.ServiceCode, tmp.Provider
	Order by AverageAmt desc
	*/

	-- Multilevel pricing, will get pricing from higher level if zip doesn't match

		--declare @BundleID int
		--declare @zipCode varchar(5)	
		--set @BundleID = 16021
		--set @zipCode = '53202'

		declare @PriceRecords TABLE(
			ServiceCode varchar(30) NOT NULL,
			Provider varchar(30) NOT NULL, 
			MedicareAvg decimal(10,2) NOT NULL, 
			AverageAmt decimal(10,2) NOT NULL, 
			MatchLevel int NOT NULL
		);

		Insert into @PriceRecords
		Select ServiceCode, Provider, avg(MedicareAmount) as MedicareAvg, avg(amount) as AverageAmt, MatchLevel
		from (
			select 
				p.ServiceCode as ServiceCode,
				m.ProviderType as Provider,
				p.AllowedAmount as MedicareAmount,
				dbo.SP_GetMedicareMultiplier(p.ProviderState,P.ProviderZip,p.ServiceCode,p.ServiceCodeType,p.ProviderNPI,m.ProviderType) * p.AllowedAmount as amount,
				-- define match levels here (high match is low number value)
				case 
					when substring(p.ProviderZip, 1, 3) = substring(@zipCode, 1, 3) then 1
					when substring(p.ProviderZip, 1, 2) = substring(@zipCode, 1, 2) then 2
					else 3 
				end
				as MatchLevel
			from dbo.NS_Pricing p
		
			INNER JOIN dbo.NS_Service m
							ON p.ServiceCode = m.ServiceCode and p.ProviderEntityCode = case when m.ProviderType='Facility' then 'O' else 'I' end
		
			where m.BundleID = @BundleID
				and substring(p.ProviderZip, 1, 1) = substring(@zipCode, 1, 1)
		) tmp
		Group by tmp.ServiceCode, tmp.Provider, tmp.MatchLevel;

		select pt.* from @PriceRecords pt
		Inner Join (
			Select 
				ServiceCode,Provider, min(MatchLevel) as MinM from @PriceRecords
			Group by ServiceCode,Provider
		) mt 
		on mt.ServiceCode= pt.ServiceCode and mt.Provider = pt.Provider
		where pt.MatchLevel = mt.MinM
		Order by AverageAmt desc;

END
