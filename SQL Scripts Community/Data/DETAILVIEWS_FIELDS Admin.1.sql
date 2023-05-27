

print 'DETAILVIEWS_FIELDS Admin';
set nocount on;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Config.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Config.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Config.DetailView', 'Config', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Config.DetailView'        ,  0, 'Config.LBL_NAME'                      , 'NAME'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Config.DetailView'        ,  1, 'Config.LBL_CATEGORY'                  , 'CATEGORY'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Config.DetailView'        ,  2, 'Config.LBL_VALUE'                     , 'VALUE'              , '{0}'        , 3;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Schedulers.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Schedulers.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Schedulers.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Schedulers.DetailView', 'Schedulers', 'vwSCHEDULERS', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  0, 'Schedulers.LBL_NAME'                  , 'NAME'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Schedulers.DetailView'    ,  1, 'Schedulers.LBL_STATUS'                , 'STATUS'             , '{0}'        , 'scheduler_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  2, 'Schedulers.LBL_JOB'                   , 'JOB'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Schedulers.DetailView'    ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  4, 'Schedulers.LBL_DATE_TIME_START'       , 'DATE_TIME_START'    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  5, 'Schedulers.LBL_TIME_FROM'             , 'TIME_FROM'          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  6, 'Schedulers.LBL_DATE_TIME_END'         , 'DATE_TIME_END'      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  7, 'Schedulers.LBL_TIME_TO'               , 'TIME_TO'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  8, 'Schedulers.LBL_LAST_RUN'              , 'LAST_RUN'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    ,  9, 'Schedulers.LBL_INTERVAL'              , 'JOB_INTERVAL'       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    , 10, 'Schedulers.LBL_CATCH_UP'              , 'CATCH_UP'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Schedulers.DetailView'    , 11, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    , 12, '.LBL_DATE_ENTERED'                    , 'DATE_ENTERED'       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Schedulers.DetailView'    , 13, '.LBL_DATE_MODIFIED'                   , 'DATE_MODIFIED'      , '{0}'        , null;
end else begin
	-- 03/29/2021 Paul.  INTERVAL is not a valid field. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Schedulers.DetailView' and DATA_FIELD = 'INTERVAL' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD        = 'JOB_INTERVAL'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()     
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Schedulers.DetailView'
		   and DATA_FIELD        = 'INTERVAL'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Terminology.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Terminology.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Terminology.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Terminology.DetailView', 'Terminology', 'vwTERMINOLOGY_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Terminology.DetailView'   ,  0, 'Terminology.LBL_NAME'                 , 'NAME'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Terminology.DetailView'   ,  1, 'Terminology.LBL_LANG'                 , 'LANG'               , '{0}'        , 'Languages', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Terminology.DetailView'   ,  2, 'Terminology.LBL_MODULE_NAME'          , 'MODULE_NAME'        , '{0}'        , 'Modules'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Terminology.DetailView'   ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Terminology.DetailView'   ,  4, 'Terminology.LBL_LIST_NAME'            , 'LIST_NAME'          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Terminology.DetailView'   ,  5, 'Terminology.LBL_LIST_ORDER'           , 'LIST_ORDER'         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Terminology.DetailView'   ,  6, 'Terminology.LBL_DISPLAY_NAME'         , 'DISPLAY_NAME'       , '{0}'        , 3;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Shortcuts.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Shortcuts.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Shortcuts.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Shortcuts.DetailView', 'Shortcuts', 'vwSHORTCUTS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Shortcuts.DetailView'     ,  0, 'Shortcuts.LBL_MODULE_NAME'            , 'MODULE_NAME'        , '{0}'        , 'Modules'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Shortcuts.DetailView'     ,  1, 'Shortcuts.LBL_DISPLAY_NAME'           , 'DISPLAY_NAME'       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Shortcuts.DetailView'     ,  2, 'Shortcuts.LBL_RELATIVE_PATH'          , 'RELATIVE_PATH'      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Shortcuts.DetailView'     ,  3, 'Shortcuts.LBL_IMAGE_NAME'             , 'IMAGE_NAME'         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Shortcuts.DetailView'     ,  4, 'Shortcuts.LBL_SHORTCUT_ORDER'         , 'SHORTCUT_ORDER'     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Shortcuts.DetailView'     ,  5, 'Shortcuts.LBL_SHORTCUT_ENABLED'       , 'SHORTCUT_ENABLED'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Shortcuts.DetailView'     ,  6, 'Shortcuts.LBL_SHORTCUT_MODULE'        , 'SHORTCUT_MODULE'    , '{0}'        , 'Modules'              , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Shortcuts.DetailView'     ,  7, 'Shortcuts.LBL_SHORTCUT_ACLTYPE'       , 'SHORTCUT_ACLTYPE'   , '{0}'        , 'shortcuts_acltype_dom', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'DynamicButtons.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'DynamicButtons.DetailView' and DELETED = 0) begin -- then 
	print 'DETAILVIEWS_FIELDS DynamicButtons.DetailView'; 
	exec dbo.spDETAILVIEWS_InsertOnly 'DynamicButtons.DetailView', 'DynamicButtons', 'vwDYNAMIC_BUTTONS_Edit', '15%', '35%', null; 
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView',  0, 'DynamicButtons.LBL_VIEW_NAME'         , 'VIEW_NAME'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView',  1, 'DynamicButtons.LBL_CONTROL_INDEX'     , 'CONTROL_INDEX'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'DynamicButtons.DetailView',  2, 'DynamicButtons.LBL_CONTROL_TYPE'      , 'CONTROL_TYPE'       , '{0}', 'dynamic_button_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'DynamicButtons.DetailView',  3, 'DynamicButtons.LBL_MODULE_NAME'       , 'MODULE_NAME'        , '{0}', 'Modules'                , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'DynamicButtons.DetailView',  4, 'DynamicButtons.LBL_MODULE_ACCESS_TYPE', 'MODULE_ACCESS_TYPE' , '{0}', 'module_access_type_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'DynamicButtons.DetailView',  5, 'DynamicButtons.LBL_TARGET_NAME'       , 'TARGET_NAME'        , '{0}', 'Modules'                , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'DynamicButtons.DetailView',  6, 'DynamicButtons.LBL_TARGET_ACCESS_TYPE', 'TARGET_ACCESS_TYPE' , '{0}', 'module_access_type_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckbox   'DynamicButtons.DetailView',  7, 'DynamicButtons.LBL_MOBILE_ONLY'       , 'MOBILE_ONLY'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckbox   'DynamicButtons.DetailView',  8, 'DynamicButtons.LBL_ADMIN_ONLY'        , 'ADMIN_ONLY'         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckbox   'DynamicButtons.DetailView',  9, 'DynamicButtons.LBL_EXCLUDE_MOBILE'    , 'EXCLUDE_MOBILE'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 10, 'DynamicButtons.LBL_CONTROL_TEXT'      , 'CONTROL_TEXT'       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 11, 'DynamicButtons.LBL_CONTROL_TOOLTIP'   , 'CONTROL_TOOLTIP'    , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 12, 'DynamicButtons.LBL_CONTROL_ACCESSKEY' , 'CONTROL_ACCESSKEY'  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 13, 'DynamicButtons.LBL_CONTROL_CSSCLASS'  , 'CONTROL_CSSCLASS'   , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 14, 'DynamicButtons.LBL_TEXT_FIELD'        , 'TEXT_FIELD'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 15, 'DynamicButtons.LBL_ARGUMENT_FIELD'    , 'ARGUMENT_FIELD'     , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 16, 'DynamicButtons.LBL_COMMAND_NAME'      , 'COMMAND_NAME'       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 17, 'DynamicButtons.LBL_URL_FORMAT'        , 'URL_FORMAT'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 18, 'DynamicButtons.LBL_URL_TARGET'        , 'URL_TARGET'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 19, 'DynamicButtons.LBL_ONCLICK_SCRIPT'    , 'ONCLICK_SCRIPT'     , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckbox   'DynamicButtons.DetailView', 20, 'DynamicButtons.LBL_HIDDEN'            , 'HIDDEN'             , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'DynamicButtons.DetailView', 21, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 22, 'DynamicButtons.LBL_BUSINESS_RULE'     , 'BUSINESS_RULE'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'DynamicButtons.DetailView', 23, 'DynamicButtons.LBL_BUSINESS_SCRIPT'   , 'BUSINESS_SCRIPT'    , '{0}', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ForumTopics.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ForumTopics.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ForumTopics.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'ForumTopics.DetailView', 'ForumTopics', 'vwFORUM_TOPICS', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ForumTopics.DetailView'   ,  0, 'ForumTopics.LBL_NAME'                 , 'NAME'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ForumTopics.DetailView'   ,  1, 'ForumTopics.LBL_ORDER'                , 'LIST_ORDER'         , '{0}'        , null;
end -- if;
GO

