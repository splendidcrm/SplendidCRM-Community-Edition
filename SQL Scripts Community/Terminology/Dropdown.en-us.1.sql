

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY Dropdown en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DROPDOWN'                                  , N'en-US', N'Dropdown', null, null, N'Dropdown:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_KEY'                                       , N'en-US', N'Dropdown', null, null, N'Key';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LANGUAGE'                                  , N'en-US', N'Dropdown', null, null, N'Language:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Dropdown', null, null, N'Dropdown List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Dropdown', null, null, N'Dropdown Select';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VALUE'                                     , N'en-US', N'Dropdown', null, null, N'Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DELETE'                                    , N'en-US', N'Dropdown', null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DOWN'                                      , N'en-US', N'Dropdown', null, null, N'Down';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DROPDOWNS'                                 , N'en-US', N'Dropdown', null, null, N'Dropdowns';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_EDIT'                                      , N'en-US', N'Dropdown', null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_INS'                                       , N'en-US', N'Dropdown', null, null, N'Ins';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_DROPDOWN'                              , N'en-US', N'Dropdown', null, null, N'Create Dropdown';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_UP'                                        , N'en-US', N'Dropdown', null, null, N'Up';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Dropdown', null, null, N'Drp';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Dropdown'                                      , N'en-US', null, N'moduleList'                        ,  34, N'Dropdown';
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

call dbo.spTERMINOLOGY_Dropdown_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Dropdown_en_us')
/
-- #endif IBM_DB2 */
