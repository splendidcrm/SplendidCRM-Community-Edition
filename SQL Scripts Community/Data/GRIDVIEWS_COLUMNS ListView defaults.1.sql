

print 'GRIDVIEWS_COLUMNS ListView defaults';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.ListView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
-- 11/17/2007 Paul.  Add spGRIDVIEWS_InsertOnly to simplify creation of Mobile views.
-- 11/25/2006 Paul.  Fix bug in beta. TEAM_ID should not be used in DATA_FIELD. 
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/28/2009 Paul.  Restore TEAM_NAME and expect it to be converted automatically when DynamicTeams is enabled. 
-- 01/13/2010 Paul.  Default to Assigned before Team. 
-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 08/02/2010 Paul.  Add information hover. 
-- 08/02/2010 Paul.  Increase the first item so that the Edit link will be next to the checkbox. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents. 

if exists(select * from GRIDVIEWS_COLUMNS where DATA_FIELD = 'TEAM_ID') begin -- then
	update GRIDVIEWS_COLUMNS
	   set DATA_FIELD = 'TEAM_NAME'    
	 where DATA_FIELD = 'TEAM_ID';
end -- if;
GO

-- 11/22/2006 Paul.  Add TEAM_NAME for team management. 
-- 02/12/2010 Paul.  Change to PHONE_OFFICE, instead of using the PHONE alias. 
-- 12/05/2010 Paul.  Use two separate fields for CITY and STATE. 
-- 02/26/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.ListView'      , 'Accounts'      , 'vwACCOUNTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.ListView'          ,  2, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                 , 'NAME'                 , '35%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          ,  3, 'Accounts.LBL_LIST_BILLING_ADDRESS_CITY'   , 'BILLING_ADDRESS_CITY' , 'BILLING_ADDRESS_CITY' , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          ,  4, 'Accounts.LBL_LIST_BILLING_ADDRESS_STATE'  , 'BILLING_ADDRESS_STATE', 'BILLING_ADDRESS_STATE', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          ,  5, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE_OFFICE'         , 'PHONE_OFFICE'         , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Accounts.ListView'          ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          ,  7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'     , 'ASSIGNED_TO_NAME'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          ,  8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'            , 'TEAM_NAME'            , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Accounts.ListView'          ,  9, null, null, '1%', 'Accounts.LBL_BILLING_ADDRESS BILLING_ADDRESS_STREET BILLING_ADDRESS_CITY BILLING_ADDRESS_STATE BILLING_ADDRESS_POSTALCODE BILLING_ADDRESS_COUNTRY WEBSITE Accounts.LBL_INDUSTRY INDUSTRY', '<div class="ListViewInfoHover">
<b>{0}</b><br />
{1}<br />
{2}, {3} {4} {5}<br />
<a href="{6}">{6}</a><br />
<b>{7}</b> {8}<br />
</div>', 'info_inline';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.ListView'       , 10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Accounts.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Accounts.ListView'          , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView' and DATA_FIELD = 'PHONE' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Accounts.ListView: Change to PHONE_OFFICE, instead of using the PHONE alias. ';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD       = 'PHONE_OFFICE'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Accounts.ListView'
		   and DATA_FIELD       = 'PHONE'
		   and DELETED          = 0;
	end -- if;
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView'          , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 02/26/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.ListView'          , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '25%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Accounts.ListView'
		   and DATA_FIELD       = 'NAME'
		   and ITEMSTYLE_WIDTH  = '35%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect    'Accounts.ListView'  ,  6, '10%';
	end -- if;
end -- if;
GO

-- 03/15/2016 Paul.  Just delete all and recreate. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.ListView' and HEADER_TEXT = 'Calls.LBL_LIST_SUBJECT' and DATA_FIELD = 'NAME' and URL_FIELD = 'ID' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Activities.ListView'
	   and DELETED          = 0;
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Activities.ListView'
	   and DELETED          = 0;
end -- if;

-- 11/26/2005 Paul.  Activities should just use the existing Calls collection.
-- 03/15/2016 Paul.  Make better use of the activities list by showing all. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Activities.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Activities.ListView'    , 'Activities'    , 'vwACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.ListView'        ,  2, 'Activities.LBL_LIST_ACTIVITY_TYPE'        , 'ACTIVITY_TYPE'   , 'ACTIVITY_TYPE'   ,  '5%', 'activities_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.ListView'        ,  3, 'Calls.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          ,  '9%', 'activity_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Activities.ListView'        ,  4, 'Activities.LBL_LIST_DIRECTION'            , 'DIRECTION'       , 'DIRECTION'       ,  '5%', 'activity_direction_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Activities.ListView'        ,  5, 'Activities.LBL_LIST_SUBJECT'              , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ACTIVITY_TYPE ID', '~/{0}/view.aspx?id={1}'    , null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Activities.ListView'        ,  6, 'Activities.LBL_LIST_RELATED_TO'           , 'PARENT_NAME'     , 'PARENT_NAME'     , '15%', 'listViewTdLinkS1', 'PARENT_ID'       , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.ListView'        ,  7, 'Activities.LBL_LIST_DATE_START'           , 'DATE_START'      , 'DATE_START'      , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.ListView'        ,  8, 'Activities.LBL_LIST_DATE_DUE'             , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.ListView'        ,  9, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'   , 'DATE_MODIFIED'   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.ListView'        , 10, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Activities.ListView'        , 11, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end -- if;
GO

-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.ListView'          , 'Bugs'          , 'vwBUGS_List'          ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView'              ,  2, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'      , 'BUG_NUMBER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.ListView'              ,  3, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView'              ,  4, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'          , 'STATUS'          , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView'              ,  5, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'            , 'TYPE'            , '10%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView'              ,  6, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'        , 'PRIORITY'        , '10%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView'              ,  7, 'Bugs.LBL_LIST_RELEASE'                    , 'FOUND_IN_RELEASE', 'FOUND_IN_RELEASE', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Bugs.ListView'              ,  8, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView'              ,  9, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView'              , 10, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.ListView'            , 11, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Bugs.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Bugs.ListView'              , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView'              , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '20%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Bugs.ListView'
		   and DATA_FIELD       = 'NAME'
		   and ITEMSTYLE_WIDTH  = '30%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Bugs.ListView'              ,  8, '10%';
	end -- if;
end -- if;
GO

-- 12/27/2012 Paul.  Change DATE_START to DateTime format. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 02/03/2018 Paul.  Should be LBL_LIST_STATUS and not LBL_LIST_CLOSE. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.ListView'         , 'Calls'         , 'vwCALLS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ListView'             , 2, 'Calls.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'call_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ListView'             , 3, 'Calls.LBL_LIST_DIRECTION'                 , 'DIRECTION'       , 'DIRECTION'       , '10%', 'call_direction_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ListView'             , 4, 'Calls.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Calls/view.aspx?id={0}', null, 'Calls', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ListView'             , 5, 'Calls.LBL_LIST_CONTACT'                   , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ListView'             , 6, 'Calls.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ListView'             , 7, 'Calls.LBL_LIST_DATE'                      , 'DATE_START'      , 'DATE_START'      , '20%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView'             , 8, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView'             , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.ListView'           ,10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Calls.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Calls.ListView'             , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView'             , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 02/03/2018 Paul.  Should be LBL_LIST_STATUS and not LBL_LIST_CLOSE. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView' and DATA_FIELD = 'STATUS' and HEADER_TEXT = 'Calls.LBL_LIST_CLOSE' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set HEADER_TEXT      = 'Calls.LBL_LIST_STATUS'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Calls.ListView'
		   and DATA_FIELD       = 'STATUS'
		   and HEADER_TEXT      = 'Calls.LBL_LIST_CLOSE'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.ListView'     , 'Campaigns'     , 'vwCAMPAIGNS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.ListView'         , 2, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Campaigns/view.aspx?id={0}', null, 'Campaigns', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.ListView'         , 3, 'Campaigns.LBL_LIST_STATUS'                , 'STATUS'          , 'STATUS'          , '10%', 'campaign_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.ListView'         , 4, 'Campaigns.LBL_LIST_TYPE'                  , 'CAMPAIGN_TYPE'   , 'CAMPAIGN_TYPE'   , '10%', 'campaign_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.ListView'         , 5, 'Campaigns.LBL_LIST_END_DATE'              , 'END_DATE'        , 'END_DATE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView'         , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView'         , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Campaigns.ListView'         ,  8, '10%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Campaigns.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Campaigns.ListView'         , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView'         , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 05/18/2017 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '20%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Campaigns.ListView'
		   and DATA_FIELD       = 'NAME'
		   and ITEMSTYLE_WIDTH  = '30%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Campaigns.ListView'         ,  8, '10%';
	end -- if;
end -- if;
GO

