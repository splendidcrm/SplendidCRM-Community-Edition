

print 'GRIDVIEWS_COLUMNS Search defaults';
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Search';
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Search';
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/28/2009 Paul.  Restore TEAM_NAME and expect it to be converted automatically when DynamicTeams is enabled. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

-- 10/04/2010 Paul.  Add searching of email. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Search', 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Search'          ,  1, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Search'          ,  2, 'Accounts.LBL_LIST_CITY'                   , 'CITY'            , 'CITY'            , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Search'          ,  3, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'           , 'PHONE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Search'          ,  4, 'Accounts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Accounts.Search'          ,  5, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Search'          ,  6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Search'          ,  7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Search' and DATA_FIELD = 'EMAIL1' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Accounts.Search: Add Email.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , MODIFIED_USER_ID  = null
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Accounts.Search'
		   and COLUMN_INDEX      >= 4
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Search'          , 4, 'Accounts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Accounts.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Accounts.Search'          ,  5, '5%';
	end -- if;
end -- if;
GO

-- 08/22/2011 Paul.  Need the search fields otherwise the the Outlook plug-in will return all bugs and not apply a filter. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Search', 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Search'              , 1, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'      , 'BUG_NUMBER'      , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Search'              , 2, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Bugs.Search'              , 3, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Search'              , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Search'              , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
end else begin
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '20%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Bugs.Search'
		   and DATA_FIELD       = 'BUG_NUMBER'
		   and ITEMSTYLE_WIDTH  = '50%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Bugs.Search'              , 3, '10%';
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Search'              , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Search'              , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	end -- if;
end -- if;
GO

-- 02/08/2008 Paul.  Fix ACCOUNT_ASSIGNED_USER_ID.  Module name should be singular. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Search', 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Search'             , 1, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Search'             , 2, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Search'             , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Search'             , 4, 'Cases.LBL_LIST_PRIORITY'                  , 'PRIORITY'        , 'PRIORITY'        , '10%', 'case_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Search'             , 5, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Cases.Search'            ,  6, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Search'             , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Search'             , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Search' and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Fix GRIDVIEWS_COLUMNS Cases.Search ACCOUNT_ASSIGNED_USER_ID';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACCOUNT_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Cases.Search'
		   and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID'
		   and DELETED = 0;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Cases.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Cases.Search'            ,  6, '5%';
	end -- if;
end -- if;
GO

-- 02/08/2008 Paul.  Fix ACCOUNT_ASSIGNED_USER_ID.  Module name should be singular. 
-- 10/04/2010 Paul.  Add searching of email. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Search', 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Search'          , 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Search'          , 2, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'           , 'TITLE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Search'          , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Search'          , 4, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Search'          , 5, 'Contacts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contacts.Search'          , 6, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Search'          , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Search'          , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Search' and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Fix GRIDVIEWS_COLUMNS Contacts.Search ACCOUNT_ASSIGNED_USER_ID';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACCOUNT_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Contacts.Search'
		   and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID'
		   and DELETED = 0;
	end -- if;
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Search' and DATA_FIELD = 'EMAIL1' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Contacts.Search: Add Email.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , MODIFIED_USER_ID  = null
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Contacts.Search'
		   and COLUMN_INDEX      >= 5
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Search'          , 5, 'Contacts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Contacts.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contacts.Search'          , 6, '5%';
	end -- if;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Search', 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Search'             , 1, 'Leads.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.Search'             , 2, 'Leads.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'lead_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Search'             , 3, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%';
	-- 07/05/2012 Paul.  Change to link to Emails module. 
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Search'             , 4, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'          , 'EMAIL1'          , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Search'             , 5, 'Leads.LBL_LIST_PHONE'                     , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Leads.Search'             , 6, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Search'             , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Search'             , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Leads.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Leads.Search'             , 6, '5%';
	end -- if;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Search', 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Search'     , 1, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Search'     , 2, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}'     , null, 'Accounts'     , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Search'     , 3, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'     , 'SALES_STAGE'     , '10%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Search'     , 4, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR' , 'AMOUNT_USDOLLAR' , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Search'     , 5, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'     , 'DATE_CLOSED'     , '10%', 'Date'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Opportunities.Search'     , 6, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Search'     , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Search'     , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Opportunities.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Opportunities.Search'     , 6, '5%';
	end -- if;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Search', 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Search'           , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Search'           , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT', null        , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Search'           , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'   , null        , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Project.Search'          ,  4, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Search'           , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Search'           , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Opportunities.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Project.Search'          ,  4, '5%';
	end -- if;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.Search';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.Search', 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Search'         , 1, 'Prospects.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Search'         , 2, 'Prospects.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '25%';
	-- 07/05/2012 Paul.  Change to link to Emails module. 
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Search'         , 3, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'          , 'EMAIL1'          , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Search'         , 4, 'Prospects.LBL_LIST_PHONE'                 , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Prospects.Search'         , 5, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Search'         , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Search'         , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Search' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '5%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Prospects.Search'
		   and DATA_FIELD       in ('ASSIGNED_TO_NAME', 'TEAM_NAME')
		   and ITEMSTYLE_WIDTH  = '10%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Prospects.Search'          ,  5, '5%';
	end -- if;
