select 
 cl.BILLING_PROVIDER_NPI NPI,cl.BILLING_PROVIDER_NAME	ProviderName,p.[ProviderEntityCode]	ProviderType, isNull(cl.TREATING_NPI,'') TreatingNPI,Provider_Name_Treating TreatingProvider, 
 cl.PROCEDURE_CODE	ProcedureCode, ISNULL(cl.MODIFIER_1,'') Modifier, cl.PROCEDURE_DESCRIPTION	ProcedureDesc,
 avg(cast(p.AllowedAmount as decimal))	AvgMedicareAllowed,avg(cast(cl.AMOUNT_BILLED as decimal))	AvgBilled,avg(cast(cl.AMOUNT_ALLOWED as decimal))	AvgAllowed,avg(cast(cl.AMOUNT_PAID as decimal))	AvgPaid,
 avg(cast(cl.AMOUNT_ALLOWED as decimal))/avg(cast(p.AllowedAmount as decimal))	Multiplier
 --,(1-avg(cast(cl.AMOUNT_ALLOWED as decimal))/avg(cast(cl.AMOUNT_BILLED as decimal)))*100	Discount

 --cl.Member_ID, cl.CLAIM_NUMBER,cl.PAID_DATE, cl.PROCEDURE_CODE,cl.[Entity_Type_Code],  cl.PROCEDURE_DESCRIPTION, p.ServiceUnits, p.AllowedAmount, cl.AMOUNT_BILLED, cl.AMOUNT_PAID, 
 --cl.BILLING_PROVIDER_NPI, cl.TREATING_NPI, cl.BILLING_PROVIDER_NAME, cl.Mailing_Address1, cl.Network_Name
 from 
(
	select c.*,n.NPI, n.Entity_Type_Code,
	ISNULL(c.TREATING_PROVIDER_NAME, 
		IIF(nt.Organization_Name IS NULL,'',nt.Organization_Name+' ')+ 
		IIF(nt.Name_Prefix IS NULL,'',nt.Name_Prefix+' ')+ 
		IIF(nt.First_Name IS NULL,'',nt.First_Name+' ')+ 
		IIF(nt.Middle_Name IS NULL,'',nt.Middle_Name+' ')+ 
		IIF(nt.Last_Name IS NULL,'',nt.Last_Name+' ')+ 
		IIF(nt.Name_Suffix IS NULL,'',nt.Name_Suffix+' ')+ 
		IIF(nt.Credential_Text IS NULL,'',nt.Credential_Text)
	) as Provider_Name_Treating
	from Alithias_Import.dbo.AI_Claims_CYPRESS c 
	left join Alithias_Common.dbo.MasterNPI n on c.BILLING_PROVIDER_NPI = n.NPI
	left join Alithias_Common.dbo.MasterNPI nt on c.TREATING_NPI = nt.NPI
	where c.Group_Name ='MENASHA CORPORATION' and c.BILLING_PROV_STATE='WI'
) cl
left join
NS_Import.dbo.PricingCore p
on 
	p.[ProviderEntityCode] = IIF( cl.[Entity_Type_Code]='1', 'I', 'O' )
	and p.ServiceCode = cl.PROCEDURE_CODE
	and p.ProviderNPI = cl.NPI

where 
cast(p.AllowedAmount as decimal) !=0.0
and
cast(cl.AMOUNT_ALLOWED as decimal)!=0.0

group by 
cl.BILLING_PROVIDER_NPI ,cl.BILLING_PROVIDER_NAME ,p.[ProviderEntityCode],cl.PROCEDURE_CODE	,cl.PROCEDURE_DESCRIPTION, cl.MODIFIER_1,cl.TREATING_NPI,cl.Provider_Name_Treating

order by
cl.BILLING_PROVIDER_NPI ,cl.BILLING_PROVIDER_NAME ,p.[ProviderEntityCode]