-- 07/22/2007 Paul.  Make the case number a hyperlink. 
-- 02/08/2008 Paul.  Fix ACCOUNT_ASSIGNED_USER_ID.  Module name should be singular. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.ListView'         , 'Cases'         , 'vwCASES_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView'             ,  2, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView'             ,  3, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView'             ,  4, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ListView'             ,  5, 'Cases.LBL_LIST_PRIORITY'                  , 'PRIORITY'        , 'PRIORITY'        , '10%', 'case_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ListView'             ,  6, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Cases.ListView'             ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ListView'             ,  8, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ListView'             ,  9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.ListView'           , 10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Cases.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Cases.ListView'             , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Fix GRIDVIEWS_COLUMNS Cases.ListView ACCOUNT_ASSIGNED_USER_ID';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACCOUNT_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Cases.ListView'
		   and URL_ASSIGNED_FIELD = 'ACCOUNTS_ASSIGNED_USER_ID'
		   and DELETED = 0;
	end -- if;
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ListView'             , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 07/22/2007 Paul.  Make the case number a hyperlink. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and COLUMN_INDEX = 2 and DATA_FIELD = 'CASE_NUMBER' and COLUMN_TYPE = 'BoundColumn' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Cases.ListView: Make the case number a hyperlink. ';
		update GRIDVIEWS_COLUMNS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Cases.ListView'
		   and COLUMN_INDEX     = 1
		   and DATA_FIELD       = 'CASE_NUMBER'
		   and COLUMN_TYPE      = 'BoundColumn'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ListView'             , 2, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'     , 'CASE_NUMBER'     , '10%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '20%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Cases.ListView'
		   and DATA_FIELD       = 'NAME'
		   and ITEMSTYLE_WIDTH  = '30%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Cases.ListView'             ,  7, '10%';
	end -- if;
end -- if;
GO

-- 11/29/2010 Paul.  Add Email column. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ListView'      , 'Contacts'      , 'vwCONTACTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView'          ,  2, 'Contacts.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '15%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView'          ,  3, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView'          ,  4, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '15%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView'          ,  5, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}'  , null, 'Emails'  , null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView'          ,  6, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'      , 'PHONE_WORK'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contacts.ListView'          ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView'          ,  8, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'   , 'DATE_MODIFIED'   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView'          ,  9, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '8%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView'          , 10, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Contacts.ListView'          , 11, null, null, '1%', 'Contacts.LBL_PRIMARY_ADDRESS PRIMARY_ADDRESS_STREET PRIMARY_ADDRESS_CITY PRIMARY_ADDRESS_STATE PRIMARY_ADDRESS_POSTALCODE PRIMARY_ADDRESS_COUNTRY Contacts.LBL_PHONE_MOBILE PHONE_MOBILE Contacts.LBL_PHONE_HOME PHONE_HOME', '<div class="ListViewInfoHover">
<b>{0}</b><br />
{1}<br />
{2}, {3} {4} {5}<br />
<b>{6}</b> {7}<br />
<b>{8}</b> {9}<br />
</div>', 'info_inline';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.ListView'          ,11, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Contacts.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Contacts.ListView'          , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView'          , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView' and DATA_FIELD = 'EMAIL1' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Contacts.ListView: Add email.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Contacts.ListView'
		   and COLUMN_INDEX      >= 5
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ListView'          , 5, 'Contacts.LBL_LIST_EMAIL1'                 , 'EMAIL1'          , 'EMAIL1'          , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}'  , null, 'Emails'  , null;
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.ListView'          , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '10%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Contacts.ListView'
		   and DATA_FIELD       in ('EMAIL1', 'PHONE_WORK')
		   and ITEMSTYLE_WIDTH  = '15%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contacts.ListView'          ,  7, '10%';
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.ListView'     , 'Documents'     , 'vwDOCUMENTS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.ListView'         ,  2, 'Documents.LBL_LIST_DOCUMENT'              , 'NAME'                 , 'NAME'                 , '25%', 'listViewTdLinkS1', 'ID', '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,  3, 'Documents.LBL_LIST_CATEGORY'              , 'CATEGORY_ID'          , 'CATEGORY_ID'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,  4, 'Documents.LBL_LIST_SUBCATEGORY'           , 'SUBCATEGORY_ID'       , 'SUBCATEGORY_ID'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,  5, 'Documents.LBL_LIST_REVISION'              , 'REVISION'             , 'REVISION'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,  6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'            , 'TEAM_NAME'            , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,  7, 'Documents.LBL_LIST_LAST_REV_CREATOR'      , 'REVISION_CREATED_BY_NAME', 'REVISION_CREATED_BY_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ListView'         ,  8, 'Documents.LBL_LIST_LAST_REV_DATE'         , 'REVISION_DATE_ENTERED', 'REVISION_DATE_ENTERED', '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ListView'         ,  9, 'Documents.LBL_LIST_ACTIVE_DATE'           , 'ACTIVE_DATE'          , 'ACTIVE_DATE'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ListView'         , 10, 'Documents.LBL_LIST_EXP_DATE'              , 'EXP_DATE'             , 'EXP_DATE'             , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Documents.ListView'         , 11, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         , 12, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'     , 'ASSIGNED_TO_NAME'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.ListView'       , 13, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Documents.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Documents.ListView'         , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'            , 'TEAM_NAME'            , '5%';
	end -- if;
	-- 11/23/2012 Paul.  Just in case there is a problem with uniqueness, check to make sure that the field does not already exist. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView' and DATA_FIELD = 'ASSIGNED_TO_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView'         ,-1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'     , 'ASSIGNED_TO_NAME'     , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.ListView'       , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '10%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Documents.ListView'
		   and DATA_FIELD       in ('CATEGORY_ID', 'SUBCATEGORY_ID', 'REVISION', 'REVISION_CREATED_BY_NAME', 'REVISION_DATE_ENTERED', 'ACTIVE_DATE', 'EXP_DATE')
		   and ITEMSTYLE_WIDTH  = '11%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Documents.ListView'         , 11, '5%';
	end -- if;
end -- if;
GO

-- 06/26/2010 Paul.  Display full Date Time for the email. 
-- 08/08/2013 Paul.  Add Email Status column. 
-- 03/08/2014 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ListView'        , 'Emails'        , 'vwEMAILS_List'        ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView'            , 2, 'Emails.LBL_LIST_SUBJECT'                  , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID'         , '~/Emails/view.aspx?id={0}', null, 'Emails', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView'            , 3, 'Emails.LBL_LIST_CONTACT'                  , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ListView'            , 4, 'Emails.LBL_LIST_RELATED_TO'               , 'PARENT_NAME'     , 'PARENT_NAME'     , '20%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ListView'            , 5, '.LBL_LIST_CREATED'                        , 'DATE_ENTERED'    , 'DATE_ENTERED'    , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.ListView'            , 6, 'Emails.LBL_LIST_STATUS'                   , 'STATUS'          , 'STATUS'          , '10%', 'dom_email_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView'            , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView'            , 8, 'Emails.LBL_LIST_TYPE'                     , 'TYPE_TERM'       , 'TYPE_TERM'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.ListView'          , 9, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Emails.ListView', 2;
	-- 08/08/2013 Paul.  Add Email Status column. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView' and DATA_FIELD = 'STATUS' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Emails.ListView'
		   and COLUMN_INDEX      >= 6
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.ListView'            , 6, 'Emails.LBL_LIST_STATUS'                   , 'STATUS'          , 'STATUS'          , '10%', 'dom_email_status';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.ListView'          , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.ListView'     , 'Employees'     , 'vwEMPLOYEES_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.ListView'         , 2, 'Employees.LBL_LIST_NAME'                  , 'FULL_NAME'       , 'FULL_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Employees/view.aspx?id={0}', null, 'Employees', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView'         , 3, 'Employees.LBL_LIST_DEPARTMENT'            , 'DEPARTMENT'      , 'DEPARTMENT'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView'         , 4, 'Employees.LBL_LIST_REPORTS_TO_NAME'       , 'REPORTS_TO_NAME' , 'REPORTS_TO_NAME' , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Employees.ListView'         , 5, 'Employees.LBL_LIST_EMAIL'                 , 'EMAIL1'          , 'EMAIL1'          , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView'         , 6, 'Employees.LBL_LIST_PRIMARY_PHONE'         , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView'         , 7, 'Employees.LBL_LIST_EMPLOYEE_STATUS'       , 'EMPLOYEE_STATUS' , 'EMPLOYEE_STATUS' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView'         , 8, 'Employees.LBL_LIST_USER_NAME'             , 'USER_NAME'       , 'USER_NAME'       , '10%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Employees.ListView', 2;
	-- 11/29/2010 Paul.  Create Email record instead of using mailto. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.ListView' and DATA_FIELD = 'EMAIL1' and URL_FORMAT = 'mailto:{0}' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Employees.ListView: Create Email record instead of using mailto. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'ID'
		     , URL_FORMAT        = '~/Emails/edit.aspx?PARENT_ID={0}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Employees.ListView'
		   and DATA_FIELD        = 'EMAIL1'
		   and URL_FORMAT        = 'mailto:{0}'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 11/28/2007 Paul.  The URL should link to the DetailView that will display the site in an IFRAME. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'iFrames.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS iFrames.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'iFrames.ListView'       , 'iFrames'       , 'vwIFRAMES_List'       ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'iFrames.ListView'           , 2, 'iFrames.LBL_LIST_NAME'                    , 'NAME'            , null              , '25%', 'listViewTdLinkS1', 'ID'         , '~/iFrames/edit.aspx?id={0}', null, 'iFrames', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'iFrames.ListView'           , 3, 'iFrames.LBL_LIST_URL'                     , 'URL'             , null              , '25%', 'listViewTdLinkS1', 'ID'         , '~/iFrames/view.aspx?id={0}', null, 'iFrames', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'iFrames.ListView'           , 4, '.LBL_LIST_CREATED'                        , 'CREATED_BY_NAME' , null              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'iFrames.ListView'           , 5, 'iFrames.LBL_LIST_TYPE'                    , 'TYPE'            , null              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'iFrames.ListView'           , 6, 'iFrames.LBL_LIST_PLACEMENT'               , 'PLACEMENT'       , null              , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'iFrames.ListView'           , 7, 'iFrames.LBL_LIST_STATUS'                  , 'STATUS'          , null              , '10%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'iFrames.ListView', 2;
