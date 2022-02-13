

print 'TERMINOLOGY Undelete en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Undelete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Undelete', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_TOKEN'                          , N'en-US', N'Undelete', null, null, N'Audit Token';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODIFIED_BY'                          , N'en-US', N'Undelete', null, null, N'Deleted By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_DATE'                           , N'en-US', N'Undelete', null, null, N'Date Deleted';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Undelete', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_TOKEN'                               , N'en-US', N'Undelete', null, null, N'Audit Token:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Undelete', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Undelete', null, null, N'Und';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_BY'                               , N'en-US', N'Undelete', null, null, N'Deleted By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_DATE'                                , N'en-US', N'Undelete', null, null, N'Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETING'                                , N'en-US', N'Undelete', null, null, N'Undeleting in the background.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTHING_SELECTED'                          , N'en-US', N'Undelete', null, null, N'Nothing was selected.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'Undelete', null, null, N'Undelete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Undelete', null, null, N'Undelete List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETE_BUTTON_LABEL'                     , N'en-US', N'Undelete', null, null, N'Undelete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETE_BUTTON_TITLE'                     , N'en-US', N'Undelete', null, null, N'Undelete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACKGROUND_OPERATION'                      , N'en-US', N'Undelete', null, null, N'Perform operation in background.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETE_COMPLETE'                         , N'en-US', N'Undelete', null, null, N'Undeleted {0} {1}.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETE_TITLE'                            , N'en-US', N'Administration', null, null, N'Undelete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNDELETE'                                  , N'en-US', N'Administration', null, null, N'Undelete records.';

exec dbo.spTERMINOLOGY_InsertOnly N'Undelete'                                      , N'en-US', null, N'moduleList', 115, N'Undelete';
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

call dbo.spTERMINOLOGY_Undelete_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Undelete_en_us')
/
-- #endif IBM_DB2 */
