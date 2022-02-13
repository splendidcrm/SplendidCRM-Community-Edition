

print 'GRIDVIEWS_COLUMNS ListView.Mobile defaults';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.ListView.Mobile'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.ListView.Mobile'      , 'Accounts'      , 'vwACCOUNTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.ListView.Mobile'          , 1, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Mobile'          , 2, 'Accounts.LBL_LIST_CITY'                   , 'CITY'            , 'CITY'            , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Mobile'          , 3, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'           , 'PHONE'           , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.ListView.Mobile'          , 'Bugs'          , 'vwBUGS_List'          ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView.Mobile'              , 1, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'      , 'BUG_NUMBER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.ListView.Mobile'              , 2, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView.Mobile'              , 3, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'          , 'STATUS'          , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView.Mobile'              , 4, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'            , 'TYPE'            , '10%', 'bug_type_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.ListView.Mobile'         , 'Calls'         , 'vwCALLS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ListView.Mobile'             , 1, 'Calls.LBL_LIST_CLOSE'                     , 'STATUS'          , 'STATUS'          , '10%', 'call_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ListView.Mobile'             , 2, 'Calls.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Calls/view.aspx?id={0}', null, 'Calls', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ListView.Mobile'             , 3, 'Calls.LBL_LIST_DATE'                      , 'DATE_START'      , 'DATE_START'      , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.ListView.Mobile'     , 'Campaigns'     , 'vwCAMPAIGNS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.ListView.Mobile'         , 1, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Campaigns/view.aspx?id={0}', null, 'Campaigns', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.ListView.Mobile'         , 2, 'Campaigns.LBL_LIST_STATUS'                , 'STATUS'          , 'STATUS'          , '10%', 'campaign_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.ListView.Mobile'         , 3, 'Campaigns.LBL_LIST_TYPE'                  , 'CAMPAIGN_TYPE'   , 'CAMPAIGN_TYPE'   , '10%', 'campaign_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.ListView.Mobile'         , 4, 'Campaigns.LBL_LIST_END_DATE'              , 'END_DATE'        , 'END_DATE'        , '10%', 'Date';
end -- if;
GO

