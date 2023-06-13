

print 'GRIDVIEWS_COLUMNS PopupView defaults';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.PopupView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.PopupView';
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/28/2009 Paul.  Restore TEAM_NAME and expect it to be converted automatically when DynamicTeams is enabled. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.PopupView', 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.PopupView'          , 1, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'            , 'NAME'            , '45%', 'listViewTdLinkS1', 'ID NAME', 'SelectAccount(''{0}'', ''{1}'');', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.PopupView'          , 2, 'Accounts.LBL_LIST_CITY'                   , 'CITY'            , 'CITY'            , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.PopupView'          , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.PopupView'          , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.PopupView', 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.PopupView'              , 1, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'      , 'BUG_NUMBER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.PopupView'              , 2, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectBug(''{0}'', ''{1}'');', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.PopupView'              , 3, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'          , 'STATUS'          , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.PopupView'              , 4, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'            , 'TYPE'            , '10%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.PopupView'              , 5, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'        , 'PRIORITY'        , '10%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.PopupView'              , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.PopupView'              , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.PopupView', 'Calls', 'vwCALLS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.PopupView'             , 1, 'Calls.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectCall(''{0}'', ''{1}'');', null, 'Calls', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.PopupView'             , 2, 'Calls.LBL_LIST_DATE'                      , 'DATE_START'      , 'DATE_START'      , '30%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.PopupView'             , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.PopupView'             , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.PopupView', 'Campaigns', 'vwCAMPAIGNS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.PopupView'         , 1, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectCampaign(''{0}'', ''{1}'');', null, 'Campaigns', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.PopupView'         , 2, 'Campaigns.LBL_LIST_STATUS'                , 'STATUS'          , 'STATUS'          , '10%', 'campaign_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.PopupView'         , 3, 'Campaigns.LBL_LIST_TYPE'                  , 'CAMPAIGN_TYPE'   , 'CAMPAIGN_TYPE'   , '10%', 'campaign_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.PopupView'         , 4, 'Campaigns.LBL_LIST_END_DATE'              , 'END_DATE'        , 'END_DATE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PopupView'         , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PopupView'         , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

-- 02/16/2022 Paul.  Default sort for React client should be RELATED_NAME. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PreviewView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PreviewView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.PreviewView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.PreviewView', 'Campaigns', 'vwCAMPAIGNS_SendEmail', 'RELATED_NAME', 'asc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PreviewView'       , 0, 'ProspectLists.LBL_LIST_LIST_TYPE'         , 'RELATED_TYPE'    , 'RELATED_TYPE'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PreviewView'       , 1, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'RELATED_NAME'    , 'RELATED_NAME'    , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.PreviewView'       , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'          , 'EMAIL1'          , '40%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
end else begin
	-- 02/16/2022 Paul.  Default sort for React client should be RELATED_NAME. 
	if exists(select * from GRIDVIEWS where NAME = 'Campaigns.PreviewView' and SORT_FIELD is null and DELETED = 0) begin -- then
		update GRIDVIEWS
		   set SORT_FIELD        = 'RELATED_NAME'
		     , SORT_DIRECTION    = 'asc'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where NAME              = 'Campaigns.PreviewView'
		   and SORT_FIELD        is null
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.PopupView', 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.PopupView'             , 1, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID NAME', 'SelectCase(''{0}'', ''{1}'');'  , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.PopupView'             , 2, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectCase(''{0}'', ''{1}'');'  , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.PopupView'             , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.PopupView'             , 4, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.PopupView'             , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.PopupView'             , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.PopupView', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.PopupView'          , 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectContact(''{0}'', ''{1}'');', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView'          , 2, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView'          , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView'          , 4, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView'          , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.PopupView', 'Documents', 'vwDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.PopupView'         , 1, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID NAME', 'SelectDocument(''{0}'', ''{1}'');', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.PopupView'         , 2, 'Documents.LBL_LIST_REVISION'              , 'REVISION'        , 'REVISION'        , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.PopupView'         , 3, 'Documents.LBL_LIST_STATUS'                , 'STATUS_ID'       , 'STATUS_ID'       , '20%', 'document_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.PopupView'         , 4, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.PopupView', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailTemplates.PopupView'    , 1, 'EmailTemplates.LBL_LIST_NAME'             , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectEmailTemplate(''{0}'', ''{1}'');', null, 'EmailTemplates', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.PopupView'    , 2, 'EmailTemplates.LBL_LIST_DESCRIPTION'      , 'DESCRIPTION'     , 'DESCRIPTION'     , '55%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailTemplates.PopupView'    , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'   , 'DATE_MODIFIED'   , '20%', 'Date';
end -- if;
GO

