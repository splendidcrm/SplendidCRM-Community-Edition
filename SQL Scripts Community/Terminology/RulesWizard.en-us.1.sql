

-- Terminology generated from database [SplendidCRM6_50] on 11/18/2010 11:58:30 PM.
print 'TERMINOLOGY RulesWizard en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_BUTTON_LABEL'                       , N'en-US', N'RulesWizard', null, null, N'Create Rule';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ERROR'                                     , N'en-US', N'RulesWizard', null, null, N'Error: ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAIL'                                      , N'en-US', N'RulesWizard', null, null, N'Fail:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAILED_IMPORT'                             , N'en-US', N'RulesWizard', null, null, N'{0} Failed Import';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'RulesWizard', null, null, N'Rules Wizard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_ROW_ERROR'                     , N'en-US', N'RulesWizard', null, null, N'Error';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_ROW_NUMBER'                    , N'en-US', N'RulesWizard', null, null, N'Row';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_ROW_STATUS'                    , N'en-US', N'RulesWizard', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAX_ERRORS'                                , N'en-US', N'RulesWizard', null, null, N'Rules Wizard stopped after too many errors';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_FILTER'                            , N'en-US', N'RulesWizard', null, null, N'Preview Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_RULES'                             , N'en-US', N'RulesWizard', null, null, N'Preview Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RULES_WIZARD_BUTTON_LABEL'                 , N'en-US', N'RulesWizard', null, null, N'Rules Wizard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RULES_WIZARD_BUTTON_TITLE'                 , N'en-US', N'RulesWizard', null, null, N'Rules Wizard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBMIT_RULES'                              , N'en-US', N'RulesWizard', null, null, N'Submit Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUCCESS'                                   , N'en-US', N'RulesWizard', null, null, N'Success:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUCCESSFULLY'                              , N'en-US', N'RulesWizard', null, null, N'{0} Successfully imported';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USE_TRANSACTION'                           , N'en-US', N'RulesWizard', null, null, N'Use Transaction:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP1'                              , N'en-US', N'RulesWizard', null, null, N'1. Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP2'                              , N'en-US', N'RulesWizard', null, null, N'2. Module Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP3'                              , N'en-US', N'RulesWizard', null, null, N'3. Rule Definitions';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP4'                              , N'en-US', N'RulesWizard', null, null, N'4. Results';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_RULES'                                     , N'en-US', N'RulesWizard', null, null, N'Rules';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'RulesWizard', null, null, N'RW';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'RulesWizard'                                   , N'en-US', null, N'moduleList'                        , 101, N'Rules Wizard';
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

call dbo.spTERMINOLOGY_RulesWizard_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_RulesWizard_en_us')
/
-- #endif IBM_DB2 */
