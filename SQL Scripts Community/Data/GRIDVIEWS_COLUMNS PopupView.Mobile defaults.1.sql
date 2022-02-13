

print 'GRIDVIEWS_COLUMNS PopupView.Mobile defaults';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.PopupView.Mobile'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.PopupView.Mobile', 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.PopupView.Mobile'          , 1, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'            , 'NAME'            , '45%', 'listViewTdLinkS1', 'ID NAME', 'SelectAccount(''{0}'', ''{1}'');', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.PopupView.Mobile'          , 2, 'Accounts.LBL_LIST_CITY'                   , 'CITY'            , 'CITY'            , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.PopupView.Mobile'          , 3, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'           , 'PHONE'           , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.PopupView.Mobile', 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.PopupView.Mobile'              , 1, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'      , 'BUG_NUMBER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.PopupView.Mobile'              , 2, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectBug(''{0}'', ''{1}'');', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.PopupView.Mobile'              , 3, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'          , 'STATUS'          , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.PopupView.Mobile'              , 4, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'            , 'TYPE'            , '10%', 'bug_type_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.PopupView.Mobile', 'Calls', 'vwCALLS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.PopupView.Mobile'             , 1, 'Calls.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectCall(''{0}'', ''{1}'');', null, 'Calls', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.PopupView.Mobile'             , 2, 'Calls.LBL_LIST_DATE'                      , 'DATE_START'      , 'DATE_START'      , '30%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.PopupView.Mobile', 'Campaigns', 'vwCAMPAIGNS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.PopupView.Mobile'         , 1, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectCampaign(''{0}'', ''{1}'');', null, 'Campaigns', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.PopupView.Mobile'         , 2, 'Campaigns.LBL_LIST_STATUS'                , 'STATUS'          , 'STATUS'          , '10%', 'campaign_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.PopupView.Mobile'         , 3, 'Campaigns.LBL_LIST_TYPE'                  , 'CAMPAIGN_TYPE'   , 'CAMPAIGN_TYPE'   , '10%', 'campaign_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.PopupView.Mobile'         , 4, 'Campaigns.LBL_LIST_END_DATE'              , 'END_DATE'        , 'END_DATE'        , '10%', 'Date';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PreviewView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.PreviewView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.PreviewView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.PreviewView', 'Campaigns', 'vwCAMPAIGNS_SendEmail';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PreviewView'              , 0, 'ProspectLists.LBL_LIST_LIST_TYPE'         , 'RELATED_TYPE'    , 'RELATED_TYPE'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.PreviewView'              , 1, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'RELATED_NAME'    , 'RELATED_NAME'    , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.PreviewView'              , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'          , 'EMAIL1'          , '40%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.PopupView.Mobile', 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.PopupView.Mobile'             , 1, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID NAME', 'SelectCase(''{0}'', ''{1}'');'  , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.PopupView.Mobile'             , 2, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectCase(''{0}'', ''{1}'');'  , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.PopupView.Mobile'             , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.PopupView.Mobile'             , 4, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.PopupView.Mobile', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.PopupView.Mobile'          , 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectContact(''{0}'', ''{1}'');', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView.Mobile'          , 2, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.PopupView.Mobile'          , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.PopupView.Mobile';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.PopupView.Mobile', 'Documents', 'vwDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.PopupView.Mobile'         , 1, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID NAME', 'SelectDocument(''{0}'', ''{1}'');', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.PopupView.Mobile'         , 2, 'Documents.LBL_LIST_REVISION'              , 'REVISION'        , 'REVISION'        , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.PopupView.Mobile'         , 3, 'Documents.LBL_LIST_STATUS'                , 'STATUS_ID'       , 'STATUS_ID'       , '20%', 'document_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.PopupView.Mobile', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailTemplates.PopupView.Mobile'    , 1, 'EmailTemplates.LBL_LIST_NAME'             , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectEmailTemplate(''{0}'', ''{1}'');', null, 'EmailTemplates', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.PopupView.Mobile'    , 2, 'EmailTemplates.LBL_LIST_DESCRIPTION'      , 'DESCRIPTION'     , 'DESCRIPTION'     , '55%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.PopupView.Mobile', 'Employees', 'vwEMPLOYEES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.PopupView.Mobile'         , 1, 'Employees.LBL_LIST_NAME'                  , 'FULL_NAME'       , 'FULL_NAME'       , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectEmployee(''{0}'', ''{1}'');', null, 'Employees', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.PopupView.Mobile'         , 2, 'Employees.LBL_LIST_USER_NAME'             , 'USER_NAME'       , 'USER_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.PopupView.Mobile'         , 3, 'Employees.LBL_LIST_EMAIL'                 , 'EMAIL1'          , 'EMAIL1'          , '20%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.PopupView.Mobile', 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.PopupView.Mobile'             , 1, 'Leads.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectLead(''{0}'', ''{1}'');', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.PopupView.Mobile'             , 2, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '40%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.PopupView.Mobile', 'Meetings', 'vwMEETINGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.PopupView.Mobile'          , 1, 'Meetings.LBL_LIST_SUBJECT'                , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectMeeting(''{0}'', ''{1}'');', null, 'Meetings', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.PopupView.Mobile'          , 2, 'Meetings.LBL_LIST_DATE'                   , 'DATE_START'      , 'DATE_START'      , '30%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.PopupView.Mobile', 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.PopupView.Mobile'     , 1, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectOpportunity(''{0}'', ''{1}'');', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.PopupView.Mobile'     , 2, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.PopupView.Mobile'     , 3, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'     , 'DATE_CLOSED'     , '10%', 'Date'    ;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.PopupView.Mobile', 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.PopupView.Mobile'           , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '60%', 'listViewTdLinkS1', 'ID NAME', 'SelectProject(''{0}'', ''{1}'');', null, 'Project', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.PopupView.Mobile', 'ProjectTask', 'vwPROJECT_TASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.PopupView.Mobile'       , 2, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID NAME', 'SelectProjectTask(''{0}'', ''{1}'');', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.PopupView.Mobile'       , 3, 'ProjectTask.LBL_LIST_PARENT_NAME'         , 'PROJECT_NAME'    , 'PROJECT_NAME'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.PopupView.Mobile'       , 4, 'ProjectTask.LBL_LIST_DUE_DATE'            , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.PopupView.Mobile'       , 5, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'          , 'STATUS'          , '10%', 'project_task_status_options';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.PopupView.Mobile', 'ProspectLists', 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.PopupView.Mobile'     , 1, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID NAME', 'SelectProspectList(''{0}'', ''{1}'');', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.PopupView.Mobile'     , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'     , 'DESCRIPTION'     , '50%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.PopupView.Mobile', 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.PopupView.Mobile'         , 1, 'Prospects.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID NAME', 'SelectProspect(''{0}'', ''{1}'');', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.PopupView.Mobile'         , 2, 'Prospects.LBL_LIST_TITLE'                 , 'TITLE'           , 'TITLE'           , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.PopupView.Mobile'         , 3, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'          , 'EMAIL1'          , '25%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.PopupView.Mobile', 'Tasks', 'vwTASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.PopupView.Mobile'             , 1, 'Tasks.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID NAME', 'SelectTask(''{0}'', ''{1}'');', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.PopupView.Mobile'             , 2, 'Tasks.LBL_LIST_DUE_DATE'                  , 'DATE_DUE'        , 'DATE_DUE'        , '20%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.PopupView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.PopupView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.PopupView.Mobile', 'Users', 'vwUSERS_ASSIGNED_TO_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupView.Mobile'             , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '40%', 'listViewTdLinkS1', 'ID FULL_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.PopupView.Mobile'             , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '40%', 'listViewTdLinkS1', 'ID USER_NAME', 'SelectUser(''{0}'', ''{1}'');', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.PopupView.Mobile'             , 3, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '20%';
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

call dbo.spGRIDVIEWS_COLUMNS_PopupViewsMobile()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_PopupViewsMobile')
/

-- #endif IBM_DB2 */

