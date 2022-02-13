

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Feeds en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_FAV_BUTTON_LABEL'                      , N'en-US', N'Feeds', null, null, N'Add to favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_FAV_BUTTON_TITLE'                      , N'en-US', N'Feeds', null, null, N'Add to favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_FAV_BUTTON_LABEL'                   , N'en-US', N'Feeds', null, null, N'Delete from favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_FAV_BUTTON_TITLE'                   , N'en-US', N'Feeds', null, null, N'Delete from favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Feeds', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_UPDATED'                              , N'en-US', N'Feeds', null, null, N'Last Updated';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Feeds', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Feeds', null, null, N'Feed List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TITLE'                                , N'en-US', N'Feeds', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_URL'                                  , N'en-US', N'Feeds', null, null, N'URL';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MOVE_DOWN'                                 , N'en-US', N'Feeds', null, null, N'Move Down';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MOVE_UP'                                   , N'en-US', N'Feeds', null, null, N'Move Up';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_LIST_FORM_TITLE'                        , N'en-US', N'Feeds', null, null, N'My List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Feeds', null, null, N'Create Feed';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RANK'                                      , N'en-US', N'Feeds', null, null, N'Rank:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RSS_URL'                                   , N'en-US', N'Feeds', null, null, N'Rss Url';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TITLE'                                     , N'en-US', N'Feeds', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_URL'                                       , N'en-US', N'Feeds', null, null, N'URL:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VISIT_WEBSITE'                             , N'en-US', N'Feeds', null, null, N'Visit Website';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_FEED_LIST'                                 , N'en-US', N'Feeds', null, null, N'Feeds';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_MY_FEED_LIST'                              , N'en-US', N'Feeds', null, null, N'My Feed List';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_FEED'                                  , N'en-US', N'Feeds', null, null, N'Create Feed';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Feeds', null, null, N'Fds';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Feeds'                                         , N'en-US', null, N'moduleList'                        ,  16, N'RSS';
exec dbo.spTERMINOLOGY_InsertOnly N'Feeds'                                         , N'en-US', null, N'moduleListSingular'                ,  16, N'RS';
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

call dbo.spTERMINOLOGY_Feeds_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Feeds_en_us')
/
-- #endif IBM_DB2 */
