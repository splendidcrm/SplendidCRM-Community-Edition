

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:41 AM.
print 'TERMINOLOGY Project en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'CONTACT_REMOVE_PROJECT_CONFIRM'                , N'en-US', N'Project', null, null, N'Are you sure?';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_PROJECT_NOT_FOUND'                         , N'en-US', N'Project', null, null, N'Project Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Project', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ESTIMATED_END_DATE'                        , N'en-US', N'Project', null, null, N'End Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ESTIMATED_START_DATE'                      , N'en-US', N'Project', null, null, N'Start Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_TEMPLATE'                               , N'en-US', N'Project', null, null, N'Is Template:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CLOSE'                                , N'en-US', N'Project', null, null, N'Close';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Project', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ESTIMATED_END_DATE'                   , N'en-US', N'Project', null, null, N'End Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ESTIMATED_START_DATE'                 , N'en-US', N'Project', null, null, N'Start Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Project', null, null, N'Project List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_TEMPLATE'                          , N'en-US', N'Project', null, null, N'Is Template';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_PROJECTS'                          , N'en-US', N'Project', null, null, N'My Projects';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_TEAM_PROJECTS'                     , N'en-US', N'Project', null, null, N'My Team Projects';
-- 07/31/2017 Paul.  Add My Favorite dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_FAVORITE_PROJECTS'                 , N'en-US', N'Project', null, null, N'My Favorite Projects';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Project', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIORITY'                             , N'en-US', N'Project', null, null, N'Priority';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Project', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TOTAL_ACTUAL_EFFORT'                  , N'en-US', N'Project', null, null, N'Total Actual Effort (hrs)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TOTAL_ESTIMATED_EFFORT'               , N'en-US', N'Project', null, null, N'Total Estimated Effort (hrs)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Project', null, null, N'Project';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Project', null, null, N'Prj';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Project', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Project', null, null, N'Create Project';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIORITY'                                  , N'en-US', N'Project', null, null, N'Priority:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PROJECT_SUBPANEL_TITLE'                    , N'en-US', N'Project', null, null, N'Projects';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Project', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TOTAL_ACTUAL_EFFORT'                       , N'en-US', N'Project', null, null, N'Total Actual Effort (hrs):';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TOTAL_ESTIMATED_EFFORT'                    , N'en-US', N'Project', null, null, N'Total Estimated Effort (hrs):';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_PROJECT'                               , N'en-US', N'Project', null, null, N'Create Project';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_PROJECT_TASK'                          , N'en-US', N'Project', null, null, N'Create Project Task';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_PROJECT_LIST'                              , N'en-US', N'Project', null, null, N'Project List';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_PROJECT_TASK_LIST'                         , N'en-US', N'Project', null, null, N'Project Tasks';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVED_PROJECTS'                         , N'en-US', N'Project', null, null, N'Archived Project';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Project'                                       , N'en-US', null, N'moduleList'                        ,  19, N'Projects';
exec dbo.spTERMINOLOGY_InsertOnly N'Project'                                       , N'en-US', null, N'moduleListSingular'                ,  19, N'Project';

exec dbo.spTERMINOLOGY_InsertOnly N'Draft'                                         , N'en-US', null, N'project_status_dom'                ,   1, N'Draft';
exec dbo.spTERMINOLOGY_InsertOnly N'In Review'                                     , N'en-US', null, N'project_status_dom'                ,   2, N'In Review';
exec dbo.spTERMINOLOGY_InsertOnly N'Published'                                     , N'en-US', null, N'project_status_dom'                ,   3, N'Published';

exec dbo.spTERMINOLOGY_InsertOnly N'high'                                          , N'en-US', null, N'projects_priority_options'         ,   1, N'High';
exec dbo.spTERMINOLOGY_InsertOnly N'medium'                                        , N'en-US', null, N'projects_priority_options'         ,   2, N'Medium';
exec dbo.spTERMINOLOGY_InsertOnly N'low'                                           , N'en-US', null, N'projects_priority_options'         ,   3, N'Low';
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

call dbo.spTERMINOLOGY_Project_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Project_en_us')
/
-- #endif IBM_DB2 */
