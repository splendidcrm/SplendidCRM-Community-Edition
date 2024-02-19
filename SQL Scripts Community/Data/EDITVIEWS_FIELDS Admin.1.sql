

print 'EDITVIEWS_FIELDS Admin';
set nocount on;
GO


-- select * from vwEDITVIEWS_FIELDS where EDIT_NAME = 'Config.EditView' order by FIELD_INDEX;
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Config.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Config.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Config.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Config.EditView', 'Config', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Config.EditView'            ,  0, 'Config.LBL_NAME'                        , 'NAME'                             , 1, 1,  60, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Config.EditView'            ,  1, 'Config.LBL_CATEGORY'                    , 'CATEGORY'                         , 0, 1,  32, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Config.EditView'            ,  2, 'Config.LBL_VALUE'                       , 'VALUE'                            , 0, 1,   8, 80, 3;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Config.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Config.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Config.SearchBasic', 'Config' , 'vwCONFIG_List', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Config.SearchBasic'         ,  0, 'Config.LBL_NAME'                        , 'NAME'                             , 0, 1,  60, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Config.SearchBasic'         ,  1, 'Config.LBL_VALUE'                       , 'VALUE'                            , 0, 1, 200, 35, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Currencies.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Currencies.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Currencies.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Currencies.EditView' , 'Currencies', 'vwCURRENCIES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Currencies.EditView'        ,  0, 'Currencies.LBL_NAME'                    , 'NAME'                             , 1, 1,  60, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Currencies.EditView'        ,  1, 'Currencies.LBL_ISO4217'                 , 'ISO4217'                          , 1, 1,  32, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Currencies.EditView'        ,  2, 'Currencies.LBL_RATE'                    , 'CONVERSION_RATE'                  , 1, 1,  32, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Currencies.EditView'        ,  3, 'Currencies.LBL_SYMBOL'                  , 'SYMBOL'                           , 1, 1,  32, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Currencies.EditView'        ,  4, 'Currencies.LBL_STATUS'                  , 'STATUS'                           , 1, 1, 'currency_status_dom', null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Schedulers.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Schedulers.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Schedulers.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Schedulers.EditView', 'Schedulers', 'vwSCHEDULERS', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Schedulers.EditView'        ,  0, 'Schedulers.LBL_NAME'                    , 'NAME'                             , 1, 1,  60, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Schedulers.EditView'        ,  1, 'Schedulers.LBL_STATUS'                  , 'STATUS'                           , 1, 1, 'scheduler_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Schedulers.EditView'        ,  2, 'Schedulers.LBL_JOB'                     , 'JOB'                              , 1, 1, 'SchedulerJobs', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Schedulers.EditView'        ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Schedulers.EditView'        ,  4, 'Schedulers.LBL_INTERVAL'                , 'JOB_INTERVAL'                     , 1, 1, 'CRON'           , null, 3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Schedulers.EditView'        ,  5, 'Schedulers.LBL_DATE_TIME_START'         , 'DATE_TIME_START'                  , 0, 1, 'DateTimePicker' , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Schedulers.EditView'        ,  6, 'Schedulers.LBL_TIME_FROM'               , 'TIME_FROM'                        , 0, 1, 'TimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Schedulers.EditView'        ,  7, 'Schedulers.LBL_DATE_TIME_END'           , 'DATE_TIME_END'                    , 0, 1, 'DateTimePicker' , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Schedulers.EditView'        ,  8, 'Schedulers.LBL_TIME_TO'                 , 'TIME_TO'                          , 0, 1, 'TimePicker'     , null, null, null;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Schedulers.EditView' and DATA_FIELD = 'JOB_INTERVAL' and FIELD_TYPE = 'TextBox' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set FIELD_TYPE        = 'CRON'
		     , FORMAT_SIZE       = null
		     , FORMAT_MAX_LENGTH = null
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where EDIT_NAME         = 'Schedulers.EditView'
		   and DATA_FIELD        = 'JOB_INTERVAL'
		   and FIELD_TYPE        = 'TextBox'
		   and DELETED           = 0;
	end -- if; 
end -- if;
GO

-- 02/03/2021 Paul.  Provide a way to search. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Schedulers.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Schedulers.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Schedulers.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Schedulers.SearchBasic', 'Schedulers', 'vwSCHEDULERS', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Schedulers.SearchBasic'     ,  0, 'Schedulers.LBL_NAME'                    , 'NAME'                             , 1, 1,  60, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Schedulers.SearchBasic'     ,  1, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Terminology.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Terminology.EditView', 'Terminology', 'vwTERMINOLOGY_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Terminology.EditView'       ,  0, 'Terminology.LBL_NAME'                   , 'NAME'                             , 0, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.EditView'       ,  1, 'Terminology.LBL_LANG'                   , 'LANG'                             , 1, 1, 'Languages'           , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.EditView'       ,  2, 'Terminology.LBL_MODULE_NAME'            , 'MODULE_NAME'                      , 0, 1, 'Modules'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Terminology.EditView'       ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.EditView'       ,  4, 'Terminology.LBL_LIST_NAME'              , 'LIST_NAME'                        , 0, 1, 'TerminologyPickLists', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Terminology.EditView'       ,  5, 'Terminology.LBL_LIST_ORDER'             , 'LIST_ORDER'                       , 0, 1,  10, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Terminology.EditView'       ,  6, 'Terminology.LBL_DISPLAY_NAME'           , 'DISPLAY_NAME'                     , 0, 1,   8, 80, 3;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Terminology.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Terminology.SearchBasic', 'Terminology', 'vwTERMINOLOGY_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Terminology.SearchBasic'    ,  0, 'Terminology.LBL_NAME'                   , 'NAME'                             , 0, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.SearchBasic'    ,  1, 'Terminology.LBL_LANG'                   , 'LANG'                             , 1, 1, 'Languages'           , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.SearchBasic'    ,  2, 'Terminology.LBL_MODULE_NAME'            , 'MODULE_NAME'                      , 0, 1, 'Modules'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Terminology.SearchBasic'    ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.SearchBasic'    ,  4, 'Terminology.LBL_LIST_NAME'              , 'LIST_NAME'                        , 0, 1, 'TerminologyPickLists', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Terminology.SearchBasic'    ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Terminology.SearchBasic'    ,  6, 'Terminology.LBL_DISPLAY_NAME'           , 'DISPLAY_NAME'                     , 0, 1,   8, 80, 3;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Shortcuts.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Shortcuts.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Shortcuts.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Shortcuts.EditView', 'Shortcuts', 'vwSHORTCUTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Shortcuts.EditView'         ,  0, 'Shortcuts.LBL_MODULE_NAME'              , 'MODULE_NAME'                      , 0, 1, 'Modules'              , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Shortcuts.EditView'         ,  1, 'Shortcuts.LBL_DISPLAY_NAME'             , 'DISPLAY_NAME'                     , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Shortcuts.EditView'         ,  2, 'Shortcuts.LBL_RELATIVE_PATH'            , 'RELATIVE_PATH'                    , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Shortcuts.EditView'         ,  3, 'Shortcuts.LBL_IMAGE_NAME'               , 'IMAGE_NAME'                       , 0, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Shortcuts.EditView'         ,  4, 'Shortcuts.LBL_SHORTCUT_ORDER'           , 'SHORTCUT_ORDER'                   , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Shortcuts.EditView'         ,  5, 'Shortcuts.LBL_SHORTCUT_ENABLED'         , 'SHORTCUT_ENABLED'                 , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Shortcuts.EditView'         ,  6, 'Shortcuts.LBL_SHORTCUT_MODULE'          , 'SHORTCUT_MODULE'                  , 0, 1, 'Modules'              , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Shortcuts.EditView'         ,  7, 'Shortcuts.LBL_SHORTCUT_ACLTYPE'         , 'SHORTCUT_ACLTYPE'                 , 0, 1, 'shortcuts_acltype_dom', null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicButtons.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicButtons.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS DynamicButtons.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'DynamicButtons.SearchBasic', 'DynamicButtons', 'vwDYNAMIC_BUTTONS', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'DynamicButtons.SearchBasic' ,  0, 'DynamicButtons.LBL_VIEW_NAME'           , 'VIEW_NAME'                        , 1, 1, 'DynamicButtonViews'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'DynamicButtons.SearchBasic' ,  1, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tags.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Tags.SearchBasic', 'Tags', 'vwTAGS_List', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tags.SearchBasic'           ,  0, 'Tags.LBL_NAME'                          , 'NAME'                             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tags.SearchBasic'           ,  1, null;
end -- if;
GO