end -- if;
GO

-- 11/28/2007 Paul.  The URL should link to the DetailView that will display the site in an IFRAME. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'iFrames.ListView' and DATA_FIELD = 'URL' and URL_FIELD = 'URL' and URL_FORMAT = '{0}' and DATA_FORMAT = 'HyperLink' and DELETED = 0) begin -- then
	print 'Display iFrame sites in an IFRAME.';
	update GRIDVIEWS_COLUMNS
	   set URL_FIELD          = 'ID'
	     , URL_FORMAT         = '~/iFrames/view.aspx?id={0}'
	     , URL_MODULE         = 'iFrames'
	     , URL_TARGET         = null
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC  = getutcdate()
	     , MODIFIED_USER_ID   = null
	 where GRID_NAME          = 'iFrames.ListView'
	   and DATA_FIELD         = 'URL'
	   and URL_FIELD          = 'URL'
	   and URL_FORMAT         = '{0}'
	   and COLUMN_TYPE        = 'TemplateColumn'
	   and DATA_FORMAT        = 'HyperLink'
	   and DELETED            = 0;
end -- if;
GO

-- 05/25/2006 Paul.  Account Name does not display on the Leads list.  The problem is that the Account Name is not a linkable field. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ListView'         , 'Leads'         , 'vwLEADS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ListView'             ,  2, 'Leads.LBL_LIST_NAME'                      , 'NAME'            , 'NAME'            , '15%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.ListView'             ,  3, 'Leads.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '15%', 'lead_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView'             ,  4, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ListView'             ,  5, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'          , 'EMAIL1'          , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}'  , null, 'Emails'  , null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView'             ,  6, 'Leads.LBL_LIST_PHONE'                     , 'PHONE_WORK'      , 'PHONE_WORK'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Leads.ListView'             ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView'             ,  8, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '8%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView'             ,  9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Leads.ListView'             , 10, null, null, '1%', 'Leads.LBL_PRIMARY_ADDRESS PRIMARY_ADDRESS_STREET PRIMARY_ADDRESS_CITY PRIMARY_ADDRESS_STATE PRIMARY_ADDRESS_POSTALCODE PRIMARY_ADDRESS_COUNTRY Leads.LBL_PHONE_MOBILE PHONE_MOBILE Leads.LBL_PHONE_HOME PHONE_HOME', '<div class="ListViewInfoHover">
<b>{0}</b><br />
{1}<br />
{2}, {3} {4} {5}<br />
<b>{6}</b> {7}<br />
<b>{8}</b> {9}<br />
</div>', 'info_inline';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.ListView'           ,10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Leads.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Leads.ListView'             , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView'             , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 05/25/2006 Paul.  Account Name does not display on the Leads list.  The problem is that the Account Name is not a linkable field. 
	-- 05/09/2016 Paul.  Some companies do want the account name to be a hyperlink. 
	/*
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and DATA_FIELD = 'ACCOUNT_NAME' and COLUMN_TYPE = 'TemplateColumn' and DATA_FORMAT = 'HyperLink' and DELETED = 0) begin -- then
	 	print 'Leads Account Name should not be a hyperlink.  Change to a bound column.';
	 	update GRIDVIEWS_COLUMNS
	 	   set COLUMN_TYPE        = 'BoundColumn'
	 	     , DATA_FORMAT        = null
	 	     , URL_FIELD          = null
	 	     , URL_FORMAT         = null
	 	     , URL_ASSIGNED_FIELD = null
	 	     , DATE_MODIFIED      = getdate()
	 	     , MODIFIED_USER_ID   = null
	 	 where GRID_NAME          = 'Leads.ListView'
	 	   and DATA_FIELD         = 'ACCOUNT_NAME'
	 	   and COLUMN_TYPE        = 'TemplateColumn'
	 	   and DATA_FORMAT        = 'HyperLink'
	 	   and DELETED            = 0;
	end -- if;
	*/
	-- 11/29/2010 Paul.  Create Email record instead of using mailto. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and DATA_FIELD = 'EMAIL1' and URL_FORMAT = 'mailto:{0}' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Leads.ListView: Create Email record instead of using mailto. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'ID'
		     , URL_FORMAT        = '~/Emails/edit.aspx?PARENT_ID={0}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Leads.ListView'
		   and DATA_FIELD        = 'EMAIL1'
		   and URL_FORMAT        = 'mailto:{0}'
		   and DELETED           = 0;
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '10%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Leads.ListView'
		   and DATA_FIELD       in ('EMAIL1', 'PHONE_WORK')
		   and ITEMSTYLE_WIDTH  = '15%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Leads.ListView'             ,  7, '10%';
	end -- if;
end -- if;
GO

-- 12/27/2012 Paul.  Change DATE_START to DateTime format. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 02/03/2018 Paul.  Should be LBL_LIST_STATUS and not LBL_LIST_CLOSE. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.ListView'      , 'Meetings'      , 'vwMEETINGS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Meetings.ListView'          , 2, 'Meetings.LBL_LIST_STATUS'                 , 'STATUS'          , 'STATUS'          , '10%', 'meeting_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ListView'          , 3, 'Meetings.LBL_LIST_SUBJECT'                , 'NAME'            , 'NAME'            , '30%', 'listViewTdLinkS1', 'ID'         , '~/Meetings/view.aspx?id={0}', null, 'Meetings', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ListView'          , 4, 'Meetings.LBL_LIST_CONTACT'                , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ListView'          , 5, 'Meetings.LBL_LIST_RELATED_TO'             , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ListView'          , 6, 'Meetings.LBL_LIST_DATE'                   , 'DATE_START'      , 'DATE_START'      , '20%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView'          , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView'          , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.ListView'        , 9, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Meetings.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Meetings.ListView'          , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView'          , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.ListView'        , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 02/03/2018 Paul.  Should be LBL_LIST_STATUS and not LBL_LIST_CLOSE. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView' and DATA_FIELD = 'STATUS' and HEADER_TEXT = 'Meetings.LBL_LIST_CLOSE' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set HEADER_TEXT      = 'Meetings.LBL_LIST_STATUS'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Meetings.ListView'
		   and DATA_FIELD       = 'STATUS'
		   and HEADER_TEXT      = 'Meetings.LBL_LIST_CLOSE'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents. 
-- 03/08/2014 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Notes.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Notes.ListView'         , 'Notes'         , 'vwNOTES_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ListView'             , 2, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Notes/view.aspx?id={0}', null, 'Notes', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ListView'             , 3, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ListView'             , 4, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView'             , 5, 'Notes.LBL_LIST_FILENAME'                  , 'FILENAME'        , 'FILENAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Notes.ListView'             , 6, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'   , 'DATE_MODIFIED'   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView'             , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Notes.ListView'           , 8, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Notes.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView'             , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '5%';
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Notes.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.ListView' , 'Opportunities' , 'vwOPPORTUNITIES_List' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView'     ,  2, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID'        ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView'     ,  3, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'    , 'ACCOUNT_NAME'    , '10%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}'     , null, 'Accounts'     , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView'     ,  4, 'Opportunities.LBL_LIST_LEAD_NAME'         , 'LEAD_NAME'       , 'LEAD_NAME'       , '10%', 'listViewTdLinkS1', 'LEAD_ID'    , '~/Leads/view.aspx?id={0}'        , null, 'Leads'        , 'LEAD_ASSIGNED_USER_ID'   ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.ListView'     ,  5, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'     , 'SALES_STAGE'     , '10%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView'     ,  6, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR' , 'AMOUNT_USDOLLAR' , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView'     ,  7, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'     , 'DATE_CLOSED'     , '10%', 'Date'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Opportunities.ListView'     ,  8, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView'     ,  9, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView'     , 10, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Opportunities.ListView'     , 11, null, null, '1%', 'Opportunities.LBL_LEAD_SOURCE LEAD_SOURCE Opportunities.LBL_PROBABILITY PROBABILITY Opportunities.LBL_OPPORTUNITY_TYPE OPPORTUNITY_TYPE', '<div class="ListViewInfoHover">
<b>{0}</b> {1}<br />
<b>{2}</b> {3}<br />
<b>{4}</b> {5}<br />
</div>', 'info_inline';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.ListView'   ,10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Opportunities.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Opportunities.ListView'     , 9, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView'     , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 05/07/2006 Paul.  Currencies should use the USD value in order to be converted properly. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and DATA_FIELD = 'AMOUNT' and DATA_FORMAT = 'Currency' and DELETED = 0) begin -- then
		print 'Currencies should use the USD value in order to be converted properly. ';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD       = 'AMOUNT_USDOLLAR'
		     , SORT_EXPRESSION  = 'AMOUNT_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Opportunities.ListView'
		   and DATA_FIELD       = 'AMOUNT'
		   and DATA_FORMAT      = 'Currency'
		   and DELETED          = 0;
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.ListView'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and DATA_FIELD = 'LEAD_NAME' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where GRID_NAME         = 'Opportunities.ListView'
		   and COLUMN_INDEX      >= 4
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ListView'     , 4, 'Opportunities.LBL_LIST_LEAD_NAME'         , 'LEAD_NAME'       , 'LEAD_NAME'       , '15%', 'listViewTdLinkS1', 'LEAD_ID'    , '~/Leads/view.aspx?id={0}'        , null, 'Leads'        , 'LEAD_ASSIGNED_USER_ID'   ;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '10%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Opportunities.ListView'
		   and DATA_FIELD       in ('ACCOUNT_NAME', 'LEAD_NAME')
		   and ITEMSTYLE_WIDTH  = '15%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Opportunities.ListView'     ,  8, '10%';
	end -- if;
