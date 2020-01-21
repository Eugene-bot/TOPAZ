CREATE OR ALTER trigger dcsnap_tanks_add_alarm_30cm for "dcSnapshotsTanks"
active after insert position 15
AS
declare variable MASS_30CM NUMERIC(15,2);
declare variable MASS_2MM_30CM NUMERIC(15,2);
declare variable MAX_MASS NUMERIC(15,2);
declare variable ZERO_TIME TIMESTAMP;
declare variable START_TIME TIMESTAMP;

begin
    if (MASS_30CM is null) then select MAX(MASS_30CM) from "dcTanks" into MASS_30CM; --���� ��� ������� �� ������� ��������, �������� ������������ �������� ����� ���� ��������

    if (new."Mass" < MASS_30CM) then -- ���� ����� ������� ������ "�����������"
    begin
        ZERO_TIME = '2001.01.01 00:00:00';
        select MAX(DELTA_2MM_30CM) from "dcTanks" where "dcTanks"."TankID" = new."TankID" into MASS_2MM_30CM;
        if (MASS_2MM_30CM is null) then select MAX(DELTA_2MM_30CM) from "dcTanks" into MASS_2MM_30CM; --���� ��� ������� �� ������� ��������, �������� ������������ �������� ����� ���� ��������

        /* 1. �������� ����/����� ����������� ������ */
        select MAX("AGRO_FUEL_LEVEL_ALARM_30CM"."DATADATETIME") from "AGRO_FUEL_LEVEL_ALARM_30CM"
        where "AGRO_FUEL_LEVEL_ALARM_30CM"."TANK_ID" = new."TankID" and "AGRO_FUEL_LEVEL_ALARM_30CM"."DATADATETIME" <= new."SnapshotDate"
        into START_TIME;
        if (START_TIME IS NULL) then START_TIME = ZERO_TIME;

        /* 2. �������� ������������ ����� ������� � ������� ����������� ������ */
        select MAX("Mass") from "dcSnapshotsTanks"
        where "dcSnapshotsTanks"."TankID" = new."TankID" and "dcSnapshotsTanks"."SnapshotDate" >= :START_TIME
        into MAX_MASS;
        if (MAX_MASS IS NULL) then MAX_MASS = 0.00;

        /* 3. ���� ������� ��������� ���������� - �����! */
        if ((MAX_MASS - new."Mass") > MASS_2MM_30CM) then
        begin
             insert into "AGRO_FUEL_LEVEL_ALARM_30CM" ("DATADATETIME", "POS_ID", "TANK_ID", "TANK_NUMBER", "FUEL_MASS", "FUEL_LEVEL")
            VALUES (new."SnapshotDate",new."PointOfSalesID", new."TankID", new."TankNum", new."Mass", new."Height");
        end
    end
end