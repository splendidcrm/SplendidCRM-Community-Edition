

-- Terminology generated from database [SplendidCRM6_50] on 11/18/2010 11:38:01 PM.
print 'TERMINOLOGY Rules en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NO_RULES'                                  , N'en-US', N'Rules', null, null, N'No rules have been specified.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTIVE'                                    , N'en-US', N'Rules', null, null, N'Active:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHAINING'                                  , N'en-US', N'Rules', null, null, N'Chaining:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONDITION'                                 , N'en-US', N'Rules', null, null, N'Condition (Example: this["CITY"] == DBNull.Value || this["CITY"] == String.Empty):';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ELSE_ACTIONS'                              , N'en-US', N'Rules', null, null, N'Else Actions:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ID'                                        , N'en-US', N'Rules', null, null, N'ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ACTIVE'                               , N'en-US', N'Rules', null, null, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CONDITION'                            , N'en-US', N'Rules', null, null, N'Condition';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ELSE_ACTIONS'                         , N'en-US', N'Rules', null, null, N'Else Actions';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ID'                                   , N'en-US', N'Rules', null, null, N'ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Rules', null, null, N'Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Rules', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIORITY'                             , N'en-US', N'Rules', null, null, N'Priority';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REEVALUATION'                         , N'en-US', N'Rules', null, null, N'Reevaluation';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RULE_NAME'                            , N'en-US', N'Rules', null, null, N'Rule Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_THEN_ACTIONS'                         , N'en-US', N'Rules', null, null, N'Then Actions';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Rules', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Rules', null, null, N'Rul';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Rules', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIORITY'                                  , N'en-US', N'Rules', null, null, N'Priority:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REEVALUATION'                              , N'en-US', N'Rules', null, null, N'Reevaluation:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_BUTTON_LABEL'                       , N'en-US', N'Rules', null, null, N'Remove';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_BUTTON_TITLE'                       , N'en-US', N'Rules', null, null, N'Remove';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RULE_NAME'                                 , N'en-US', N'Rules', null, null, N'Rule Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_THEN_ACTIONS'                              , N'en-US', N'Rules', null, null, N'Then Actions (Example: this["CITY"] = "value is null"):';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */

exec dbo.spTERMINOLOGY_InsertOnly N'Sequential'                                    , N'en-US', null, N'rules_chaining_dom'                ,   0, N'Sequential';
exec dbo.spTERMINOLOGY_InsertOnly N'Explicit Update Only'                          , N'en-US', null, N'rules_chaining_dom'                ,   1, N'Explicit Update Only';
exec dbo.spTERMINOLOGY_InsertOnly N'Full Chaining'                                 , N'en-US', null, N'rules_chaining_dom'                ,   2, N'Full Chaining';

-- 10/25/2010 Paul.  You have to be careful with Reevaluation Always as it will re-evaluate after the Then or Else actions to see if it needs to be run again. 
exec dbo.spTERMINOLOGY_InsertOnly N'Never'                                         , N'en-US', null, N'rules_reevaluation_dom'            ,   0, N'Never';
exec dbo.spTERMINOLOGY_InsertOnly N'Always'                                        , N'en-US', null, N'rules_reevaluation_dom'            ,   1, N'Always';
GO


set nocount off;
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_Rules_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Rules_en_us')
/
-- #endif IBM_DB2 */
