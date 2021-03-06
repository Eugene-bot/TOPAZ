USE [AG_Data]
GO
/****** Object:  StoredProcedure [dbo].[updateAgroFuelLevelAlarm30cm]    Script Date: 21.01.2020 11:41:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[updateAgroFuelLevelAlarm30cm] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

declare @last_id int

select @last_id = max(alarm_id) from agro_fuel_level_alarm_30cm
if @last_id is null set @last_id = 0

declare @id_alarm int
declare @datadatetime datetime
declare @id_pos int
declare @id_tank int
declare @tank_num int
declare @fuel_level int
declare @fuel_mass numeric(15,2)

select top 1 
@id_alarm = ID, @datadatetime = DATADATETIME, @id_pos = POS_ID, @id_tank = TANK_ID, @tank_num = TANK_NUMBER, @fuel_level = FUEL_LEVEL, @fuel_mass = FUEL_MASS
from [TOPAZ]...[AGRO_FUEL_LEVEL_ALARM_30CM] where ID > @last_id order by ID

while @@ROWCOUNT > 0
begin
	declare @send_email int;
	select @send_email = send_alarms_30cm from Geozones where topaz_pos_id = @id_pos
	
	insert into agro_fuel_level_alarm_30cm(alarm_id, datadatetime, pos_id, tank_id, tank_number, fuel_level, fuel_mass, send_email, is_email_sent) 
	values(@id_alarm, @datadatetime, @id_pos, @id_tank, @tank_num, @fuel_level, @fuel_mass, @send_email, 0)

	select top 1 
	@id_alarm = ID, @datadatetime = DATADATETIME, @id_pos = POS_ID, @id_tank = TANK_ID, @tank_num = TANK_NUMBER, @fuel_level = FUEL_LEVEL, @fuel_mass = FUEL_MASS
	from [TOPAZ]...[AGRO_FUEL_LEVEL_ALARM_30CM] where ID > @last_id and ID > @id_alarm order by ID
end
END

