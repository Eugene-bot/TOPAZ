/******************************************************************************/
/***               Generated by IBExpert 18.10.2019 13:06:01                ***/
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
    DATETIME        "TDateTime" /* "TDateTime" = TIMESTAMP */,
    ID              INTEGER,
    QUANTITY        TINT /* TINT = INTEGER */,
    DIFFERENCE      "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    TANKID          TINT /* TINT = INTEGER */,
    SNAPSHOTID      TID /* TID = INTEGER */,
    POS_ID          TID /* TID = INTEGER */,
    TEST_STRING     "TName" /* "TName" = VARCHAR(50) */,
    DATE_LAST_ZAPR  "TDateTime" /* "TDateTime" = TIMESTAMP */,
    MASS_LAST_ZAPR  "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    CURRENT_MASS    "TCurrency" /* "TCurrency" = NUMERIC(15,2) */,
    ID_LAST_ZAPR    TID /* TID = INTEGER */
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
