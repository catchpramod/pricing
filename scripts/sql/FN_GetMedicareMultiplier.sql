SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[SP_GetMedicareMultiplier]
(
	-- Add the parameters for the function here
	@State varchar(10),
	@Zip varchar(10),
	@Code varchar(20),
	@CodeType varchar(10),
	@NPI varchar(20),
	@ProviderType varchar(20)
)

RETURNS Decimal(5,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @RowCount as int
	DECLARE @ReturnMultiplier as Decimal(5,2)

	-- return 1.0

	-- PASS 1: Match zip, service code(code+type) and NPI
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
            SUBSTRING([ZipCode],1,3) = SUBSTRING(isnull(@Zip,''),1,3) and
            [ServiceCode] = @Code and
            [CodeType] = @CodeType and
            [NPI] = @NPI

	if(@RowCount>0) Return @ReturnMultiplier

	-- PASS 2: Match zip, service code and provider type
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
            SUBSTRING([ZipCode],1,3) = SUBSTRING(isnull(@Zip,''),1,3) and
            [ServiceCode] = @Code and
            [CodeType] = @CodeType and
			[ProviderType]=  @ProviderType

	if(@RowCount>0) Return @ReturnMultiplier

	-- PASS 3: Match state, service code and provider type ( using NPI here won't make sense since NPI will be mostly bound to a fixed place )
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
			[State] = @State and
            [ServiceCode] = @Code and
            [CodeType] = @CodeType and
			[ProviderType]=  @ProviderType

	if(@RowCount>0) Return @ReturnMultiplier


	-- PASS 4: Match zip, service code
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
			SUBSTRING([ZipCode],1,3) = SUBSTRING(isnull(@Zip,''),1,3) and
            [ServiceCode] = @Code and
            [CodeType] = @CodeType

	if(@RowCount>0) Return @ReturnMultiplier



	-- PASS 5: Match zip, provider type
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
			SUBSTRING([ZipCode],1,3) = SUBSTRING(isnull(@Zip,''),1,3) and
            [ProviderType]=  @ProviderType

	if(@RowCount>0) Return @ReturnMultiplier

	-- PASS 6: Match state, service code
	select @RowCount= count(Multiplier), @ReturnMultiplier= avg(Multiplier) from dbo.NS_Multiplier
		where
			[State] = @State and
            [ServiceCode] = @Code and
            [CodeType] = @CodeType

	if(@RowCount>0) Return @ReturnMultiplier

	Return 3.0


END