end -- if;
GO

-- 05/07/2006 Paul.  Fix project module name. 
-- 01/13/2010 Paul.  Fix before insert to prevent duplicate rows. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.ListView' and DELETED = 0) begin -- then
	print 'Fix project module name.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.ListView'
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.ListView'
	   and DELETED          = 0;
end -- if;
GO

-- 05/07/2006 Paul.  Fix project module name. 
-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
-- select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and DEFAULT_VIEW = 0 order by COLUMN_INDEX
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ListView'       , 'Project'       , 'vwPROJECTS_List'      ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.ListView'           ,  2, 'Project.LBL_LIST_NAME'                    , 'NAME'                  , 'NAME'                , '25%', 'listViewTdLinkS1', 'ID'         , '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
-- 01/13/2010 Paul.  SugarCRM nolonger displayes the effort fields. 
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView'           ,  3, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT', null                  , '23%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView'           ,  4, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'   , null                  , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView'           ,  3, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'  , 'ESTIMATED_START_DATE', '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView'           ,  4, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'    , 'ESTIMATED_END_DATE'  , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ListView'           ,  5, 'Project.LBL_LIST_STATUS'                  , 'STATUS'                , 'STATUS'              , '15%', 'project_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Project.ListView'           ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView'           ,  7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'      , 'ASSIGNED_TO_NAME'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView'           ,  8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'             , 'TEAM_NAME'           , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.ListView'         ,  9, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Project.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Project.ListView'           , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'             , 'TEAM_NAME'           , '5%';
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Project.ListView: Add start date and end date.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX = COLUMN_INDEX + 3
		 where GRID_NAME    = 'Project.ListView'
		   and COLUMN_INDEX >= 3
		   and DELETED      = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView'           , 3, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'  , 'ESTIMATED_START_DATE', '15%', 'Date';
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ListView'           , 4, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'    , 'ESTIMATED_END_DATE'  , '15%', 'Date';
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ListView'           , 5, 'Project.LBL_LIST_STATUS'                  , 'STATUS'                , 'STATUS'              , '15%', 'project_status_dom';
	end -- if;
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView'           , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'             , 'TEAM_NAME'           , '5%';
	end -- if;
	-- 04/20/2011 Paul.  Fix the width of ASSIGNED_TO_NAME. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and ITEMSTYLE_WIDTH = '25' and DELETED = 0) begin -- then
		print 'Fix project ASSIGNED_TO_NAME width.';
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '25%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Project.ListView'
		   and DATA_FIELD       = 'ASSIGNED_TO_NAME'
		   and ITEMSTYLE_WIDTH  = '25'
		   and DELETED          = 0;
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.ListView'         , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '15%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Project.ListView'
		   and DATA_FIELD       = 'ASSIGNED_TO_NAME'
		   and ITEMSTYLE_WIDTH  = '25%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Project.ListView'           ,  6, '10%';
	end -- if;
end -- if;
GO

-- 05/07/2006 Paul.  Fix project task module name. 
-- 03/08/2014 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.ListView'   , 'ProjectTask'   , 'vwPROJECT_TASKS_List' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView'       , 2, 'ProjectTask.LBL_LIST_ORDER_NUMBER'        , 'ORDER_NUMBER'    , 'ORDER_NUMBER'    , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.ListView'       , 3, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.ListView'       , 4, 'ProjectTask.LBL_LIST_PARENT_NAME'         , 'PROJECT_NAME'    , 'PROJECT_NAME'    , '20%', 'listViewTdLinkS1', 'PROJECT_ID' , '~/Projects/view.aspx?id={0}', null, 'Project', 'PROJECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.ListView'       , 5, 'ProjectTask.LBL_LIST_DUE_DATE'            , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.ListView'       , 6, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'          , 'STATUS'          , '10%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView'       , 7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView'       , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.ListView'     , 9, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'ProjectTask.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'ProjectTask.ListView'       , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView'       , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.ListView'     , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 05/07/2006 Paul.  Fix project task module name. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTasks.ListView' and DELETED = 0) begin -- then
	print 'Fix project task module name.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'ProjectTask.ListView'
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'ProjectTasks.ListView'
	   and DELETED          = 0;
end -- if;
GO

-- 08/12/2007 Paul.  Add List Type and Domain Name to support Campaign management.
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.ListView' , 'ProspectLists' , 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.ListView'     , 2, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID'         , '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProspectLists.ListView'     , 3, 'ProspectLists.LBL_LIST_LIST_TYPE'         , 'LIST_TYPE'       , 'LIST_TYPE'       , '10%', 'prospect_list_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView'     , 4, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'     , 'DESCRIPTION'     , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'ProspectLists.ListView'     , 5, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView'     , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView'     , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'ProspectLists.ListView', 2;
	-- 08/12/2007 Paul.  Keep index at 3 as it refers to a value before List Type was added. 
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'ProspectLists.ListView'     , 6, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView'     , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 08/12/2007 Paul.  Add List Type and Domain Name to support Campaign management.
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView' and DATA_FIELD = 'LIST_TYPE' and DELETED = 0) begin -- then
		print 'Add List Type to Prospect List.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX = COLUMN_INDEX + 1
		 where GRID_NAME    = 'ProspectLists.ListView'
		   and COLUMN_INDEX >= 3
		   and DELETED      = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProspectLists.ListView'     , 3, 'ProspectLists.LBL_LIST_LIST_TYPE'         , 'LIST_TYPE'       , 'LIST_TYPE'       , '10%', 'prospect_list_type_dom';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '40%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'ProspectLists.ListView'
		   and DATA_FIELD       = 'DESCRIPTION'
		   and ITEMSTYLE_WIDTH  = '50%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'ProspectLists.ListView'     , 5, '10%';
	end -- if;
end -- if;
GO

-- 03/08/2014 Paul.  Add Preview button. 
-- 05/15/2016 Paul.  Add tags to list view. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ListView'     , 'Prospects'     , 'vwPROSPECTS_List'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ListView'         ,  2, 'Prospects.LBL_LIST_NAME'                  , 'NAME'            , 'NAME'            , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView'         ,  3, 'Prospects.LBL_LIST_TITLE'                 , 'TITLE'           , 'TITLE'           , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ListView'         ,  4, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'          , 'EMAIL1'          , '35%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView'         ,  5, 'Prospects.LBL_LIST_PHONE'                 , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Prospects.ListView'         ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView'         ,  7, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView'         ,  8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Prospects.ListView'         ,  9, null, null, '1%', 'Prospects.LBL_PRIMARY_ADDRESS PRIMARY_ADDRESS_STREET PRIMARY_ADDRESS_CITY PRIMARY_ADDRESS_STATE PRIMARY_ADDRESS_POSTALCODE PRIMARY_ADDRESS_COUNTRY Prospects.LBL_PHONE_MOBILE PHONE_MOBILE Prospects.LBL_PHONE_HOME PHONE_HOME', '<div class="ListViewInfoHover">
<b>{0}</b><br />
{1}<br />
{2}, {3} {4} {5}<br />
<b>{6}</b> {7}<br />
<b>{8}</b> {9}<br />
</div>', 'info_inline';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.ListView'       , 9, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Prospects.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Prospects.ListView'         , 8, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView'         , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 11/29/2010 Paul.  Create Email record instead of using mailto. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView' and DATA_FIELD = 'EMAIL1' and URL_FORMAT = 'mailto:{0}' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Prospects.ListView: Create Email record instead of using mailto. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'ID'
		     , URL_FORMAT        = '~/Emails/edit.aspx?PARENT_ID={0}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Prospects.ListView'
		   and DATA_FIELD        = 'EMAIL1'
		   and URL_FORMAT        = 'mailto:{0}'
		   and DELETED           = 0;
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.ListView'       , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 05/15/2016 Paul.  Add tags to list view. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		update GRIDVIEWS_COLUMNS
		   set ITEMSTYLE_WIDTH  = '25%'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Prospects.ListView'
		   and DATA_FIELD       = 'NAME'
		   and ITEMSTYLE_WIDTH  = '35%'
		   and DELETED          = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Prospects.ListView'         ,  6, '10%';
	end -- if;