-- 05/09/2008 Paul.  Correct Employees.PopupView URL_ASSIGNED_FIELD.
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.PopupView', 'Employees', 'vwEMPLOYEES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.PopupView'         , 1, 'Employees.LBL_LIST_NAME'                  , 'FULL_NAME'       , 'FULL_NAME'       , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectEmployee(''{0}'', ''{1}'');', null, 'Employees', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.PopupView'         , 2, 'Employees.LBL_LIST_USER_NAME'             , 'USER_NAME'       , 'USER_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.PopupView'         , 3, 'Employees.LBL_LIST_EMAIL'                 , 'EMAIL1'          , 'EMAIL1'          , '20%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.PopupView'         , 4, 'Employees.LBL_LIST_EMPLOYEE_STATUS'       , 'EMPLOYEE_STATUS' , 'EMPLOYEE_STATUS' , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.PopupView'         , 5, 'Employees.LBL_LIST_REPORTS_TO_NAME'       , 'REPORTS_TO_NAME' , 'REPORTS_TO_NAME' , '20%';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.PopupView' and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Correct Employees.PopupView URL_ASSIGNED_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = null
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Employees.PopupView'
		   and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.PopupView', 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.PopupView'             , 1, 'Leads.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectLead(''{0}'', ''{1}'');', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.PopupView'             , 2, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.PopupView'             , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.PopupView'             , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.PopupView', 'Meetings', 'vwMEETINGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.PopupView'          , 1, 'Meetings.LBL_LIST_SUBJECT'                , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectMeeting(''{0}'', ''{1}'');', null, 'Meetings', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.PopupView'          , 2, 'Meetings.LBL_LIST_DATE'                   , 'DATE_START'      , 'DATE_START'      , '30%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.PopupView'          , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.PopupView'          , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.PopupView', 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.PopupView'     , 1, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectOpportunity(''{0}'', ''{1}'');', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.PopupView'     , 2, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.PopupView'     , 3, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'     , 'DATE_CLOSED'     , '10%', 'Date'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.PopupView'     , 4, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.PopupView'     , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.PopupView', 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.PopupView'           , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '60%', 'listViewTdLinkS1', 'ID NAME', 'SelectProject(''{0}'', ''{1}'');', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.PopupView'           , 2, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.PopupView'           , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.PopupView', 'ProjectTask', 'vwPROJECT_TASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.PopupView'       , 2, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectProjectTask(''{0}'', ''{1}'');', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.PopupView'       , 3, 'ProjectTask.LBL_LIST_PARENT_NAME'         , 'PROJECT_NAME'    , 'PROJECT_NAME'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.PopupView'       , 4, 'ProjectTask.LBL_LIST_DUE_DATE'            , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.PopupView'       , 5, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'          , 'STATUS'          , '10%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.PopupView'       , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.PopupView'       , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.PopupView', 'ProspectLists', 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.PopupView'     , 1, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectProspectList(''{0}'', ''{1}'');', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.PopupView'     , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'     , 'DESCRIPTION'     , '50%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.PopupView'     , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.PopupView'     , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.PopupView', 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.PopupView'         , 1, 'Prospects.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectProspect(''{0}'', ''{1}'');', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.PopupView'         , 2, 'Prospects.LBL_LIST_TITLE'                 , 'TITLE'           , 'TITLE'           , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.PopupView'         , 3, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'          , 'EMAIL1'          , '25%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.PopupView'         , 4, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.PopupView'         , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.PopupView', 'Tasks', 'vwTASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.PopupView'             , 1, 'Tasks.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID NAME', 'SelectTask(''{0}'', ''{1}'');', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.PopupView'             , 2, 'Tasks.LBL_LIST_DUE_DATE'                  , 'DATE_DUE'        , 'DATE_DUE'        , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.PopupView'             , 3, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.PopupView'             , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '15%';
end -- if;
GO

