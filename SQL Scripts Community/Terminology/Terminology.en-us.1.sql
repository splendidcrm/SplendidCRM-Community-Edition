

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Terminology en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISPLAY_NAME'                              , N'en-US', N'Terminology', null, null, N'Display Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GLOBAL_TERMS'                              , N'en-US', N'Terminology', null, null, N'Global Terms';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_TERMINOLOGY_INSTRUCTIONS'           , N'en-US', N'Terminology', null, null, N'SplendidCRM can import a SugarCRM language pack.  The language pack is expected to be a zipped collection of PHP files.  Some files, such as Japanese, require the UTF8 option.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INCLUDE_LISTS'                             , N'en-US', N'Terminology', null, null, N'Include Lists';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LANG'                                      , N'en-US', N'Terminology', null, null, N'Language:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DISPLAY_NAME'                         , N'en-US', N'Terminology', null, null, N'Display Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Terminology', null, null, N'Terminology List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LANG'                                 , N'en-US', N'Terminology', null, null, N'Language';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LIST_NAME'                            , N'en-US', N'Terminology', null, null, N'List Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LIST_ORDER'                           , N'en-US', N'Terminology', null, null, N'List Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Terminology', null, null, N'Module Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Terminology', null, null, N'List Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME_LABEL'                           , N'en-US', N'Terminology', null, null, N'Name Label';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME_NAME'                            , N'en-US', N'Terminology', null, null, N'Name Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORDER'                                , N'en-US', N'Terminology', null, null, N'List Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Terminology', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Terminology', null, null, N'Ter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Terminology', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Terminology', null, null, N'Create Terminology';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Terminology', null, null, N'Search';
-- 09/11/2021 Paul.  The React client requires relationship. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUGARCRM_LANGUAGE_PACKS'                   , N'en-US', N'Terminology', null, null, N'SugarCRM Language Packs';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SPLENDIDCRM_LANGUAGE_PACKS'                , N'en-US', N'Terminology', null, null, N'SplendidCRM Language Packs';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_NAME'                          , N'en-US', N'Terminology', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_DATE'                          , N'en-US', N'Terminology', null, null, N'Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_DESCRIPTION'                   , N'en-US', N'Terminology', null, null, N'Description';
GO

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Terminology'                                   , N'en-US', null, N'moduleList'                        ,  37, N'Terminology';
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

call dbo.spTERMINOLOGY_Terminology_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Terminology_en_us')
/
-- #endif IBM_DB2 */
