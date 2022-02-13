

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY ForumTopics en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FORUM_TOPIC_NOT_FOUND'                     , N'en-US', N'ForumTopics', null, null, N'Forum Topic Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'ForumTopics', null, null, N'Forum Topic List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LIST_ORDER'                           , N'en-US', N'ForumTopics', null, null, N'List Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'ForumTopics', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORDER'                                , N'en-US', N'ForumTopics', null, null, N'List Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'ForumTopics', null, null, N'Forum Topics: Home';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ForumTopics', null, null, N'FoT';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ForumTopics', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORDER'                                     , N'en-US', N'ForumTopics', null, null, N'Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_FORUM_TOPIC_LIST'                          , N'en-US', N'ForumTopics', null, null, N'Forum Topics';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_FORUM_TOPIC'                           , N'en-US', N'ForumTopics', null, null, N'Create Forum Topic';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'ForumTopics'                                   , N'en-US', null, N'moduleList'                        ,  78, N'Forum Topics';
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

call dbo.spTERMINOLOGY_ForumTopics_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ForumTopics_en_us')
/
-- #endif IBM_DB2 */