-- 04/03/2020 Paul.  Provide search view for Tags Popup. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.SearchPopup';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tags.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly            'Tags.SearchPopup', 'Tags', 'vwTAGS_List', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tags.SearchPopup'           ,  0, 'Tags.LBL_NAME'                          , 'NAME'                             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tags.SearchPopup'           ,  1, 'Tags.LBL_DESCRIPTION'                   , 'DESCRIPTION'                             , 0, 1, 150, 35, null;
end -- if;
GO


-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'PaymentGateway.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'PaymentGateway.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS PaymentGateway.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'PaymentGateway.SearchBasic', 'PaymentGateway', 'vwPAYMENT_GATEWAYS', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PaymentGateway.SearchBasic' ,  0, 'PaymentGateway.LBL_NAME'                , 'NAME'                             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'PaymentGateway.SearchBasic' ,  1, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ForumTopics.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ForumTopics.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ForumTopics.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'ForumTopics.EditView', 'ForumTopics', 'vwFORUM_TOPICS', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ForumTopics.EditView'       ,  0, 'ForumTopics.LBL_NAME'                   , 'NAME'                             , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ForumTopics.EditView'       ,  1, 'ForumTopics.LBL_ORDER'                  , 'LIST_ORDER'                       , 0, 1,  10, 20, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Asterisk.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Asterisk.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Asterisk.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Asterisk.ConfigView', 'Asterisk', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  0, 'Asterisk.LBL_HOST_SERVER'               , 'Asterisk.Host'                    , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  1, 'Asterisk.LBL_HOST_PORT'                 , 'Asterisk.Port'                    , 0, 1,  10, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  2, 'Asterisk.LBL_USER_NAME'                 , 'Asterisk.UserName'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  3, 'Asterisk.LBL_PASSWORD'                  , 'Asterisk.Password'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  4, 'Asterisk.LBL_FROM_TRUNK'                , 'Asterisk.Trunk'                   , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Asterisk.ConfigView'        ,  5, 'Asterisk.LBL_FROM_CONTEXT'              , 'Asterisk.Context'                 , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  6, 'Asterisk.LBL_LOG_MISSED_INCOMING_CALLS' , 'Asterisk.LogIncomingMissedCalls'  , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  7, 'Asterisk.LBL_LOG_MISSED_OUTGOING_CALLS' , 'Asterisk.LogOutgoingMissedCalls'  , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  8, 'Asterisk.LBL_LOG_CALL_DETAILS'          , 'Asterisk.LogCallDetails'          , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Asterisk.ConfigView'        ,  9, 'Asterisk.LBL_ORIGINATE_EXTENSION_FIRST' , 'Asterisk.OriginateExtensionFirst' , 0, 1, null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'PayTrace.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'PayTrace.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS PayTrace.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'PayTrace.ConfigView', 'PayTrace', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'PayTrace.ConfigView'        ,  0, 'PayTrace.LBL_ENABLED'                   , 'PayTrace.Enabled'                , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'PayTrace.ConfigView'        ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  2, 'PayTrace.LBL_USER_NAME'                 , 'PayTrace.UserName'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  3, 'PayTrace.LBL_PASSWORD'                  , 'PayTrace.Password'                , 0, 1, 150, 35, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'PayPal.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'PayPal.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS PayPal.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'PayPal.ConfigView', 'PayPal', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  0, 'PayPal.LBL_USER_NAME'                   , 'PayPal.APIUsername'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayPal.ConfigView'          ,  1, 'PayPal.LBL_PASSWORD'                    , 'PayPal.APIPassword'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'PayPal.ConfigView'          ,  2, 'PayPal.LBL_PRIVATE_KEY'                 , 'PayPal.X509PrivateKey'            , 0, 1,   3, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'PayPal.ConfigView'          ,  3, 'PayPal.LBL_CERTIFICATE'                 , 'PayPal.X509Certificate'           , 0, 1,   3, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'PayPal.ConfigView'          ,  4, 'PayPal.LBL_REST_CLIENT_ID'              , 'PayPal.ClientID'                  , 0, 1,   3, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'PayPal.ConfigView'          ,  5, 'PayPal.LBL_REST_CLIENT_SECRET'          , 'PayPal.ClientSecret'              , 0, 1,   3, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'PayPal.ConfigView'          ,  6, 'PayPal.LBL_SANDBOX'                     , 'PayPal.Sandbox'                   , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'PayPal.ConfigView'          ,  7, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'AuthorizeNet.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'AuthorizeNet.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS AuthorizeNet.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'AuthorizeNet.ConfigView', 'AuthorizeNet', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'AuthorizeNet.ConfigView'    ,  0, 'AuthorizeNet.LBL_ENABLED'               , 'AuthorizeNet.Enabled'             , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'AuthorizeNet.ConfigView'    ,  1, 'AuthorizeNet.LBL_TEST_MODE'             , 'AuthorizeNet.TestMode'            , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'AuthorizeNet.ConfigView'    ,  2, 'AuthorizeNet.LBL_USER_NAME'             , 'AuthorizeNet.UserName'            , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'AuthorizeNet.ConfigView'    ,  3, 'AuthorizeNet.LBL_TRANSACTION_KEY'       , 'AuthorizeNet.TransactionKey'      , 0, 1, 150, 35, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Facebook.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Facebook.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Facebook.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Facebook.ConfigView', 'Facebook', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Facebook.ConfigView'        ,  0, 'Facebook.LBL_FACEBOOK_APPID'            , 'facebook.AppID'                   , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Facebook.ConfigView'        ,  1, 'Facebook.LBL_FACEBOOK_ENABLE_LOGIN'     , 'facebook.EnableLogin'             , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Facebook.ConfigView'        ,  2, 'Facebook.LBL_FACEBOOK_SECRET_KEY'       , 'facebook.AppSecret'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Facebook.ConfigView'        ,  3, 'Facebook.LBL_FACEBOOK_PORTAL_LOGIN'     , 'facebook.Portal.EnableLogin'      , 0, 1, null, null, null;
end -- if;
GO