end -- if;
GO

-- 03/08/2014 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.ListView'         , 'Tasks'         , 'vwTASKS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ListView'             , 2, 'Tasks.LBL_LIST_SUBJECT'                   , 'NAME'            , 'NAME'            , '40%', 'listViewTdLinkS1', 'ID'         , '~/Tasks/view.aspx?id={0}', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ListView'             , 3, 'Tasks.LBL_LIST_CONTACT'                   , 'CONTACT_NAME'    , 'CONTACT_NAME'    , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ListView'             , 4, 'Tasks.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'     , 'PARENT_NAME'     , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.ListView'             , 5, 'Tasks.LBL_LIST_DUE_DATE'                  , 'DATE_DUE'        , 'DATE_DUE'        , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView'             , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView'             , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Tasks.ListView'           , 8, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Tasks.ListView', 2;
	exec dbo.spGRIDVIEWS_COLUMNS_InsField     'Tasks.ListView'             , 7, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	-- 02/24/2010 Paul.  Allow a field to be added to the end using an index of -1. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ListView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView'             , -1, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';
	end -- if;
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Tasks.ListView'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 10/21/2020 Paul.  Convert USER_NAME into a hyperlink. 
-- 10/21/2020 Paul.  Correct URL to navigate to Administration pages. 
-- 11/10/2020 Paul.  Can't use ~/Administration/Users as this layout is used on React and ASP.NET, but React is easier to re-route. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.ListView'         , 'Users'         , 'vwUSERS_List'         ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.ListView'             , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.ListView'             , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView'             , 3, 'Users.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'      , 'DEPARTMENT'      , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.ListView'             , 4, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'          , 'EMAIL1'          , '20%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView'             , 5, 'Users.LBL_LIST_PRIMARY_PHONE'             , 'PHONE_WORK'      , 'PHONE_WORK'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView'             , 6, 'Users.LBL_LIST_STATUS'                    , 'STATUS'          , 'STATUS'          , '10%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'Users.ListView', 1;
	-- 11/29/2010 Paul.  Create Email record instead of using mailto. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ListView' and DATA_FIELD = 'EMAIL1' and URL_FORMAT = 'mailto:{0}' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Users.ListView: Create Email record instead of using mailto. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'ID'
		     , URL_FORMAT        = '~/Emails/edit.aspx?PARENT_ID={0}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Users.ListView'
		   and DATA_FIELD        = 'EMAIL1'
		   and URL_FORMAT        = 'mailto:{0}'
		   and DELETED           = 0;
	end -- if;
	-- 10/21/2020 Paul.  Convert USER_NAME into a hyperlink. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ListView' and DATA_FIELD = 'USER_NAME' and COLUMN_TYPE = 'BoundColumn' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Users.ListView: Convert USER_NAME into a hyperlink.  ';
		update GRIDVIEWS_COLUMNS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Users.ListView'
		   and DATA_FIELD        = 'USER_NAME'
		   and COLUMN_TYPE       = 'BoundColumn'
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.ListView'             , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Users/view.aspx?id={0}', null, 'Users', null;
	end -- if;
	-- 10/21/2020 Paul.  Correct URL to navigate to Administration pages. 
	-- 11/10/2020 Paul.  Can't use ~/Administration/Users as this layout is used on React and ASP.NET, but React is easier to re-route. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ListView' and URL_FORMAT = '~/Administration/Users/view.aspx?id={0}' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Users.ListView: Correct URL to navigate to Administration pages. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FORMAT        = '~/Users/view.aspx?id={0}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Users.ListView'
		   and URL_FORMAT        = '~/Administration/Users/view.aspx?id={0}'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Releases.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Releases.ListView';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Releases.ListView'          , 1, 'Releases.LBL_LIST_NAME'                   , 'NAME'            , 'NAME'            , '72%', 'listViewTdLinkS1', 'ID', '~/Administration/Releases/edit.aspx?id={0}', null, 'Releases', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Releases.ListView'          , 2, 'Releases.LBL_LIST_STATUS'                 , 'STATUS'          , 'STATUS'          , '10%', 'release_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Releases.ListView'          , 3, 'Releases.LBL_LIST_LIST_ORDER'             , 'LIST_ORDER'      , 'LIST_ORDER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'Releases.ListView',  'LIST_ORDER', '{0:N0}';
end else begin
	-- 02/22/2021 Paul.  Make use of new procedure spGRIDVIEWS_COLUMNS_UpdateFormat.
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Releases.ListView' and DATA_FIELD = 'LIST_ORDER' and DATA_FORMAT is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'Releases.ListView',  'LIST_ORDER', '{0:N0}';
	end -- if;
	-- 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'Releases.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'Releases.ListView', 'LIST_ORDER', 'asc';
	end -- if;
end -- if;
GO

-- 12/10/2007 Paul.  Removed references to TestCases, TestPlans and TestRuns.


-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ACLRoles.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ACLRoles.ListView', 'ACLRoles', 'vwACL_ROLES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ACLRoles.ListView'          , 1, 'ACLRoles.LBL_NAME'                        , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID', '~/Administration/ACLRoles/view.aspx?id={0}', null, 'ACLRoles', null;
end -- if;
GO

-- 07/11/2007 Paul.  Add CampaignTrackers and EmailMarketing modules. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'CampaignTrackers.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'CampaignTrackers.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS CampaignTrackers.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'CampaignTrackers.ListView', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'CampaignTrackers.ListView'  , 2, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'             , 'CAMPAIGN_NAME'             , '20%', 'listViewTdLinkS1', 'CAMPAIGN_ID', '~/Campaigns/view.aspx?id={0}'       , null, 'Campaigns'       , 'CAMPAIGN_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'CampaignTrackers.ListView'  , 3, 'CampaignTrackers.LBL_TRACKER_NAME'        , 'TRACKER_NAME'              , 'TRACKER_NAME'              , '20%', 'listViewTdLinkS1', 'ID'         , '~/CampaignTrackers/view.aspx?id={0}', null, 'CampaignTrackers', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CampaignTrackers.ListView'  , 4, 'CampaignTrackers.LBL_TRACKER_URL'         , 'TRACKER_URL'               , 'TRACKER_URL'               , '50%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CampaignTrackers.ListView'  , 5, 'CampaignTrackers.LBL_TRACKER_KEY'         , 'TRACKER_KEY'               , 'TRACKER_KEY'               , '20%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'CampaignTrackers.ListView', 2;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMarketing.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMarketing.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailMarketing.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailMarketing.ListView', 'EmailMarketing', 'vwEMAIL_MARKETING_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView'    , 2, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'             , 'CAMPAIGN_NAME'             , '20%', 'listViewTdLinkS1', 'CAMPAIGN_ID', '~/Campaigns/view.aspx?id={0}'       , null, 'Campaigns'     , 'CAMPAIGN_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView'    , 3, 'EmailMarketing.LBL_LIST_NAME'             , 'NAME'                      , 'NAME'                      , '30%', 'listViewTdLinkS1', 'ID'         , '~/EmailMarketing/view.aspx?id={0}'  , null, 'EmailMarketing', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailMarketing.ListView'    , 4, 'EmailMarketing.LBL_LIST_DATE_START'       , 'DATE_START'                , 'DATE_START'                , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'EmailMarketing.ListView'    , 5, 'EmailMarketing.LBL_LIST_STATUS'           , 'STATUS'                    , 'STATUS'                    , '15%', 'email_marketing_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ListView'    , 6, 'EmailMarketing.LBL_LIST_TEMPLATE_NAME'    , 'TEMPLATE_NAME'             , 'TEMPLATE_NAME'             , '20%', 'listViewTdLinkS1', 'TEMPLATE_ID', '~/EmailTemplates/view.aspx?id={0}'  , null, 'EmailTemplates', null;
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'EmailMarketing.ListView', 2;
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'CallMarketing.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'CallMarketing.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS CallMarketing.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'CallMarketing.ListView'     , 'CallMarketing', 'vwCALL_MARKETING_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'CallMarketing.ListView'     , 2, 'Campaigns.LBL_LIST_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'             , 'CAMPAIGN_NAME'             , '20%', 'listViewTdLinkS1', 'CAMPAIGN_ID', '~/Campaigns/view.aspx?id={0}'       , null, 'Campaigns'     , 'CAMPAIGN_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'CallMarketing.ListView'     , 3, 'CallMarketing.LBL_LIST_NAME'              , 'NAME'                      , 'NAME'                      , '30%', 'listViewTdLinkS1', 'ID'         , '~/EmailMarketing/view.aspx?id={0}'  , null, 'EmailMarketing', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'CallMarketing.ListView'     , 4, 'CallMarketing.LBL_LIST_DATE_START'        , 'DATE_START'                , 'DATE_START'                , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'CallMarketing.ListView'     , 5, 'CallMarketing.LBL_LIST_STATUS'            , 'STATUS'                    , 'STATUS'                    , '15%', 'call_marketing_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'CallMarketing.ListView'     , 6, 'CallMarketing.LBL_LIST_DISTRIBUTION'      , 'DISTRIBUTION'              , 'DISTRIBUTION'              , '15%', 'call_distribution_dom'    ;
end -- if;
GO

