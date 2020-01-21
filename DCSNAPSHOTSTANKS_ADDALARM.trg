CREATE OR ALTER trigger dcsnapshotstanks_addalarm for "dcSnapshotsTanks"
active after insert position 11
AS
declare variable OLD_MASS NUMERIC(15,2);
declare variable AZS_CODE VARCHAR(40);
declare variable PREV_TIME TIMESTAMP;
declare variable ZAPR_TIME TIMESTAMP;
declare variable ALARM_TIME TIMESTAMP;
declare variable RECEPT_TIME TIMESTAMP;
declare variable START_TIME TIMESTAMP;
declare variable IS_VIRTUAL INTEGER;
declare variable EVENT_TYPE VARCHAR(40);

begin
    select "dcTanks".ISVIRTUAL from "dcTanks"
    where "dcTanks"."TankID" = new."TankID" 
    into IS_VIRTUAL;

    if (IS_VIRTUAL = 0) then -- исключаем из проверки виртуальные емкости
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
        
        /* 4. Получаем время последнего поступления топлива на этот склад */
        select MAX("flRecepts"."EndDateTime") from "flRecepts"
        join "flSesTanks" on "flRecepts"."SesTankID" = "flSesTanks"."SesTankID"
        join "flSessions" on "flSesTanks"."SessionID" = "flSessions"."SessionID"
        where "flSessions"."AzsCode" = :AZS_CODE and "flSesTanks"."TankNum" = new."TankNum"
        into RECEPT_TIME;
        
        /* 5 Определяем, от какого события будем отталкиваться и его время */
        if (ZAPR_TIME > ALARM_TIME) then 
        begin
            EVENT_TYPE = 'Отпуск';
            START_TIME = ZAPR_TIME;
        end
        else
        begin
           EVENT_TYPE = 'Аларм';
           START_TIME = ALARM_TIME;
        end
        
        if (RECEPT_TIME > START_TIME) then
        begin
            EVENT_TYPE = 'Поступление';
            START_TIME = RECEPT_TIME;
        end
        
        /* 6. Находим следующую по времени запись в таблице "dcSnapshotsTanks"*/
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
            insert into "AGRO_FUEL_LEVEL_ALARM" ("DATADATETIME", "DIFF", "TANKID", "SNAPSHOTID", "POS_ID", "LASTDATETIME","MASS_LAST_ZAPR", "CURRENT_MASS", "TYPE_LAST_EVENT")
            VALUES (new."SnapshotDate",(:OLD_MASS - new."Mass"), new."TankID", new."SnapshotTankID", new."PointOfSalesID", :START_TIME, :OLD_MASS, new."Mass", :EVENT_TYPE);
        end
    end
end