-- 03/10/2021 Paul.  Correct PushNotificationURL field type. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Google.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Google.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Google.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Google.ConfigView', 'Google', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  0, 'Google.LBL_GOOGLE_APPS_ENABLED'         , 'GoogleApps.Enabled'               , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  1, 'Google.LBL_VERBOSE_STATUS'              , 'GoogleApps.VerboseStatus'         , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  2, 'Google.LBL_OAUTH_API_KEY'               , 'GoogleApps.ApiKey'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  3, 'Google.LBL_OAUTH_CLIENT_ID'             , 'GoogleApps.ClientID'              , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Google.ConfigView'          ,  4, 'Google.LBL_PUSH_NOTIFICATIONS'          , 'GoogleApps.PushNotifications'     , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  5, 'Google.LBL_OAUTH_CLIENT_SECRET'         , 'GoogleApps.ClientSecret'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  6, 'Google.LBL_PUSH_NOTIFICATION_URL'       , 'GoogleApps.PushNotificationURL'   , 0, 1, 255, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsButton      'Google.ConfigView'          ,  7, null                                     , 'Exchange.LBL_TEST_URL'           , 'TestPushURL', -1;
end else begin
	-- 03/10/2021 Paul.  Correct PushNotificationURL field type. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Google.ConfigView' and DATA_FIELD = 'GoogleApps.PushNotificationURL' and FIELD_TYPE = 'CheckBox' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where EDIT_NAME         = 'Google.ConfigView'
		   and DATA_FIELD        = 'GoogleApps.PushNotificationURL'
		   and FIELD_TYPE        = 'CheckBox'
		   and DELETED           = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsBound       'Google.ConfigView'          ,  6, 'Google.LBL_PUSH_NOTIFICATION_URL'       , 'GoogleApps.PushNotificationURL'   , 0, 1, 255, 60, 3;
		exec dbo.spEDITVIEWS_FIELDS_InsButton      'Google.ConfigView'          ,  7, null                                     , 'Exchange.LBL_TEST_URL'           , 'TestPushURL', -1;
	end -- if; 
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'LinkedIn.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'LinkedIn.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS LinkedIn.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'LinkedIn.ConfigView', 'LinkedIn', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'LinkedIn.ConfigView'        ,  0, 'LinkedIn.LBL_LINKEDIN_API_KEY'          , 'LinkedIn.APIKey'                  , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'LinkedIn.ConfigView'        ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'LinkedIn.ConfigView'        ,  2, 'LinkedIn.LBL_LINKEDIN_SECRET_KEY'       , 'LinkedIn.SecretKey'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'LinkedIn.ConfigView'        ,  3, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Twitter.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Twitter.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Twitter.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Twitter.ConfigView', 'Twitter', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  0, 'Twitter.LBL_TWITTER_CONSUMER_KEY'       , 'Twitter.ConsumerKey'              , 0, 1, 150, 35, 3
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twitter.ConfigView'         ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  2, 'Twitter.LBL_TWITTER_SECRET_KEY'         , 'Twitter.ConsumerSecret'           , 0, 1, 150, 35, 3
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twitter.ConfigView'         ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  4, 'Twitter.LBL_ACCESS_TOKEN'               , 'Twitter.AccessToken'              , 0, 1, 150, 35, 3
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twitter.ConfigView'         ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twitter.ConfigView'         ,  6, 'Twitter.LBL_ACCESS_TOKEN_SECRET'        , 'Twitter.AccessTokenSecret'        , 0, 1, 150, 35, 3
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twitter.ConfigView'         ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Twitter.ConfigView'         ,  8, 'Twitter.LBL_ENABLE_TRACKING'            , 'Twitter.EnableTracking'           , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twitter.ConfigView'         ,  9, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Salesforce.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Salesforce.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Salesforce.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Salesforce.ConfigView', 'Salesforce', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Salesforce.ConfigView'      ,  0, 'Salesforce.LBL_SALESFORCE_CONSUMER_KEY' , 'Salesforce.ConsumerKey'           , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Salesforce.ConfigView'      ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Salesforce.ConfigView'      ,  2, 'Salesforce.LBL_SALESFORCE_SECRET_KEY'   , 'Salesforce.ConsumerSecret'        , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Salesforce.ConfigView'      ,  3, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Twilio.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Twilio.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Twilio.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Twilio.ConfigView', 'Twilio', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  0, 'Twilio.LBL_ACCOUNT_SID'                 , 'Twilio.AccountSID'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  1, 'Twilio.LBL_AUTH_TOKEN'                  , 'Twilio.AuthToken'                 , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Twilio.ConfigView'          ,  2, 'Twilio.LBL_FROM_PHONE'                  , 'Twilio.FromPhone'                 , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Twilio.ConfigView'          ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Twilio.ConfigView'          ,  4, 'Twilio.LBL_LOG_INBOUND_MESSAGES'        , 'Twilio.LogInboundMessages'        , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Twilio.ConfigView'          ,  5, 'Twilio.LBL_MESSAGE_REQUEST_URL'         , 'Twilio.MessageRequestURL'         , null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'HubSpot.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'HubSpot.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS HubSpot.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'HubSpot.ConfigView', 'HubSpot', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'HubSpot.ConfigView'         ,  0, 'HubSpot.LBL_HUBSPOT_ENABLED'            , 'HubSpot.Enabled'                  , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'HubSpot.ConfigView'         ,  1, 'HubSpot.LBL_VERBOSE_STATUS'             , 'HubSpot.VerboseStatus'            , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  2, 'HubSpot.LBL_OAUTH_PORTAL_ID'            , 'HubSpot.PortalID'                 , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  3, 'HubSpot.LBL_OAUTH_ACCESS_TOKEN'         , 'HubSpot.OAuthAccessToken'         , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  4, 'HubSpot.LBL_OAUTH_CLIENT_ID'            , 'HubSpot.ClientID'                 , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  5, 'HubSpot.LBL_OAUTH_REFRESH_TOKEN'        , 'HubSpot.OAuthRefreshToken'        , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  6, 'HubSpot.LBL_OAUTH_CLIENT_SECRET'        , 'HubSpot.ClientSecret'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'HubSpot.ConfigView'         ,  7, 'HubSpot.LBL_OAUTH_EXPIRES_AT'           , 'HubSpot.OAuthExpiresAt'           , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         ,  8, 'HubSpot.LBL_DIRECTION'                  , 'HubSpot.Direction'                , 1, 1, 'hubspot_sync_direction'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         ,  9, 'HubSpot.LBL_CONFLICT_RESOLUTION'        , 'HubSpot.ConflictResolution'       , 0, 1, 'sync_conflict_resolution' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'HubSpot.ConfigView'         , 10, 'HubSpot.LBL_SYNC_MODULES'               , 'HubSpot.SyncModules'              , 1, 1, 'hubspot_sync_module'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'HubSpot.ConfigView'         , 11, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'iContact.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'iContact.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS iContact.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'iContact.ConfigView', 'iContact', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'iContact.ConfigView'        ,  0, 'iContact.LBL_ICONTACT_ENABLED'          , 'iContact.Enabled'                 , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'iContact.ConfigView'        ,  1, 'iContact.LBL_VERBOSE_STATUS'            , 'iContact.VerboseStatus'           , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  2, 'iContact.LBL_API_APP_ID'                , 'iContact.ApiAppId'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iContact.ConfigView'        ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  4, 'iContact.LBL_API_USERNAME'              , 'iContact.ApiUsername'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  5, 'iContact.LBL_API_PASSWORD'              , 'iContact.ApiPassword'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  6, 'iContact.LBL_ICONTACT_ACCOUNT_ID'       , 'iContact.iContactAccountId'       , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iContact.ConfigView'        ,  7, 'iContact.LBL_ICONTACT_CLIENT_FOLDER_ID' , 'iContact.iContactClientFolderId'  , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        ,  8, 'iContact.LBL_DIRECTION'                 , 'iContact.Direction'               , 1, 1, 'icontact_sync_direction'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        ,  9, 'iContact.LBL_CONFLICT_RESOLUTION'       , 'iContact.ConflictResolution'      , 0, 1, 'sync_conflict_resolution' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'iContact.ConfigView'        , 10, 'iContact.LBL_SYNC_MODULES'              , 'iContact.SyncModules'             , 1, 1, 'icontact_sync_module'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iContact.ConfigView'        , 11, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ConstantContact.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ConstantContact.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ConstantContact.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'ConstantContact.ConfigView', 'ConstantContact', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'ConstantContact.ConfigView' ,  0, 'ConstantContact.LBL_CONSTANTCONTACT_ENABLED', 'ConstantContact.Enabled'       , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'ConstantContact.ConfigView' ,  1, 'ConstantContact.LBL_VERBOSE_STATUS'     , 'ConstantContact.VerboseStatus'     , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  2, 'ConstantContact.LBL_OAUTH_CLIENT_ID'    , 'ConstantContact.ClientID'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  3, 'ConstantContact.LBL_OAUTH_ACCESS_TOKEN' , 'ConstantContact.OAuthAccessToken'  , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  4, 'ConstantContact.LBL_OAUTH_CLIENT_SECRET', 'ConstantContact.ClientSecret'      , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ConstantContact.ConfigView' ,  5, 'ConstantContact.LBL_OAUTH_REFRESH_TOKEN', 'ConstantContact.OAuthRefreshToken' , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  6, 'ConstantContact.LBL_DIRECTION'          , 'ConstantContact.Direction'         , 1, 1, 'constantcontact_sync_direction', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  7, 'ConstantContact.LBL_CONFLICT_RESOLUTION', 'ConstantContact.ConflictResolution', 0, 1, 'sync_conflict_resolution'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ConstantContact.ConfigView' ,  8, 'ConstantContact.LBL_SYNC_MODULES'       , 'ConstantContact.SyncModules'       , 1, 1, 'constantcontact_sync_module'   , null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Marketo.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Marketo.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Marketo.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Marketo.ConfigView', 'Marketo', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Marketo.ConfigView'         ,  0, 'Marketo.LBL_MARKETO_ENABLED'            , 'Marketo.Enabled'                 , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Marketo.ConfigView'         ,  1, 'Marketo.LBL_VERBOSE_STATUS'             , 'Marketo.VerboseStatus'           , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  2, 'Marketo.LBL_OAUTH_ENDPOINT_URL'         , 'Marketo.EndpointURL'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  3, 'Marketo.LBL_OAUTH_IDENTITY_URL'         , 'Marketo.IdentityURL'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  4, 'Marketo.LBL_OAUTH_CLIENT_ID'            , 'Marketo.ClientID'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  5, 'Marketo.LBL_OAUTH_ACCESS_TOKEN'         , 'Marketo.OAuthAccessToken'        , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  6, 'Marketo.LBL_OAUTH_CLIENT_SECRET'        , 'Marketo.ClientSecret'            , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  7, 'Marketo.LBL_OAUTH_SCOPE'                , 'Marketo.OAuthScope'              , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Marketo.ConfigView'         ,  8, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Marketo.ConfigView'         ,  9, 'Marketo.LBL_OAUTH_EXPIRES_AT'           , 'Marketo.OAuthExpiresAt'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 10, 'Marketo.LBL_DIRECTION'                  , 'Marketo.Direction'               , 1, 1, 'marketo_sync_direction'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 11, 'Marketo.LBL_CONFLICT_RESOLUTION'        , 'Marketo.ConflictResolution'      , 0, 1, 'sync_conflict_resolution' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Marketo.ConfigView'         , 12, 'Marketo.LBL_SYNC_MODULES'               , 'Marketo.SyncModules'             , 1, 1, 'marketo_sync_module'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Marketo.ConfigView'         , 13, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'CurrencyLayer.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'CurrencyLayer.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS CurrencyLayer.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'CurrencyLayer.ConfigView', 'CurrencyLayer', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CurrencyLayer.ConfigView'   ,  0, 'CurrencyLayer.LBL_ACCESS_KEY'           , 'CurrencyLayer.AccessKey'         , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'CurrencyLayer.ConfigView'   ,  1, 'CurrencyLayer.LBL_LOG_CONVERSIONS'      , 'CurrencyLayer.LogConversions'    , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CurrencyLayer.ConfigView'   ,  2, 'CurrencyLayer.LBL_RATE_LIFETIME'        , 'CurrencyLayer.RateLifetime'      , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'CurrencyLayer.ConfigView'   ,  3, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'GetResponse.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'GetResponse.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS GetResponse.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'GetResponse.ConfigView', 'GetResponse', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'GetResponse.ConfigView'     ,  0, 'GetResponse.LBL_GETRESPONSE_ENABLED'    , 'GetResponse.Enabled'             , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'GetResponse.ConfigView'     ,  1, 'GetResponse.LBL_VERBOSE_STATUS'         , 'GetResponse.VerboseStatus'       , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'GetResponse.ConfigView'     ,  2, 'GetResponse.LBL_SECRET_API_KEY'         , 'GetResponse.SecretApiKey'        , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'GetResponse.ConfigView'     ,  3, 'GetResponse.LBL_DEFAULT_CAMPAIGN_NAME'  , 'GetResponse.DefaultCampaignName' , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  4, 'GetResponse.LBL_DIRECTION'              , 'GetResponse.Direction'           , 1, 1, 'getresponse_sync_direction', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  5, 'GetResponse.LBL_CONFLICT_RESOLUTION'    , 'GetResponse.ConflictResolution'  , 0, 1, 'sync_conflict_resolution'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'GetResponse.ConfigView'     ,  6, 'GetResponse.LBL_SYNC_MODULES'           , 'GetResponse.SyncModules'         , 1, 1, 'getresponse_sync_module'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'GetResponse.ConfigView'     ,  7, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Pardot.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Pardot.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Pardot.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Pardot.ConfigView', 'Pardot', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Pardot.ConfigView'          ,  0, 'Pardot.LBL_PARDOT_ENABLED'              , 'Pardot.Enabled'                  , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Pardot.ConfigView'          ,  1, 'Pardot.LBL_VERBOSE_STATUS'              , 'Pardot.VerboseStatus'            , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  2, 'Pardot.LBL_API_USER_KEY'                , 'Pardot.ApiUserKey'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Pardot.ConfigView'          ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  3, 'Pardot.LBL_API_USERNAME'                , 'Pardot.ApiUsername'              , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Pardot.ConfigView'          ,  3, 'Pardot.LBL_API_PASSWORD'                , 'Pardot.ApiPassword'              , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  4, 'Pardot.LBL_DIRECTION'                   , 'Pardot.Direction'                , 1, 1, 'pardot_sync_direction'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  5, 'Pardot.LBL_CONFLICT_RESOLUTION'         , 'Pardot.ConflictResolution'       , 0, 1, 'sync_conflict_resolution', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Pardot.ConfigView'          ,  6, 'Pardot.LBL_SYNC_MODULES'                , 'Pardot.SyncModules'              , 1, 1, 'pardot_sync_module'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Pardot.ConfigView'          ,  7, null;
end -- if;
GO

