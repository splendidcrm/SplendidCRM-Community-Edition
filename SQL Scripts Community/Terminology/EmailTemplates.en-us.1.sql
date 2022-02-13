

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY EmailTemplates en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_EMAIL_TEMPLATE_NOT_FOUND'                  , N'en-US', N'EmailTemplates', null, null, N'Email Template Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BODY'                                      , N'en-US', N'EmailTemplates', null, null, N'Body:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BODY_HTML'                                 , N'en-US', N'EmailTemplates', null, null, N'Body:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTACT_AND_OTHERS'                        , N'en-US', N'EmailTemplates', null, null, N'Contact/Lead/Target';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_LINK_TEXT'                         , N'en-US', N'EmailTemplates', null, null, N'Default Link Text';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'EmailTemplates', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_ATTACHMENT'                          , N'en-US', N'EmailTemplates', null, null, N'Email Attachment';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSERT'                                    , N'en-US', N'EmailTemplates', null, null, N'Insert';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSERT_TRACKER_URL'                        , N'en-US', N'EmailTemplates', null, null, N'Insert Tracker Url:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSERT_URL_REF'                            , N'en-US', N'EmailTemplates', null, null, N'Insert URL Reference';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSERT_VARIABLE'                           , N'en-US', N'EmailTemplates', null, null, N'Insert Variable:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_BODY'                                 , N'en-US', N'EmailTemplates', null, null, N'Body';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_BODY_HTML'                            , N'en-US', N'EmailTemplates', null, null, N'Body';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'EmailTemplates', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'EmailTemplates', null, null, N'Email Template List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'EmailTemplates', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PUBLISHED'                            , N'en-US', N'EmailTemplates', null, null, N'Published';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_READ_ONLY'                            , N'en-US', N'EmailTemplates', null, null, N'Read Only';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SUBJECT'                              , N'en-US', N'EmailTemplates', null, null, N'Subject';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEXT_ONLY'                            , N'en-US', N'EmailTemplates', null, null, N'Text Only';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'EmailTemplates', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PUBLISHED'                                 , N'en-US', N'EmailTemplates', null, null, N'Published:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_READ_ONLY'                                 , N'en-US', N'EmailTemplates', null, null, N'Read Only:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBJECT'                                   , N'en-US', N'EmailTemplates', null, null, N'Subject:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEXT_ONLY'                                 , N'en-US', N'EmailTemplates', null, null, N'Text Only:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ALL_EMAIL_LIST'                            , N'en-US', N'EmailTemplates', null, null, N'All Emails';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DRAFTS_EMAIL_LIST'                         , N'en-US', N'EmailTemplates', null, null, N'All Draft Emails';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_EMAIL_TEMPLATE_LIST'                       , N'en-US', N'EmailTemplates', null, null, N'Email Templates';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ARCHIVE_EMAIL'                         , N'en-US', N'EmailTemplates', null, null, N'Create Archived Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_EMAIL_TEMPLATE'                        , N'en-US', N'EmailTemplates', null, null, N'Create Email Template';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_SEND_EMAIL'                            , N'en-US', N'EmailTemplates', null, null, N'Compose Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_VIEW_CALENDAR'                             , N'en-US', N'EmailTemplates', null, null, N'Today';
-- 08/02/2013 Paul.  Make it easy to insert a survey into an email template. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSERT_SURVEY'                             , N'en-US', N'EmailTemplates', null, null, N'Insert Survey:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_SURVEY'                             , N'en-US', N'EmailTemplates', null, null, N'Select Survey';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INCLUDE_CONTACT'                           , N'en-US', N'EmailTemplates', null, null, N'Include contact in survey';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'EmailTemplates', null, null, N'EmT';

-- 05/13/2020 Paul.  Create list for React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'Accounts'                                      , N'en-US', null, N'template_variable_module',  0, N'Account';
exec dbo.spTERMINOLOGY_InsertOnly N'Contacts'                                      , N'en-US', null, N'template_variable_module',  1, N'Contact/Lead/Target';
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'EmailTemplates'                                , N'en-US', null, N'moduleList'                        ,  31, N'Email Templates';
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

call dbo.spTERMINOLOGY_EmailTemplates_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_EmailTemplates_en_us')
/
-- #endif IBM_DB2 */
