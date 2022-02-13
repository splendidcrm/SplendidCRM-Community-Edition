

print 'GRIDVIEWS_COLUMNS ListView Admin';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.ListView'
--GO

set nocount on;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Config.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Config.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Config.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Config.ListView', 'Config', 'vwCONFIG_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Config.ListView'        ,  2, 'Config.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID', '~/Administration/Config/view.aspx?id={0}', null, 'Config', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Config.ListView'        ,  3, 'Config.LBL_LIST_CATEGORY'            , 'CATEGORY'        , 'CATEGORY'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Config.ListView'        ,  4, 'Config.LBL_LIST_VALUE'               , 'VALUE'           , 'VALUE'           , '50%';
end -- if;
GO

-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
-- 08/18/2021 Paul.  Line number should not have any decimal places. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'SystemLog.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SystemLog.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SystemLog.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'SystemLog.ListView', 'SystemLog', 'vwSYSTEM_LOG', 'DATE_ENTERED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SystemLog.ListView'     ,  0, '.LBL_LIST_DATE_ENTERED'              , 'DATE_ENTERED'    , 'DATE_ENTERED'    , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  1, 'SystemLog.LBL_LIST_USER_NAME'        , 'USER_NAME'       , 'USER_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  2, 'SystemLog.LBL_LIST_ERROR_TYPE'       , 'ERROR_TYPE'      , 'ERROR_TYPE'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  3, 'SystemLog.LBL_LIST_MESSAGE'          , 'MESSAGE'         , 'MESSAGE'         , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  4, 'SystemLog.LBL_LIST_FILE_NAME'        , 'FILE_NAME'       , 'FILE_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  5, 'SystemLog.LBL_LIST_METHOD'           , 'METHOD'          , 'METHOD'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  6, 'SystemLog.LBL_LIST_LINE_NUMBER'      , 'LINE_NUMBER'     , 'LINE_NUMBER'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  7, 'SystemLog.LBL_LIST_RELATIVE_PATH'    , 'RELATIVE_PATH'   , 'RELATIVE_PATH'   , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemLog.ListView'     ,  8, 'SystemLog.LBL_LIST_PARAMETERS'       , 'PARAMETERS'      , 'PARAMETERS'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'SystemLog.ListView'    , 0, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'SystemLog.ListView', 'LINE_NUMBER', '{0:N}';
end else begin
	-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'SystemLog.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'SystemLog.ListView', 'DATE_ENTERED', 'desc';
	end -- if;
	-- 08/18/2021 Paul.  Line number should not have any decimal places. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SystemLog.ListView' and DATA_FIELD = 'LINE_NUMBER' and DATA_FORMAT is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'AzureSystemLog.ListView', 'LINE_NUMBER', '{0:N}';
	end -- if;
end -- if;
GO

