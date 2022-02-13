

print 'GRIDVIEWS_COLUMNS ArchiveView SubPanel default';
set nocount on;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME like '%.ArchiveView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Activities.ArchiveView', 'Accounts', 'vwACCOUNTS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.ArchiveView'                 , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Activities.ArchiveView'                 , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.ArchiveView'                 , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.ArchiveView'                 , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW' , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Activities.ArchiveView'                 , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Bugs.ArchiveView', 'Accounts', 'vwACCOUNTS_BUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Bugs.ArchiveView'                   , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Bugs.ArchiveView'                   , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs.ArchiveView'                   , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs.ArchiveView'                   , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs.ArchiveView'                   , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Cases.ArchiveView', 'Accounts', 'vwACCOUNTS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases.ArchiveView'                  , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases.ArchiveView'                  , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases.ArchiveView'                  , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Cases.ArchiveView'                  , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Contacts.ArchiveView', 'Accounts', 'vwACCOUNTS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contacts.ArchiveView'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Contacts.ArchiveView'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contacts.ArchiveView'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Contacts.ArchiveView'               , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	-- MODIFIED_USER_ID, GRID_NAME, COLUMN_INDEX, ITEMSTYLE_WIDTH, ITEMSTYLE_CSSCLASS, ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_VERTICAL_ALIGN, ITEMSTYLE_WRAP
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Accounts.Contacts.ArchiveView'         , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Leads.ArchiveView', 'Accounts', 'vwACCOUNTS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Leads.ArchiveView'                  , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   ,'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Leads.ArchiveView'                  , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             ,'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Leads.ArchiveView'                  , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            ,'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Leads.ArchiveView'                  , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION','LEAD_SOURCE_DESCRIPTION', '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Opportunities.ArchiveView', 'Accounts', 'vwACCOUNTS_OPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Opportunities.ArchiveView'          , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Opportunities.ArchiveView'          , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW'    , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Opportunities.ArchiveView'          , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Project.ArchiveView', 'Accounts', 'vwACCOUNTS_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Project.ArchiveView'                , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project.ArchiveView'                , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project.ArchiveView'                , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project.ArchiveView'                , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Documents.ArchiveView', 'Accounts', 'vwACCOUNTS_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Documents.ArchiveView'              , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'          , 'DOCUMENT_NAME'          , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents.ArchiveView'              , 1, 'Documents.LBL_LIST_IS_TEMPLATE'           , 'IS_TEMPLATE'            , 'IS_TEMPLATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents.ArchiveView'              , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'         , 'TEMPLATE_TYPE'          , 'TEMPLATE_TYPE'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents.ArchiveView'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents.ArchiveView'              , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Accounts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Accounts.ArchiveView', 'Bugs', 'vwBUGS_ACCOUNTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Accounts.ArchiveView'                   , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Accounts.ArchiveView'                   , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Accounts.ArchiveView'                   , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Activities.ArchiveView', 'Bugs', 'vwBUGS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.ArchiveView'                     , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.Activities.ArchiveView'                     , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.ArchiveView'                     , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.ArchiveView'                     , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'BUG_NAME'               , 'BUG_NAME'               , '20%', 'listViewTdLinkS1', 'BUG_ID ARCHIVE_VIEW'     , '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'BUG_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.Activities.ArchiveView'                     , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Cases.ArchiveView', 'Bugs', 'vwBUGS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases.ArchiveView'                      , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases.ArchiveView'                      , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases.ArchiveView'                      , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.Cases.ArchiveView'                      , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Contacts.ArchiveView', 'Bugs', 'vwBUGS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Contacts.ArchiveView'                   , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Contacts.ArchiveView'                   , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Contacts.ArchiveView'                   , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Contacts.ArchiveView'                   , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Bugs.Contacts.ArchiveView'             , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Documents.ArchiveView', 'Bugs', 'vwBUGS_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Documents.ArchiveView'                  , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'          , 'DOCUMENT_NAME'          , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents.ArchiveView'                  , 1, 'Documents.LBL_LIST_IS_TEMPLATE'           , 'IS_TEMPLATE'            , 'IS_TEMPLATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents.ArchiveView'                  , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'         , 'TEMPLATE_TYPE'          , 'TEMPLATE_TYPE'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents.ArchiveView'                  , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents.ArchiveView'                  , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Contacts.ArchiveView', 'Calls', 'vwCALLS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Contacts.ArchiveView'                  , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Contacts.ArchiveView'                  , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Contacts.ArchiveView'                  , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Contacts.ArchiveView'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Contacts.ArchiveView'            , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Leads.ArchiveView', 'Calls', 'vwCALLS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Leads.ArchiveView'                     , 0, 'Leads.LBL_LIST_LEAD_NAME'                 , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Leads.ArchiveView'                     , 1, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Leads.ArchiveView'                     , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Leads.ArchiveView'                     , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Leads.ArchiveView'               , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Users.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Users.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Users.ArchiveView', 'Calls', 'vwCALLS_USERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Users.ArchiveView'                     , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID ARCHIVE_VIEW', '~/Users/view.aspx?ID={0}&ArchiveView={1}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Users.ArchiveView'                     , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Users.ArchiveView'                     , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Users.ArchiveView'                     , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Users.ArchiveView'               , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Notes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Notes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Notes.ArchiveView', 'Calls', 'vwCALLS_NOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes.ArchiveView'                     , 0, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Notes/view.aspx?ID={0}&ArchiveView={1}'   , null, 'Notes'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes.ArchiveView'                     , 1, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '10%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes.ArchiveView'                     , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'            , 'PARENT_NAME'            , '10%', 'listViewTdLinkS1', 'PARENT_ID ARCHIVE_VIEW'  , '~/Parents/view.aspx?ID={0}&ArchiveView={1}' , null, 'Parents' , 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.Notes.ArchiveView'                     , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Activities.ArchiveView', 'Cases', 'vwCASES_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.ArchiveView'                    , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Activities.ArchiveView'                    , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.ArchiveView'                    , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.ArchiveView'                    , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'CASE_NAME'              , 'CASE_NAME'              , '20%', 'listViewTdLinkS1', 'CASE_ID ARCHIVE_VIEW'    , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'CASE_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Activities.ArchiveView'                    , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Bugs.ArchiveView', 'Cases', 'vwCASES_BUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Bugs.ArchiveView'                      , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Bugs.ArchiveView'                      , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs.ArchiveView'                      , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs.ArchiveView'                      , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs.ArchiveView'                      , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Contacts.ArchiveView', 'Cases', 'vwCASES_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Contacts.ArchiveView'                  , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Contacts.ArchiveView'                  , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Contacts.ArchiveView'                  , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Contacts.ArchiveView'                  , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Cases.Contacts.ArchiveView'            , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Project.ArchiveView', 'Cases', 'vwCASES_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Project.ArchiveView'                   , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Project.ArchiveView'                   , 1, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'   , 'ESTIMATED_START_DATE'   , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Project.ArchiveView'                   , 2, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'     , 'ESTIMATED_END_DATE'     , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project.ArchiveView'                   , 3, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project.ArchiveView'                   , 4, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project.ArchiveView'                   , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Activities.ArchiveView', 'Contacts', 'vwCONTACTS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Activities.ArchiveView'             , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '60%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Activities.ArchiveView'             , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '20%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Activities.ArchiveView'             , 3, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '20%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Bugs.ArchiveView', 'Contacts', 'vwCONTACTS_BUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Bugs.ArchiveView'                   , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Bugs.ArchiveView'                   , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs.ArchiveView'                   , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs.ArchiveView'                   , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs.ArchiveView'                   , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Cases.ArchiveView', 'Contacts', 'vwCONTACTS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases.ArchiveView'                  , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases.ArchiveView'                  , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases.ArchiveView'                  , 2, '.LBL_LIST_CONTACT_NAME'                   , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '25%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Cases.ArchiveView'                  , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Leads.ArchiveView', 'Contacts', 'vwCONTACTS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Leads.ArchiveView'                  , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Leads.ArchiveView'                  , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Leads.ArchiveView'                  , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Leads.ArchiveView'                  , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Opportunities.ArchiveView', 'Contacts', 'vwCONTACTS_OPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Opportunities.ArchiveView'          , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Opportunities.ArchiveView'          , 1, '.LBL_LIST_CONTACT_NAME'                   , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '25%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW'    , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'     , null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Opportunities.ArchiveView'          , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Project.ArchiveView', 'Contacts', 'vwCONTACTS_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Project.ArchiveView'                , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project.ArchiveView'                , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project.ArchiveView'                , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project.ArchiveView'                , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ProspectLists.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ProspectLists.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ProspectLists.ArchiveView', 'Contacts', 'vwCONTACTS_PROSPECT_LISTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ProspectLists.ArchiveView'          , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/ProspectLists/view.aspx?id={0}&ArchiveView={1}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ProspectLists.ArchiveView'          , 1, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '40%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Documents.ArchiveView', 'Contacts', 'vwCONTACTS_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Documents.ArchiveView'              , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'          , 'DOCUMENT_NAME'          , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents.ArchiveView'              , 1, 'Documents.LBL_LIST_IS_TEMPLATE'           , 'IS_TEMPLATE'            , 'IS_TEMPLATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents.ArchiveView'              , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'         , 'TEMPLATE_TYPE'          , 'TEMPLATE_TYPE'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents.ArchiveView'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents.ArchiveView'              , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Documents.ArchiveView', 'Cases', 'vwCASES_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Documents.ArchiveView'                 , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'          , 'DOCUMENT_NAME'          , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents.ArchiveView'                 , 1, 'Documents.LBL_LIST_IS_TEMPLATE'           , 'IS_TEMPLATE'            , 'IS_TEMPLATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents.ArchiveView'                 , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'         , 'TEMPLATE_TYPE'          , 'TEMPLATE_TYPE'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents.ArchiveView'                 , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents.ArchiveView'                 , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Contacts.ArchiveView', 'Emails', 'vwEMAILS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Contacts.ArchiveView'                 , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Contacts.ArchiveView'                 , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Contacts.ArchiveView'                 , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Contacts.ArchiveView'                 , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Emails.Contacts.ArchiveView'           , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Users.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Users.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Users.ArchiveView', 'Emails', 'vwEMAILS_USERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Users.ArchiveView'                    , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID ARCHIVE_VIEW', '~/Users/view.aspx?ID={0}&ArchiveView={1}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Users.ArchiveView'                    , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Users.ArchiveView'                    , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Users.ArchiveView'                    , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Emails.Users.ArchiveView'              , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Accounts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Accounts.ArchiveView', 'Emails', 'vwEMAILS_ACCOUNTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Accounts.ArchiveView'                 , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Accounts.ArchiveView'                 , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Accounts.ArchiveView'                 , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Opportunities.ArchiveView', 'Emails', 'vwEMAILS_OPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Opportunities.ArchiveView'            , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '50%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Opportunities.ArchiveView'            , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '30%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW'    , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Opportunities.ArchiveView'            , 2, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'            , 'SALES_STAGE'            , '20%', 'sales_stage_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Leads.ArchiveView', 'Emails', 'vwEMAILS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Leads.ArchiveView'                    , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '20%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Leads.ArchiveView'                    , 1, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '15%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Leads.ArchiveView'                    , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Leads.ArchiveView'                    , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '40%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Cases.ArchiveView', 'Emails', 'vwEMAILS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases.ArchiveView'                    , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '10%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases.ArchiveView'                    , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Cases.ArchiveView'                    , 2, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases.ArchiveView'                    , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Cases.ArchiveView'                    , 4, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'bug_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Bugs.ArchiveView', 'Emails', 'vwEMAILS_BUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Bugs.ArchiveView'                     , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '10%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Bugs.ArchiveView'                     , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs.ArchiveView'                     , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '20%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs.ArchiveView'                     , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '20%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs.ArchiveView'                     , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '20%', 'bug_priority_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Project.ArchiveView', 'Emails', 'vwEMAILS_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Project.ArchiveView'                  , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project.ArchiveView'                  , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project.ArchiveView'                  , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project.ArchiveView'                  , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '25%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ProjectTask.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ProjectTask.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ProjectTask.ArchiveView', 'Emails', 'vwEMAILS_PROJECT_TASKS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ProjectTask.ArchiveView'              , 0, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/ProjectTasks/view.aspx?ID={0}&ArchiveView={1}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ProjectTask.ArchiveView'              , 1, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'    , 'PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.ProjectTask.ArchiveView'              , 2, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'                 , 'STATUS'                 , '15%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ProjectTask.ArchiveView'              , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ProjectTask.ArchiveView'              , 4, 'ProjectTask.LBL_LIST_DATE_DUE'            , 'DATE_DUE'               , 'DATE_DUE'               , '15%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Activities.ArchiveView', 'Leads', 'vwLEADS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.ArchiveView'                    , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.Activities.ArchiveView'                    , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.ArchiveView'                    , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.ArchiveView'                    , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'LEAD_NAME'              , 'LEAD_NAME'              , '20%', 'listViewTdLinkS1', 'LEAD_ID ARCHIVE_VIEW'    , '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'LEAD_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.Activities.ArchiveView'                    , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly             'Leads.Contacts.ArchiveView', 'Leads', 'vwLEADS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Leads.Contacts.ArchiveView'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'            , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Leads.Contacts.ArchiveView'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'            , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Leads.Contacts.ArchiveView'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'           , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Leads.Contacts.ArchiveView'               , 3, 'Contacts.LBL_LIST_PHONE'                   , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Leads.Contacts.ArchiveView'           , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Documents.ArchiveView', 'Leads', 'vwLEADS_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Documents.ArchiveView'                , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?id={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents.ArchiveView'                , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents.ArchiveView'                , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents.ArchiveView'                , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents.ArchiveView'                , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ProspectLists.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ProspectLists.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ProspectLists.ArchiveView', 'Leads', 'vwLEADS_PROSPECT_LISTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ProspectLists.ArchiveView'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/ProspectLists/view.aspx?id={0}&ArchiveView={1}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ProspectLists.ArchiveView'         , 1, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '40%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Contacts.ArchiveView', 'Meetings', 'vwMEETINGS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Contacts.ArchiveView'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Contacts.ArchiveView'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Contacts.ArchiveView'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Contacts.ArchiveView'               , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Contacts.ArchiveView'         , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Leads.ArchiveView', 'Meetings', 'vwMEETINGS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Leads.ArchiveView'                  , 0, 'Leads.LBL_LIST_LEAD_NAME'                 , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Leads.ArchiveView'                  , 1, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Leads.ArchiveView'                  , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Leads.ArchiveView'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Leads.ArchiveView'            , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Notes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Notes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Notes.ArchiveView', 'Meetings', 'vwMEETINGS_NOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes.ArchiveView'                  , 0, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Notes/view.aspx?ID={0}&ArchiveView={1}'   , null, 'Notes'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes.ArchiveView'                  , 1, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '10%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes.ArchiveView'                  , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'            , 'PARENT_NAME'            , '10%', 'listViewTdLinkS1', 'PARENT_ID ARCHIVE_VIEW'  , '~/Parents/view.aspx?ID={0}&ArchiveView={1}' , null, 'Parents' , 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.Notes.ArchiveView'                  , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Users.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Users.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Users.ArchiveView', 'Meetings', 'vwMEETINGS_USERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Users.ArchiveView'                  , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID ARCHIVE_VIEW', '~/Users/view.aspx?ID={0}&ArchiveView={1}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Users.ArchiveView'                  , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Users.ArchiveView'                  , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Users.ArchiveView'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Users.ArchiveView'            , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Activities.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.ArchiveView'            , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW'   , '~/Activities/view.aspx?ID={0}&ArchiveView={1}'   , null, 'Activities'   , 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Activities.ArchiveView'            , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.ArchiveView'            , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW'    , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'     , null, 'Contacts'     , 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.ArchiveView'            , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'OPPORTUNITY_NAME'       , 'OPPORTUNITY_NAME'       , '20%', 'listViewTdLinkS1', 'OPPORTUNITY_ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'OPPORTUNITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Activities.ArchiveView'            , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO


if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Contacts.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contacts.ArchiveView'          , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Contacts.ArchiveView'          , 1, 'Contacts.LBL_LIST_CONTACT_ROLE'           , 'CONTACT_ROLE'           , 'CONTACT_ROLE'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contacts.ArchiveView'          , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Contacts.ArchiveView'          , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.Contacts.ArchiveView'    , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Leads.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Leads.ArchiveView'             , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Leads.ArchiveView'             , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Leads.ArchiveView'             , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Leads.ArchiveView'             , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Project.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Project.ArchiveView'           , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project.ArchiveView'           , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project.ArchiveView'           , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project.ArchiveView'           , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Documents.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Documents.ArchiveView'         , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'          , 'DOCUMENT_NAME'          , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents.ArchiveView'         , 1, 'Documents.LBL_LIST_IS_TEMPLATE'           , 'IS_TEMPLATE'            , 'IS_TEMPLATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents.ArchiveView'         , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'         , 'TEMPLATE_TYPE'          , 'TEMPLATE_TYPE'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents.ArchiveView'         , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents.ArchiveView'         , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Accounts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Accounts.ArchiveView', 'Project', 'vwPROJECTS_ACCOUNTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Accounts.ArchiveView'                , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Accounts.ArchiveView'                , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Accounts.ArchiveView'                , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Activities.ArchiveView', 'Project', 'vwPROJECTS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.ArchiveView'                  , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.Activities.ArchiveView'                  , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.ArchiveView'                  , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.ArchiveView'                  , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_NAME'           , 'PROJECT_NAME'           , '20%', 'listViewTdLinkS1', 'PROJECT_ID ARCHIVE_VIEW' , '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'PROJECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Activities.ArchiveView'                  , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Contacts.ArchiveView', 'Project', 'vwPROJECTS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts.ArchiveView'                , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts.ArchiveView'                , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts.ArchiveView'                , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Contacts.ArchiveView'                , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Project.Contacts.ArchiveView'          , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Opportunities.ArchiveView', 'Project', 'vwPROJECTS_OPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Opportunities.ArchiveView'           , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Opportunities.ArchiveView'           , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW'    , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Opportunities.ArchiveView'           , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ProjectTask.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ProjectTask.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ProjectTask.ArchiveView', 'Project', 'vwPROJECTS_PROJECT_TASKS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.ProjectTask.ArchiveView'             , 0, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/ProjectTasks/view.aspx?ID={0}&ArchiveView={1}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ProjectTask.ArchiveView'             , 1, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'    , 'PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ProjectTask.ArchiveView'             , 2, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'                 , 'STATUS'                 , '15%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ProjectTask.ArchiveView'             , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ProjectTask.ArchiveView'             , 4, 'ProjectTask.LBL_LIST_DATE_DUE'            , 'DATE_DUE'               , 'DATE_DUE'               , '15%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.Activities.ArchiveView', 'Prospects', 'vwPROSPECTS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.ArchiveView'            , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Prospects.Activities.ArchiveView'            , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.ArchiveView'            , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Contacts'  , 'CONTACT_ASSIGNED_USER_ID' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.ArchiveView'            , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROSPECT_NAME'          , 'PROSPECT_NAME'          , '20%', 'listViewTdLinkS1', 'PROSPECT_ID ARCHIVE_VIEW', '~/Prospects/view.aspx?ID={0}&ArchiveView={1}' , null, 'Prospects' , 'PROSPECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.Activities.ArchiveView'            , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ProspectLists.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ProspectLists.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ProspectLists.ArchiveView', 'Prospects', 'vwPROSPECTS_PROSPECT_LISTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ProspectLists.ArchiveView'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/ProspectLists/view.aspx?ID={0}&ArchiveView={1}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ProspectLists.ArchiveView'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ProspectLists.ArchiveView'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.Activities.ArchiveView', 'ProjectTask', 'vwPROJECT_TASKS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.ArchiveView'          , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW'     , '~/Activities/view.aspx?ID={0}&ArchiveView={1}' , null, 'Activities' , 'ACTIVITY_ASSIGNED_USER_ID'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.Activities.ArchiveView'          , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.ArchiveView'          , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW'      , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'   , null, 'Contacts'   , 'CONTACT_ASSIGNED_USER_ID'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.ArchiveView'          , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_TASK_NAME'      , 'PROJECT_TASK_NAME'      , '20%', 'listViewTdLinkS1', 'PROJECT_TASK_ID ARCHIVE_VIEW' , '~/ProjectTask/view.aspx?ID={0}&ArchiveView={1}', null, 'ProjectTask', 'PROJECT_TASK_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.Activities.ArchiveView'          , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.DocumentRevisions.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.DocumentRevisions.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.DocumentRevisions.ArchiveView'     , 'Documents', 'vwDOCUMENT_REVISIONS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.DocumentRevisions.ArchiveView'     , 0, 'Documents.LBL_LIST_FILENAME'              , 'FILENAME'               , 'FILENAME'               , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Documents/Document.aspx?ID={0}&ArchiveView={1}' , null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions.ArchiveView'     , 1, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.DocumentRevisions.ArchiveView'     , 2, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions.ArchiveView'     , 3, '.LBL_LIST_CREATED'                        , 'CREATED_BY'             , 'CREATED_BY'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions.ArchiveView'     , 4, 'Documents.LBL_REV_LIST_LOG'               , 'CHANGE_LOG'             , 'CHANGE_LOG'             , '25%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Accounts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Accounts.ArchiveView', 'Documents', 'vwDOCUMENTS_ACCOUNTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Accounts.ArchiveView'              , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts.ArchiveView'              , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts.ArchiveView'              , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts.ArchiveView'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts.ArchiveView'              , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Contacts.ArchiveView', 'Documents', 'vwDOCUMENTS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contacts.ArchiveView'              , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '20%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts.ArchiveView'              , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contacts.ArchiveView'              , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '20%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts.ArchiveView'              , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Documents.Contacts.ArchiveView'        , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts.ArchiveView'              , 4, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts.ArchiveView'              , 5, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Leads.ArchiveView', 'Documents', 'vwDOCUMENTS_LEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Leads.ArchiveView'                 , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Leads/view.aspx?ID={0}&ArchiveView={1}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads.ArchiveView'                 , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Leads.ArchiveView'                 , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '15%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads.ArchiveView'                 , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads.ArchiveView'                 , 4, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads.ArchiveView'                 , 5, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Opportunities.ArchiveView', 'Documents', 'vwDOCUMENTS_OPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Opportunities.ArchiveView'         , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '35%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Opportunities/view.aspx?ID={0}&ArchiveView={1}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Opportunities.ArchiveView'         , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW'    , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Opportunities.ArchiveView'         , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Opportunities.ArchiveView'         , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Opportunities.ArchiveView'         , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Bugs.ArchiveView', 'Documents', 'vwDOCUMENTS_BUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Bugs.ArchiveView'                  , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Bugs.ArchiveView'                  , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Bugs/view.aspx?ID={0}&ArchiveView={1}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs.ArchiveView'                  , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs.ArchiveView'                  , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs.ArchiveView'                  , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Cases.ArchiveView', 'Documents', 'vwDOCUMENTS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases.ArchiveView'                 , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases.ArchiveView'                 , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases.ArchiveView'                 , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Cases.ArchiveView'                 , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
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

call dbo.spGRIDVIEWS_COLUMNS_ArchiveView_SubPanels()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ArchiveView_SubPanels')
/

-- #endif IBM_DB2 */

