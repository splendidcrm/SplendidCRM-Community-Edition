

print 'TERMINOLOGY ChatMessages en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'ChatMessages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'ChatMessages', null, null, N'Chat Messages';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ChatMessages', null, null, N'ChM';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'ChatMessages', null, null, N'Chat Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CHAT_MESSAGE_LIST'                         , N'en-US', N'ChatMessages', null, null, N'Chat Messages';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CHAT_MESSAGE'                          , N'en-US', N'ChatMessages', null, null, N'Create New Message';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ChatMessages', null, null, N'Message:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'ChatMessages', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHAT_CHANNEL_ID'                           , N'en-US', N'ChatMessages', null, null, N'Chat Channel:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHAT_CHANNEL_NAME'                         , N'en-US', N'ChatMessages', null, null, N'Chat Channel:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'ChatMessages', null, null, N'Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_NAME'                          , N'en-US', N'ChatMessages', null, null, N'Related';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'ChatMessages', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CHAT_CHANNEL_NAME'                    , N'en-US', N'ChatMessages', null, null, N'Chat Channel';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_NAME'                               , N'en-US', N'ChatMessages', null, null, N'Related:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPLOAD_FILE'                               , N'en-US', N'ChatMessages', null, null, N'Upload File:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHAT_INCOMING_MESSAGE'                     , N'en-US', N'ChatMessages', null, null, N'Chat Incoming Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHAT_INCOMING_MESSAGE_TEMPLATE'            , N'en-US', N'ChatMessages', null, null, N'New incoming chat from {0}: {1}';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ATTACHMENT'                                , N'en-US', N'ChatMessages', null, null, N'Chat Attachment: ';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVED_CHAT_MESSAGES'                    , N'en-US', N'ChatMessages', null, null, N'Archived ChatMessages';

exec dbo.spTERMINOLOGY_InsertOnly N'ChatMessages'                                  , N'en-US', null, N'moduleList', 119, N'Chat Messages';
-- 03/16/2016  Paul.  Add to list of activities. 
exec dbo.spTERMINOLOGY_InsertOnly N'ChatMessages'                                  , N'en-US', null, N'activity_dom',   8, N'Chat Message';
exec dbo.spTERMINOLOGY_InsertOnly N'ChatMessages'                                  , N'en-US', null, N'activities_dom', 8, N'Chat Messages';
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

call dbo.spTERMINOLOGY_ChatMessages_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ChatMessages_en_us')
/
-- #endif IBM_DB2 */