-- 10/30/2020 Paul.  The React Client needs a layout for SystemSyncLog. 
-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'SystemSyncLog.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SystemSyncLog.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SystemSyncLog.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'SystemSyncLog.ListView', 'SystemSyncLog', 'vwSYSTEM_SYNC_LOG', 'DATE_ENTERED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SystemSyncLog.ListView'     ,  0, '.LBL_LIST_DATE_ENTERED'              , 'DATE_ENTERED'    , 'DATE_ENTERED'    , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemSyncLog.ListView'     ,  2, 'SystemLog.LBL_LIST_ERROR_TYPE'       , 'ERROR_TYPE'      , 'ERROR_TYPE'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemSyncLog.ListView'     ,  3, 'SystemLog.LBL_LIST_MESSAGE'          , 'MESSAGE'         , 'MESSAGE'         , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemSyncLog.ListView'     ,  4, 'SystemLog.LBL_LIST_FILE_NAME'        , 'FILE_NAME'       , 'FILE_NAME'       , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemSyncLog.ListView'     ,  5, 'SystemLog.LBL_LIST_METHOD'           , 'METHOD'          , 'METHOD'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SystemSyncLog.ListView'     ,  6, 'SystemLog.LBL_LIST_LINE_NUMBER'      , 'LINE_NUMBER'     , 'LINE_NUMBER'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'SystemSyncLog.ListView'    , 0, null, null, null, null, 0;
end else begin
	-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'SystemSyncLog.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'SystemSyncLog.ListView', 'DATE_ENTERED', 'desc';
	end -- if;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Schedulers.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Schedulers.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Schedulers.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Schedulers.ListView', 'Schedulers', 'vwSCHEDULERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Schedulers.ListView'    ,  2, 'Schedulers.LBL_SCHEDULER'            , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID', '~/Administration/Schedulers/view.aspx?id={0}', null, 'Schedulers', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Schedulers.ListView'    ,  3, 'Schedulers.LBL_INTERVAL'             , 'JOB_INTERVAL'    , 'JOB_INTERVAL'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Schedulers.ListView'    ,  4, 'Schedulers.LBL_DATE_TIME_START'      , 'DATE_TIME_START' , 'DATE_TIME_START' , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Schedulers.ListView'    ,  5, 'Schedulers.LBL_DATE_TIME_END'        , 'DATE_TIME_END'   , 'DATE_TIME_END'   , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Schedulers.ListView'    ,  6, 'Schedulers.LBL_LIST_STATUS'          , 'STATUS'          , 'STATUS'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Schedulers.ListView'    ,  7, 'Schedulers.LBL_LAST_RUN'             , 'LAST_RUN'        , 'LAST_RUN'        , '15%', 'DateTime';
end -- if;
GO

-- 03/27/2019 Paul.  Same as UserLogins.ListView, 
-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserLogins.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserLogins.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS UserLogins.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'UserLogins.ListView', 'Users', 'vwUSERS_LOGINS', 'DATE_MODIFIED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.ListView'    , 0, 'Users.LBL_LIST_NAME'                  , 'FULL_NAME'       , 'FULL_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.ListView'    , 1, 'Users.LBL_LIST_USER_NAME'             , 'USER_NAME'       , 'USER_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'UserLogins.ListView'    , 2, 'Users.LBL_LIST_LOGIN_DATE'            , 'LOGIN_DATE'      , 'LOGIN_DATE'      , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'UserLogins.ListView'    , 3, 'Users.LBL_LIST_LOGOUT_DATE'           , 'LOGOUT_DATE'     , 'LOGOUT_DATE'     , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'UserLogins.ListView'    , 4, 'Users.LBL_LIST_LOGIN_STATUS'          , 'LOGIN_STATUS'    , 'LOGIN_STATUS'    , '10%', 'login_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'UserLogins.ListView'    , 5, 'Users.LBL_LIST_LOGIN_TYPE'            , 'LOGIN_TYPE'      , 'LOGIN_TYPE'      , '10%', 'login_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.ListView'    , 6, 'Users.LBL_LIST_REMOTE_HOST'           , 'REMOTE_HOST'     , 'REMOTE_HOST'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.ListView'    , 7, 'Users.LBL_LIST_TARGET'                , 'TARGET'          , 'TARGET'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.ListView'    , 8, 'Users.LBL_LIST_ASPNET_SESSIONID'      , 'ASPNET_SESSIONID', 'ASPNET_SESSIONID', '10%';
end else begin
	-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'UserLogins.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'UserLogins.ListView', 'DATE_MODIFIED', 'desc';
	end -- if;
end -- if;
GO