-- 02/21/2021 Paul.  Languages for React client. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Languages.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Languages.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Languages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Languages.DetailView', 'Languages', 'vwLANGUAGES', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Languages.DetailView'     ,  0, 'Languages.LBL_NAME'                   , 'NAME'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Languages.DetailView'     ,  1, 'Languages.LBL_LCID'                   , 'LCID'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckbox   'Languages.DetailView'     ,  2, 'Languages.LBL_ACTIVE'                 , 'ACTIVE'             , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Languages.DetailView'     ,  3, 'Languages.LBL_NATIVE_NAME'            , 'NATIVE_NAME'        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Languages.DetailView'     ,  4, 'Languages.LBL_DISPLAY_NAME'           , 'DISPLAY_NAME'       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Languages.DetailView'     ,  5, null;
end -- if;
GO


-- 02/24/2021 Paul.  Add support for React client. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Asterisk.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Asterisk.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Asterisk.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Asterisk.ConfigView', 'Asterisk', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  0, 'Asterisk.LBL_HOST_SERVER'               , 'Asterisk.Host'                    , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  1, 'Asterisk.LBL_HOST_PORT'                 , 'Asterisk.Port'                    , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  2, 'Asterisk.LBL_USER_NAME'                 , 'Asterisk.UserName'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  3, 'Asterisk.LBL_PASSWORD'                  , 'Asterisk.Password'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  4, 'Asterisk.LBL_FROM_TRUNK'                , 'Asterisk.Trunk'                   , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  5, 'Asterisk.LBL_FROM_CONTEXT'              , 'Asterisk.Context'                 , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  6, 'Asterisk.LBL_LOG_MISSED_INCOMING_CALLS' , 'Asterisk.LogIncomingMissedCalls'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  7, 'Asterisk.LBL_LOG_MISSED_OUTGOING_CALLS' , 'Asterisk.LogOutgoingMissedCalls'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  8, 'Asterisk.LBL_LOG_CALL_DETAILS'          , 'Asterisk.LogCallDetails'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  9, 'Asterisk.LBL_ORIGINATE_EXTENSION_FIRST' , 'Asterisk.OriginateExtensionFirst' , null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayTrace.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayTrace.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS PayTrace.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'PayTrace.ConfigView', 'PayTrace', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'PayTrace.ConfigView'        ,  0, 'PayTrace.LBL_ENABLED'                   , 'PayTrace.Enabled'                 , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'PayTrace.ConfigView'        ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  2, 'PayTrace.LBL_USER_NAME'                 , 'PayTrace.UserName'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  3, 'PayTrace.LBL_PASSWORD'                  , 'PayTrace.Password'                , '{0}', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayPal.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayPal.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS PayPal.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'PayPal.ConfigView', 'PayPal', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  0, 'PayPal.LBL_USER_NAME'                   , 'PayPal.APIUsername'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  1, 'PayPal.LBL_PASSWORD'                    , 'PayPal.APIPassword'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  2, 'PayPal.LBL_PRIVATE_KEY'                 , 'PayPal.X509PrivateKey'            , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  3, 'PayPal.LBL_CERTIFICATE'                 , 'PayPal.X509Certificate'           , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  4, 'PayPal.LBL_REST_CLIENT_ID'              , 'PayPal.ClientID'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  5, 'PayPal.LBL_REST_CLIENT_SECRET'          , 'PayPal.ClientSecret'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'PayPal.ConfigView'          ,  6, 'PayPal.LBL_SANDBOX'                     , 'PayPal.Sandbox'                   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'PayPal.ConfigView'          ,  7, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'AuthorizeNet.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'AuthorizeNet.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS AuthorizeNet.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'AuthorizeNet.ConfigView', 'AuthorizeNet', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'AuthorizeNet.ConfigView'    ,  0, 'AuthorizeNet.LBL_ENABLED'               , 'AuthorizeNet.Enabled'             , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'AuthorizeNet.ConfigView'    ,  1, 'AuthorizeNet.LBL_TEST_MODE'             , 'AuthorizeNet.TestMode'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'AuthorizeNet.ConfigView'    ,  2, 'AuthorizeNet.LBL_USER_NAME'             , 'AuthorizeNet.UserName'            , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'AuthorizeNet.ConfigView'    ,  3, 'AuthorizeNet.LBL_TRANSACTION_KEY'       , 'AuthorizeNet.TransactionKey'      , '{0}', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Facebook.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Facebook.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Facebook.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Facebook.ConfigView', 'Facebook', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Facebook.ConfigView'        ,  0, 'Facebook.LBL_FACEBOOK_APPID'            , 'facebook.AppID'                   , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Facebook.ConfigView'        ,  1, 'Facebook.LBL_FACEBOOK_ENABLE_LOGIN'     , 'facebook.EnableLogin'             , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Facebook.ConfigView'        ,  2, 'Facebook.LBL_FACEBOOK_SECRET_KEY'       , 'facebook.AppSecret'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Facebook.ConfigView'        ,  3, 'Facebook.LBL_FACEBOOK_PORTAL_LOGIN'     , 'facebook.Portal.EnableLogin'      , null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Google.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Google.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Google.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Google.ConfigView', 'Google', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  0, 'Google.LBL_GOOGLE_APPS_ENABLED'         , 'GoogleApps.Enabled'               , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  1, 'Google.LBL_VERBOSE_STATUS'              , 'GoogleApps.VerboseStatus'         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  2, 'Google.LBL_OAUTH_API_KEY'               , 'GoogleApps.ApiKey'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  3, 'Google.LBL_OAUTH_CLIENT_ID'             , 'GoogleApps.ClientID'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  4, 'Google.LBL_PUSH_NOTIFICATIONS'          , 'GoogleApps.PushNotifications'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  5, 'Google.LBL_OAUTH_CLIENT_SECRET'         , 'GoogleApps.ClientSecret'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  6, 'Google.LBL_PUSH_NOTIFICATION_URL'       , 'GoogleApps.PushNotificationURL'   , null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'LinkedIn.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'LinkedIn.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS LinkedIn.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'LinkedIn.ConfigView', 'LinkedIn', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'LinkedIn.ConfigView'        ,  0, 'LinkedIn.LBL_LINKEDIN_API_KEY'          , 'LinkedIn.APIKey'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'LinkedIn.ConfigView'        ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'LinkedIn.ConfigView'        ,  2, 'LinkedIn.LBL_LINKEDIN_SECRET_KEY'       , 'LinkedIn.SecretKey'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'LinkedIn.ConfigView'        ,  3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Twitter.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Twitter.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Twitter.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Twitter.ConfigView', 'Twitter', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  0, 'Twitter.LBL_TWITTER_CONSUMER_KEY'       , 'Twitter.ConsumerKey'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  1, 'Twitter.LBL_TWITTER_SECRET_KEY'         , 'Twitter.ConsumerSecret'           , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  2, 'Twitter.LBL_ACCESS_TOKEN'               , 'Twitter.AccessToken'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  3, 'Twitter.LBL_ACCESS_TOKEN_SECRET'        , 'Twitter.AccessTokenSecret'        , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Twitter.ConfigView'         ,  4, 'Twitter.LBL_ENABLE_TRACKING'            , 'Twitter.EnableTracking'           , null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Salesforce.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Salesforce.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Salesforce.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Salesforce.ConfigView', 'Salesforce', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Salesforce.ConfigView'      ,  0, 'Salesforce.LBL_SALESFORCE_CONSUMER_KEY' , 'Salesforce.ConsumerKey'           , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Salesforce.ConfigView'      ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Salesforce.ConfigView'      ,  2, 'Salesforce.LBL_SALESFORCE_SECRET_KEY'   , 'Salesforce.ConsumerSecret'        , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Salesforce.ConfigView'      ,  3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Twilio.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Twilio.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Twilio.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Twilio.ConfigView', 'Twilio', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  0, 'Twilio.LBL_ACCOUNT_SID'                 , 'Twilio.AccountSID'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  1, 'Twilio.LBL_AUTH_TOKEN'                  , 'Twilio.AuthToken'                 , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  2, 'Twilio.LBL_FROM_PHONE'                  , 'Twilio.FromPhone'                 , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Twilio.ConfigView'          ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Twilio.ConfigView'          ,  4, 'Twilio.LBL_LOG_INBOUND_MESSAGES'        , 'Twilio.LogInboundMessages'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  5, 'Twilio.LBL_MESSAGE_REQUEST_URL'         , 'Twilio.MessageRequestURL'         , '{0}', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'HubSpot.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'HubSpot.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS HubSpot.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'HubSpot.ConfigView', 'HubSpot', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'HubSpot.ConfigView'         ,  0, 'HubSpot.LBL_HUBSPOT_ENABLED'            , 'HubSpot.Enabled'                  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'HubSpot.ConfigView'         ,  1, 'HubSpot.LBL_VERBOSE_STATUS'             , 'HubSpot.VerboseStatus'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  2, 'HubSpot.LBL_OAUTH_PORTAL_ID'            , 'HubSpot.PortalID'                 , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  3, 'HubSpot.LBL_OAUTH_ACCESS_TOKEN'         , 'HubSpot.OAuthAccessToken'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  4, 'HubSpot.LBL_OAUTH_CLIENT_ID'            , 'HubSpot.ClientID'                 , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  5, 'HubSpot.LBL_OAUTH_REFRESH_TOKEN'        , 'HubSpot.OAuthRefreshToken'        , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  6, 'HubSpot.LBL_OAUTH_CLIENT_SECRET'        , 'HubSpot.ClientSecret'             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  7, 'HubSpot.LBL_OAUTH_EXPIRES_AT'           , 'HubSpot.OAuthExpiresAt'           , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         ,  8, 'HubSpot.LBL_DIRECTION'                  , 'HubSpot.Direction'                , '{0}', 'hubspot_sync_direction'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         ,  9, 'HubSpot.LBL_CONFLICT_RESOLUTION'        , 'HubSpot.ConflictResolution'       , '{0}', 'sync_conflict_resolution' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         , 10, 'HubSpot.LBL_SYNC_MODULES'               , 'HubSpot.SyncModules'              , '{0}', 'hubspot_sync_module'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'HubSpot.ConfigView'         , 11, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'iContact.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'iContact.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS iContact.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'iContact.ConfigView', 'iContact', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'iContact.ConfigView'        ,  0, 'iContact.LBL_ICONTACT_ENABLED'          , 'iContact.Enabled'                 , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'iContact.ConfigView'        ,  1, 'iContact.LBL_VERBOSE_STATUS'            , 'iContact.VerboseStatus'           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  2, 'iContact.LBL_API_APP_ID'                , 'iContact.ApiAppId'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'iContact.ConfigView'        ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  4, 'iContact.LBL_API_USERNAME'              , 'iContact.ApiUsername'             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  5, 'iContact.LBL_API_PASSWORD'              , 'iContact.ApiPassword'             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  6, 'iContact.LBL_ICONTACT_ACCOUNT_ID'       , 'iContact.iContactAccountId'       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  7, 'iContact.LBL_ICONTACT_CLIENT_FOLDER_ID' , 'iContact.iContactClientFolderId'  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        ,  8, 'iContact.LBL_DIRECTION'                 , 'iContact.Direction'               , '{0}', 'icontact_sync_direction'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        ,  9, 'iContact.LBL_CONFLICT_RESOLUTION'       , 'iContact.ConflictResolution'      , '{0}', 'sync_conflict_resolution' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        , 10, 'iContact.LBL_SYNC_MODULES'              , 'iContact.SyncModules'             , '{0}', 'icontact_sync_module'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'iContact.ConfigView'        , 11, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ConstantContact.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ConstantContact.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ConstantContact.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'ConstantContact.ConfigView', 'ConstantContact', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'ConstantContact.ConfigView' ,  0, 'ConstantContact.LBL_CONSTANTCONTACT_ENABLED', 'ConstantContact.Enabled'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'ConstantContact.ConfigView' ,  1, 'ConstantContact.LBL_VERBOSE_STATUS'     , 'ConstantContact.VerboseStatus'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  2, 'ConstantContact.LBL_OAUTH_CLIENT_ID'    , 'ConstantContact.ClientID'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  3, 'ConstantContact.LBL_OAUTH_ACCESS_TOKEN' , 'ConstantContact.OAuthAccessToken'  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  4, 'ConstantContact.LBL_OAUTH_CLIENT_SECRET', 'ConstantContact.ClientSecret'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  5, 'ConstantContact.LBL_OAUTH_REFRESH_TOKEN', 'ConstantContact.OAuthRefreshToken' , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  6, 'ConstantContact.LBL_DIRECTION'          , 'ConstantContact.Direction'         , '{0}', 'constantcontact_sync_direction', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  7, 'ConstantContact.LBL_CONFLICT_RESOLUTION', 'ConstantContact.ConflictResolution', '{0}', 'sync_conflict_resolution'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  8, 'ConstantContact.LBL_SYNC_MODULES'       , 'ConstantContact.SyncModules'       , '{0}', 'constantcontact_sync_module'   , null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Marketo.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Marketo.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Marketo.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Marketo.ConfigView', 'Marketo', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Marketo.ConfigView'         ,  0, 'Marketo.LBL_MARKETO_ENABLED'            , 'Marketo.Enabled'                 , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Marketo.ConfigView'         ,  1, 'Marketo.LBL_VERBOSE_STATUS'             , 'Marketo.VerboseStatus'           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  2, 'Marketo.LBL_OAUTH_ENDPOINT_URL'         , 'Marketo.EndpointURL'             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  3, 'Marketo.LBL_OAUTH_IDENTITY_URL'         , 'Marketo.IdentityURL'             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  4, 'Marketo.LBL_OAUTH_CLIENT_ID'            , 'Marketo.ClientID'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  5, 'Marketo.LBL_OAUTH_ACCESS_TOKEN'         , 'Marketo.OAuthAccessToken'        , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  6, 'Marketo.LBL_OAUTH_CLIENT_SECRET'        , 'Marketo.ClientSecret'            , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  7, 'Marketo.LBL_OAUTH_SCOPE'                , 'Marketo.OAuthScope'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Marketo.ConfigView'         ,  8, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  9, 'Marketo.LBL_OAUTH_EXPIRES_AT'           , 'Marketo.OAuthExpiresAt'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 10, 'Marketo.LBL_DIRECTION'                  , 'Marketo.Direction'               , '{0}', 'marketo_sync_direction'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 11, 'Marketo.LBL_CONFLICT_RESOLUTION'        , 'Marketo.ConflictResolution'      , '{0}', 'sync_conflict_resolution' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 12, 'Marketo.LBL_SYNC_MODULES'               , 'Marketo.SyncModules'             , '{0}', 'marketo_sync_module'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Marketo.ConfigView'         , 13, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CurrencyLayer.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CurrencyLayer.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS CurrencyLayer.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'CurrencyLayer.ConfigView', 'CurrencyLayer', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'CurrencyLayer.ConfigView'   ,  0, 'CurrencyLayer.LBL_ACCESS_KEY'           , 'CurrencyLayer.AccessKey'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'CurrencyLayer.ConfigView'   ,  1, 'CurrencyLayer.LBL_LOG_CONVERSIONS'      , 'CurrencyLayer.LogConversions'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'CurrencyLayer.ConfigView'   ,  2, 'CurrencyLayer.LBL_RATE_LIFETIME'        , 'CurrencyLayer.RateLifetime'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'CurrencyLayer.ConfigView'   ,  3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'GetResponse.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'GetResponse.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS GetResponse.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'GetResponse.ConfigView', 'GetResponse', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'GetResponse.ConfigView'     ,  0, 'GetResponse.LBL_GETRESPONSE_ENABLED'    , 'GetResponse.Enabled'             , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'GetResponse.ConfigView'     ,  1, 'GetResponse.LBL_VERBOSE_STATUS'         , 'GetResponse.VerboseStatus'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'GetResponse.ConfigView'     ,  2, 'GetResponse.LBL_SECRET_API_KEY'         , 'GetResponse.SecretApiKey'        , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'GetResponse.ConfigView'     ,  3, 'GetResponse.LBL_DEFAULT_CAMPAIGN_NAME'  , 'GetResponse.DefaultCampaignName' , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  4, 'GetResponse.LBL_DIRECTION'              , 'GetResponse.Direction'           , '{0}', 'getresponse_sync_direction', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  5, 'GetResponse.LBL_CONFLICT_RESOLUTION'    , 'GetResponse.ConflictResolution'  , '{0}', 'sync_conflict_resolution'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  6, 'GetResponse.LBL_SYNC_MODULES'           , 'GetResponse.SyncModules'         , '{0}', 'getresponse_sync_module'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'GetResponse.ConfigView'     ,  7, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Pardot.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Pardot.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Pardot.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Pardot.ConfigView', 'Pardot', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Pardot.ConfigView'          ,  0, 'Pardot.LBL_PARDOT_ENABLED'              , 'Pardot.Enabled'                  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Pardot.ConfigView'          ,  1, 'Pardot.LBL_VERBOSE_STATUS'              , 'Pardot.VerboseStatus'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  2, 'Pardot.LBL_API_USER_KEY'                , 'Pardot.ApiUserKey'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Pardot.ConfigView'          ,  7, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  3, 'Pardot.LBL_API_USERNAME'                , 'Pardot.ApiUsername'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  3, 'Pardot.LBL_API_PASSWORD'                , 'Pardot.ApiPassword'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  4, 'Pardot.LBL_DIRECTION'                   , 'Pardot.Direction'                , '{0}', 'pardot_sync_direction'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  5, 'Pardot.LBL_CONFLICT_RESOLUTION'         , 'Pardot.ConflictResolution'       , '{0}', 'sync_conflict_resolution', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  6, 'Pardot.LBL_SYNC_MODULES'                , 'Pardot.SyncModules'              , '{0}', 'pardot_sync_module'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Pardot.ConfigView'          ,  7, null;
end -- if;
GO

