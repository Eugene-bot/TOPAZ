USE [AG_Data]
GO
/****** Object:  StoredProcedure [dbo].[checkEventsForAlarms]    Script Date: 21.01.2020 11:36:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
ALTER PROCEDURE [dbo].[checkEventsForAlarms] 
AS
BEGIN

SET NOCOUNT ON;

declare @id int
declare @slisedate datetime
declare @id_alarm int
declare @pos_id int
declare @is_alarm numeric(1,0)
declare @device_list nvarchar(4000)

select top 1 @id = id, @id_alarm = id_alarm, @slisedate = datadatetime, @pos_id = id_pos from [agro_fuel_level_alarm] where is_checked = 0 order by id
while @@ROWCOUNT > 0
begin
	declare @send_email int;
	select @send_email = send_alarms from Geozones where topaz_pos_id = @pos_id

	--проверяем три раза: две минуты назад, минуту назад и в текущее время:
	declare @volta int = 0;
	while @volta < 3
	begin
		declare @checkdate datetime = DATEADD(minute, -@volta, @slisedate)
		exec checkDevicesInAZS @checkdate, @pos_id, @id, @is_alarm output, @device_list output
		
		update agro_fuel_level_alarm set is_checked = 1, is_alarm = @is_alarm, send_email = @send_email where id = @id

		while LEN(@device_list) > 0
		begin
			declare @commaPosition int = PATINDEX('%,%', @device_list)
			declare @dev_id int = CONVERT(int, LEFT(@device_list, @commaPosition - 1))
		
			insert into agro_fuel_alarms_found_devices(alarm_id, device_id) values (@id, @dev_id)
		
			set @device_list = SUBSTRING(@device_list, @commaPosition + 1, LEN(@device_list) - @commaPosition)
		end
		set @volta = @volta + 1

		if @is_alarm = 0 break --если на каком-либо этапе выяснится, что все хорошо, то прерываем проверку
	end

	select top 1 @id = id, @slisedate = datadatetime, @pos_id = id_pos from [agro_fuel_level_alarm] where is_checked = 0 and id > @id order by id
end 

if @is_alarm = 1 
begin
	exec updateAlarmStatus @id_alarm, 1
	exec setNextAlarmStage @id_alarm, 1
end
END
