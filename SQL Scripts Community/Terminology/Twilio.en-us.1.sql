

print 'TERMINOLOGY Twilio en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Twilio';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_TITLE'                              , N'en-US', N'Twilio', null, null, N'Twilio';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_SETTINGS'                           , N'en-US', N'Twilio', null, null, N'Twilio Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_SETTINGS_DESC'                      , N'en-US', N'Twilio', null, null, N'Configure Twilio settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_MESSAGES'                           , N'en-US', N'Twilio', null, null, N'Twilio Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_MESSAGES_DESC'                      , N'en-US', N'Twilio', null, null, N'Search Twilio Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT_SID'                               , N'en-US', N'Twilio', null, null, N'Account SID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUTH_TOKEN'                                , N'en-US', N'Twilio', null, null, N'Auth Token:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_PHONE'                                , N'en-US', N'Twilio', null, null, N'From Phone:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOG_INBOUND_MESSAGES'                      , N'en-US', N'Twilio', null, null, N'Log Inbound Messages:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSAGE_REQUEST_URL'                       , N'en-US', N'Twilio', null, null, N'Messaging Request URL:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_BUTTON_LABEL'                         , N'en-US', N'Twilio', null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONNECTION_SUCCESSFUL'                     , N'en-US', N'Twilio', null, null, N'Connection successful';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FAILED_TO_CONNECT'                         , N'en-US', N'Twilio', null, null, N'Failed to connect: {0}';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Twilio', null, null, N'Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Twilio', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_SENT'                                 , N'en-US', N'Twilio', null, null, N'Date Sent:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_NUMBER'                               , N'en-US', N'Twilio', null, null, N'From Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TO_NUMBER'                                 , N'en-US', N'Twilio', null, null, N'To Number:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_CREATE_MESSAGE'                     , N'en-US', N'Twilio', null, null, N'Twilio Create Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWILIO_INCOMING_MESSAGE'                   , N'en-US', N'Twilio', null, null, N'Twilio Incoming Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_INCOMING_MESSAGE_TEMPLATE'             , N'en-US', N'Twilio', null, null, N'New incoming call from {0}: {1}';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Twilio', null, null, N'Twl';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Twilio'                                        , N'en-US', null, N'moduleList', 117, N'Twilio';
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

call dbo.spTERMINOLOGY_Twilio_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Twilio_en_us')
/
-- #endif IBM_DB2 */