-- 12/02/2009 Paul.  Correct Users.PopupView URL_FIELD.
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.PopupView', 'Users', 'vwUSERS_ASSIGNED_TO_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupView'             , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '40%', 'listViewTdLinkS1', 'ID USER_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupView'             , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '40%', 'listViewTdLinkS1', 'ID USER_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.PopupView'             , 3, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '20%';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.PopupView' and URL_FIELD = 'ID FULL_NAME' and DELETED = 0) begin -- then
		print 'Correct Users.PopupView URL_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD          = 'ID USER_NAME'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Users.PopupView'
		   and URL_FIELD          = 'ID FULL_NAME'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 08/01/2010 Paul.  We need a separate view to select the Full Name instead of the User Name. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.PopupViewName' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.PopupViewName';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.PopupViewName', 'Users', 'vwUSERS_ASSIGNED_TO_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupViewName'         , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '40%', 'listViewTdLinkS1', 'ID FULL_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupViewName'         , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '40%', 'listViewTdLinkS1', 'ID FULL_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.PopupViewName'         , 3, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '20%';
end -- if;
GO

-- 07/23/2014 Paul.  UserCalendarPopup includes user schedule. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.UserCalendarPopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.UserCalendarPopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.UserCalendarPopupView', 'Users', 'vwUSERS_ASSIGNED_TO_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.UserCalendarPopupView'    , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '20%', 'listViewTdLinkS1', 'ID USER_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.UserCalendarPopupView'    , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '20%', 'listViewTdLinkS1', 'ID USER_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.UserCalendarPopupView'    , 4, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.UserCalendarPopupViewName' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.UserCalendarPopupViewName';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.UserCalendarPopupViewName', 'Users', 'vwUSERS_ASSIGNED_TO_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.UserCalendarPopupViewName', 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '20%', 'listViewTdLinkS1', 'ID FULL_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.UserCalendarPopupViewName', 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '20%', 'listViewTdLinkS1', 'ID FULL_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.UserCalendarPopupViewName', 4, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '15%';
end -- if;
GO

-- 08/05/2010 Paul.  Add support for Releases popup. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Releases.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Releases.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Releases.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Releases.PopupView', 'Releases', 'vwRELEASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Releases.PopupView'         , 1, 'Releases.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '72%', 'listViewTdLinkS1', 'ID NAME', 'SelectRelease(''{0}'', ''{1}'');', null, 'Releases', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Releases.PopupView'         , 2, 'Releases.LBL_LIST_STATUS'                 , 'STATUS'          , 'STATUS'          , '10%', 'release_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Releases.PopupView'         , 3, 'Releases.LBL_LIST_LIST_ORDER'             , 'LIST_ORDER'      , 'LIST_ORDER'      , '10%';
end -- if;
GO

