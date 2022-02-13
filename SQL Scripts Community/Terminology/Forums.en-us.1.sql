

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Forums en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NO_TOPICS'                                 , N'en-US', N'Forums', null, null, N'No Topics.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATEGORY'                                  , N'en-US', N'Forums', null, null, N'Topic:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Forums', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_THREAD_CREATED_BY'                    , N'en-US', N'Forums', null, null, N'Last Thread Created By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_THREAD_DATE_MODIFIED'                 , N'en-US', N'Forums', null, null, N'Last Thread Date Modified';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_THREAD_TITLE'                         , N'en-US', N'Forums', null, null, N'Last Thread Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CATEGORY'                             , N'en-US', N'Forums', null, null, N'Topic';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Forums', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Forums', null, null, N'Forum List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_THREAD_CREATED_BY'               , N'en-US', N'Forums', null, null, N'Post By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_THREAD_TITLE'                    , N'en-US', N'Forums', null, null, N'Last Thread';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_THREADANDPOSTCOUNT'                   , N'en-US', N'Forums', null, null, N'Posts';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_THREADCOUNT'                          , N'en-US', N'Forums', null, null, N'Threads';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TITLE'                                , N'en-US', N'Forums', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_THREADANDPOSTCOUNT'                        , N'en-US', N'Forums', null, null, N'Posts:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_THREADCOUNT'                               , N'en-US', N'Forums', null, null, N'Threads:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TITLE'                                     , N'en-US', N'Forums', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_FORUM_LIST'                                , N'en-US', N'Forums', null, null, N'Forums';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_FORUM'                                 , N'en-US', N'Forums', null, null, N'Create Forum';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Forums', null, null, N'For';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Forums'                                        , N'en-US', null, N'moduleList'                        ,  50, N'Forums';
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

call dbo.spTERMINOLOGY_Forums_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Forums_en_us')
/
-- #endif IBM_DB2 */