-- 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Exchange.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Exchange.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Exchange.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Exchange.ConfigView', 'Exchange', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  0, 'Exchange.LBL_SERVER_URL'                , 'Exchange.ServerURL'              , '{0}', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Exchange.ConfigView'        ,  2, 'Exchange.LBL_AUTHENTICATION_METHOD'     , 'Exchange.AuthenticationMethod'   , '{0}', 'exchange_authentication_method', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  3, 'Exchange.LBL_OAUTH_DIRECTORY_TENANT_ID' , 'Exchange.DirectoryTenantID'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  4, 'Exchange.LBL_OAUTH_CLIENT_ID'           , 'Exchange.ClientID'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  5, 'Exchange.LBL_OAUTH_CLIENT_SECRET'       , 'Exchange.ClientSecret'           , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  6, 'Exchange.LBL_USER_NAME'                 , 'Exchange.UserName'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  7, 'Exchange.LBL_PASSWORD'                  , 'Exchange.Password'               , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        ,  8, 'Exchange.LBL_IGNORE_CERTIFICATE'        , 'Exchange.IgnoreCertificate'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'Exchange.ConfigView'        ,  9, 'Exchange.LBL_IMPERSONATED_TYPE'         , 'Exchange.ImpersonatedType'       , '{0}', 'exchange_impersonated_type'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 10, 'Exchange.LBL_INBOX_ROOT'                , 'Exchange.InboxRoot'              , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 11, 'Exchange.LBL_SENT_ITEMS_ROOT'           , 'Exchange.SentItemsRoot'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 12, 'Exchange.LBL_PUSH_NOTIFICATIONS'        , 'Exchange.PushNotifications'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 13, 'Exchange.LBL_SENT_ITEMS_SYNC'           , 'Exchange.SentItemsSync'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        , 14, 'Exchange.LBL_PUSH_FREQUENCY'            , 'Exchange.PushFrequency'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 15, 'Exchange.LBL_INBOX_SYNC'                , 'Exchange.InboxSync'              , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        , 16, 'Exchange.LBL_PUSH_NOTIFICATION_URL'     , 'Exchange.PushNotificationURL'    , '{0}', 3;
end else begin
	-- 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Exchange.ConfigView' and DATA_FIELD = 'Exchange.Version' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DELETED           = 0
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()     
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Exchange.ConfigView'
		   and DATA_FIELD        = 'Exchange.Version'
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  3, 'Exchange.LBL_OAUTH_DIRECTORY_TENANT_ID' , 'Exchange.DirectoryTenantID'      , '{0}', null;
	end -- if;