-- 04/11/2011 Paul.  Add support for Dynamic Layout popups. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.DetailView.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.DetailView.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS DynamicLayout.DetailView.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'DynamicLayout.DetailView.PopupView', 'DynamicLayout', 'vwDETAILVIEWS_FIELDS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'DynamicLayout.DetailView.PopupView', 1, 'DynamicLayout.LBL_LIST_DETAIL_NAME' , 'DETAIL_NAME'     , 'DETAIL_NAME'     , '20%', 'listViewTdLinkS1', 'ID DETAIL_NAME', 'SelectLayoutField(''{0}'', ''{1}'');', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.DetailView.PopupView', 2, 'DynamicLayout.LBL_LIST_FIELD_INDEX' , 'FIELD_INDEX'     , 'FIELD_INDEX'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.DetailView.PopupView', 3, 'DynamicLayout.LBL_LIST_FIELD_TYPE'  , 'FIELD_TYPE'      , 'FIELD_TYPE'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.DetailView.PopupView', 4, 'DynamicLayout.LBL_LIST_DATA_FIELD'  , 'DATA_FIELD'      , 'DATA_FIELD'      , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.DetailView.PopupView', 5, 'DynamicLayout.LBL_LIST_DATA_LABEL'  , 'DATA_LABEL'      , 'DATA_LABEL'      , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.DetailView.PopupView', 6, 'DynamicLayout.LBL_LIST_LIST_NAME'   , 'LIST_NAME'       , 'LIST_NAME'       , '10%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.EditView.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.EditView.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS DynamicLayout.EditView.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'DynamicLayout.EditView.PopupView'  , 'DynamicLayout', 'vwEDITVIEWS_FIELDS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'DynamicLayout.EditView.PopupView'  , 1, 'DynamicLayout.LBL_LIST_EDIT_NAME'   , 'EDIT_NAME'       , 'EDIT_NAME'       , '25%', 'listViewTdLinkS1', 'ID EDIT_NAME', 'SelectLayoutField(''{0}'', ''{1}'');', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.EditView.PopupView'  , 2, 'DynamicLayout.LBL_LIST_FIELD_INDEX' , 'FIELD_INDEX'     , 'FIELD_INDEX'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.EditView.PopupView'  , 3, 'DynamicLayout.LBL_LIST_FIELD_TYPE'  , 'FIELD_TYPE'      , 'FIELD_TYPE'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.EditView.PopupView'  , 4, 'DynamicLayout.LBL_LIST_DATA_FIELD'  , 'DATA_FIELD'      , 'DATA_FIELD'      , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.EditView.PopupView'  , 5, 'DynamicLayout.LBL_LIST_DATA_LABEL'  , 'DATA_LABEL'      , 'DATA_LABEL'      , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.EditView.PopupView'  , 6, 'DynamicLayout.LBL_LIST_LIST_NAME'   , 'LIST_NAME'       , 'LIST_NAME'       , '10%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.GridView.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'DynamicLayout.GridView.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS DynamicLayout.GridView.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'DynamicLayout.GridView.PopupView'  , 'DynamicLayout', 'vwGRIDVIEWS_COLUMNS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'DynamicLayout.GridView.PopupView'  , 1, 'DynamicLayout.LBL_LIST_GRID_NAME'   , 'GRID_NAME'       , 'GRID_NAME'       , '25%', 'listViewTdLinkS1', 'ID GRID_NAME', 'SelectLayoutField(''{0}'', ''{1}'');', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.GridView.PopupView'  , 2, 'DynamicLayout.LBL_LIST_COLUMN_INDEX', 'COLUMN_INDEX'    , 'COLUMN_INDEX'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.GridView.PopupView'  , 3, 'DynamicLayout.LBL_LIST_COLUMN_TYPE' , 'COLUMN_TYPE'     , 'COLUMN_TYPE'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.GridView.PopupView'  , 4, 'DynamicLayout.LBL_LIST_DATA_FORMAT' , 'DATA_FORMAT'     , 'DATA_FORMAT'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.GridView.PopupView'  , 5, 'DynamicLayout.LBL_LIST_DATA_FIELD'  , 'DATA_FIELD'      , 'DATA_FIELD'      , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'DynamicLayout.GridView.PopupView'  , 6, 'DynamicLayout.LBL_LIST_HEADER_TEXT' , 'HEADER_TEXT'     , 'HEADER_TEXT'     , '25%';
end -- if;
GO

-- 04/27/2012 Paul.  New images popup for use with CKEditor. 
-- 08/15/2014 Paul.  Display image. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailImages.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailImages.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailImages.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailImages.PopupView', 'EmailImages', 'vwEMAIL_IMAGES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailImages.PopupView'       , 1, 'Notes.LBL_LIST_FILENAME'                  , 'FILENAME'        , 'FILENAME'        , '50%', 'listViewTdLinkS1', 'ID FILENAME', 'SelectImage(''{0}'', ''{1}'');', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailImages.PopupView'       , 2, 'Notes.LBL_LIST_FILE_MIME_TYPE'            , 'FILE_MIME_TYPE'  , 'FILE_MIME_TYPE'  , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailImages.PopupView'       , 3, 'EmailClient.LBL_LIST_SIZE'                , 'FILE_SIZE'       , 'FILE_SIZE'       , '20%';
/* -- #if IBM_DB2
	exec dbo.spGRIDVIEWS_COLUMNS_Update in_ID, null, 'EmailImages.PopupView' , 4, 'BoundColumn', 'EmailClient.LBL_LIST_IMAGE', null, null, null, null, null, null, 'ID', 'Image', null, '~/Images/EmailImage.aspx?ID=', null, null, null, null, null, null;
-- #endif IBM_DB2 */
/* -- #if Oracle
	exec dbo.spGRIDVIEWS_COLUMNS_Update in_ID, null, 'EmailImages.PopupView' , 4, 'BoundColumn', 'EmailClient.LBL_LIST_IMAGE', null, null, null, null, null, null, 'ID', 'Image', null, '~/Images/EmailImage.aspx?ID=', null, null, null, null, null, null;
-- #endif Oracle */
-- #if SQL_Server /*
	exec dbo.spGRIDVIEWS_COLUMNS_Update null, null, 'EmailImages.PopupView' , 4, 'BoundColumn', 'EmailClient.LBL_LIST_IMAGE', null, null, null, null, null, null, 'ID', 'Image', null, '~/Images/EmailImage.aspx?ID=', null, null, null, null, null, null;
