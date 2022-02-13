

print 'DASHLETS defaults';
--delete from DASHLETS
--GO

set nocount on;
GO

-- 09/20/2009 Paul.  Move Team Notices to the Professional file. 
-- 12/29/2009 Paul.  Correct ProjectTask (singular). 
-- 01/13/2010 Paul.  Add My Projects.
-- 01/24/2010 Paul.  Allow multiple. 
-- 01/27/2011 Paul.  Add My Prospects.
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Accounts'         , '~/Accounts/MyAccounts'                     , 'Accounts.LBL_LIST_MY_ACCOUNTS'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Activities'       , '~/Activities/MyActivities'                 , 'Activities.LBL_UPCOMING'              , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Bugs'             , '~/Bugs/MyBugs'                             , 'Bugs.LBL_LIST_MY_BUGS'                , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Calendar'         , '~/Calendar/MyCalendar'                     , 'Calendar.LBL_MODULE_TITLE'            , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Calls'            , '~/Calls/MyCalls'                           , 'Calls.LBL_LIST_MY_CALLS'              , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Cases'            , '~/Cases/MyCases'                           , 'Cases.LBL_LIST_MY_CASES'              , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Contacts'         , '~/Contacts/MyContacts'                     , 'Contacts.LBL_LIST_MY_CONTACTS'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Leads'            , '~/Leads/MyLeads'                           , 'Leads.LBL_LIST_MY_LEADS'              , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Meetings'         , '~/Meetings/MyMeetings'                     , 'Meetings.LBL_LIST_MY_MEETINGS'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Opportunities'    , '~/Opportunities/MyOpportunities'           , 'Opportunities.LBL_TOP_OPPORTUNITIES'  , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Opportunities'    , '~/Opportunities/MyPipeline'                , 'Home.LBL_PIPELINE_FORM_TITLE'         , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Project'          , '~/Projects/MyProjects'                     , 'Project.LBL_LIST_MY_PROJECTS'         , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'ProjectTask'      , '~/ProjectTasks/MyProjectTasks'             , 'ProjectTask.LBL_LIST_MY_PROJECT_TASKS', 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Tasks'            , '~/Tasks/MyTasks'                           , 'Tasks.LBL_LIST_MY_TASKS'              , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Emails'           , '~/Emails/MyEmails'                         , 'Emails.LBL_LIST_MY_EMAILS'            , 0;
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Prospects'        , '~/Prospects/MyProspects'                   , 'Prospects.LBL_LIST_MY_PROSPECTS'      , 0;
end -- if;
GO

if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and MODULE_NAME = 'Prospects' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Prospects'        , '~/Prospects/MyProspects'                   , 'Prospects.LBL_LIST_MY_PROSPECTS'      , 0;
end -- if;
GO

if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and MODULE_NAME = 'Project' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Project'          , '~/Projects/MyProjects'                     , 'Project.LBL_LIST_MY_PROJECTS'         , 0;
end -- if;
GO

-- 11/02/2010 Paul.  Add Emails Dashlet. 
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and MODULE_NAME = 'Emails' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Emails'           , '~/Emails/MyEmails'                         , 'Emails.LBL_LIST_MY_EMAILS'            , 0;
end -- if;
GO

-- 02/11/2010 Paul.  Fix My Projects title. 
if exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and MODULE_NAME = 'Project' and TITLE = 'Project.LBL_LIST_MY_PROJECT_TASKS') begin -- then
	print 'DASHLETS: Fix My Projects title.';
	update DASHLETS
	   set TITLE            = 'Project.LBL_LIST_MY_PROJECTS'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where CATEGORY         = 'My Dashlets'
	   and MODULE_NAME      = 'Project'
	   and TITLE            = 'Project.LBL_LIST_MY_PROJECT_TASKS'
	   and DELETED          = 0;
end -- if;
GO

if not exists(select * from DASHLETS where CATEGORY = 'Dashboard' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/PipelineBySalesStage'          , 'Dashboard.LBL_SALES_STAGE_FORM_TITLE' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/OppByLeadSourceByOutcome'      , 'Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/PipelineByMonthByOutcome'      , 'Dashboard.LBL_YEAR_BY_OUTCOME'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/OppByLeadSource'               , 'Dashboard.LBL_LEAD_SOURCE_FORM_TITLE' , 0;
end -- if;
GO

-- 12/29/2009 Paul.  Correct ProjectTask (singular). 
if exists(select * from DASHLETS where MODULE_NAME = 'ProjectTasks' and DELETED = 0) begin -- then
	print 'DASHLETS: Fix ProjectTask.';
	update DASHLETS
	   set MODULE_NAME      = 'ProjectTask'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where MODULE_NAME      = 'ProjectTasks'
	   and DELETED = 0;
end -- if;
GO

-- 11/10/2014 Paul.  Add ChatChannels support. 
-- delete from DASHLETS where CATEGORY = 'My Dashlets' and MODULE_NAME = 'ChatChannels';
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and CONTROL_NAME = '~/ChatChannels/MyChatChannels' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'ChatChannels'      , '~/ChatChannels/MyChatChannels', 'ChatChannels.LBL_LIST_MY_CHAT_CHANNELS', 0;
end -- if;
GO

-- 06/02/2016 Paul.  Add Activity Stream dashlet. 
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and CONTROL_NAME = '~/ActivityStream/MyRecentActivity' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'ActivityStream'    , '~/ActivityStream/MyRecentActivity', 'ActivityStream.LBL_MY_ACTIVITY_STREAM', 0;
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

call dbo.spDASHLETS_Defaults()
/

call dbo.spSqlDropProcedure('spDASHLETS_Defaults')
/

-- #endif IBM_DB2 */

