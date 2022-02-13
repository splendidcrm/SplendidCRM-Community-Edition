

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:38 AM.
print 'TERMINOLOGY Modules en-us';
GO

set nocount on;
GO

-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MODULE_NOT_FOUND'                          , N'en-US', N'Modules', null, null, N'Module Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_ENABLED'                            , N'en-US', N'Modules', null, null, N'Custom Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_PAGING'                             , N'en-US', N'Modules', null, null, N'Custom Paging:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_PAGING_DISABLED'                    , N'en-US', N'Modules', null, null, N'Custom Paging is disabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_PAGING_ENABLED'                     , N'en-US', N'Modules', null, null, N'Custom Paging is enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_SEARCH_ENABLED'                    , N'en-US', N'Modules', null, null, N'Default Search:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISABLE'                                   , N'en-US', N'Modules', null, null, N'Disable Paging';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISPLAY_NAME'                              , N'en-US', N'Modules', null, null, N'Display Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLE'                                    , N'en-US', N'Modules', null, null, N'Enable Paging';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_CREATE_PARENT'                    , N'en-US', N'Modules', null, null, N'Exchange Create Parent:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_FOLDERS'                          , N'en-US', N'Modules', null, null, N'Exchange Folders:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_SYNC'                             , N'en-US', N'Modules', null, null, N'Exchange Sync:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_ENABLED'                            , N'en-US', N'Modules', null, null, N'Import Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_ADMIN'                                  , N'en-US', N'Modules', null, null, N'Is Admin:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CUSTOM_ENABLED'                       , N'en-US', N'Modules', null, null, N'Custom Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CUSTOM_PAGING'                        , N'en-US', N'Modules', null, null, N'Custom Paging';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEFAULT_SEARCH_ENABLED'               , N'en-US', N'Modules', null, null, N'Default Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DISPLAY_NAME'                         , N'en-US', N'Modules', null, null, N'Display Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EXCHANGE_CREATE_PARENT'               , N'en-US', N'Modules', null, null, N'Create Parent';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EXCHANGE_FOLDERS'                     , N'en-US', N'Modules', null, null, N'Exchange Folders';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EXCHANGE_SYNC'                        , N'en-US', N'Modules', null, null, N'Exchange Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Modules', null, null, N'Module List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMPORT_ENABLED'                       , N'en-US', N'Modules', null, null, N'Import Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_ADMIN'                             , N'en-US', N'Modules', null, null, N'Is Admin';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MASS_UPDATE_ENABLED'                  , N'en-US', N'Modules', null, null, N'Mass Update Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MOBILE_ENABLED'                       , N'en-US', N'Modules', null, null, N'Mobile Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_ENABLED'                       , N'en-US', N'Modules', null, null, N'Module Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Modules', null, null, N'Module Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PORTAL_ENABLED'                       , N'en-US', N'Modules', null, null, N'Portal Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RELATIVE_PATH'                        , N'en-US', N'Modules', null, null, N'Relative Path';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REPORT_ENABLED'                       , N'en-US', N'Modules', null, null, N'Report Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REST_ENABLED'                         , N'en-US', N'Modules', null, null, N'REST Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SYNC_ENABLED'                         , N'en-US', N'Modules', null, null, N'Sync Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TAB_ENABLED'                          , N'en-US', N'Modules', null, null, N'Tab Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TAB_ORDER'                            , N'en-US', N'Modules', null, null, N'Tab Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TABLE_NAME'                           , N'en-US', N'Modules', null, null, N'Table Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MASS_UPDATE_ENABLED'                       , N'en-US', N'Modules', null, null, N'Mass Update Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MOBILE_ENABLED'                            , N'en-US', N'Modules', null, null, N'Mobile Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ENABLED'                            , N'en-US', N'Modules', null, null, N'Module Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Modules', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Modules', null, null, N'Mod';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PORTAL_ENABLED'                            , N'en-US', N'Modules', null, null, N'Portal Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELATIVE_PATH'                             , N'en-US', N'Modules', null, null, N'Relative Path:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPORT_ENABLED'                            , N'en-US', N'Modules', null, null, N'Report Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REST_ENABLED'                              , N'en-US', N'Modules', null, null, N'REST Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_ENABLED'                              , N'en-US', N'Modules', null, null, N'Sync Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAB_ENABLED'                               , N'en-US', N'Modules', null, null, N'Tab Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAB_ORDER'                                 , N'en-US', N'Modules', null, null, N'Tab Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABLE_NAME'                                , N'en-US', N'Modules', null, null, N'Table Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_MODULE_LIST'                               , N'en-US', N'Modules', null, null, N'Modules';
exec dbo.spTERMINOLOGY_InsertOnly N'Modules.ERR_MODULE_NOT_FOUND'                  , N'en-US', N'Modules', null, null, N'Modules.err Module Not Found';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Modules', null, null, N'Create Module';

