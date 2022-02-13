

-- Terminology generated from database [SplendidCRM6_50] on 11/18/2010 11:37:52 PM.
print 'TERMINOLOGY BusinessRules en-us';
GO

set nocount on;
GO

-- 03/28/2019 Paul.  Every module should have a LBL_NEW_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'BusinessRules', null, null, N'Business Rules';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUSINESS_RULES'                            , N'en-US', N'BusinessRules', null, null, N'Create rules for use in the layout editors';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUSINESS_RULES_TITLE'                      , N'en-US', N'BusinessRules', null, null, N'Business Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_BUTTON_LABEL'                       , N'en-US', N'BusinessRules', null, null, N'Create Rule';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'BusinessRules', null, null, N'Business Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_EVENT_NAME'                            , N'en-US', N'BusinessRules', null, null, N'New Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POST_LOAD_EVENT_NAME'                      , N'en-US', N'BusinessRules', null, null, N'Post-Load Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POST_SAVE_EVENT_NAME'                      , N'en-US', N'BusinessRules', null, null, N'Post-Save Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRE_LOAD_EVENT_NAME'                       , N'en-US', N'BusinessRules', null, null, N'Pre-Load Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRE_SAVE_EVENT_NAME'                       , N'en-US', N'BusinessRules', null, null, N'Pre-Save Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROW_LOAD_EVENT_NAME'                       , N'en-US', N'BusinessRules', null, null, N'Row-Load Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABLE_LOAD_EVENT_NAME'                     , N'en-US', N'BusinessRules', null, null, N'Table-Load Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_FILTER'                            , N'en-US', N'BusinessRules', null, null, N'Preview Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_RULES'                             , N'en-US', N'BusinessRules', null, null, N'Preview Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBMIT_RULES'                              , N'en-US', N'BusinessRules', null, null, N'Submit Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VALIDATION_EVENT_NAME'                     , N'en-US', N'BusinessRules', null, null, N'Validation Event:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP1'                              , N'en-US', N'BusinessRules', null, null, N'1. Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP2'                              , N'en-US', N'BusinessRules', null, null, N'2. Module Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP3'                              , N'en-US', N'BusinessRules', null, null, N'3. Rule Definitions';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_STEP4'                              , N'en-US', N'BusinessRules', null, null, N'4. Results';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_RULES'                                     , N'en-US', N'BusinessRules', null, null, N'Business Rules';

-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SCRIPT'                                    , N'en-US', N'BusinessRules', null, null, N'Layout JavaScript:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'BusinessRules', null, null, N'BR';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'BusinessRules'                                 , N'en-US', null, N'moduleList'                        , 101, N'Business Rules';
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

call dbo.spTERMINOLOGY_BusinessRules_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_BusinessRules_en_us')
/
-- #endif IBM_DB2 */
