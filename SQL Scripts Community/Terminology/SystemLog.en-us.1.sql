

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY SystemLog en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASPNET_SESSIONID'                          , N'en-US', N'SystemLog', null, null, N'ASP.NET Session ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ERROR_TYPE'                                , N'en-US', N'SystemLog', null, null, N'Error Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FILE_NAME'                                 , N'en-US', N'SystemLog', null, null, N'File Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINE_NUMBER'                               , N'en-US', N'SystemLog', null, null, N'Line Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASPNET_SESSIONID'                     , N'en-US', N'SystemLog', null, null, N'ASP.NET Session ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ERROR_TYPE'                           , N'en-US', N'SystemLog', null, null, N'Error Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FILE_NAME'                            , N'en-US', N'SystemLog', null, null, N'File Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LINE_NUMBER'                          , N'en-US', N'SystemLog', null, null, N'Line Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MACHINE'                              , N'en-US', N'SystemLog', null, null, N'Machine';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSAGE'                              , N'en-US', N'SystemLog', null, null, N'Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_METHOD'                               , N'en-US', N'SystemLog', null, null, N'Method';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARAMETERS'                           , N'en-US', N'SystemLog', null, null, N'Parameters';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RELATIVE_PATH'                        , N'en-US', N'SystemLog', null, null, N'Relative Path';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REMOTE_HOST'                          , N'en-US', N'SystemLog', null, null, N'Remote Host';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SERVER_HOST'                          , N'en-US', N'SystemLog', null, null, N'Server Host';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TARGET'                               , N'en-US', N'SystemLog', null, null, N'Target';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_ID'                              , N'en-US', N'SystemLog', null, null, N'User ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_NAME'                            , N'en-US', N'SystemLog', null, null, N'User Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MACHINE'                                   , N'en-US', N'SystemLog', null, null, N'Machine:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSAGE'                                   , N'en-US', N'SystemLog', null, null, N'Message:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_METHOD'                                    , N'en-US', N'SystemLog', null, null, N'Method:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARAMETERS'                                , N'en-US', N'SystemLog', null, null, N'Parameters:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELATIVE_PATH'                             , N'en-US', N'SystemLog', null, null, N'Relative Path:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOTE_HOST'                               , N'en-US', N'SystemLog', null, null, N'Remote Host:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SERVER_HOST'                               , N'en-US', N'SystemLog', null, null, N'Server Host:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TARGET'                                    , N'en-US', N'SystemLog', null, null, N'Target:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_ID'                                   , N'en-US', N'SystemLog', null, null, N'User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_NAME'                                 , N'en-US', N'SystemLog', null, null, N'User Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'SystemLog', null, null, N'SyL';
-- 08/11/2020 Paul.  The React Client needs a LBL_LIST_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'SystemLog', null, null, N'System Log List';
-- 12/09/2020 Paul.  Every module should have a name. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'SystemLog', null, null, N'Name:';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'SystemLog'                                     , N'en-US', null, N'moduleList'                        ,  98, N'SystemLog';

exec dbo.spTERMINOLOGY_InsertOnly N'Warning'                                       , N'en-US', null, N'system_log_type_dom'               ,   1, N'Warning';
exec dbo.spTERMINOLOGY_InsertOnly N'Error'                                         , N'en-US', null, N'system_log_type_dom'               ,   2, N'Error';
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

call dbo.spTERMINOLOGY_SystemLog_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_SystemLog_en_us')
/
-- #endif IBM_DB2 */
