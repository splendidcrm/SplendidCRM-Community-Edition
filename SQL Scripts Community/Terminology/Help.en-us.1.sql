

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Help en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HELP_BOOKMARK'                             , N'en-US', N'Help', null, null, N'Bookmark this page';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HELP_EMAIL'                                , N'en-US', N'Help', null, null, N'Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HELP_PRINT'                                , N'en-US', N'Help', null, null, N'Print';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Help', null, null, N'Help List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LANG'                                 , N'en-US', N'Help', null, null, N'Language';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Help', null, null, N'Module Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Help', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TOPICS'                                    , N'en-US', N'Help', null, null, N'Topics';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST'                                      , N'en-US', N'Help', null, null, N'Test';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Help', null, null, N'Hlp';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Help'                                          , N'en-US', null, N'moduleList'                        ,  65, N'Help';
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

call dbo.spTERMINOLOGY_Help_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Help_en_us')
/
-- #endif IBM_DB2 */