-- 02/08/2008 Paul.  Fix ACCOUNT_ASSIGNED_USER_ID.  Module name should be singular. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.ListView.Mobile'         , 'Cases'         , 'vwCASES_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView.Mobile'             , 1, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView.Mobile'             , 2, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView.Mobile'             , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ListView.Mobile'             , 4, 'Cases.LBL_LIST_PRIORITY'                  , 'PRIORITY'        , 'PRIORITY'        , '10%', 'case_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ListView.Mobile'             , 5, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'case_status_dom';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView.Mobile' and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Fix GRIDVIEWS_COLUMNS Cases.ListView.Mobile ACCOUNT_ASSIGNED_USER_ID';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACCOUNT_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Cases.ListView.Mobile'
		   and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID'
		   and DELETED = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ListView.Mobile'      , 'Contacts'      , 'vwCONTACTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView.Mobile'          , 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Mobile'          , 2, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView.Mobile'          , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Mobile'          , 4, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.ListView.Mobile'     , 'Documents'     , 'vwDOCUMENTS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.ListView.Mobile'         , 1, 'Documents.LBL_LIST_DOCUMENT'              , 'NAME'            , 'NAME'            , '23%', 'listViewTdLinkS1', 'ID', '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView.Mobile'         , 2, 'Documents.LBL_LIST_CATEGORY'              , 'CATEGORY_ID'     , 'CATEGORY_ID'     , '11%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView.Mobile'         , 3, 'Documents.LBL_LIST_SUBCATEGORY'           , 'SUBCATEGORY_ID'  , 'SUBCATEGORY_ID'  , '11%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView.Mobile'         , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'        , 'REVISION'        , '11%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ListView.Mobile'        , 'Emails'        , 'vwEMAILS_List'        ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView.Mobile'            , 1, 'Emails.LBL_LIST_SUBJECT'                  , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Emails/view.aspx?id={0}', null, 'Emails', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView.Mobile'            , 2, 'Emails.LBL_LIST_CONTACT'                  , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView.Mobile'            , 3, 'Emails.LBL_LIST_RELATED_TO'               , 'PARENT_NAME'     , 'PARENT_NAME'     , '20%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Mobile'            , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Mobile'            , 5, 'Emails.LBL_LIST_TYPE'                     , 'TYPE_TERM'       , 'TYPE_TERM'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ListView.Mobile'            , 6, '.LBL_LIST_CREATED'                        , 'DATE_ENTERED'    , 'DATE_ENTERED'    , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.ListView.Mobile'     , 'Employees'     , 'vwEMPLOYEES_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.ListView.Mobile'         , 1, 'Employees.LBL_LIST_NAME'                  , 'FULL_NAME'       , 'FULL_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Employees/view.aspx?id={0}', null, 'Employees', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.ListView.Mobile'         , 4, 'Employees.LBL_LIST_EMAIL'                 , 'EMAIL1'          , 'EMAIL1'          , '15%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Mobile'         , 5, 'Employees.LBL_LIST_PRIMARY_PHONE'         , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Mobile'         , 7, 'Employees.LBL_LIST_USER_NAME'             , 'USER_NAME'       , 'USER_NAME'       , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ListView.Mobile'         , 'Leads'         , 'vwLEADS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ListView.Mobile'             , 1, 'Leads.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.ListView.Mobile'             , 2, 'Leads.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'lead_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Mobile'             , 3, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ListView.Mobile'             , 4, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Mobile'             , 5, 'Leads.LBL_LIST_PHONE'                     , 'PHONE_WORK'      , 'PHONE_WORK'      , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.ListView.Mobile'      , 'Meetings'      , 'vwMEETINGS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Meetings.ListView.Mobile'          , 1, 'Meetings.LBL_LIST_CLOSE'                  , 'STATUS'          , 'STATUS'          , '10%', 'meeting_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ListView.Mobile'          , 2, 'Meetings.LBL_LIST_SUBJECT'                , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Meetings/view.aspx?id={0}', null, 'Meetings', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ListView.Mobile'          , 3, 'Meetings.LBL_LIST_DATE'                   , 'DATE_START'      , 'DATE_START'      , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Notes.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Notes.ListView.Mobile'         , 'Notes'         , 'vwNOTES_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ListView.Mobile'             , 1, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Notes/view.aspx?id={0}', null, 'Notes', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ListView.Mobile'             , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.ListView.Mobile' , 'Opportunities' , 'vwOPPORTUNITIES_List' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView.Mobile'     , 1, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView.Mobile'     , 2, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.ListView.Mobile'     , 3, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'     , 'SALES_STAGE'     , '10%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView.Mobile'     , 4, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR' , 'AMOUNT_USDOLLAR' , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView.Mobile'     , 5, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'     , 'DATE_CLOSED'     , '10%', 'Date'    ;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView.Mobile';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ListView.Mobile'       , 'Project'       , 'vwPROJECTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.ListView.Mobile'           , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'                  , 'NAME'                , '23%', 'listViewTdLinkS1', 'ID'         , '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
