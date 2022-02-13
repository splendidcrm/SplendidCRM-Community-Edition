

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY Dashboard en-us';
GO

set nocount on;
GO

-- 05/18/2017 Paul.  Change to Create Dashboard. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Dashboard', null, null, N'Create Dashboard';
if exists(select * from TERMINOLOGY where MODULE_NAME = N'Dashboard' and NAME = N'LBL_NEW_FORM_TITLE' and DISPLAY_NAME = N'Dashboard' and DELETED = 0) begin -- then
	update TERMINOLOGY
	   set DISPLAY_NAME      = N'Create Dashboard'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where MODULE_NAME       = N'Dashboard'
	   and NAME              = N'LBL_NEW_FORM_TITLE'
	   and DISPLAY_NAME      = N'Dashboard'
	   and DELETED           = 0;
end -- if;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED_ON'                                , N'en-US', N'Dashboard', null, null, N'Created On';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_END'                                  , N'en-US', N'Dashboard', null, null, N'Date End:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_RANGE'                                , N'en-US', N'Dashboard', null, null, N'Date Range';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_RANGE_TO'                             , N'en-US', N'Dashboard', null, null, N' to ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_START'                                , N'en-US', N'Dashboard', null, null, N'Date Start:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT'                                      , N'en-US', N'Dashboard', null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCE_BY_OUTCOME'                    , N'en-US', N'Dashboard', null, null, N'Lead Source By Outcome';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCE_BY_OUTCOME_DESC'               , N'en-US', N'Dashboard', null, null, N'Shows cumulative amounts by lead source by outcome.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCE_FORM_DESC'                     , N'en-US', N'Dashboard', null, null, N'Shows cumulative amounts by lead source.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCE_FORM_TITLE'                    , N'en-US', N'Dashboard', null, null, N'Lead Source';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCE_OTHER'                         , N'en-US', N'Dashboard', null, null, N'Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LEAD_SOURCES'                              , N'en-US', N'Dashboard', null, null, N'Lead Sources:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Dashboard', null, null, N'Dashboard List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MONTH_BY_OUTCOME_DESC'                     , N'en-US', N'Dashboard', null, null, N'Shows cumulative amounts by month by outcome.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPP_SIZE'                                  , N'en-US', N'Dashboard', null, null, N'Size in ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPP_THOUSANDS'                             , N'en-US', N'Dashboard', null, null, N'K';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPPS_IN_LEAD_SOURCE'                       , N'en-US', N'Dashboard', null, null, N' lead source is ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPPS_IN_STAGE'                             , N'en-US', N'Dashboard', null, null, N' sales stage is ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPPS_OUTCOME'                              , N'en-US', N'Dashboard', null, null, N' outcome is ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPPS_WORTH'                                , N'en-US', N'Dashboard', null, null, N'opportunities worth';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PIPELINE_FORM_TITLE_DESC'                  , N'en-US', N'Dashboard', null, null, N'Shows cumulative amounts by sales stages.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REFRESH'                                   , N'en-US', N'Dashboard', null, null, N'Refresh';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROLLOVER_DETAILS'                          , N'en-US', N'Dashboard', null, null, N'Roll over the graph elements to get more details.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROLLOVER_WEDGE_DETAILS'                    , N'en-US', N'Dashboard', null, null, N'Roll over the graph elements to get more details.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALES_STAGE_FORM_TITLE'                    , N'en-US', N'Dashboard', null, null, N'Sales Stage';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALES_STAGES'                              , N'en-US', N'Dashboard', null, null, N'Sales Stages:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TOTAL_PIPELINE'                            , N'en-US', N'Dashboard', null, null, N'Total Pipeline';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USERS'                                     , N'en-US', N'Dashboard', null, null, N'Users:';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAMS'                                     , N'en-US', N'Dashboard', null, null, N'Teams:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_YEAR'                                      , N'en-US', N'Dashboard', null, null, N'Year:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_YEAR_BY_OUTCOME'                           , N'en-US', N'Dashboard', null, null, N'Pipeline By Month By Outcome';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ACCOUNT'                               , N'en-US', N'Dashboard', null, null, N'Create Account';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_BUG'                                   , N'en-US', N'Dashboard', null, null, N'Create Bug';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CALL'                                  , N'en-US', N'Dashboard', null, null, N'Create Call';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CASE'                                  , N'en-US', N'Dashboard', null, null, N'Create Case';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CONTACT'                               , N'en-US', N'Dashboard', null, null, N'Create Contact';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_LEAD'                                  , N'en-US', N'Dashboard', null, null, N'Create Lead';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_MEETING'                               , N'en-US', N'Dashboard', null, null, N'Create Meeting';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_NOTE'                                  , N'en-US', N'Dashboard', null, null, N'Create Note';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_OPPORTUNITY'                           , N'en-US', N'Dashboard', null, null, N'Create Opportunity';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_QUOTE'                                 , N'en-US', N'Dashboard', null, null, N'Create Quote';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_TASK'                                  , N'en-US', N'Dashboard', null, null, N'Create Task';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Dashboard', null, null, N'Das';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_AFTER'                              , N'en-US', N'Dashboard', null, null, N'On or After:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_BEFORE'                             , N'en-US', N'Dashboard', null, null, N'Before:';
-- 05/31/2017 Paul.  Dashboard properties. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Dashboard', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Dashboard', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ID'                                        , N'en-US', N'Dashboard', null, null, N'ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PANEL_TYPE'                                , N'en-US', N'Dashboard', null, null, N'Panel Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHBOARD_APP_ID'                          , N'en-US', N'Dashboard', null, null, N'Dashboard App ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATEGORY'                                  , N'en-US', N'Dashboard', null, null, N'Category:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CATEGORY'                             , N'en-US', N'Dashboard', null, null, N'Location';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SETTINGS_EDITVIEW'                         , N'en-US', N'Dashboard', null, null, N'Settings EditView:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_ADMIN'                                  , N'en-US', N'Dashboard', null, null, N'Is Admin:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_ENABLED'                               , N'en-US', N'Dashboard', null, null, N'App Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SCRIPT_URL'                                , N'en-US', N'Dashboard', null, null, N'Script URL:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Dashboard', null, null, N'Module Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TITLE'                                     , N'en-US', N'Dashboard', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BLANK_TYPE'                                , N'en-US', N'Dashboard', null, null, N'(Blank)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_BLANK'                                 , N'en-US', N'Dashboard', null, null, N'New Blank';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_ROW'                                   , N'en-US', N'Dashboard', null, null, N'New Row';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COPY_BUTTON_TITLE'                         , N'en-US', N'Dashboard', null, null, N'Copy';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_BUTTON_TITLE'                       , N'en-US', N'Dashboard', null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_ROLE'                               , N'en-US', N'Dashboard', null, null, N'Select Role';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_DELETE_CONFIRM'                            , N'en-US', N'Dashboard', null, null, N'Are you sure?';
-- 06/17/2017 Paul.  Dashboard popup. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HOME_PAGE_DASHBOARDS'                      , N'en-US', N'Dashboard', null, null, N'Home Page Dashboards';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHBOARDS'                                , N'en-US', N'Dashboard', null, null, N'Dashboards';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_NEW_DASHBOARD'                      , N'en-US', N'Dashboard', null, null, N'Create New Dashboard';
-- 06/15/2019 Paul.  Missing term DEFAULT_SETTINGS. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_SETTINGS'                          , N'en-US', N'Dashboard', null, null, N'Default Settings:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME_REQUIRED'                             , N'en-US', N'Dashboard', null, null, N'A name is required.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PANELS_EMPTY'                              , N'en-US', N'Dashboard', null, null, N'Panels cannot be empty.';
-- 06/09/2021 Paul.  
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHBOARD_TAB_EDIT'                        , N'en-US', N'Dashboard', null, null, N'Edit Dashboard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHBOARD_TAB_CREATE'                      , N'en-US', N'Dashboard', null, null, N'Create New Dashboard';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Dashboard'                                     , N'en-US', null, N'moduleList'                        ,   2, N'Dashboard';
exec dbo.spTERMINOLOGY_InsertOnly N'Dashboard'                                     , N'en-US', null, N'moduleListSingular'                ,   2, N'Dashboard';
-- select * from TERMINOLOGY where list_name = 'modulelist' order by list_order desc
-- 08/10/2017 Paul.  Need label for DashboardPanels and Images.  They appear on ACL Access View. 
exec dbo.spTERMINOLOGY_InsertOnly N'DashboardPanels'                               , N'en-US', null, N'moduleList'                        , 170, N'Dashboard Panels';
exec dbo.spTERMINOLOGY_InsertOnly N'Images'                                        , N'en-US', null, N'moduleList'                        , 171, N'Images';
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

call dbo.spTERMINOLOGY_Dashboard_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Dashboard_en_us')
/
-- #endif IBM_DB2 */
