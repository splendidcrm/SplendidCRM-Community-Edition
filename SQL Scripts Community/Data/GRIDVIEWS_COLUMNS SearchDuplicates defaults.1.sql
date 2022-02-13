

print 'GRIDVIEWS_COLUMNS Duplicate Search defaults';
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME like '%.SearchDuplicates';
--GO

set nocount on;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.SearchDuplicates', 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.SearchDuplicates'          , 1, 'Accounts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.SearchDuplicates', 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.SearchDuplicates'              , 1, 'Bugs.LBL_LIST_NAME'                       , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.SearchDuplicates', 'Campaigns', 'vwCAMPAIGNS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.SearchDuplicates'         , 1, 'Campaigns.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Campaigns/view.aspx?id={0}', null, 'Campaigns', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.SearchDuplicates', 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.SearchDuplicates'             , 1, 'Cases.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.SearchDuplicates'             , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '50%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.SearchDuplicates', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchDuplicates'          , 1, 'Contacts.LBL_LIST_FIRST_NAME'             , 'FIRST_NAME'      , 'FIRST_NAME'      , '25%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchDuplicates'          , 2, 'Contacts.LBL_LIST_LAST_NAME'              , 'LAST_NAME'       , 'LAST_NAME'       , '25%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchDuplicates'          , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.SearchDuplicates'          , 4, 'Contacts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '25%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.SearchDuplicates', 'Documents', 'vwDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.SearchDuplicates'         , 1, 'Documents.LBL_LIST_DOCUMENT_NAME'         , 'DOCUMENT_NAME'   , 'DOCUMENT_NAME'   , '50%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.SearchDuplicates', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailTemplates.SearchDuplicates'    , 1, 'EmailTemplates.LBL_LIST_NAME'             , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/EmailTemplates/view.aspx?id={0}', null, 'EmailTemplates', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.SearchDuplicates', 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.SearchDuplicates'             , 1, 'Leads.LBL_LIST_FIRST_NAME'                , 'FIRST_NAME'      , 'FIRST_NAME'      , '25%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.SearchDuplicates'             , 2, 'Leads.LBL_LIST_LAST_NAME'                 , 'LAST_NAME'       , 'LAST_NAME'       , '25%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchDuplicates'             , 3, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchDuplicates'             , 4, 'Leads.LBL_LIST_EMAIL1'                    , 'EMAIL1'          , 'EMAIL1'          , '25%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.SearchDuplicates', 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.SearchDuplicates'     , 1, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.SearchDuplicates'     , 2, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '50%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}'     , null, 'Accounts'     , 'ACCOUNT_ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.SearchDuplicates', 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.SearchDuplicates'           , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.SearchDuplicates', 'ProjectTask', 'vwPROJECT_TASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.SearchDuplicates'       , 1, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.SearchDuplicates'       , 2, 'ProjectTask.LBL_PARENT_ID'                , 'PROJECT_NAME'    , 'PROJECT_NAME'    , '50%', 'listViewTdLinkS1', 'PROJECT_ID' , '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.SearchDuplicates', 'ProspectLists', 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.SearchDuplicates'     , 1, 'ProspectLists.LBL_LIST_NAME'              , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.SearchDuplicates', 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.SearchDuplicates'         , 1, 'Prospects.LBL_LIST_FIRST_NAME'            , 'FIRST_NAME'      , 'FIRST_NAME'      , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.SearchDuplicates'         , 2, 'Prospects.LBL_LIST_LAST_NAME'             , 'LAST_NAME'       , 'LAST_NAME'       , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchDuplicates'         , 3, 'Prospects.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchDuplicates'         , 4, 'Prospects.LBL_LIST_EMAIL1'                , 'EMAIL1'          , 'EMAIL1'          , '25%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.SearchDuplicates' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.SearchDuplicates';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.SearchDuplicates', 'Tasks', 'vwTASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.SearchDuplicates'             , 1, 'Tasks.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Tasks/view.aspx?id={0}', null, 'Tasks', 'ASSIGNED_USER_ID';
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

call dbo.spGRIDVIEWS_COLUMNS_SearchDuplicates()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_SearchDuplicates')
/

-- #endif IBM_DB2 */

