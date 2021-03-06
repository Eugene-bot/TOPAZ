USE [AG_Data]
GO
/****** Object:  StoredProcedure [dbo].[updateAgroFuelLevelAlarm]    Script Date: 21.01.2020 12:37:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[updateAgroFuelLevelAlarm] 
AS
BEGIN

SET NOCOUNT ON;

declare @last_id int

select @last_id = max(id_alarm) from agro_fuel_level_alarm
if @last_id is null set @last_id = 0

declare @id_alarm int
declare @datadatetime datetime
declare @id_pos int
declare @id_tank int
declare @difference numeric(15,2)
declare @currentMass numeric(15,2)
declare @lastMass numeric(15,2)
declare @lastDateTime datetime
declare @tank_num int

select top 1 
@id_alarm = ID, @datadatetime = DATADATETIME, @id_pos = POS_ID, @id_tank = TANKID, @tank_num = TANKNUMBER,
@difference = DIFF, @currentMass = CURRENT_MASS, @lastMass = MASS_LAST_ZAPR, @lastDateTime = LASTDATETIME
from [TOPAZ]...[AGRO_FUEL_LEVEL_ALARM] where ID > @last_id order by ID

while @@ROWCOUNT > 0
begin
	insert into agro_fuel_level_alarm(id_alarm, datadatetime, diff, id_tank, id_pos, current_mass, last_mass, lastdatetime, is_email_sent, currTime, is_checked, tank_number) 
	values(@id_alarm, @datadatetime, @difference, @id_tank, @id_pos, @currentMass, @lastMass, @lastDateTime, 0, CURRENT_TIMESTAMP, 0, @tank_num)

	select top 1 
	@id_alarm = ID, @datadatetime = DATADATETIME, @id_pos = POS_ID, @id_tank = TANKID, @tank_num = TANKNUMBER,
	@difference = DIFF, @currentMass = CURRENT_MASS, @lastMass = MASS_LAST_ZAPR, @lastDateTime = LASTDATETIME
	from [TOPAZ]...[AGRO_FUEL_LEVEL_ALARM] where ID > @last_id and ID > @id_alarm order by ID
end
END