end -- if;
GO

-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.SearchPhones' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.SearchPhones';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.SearchPhones', 'Accounts', 'vwPHONE_NUMBERS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.SearchPhones'    , 1, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'             , 'NAME'             , '35%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.SearchPhones'    , 2, 'Accounts.LBL_LIST_CITY'                   , 'CITY'             , 'CITY'             , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.SearchPhones'    , 3, 'Accounts.LBL_LIST_PHONE'                  , 'NORMALIZED_NUMBER', 'NORMALIZED_NUMBER', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.SearchPhones'    , 4, 'Accounts.LBL_LIST_EMAIL1'                 , 'EMAIL1'           , 'EMAIL1'           , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.SearchPhones'    , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.SearchPhones'    , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME' , 'ASSIGNED_TO_NAME' , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.SearchPhones' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.SearchPhones';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.SearchPhones', 'Contacts', 'vwPHONE_NUMBERS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchPhones'    , 1, 'Contacts.LBL_LIST_NAME'                   , 'NAME'             , 'NAME'             , '20%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.SearchPhones'    , 2, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'            , 'TITLE'            , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchPhones'    , 3, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'     , 'ACCOUNT_NAME'     , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.SearchPhones'    , 4, 'Contacts.LBL_LIST_PHONE'                  , 'NORMALIZED_NUMBER', 'NORMALIZED_NUMBER', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.SearchPhones'    , 5, 'Contacts.LBL_LIST_EMAIL1'                 , 'EMAIL1'           , 'EMAIL1'           , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.SearchPhones'    , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.SearchPhones'    , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME' , 'ASSIGNED_TO_NAME' , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.SearchPhones' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.SearchPhones';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.SearchPhones', 'Leads', 'vwPHONE_NUMBERS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.SearchPhones'       , 1, 'Leads.LBL_LIST_NAME'                      , 'NAME'             , 'NAME'             , '25%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.SearchPhones'       , 2, 'Leads.LBL_LIST_STATUS'                    , 'STATUS'           , 'STATUS'           , '10%', 'lead_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchPhones'       , 3, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'     , 'ACCOUNT_NAME'     , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchPhones'       , 4, 'Leads.LBL_LIST_PHONE'                     , 'NORMALIZED_NUMBER', 'NORMALIZED_NUMBER', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.SearchPhones'       , 5, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'           , 'EMAIL1'           , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchPhones'       , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.SearchPhones'       , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME' , 'ASSIGNED_TO_NAME' , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.SearchPhones' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.SearchPhones';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.SearchPhones', 'Prospects', 'vwPHONE_NUMBERS_PROSPECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.SearchPhones'   , 1, 'Prospects.LBL_LIST_NAME'                  , 'NAME'             , 'NAME'             , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchPhones'   , 2, 'Prospects.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'     , 'ACCOUNT_NAME'     , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchPhones'   , 3, 'Prospects.LBL_LIST_PHONE'                 , 'NORMALIZED_NUMBER', 'NORMALIZED_NUMBER', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.SearchPhones'   , 4, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'           , 'EMAIL1'           , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', 'Emails', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchPhones'   , 5, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.SearchPhones'   , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME' , 'ASSIGNED_TO_NAME' , '10%';
end -- if;
GO

-- 12/08/2014 Paul.  Add ChatMessages. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatMessages.Search';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatMessages.Search' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatMessages.Search';
	exec dbo.spGRIDVIEWS_InsertOnly             'ChatMessages.Search', 'ChatMessages', 'vwCHAT_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.Search',  2, 'ChatMessages.LBL_LIST_NAME'                , 'NAME'             , 'NAME'             , '43%', 'listViewTdLinkS1', 'ID'             , '~/ChatMessages/view.aspx?id={0}', null, 'ChatMessages', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.Search',  3, 'ChatMessages.LBL_LIST_PARENT_NAME'         , 'PARENT_NAME'      , 'PARENT_NAME'      , '15%', 'listViewTdLinkS1', 'PARENT_ID'      , '~/Parents/view.aspx?id={0}'     , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'ChatMessages.Search',  4, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'     , 'DATE_ENTERED'     , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatMessages.Search',  5, '.LBL_LIST_CREATED_BY_NAME'                 , 'CREATED_BY_NAME'  , 'CREATED_BY_NAME'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.Search',  6, 'ChatMessages.LBL_LIST_CHAT_CHANNEL_NAME'   , 'CHAT_CHANNEL_NAME', 'CHAT_CHANNEL_NAME', '10%', 'listViewTdLinkS1', 'CHAT_CHANNEL_ID', '~/ChatChannels/view.aspx?id={0}', null, 'ChatChannels', 'CHAT_CHANNEL_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatMessages.Search',  7, 'Teams.LBL_LIST_TEAM'                       , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ChatMessages.Search',  8, null, '1%', 'ID', 'Preview', 'preview_inline';
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

call dbo.spGRIDVIEWS_COLUMNS_Search()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_Search')
/

-- #endif IBM_DB2 */