-- #endif SQL_Server */
end -- if;
GO

-- 11/23/2014 Paul.  Add ChatChannels module. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatChannels.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly             'ChatChannels.PopupView', 'ChatChannels', 'vwCHAT_CHANNELS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatChannels.PopupView'    ,  1, 'ChatChannels.LBL_LIST_NAME'              , 'NAME'            , 'NAME'            , '69%', 'listViewTdLinkS1', 'ID NAME', 'SelectChatChannel(''{0}'', ''{1}'');', null, 'ChatChannels', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatChannels.PopupView'    ,  2, '.LBL_LIST_ASSIGNED_USER'                 , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatChannels.PopupView'    ,  3, 'Teams.LBL_LIST_TEAM'                     , 'TEAM_NAME'       , 'TEAM_NAME'       , '20%';
end -- if;
GO

-- 03/15/2016 Paul.  Make better use of the activities list by showing all. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Activities.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Activities.PopupView'    , 'Activities'    , 'vwACTIVITIES'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.PopupView'       ,  1, 'Activities.LBL_LIST_ACTIVITY_TYPE'        , 'ACTIVITY_TYPE'   , 'ACTIVITY_TYPE'   ,  '5%', 'activities_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.PopupView'       ,  2, 'Calls.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          ,  '9%', 'activity_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.PopupView'       ,  3, 'Activities.LBL_LIST_DIRECTION'            , 'DIRECTION'       , 'DIRECTION'       ,  '5%', 'activity_direction_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.PopupView'       ,  4, 'Activities.LBL_LIST_SUBJECT'              , 'NAME'            , 'NAME'            , '20%' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.PopupView'       ,  5, 'Activities.LBL_LIST_RELATED_TO'           , 'PARENT_NAME'     , 'PARENT_NAME'     , '15%' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.PopupView'       ,  6, 'Activities.LBL_LIST_DATE_START'           , 'DATE_START'      , 'DATE_START'      , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.PopupView'       ,  7, 'Activities.LBL_LIST_DATE_DUE'             , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.PopupView'       ,  8, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'   , 'DATE_MODIFIED'   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.PopupView'       ,  9, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.PopupView'       , 10, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end -- if;
GO

-- 04/13/2016 Paul.  Add ZipCodes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ZipCodes.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ZipCodes.PopupView', 'ZipCodes', 'vwZIPCODES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ZipCodes.PopupView'         , 1, 'ZipCodes.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID NAME', 'SelectZipCode(''{0}'', ''{1}'');', null, 'ZipCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupView'         , 2, 'ZipCodes.LBL_LIST_CITY'                    , 'CITY'            , 'CITY'            , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupView'         , 3, 'ZipCodes.LBL_LIST_STATE'                   , 'STATE'           , 'STATE'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupView'         , 4, 'ZipCodes.LBL_LIST_COUNTRY'                 , 'COUNTRY'         , 'COUNTRY'         , '20%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.PopupAddressView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.PopupAddressView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ZipCodes.PopupAddressView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ZipCodes.PopupAddressView', 'ZipCodes', 'vwZIPCODES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ZipCodes.PopupAddressView'  , 1, 'ZipCodes.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'NAME CITY STATE COUNTRY', 'SelectZipCodeAddress(''{0}'', ''{1}'', ''{2}'', ''{3}'');', null, 'ZipCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupAddressView'  , 2, 'ZipCodes.LBL_LIST_CITY'                    , 'CITY'            , 'CITY'            , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupAddressView'  , 3, 'ZipCodes.LBL_LIST_STATE'                   , 'STATE'           , 'STATE'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ZipCodes.PopupAddressView'  , 4, 'ZipCodes.LBL_LIST_COUNTRY'                 , 'COUNTRY'         , 'COUNTRY'         , '20%';
end -- if;
GO

-- 05/12/2016 Paul.  Add support for Tags. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tags.PopupView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tags.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tags.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tags.PopupView', 'Tags', 'vwTAGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tags.PopupView'             ,  1, 'Tags.LBL_LIST_NAME'                       , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectTag(''{0}'', ''{1}'');', null, 'Tags', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tags.PopupView'             ,  2, 'Tags.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'     , 'DESCRIPTION'     , '65%';
end -- if;
GO