-- 02/20/2021 Paul.  HyperLink on DISPLAY_NAME. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Shortcuts.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Shortcuts.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Shortcuts.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Shortcuts.ListView', 'Shortcuts', 'vwCONFIG_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Shortcuts.ListView'     ,  2, 'Shortcuts.LBL_LIST_MODULE_NAME'      , 'MODULE_NAME'     , 'MODULE_NAME'     , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Shortcuts.ListView'     ,  3, 'Shortcuts.LBL_LIST_DISPLAY_NAME'     , 'DISPLAY_NAME'    , 'DISPLAY_NAME'    , '30%', 'listViewTdLinkS1', 'ID', '~/Administration/Shortcuts/edit.aspx?id={0}', null, 'Shortcuts', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Shortcuts.ListView'     ,  4, 'Shortcuts.LBL_LIST_RELATIVE_PATH'    , 'RELATIVE_PATH'   , 'RELATIVE_PATH'   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Shortcuts.ListView'     ,  5, 'Shortcuts.LBL_LIST_SHORTCUT_ORDER'   , 'SHORTCUT_ORDER'  , 'SHORTCUT_ORDER'  , '10%';
end else begin
	-- 02/20/2021 Paul.  HyperLink on DISPLAY_NAME. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Shortcuts.ListView' and DATA_FIELD = 'DISPLAY_NAME' and COLUMN_TYPE = 'BoundColumn' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set COLUMN_TYPE        = 'TemplateColumn'
		     , ITEMSTYLE_CSSCLASS = 'listViewTdLinkS1'
		     , DATA_FORMAT        = 'HyperLink'
		     , URL_FIELD          = 'ID'
		     , URL_FORMAT         = '~/Administration/Shortcuts/edit.aspx?id={0}'
		     , URL_MODULE         = 'Shortcuts'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		 where GRID_NAME          = 'Shortcuts.ListView'
		    and DATA_FIELD        = 'DISPLAY_NAME'
		   and COLUMN_TYPE        = 'BoundColumn'
		   and DELETED            = 0;
		update GRIDVIEWS_COLUMNS
		   set COLUMN_TYPE        = 'BoundColumn'
		     , ITEMSTYLE_CSSCLASS = null
		     , DATA_FORMAT        = null
		     , URL_FIELD          = null
		     , URL_FORMAT         = null
		     , URL_MODULE         = null
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		 where GRID_NAME          = 'Shortcuts.ListView'
		    and DATA_FIELD        = 'MODULE_NAME'
		   and COLUMN_TYPE        = 'TemplateColumn'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicButtons.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicButtons.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS DynamicButtons.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'DynamicButtons.ListView', 'DynamicButtons', 'vwDYNAMIC_BUTTONS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'DynamicButtons.ListView',  2, 'DynamicButtons.LBL_LIST_CONTROL_TEXT', 'CONTROL_TEXT'    , 'CONTROL_TEXT'    , '19%', 'listViewTdLinkS1', 'ID', '~/Administration/DynamicButtons/view.aspx?id={0}', null, 'DynamicButtons', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicButtons.ListView',  3, 'DynamicButtons.LBL_LIST_MODULE_NAME' , 'MODULE_NAME'     , 'MODULE_NAME'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicButtons.ListView',  4, 'DynamicButtons.LBL_LIST_CONTROL_TYPE', 'CONTROL_TYPE'    , 'CONTROL_TYPE'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicButtons.ListView',  5, 'DynamicButtons.LBL_LIST_COMMAND_NAME', 'COMMAND_NAME'    , 'COMMAND_NAME'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicButtons.ListView',  6, 'DynamicButtons.LBL_LIST_TEXT_FIELD'  , 'TEXT_FIELD'      , 'TEXT_FIELD'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicButtons.ListView',  7, 'DynamicButtons.LBL_LIST_URL_FORMAT'  , 'URL_FORMAT'      , 'URL_FORMAT'      , '30%';
end -- if;
GO