-- 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations.
-- 07/08/2023 Paul.  Password should be of type Password.  
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Exchange.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Exchange.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Exchange.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Exchange.ConfigView', 'Exchange', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  0, 'Exchange.LBL_SERVER_URL'                , 'Exchange.ServerURL'              , 0, 1, 150, 35, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsButton      'Exchange.ConfigView'        ,  1, null                                     , 'Exchange.LBL_USE_OFFICE365'      , 'UseOffice365', -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Exchange.ConfigView'        ,  2, 'Exchange.LBL_AUTHENTICATION_METHOD'     , 'Exchange.AuthenticationMethod'   , 1, 1, 'exchange_authentication_method', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  3, 'Exchange.LBL_OAUTH_DIRECTORY_TENANT_ID' , 'Exchange.DirectoryTenantID'      , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  4, 'Exchange.LBL_OAUTH_CLIENT_ID'           , 'Exchange.ClientID'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  5, 'Exchange.LBL_OAUTH_CLIENT_SECRET'       , 'Exchange.ClientSecret'           , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  6, 'Exchange.LBL_USER_NAME'                 , 'Exchange.UserName'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsPassword    'Exchange.ConfigView'        ,  7, 'Exchange.LBL_PASSWORD'                  , 'Exchange.Password'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        ,  8, 'Exchange.LBL_IGNORE_CERTIFICATE'        , 'Exchange.IgnoreCertificate'      , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Exchange.ConfigView'        ,  9, 'Exchange.LBL_IMPERSONATED_TYPE'         , 'Exchange.ImpersonatedType'       , 1, 1, 'exchange_impersonated_type'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 10, 'Exchange.LBL_INBOX_ROOT'                , 'Exchange.InboxRoot'              , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 11, 'Exchange.LBL_SENT_ITEMS_ROOT'           , 'Exchange.SentItemsRoot'          , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 12, 'Exchange.LBL_PUSH_NOTIFICATIONS'        , 'Exchange.PushNotifications'      , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 13, 'Exchange.LBL_SENT_ITEMS_SYNC'           , 'Exchange.SentItemsSync'          , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        , 14, 'Exchange.LBL_PUSH_FREQUENCY'            , 'Exchange.PushFrequency'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Exchange.ConfigView'        , 15, 'Exchange.LBL_INBOX_SYNC'                , 'Exchange.InboxSync'              , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        , 16, 'Exchange.LBL_PUSH_NOTIFICATION_URL'     , 'Exchange.PushNotificationURL'    , 0, 1, 150, 35, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsButton      'Exchange.ConfigView'        , 17, null                                     , 'Exchange.LBL_TEST_URL'           , 'TestPushURL', -1;
	update EDITVIEWS_FIELDS
	   set FIELD_TYPE        = 'Radio'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where EDIT_NAME         = 'Exchange.ConfigView'
	   and DATA_FIELD        = 'Exchange.AuthenticationMethod'
	   and DELETED           = 0;
