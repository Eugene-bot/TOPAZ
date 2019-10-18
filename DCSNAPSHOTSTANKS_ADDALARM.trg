CREATE OR ALTER trigger dcsnapshotstanks_addalarm for "dcSnapshotsTanks"
active after insert position 11
AS
declare variable OLD_MASS NUMERIC(15,2);
declare variable AZS_CODE VARCHAR(40);
declare variable PREV_TIME TIMESTAMP;
declare variable ZAPR_TIME TIMESTAMP;
declare variable ID_LAST_ZAPR INTEGER;
begin
    if (new."TankID" <> 9) then -- исключаем из проверки виртуальную емкость № 9
    begin
  /*Получаем имя склада (код АЗС), на котором произошло событие*/
  select "dcPointsOfSales"."PosName"
  from "dcPointsOfSales"
  where "dcPointsOfSales"."PointOfSalesID" = new."PointOfSalesID"
  into AZS_CODE;

  /* Получаем время последней заправки с этого склада*/
  select MAX("rgAmountRests"."Date")
  from "rgAmountRests"
  where "rgAmountRests"."AZSCode" = :AZS_CODE and "rgAmountRests"."Date" <= new."SnapshotDate"
  group by "rgAmountRests"."AZSCode"
  into ZAPR_TIME;

  /* Получаем ИД записи последней заправки с этого склада*/
  select "rgAmountRests"."AmountRestID"  from "rgAmountRests"
  where  "rgAmountRests"."AZSCode" = :AZS_CODE and "rgAmountRests"."Date" = :ZAPR_TIME
  into ID_LAST_ZAPR;

  /* Находим следующую по времени запись в таблице "dcSnapshotsTanks"*/
    select  MIN("dcSnapshotsTanks"."SnapshotDate") from "dcSnapshotsTanks"
    where "dcSnapshotsTanks"."TankID" = new."TankID" and "dcSnapshotsTanks"."SnapshotDate" > :ZAPR_TIME
    group by "dcSnapshotsTanks"."TankID"
    into PREV_TIME;

    /* Находим массу топлива*/
    select "dcSnapshotsTanks"."Mass"
    from "dcSnapshotsTanks"
    where "dcSnapshotsTanks"."TankID" = new."TankID" and "dcSnapshotsTanks"."SnapshotDate" = :PREV_TIME
    into OLD_MASS;

    /*Проверяем величину отклонения*/
    if ((OLD_MASS - new."Mass") > 20) then
    begin
        insert into "AGRO_FUEL_LEVEL_ALARM" ("DATADATETIME", "DIFFERENCE", "TANKID", "SNAPSHOTID", "POS_ID", "DATE_LAST_ZAPR","MASS_LAST_ZAPR", "CURRENT_MASS", "ID_LAST_ZAPR")
        VALUES (new."SnapshotDate",(:OLD_MASS - new."Mass"), new."TankID", new."SnapshotTankID", new."PointOfSalesID", :ZAPR_TIME, :OLD_MASS, new."Mass", :ID_LAST_ZAPR );
    end
    end
end