-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Languages.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Languages.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Languages.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Languages.ListView', 'Languages', 'vwLANGUAGES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Languages.ListView'     ,  2, 'Terminology.LBL_LIST_LANG'           , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID', '~/Administration/Languages/view.aspx?id={0}', null, 'Languages', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Languages.ListView'     ,  3, 'Terminology.LBL_LIST_NAME_NAME'      , 'DISPLAY_NAME'    , 'DISPLAY_NAME'    , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Languages.ListView'     ,  4, 'Terminology.LBL_LIST_DISPLAY_NAME'   , 'NATIVE_NAME'     , 'NATIVE_NAME'     , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Languages.ListView'     ,  5, 'Administration.LNK_ENABLED'          , 'ACTIVE'          , 'ACTIVE'          , '5%', 'yesno_list';
end else begin
	-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Languages.ListView' and LIST_NAME = 'yesno_dom' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME          = 'yesno_list'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		 where GRID_NAME          = 'Languages.ListView'
		   and LIST_NAME          = 'yesno_dom'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 01/29/2021 Paul.  Add EditCustomFields to React client. 
-- 02/22/2021 Paul.  Make use of new procedure spGRIDVIEWS_COLUMNS_UpdateFormat.
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'EditCustomFields.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EditCustomFields.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EditCustomFields.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EditCustomFields.ListView', 'EditCustomFields', 'vwFIELDS_META_DATA_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EditCustomFields.ListView',  2, 'EditCustomFields.COLUMN_TITLE_NAME'           , 'NAME'            , 'NAME'           , '22%', 'listViewTdLinkS1', 'ID', '~/Administration/EditCustomFields/edit.aspx?id={0}', null, 'EditCustomFields', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  3, 'EditCustomFields.COLUMN_TITLE_LABEL'          , 'LABEL'           , 'LABEL'          , '22%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  4, 'EditCustomFields.COLUMN_TITLE_DATA_TYPE'      , 'DATA_TYPE'       , 'DATA_TYPE'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  5, 'EditCustomFields.COLUMN_TITLE_MAX_SIZE'       , 'MAX_SIZE'        , 'MAX_SIZE'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  6, 'EditCustomFields.COLUMN_TITLE_REQUIRED_OPTION', 'REQUIRED_OPTION' , 'REQUIRED_OPTION', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  7, 'EditCustomFields.COLUMN_TITLE_DEFAULT_VALUE'  , 'DEFAULT_VALUE'   , 'DEFAULT_VALUE'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EditCustomFields.ListView',  8, 'EditCustomFields.COLUMN_TITLE_DROPDOWN'       , 'EXT1'            , 'EXT1'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'EditCustomFields.ListView',  'MAX_SIZE', '{0:N0}';
end -- if;
GO

-- 02/22/2021 Paul.  React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ForumTopics.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ForumTopics.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ForumTopics.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ForumTopics.ListView', 'ForumTopics', 'vwFORUM_TOPICS', 'LIST_ORDER', 'asc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ForumTopics.ListView'   ,  2, 'ForumTopics.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '65%', 'listViewTdLinkS1', 'ID', '~/Administration/ForumTopics/view.aspx?id={0}', null, 'ForumTopics', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ForumTopics.ListView'   ,  3, 'ForumTopics.LBL_LIST_LIST_ORDER'          , 'LIST_ORDER'      , 'LIST_ORDER'      , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'ForumTopics.ListView',  'LIST_ORDER', '{0:N0}';
end -- if;
GO

-- 03/30/2021 Paul.  React client. 
-- delete from GRIDVIEWS where NAME = 'EmailMan.ListView';
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMan.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMan.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailMan.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailMan.ListView', 'EmailMan', 'vwEMAILMAN_List', 'SEND_DATE_TIME', 'asc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  1, 'EmailMan.LBL_LIST_CAMPAIGN'                , 'CAMPAIGN_NAME'            , 'CAMPAIGN_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  2, 'EmailMan.LBL_LIST_RECIPIENT_NAME'          , 'RECIPIENT_NAME'           , 'RECIPIENT_NAME'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  3, 'EmailMan.LBL_LIST_RECIPIENT_EMAIL'         , 'RECIPIENT_EMAIL'          , 'RECIPIENT_EMAIL'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  4, 'EmailMan.LBL_LIST_MESSAGE_NAME'            , 'EMAIL_MARKETING_NAME'     , 'EMAIL_MARKETING_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  5, 'EmailMan.LBL_LIST_SEND_DATE_TIME'          , 'SEND_DATE_TIME'           , 'SEND_DATE_TIME'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  6, 'EmailMan.LBL_LIST_SEND_ATTEMPTS'           , 'SEND_ATTEMPTS'            , 'SEND_ATTEMPTS'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMan.ListView'   ,  7, 'EmailMan.LBL_LIST_IN_QUEUE'                , 'IN_QUEUE'                 , 'IN_QUEUE'            , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'EmailMan.ListView',  'SEND_ATTEMPTS', '{0:N0}';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'EmailMan.ListView', 4, null, null, null, null, 0;
end -- if;
GO