end else begin
	-- 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Exchange.ConfigView' and DATA_FIELD = 'Exchange.Version' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Exchange.ConfigView'
		   and DATA_FIELD        = 'Exchange.Version'
		   and DELETED           = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsBound       'Exchange.ConfigView'        ,  3, 'Exchange.LBL_OAUTH_DIRECTORY_TENANT_ID' , 'Exchange.DirectoryTenantID'      , 0, 1, 150, 35, null;
	end -- if; 
	-- 07/08/2023 Paul.  Password should be of type Password.  
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Exchange.ConfigView' and DATA_FIELD = 'Exchange.Password' and FIELD_TYPE = 'TextBox' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set FIELD_TYPE        = 'Password'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Exchange.ConfigView'
		   and DATA_FIELD        = 'Exchange.Password'
		   and FIELD_TYPE        = 'TextBox'
		   and DELETED           = 0;
	end -- if; 
end -- if;
GO

if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.ConfigView' and DATA_FIELD = 'EmailMan.fromname' and DELETED = 0) begin -- then
	delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.ConfigView';
end -- if;

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailMan.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'EmailMan.ConfigView', 'EmailMan', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsHeader      'EmailMan.ConfigView'        ,  0, 'EmailMan.LBL_NOTIFY_TITLE', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  1, 'EmailMan.LBL_NOTIFY_FROMNAME'           , 'fromname'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  2, 'EmailMan.LBL_NOTIFY_FROMADDRESS'        , 'fromaddress'            , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'EmailMan.ConfigView'        ,  3, 'EmailMan.LBL_MAIL_SENDTYPE'             , 'mail_sendtype'          , 1, 1, 'outbound_send_type', 3, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  4, 'EmailMan.LBL_MAIL_SMTPSERVER'           , 'smtpserver'             , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  5, 'EmailMan.LBL_MAIL_SMTPPORT'             , 'smtpport'               , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'EmailMan.ConfigView'        ,  6, 'EmailMan.LBL_MAIL_SMTPAUTH_REQ'         , 'smtpauth_req'           , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'EmailMan.ConfigView'        ,  7, 'EmailMan.LBL_MAIL_SMTPSSL'              , 'smtpssl'                , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.ConfigView'        ,  8, 'EmailMan.LBL_MAIL_SMTPUSER'             , 'smtpuser'               , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsPassword    'EmailMan.ConfigView'        ,  9, 'EmailMan.LBL_MAIL_SMTPPASS'             , 'smtppass'               , 0, 1, 150, 35, null;
end -- if;
GO

