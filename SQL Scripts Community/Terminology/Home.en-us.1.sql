

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Home en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ONE_CHAR'                                  , N'en-US', N'Home', null, null, N'Please provide text to search.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_DASHLETS'                              , N'en-US', N'Home', null, null, N'Add Dashlets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_NEW_DASHLETS'                          , N'en-US', N'Home', null, null, N'Add New Dashlets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLOSE_DASHLETS'                            , N'en-US', N'Home', null, null, N'Close Dashlets';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PIPELINE_FORM_TITLE'                       , N'en-US', N'Home', null, null, N'My Pipeline';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_TEAM_PIPELINE'                          , N'en-US', N'Home', null, null, N'My Team Pipeline';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_DASHLET_CONFIRM'                    , N'en-US', N'Home', null, null, N'Are you sure?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_RESULTS'                            , N'en-US', N'Home', null, null, N'Search Results';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_NOTICES_TITLE'                        , N'en-US', N'Home', null, null, N'Team Notices';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ACCOUNT'                               , N'en-US', N'Home', null, null, N'Create Account';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_BUG'                                   , N'en-US', N'Home', null, null, N'Create Bug';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CALL'                                  , N'en-US', N'Home', null, null, N'Create Call';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CASE'                                  , N'en-US', N'Home', null, null, N'Create Case';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CONTACT'                               , N'en-US', N'Home', null, null, N'Create Contact';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_EMAIL'                                 , N'en-US', N'Home', null, null, N'Create Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_LEAD'                                  , N'en-US', N'Home', null, null, N'Create Lead';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_MEETING'                               , N'en-US', N'Home', null, null, N'Create Meeting';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_NOTE'                                  , N'en-US', N'Home', null, null, N'Create Note';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_OPPORTUNITY'                           , N'en-US', N'Home', null, null, N'Create Opportunity';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_SEND_EMAIL'                            , N'en-US', N'Home', null, null, N'Create Send Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_TASK'                                  , N'en-US', N'Home', null, null, N'Create Task';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Home', null, null, N'Hom';
-- 06/14/2017 Paul.  Add Home/My Dashboard. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Home', null, null, N'Home';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Home', null, null, N'Create Dashboard';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Home'                                          , N'en-US', null, N'moduleList'                        ,   1, N'Home';
exec dbo.spTERMINOLOGY_InsertOnly N'Home'                                          , N'en-US', null, N'moduleListSingular'                ,   1, N'Home';
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

call dbo.spTERMINOLOGY_Home_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Home_en_us')
/
-- #endif IBM_DB2 */