end -- if;
GO

-- 11/02/2019 Paul.  New layout for Avaya. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Avaya.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Avaya.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Avaya.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'Avaya.ConfigView', 'Avaya', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  1, 'Avaya.LBL_HOST_SERVER'                  , 'Avaya.Host'                      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  2, 'Avaya.LBL_HOST_PORT'                    , 'Avaya.Port'                      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  3, 'Avaya.LBL_SWITCH_NAME'                  , 'Avaya.SwitchName'                , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  4, 'Avaya.LBL_SECURE_SOCKET'                , 'Avaya.SecureSocket'              , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  5, 'Avaya.LBL_USER_NAME'                    , 'Avaya.UserName'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  6, 'Avaya.LBL_PASSWORD'                     , 'Avaya.Password'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  7, 'Avaya.LBL_LOG_MISSED_INCOMING_CALLS'    , 'Avaya.LogIncomingMissedCalls'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  8, 'Avaya.LBL_LOG_MISSED_OUTGOING_CALLS'    , 'Avaya.LogOutgoingMissedCalls'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  9, 'Avaya.LBL_LOG_CALL_DETAILS'             , 'Avaya.LogCallDetails'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'Avaya.ConfigView'           , 10, null;
end -- if;
GO

-- 11/02/2019 Paul.  New layout for PayTrace. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayTrace.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'PayTrace.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS PayTrace.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'PayTrace.ConfigView', 'PayTrace', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'PayTrace.ConfigView'        ,  0, 'PayTrace.LBL_ENABLED'                   , 'Avaya.Enabled'                   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'PayTrace.ConfigView'        ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  2, 'PayTrace.LBL_USER_NAME'                 , 'Avaya.UserName'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  3, 'PayTrace.LBL_PASSWORD'                  , 'Avaya.Password'                  , '{0}', null;
end -- if;
GO

