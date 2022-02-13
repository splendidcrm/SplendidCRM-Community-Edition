

print 'DASHBOARD_APPS';
--delete from DASHBOARD_APPS
--GO

set nocount on;
GO

-- 06/14/2017 Paul.  There were very few distributions of 11.3 with the dashlets in an old location, but we still need to clean them up. 
if exists(select * from DASHBOARD_APPS where SCRIPT_URL like '~/Dashboard/javascript/%') begin -- then
	delete from DASHBOARD_APPS;
end -- if;

-- 07/31/2017 Paul.  Add My Emails. 
-- delete from DASHBOARD_APPS where MODULE_NAME = 'Project';
if not exists(select * from DASHBOARD_APPS where CATEGORY = 'My Dashboard' and NAME = 'My Accounts' and DELETED = 0) begin -- then
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Accounts'                  , 'My Dashboard', 'Accounts'     , 'Accounts.LBL_LIST_MY_ACCOUNTS'          , 'Accounts.SearchHome'                   , '~/html5/Dashlets/MyAccounts.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Activities'                , 'My Dashboard', 'Activities'   , 'Activities.LBL_UPCOMING'                , 'Activities.SearchHome'                 , '~/html5/Dashlets/MyActivities.js'            , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Bugs'                      , 'My Dashboard', 'Bugs'         , 'Bugs.LBL_LIST_MY_BUGS'                  , 'Bugs.SearchHome'                       , '~/html5/Dashlets/MyBugs.js'                  , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Calls'                     , 'My Dashboard', 'Calls'        , 'Calls.LBL_LIST_MY_CALLS'                , 'Calls.SearchHome'                      , '~/html5/Dashlets/MyCalls.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Cases'                     , 'My Dashboard', 'Cases'        , 'Cases.LBL_LIST_MY_CASES'                , 'Cases.SearchHome'                      , '~/html5/Dashlets/MyCases.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Contacts'                  , 'My Dashboard', 'Contacts'     , 'Contacts.LBL_LIST_MY_CONTACTS'          , 'Contacts.SearchHome'                   , '~/html5/Dashlets/MyContacts.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Leads'                     , 'My Dashboard', 'Leads'        , 'Leads.LBL_LIST_MY_LEADS'                , 'Leads.SearchHome'                      , '~/html5/Dashlets/MyLeads.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Meetings'                  , 'My Dashboard', 'Meetings'     , 'Meetings.LBL_LIST_MY_MEETINGS'          , 'Meetings.SearchHome'                   , '~/html5/Dashlets/MyMeetings.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Opportunities'             , 'My Dashboard', 'Opportunities', 'Opportunities.LBL_TOP_OPPORTUNITIES'    , 'Opportunities.SearchHome'              , '~/html5/Dashlets/MyOpportunities.js'         , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Project'                   , 'My Dashboard', 'Project'      , 'Project.LBL_LIST_MY_PROJECTS'           , 'Project.SearchHome'                    , '~/html5/Dashlets/MyProjects.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My ProjectTask'               , 'My Dashboard', 'ProjectTask'  , 'ProjectTask.LBL_LIST_MY_PROJECT_TASKS'  , 'ProjectTask.SearchHome'                , '~/html5/Dashlets/MyProjectTask.js'           , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Prospects'                 , 'My Dashboard', 'Prospects'    , 'Prospects.LBL_LIST_MY_PROSPECTS'        , 'Prospects.SearchHome'                  , '~/html5/Dashlets/MyProspects.js'             , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Tasks'                     , 'My Dashboard', 'Tasks'        , 'Tasks.LBL_LIST_MY_TASKS'                , 'Tasks.SearchHome'                      , '~/html5/Dashlets/MyTasks.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Pipeline By Sales Stage'   , 'My Dashboard', 'Opportunities', 'Home.LBL_PIPELINE_FORM_TITLE'           , 'Opportunities.MyPipelineBySalesStage'  , '~/html5/Dashlets/MyPipelineBySalesStage.js'  , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Emails'                    , 'My Dashboard', 'Emails'       , 'Emails.LBL_LIST_MY_EMAILS'              , 'Emails.SearchHome'                     , '~/html5/Dashlets/MyEmails.js'                , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Recent Emails'                , 'My Dashboard', 'Emails'       , 'Emails.LBL_LIST_RECENT_EMAILS'          , 'Emails.SearchHome'                     , '~/html5/Dashlets/RecentEmails.js'            , 0;
end -- if;
GO

-- 07/31/2017 Paul.  Add My Emails. 
if not exists(select * from DASHBOARD_APPS where CATEGORY = 'My Dashboard' and NAME = 'Recent Emails' and DELETED = 0) begin -- then
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Emails'                    , 'My Dashboard', 'Emails'       , 'Emails.LBL_LIST_MY_EMAILS'              , 'Emails.SearchHome'                     , '~/html5/Dashlets/MyEmails.js'                , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Recent Emails'                , 'My Dashboard', 'Emails'       , 'Emails.LBL_LIST_RECENT_EMAILS'          , 'Emails.SearchHome'                     , '~/html5/Dashlets/RecentEmails.js'            , 0;
end -- if;
GO

-- 10/20/2020 Paul.  Add My Calendar. 
if not exists(select * from DASHBOARD_APPS where CATEGORY = 'My Dashboard' and NAME = 'My Calendar' and DELETED = 0) begin -- then
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Calendar'                  , 'My Dashboard', 'Calendar'     , 'Calendar.LBL_MODULE_TITLE'              , 'Calendar.SearchHome'                   , '~/html5/Dashlets/MyCalendar.js'             , 0;
end -- if;
GO

