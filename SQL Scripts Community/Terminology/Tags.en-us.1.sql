

print 'TERMINOLOGY Tags en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_TAG_SET'                               , N'en-US', N'Tags', null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Tags', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISABLE'                                   , N'en-US', N'Tags', null, null, N'Disable';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Tags', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Tags', null, null, N'Tag List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Tags', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TAG'                                  , N'en-US', N'Tags', null, null, N'Tag';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Tags', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPLACE_TAG_SET'                           , N'en-US', N'Tags', null, null, N'Replace';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Tags', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAG'                                       , N'en-US', N'Tags', null, null, N'Tag:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAGS'                                      , N'en-US', N'Tags', null, null, N'Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_TAG'                                   , N'en-US', N'Tags', null, null, N'Create Tag';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_TAG_LIST'                                  , N'en-US', N'Tags', null, null, N'Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Tags', null, null, N'Create Tag';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Tags', null, null, N'Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Tags', null, null, N'Tag';
-- select * from vwTERMINOLOGY where LIST_NAME = 'moduleList' order by LIST_ORDER desc;
exec dbo.spTERMINOLOGY_InsertOnly N'Tags'                                          , N'en-US', null, N'moduleList',  162, N'Tags';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAG_SET_NAME'                              , N'en-US', null, null, null, N'Tags:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TAG_SET_NAME'                         , N'en-US', null, null, null, N'Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_TAGS_TITLE'                         , N'en-US', N'Administration', null, null, N'Manage Tags';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_TAGS'                               , N'en-US', N'Administration', null, null, N'Manage Tags';
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

call dbo.spTERMINOLOGY_Tags_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Tags_en_us')
/
-- #endif IBM_DB2 */