-- 04/15/2021 Paul.  New layout for React Precompile. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMan.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMan.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS EmailMan.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'EmailMan.ConfigView', 'EmailMan', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader      'EmailMan.ConfigView'        ,  0, 'EmailMan.LBL_NOTIFY_TITLE', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  1, 'EmailMan.LBL_NOTIFY_FROMNAME'           , 'fromname'                       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  2, 'EmailMan.LBL_NOTIFY_FROMADDRESS'        , 'fromaddress'                    , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList   'EmailMan.ConfigView'        ,  3, 'EmailMan.LBL_MAIL_SENDTYPE'             , 'mail_sendtype'                  , '{0}', 'outbound_send_type', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  4, 'EmailMan.LBL_MAIL_SMTPSERVER'           , 'smtpserver'                     , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  5, 'EmailMan.LBL_MAIL_SMTPPORT'             , 'smtpport'                       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'EmailMan.ConfigView'        ,  6, 'EmailMan.LBL_MAIL_SMTPAUTH_REQ'         , 'smtpauth_req'                   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'EmailMan.ConfigView'        ,  7, 'EmailMan.LBL_MAIL_SMTPSSL'              , 'smtpssl'                        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  8, 'EmailMan.LBL_MAIL_SMTPUSER'             , 'smtpuser'                       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'EmailMan.ConfigView'        ,  9, null;
end -- if;
GO