-- 10/27/2019 Paul.  New layout for PasswordManager.  Needed to manually allow PasswordManager as module even as no entry exists in MODULES table. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'PasswordManager.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'PasswordManager.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS PasswordManager.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'PasswordManager.EditView', 'PasswordManager', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  0, 'PasswordManager.LBL_PREFERRED_PASSWORD_LENGTH'    , 'Password.PreferredPasswordLength'   , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  1, 'PasswordManager.LBL_MINIMUM_LOWER_CASE_CHARACTERS', 'Password.MinimumLowerCaseCharacters', 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  2, 'PasswordManager.LBL_MINIMUM_UPPER_CASE_CHARACTERS', 'Password.MinimumUpperCaseCharacters', 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  3, 'PasswordManager.LBL_MINIMUM_NUMERIC_CHARACTERS'   , 'Password.MinimumNumericCharacters'  , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  4, 'PasswordManager.LBL_MINIMUM_SYMBOL_CHARACTERS'    , 'Password.MinimumSymbolCharacters'   , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  5, 'PasswordManager.LBL_SYMBOL_CHARACTERS'            , 'Password.SymbolCharacters'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'PasswordManager.EditView'   ,  6, null                                               , 'PasswordManager.LBL_SYMBOL_CHARACTERS_DEFAULT !@#$%^&*()<>?~.', -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  7, 'PasswordManager.LBL_COMPLEXITY_NUMBER'            , 'Password.ComplexityNumber'          , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  8, 'PasswordManager.LBL_HISTORY_MAXIMUM'              , 'Password.HistoryMaximum'            , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   ,  9, 'PasswordManager.LBL_LOGIN_LOCKOUT_COUNT'          , 'Password.LoginLockoutCount'         , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PasswordManager.EditView'   , 10, 'PasswordManager.LBL_EXPIRATION_DAYS'              , 'Password.ExpirationDays'            , 0, 1,  10, 10, null;
end -- if;
GO

-- 10/27/2019 Paul.  New layout for BusinessMode. 
-- delete from EDITVIEWS where NAME = 'BusinessMode.EditView';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessMode.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessMode.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessMode.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'BusinessMode.EditView', 'BusinessMode', 'vwCONFIG_Edit', '0%', '50%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'BusinessMode.EditView'      ,  0, null, 'Administration.LBL_BUSINESS_MODE_INSTRUCTIONS'     , null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'BusinessMode.EditView'      ,  1, null, 'Administration.LBL_OPPORTUNITIES_MODE_INSTRUCTIONS', null;
	exec dbo.spEDITVIEWS_FIELDS_InsRadio       'BusinessMode.EditView'      ,  2, null, 'BusinessMode'                                      , 0, 1, 'business_mode_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsRadio       'BusinessMode.EditView'      ,  3, null, 'OpportunitiesMode'                                 , 0, 1, 'opportunities_mode_dom', null, null;
end -- if;
GO

-- 11/01/2019 Paul.  New layout for Asterisk. 
-- 02/24/2021 Paul.  Duplicate layout for Asterisk. 

-- 11/02/2019 Paul.  New layout for Avaya. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Avaya.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Avaya.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Avaya.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Avaya.ConfigView', 'Avaya', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  1, 'Avaya.LBL_HOST_SERVER'                  , 'Avaya.Host'                      , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  2, 'Avaya.LBL_HOST_PORT'                    , 'Avaya.Port'                      , 1, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  3, 'Avaya.LBL_SWITCH_NAME'                  , 'Avaya.SwitchName'                , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  4, 'Avaya.LBL_SECURE_SOCKET'                , 'Avaya.SecureSocket'              , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  5, 'Avaya.LBL_USER_NAME'                    , 'Avaya.UserName'                  , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Avaya.ConfigView'           ,  6, 'Avaya.LBL_PASSWORD'                     , 'Avaya.Password'                  , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  7, 'Avaya.LBL_LOG_MISSED_INCOMING_CALLS'    , 'Avaya.LogIncomingMissedCalls'    , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  8, 'Avaya.LBL_LOG_MISSED_OUTGOING_CALLS'    , 'Avaya.LogOutgoingMissedCalls'    , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Avaya.ConfigView'           ,  9, 'Avaya.LBL_LOG_CALL_DETAILS'             , 'Avaya.LogCallDetails'            , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Avaya.ConfigView'           , 10, null;
end -- if;
GO

-- 11/02/2019 Paul.  New layout for PayTrace. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'PayTrace.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'PayTrace.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS PayTrace.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'PayTrace.ConfigView', 'PayTrace', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'PayTrace.ConfigView'        ,  0, 'PayTrace.LBL_ENABLED'                      , 'Avaya.Enabled'                   , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'PayTrace.ConfigView'        ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  2, 'PayTrace.LBL_USER_NAME'                    , 'Avaya.UserName'                  , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'PayTrace.ConfigView'        ,  3, 'PayTrace.LBL_PASSWORD'                     , 'Avaya.Password'                  , 1, 1, 150, 35, null;
end -- if;
GO

