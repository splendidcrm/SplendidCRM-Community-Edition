

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY InboundEmail en-us';
GO

set nocount on;
GO

-- 03/28/2019 Paul.  Every module should have a LBL_NEW_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'InboundEmail', null, null, N'Inbound Email';
-- 01/18/2021 Paul.  LBL_LIST_FORM_TITLE is needed for the React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'InboundEmail', null, null, N'Inbound Email List';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUTOREPLY'                                 , N'en-US', N'InboundEmail', null, null, N'Autoreply';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BASIC'                                     , N'en-US', N'InboundEmail', null, null, N'Basic';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_NEW_GROUP'                          , N'en-US', N'InboundEmail', null, null, N'Create New Group';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_SEEN'                               , N'en-US', N'InboundEmail', null, null, N'Delete Seen:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_OPTIONS'                             , N'en-US', N'InboundEmail', null, null, N'Email Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_PASSWORD'                            , N'en-US', N'InboundEmail', null, null, N'Email Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_USER'                                , N'en-US', N'InboundEmail', null, null, N'Email User:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FILTER_DOMAIN'                             , N'en-US', N'InboundEmail', null, null, N'Filter Domain:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_ADDR'                                 , N'en-US', N'InboundEmail', null, null, N'From Email Address:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_NAME'                                 , N'en-US', N'InboundEmail', null, null, N'From Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_ID'                                  , N'en-US', N'InboundEmail', null, null, N'Group ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_NAME'                                , N'en-US', N'InboundEmail', null, null, N'Group Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_QUEUE'                               , N'en-US', N'InboundEmail', null, null, N'Group Queue';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DELETE_SEEN'                          , N'en-US', N'InboundEmail', null, null, N'Delete Seen';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMAIL_PASSWORD'                       , N'en-US', N'InboundEmail', null, null, N'Email Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMAIL_USER'                           , N'en-US', N'InboundEmail', null, null, N'Email User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FILTER_DOMAIN'                        , N'en-US', N'InboundEmail', null, null, N'Filter Domain';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FROM_ADDR'                            , N'en-US', N'InboundEmail', null, null, N'From Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FROM_NAME'                            , N'en-US', N'InboundEmail', null, null, N'From Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_GROUP_ID'                             , N'en-US', N'InboundEmail', null, null, N'Group ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_GROUP_NAME'                           , N'en-US', N'InboundEmail', null, null, N'Group Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAILBOX'                              , N'en-US', N'InboundEmail', null, null, N'Mailbox';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAILBOX_SSL'                          , N'en-US', N'InboundEmail', null, null, N'Use SSL';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAILBOX_TYPE'                         , N'en-US', N'InboundEmail', null, null, N'Mailbox Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'InboundEmail', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ONLY_SINCE'                           , N'en-US', N'InboundEmail', null, null, N'Only Since';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PORT'                                 , N'en-US', N'InboundEmail', null, null, N'Port';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SERVER_URL'                           , N'en-US', N'InboundEmail', null, null, N'Mail Server';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SERVICE'                              , N'en-US', N'InboundEmail', null, null, N'Service';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'InboundEmail', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STORED_OPTIONS'                       , N'en-US', N'InboundEmail', null, null, N'Stored Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEMPLATE_ID'                          , N'en-US', N'InboundEmail', null, null, N'Template ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEMPLATE_NAME'                        , N'en-US', N'InboundEmail', null, null, N'Template Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN'                                     , N'en-US', N'InboundEmail', null, null, N'Login';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX'                                   , N'en-US', N'InboundEmail', null, null, N'Mailbox:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX_DEFAULT'                           , N'en-US', N'InboundEmail', null, null, N'Mailbox Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX_SSL'                               , N'en-US', N'InboundEmail', null, null, N'Use SSL:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILBOX_TYPE'                              , N'en-US', N'InboundEmail', null, null, N'Mailbox Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MARK_READ'                                 , N'en-US', N'InboundEmail', null, null, N'Mark Read';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'InboundEmail', null, null, N'Inbound Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'InboundEmail', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ONLY_SINCE'                                , N'en-US', N'InboundEmail', null, null, N'Only Since:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD'                                  , N'en-US', N'InboundEmail', null, null, N'Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PORT'                                      , N'en-US', N'InboundEmail', null, null, N'Port:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SERVER_OPTIONS'                            , N'en-US', N'InboundEmail', null, null, N'Server Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SERVER_TYPE'                               , N'en-US', N'InboundEmail', null, null, N'Server Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SERVER_URL'                                , N'en-US', N'InboundEmail', null, null, N'Mail Server:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SERVICE'                                   , N'en-US', N'InboundEmail', null, null, N'Service:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'InboundEmail', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STORED_OPTIONS'                            , N'en-US', N'InboundEmail', null, null, N'Stored Options:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEMPLATE_ID'                               , N'en-US', N'InboundEmail', null, null, N'Template ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEMPLATE_NAME'                             , N'en-US', N'InboundEmail', null, null, N'Template Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_CREATE_NEW'                           , N'en-US', N'InboundEmail', null, null, N'Create Mailbox';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_MAILBOXES'                            , N'en-US', N'InboundEmail', null, null, N'All Mailboxes';