-- 12/26/2022 Paul.  Add support for Microsoft Teams. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'MicrosoftTeams.ConfigView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'MicrosoftTeams.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS MicrosoftTeams.ConfigView';
	exec dbo.spDETAILVIEWS_InsertOnly            'MicrosoftTeams.ConfigView', 'MicrosoftTeams', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'MicrosoftTeams.ConfigView' ,  0, 'MicrosoftTeams.LBL_MICROSOFTTEAMS_ENABLED'   , 'MicrosoftTeams.Enabled'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox    'MicrosoftTeams.ConfigView' ,  1, 'MicrosoftTeams.LBL_VERBOSE_STATUS'           , 'MicrosoftTeams.VerboseStatus'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  2, 'MicrosoftTeams.LBL_OAUTH_DIRECTORY_TENANT_ID', 'MicrosoftTeams.DirectoryTenantID' , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank       'MicrosoftTeams.ConfigView' ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  4, 'MicrosoftTeams.LBL_OAUTH_CLIENT_ID'          , 'MicrosoftTeams.ClientID'          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  5, 'MicrosoftTeams.LBL_OAUTH_ACCESS_TOKEN'       , 'MicrosoftTeams.OAuthAccessToken'  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  6, 'MicrosoftTeams.LBL_OAUTH_CLIENT_SECRET'      , 'MicrosoftTeams.ClientSecret'      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  7, 'MicrosoftTeams.LBL_OAUTH_REFRESH_TOKEN'      , 'MicrosoftTeams.OAuthRefreshToken' , '{0}', null;
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

call dbo.spDETAILVIEWS_FIELDS_Admin()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_Admin')
/

-- #endif IBM_DB2 */