-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DUPLICATE_CHECHING_ENABLED'                , N'en-US', N'Modules', null, null, N'Duplicate Checking Enabled:';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUILD_ARCHIVE_TABLE'                       , N'en-US', N'Modules', null, null, N'Build Archive Table';
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RECORD_LEVEL_SECURITY_ENABLED'             , N'en-US', N'Modules', null, null, N'Record Level Security Enabled:';
-- 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REACT_CLIENT_ENABLE'                       , N'en-US', N'Modules', null, null, N'Enable React';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REACT_CLIENT_IS_ENABLED'                   , N'en-US', N'Modules', null, null, N'React Client is Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REACT_CLIENT_DISABLE'                      , N'en-US', N'Modules', null, null, N'Disable React';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REACT_CLIENT_IS_DISABLED'                  , N'en-US', N'Modules', null, null, N'React Client is Disabled';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Modules'                                       , N'en-US', null, N'moduleList'                        ,  81, N'Modules';

exec dbo.spTERMINOLOGY_InsertOnly N'Accounts'                                      , N'en-US', null, N'record_type_display'               ,   1, N'Account';
exec dbo.spTERMINOLOGY_InsertOnly N'Opportunities'                                 , N'en-US', null, N'record_type_display'               ,   2, N'Opportunity';
exec dbo.spTERMINOLOGY_InsertOnly N'Cases'                                         , N'en-US', null, N'record_type_display'               ,   3, N'Case';
exec dbo.spTERMINOLOGY_InsertOnly N'Leads'                                         , N'en-US', null, N'record_type_display'               ,   4, N'Lead';
exec dbo.spTERMINOLOGY_InsertOnly N'Contacts'                                      , N'en-US', null, N'record_type_display'               ,   5, N'Contact';
exec dbo.spTERMINOLOGY_InsertOnly N'Bugs'                                          , N'en-US', null, N'record_type_display'               ,   6, N'Bug';
exec dbo.spTERMINOLOGY_InsertOnly N'Project'                                       , N'en-US', null, N'record_type_display'               ,   7, N'Project';
exec dbo.spTERMINOLOGY_InsertOnly N'ProjectTask'                                   , N'en-US', null, N'record_type_display'               ,   8, N'Project Task';
exec dbo.spTERMINOLOGY_InsertOnly N'Tasks'                                         , N'en-US', null, N'record_type_display'               ,   9, N'Task';
exec dbo.spTERMINOLOGY_InsertOnly N'Prospects'                                     , N'en-US', null, N'record_type_display'               ,  10, N'Target';
exec dbo.spTERMINOLOGY_InsertOnly N'Calls'                                         , N'en-US', null, N'record_type_display'               ,  11, N'Call';
exec dbo.spTERMINOLOGY_InsertOnly N'Users'                                         , N'en-US', null, N'record_type_display'               ,  12, N'User';
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

call dbo.spTERMINOLOGY_Modules_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Modules_en_us')
/
-- #endif IBM_DB2 */