-- 11/22/2020 Paul.  Add Dropdown editor support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Dropdown.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Dropdown.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Dropdown.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Dropdown.EditView', 'Dropdown', 'vwTERMINOLOGY', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Dropdown.EditView'          ,  1, 'Dropdown.LBL_DROPDOWN'                     , 'LIST_NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Dropdown.EditView'          ,  2, 'Dropdown.LBL_LANGUAGE'                     , 'LANG'                            , 1, 1, 'Languages', null, null, null;
end -- if;
GO

-- 11/22/2020 Paul.  Add Dropdown editor support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Dropdown.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Dropdown.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Dropdown.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Dropdown.SearchBasic', 'Dropdown', 'vwTERMINOLOGY', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Dropdown.SearchBasic'       ,  1, 'Dropdown.LBL_DROPDOWN'                     , 'LIST_NAME'                       , 1, 1, 'TerminologyPickLists', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Dropdown.SearchBasic'       ,  2, 'Dropdown.LBL_LANGUAGE'                     , 'LANG'                            , 1, 1, 'Languages', null, null, null;
end -- if;
GO

-- 01/30/2021 Paul.  Add EditCustomFields support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EditCustomFields.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'EditCustomFields.NewRecord', 'EditCustomFields', 'vwFIELDS_META_DATA', '30%', '70%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.NewRecord' ,  0, 'EditCustomFields.COLUMN_TITLE_NAME'           , 'NAME'                           , 1, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.NewRecord' ,  1, 'EditCustomFields.COLUMN_TITLE_LABEL'          , 'LABEL'                          , 1, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'EditCustomFields.NewRecord' ,  2, 'EditCustomFields.COLUMN_TITLE_DATA_TYPE'      , 'DATA_TYPE'                      , 1, 1, 'custom_field_type_dom', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.NewRecord' ,  3, 'EditCustomFields.COLUMN_TITLE_MAX_SIZE'       , 'MAX_SIZE'                       , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'EditCustomFields.NewRecord' ,  4, 'EditCustomFields.COLUMN_TITLE_REQUIRED_OPTION', 'REQUIRED'                       , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.NewRecord' ,  5, 'EditCustomFields.COLUMN_TITLE_DEFAULT_VALUE'  , 'DEFAULT_VALUE'                  , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'EditCustomFields.NewRecord' ,  6, 'EditCustomFields.LBL_DROPDOWN_LIST'           , 'DROPDOWN_LIST'                  , 1, 1, 'TerminologyPickLists', null, null, null
end -- if;
GO

-- 01/30/2021 Paul.  Add EditCustomFields support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EditCustomFields.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'EditCustomFields.EditView', 'EditCustomFields', 'vwFIELDS_META_DATA', '30%', '70%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'EditCustomFields.EditView'  ,  0, 'EditCustomFields.COLUMN_TITLE_NAME'           , 'NAME'                           , null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'EditCustomFields.EditView'  ,  1, 'EditCustomFields.COLUMN_TITLE_LABEL'          , 'LABEL'                          , null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'EditCustomFields.EditView'  ,  2, 'EditCustomFields.COLUMN_TITLE_DATA_TYPE'      , 'DATA_TYPE'                      , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.EditView'  ,  3, 'EditCustomFields.COLUMN_TITLE_MAX_SIZE'       , 'MAX_SIZE'                       , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'EditCustomFields.EditView'  ,  4, 'EditCustomFields.COLUMN_TITLE_REQUIRED_OPTION', 'REQUIRED'                       , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EditCustomFields.EditView'  ,  5, 'EditCustomFields.COLUMN_TITLE_DEFAULT_VALUE'  , 'DEFAULT_VALUE'                  , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'EditCustomFields.EditView'  ,  6, 'EditCustomFields.LBL_DROPDOWN_LIST'           , 'DROPDOWN_LIST'                  , 1, 1, 'TerminologyPickLists', null, null, null
end -- if;
GO

-- 11/22/2020 Paul.  Add Dropdown editor support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.RenameTabs';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Terminology.RenameTabs' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Terminology.RenameTabs';
	exec dbo.spEDITVIEWS_InsertOnly            'Terminology.RenameTabs', 'Terminology', 'vwMODULES_RenameTabs', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Terminology.RenameTabs'     ,  1, 'Dropdown.LBL_LANGUAGE'                       , 'LANG'                            , 1, 1, 'Languages', null, null, null;
end -- if;
GO

-- 03/24/2021 Paul.  Add CampaignEmailSettings support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'Campaigns.ConfigView', 'EditCustomFields', 'vwFIELDS_META_DATA', '30%', '70%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.ConfigView'       ,  0, 'EmailMan.LBL_EMAILS_PER_RUN'                 , 'massemailer_campaign_emails_per_run'        , 1, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsRadio       'Campaigns.ConfigView'       ,  1, 'EmailMan.LBL_LOCATION_TRACK'                 , 'massemailer_tracking_entities_location_type', 0, 1, 'tracking_entities_location_type', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.ConfigView'       ,  2, null                                          , 'massemailer_tracking_entities_location'     , 0, 1, 255, 35, null;
end -- if;
GO

-- 03/30/2021 Paul.  Add EmailMan support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMan.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailMan.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'EmailMan.SearchBasic', 'EmailMan', 'vwEMAILMAN_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.SearchBasic'       ,  0, 'EmailMan.LBL_LIST_CAMPAIGN'                 , 'CAMPAIGN_NAME'        , null, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.SearchBasic'       ,  1, 'EmailMan.LBL_LIST_RECIPIENT_NAME'           , 'RECIPIENT_NAME'       , null, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMan.SearchBasic'       ,  2, 'EmailMan.LBL_LIST_RECIPIENT_EMAIL'          , 'RECIPIENT_EMAIL'      , null, 1, 255, 35, null;
end -- if;
GO

-- 09/09/2021 Paul.  Add Updater support to React Client. 
-- delete from EDITVIEWS where NAME = 'Updater.EditView';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Updater.EditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Updater.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Updater.EditView';
	exec dbo.spEDITVIEWS_InsertOnly            'Updater.EditView', 'Updater', 'vwCONFIG_Edit', '30%', '70%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Updater.EditView'           ,  0, 'Administration.LBL_SEND_STAT'               , 'send_usage_info'        , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Updater.EditView'           ,  1, 'Administration.LBL_UPDATE_CHECK_TYPE'       , 'check_for_updates'      , 0, 1, null, null, null;
end -- if;
GO