-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPLY_TO_ADDR'                             , N'en-US', N'InboundEmail', null, null, N'Reply-To Address:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPLY_TO_NAME'                             , N'en-US', N'InboundEmail', null, null, N'Reply-To Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REPLY_TO_ADDR'                        , N'en-US', N'InboundEmail', null, null, N'Reply-To Address';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REPLY_TO_NAME'                        , N'en-US', N'InboundEmail', null, null, N'Reply-To Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_TEAM'                                , N'en-US', N'InboundEmail', null, null, N'Group Team:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_GROUP_TEAM'                           , N'en-US', N'InboundEmail', null, null, N'Group Team';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'InboundEmail', null, null, N'Inb';

-- 03/27/2021 Paul.  React client needs feedback. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHECKING_MAIL'                             , N'en-US', N'InboundEmail', null, null, N'Checking mail . . .';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPERATION_COMPLETE'                        , N'en-US', N'InboundEmail', null, null, N'Operation complete.';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'InboundEmail'                                  , N'en-US', null, N'moduleList'                        ,  57, N'Inbound Email';

exec dbo.spTERMINOLOGY_InsertOnly N'pop3'                                          , N'en-US', null, N'dom_email_server_type'             ,   1, N'POP3';
exec dbo.spTERMINOLOGY_InsertOnly N'imap'                                          , N'en-US', null, N'dom_email_server_type'             ,   2, N'IMAP';

exec dbo.spTERMINOLOGY_InsertOnly N'pick'                                          , N'en-US', null, N'dom_mailbox_type'                  ,   1, N'Create [Any]';
exec dbo.spTERMINOLOGY_InsertOnly N'bug'                                           , N'en-US', null, N'dom_mailbox_type'                  ,   2, N'Create Bug';
exec dbo.spTERMINOLOGY_InsertOnly N'support'                                       , N'en-US', null, N'dom_mailbox_type'                  ,   3, N'Create Case';
exec dbo.spTERMINOLOGY_InsertOnly N'contact'                                       , N'en-US', null, N'dom_mailbox_type'                  ,   4, N'Create Contact';
exec dbo.spTERMINOLOGY_InsertOnly N'sales'                                         , N'en-US', null, N'dom_mailbox_type'                  ,   5, N'Create Lead';
exec dbo.spTERMINOLOGY_InsertOnly N'task'                                          , N'en-US', null, N'dom_mailbox_type'                  ,   6, N'Create Task';
exec dbo.spTERMINOLOGY_InsertOnly N'bounce'                                        , N'en-US', null, N'dom_mailbox_type'                  ,   7, N'Bounce Handling';
-- 09/09/2014 Paul.  Create a general inbox type. 
exec dbo.spTERMINOLOGY_InsertOnly N'inbox'                                         , N'en-US', null, N'dom_mailbox_type'                  ,   8, N'General Inbox';

exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'user_status_dom'                   ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Inactive'                                      , N'en-US', null, N'user_status_dom'                   ,   2, N'Inactive';
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

call dbo.spTERMINOLOGY_InboundEmail_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_InboundEmail_en_us')
/
-- #endif IBM_DB2 */