-- 07/31/2017 Paul.  Add My Favorite dashlets. 
-- delete from DASHBOARD_APPS where CATEGORY = 'My Dashboard' and NAME like 'My Favorite %';
if not exists(select * from DASHBOARD_APPS where CATEGORY = 'My Dashboard' and NAME = 'My Favorite Accounts' and DELETED = 0) begin -- then
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Accounts'         , 'My Dashboard', 'Accounts'     , 'Accounts.LBL_LIST_MY_FAVORITE_ACCOUNTS'          , 'Accounts.SearchHome'                 , '~/html5/Dashlets/MyFavoriteAccounts.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Bugs'             , 'My Dashboard', 'Bugs'         , 'Bugs.LBL_LIST_MY_FAVORITE_BUGS'                  , 'Bugs.SearchHome'                     , '~/html5/Dashlets/MyFavoriteBugs.js'                  , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Calls'            , 'My Dashboard', 'Calls'        , 'Calls.LBL_LIST_MY_FAVORITE_CALLS'                , 'Calls.SearchHome'                    , '~/html5/Dashlets/MyFavoriteCalls.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Cases'            , 'My Dashboard', 'Cases'        , 'Cases.LBL_LIST_MY_FAVORITE_CASES'                , 'Cases.SearchHome'                    , '~/html5/Dashlets/MyFavoriteCases.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Contacts'         , 'My Dashboard', 'Contacts'     , 'Contacts.LBL_LIST_MY_FAVORITE_CONTACTS'          , 'Contacts.SearchHome'                 , '~/html5/Dashlets/MyFavoriteContacts.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Leads'            , 'My Dashboard', 'Leads'        , 'Leads.LBL_LIST_MY_FAVORITE_LEADS'                , 'Leads.SearchHome'                    , '~/html5/Dashlets/MyFavoriteLeads.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Meetings'         , 'My Dashboard', 'Meetings'     , 'Meetings.LBL_LIST_MY_FAVORITE_MEETINGS'          , 'Meetings.SearchHome'                 , '~/html5/Dashlets/MyFavoriteMeetings.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Opportunities'    , 'My Dashboard', 'Opportunities', 'Opportunities.LBL_MY_FAVORITE_OPPORTUNITIES'     , 'Opportunities.SearchHome'            , '~/html5/Dashlets/MyFavoriteOpportunities.js'         , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Project'          , 'My Dashboard', 'Project'      , 'Project.LBL_LIST_MY_FAVORITE_PROJECTS'           , 'Project.SearchHome'                  , '~/html5/Dashlets/MyFavoriteProjects.js'              , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite ProjectTask'      , 'My Dashboard', 'ProjectTask'  , 'ProjectTask.LBL_LIST_MY_FAVORITE_PROJECT_TASKS'  , 'ProjectTask.SearchHome'              , '~/html5/Dashlets/MyFavoriteProjectTasks.js'          , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Prospects'        , 'My Dashboard', 'Prospects'    , 'Prospects.LBL_LIST_MY_FAVORITE_PROSPECTS'        , 'Prospects.SearchHome'                , '~/html5/Dashlets/MyFavoriteProspects.js'             , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Tasks'            , 'My Dashboard', 'Tasks'        , 'Tasks.LBL_LIST_MY_FAVORITE_TASKS'                , 'Tasks.SearchHome'                    , '~/html5/Dashlets/MyFavoriteTasks.js'                 , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'My Favorite Emails'           , 'My Dashboard', 'Emails'       , 'Emails.LBL_LIST_MY_FAVORITE_EMAILS'              , 'Emails.SearchHome'                   , '~/html5/Dashlets/MyFavoriteEmails.js'                , 0;
end -- if;
GO

if not exists(select * from DASHBOARD_APPS where CATEGORY = 'Dashboard' and DELETED = 0) begin -- then
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Pipeline By Sales Stage'      , 'Dashboard'   , 'Opportunities', 'Dashboard.LBL_SALES_STAGE_FORM_TITLE'   , 'Opportunities.PipelineBySalesStage'    , '~/html5/Dashlets/PipelineBySalesStage.js'    , 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Opp By Lead Source By Outcome', 'Dashboard'   , 'Opportunities', 'Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME'   , 'Opportunities.OppByLeadSourceByOutcome', '~/html5/Dashlets/OppByLeadSourceByOutcome.js', 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Pipeline By Month By Outcome' , 'Dashboard'   , 'Opportunities', 'Dashboard.LBL_YEAR_BY_OUTCOME'          , 'Opportunities.PipelineByMonthByOutcome', '~/html5/Dashlets/PipelineByMonthByOutcome.js', 0;
	exec dbo.spDASHBOARD_APPS_InsertOnly 'Opp By Lead Source'           , 'Dashboard'   , 'Opportunities', 'Dashboard.LBL_LEAD_SOURCE_FORM_TITLE'   , 'Opportunities.OppByLeadSource'         , '~/html5/Dashlets/OppByLeadSource.js'         , 0;
end -- if;
GO

set nocount off;
GO

/* -- #if Oracle
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			StoO_selcnt := 0;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spDASHBOARD_APPS()
/

call dbo.spSqlDropProcedure('spDASHBOARD_APPS')
/

-- #endif IBM_DB2 */

