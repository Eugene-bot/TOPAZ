/******************************************************************************/
/***               Generated by IBExpert 21.01.2020 10:22:23                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/


CREATE GENERATOR "GEN_AGRO_FUEL_30CM_ID";

CREATE TABLE AGRO_FUEL_LEVEL_ALARM_30CM (
    ID            TID /* TID = INTEGER */,
    DATADATETIME  "TDateTime" /* "TDateTime" = TIMESTAMP */,
    POS_ID        TID /* TID = INTEGER */,
    TANK_ID       TID /* TID = INTEGER */,
    TANK_NUMBER   TINT /* TINT = INTEGER */,
    FUEL_LEVEL    TINT /* TINT = INTEGER */,
    FUEL_MASS     "TCurrency" /* "TCurrency" = NUMERIC(15,2) */
);




/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/



SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: AGRO_FUEL_LEVEL_ALARM_30CM_BI0 */
CREATE OR ALTER TRIGGER AGRO_FUEL_LEVEL_ALARM_30CM_BI0 FOR AGRO_FUEL_LEVEL_ALARM_30CM
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  if (new."ID" is null) then
    new."ID" = gen_id("GEN_AGRO_FUEL_30CM_ID",1);
end
^

SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