-- 09/09/2021 Paul.  Add Undelete support to React Client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Undelete.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Undelete.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Undelete.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Undelete.SearchBasic', 'Undelete', 'vwCONFIG_Edit', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Undelete.SearchBasic'       ,  0, 'Undelete.LBL_NAME'                          , 'NAME'                   , null, null, 255, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Undelete.SearchBasic'       ,  1, 'Undelete.LBL_MODULE_NAME'                   , 'MODULE_NAME'            , null, null, 'AuditedModules', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Undelete.SearchBasic'       ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Undelete.SearchBasic'       ,  3, 'Undelete.LBL_AUDIT_TOKEN'                   , 'AUDIT_TOKEN'            , null, null, 255, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Undelete.SearchBasic'       ,  4, 'Undelete.LBL_MODIFIED_BY'                   , 'MODIFIED_USER_ID'       , null, null, 'ActiveUsers'   , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Undelete.SearchBasic'       ,  5, 'Undelete.LBL_AUDIT_DATE'                    , 'AUDIT_DATE'             , NULL, null, 'DateRange'     , null, null, null;
end -- if;
GO

-- 10/27/2021 Paul.  Administration.AdminWizard layout is used as a collection of values and not for layout purposes. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Company';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Company' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Configurator.AdminWizard.Company';
	exec dbo.spEDITVIEWS_InsertOnly            'Configurator.AdminWizard.Company', 'Configurator', 'vwCONFIG_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  0, 'Configurator.LBL_COMPANY_NAME'          , 'company_name'           , 0, 1, 255, 40, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  1, 'Configurator.LBL_HEADER_LOGO_IMAGE'     , 'header_logo_image'      , 0, 1, 255, 40, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  2, 'Configurator.LBL_HEADER_LOGO_WIDTH'     , 'header_logo_width'      , 0, 1, 255, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  3, 'Configurator.LBL_HEADER_LOGO_HEIGHT'    , 'header_logo_height'     , 0, 1, 255, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  4, 'Configurator.LBL_HEADER_LOGO_STYLE'     , 'header_logo_style'      , 0, 1, 255, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Company',  5, 'Configurator.LBL_ATLANTIC_HOME_IMAGE'   , 'header_home_image'      , 0, 1, 255, 40, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Locale';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Locale' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Configurator.AdminWizard.Locale';
	exec dbo.spEDITVIEWS_InsertOnly            'Configurator.AdminWizard.Locale' , 'Configurator', 'vwCONFIG_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Configurator.AdminWizard.Locale' ,  0, 'Users.LBL_LANGUAGE'                     , 'default_language'       , 0, 2, 'Languages'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Configurator.AdminWizard.Locale' ,  1, 'Users.LBL_CURRENCY'                     , 'default_currency'       , 0, 2, 'Currencies'      , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Configurator.AdminWizard.Locale' ,  2, 'Users.LBL_DATE_FORMAT'                  , 'default_date_format'    , 0, 2, 'DateFormat.en-US', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Configurator.AdminWizard.Locale' ,  3, 'Users.LBL_TIME_FORMAT'                  , 'default_language'       , 0, 2, 'TimeForamt.en-US', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Configurator.AdminWizard.Locale' ,  4, 'Users.LBL_TIMEZONE'                     , 'default_timezone'       , 0, 2, 'TimeZones'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Configurator.AdminWizard.Locale' ,  5, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Mail';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Configurator.AdminWizard.Mail' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Configurator.AdminWizard.Mail';
	exec dbo.spEDITVIEWS_InsertOnly            'Configurator.AdminWizard.Mail', 'Configurator', 'vwCONFIG_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Mail'  ,  0, 'EmailMan.LBL_NOTIFY_FROMNAME'           , 'fromname'               , 0, 3, 128, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Mail'  ,  1, 'EmailMan.LBL_NOTIFY_FROMADDRESS'        , 'fromaddress'            , 0, 3, 128, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Mail'  ,  2, 'EmailMan.LBL_MAIL_SMTPSERVER'           , 'smtpserver'             , 0, 3,  64, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Mail'  ,  3, 'EmailMan.LBL_MAIL_SMTPPORT'             , 'smtpport'               , 0, 3,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Configurator.AdminWizard.Mail'  ,  4, 'EmailMan.LBL_MAIL_SMTPAUTH_REQ'         , 'smtpauth_req'           , 0, 3, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'Configurator.AdminWizard.Mail'  ,  5, 'EmailMan.LBL_MAIL_SMTPSSL'              , 'smtpssl'                , 0, 3, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Configurator.AdminWizard.Mail'  ,  6, 'EmailMan.LBL_MAIL_SMTPUSER'             , 'smtpuser'               , 0, 3,  64, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsPassword    'Configurator.AdminWizard.Mail'  ,  7, 'EmailMan.LBL_MAIL_SMTPPASS'             , 'password'               , 0, 3,  64, 25, null;
end -- if;
GO

-- 12/26/2022 Paul.  Add support for Microsoft Teams. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'MicrosoftTeams.ConfigView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'MicrosoftTeams.ConfigView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS MicrosoftTeams.ConfigView';
	exec dbo.spEDITVIEWS_InsertOnly            'MicrosoftTeams.ConfigView', 'MicrosoftTeams', 'vwCONFIG_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'MicrosoftTeams.ConfigView' ,  0, 'MicrosoftTeams.LBL_MICROSOFTTEAMS_ENABLED'   , 'MicrosoftTeams.Enabled'           , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox    'MicrosoftTeams.ConfigView' ,  1, 'MicrosoftTeams.LBL_VERBOSE_STATUS'           , 'MicrosoftTeams.VerboseStatus'     , 0, 1, null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  2, 'MicrosoftTeams.LBL_OAUTH_DIRECTORY_TENANT_ID', 'MicrosoftTeams.DirectoryTenantID' , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'MicrosoftTeams.ConfigView' ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  4, 'MicrosoftTeams.LBL_OAUTH_CLIENT_ID'          , 'MicrosoftTeams.ClientID'          , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  5, 'MicrosoftTeams.LBL_OAUTH_ACCESS_TOKEN'       , 'MicrosoftTeams.OAuthAccessToken'  , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  6, 'MicrosoftTeams.LBL_OAUTH_CLIENT_SECRET'      , 'MicrosoftTeams.ClientSecret'      , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'MicrosoftTeams.ConfigView' ,  7, 'MicrosoftTeams.LBL_OAUTH_REFRESH_TOKEN'      , 'MicrosoftTeams.OAuthRefreshToken' , 0, 1, 150, 35, null;
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

call dbo.spEDITVIEWS_FIELDS_Admin()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_Admin')
/

-- #endif IBM_DB2 */


