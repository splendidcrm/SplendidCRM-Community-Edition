

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Config en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_CANNOT_EDIT_MAX_USERS'                     , N'en-US', N'Config', null, null, N'Cannot Edit Max Users.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATEGORY'                                  , N'en-US', N'Config', null, null, N'Category:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CATEGORY'                             , N'en-US', N'Config', null, null, N'Category';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Config', null, null, N'Config List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Config', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_VALUE'                                , N'en-US', N'Config', null, null, N'Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Config', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Config', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VALUE'                                     , N'en-US', N'Config', null, null, N'Value:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CONFIG_LIST'                               , N'en-US', N'Config', null, null, N'System Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CONFIG'                                , N'en-US', N'Config', null, null, N'Create New Setting';
-- 04/09/2019 Paul.  Error when saving a secured value when not changed. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_SECURED_VALUE_UNCHANGED'                   , N'en-US', N'Config', null, null, N'Secured value has not changed.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Config', null, null, N'Create New Setting';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Config', null, null, N'Cnf';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Config'                                        , N'en-US', null, N'moduleList'                        ,  38, N'Configuration';
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

call dbo.spTERMINOLOGY_Config_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Config_en_us')
/
-- #endif IBM_DB2 */
