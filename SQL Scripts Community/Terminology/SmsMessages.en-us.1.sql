

print 'TERMINOLOGY SmsMessages en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'SmsMessages' or NAME = 'SmsMessages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_NUMBER'                               , N'en-US', N'SmsMessages', null, null, N'From Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TO_NUMBER'                                 , N'en-US', N'SmsMessages', null, null, N'To Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_LOCATION'                             , N'en-US', N'SmsMessages', null, null, N'From Location:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TO_LOCATION'                               , N'en-US', N'SmsMessages', null, null, N'To Location:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_START'                                , N'en-US', N'SmsMessages', null, null, N'Date Sent:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'SmsMessages', null, null, N'Message:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ATTACHMENT'                                , N'en-US', N'SmsMessages', null, null, N'Attachment:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX_ID'                                , N'en-US', N'SmsMessages', null, null, N'Mailbox ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX_NAME'                              , N'en-US', N'SmsMessages', null, null, N'Mailbox Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSAGE_ID'                                , N'en-US', N'SmsMessages', null, null, N'Message ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSAGE_NAME'                              , N'en-US', N'SmsMessages', null, null, N'Message Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_ID'                                 , N'en-US', N'SmsMessages', null, null, N'Parent ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_NAME'                               , N'en-US', N'SmsMessages', null, null, N'Parent Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_TYPE'                               , N'en-US', N'SmsMessages', null, null, N'Parent Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'SmsMessages', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TYPE'                                      , N'en-US', N'SmsMessages', null, null, N'Type:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FROM_NUMBER'                          , N'en-US', N'SmsMessages', null, null, N'From Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TO_NUMBER'                            , N'en-US', N'SmsMessages', null, null, N'To Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_START'                           , N'en-US', N'SmsMessages', null, null, N'Date Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'SmsMessages', null, null, N'Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ATTACHMENT'                           , N'en-US', N'SmsMessages', null, null, N'Attachment';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAILBOX_ID'                           , N'en-US', N'SmsMessages', null, null, N'Mailbox ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAILBOX_NAME'                         , N'en-US', N'SmsMessages', null, null, N'Mailbox Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSAGE_ID'                           , N'en-US', N'SmsMessages', null, null, N'Message ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSAGE_NAME'                         , N'en-US', N'SmsMessages', null, null, N'Message Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_ID'                            , N'en-US', N'SmsMessages', null, null, N'Parent ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_NAME'                          , N'en-US', N'SmsMessages', null, null, N'Parent Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_TYPE'                          , N'en-US', N'SmsMessages', null, null, N'Parent Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RELATED_TO'                           , N'en-US', N'SmsMessages', null, null, N'Related To';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'SmsMessages', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TYPE'                                 , N'en-US', N'SmsMessages', null, null, N'Type';

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NOT_ADDRESSED'                             , N'en-US', N'SmsMessages', null, null, N'Not Addressed.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_FORWARD'                            , N'en-US', N'SmsMessages', null, null, N'Forward';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_REPLY'                              , N'en-US', N'SmsMessages', null, null, N'Reply';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SAVE_AS_DRAFT'                      , N'en-US', N'SmsMessages', null, null, N'Save As Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SEND'                               , N'en-US', N'SmsMessages', null, null, N'Send';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'SmsMessages', null, null, N'Sent Text Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_SMS_MESSAGE'                           , N'en-US', N'SmsMessages', null, null, N'Send Text Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SMS_MESSAGES_LIST'                         , N'en-US', N'SmsMessages', null, null, N'Text Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'SmsMessages', null, null, N'Text Messages';
-- 06/04/2015 Paul.  Add module abbreviation. 
-- delete from TERMINOLOGY where NAME = 'LBL_MODULE_ABBREVIATION' and MODULE_NAME = 'SmsMessages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'SmsMessages', null, null, N'Txt';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INBOUND_TITLE'                             , N'en-US', N'SmsMessages', null, null, N'Inbound Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_SMS_MESSAGES'                      , N'en-US', N'SmsMessages', null, null, N'My Text Messages';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_TEAM_SMS_MESSAGES'                 , N'en-US', N'SmsMessages', null, null, N'My Team Text Messages';
-- 07/31/2017 Paul.  Add My Favorite dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_FAVORITE_SMS_MESSAGES'             , N'en-US', N'SmsMessages', null, null, N'My Favorite Text Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_SENT_TITLE'                      , N'en-US', N'SmsMessages', null, null, N'Sent Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'SmsMessages', null, null, N'Message List';