-- 09/11/2021 Paul.  React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.LanguagePacks';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.LanguagePacks' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Terminology.LanguagePacks';
	exec dbo.spGRIDVIEWS_InsertOnly           'Terminology.LanguagePacks', 'Terminology', 'vwTERMINOLOGY', 'Name', 'asc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Terminology.LanguagePacks'        ,  0, 'Terminology.LBL_LIST_IMPORT_NAME'          , 'Name'                     , 'Name'                , '25%', 'listViewTdLinkS1', 'Name', '~/Administration/Terminology/import.aspx?Name={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.LanguagePacks'        ,  1, 'Terminology.LBL_LIST_IMPORT_DATE'          , 'Date'                     , 'Date'                , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.LanguagePacks'        ,  2, 'Terminology.LBL_LIST_IMPORT_DESCRIPTION'   , 'Description'              , 'Description'         , '60%';
end -- if;
GO

-- 09/11/2021 Paul.  React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.SplendidLanguagePacks';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.SplendidLanguagePacks' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Terminology.SplendidLanguagePacks';
	exec dbo.spGRIDVIEWS_InsertOnly           'Terminology.SplendidLanguagePacks', 'Terminology', 'vwTERMINOLOGY', 'Name', 'asc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Terminology.SplendidLanguagePacks',  0, 'Terminology.LBL_LIST_IMPORT_NAME'         , 'Name'                     , 'Name'                , '25%', 'listViewTdLinkS1', 'Name', '~/Administration/Terminology/import.aspx?Name={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.SplendidLanguagePacks',  1, 'Terminology.LBL_LIST_IMPORT_DATE'         , 'Date'                     , 'Date'                , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.SplendidLanguagePacks',  2, 'Terminology.LBL_LIST_IMPORT_DESCRIPTION'  , 'Description'              , 'Description'         , '60%';
end -- if;
GO

-- 09/14/2021 Paul.  Add Undelete support to React Client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Undelete.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Undelete.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Undelete.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Undelete.ListView', 'Undelete', 'vwCONFIG', 'AUDIT_DATE', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Undelete.ListView'   ,  1, 'Undelete.LBL_LIST_NAME'                , 'NAME'            , 'NAME'       , '70%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Undelete.ListView'   ,  2, 'Undelete.LBL_LIST_AUDIT_TOKEN'         , 'AUDIT_TOKEN'     , 'AUDIT_TOKEN', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Undelete.ListView'   ,  3, 'Undelete.LBL_LIST_MODIFIED_BY'         , 'MODIFIED_BY'     , 'MODIFIED_BY', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Undelete.ListView'   ,  4, 'Undelete.LBL_LIST_AUDIT_DATE'          , 'AUDIT_DATE'      , 'AUDIT_DATE' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Undelete.ListView', 2, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Undelete.ListView', 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Undelete.ListView', 4, null, null, null, null, 0;
end -- if;
GO


set nocount off;
GO


/* -- #if Oracle
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			StoO_selcnt := 0;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spGRIDVIEWS_COLUMNS_ListViewsAdmin()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ListViewsAdmin')
/

-- #endif IBM_DB2 */