-- 01/13/2010 Paul.  SugarCRM nolonger displayes the effort fields. 
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView.Mobile'           , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT', null                  , '23%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView.Mobile'           , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'   , null                  , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView.Mobile'           , 2, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'  , 'ESTIMATED_START_DATE', '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView.Mobile'           , 3, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'    , 'ESTIMATED_END_DATE'  , '15%', 'Date';
end else begin
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView.Mobile' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Project.ListView.Mobile: Add start date and end date.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX = COLUMN_INDEX + 2
		 where GRID_NAME    = 'Project.ListView.Mobile'
		   and COLUMN_INDEX >= 2
		   and DELETED      = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView.Mobile'           , 2, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'  , 'ESTIMATED_START_DATE', '15%', 'Date';
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView.Mobile'           , 3, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'    , 'ESTIMATED_END_DATE'  , '15%', 'Date';
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.ListView.Mobile'   , 'ProjectTask'   , 'vwPROJECT_TASKS_List' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Mobile'       , 1, 'ProjectTask.LBL_LIST_ORDER_NUMBER'        , 'ORDER_NUMBER'    , 'ORDER_NUMBER'    , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.ListView.Mobile'       , 2, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.ListView.Mobile'       , 3, 'ProjectTask.LBL_LIST_PARENT_NAME'         , 'PROJECT_NAME'    , 'PROJECT_NAME'    , '20%', 'listViewTdLinkS1', 'PROJECT_ID' , '~/Projects/view.aspx?id={0}', null, 'Project', 'PROJECT_ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.ListView.Mobile' , 'ProspectLists' , 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.ListView.Mobile'     , 1, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProspectLists.ListView.Mobile'     , 2, 'ProspectLists.LBL_LIST_LIST_TYPE'         , 'LIST_TYPE'       , 'LIST_TYPE'       , '10%', 'prospect_list_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView.Mobile'     , 3, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'     , 'DESCRIPTION'     , '50%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ListView.Mobile'     , 'Prospects'     , 'vwPROSPECTS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ListView.Mobile'         , 1, 'Prospects.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Mobile'         , 2, 'Prospects.LBL_LIST_TITLE'                 , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ListView.Mobile'         , 3, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'          , 'EMAIL1'          , '35%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Mobile'         , 4, 'Prospects.LBL_LIST_PHONE'                 , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.ListView.Mobile'         , 'Tasks'         , 'vwTASKS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ListView.Mobile'             , 1, 'Tasks.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Tasks/view.aspx?id={0}', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ListView.Mobile'             , 2, 'Tasks.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMarketing.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailMarketing.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailMarketing.ListView.Mobile', 'EmailMarketing', 'vwEMAIL_MARKETING_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView.Mobile'    , 1, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'       , 'CAMPAIGN_NAME'       , '20%', 'listViewTdLinkS1', 'CAMPAIGN_ID', '~/Campaigns/view.aspx?id={0}'       , null, 'Campaigns'     , 'CAMPAIGN_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView.Mobile'    , 2, 'EmailMarketing.LBL_LIST_NAME'             , 'NAME'                , 'NAME'                , '30%', 'listViewTdLinkS1', 'ID'         , '~/EmailMarketing/view.aspx?id={0}'  , null, 'EmailMarketing', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailMarketing.ListView.Mobile'    , 3, 'EmailMarketing.LBL_LIST_DATE_START'       , 'DATE_START'          , 'DATE_START'          , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'EmailMarketing.ListView.Mobile'    , 4, 'EmailMarketing.LBL_LIST_STATUS'           , 'STATUS'              , 'STATUS'              , '15%', 'email_marketing_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView.Mobile'    , 5, 'EmailMarketing.LBL_LIST_TEMPLATE_NAME'    , 'TEMPLATE_NAME'       , 'TEMPLATE_NAME'       , '20%', 'listViewTdLinkS1', 'TEMPLATE_ID', '~/EmailTemplates/view.aspx?id={0}'  , null, 'EmailTemplates', null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.ListView.Mobile' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.ListView.Mobile';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.ListView.Mobile', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailTemplates.ListView.Mobile'    , 1, 'EmailTemplates.LBL_LIST_NAME'             , 'NAME'                , 'NAME'                , '35%', 'listViewTdLinkS1', 'ID'         , 'view.aspx?id={0}'           , null, 'EmailTemplates', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.ListView.Mobile'    , 2, 'EmailTemplates.LBL_LIST_DESCRIPTION'      , 'DESCRIPTION'         , 'DESCRIPTION'         , '55%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailTemplates.ListView.Mobile'    , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'       , 'DATE_MODIFIED'       , '20%', 'Date';
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

call dbo.spGRIDVIEWS_COLUMNS_ListViewsMobile()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ListViewsMobile')
/

-- #endif IBM_DB2 */

