

print 'TERMINOLOGY ChatChannels en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'ChatChannels', null, null, N'Chat Channels';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'ChatChannels', null, null, N'New Chat Channel';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CHAT_CHANNEL_LIST'                         , N'en-US', N'ChatChannels', null, null, N'Chat Channels';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CHAT_CHANNEL'                          , N'en-US', N'ChatChannels', null, null, N'Create Chat Channel';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ATTACHMENTS'                               , N'en-US', N'ChatChannels', null, null, N'Attachments';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ChatChannels', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'ChatChannels', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_CHAT_CHANNELS'                     , N'en-US', N'ChatChannels', null, null, N'My Chat Channels';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_TEAM_CHAT_CHANNELS'                , N'en-US', N'ChatChannels', null, null, N'My Team Chat Channels';
-- 07/31/2017 Paul.  Add My Favorite dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_FAVORITE_CHAT_CHANNELS'            , N'en-US', N'ChatChannels', null, null, N'My Favorite Chat Channels';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ChatChannels', null, null, N'ChC';

exec dbo.spTERMINOLOGY_InsertOnly N'ChatChannels'                                  , N'en-US', null, N'moduleList', 118, N'Chat Channels';
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

call dbo.spTERMINOLOGY_ChatChannels_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ChatChannels_en_us')
/
-- #endif IBM_DB2 */

