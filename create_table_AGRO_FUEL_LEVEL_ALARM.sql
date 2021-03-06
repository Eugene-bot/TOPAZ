/******************************************************************************/
/***               Generated by IBExpert 30.10.2019 13:27:50                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/


CREATE GENERATOR "GEN_AGRO_FUEL_LEVEL_ALARM_ID";

CREATE TABLE AGRO_FUEL_LEVEL_ALARM (
    ID               TID /* TID = INTEGER */,
    DATADATETIME     "TDateTime" /* "TDateTime" = TIMESTAMP */,
    POS_ID           TID /* TID = INTEGER */,
    TANKID           TID /* TID = INTEGER */,
    DIFF             "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    SNAPSHOTID       TID /* TID = INTEGER */,
    CURRENT_MASS     "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    MASS_LAST_ZAPR   "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    DATE_LAST_ZAPR   "TDateTime" /* "TDateTime" = TIMESTAMP */,
    ID_LAST_ZAPR     TID /* TID = INTEGER */,
    DATE_LAST_ALARM  "TDateTime" /* "TDateTime" = TIMESTAMP */,
    ID_LAST_ALARM    TID /* TID = INTEGER */
);




/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/



SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: AGRO_FUEL_LEVEL_ALARM_BI0 */
CREATE OR ALTER TRIGGER AGRO_FUEL_LEVEL_ALARM_BI0 FOR AGRO_FUEL_LEVEL_ALARM
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  if (new."ID" is null) then
    new."ID" = gen_id("GEN_AGRO_FUEL_LEVEL_ALARM_ID",1);
end
^

SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/