-- 07/11/2007 Paul.  EmailTemplates were not previously driven by data. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.ListView', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailTemplates.ListView'    , 2, 'EmailTemplates.LBL_LIST_NAME'             , 'NAME'                      , 'NAME'                      , '35%', 'listViewTdLinkS1', 'ID'         , 'view.aspx?id={0}'           , null, 'EmailTemplates', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.ListView'    , 3, 'EmailTemplates.LBL_LIST_DESCRIPTION'      , 'DESCRIPTION'               , 'DESCRIPTION'               , '55%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailTemplates.ListView'    , 4, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'             , 'DATE_MODIFIED'             , '20%', 'Date';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'EmailTemplates.ListView', 2;
end -- if;
GO

-- 01/28/2017 Paul.  Add Server Type. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'InboundEmail.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'InboundEmail.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS InboundEmail.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'InboundEmail.ListView', 'InboundEmail', 'vwINBOUND_EMAILS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'InboundEmail.ListView'      , 1, 'InboundEmail.LBL_NAME'                    , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID', '~/Administration/InboundEmail/view.aspx?id={0}'   , null, 'InboundEmail', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'InboundEmail.ListView'      , 2, 'InboundEmail.LBL_SERVICE'                 , 'SERVICE'         , 'SERVICE'         , '15%', 'dom_email_server_type';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'InboundEmail.ListView'      , 3, 'InboundEmail.LBL_MAILBOX_TYPE'            , 'MAILBOX_TYPE'    , 'MAILBOX_TYPE'    , '15%', 'dom_mailbox_type';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.ListView'      , 4, 'InboundEmail.LBL_SERVER_URL'              , 'SERVER_URL'      , 'SERVER_URL'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'InboundEmail.ListView'      , 5, 'InboundEmail.LBL_STATUS'                  , 'STATUS'          , 'STATUS'          , '15%', 'user_status_dom';
end else begin
	-- 01/28/2017 Paul.  Add Server Type. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'InboundEmail.ListView' and DATA_FIELD = 'SERVICE' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS InboundEmail.ListView: Add SERVICE.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX  = COLUMN_INDEX + 1
		 where GRID_NAME     = 'InboundEmail.ListView'
		   and COLUMN_INDEX >= 2
		   and DELETED       = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'InboundEmail.ListView'      , 2, 'InboundEmail.LBL_SERVICE'                 , 'SERVICE'         , 'SERVICE'         , '15%', 'dom_email_server_type';
	end -- if;
end -- if;
GO

-- 07/11/2018 Paul.  Increase index to add space for checkboxes. 
-- select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.LoginView' order by COLUMN_INDEX
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.LoginView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.LoginView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.LoginView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.LoginView', 'Users', 'vwUSERS_LOGINS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 1, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'       , 'FULL_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 2, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'       , 'USER_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 3, 'Users.LBL_LIST_LOGIN_DATE'                , 'LOGIN_DATE'      , 'LOGIN_DATE'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 4, 'Users.LBL_LIST_LOGOUT_DATE'               , 'LOGOUT_DATE'     , 'LOGOUT_DATE'     , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Users.LoginView'            , 5, 'Users.LBL_LIST_LOGIN_STATUS'              , 'LOGIN_STATUS'    , 'LOGIN_STATUS'    , '10%', 'login_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Users.LoginView'            , 6, 'Users.LBL_LIST_LOGIN_TYPE'                , 'LOGIN_TYPE'      , 'LOGIN_TYPE'      , '10%', 'login_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 7, 'Users.LBL_LIST_REMOTE_HOST'               , 'REMOTE_HOST'     , 'REMOTE_HOST'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 8, 'Users.LBL_LIST_TARGET'                    , 'TARGET'          , 'TARGET'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.LoginView'            , 9, 'Users.LBL_LIST_ASPNET_SESSIONID'          , 'ASPNET_SESSIONID', 'ASPNET_SESSIONID', '10%';
end else begin
	-- 07/11/2018 Paul.  Increase index to add space for checkboxes. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.LoginView' and COLUMN_INDEX = 0 and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Users.LoginView: Shift indexes to make space for checkboxes.';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Users.LoginView'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 09/09/2009 Paul.  Allow direct editing of the module table. 
-- 06/22/2013 Paul.  Add edit link and move to front. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Modules.ListView' and DELETED = 0;
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Modules.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Modules.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Modules.ListView', 'Modules', 'vwMODULES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Modules.ListView'           ,  0, 'Modules.LBL_LIST_MODULE_NAME'             , 'MODULE_NAME'     , 'MODULE_NAME'     , '30%', 'listViewTdLinkS1', 'ID', '~/Administration/Modules/view.aspx?id={0}', null, 'Modules', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  1, 'Modules.LBL_LIST_TABLE_NAME'              , 'TABLE_NAME'      , 'TABLE_NAME'      , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  2, 'Modules.LBL_LIST_RELATIVE_PATH'           , 'RELATIVE_PATH'   , 'RELATIVE_PATH'   , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  3, 'Modules.LBL_LIST_MODULE_ENABLED'          , 'MODULE_ENABLED'  , 'MODULE_ENABLED'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  4, 'Modules.LBL_LIST_CUSTOM_PAGING'           , 'CUSTOM_PAGING'   , 'CUSTOM_PAGING'   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  5, 'Modules.LBL_LIST_TAB_ORDER'               , 'TAB_ORDER'       , 'TAB_ORDER'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Modules.ListView'           ,  6, 'Modules.LBL_LIST_IS_ADMIN'                , 'IS_ADMIN'        , 'IS_ADMIN'        , '10%';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Modules.ListView' and DATA_FIELD = 'MODULE_NAME' and COLUMN_INDEX = 0 and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Modules.ListView: Move edit link to front. ';
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX      = COLUMN_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Modules.ListView'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 09/12/2009 Paul.  Allow editing of Field Validators. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'FieldValidators.ListView' and DELETED = 0;
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'FieldValidators.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS FieldValidators.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'FieldValidators.ListView', 'FieldValidators', 'vwFIELD_VALIDATORS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'FieldValidators.ListView'   , 2, 'FieldValidators.LBL_LIST_NAME'             , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID', '~/Administration/FieldValidators/view.aspx?id={0}', null, 'FieldValidators', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'FieldValidators.ListView'   , 3, 'FieldValidators.LBL_LIST_VALIDATION_TYPE'  , 'VALIDATION_TYPE' , 'VALIDATION_TYPE' , '50%';
end else begin
	exec dbo.spGRIDVIEWS_COLUMNS_ReserveIndex null, 'FieldValidators.ListView', 2;
end -- if;
GO

-- 01/23/2012 Paul.  Create full editing for number sequences. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'NumberSequences.ListView' and DELETED = 0;
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'NumberSequences.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS NumberSequences.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'NumberSequences.ListView', 'NumberSequences', 'vwNUMBER_SEQUENCES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'NumberSequences.ListView'   ,  1, 'NumberSequences.LBL_LIST_NAME'            , 'NAME'            , 'NAME'            , '20%', 'listViewTdLinkS1', 'ID', '~/Administration/NumberSequences/view.aspx?id={0}', null, 'NumberSequences', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NumberSequences.ListView'   ,  2, 'NumberSequences.LBL_LIST_CURRENT_VALUE'   , 'CURRENT_VALUE'   , 'CURRENT_VALUE'   , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NumberSequences.ListView'   ,  3, 'NumberSequences.LBL_LIST_ALPHA_PREFIX'    , 'ALPHA_PREFIX'    , 'ALPHA_PREFIX'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NumberSequences.ListView'   ,  4, 'NumberSequences.LBL_LIST_ALPHA_SUFFIX'    , 'ALPHA_SUFFIX'    , 'ALPHA_SUFFIX'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NumberSequences.ListView'   ,  5, 'NumberSequences.LBL_LIST_SEQUENCE_STEP'   , 'SEQUENCE_STEP'   , 'SEQUENCE_STEP'   , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NumberSequences.ListView'   ,  6, 'NumberSequences.LBL_LIST_NUMERIC_PADDING' , 'NUMERIC_PADDING' , 'NUMERIC_PADDING' , '15%';
end -- if;
GO