-- 08/01/2016 Paul.  Roles needed for BPMN. 
-- 10/30/2020 Paul.  Add the DESCRIPTION for the React Client. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ACLRoles.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ACLRoles.PopupView', 'ACLRoles', 'vwACL_ROLES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ACLRoles.PopupView'         ,  1, 'ACLRoles.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '49%', 'listViewTdLinkS1', 'ID NAME', 'SelectACLRole(''{0}'', ''{1}'');', null, 'ACLRoles', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ACLRoles.PopupView'         ,  2, 'Tags.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'     , 'DESCRIPTION'     , '49%';
end else begin
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.PopupView' and DATA_FIELD = 'DESCRIPTION' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH    = '49%'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'ACLRoles.PopupView'
		   and DATA_FIELD         = 'NAME'
		   and ITEMSTYLE_WIDTH    = '100%'
		   and DELETED            = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ACLRoles.PopupView'         ,  2, 'Tags.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'     , 'DESCRIPTION'     , '49%';
	end -- if;
end -- if;
GO

-- 06/07/2017 Paul.  Add support for NAICS Codes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.PopupView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS NAICSCodes.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'NAICSCodes.PopupView', 'NAICSCodes', 'vwNAICS_CODES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'NAICSCodes.PopupView'       ,  1, 'NAICSCodes.LBL_LIST_NAME'                 , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID NAME', 'SelectNAICSCode(''{0}'', ''{1}'');', null, 'NAICSCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NAICSCodes.PopupView'       ,  2, 'NAICSCodes.LBL_LIST_DESCRIPTION'          , 'DESCRIPTION'     , 'DESCRIPTION'     , '75%';
end -- if;
GO

-- 03/25/2020 Paul.  The React Client needs a Dashboard PopupView for the ReportDesigner. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Dashboard.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Dashboard.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Dashboard.PopupView', 'Dashboard', 'vwDASHBOARDS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Dashboard.PopupView'         , 1, 'Dashboard.LBL_NAME'                       , 'NAME'            , 'NAME'            , '99%', 'listViewTdLinkS1', 'ID NAME', 'SelectDashboard''{1}'');', null, null, null;
end -- if;
GO

-- 05/01/2020 Paul.  The React Client needs an Email Popup list for Emails.EditView. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.PopupEmailAddresses' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.PopupEmailAddresses';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.PopupEmailAddresses', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.PopupEmailAddresses', 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectContact(''{0}'', ''{1}'');', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.PopupEmailAddresses', 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'          , 'EMAIL1'          , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.PopupEmailAddresses', 3, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL2'          , 'EMAIL2'          , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.PopupEmailAddresses', 4, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.PopupEmailAddresses', 5, 'Emails.LBL_LIST_TYPE'                     , 'ADDRESS_TYPE'    , 'ADDRESS_TYPE'    , '10%', 'moduleListSingular';
end -- if;
GO

-- 10/17/2020 Paul.  The React Client needs to select from a list of terms. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Terminology.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Terminology.PopupView', 'Terminology', 'vwTERMINOLOGY_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Terminology.PopupView'       , 1, 'Terminology.LBL_LIST_NAME'              , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'NAME NAME', 'SelectTerm(''{0}'', ''{1}'');', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Terminology.PopupView'       , 2, 'Terminology.LBL_LIST_DISPLAY_NAME'      , 'DISPLAY_NAME'    , 'DISPLAY_NAME'    , '40%', 'countries_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.PopupView'       , 3, 'Terminology.LBL_LIST_LIST_ORDER'        , 'LIST_ORDER'      , 'LIST_ORDER'      , '15%';
end -- if;
GO

-- 02/05/2023 Paul.  The React Client needs an Sms Popup list for SmsMessages.EditView. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.PopupSmsNumbers' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SmsMessages.PopupSmsNumbers';
	exec dbo.spGRIDVIEWS_InsertOnly           'SmsMessages.PopupSmsNumbers', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'SmsMessages.PopupSmsNumbers', 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectContact(''{0}'', ''{1}'');', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.PopupSmsNumbers', 2, 'Contacts.LBL_LIST_PHONE_MOBILE'           , 'PHONE_MOBILE'    , 'PHONE_MOBILE'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.PopupSmsNumbers', 4, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'SmsMessages.PopupSmsNumbers', 5, 'SmsMessages.LBL_LIST_TYPE'                , 'MODULE_TYPE'     , 'MODULE_TYPE'     , '15%', 'moduleListSingular';
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

call dbo.spGRIDVIEWS_COLUMNS_PopupViews()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_PopupViews')
/

-- #endif IBM_DB2 */