-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVED_SMS_MESSAGES'                     , N'en-US', N'SmsMessages', null, null, N'Archived Text Messages';
-- 06/18/2023 Paul.  Add missing term. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_FILE'                                  , N'en-US', N'SmsMessages', null, null, N'Attach File';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'SmsMessages'                                   , N'en-US', null, N'moduleList'                        , 120, N'Text Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'SmsMessages'                                   , N'en-US', null, N'moduleListSingular'                , 120, N'Text Message';

exec dbo.spTERMINOLOGY_InsertOnly N'archived'                                      , N'en-US', null, N'dom_sms_status'                    ,   1, N'Archived';
exec dbo.spTERMINOLOGY_InsertOnly N'closed'                                        , N'en-US', null, N'dom_sms_status'                    ,   2, N'Closed';
exec dbo.spTERMINOLOGY_InsertOnly N'draft'                                         , N'en-US', null, N'dom_sms_status'                    ,   3, N'In Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'read'                                          , N'en-US', null, N'dom_sms_status'                    ,   4, N'Read';
exec dbo.spTERMINOLOGY_InsertOnly N'replied'                                       , N'en-US', null, N'dom_sms_status'                    ,   5, N'Replied';
exec dbo.spTERMINOLOGY_InsertOnly N'sent'                                          , N'en-US', null, N'dom_sms_status'                    ,   6, N'Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'send error'                                    , N'en-US', null, N'dom_sms_status'                    ,   7, N'Send error';
exec dbo.spTERMINOLOGY_InsertOnly N'unread'                                        , N'en-US', null, N'dom_sms_status'                    ,   8, N'Unread';
exec dbo.spTERMINOLOGY_InsertOnly N'received'                                      , N'en-US', null, N'dom_sms_status'                    ,  10, N'Received';

exec dbo.spTERMINOLOGY_InsertOnly N'out'                                           , N'en-US', null, N'dom_sms_types'                     ,   1, N'Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'archived'                                      , N'en-US', null, N'dom_sms_types'                     ,   2, N'Archived';
exec dbo.spTERMINOLOGY_InsertOnly N'draft'                                         , N'en-US', null, N'dom_sms_types'                     ,   3, N'Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'inbound'                                       , N'en-US', null, N'dom_sms_types'                     ,   4, N'Inbound';
exec dbo.spTERMINOLOGY_InsertOnly N'campaign'                                      , N'en-US', null, N'dom_sms_types'                     ,   5, N'Campaign';
exec dbo.spTERMINOLOGY_InsertOnly N'sent'                                          , N'en-US', null, N'dom_sms_types'                     ,   6, N'Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'partial'                                       , N'en-US', null, N'dom_sms_types'                     ,   7, N'Partially sent';

-- delete from TERMINOLOGY where LIST_NAME in ('dom_sms_opt_in', 'dom_sms_opt_in_search');
exec dbo.spTERMINOLOGY_InsertOnly N'yes'                                           , N'en-US', null, N'dom_sms_opt_in'                    ,   1, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N'no'                                            , N'en-US', null, N'dom_sms_opt_in'                    ,   2, N'No';

exec dbo.spTERMINOLOGY_InsertOnly N'yes'                                           , N'en-US', null, N'dom_sms_opt_in_search'             ,   1, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N''                                              , N'en-US', null, N'dom_sms_opt_in_search'             ,   2, N'Unspecified';
exec dbo.spTERMINOLOGY_InsertOnly N'no'                                            , N'en-US', null, N'dom_sms_opt_in_search'             ,   3, N'No';

-- 03/16/2016  Paul.  Add to list of activities. 
exec dbo.spTERMINOLOGY_InsertOnly N'SmsMessages'                                   , N'en-US', null, N'activity_dom'                      ,   6, N'Text Message';
exec dbo.spTERMINOLOGY_InsertOnly N'SmsMessages'                                   , N'en-US', null, N'activities_dom'                    ,   6, N'Text Messages';
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

call dbo.spTERMINOLOGY_SmsMessages_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_SmsMessages_en_us')
/
-- #endif IBM_DB2 */