-- 03/29/2012 Paul.  Add Rules Wizard support to Terminology module. 
-- 12/05/2012 Paul.  LBL_LIST_NAME is getting confused with the list version, so change to LBL_NAME. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.ListView' and DELETED = 0;
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Terminology.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Terminology.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Terminology.ListView', 'Terminology', 'vwTERMINOLOGY';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.ListView'       ,  1, 'Terminology.LBL_LIST_MODULE_NAME'         , 'MODULE_NAME'     , 'MODULE_NAME'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Terminology.ListView'       ,  2, 'Terminology.LBL_NAME'                     , 'NAME'            , 'NAME'            , '22%', 'listViewTdLinkS1', 'ID', '~/Administration/Terminology/view.aspx?id={0}', null, 'Terminology', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.ListView'       ,  3, 'Terminology.LBL_LIST_LANG'                , 'LANG'            , 'LANG'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.ListView'       ,  4, 'Terminology.LBL_LIST_LIST_NAME'           , 'LIST_NAME'       , 'LIST_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.ListView'       ,  5, 'Terminology.LBL_LIST_LIST_ORDER'          , 'LIST_ORDER'      , 'LIST_ORDER'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Terminology.ListView'       ,  6, 'Terminology.LBL_LIST_DISPLAY_NAME'        , 'DISPLAY_NAME'    , 'DISPLAY_NAME'    , '30%';
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
-- 03/08/2014 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'SmsMessages.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SmsMessages.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SmsMessages.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'SmsMessages.ListView', 'SmsMessages', 'vwSMS_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'SmsMessages.ListView'       , 2, 'SmsMessages.LBL_LIST_NAME'                 , 'NAME'            , 'NAME'            , '35%', 'listViewTdLinkS1', 'ID'         , '~/SmsMessages/view.aspx?id={0}', null, 'SmsMessages', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SmsMessages.ListView'       , 3, 'SmsMessages.LBL_LIST_DATE_START'           , 'DATE_START'      , 'DATE_START'      , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView'       , 4, 'SmsMessages.LBL_LIST_FROM_NUMBER'          , 'FROM_NUMBER'     , 'FROM_NUMBER'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView'       , 5, 'SmsMessages.LBL_LIST_TO_NUMBER'            , 'TO_NUMBER'       , 'TO_NUMBER'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'SmsMessages.ListView'       , 6, 'SmsMessages.LBL_LIST_RELATED_TO'           , 'PARENT_NAME'     , 'PARENT_NAME'     , '18%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView'       , 7, '.LBL_LIST_ASSIGNED_USER'                   , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'SmsMessages.ListView'       , 8, 'SmsMessages.LBL_LIST_STATUS'               , 'STATUS'          , 'STATUS'          , '5%', 'dom_sms_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView'       , 9, 'SmsMessages.LBL_LIST_TYPE'                 , 'TYPE_TERM'       , 'TYPE_TERM'       , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'SmsMessages.ListView'     ,10, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SmsMessages.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'SmsMessages.ListView'     , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/22/2013 Paul.  Add OutboundSms module. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'OutboundSms.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'OutboundSms.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS OutboundSms.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'OutboundSms.ListView', 'OutboundSms', 'vwOUTBOUND_EMAILS_Edit';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'OutboundSms.ListView'       , 1, 'OutboundSms.LBL_LIST_NAME'                 , 'NAME'            , 'NAME'            , '45%', 'listViewTdLinkS1', 'ID', '~/Administration/OutboundSms/view.aspx?id={0}', null, 'OutboundSms', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'OutboundSms.ListView'       , 2, 'OutboundSms.LBL_LIST_FROM_NUMBER'          , 'FROM_NUMBER'     , 'FROM_NUMBER'     , '50%';
end -- if;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module. 
-- 03/08/2014 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS TwitterMessages.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'TwitterMessages.ListView', 'TwitterMessages', 'vwTWITTER_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ListView'   ,  2, 'TwitterMessages.LBL_LIST_NAME'                , 'NAME'                , 'NAME'                , '35%', 'listViewTdLinkS1', 'ID'       , '~/TwitterMessages/view.aspx?id={0}', null, 'TwitterMessages', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ListView'   ,  3, 'TwitterMessages.LBL_LIST_DATE_START'          , 'DATE_START'          , 'DATE_START'          , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ListView'   ,  4, 'TwitterMessages.LBL_LIST_TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME' , '10%', 'listViewTdLinkS1', 'TWITTER_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ListView'   ,  5, 'TwitterMessages.LBL_LIST_RELATED_TO'          , 'PARENT_NAME'         , 'PARENT_NAME'         , '10%', 'listViewTdLinkS1', 'PARENT_ID', '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView'   ,  6, 'TwitterMessages.LBL_LIST_IS_RETWEET'          , 'IS_RETWEET'          , 'IS_RETWEET'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ListView'   ,  7, 'TwitterMessages.LBL_LIST_ORIGINAL_SCREEN_NAME', 'ORIGINAL_SCREEN_NAME', 'ORIGINAL_SCREEN_NAME', '10%', 'listViewTdLinkS1', 'ORIGINAL_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView'   ,  8, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'    , 'ASSIGNED_TO_NAME'    , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView'   ,  9, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'           , 'TEAM_NAME'           , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'TwitterMessages.ListView'   , 10, 'TwitterMessages.LBL_LIST_STATUS'              , 'STATUS'              , 'STATUS'              , '5%', 'dom_twitter_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView'   , 11, 'TwitterMessages.LBL_LIST_TYPE'                , 'TYPE_TERM'           , 'TYPE_TERM'           , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'TwitterMessages.ListView' , 12, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 03/08/2014 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ListView' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'TwitterMessages.ListView' , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ImportView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ImportView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS TwitterMessages.ImportView';
	exec dbo.spGRIDVIEWS_InsertOnly           'TwitterMessages.ImportView', 'TwitterMessages', 'vwTWITTER_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ImportView',  2, 'TwitterMessages.LBL_LIST_NAME'                , 'DESCRIPTION'         , 'DESCRIPTION'         , '50%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ImportView',  3, 'TwitterMessages.LBL_LIST_DATE_START'          , 'DATE_START'          , 'DATE_START'          , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ImportView',  4, 'TwitterMessages.LBL_LIST_TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME' , '10%', 'listViewTdLinkS1', 'TWITTER_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ImportView',  5, 'TwitterMessages.LBL_LIST_RELATED_TO'          , 'PARENT_NAME'         , 'PARENT_NAME'         , '10%', 'listViewTdLinkS1', 'PARENT_ID', '~/Parents/view.aspx?id={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ImportView',  6, 'TwitterMessages.LBL_LIST_IS_RETWEET'          , 'IS_RETWEET'          , 'IS_RETWEET'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ImportView',  7, 'TwitterMessages.LBL_LIST_ORIGINAL_SCREEN_NAME', 'ORIGINAL_SCREEN_NAME', 'ORIGINAL_SCREEN_NAME', '10%', 'listViewTdLinkS1', 'ORIGINAL_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ImportView',  8, 'TwitterMessages.LBL_LIST_TWITTER_ID'          , 'TWITTER_ID'          , 'TWITTER_ID'          , '5%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ImportView',  9, 'TwitterMessages.LBL_LIST_ORIGINAL_ID'         , 'ORIGINAL_ID'         , 'ORIGINAL_ID'         , '5%';
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatChannels.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'ChatChannels.ListView', 'ChatChannels', 'vwCHAT_CHANNELS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatChannels.ListView',  2, 'ChatChannels.LBL_LIST_NAME'                , 'NAME'            , 'NAME'            , '65%', 'listViewTdLinkS1', 'ID'         , '~/ChatChannels/view.aspx?id={0}', null, 'ChatChannels', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatChannels.ListView',  3, '.LBL_LIST_ASSIGNED_USER'                   , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatChannels.ListView',  4, 'Teams.LBL_LIST_TEAM'                       , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ChatChannels.ListView',  5, null, '1%', 'ID', 'Preview', 'preview_inline';
end -- if;
GO

-- 08/01/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
-- select * from GRIDVIEWS where NAME = 'ChatMessages.ListView' and DELETED = 0
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatMessages.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatMessages.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatMessages.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'ChatMessages.ListView', 'ChatMessages', 'vwCHAT_MESSAGES_List', 'DATE_ENTERED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.ListView',  2, 'ChatMessages.LBL_LIST_NAME'                , 'NAME'             , 'NAME'             , '43%', 'listViewTdLinkS1', 'ID'             , '~/ChatMessages/view.aspx?id={0}', null, 'ChatMessages', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.ListView',  3, 'ChatMessages.LBL_LIST_PARENT_NAME'         , 'PARENT_NAME'      , 'PARENT_NAME'      , '15%', 'listViewTdLinkS1', 'PARENT_ID'      , '~/Parents/view.aspx?id={0}'     , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'ChatMessages.ListView',  4, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'     , 'DATE_ENTERED'     , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatMessages.ListView',  5, '.LBL_LIST_CREATED_BY_NAME'                 , 'CREATED_BY_NAME'  , 'CREATED_BY_NAME'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ChatMessages.ListView',  6, 'ChatMessages.LBL_LIST_CHAT_CHANNEL_NAME'   , 'CHAT_CHANNEL_NAME', 'CHAT_CHANNEL_NAME', '10%', 'listViewTdLinkS1', 'CHAT_CHANNEL_ID', '~/ChatChannels/view.aspx?id={0}', null, 'ChatChannels', 'CHAT_CHANNEL_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ChatMessages.ListView',  7, 'Teams.LBL_LIST_TEAM'                       , 'TEAM_NAME'        , 'TEAM_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ChatMessages.ListView',  8, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 08/01/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'ChatMessages.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'ChatMessages.ListView', 'DATE_ENTERED', 'desc';
	end -- if;
end -- if;
GO

-- 04/13/2016 Paul.  Add ZipCodes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ZipCodes.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'ZipCodes.ListView', 'ZipCodes', 'vwZIPCODES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'ZipCodes.ListView'    , 1, 'ZipCodes.LBL_LIST_NAME'                     , 'NAME'             , 'NAME'             , '25%', 'listViewTdLinkS1', 'ID', '~/Administration/ZipCodes/view.aspx?id={0}', null, 'ZipCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.ListView'    , 2, 'ZipCodes.LBL_LIST_CITY'                     , 'CITY'             , 'CITY'             , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.ListView'    , 3, 'ZipCodes.LBL_LIST_STATE'                    , 'STATE'            , 'STATE'            , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.ListView'    , 4, 'ZipCodes.LBL_LIST_COUNTRY'                  , 'COUNTRY'          , 'COUNTRY'          , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover       'ZipCodes.ListView'    , 5, null, null, '1%', 'LONGITUDE LATITUDE', '<div style="background-color: white; padding: 10px;">
<a href="https://www.google.com/maps/?q={0},{1}" target="GoogleMaps">Google Maps</a>
</div>', 'info_inline';
end -- if;
GO

-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Currencies.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Currencies.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Currencies.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'Currencies.ListView', 'Currencies', 'vwCURRENCIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Currencies.ListView'  , 2, 'Currencies.LBL_LIST_NAME'                   , 'NAME'             , 'NAME'             , '30%', 'listViewTdLinkS1', 'ID', '~/Administration/Currencies/view.aspx?id={0}', null, 'Currencies', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList   'Currencies.ListView'  , 3, 'Currencies.LBL_LIST_STATUS'                 , 'STATUS'           , 'STATUS'           , '10%', 'currency_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Currencies.ListView'  , 4, 'Currencies.LBL_LIST_ISO4217'                , 'ISO4217'          , 'ISO4217'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Currencies.ListView'  , 5, 'Currencies.LBL_LIST_SYMBOL'                 , 'SYMBOL'           , 'SYMBOL'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Currencies.ListView'  , 6, 'Currencies.LBL_LIST_CONVERSION_RATE'        , 'CONVERSION_RATE'  , 'CONVERSION_RATE'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList   'Currencies.ListView'  , 7, 'Currencies.LBL_LIST_DEFAULT_CURRENCY'       , 'IS_DEFAULT'       , 'IS_DEFAULT'       , '10%', 'yesno_list';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList   'Currencies.ListView'  , 8, 'Currencies.LBL_LIST_BASE_CURRENCY'          , 'IS_BASE'          , 'IS_BASE'          , '10%', 'yesno_list';
	-- 05/01/2016 Paul.  Format is not working, but keep anyway. 
	update GRIDVIEWS_COLUMNS
	   set COLUMN_TYPE        = 'BoundColumn'
	     , DATA_FORMAT        = '{0:F3}'
	 where GRID_NAME          = 'Currencies.ListView'
	   and DATA_FIELD         = 'CONVERSION_RATE'
	   and DELETED            = 0;
end else begin
	-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Currencies.ListView' and LIST_NAME = 'yesno_dom' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME          = 'yesno_list'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		 where GRID_NAME          = 'Currencies.ListView'
		   and LIST_NAME          = 'yesno_dom'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 05/11/2016 Paul.  Add support for Tags. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tags.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tags.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tags.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'Tags.ListView', 'Tags', 'vwTAGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Tags.ListView',  1, 'Tags.LBL_LIST_NAME'                       , 'NAME'             , 'NAME'             , '30%', 'listViewTdLinkS1', 'ID', '~/Administration/Tags/view.aspx?id={0}', null, 'Tags', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Tags.ListView',  2, 'Tags.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'      , 'DESCRIPTION'      , '45%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'Tags.ListView',  3, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'     , 'DATE_ENTERED'     , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Tags.ListView',  4, '.LBL_LIST_CREATED_BY_NAME'                , 'CREATED_BY_NAME'  , 'CREATED_BY_NAME'  , '10%';
end -- if;
GO

-- 06/07/2017 Paul.  Add support for NAICS Codes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS NAICSCodes.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'NAICSCodes.ListView', 'NAICSCodes', 'vwNAICS_CODES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'NAICSCodes.ListView', 0, 'NAICSCodes.LBL_LIST_NAME'              , 'NAME'             , 'NAME'             , '20%', 'listViewTdLinkS1', 'ID', '~/Administration/NAICSCodes/view.aspx?id={0}', null, 'NAICSCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NAICSCodes.ListView', 1, 'NAICSCodes.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'      , 'DESCRIPTION'      , '75%';
end -- if;
GO

-- 01/20/2010 Paul.  Add ability to search the new Audit Events table. 
-- 03/28/2019 Paul.  Move AuditEvents.ListView to default file for Community edition. 
-- 03/28/2019 Paul.  Convert to DateTime field. 
-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'AuditEvents.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'AuditEvents.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS AuditEvents.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'AuditEvents.ListView', 'AuditEvents', 'vwAUDIT_EVENTS', 'DATE_MODIFIED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'AuditEvents.ListView'       , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'            , 'FULL_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'AuditEvents.ListView'       , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'            , 'USER_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'AuditEvents.ListView'       , 2, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'        , 'DATE_MODIFIED'   , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'AuditEvents.ListView'       , 4, 'Audit.LBL_LIST_AUDIT_ACTION'              , 'AUDIT_ACTION'         , 'AUDIT_ACTION'    , '10%', 'audit_action_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'AuditEvents.ListView'       , 5, 'Audit.LBL_LIST_MODULE_NAME'               , 'MODULE_NAME'          , 'MODULE_NAME'     , '15%', 'Modules';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'AuditEvents.ListView'       , 6, 'Audit.LBL_LIST_AUDIT_ITEM'                , 'AUDIT_PARENT_ID'      , 'AUDIT_PARENT_ID' , '30%', 'listViewTdLinkS1', 'MODULE_FOLDER AUDIT_PARENT_ID', '~/{0}/view.aspx?id={1}', null, null, null;
end else begin
	-- 03/28/2019 Paul.  Convert to DateTime field. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'AuditEvents.ListView' and DATA_FIELD = 'DATE_MODIFIED' and DATA_FORMAT is null and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'AuditEvents.ListView'
		   and DATA_FIELD        = 'DATE_MODIFIED'
		   and DATA_FORMAT       is null
		   and DELETED           = 0;
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'AuditEvents.ListView'       , 2, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'        , 'DATE_MODIFIED'   , '15%', 'DateTime';
	end -- if;
	-- 02/24/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	if exists(select * from GRIDVIEWS where NAME = 'AuditEvents.ListView' and SORT_FIELD is null and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_UpdateSort null, 'AuditEvents.ListView', 'DATE_MODIFIED', 'desc';
	end -- if;
end -- if;
GO

-- 08/20/2019 Paul.  React Client needs an audit layout. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Audit.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Audit.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Audit.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Audit.ListView', 'Audit', 'vwAUDIT_VIEW';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.ListView', 0, 'Audit.LBL_FIELD_NAME'            , 'FIELD_NAME'          , 'FIELD_NAME'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.ListView', 1, 'Audit.LBL_OLD_NAME'              , 'BEFORE_VALUE'        , 'BEFORE_VALUE'   , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.ListView', 2, 'Audit.LBL_NEW_VALUE'             , 'AFTER_VALUE'         , 'AFTER_VALUE'    , '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.ListView', 3, 'Audit.LBL_CHANGED_BY'            , 'CREATED_BY'          , 'CREATED_BY'     , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Audit.ListView', 4, 'Audit.LBL_LIST_DATE'             , 'DATE_CREATED'        , 'DATE_CREATED'   , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Audit.ListView', 0, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Audit.ListView', 4, null, null, null, null, 0;
end -- if;
GO


-- 08/28/2019 Paul.  React Client needs an audit layout. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Audit.PersonalInfo';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Audit.PersonalInfo' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Audit.PersonalInfo';
	exec dbo.spGRIDVIEWS_InsertOnly           'Audit.PersonalInfo', 'Audit', 'vwAUDIT_VIEW';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.PersonalInfo', 0, 'Audit.LBL_LIST_FIELD'        , 'FIELD_NAME'          , 'FIELD_NAME'     , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.PersonalInfo', 1, 'Audit.LBL_LIST_VALUE'        , 'VALUE'               , 'VALUE'          , '45%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Audit.PersonalInfo', 2, 'Audit.LBL_LIST_LEAD_SOURCE'  , 'LEAD_SOURCE'         , 'LEAD_SOURCE'    , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Audit.PersonalInfo', 3, 'Audit.LBL_LIST_LAST_UPDATED' , 'LAST_UPDATED'        , 'LAST_UPDATED'   , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Audit.PersonalInfo', 3, null, null, null, null, 0;
end -- if;
GO


-- 05/28/2020 Paul.  React Client allows list view for signatures. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserSignatures.ListView'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserSignatures.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS UserSignatures.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly             'UserSignatures.ListView', 'UserSignatures', 'vwUSERS_SIGNATURES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'UserSignatures.ListView',  1, 'UserSignatures.LBL_LIST_NAME', 'NAME'             , 'NAME'             , '75%', 'listViewTdLinkS1', 'ID', '~/UserSignatures/view.aspx?id={0}', null, 'UserSignatures', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'UserSignatures.ListView',  3, '.LBL_LIST_DATE_ENTERED'      , 'DATE_ENTERED'     , 'DATE_ENTERED'     , '20%', 'DateTime';
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

call dbo.spGRIDVIEWS_COLUMNS_ListViews()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ListViews')
/

-- #endif IBM_DB2 */

