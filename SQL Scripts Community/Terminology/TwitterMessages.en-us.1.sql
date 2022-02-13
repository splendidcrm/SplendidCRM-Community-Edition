

print 'TERMINOLOGY TwitterMessages en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'TwitterMessages' or NAME = 'TwitterMessages';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_ID'                                , N'en-US', N'TwitterMessages', null, null, N'Twitter ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_USER_ID'                           , N'en-US', N'TwitterMessages', null, null, N'Twitter User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_FULL_NAME'                         , N'en-US', N'TwitterMessages', null, null, N'Twitter Full Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_SCREEN_NAME'                       , N'en-US', N'TwitterMessages', null, null, N'Twitter Screen Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_START'                                , N'en-US', N'TwitterMessages', null, null, N'Date Sent:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'TwitterMessages', null, null, N'Message:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_ID'                                 , N'en-US', N'TwitterMessages', null, null, N'Parent ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_NAME'                               , N'en-US', N'TwitterMessages', null, null, N'Parent Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_TYPE'                               , N'en-US', N'TwitterMessages', null, null, N'Parent Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'TwitterMessages', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TYPE'                                      , N'en-US', N'TwitterMessages', null, null, N'Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_RETWEET'                                , N'en-US', N'TwitterMessages', null, null, N'Retweet:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORIGINAL_ID'                               , N'en-US', N'TwitterMessages', null, null, N'Original ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORIGINAL_USER_ID'                          , N'en-US', N'TwitterMessages', null, null, N'Original User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORIGINAL_FULL_NAME'                        , N'en-US', N'TwitterMessages', null, null, N'Original Full Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORIGINAL_SCREEN_NAME'                      , N'en-US', N'TwitterMessages', null, null, N'Original Screen Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'TwitterMessages', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_TEXT'                               , N'en-US', N'TwitterMessages', null, null, N'Search Text:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TWITTER_ID'                           , N'en-US', N'TwitterMessages', null, null, N'Twitter ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TWITTER_USER_ID'                      , N'en-US', N'TwitterMessages', null, null, N'User ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TWITTER_FULL_NAME'                    , N'en-US', N'TwitterMessages', null, null, N'Full Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TWITTER_SCREEN_NAME'                  , N'en-US', N'TwitterMessages', null, null, N'Screen Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_START'                           , N'en-US', N'TwitterMessages', null, null, N'Date Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'TwitterMessages', null, null, N'Message';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_ID'                            , N'en-US', N'TwitterMessages', null, null, N'Parent ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_NAME'                          , N'en-US', N'TwitterMessages', null, null, N'Parent Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PARENT_TYPE'                          , N'en-US', N'TwitterMessages', null, null, N'Parent Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RELATED_TO'                           , N'en-US', N'TwitterMessages', null, null, N'Related To';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'TwitterMessages', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TYPE'                                 , N'en-US', N'TwitterMessages', null, null, N'Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_RETWEET'                           , N'en-US', N'TwitterMessages', null, null, N'Retweet';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORIGINAL_ID'                          , N'en-US', N'TwitterMessages', null, null, N'Original ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORIGINAL_USER_ID'                     , N'en-US', N'TwitterMessages', null, null, N'Original User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORIGINAL_FULL_NAME'                   , N'en-US', N'TwitterMessages', null, null, N'Original Full';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORIGINAL_SCREEN_NAME'                 , N'en-US', N'TwitterMessages', null, null, N'Original Screen';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'TwitterMessages', null, null, N'Description';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_RETWEET'                            , N'en-US', N'TwitterMessages', null, null, N'Retweet';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SEND'                               , N'en-US', N'TwitterMessages', null, null, N'Send';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SIGNIN'                             , N'en-US', N'TwitterMessages', null, null, N'Sign In';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SIGNOUT'                            , N'en-US', N'TwitterMessages', null, null, N'Sign Out';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BUTTON_SEARCH'                             , N'en-US', N'TwitterMessages', null, null, N'Search';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'TwitterMessages', null, null, N'Sent Tweets';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_TWITTER_MESSAGE'                       , N'en-US', N'TwitterMessages', null, null, N'Send Tweet';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_TWITTER_MESSAGES_LIST'                     , N'en-US', N'TwitterMessages', null, null, N'Tweets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'TwitterMessages', null, null, N'Tweets';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'TwitterMessages', null, null, N'TwM';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INBOUND_TITLE'                             , N'en-US', N'TwitterMessages', null, null, N'Inbound Tweet';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_SENT_TITLE'                      , N'en-US', N'TwitterMessages', null, null, N'Sent Tweets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'TwitterMessages', null, null, N'Tweets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOT_SENT'                                  , N'en-US', N'TwitterMessages', null, null, N'Message not sent.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_MESSAGE'                           , N'en-US', N'TwitterMessages', null, null, N'Invalid message format.';

-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVED_TWITTER_MESSAGES'                 , N'en-US', N'TwitterMessages', null, null, N'Archived Tweets';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'TwitterMessages'                               , N'en-US', null, N'moduleList'                        , 121, N'Tweets';
exec dbo.spTERMINOLOGY_InsertOnly N'TwitterMessages'                               , N'en-US', null, N'moduleListSingular'                , 121, N'Tweet';

exec dbo.spTERMINOLOGY_InsertOnly N'draft'                                         , N'en-US', null, N'dom_twitter_status'                ,   1, N'In Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'read'                                          , N'en-US', null, N'dom_twitter_status'                ,   2, N'Read';
exec dbo.spTERMINOLOGY_InsertOnly N'replied'                                       , N'en-US', null, N'dom_twitter_status'                ,   3, N'Replied';
exec dbo.spTERMINOLOGY_InsertOnly N'sent'                                          , N'en-US', null, N'dom_twitter_status'                ,   4, N'Sent';
exec dbo.spTERMINOLOGY_InsertOnly N'unread'                                        , N'en-US', null, N'dom_twitter_status'                ,   5, N'Unread';
exec dbo.spTERMINOLOGY_InsertOnly N'received'                                      , N'en-US', null, N'dom_twitter_status'                ,   6, N'Received';
exec dbo.spTERMINOLOGY_InsertOnly N'retweet'                                       , N'en-US', null, N'dom_twitter_status'                ,   7, N'Retweet';
exec dbo.spTERMINOLOGY_InsertOnly N'send_error'                                    , N'en-US', null, N'dom_twitter_status'                ,   8, N'Send Error';

exec dbo.spTERMINOLOGY_InsertOnly N'out'                                           , N'en-US', null, N'dom_twitter_types'                 ,   1, N'Send';
exec dbo.spTERMINOLOGY_InsertOnly N'draft'                                         , N'en-US', null, N'dom_twitter_types'                 ,   2, N'Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'inbound'                                       , N'en-US', null, N'dom_twitter_types'                 ,   3, N'Inbound';
exec dbo.spTERMINOLOGY_InsertOnly N'sent'                                          , N'en-US', null, N'dom_twitter_types'                 ,   4, N'Sent';

-- 03/16/2016  Paul.  Add to list of activities. 
exec dbo.spTERMINOLOGY_InsertOnly N'TwitterMessages'                               , N'en-US', null, N'activity_dom'                      ,   7, N'Tweet';
exec dbo.spTERMINOLOGY_InsertOnly N'TwitterMessages'                               , N'en-US', null, N'activities_dom'                    ,   7, N'Tweets';
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

call dbo.spTERMINOLOGY_TwitterMessages_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_TwitterMessages_en_us')
/
-- #endif IBM_DB2 */
