AS
declare variable OLD_MASS NUMERIC(15,2);
declare variable AZS_CODE VARCHAR(40);
declare variable PREV_TIME TIMESTAMP;
declare variable ZAPR_TIME TIMESTAMP;
declare variable ALARM_TIME TIMESTAMP;
declare variable START_TIME TIMESTAMP;
declare variable ID_LAST_ZAPR INTEGER;
declare variable ID_LAST_ALARM INTEGER;

begin
    if (new."TankID" <> 9) then -- исключаем из проверки виртуальную емкость № 9
    begin
        /* 1. Получаем имя склада (код АЗС), на котором произошло событие*/
        select "dcPointsOfSales"."PosName" from "dcPointsOfSales"
        where "dcPointsOfSales"."PointOfSalesID" = new."PointOfSalesID"
        into AZS_CODE;

        /* 2. Получаем время последней заправки с этого склада*/
        select MAX("rgAmountRests"."Date") from "rgAmountRests"
        where "rgAmountRests"."AZSCode" = :AZS_CODE and "rgAmountRests"."Date" <= new."SnapshotDate"
        --group by "rgAmountRests"."AZSCode"
        into ZAPR_TIME;
        
        /* 3. Получаем время последнего аларма с этого склада */
        select MAX("AGRO_FUEL_LEVEL_ALARM"."DATADATETIME") from "AGRO_FUEL_LEVEL_ALARM"
        where "AGRO_FUEL_LEVEL_ALARM"."POS_ID" = new."PointOfSalesID" and "AGRO_FUEL_LEVEL_ALARM"."DATADATETIME" <= new."SnapshotDate"
        --group by "AGRO_FUEL_LEVEL_ALARM"."POS_ID"
        into ALARM_TIME;
        
        /* 4. */
        if (ZAPR_TIME > ALARM_TIME) then
        begin
            /* Получаем ИД записи последней заправки с этого склада*/
            select max("rgAmountRests"."AmountRestID") from "rgAmountRests"
            where  "rgAmountRests"."AZSCode" = :AZS_CODE and "rgAmountRests"."Date" = :ZAPR_TIME
            into ID_LAST_ZAPR;
            
            START_TIME = ZAPR_TIME;
        end
        else
        begin
            /* Получаем ИД записи последнего аларма с этого склада*/
           select max("AGRO_FUEL_LEVEL_ALARM"."ID") from "AGRO_FUEL_LEVEL_ALARM"
           where  "AGRO_FUEL_LEVEL_ALARM"."POS_ID" = new."PointOfSalesID" and "AGRO_FUEL_LEVEL_ALARM"."DATADATETIME" = :ALARM_TIME
           into ID_LAST_ALARM;
           
           START_TIME = ALARM_TIME;
        end

        /* 5. Находим следующую по времени запись в таблице "dcSnapshotsTanks"*/
        select  MIN("dcSnapshotsTanks"."SnapshotDate") from "dcSnapshotsTanks"
        where "dcSnapshotsTanks"."TankID" = new."TankID" and "dcSnapshotsTanks"."SnapshotDate" > :START_TIME --and  "dcSnapshotsTanks"."SnapshotDate" < new."SnapshotDate"
        --group by "dcSnapshotsTanks"."TankID"
        into PREV_TIME;

        /* 6. Получаем "исходную" массу топлива в топливной емкости */
        select "dcSnapshotsTanks"."Mass" from "dcSnapshotsTanks"
        where "dcSnapshotsTanks"."TankID" = new."TankID" and "dcSnapshotsTanks"."SnapshotDate" = :PREV_TIME
        into OLD_MASS;

        /* 7. Проверяем величину отклонения, при необходимости добавляем аларм */
        if ((OLD_MASS - new."Mass") > 20) then
        begin
            insert into "AGRO_FUEL_LEVEL_ALARM" ("DATADATETIME", "DIFF", "TANKID", "SNAPSHOTID", "POS_ID", "DATE_LAST_ZAPR","MASS_LAST_ZAPR", "CURRENT_MASS", "ID_LAST_ZAPR", "DATE_LAST_ALARM", "ID_LAST_ALARM")
            VALUES (new."SnapshotDate",(:OLD_MASS - new."Mass"), new."TankID", new."SnapshotTankID", new."PointOfSalesID", :ZAPR_TIME, :OLD_MASS, new."Mass", :ID_LAST_ZAPR, :ALARM_TIME, :ID_LAST_ALARM );
        end
    end
end