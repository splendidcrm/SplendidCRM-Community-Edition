

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY EmailClient en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BCC'                                       , N'en-US', N'EmailClient', null, null, N'BCC:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BODY'                                      , N'en-US', N'EmailClient', null, null, N'Body:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CC'                                        , N'en-US', N'EmailClient', null, null, N'CC:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_RECEIVED'                             , N'en-US', N'EmailClient', null, null, N'Date Received:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_SENT'                                 , N'en-US', N'EmailClient', null, null, N'Date Sent:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_LOADING'                             , N'en-US', N'EmailClient', null, null, N'Loading...';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_QUICK_CREATE'                        , N'en-US', N'EmailClient', null, null, N'Quick Create';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FOLDER_TITLE'                              , N'en-US', N'EmailClient', null, null, N'{0} ({1} messages)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM'                                      , N'en-US', N'EmailClient', null, null, N'From:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADERS'                                   , N'en-US', N'EmailClient', null, null, N'Headers:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_BCC'                                  , N'en-US', N'EmailClient', null, null, N'BCC';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_BODY'                                 , N'en-US', N'EmailClient', null, null, N'Body';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CC'                                   , N'en-US', N'EmailClient', null, null, N'CC';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_RECEIVED'                        , N'en-US', N'EmailClient', null, null, N'Received';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_SENT'                            , N'en-US', N'EmailClient', null, null, N'Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'EmailClient', null, null, N'Email Client';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FROM'                                 , N'en-US', N'EmailClient', null, null, N'From';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_HEADERS'                              , N'en-US', N'EmailClient', null, null, N'Headers';
-- 08/15/2014 Paul.  Display image in popup. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMAGE'                                , N'en-US', N'EmailClient', null, null, N'Image';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSAGEID'                            , N'en-US', N'EmailClient', null, null, N'Message ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIORITY'                             , N'en-US', N'EmailClient', null, null, N'Priority';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SENDER'                               , N'en-US', N'EmailClient', null, null, N'Sender';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SIZE'                                 , N'en-US', N'EmailClient', null, null, N'Size';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SUBJECT'                              , N'en-US', N'EmailClient', null, null, N'Subject';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TO'                                   , N'en-US', N'EmailClient', null, null, N'To';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSAGEID'                                 , N'en-US', N'EmailClient', null, null, N'Message ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIORITY'                                  , N'en-US', N'EmailClient', null, null, N'Priority:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SENDER'                                    , N'en-US', N'EmailClient', null, null, N'Sender:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SETTINGS_BUTTON_LABEL'                     , N'en-US', N'EmailClient', null, null, N'Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SETTINGS_BUTTON_TITLE'                     , N'en-US', N'EmailClient', null, null, N'Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIZE'                                      , N'en-US', N'EmailClient', null, null, N'Size:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBJECT'                                   , N'en-US', N'EmailClient', null, null, N'Subject:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TO'                                        , N'en-US', N'EmailClient', null, null, N'To:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_EMAIL_LIST'                                , N'en-US', N'EmailClient', null, null, N'Email Client';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_EMAIL'                                 , N'en-US', N'EmailClient', null, null, N'New Email';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'EmailClient', null, null, N'EmC';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'EmailClient'                                   , N'en-US', null, N'moduleList'                        ,  86, N'Email Client';
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

call dbo.spTERMINOLOGY_EmailClient_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_EmailClient_en_us')
/
-- #endif IBM_DB2 */
