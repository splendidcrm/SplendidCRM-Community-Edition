

print 'GRIDVIEWS_COLUMNS SubPanel default';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME not like '%.ListView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 04/24/2008 Paul.  Allow sorting of sub panel. Copy the DATA_FIELD to SORT_EXPRESSION. 
-- 01/01/2008 Paul.  Documents, CampaignTrackers, EmailMarketing, EmailTemplates, Employees and ProductTemplates
-- all do not have ASSIGNED_USER_ID fields.  Remove them so that no attempt will be made to filter on ASSIGNED_USER_ID.  
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 06/07/2015 Paul.  Add Preview button. 

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Activities.Open', 'Accounts', 'vwACCOUNTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.Open'        , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Activities.Open'        , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.Open'        , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.Open'        , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Activities.Open'        , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Activities.Open'      , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Activities.History', 'Accounts', 'vwACCOUNTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.History'     , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Activities.History'     , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.History'     , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Activities.History'     , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Activities.History'     , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Activities.History'   , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Activities.History', -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Bugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Bugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Bugs', 'Accounts', 'vwACCOUNTS_BUGS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Bugs'                   , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Bugs'                   , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs'                   , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs'                   , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Bugs'                   , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Bugs'                 , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Bugs' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Bugs'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Cases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Cases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Cases', 'Accounts', 'vwACCOUNTS_CASES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases'                  , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases'                  , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Cases'                  , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Cases'                  , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Cases'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Cases' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Cases'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Contacts' and URL_FORMAT = 'Preview';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Contacts', 'Accounts', 'vwACCOUNTS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contacts'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Contacts'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contacts'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Contacts'               , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Contacts'             , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
	-- MODIFIED_USER_ID, GRID_NAME, COLUMN_INDEX, ITEMSTYLE_WIDTH, ITEMSTYLE_CSSCLASS, ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_VERTICAL_ALIGN, ITEMSTYLE_WRAP
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Accounts.Contacts'         , 3, null, null, null, null, 0;
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Contacts'          , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Leads', 'Accounts', 'vwACCOUNTS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Leads'                  , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   ,'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Leads'                  , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             ,'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Leads'                  , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            ,'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Leads'                  , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION','LEAD_SOURCE_DESCRIPTION', '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Leads'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Leads' and DATA_FIELD = 'LEAD_SOURCE' and LIST_NAME = 'lead_status_dom' and DELETED = 0) begin -- then
		print 'Accounts.Leads: Fix list name for LEAD_SOURCE.';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME         = 'lead_source_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where GRID_NAME         = 'Accounts.Leads'
		   and DATA_FIELD        = 'LEAD_SOURCE'
		   and LIST_NAME         = 'lead_status_dom'
		   and DELETED           = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Leads'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 12/04/2012 Paul.  ACCOUNT_ID points to the parent, not the member. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MemberOrganizations' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.MemberOrganizations';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.MemberOrganizations', 'Accounts', 'vwACCOUNTS_MEMBERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.MemberOrganizations'    , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   ,'NAME'                   , '20%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.MemberOrganizations'    , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   ,'CITY'                   , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.MemberOrganizations'    , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  ,'PHONE'                  , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.MemberOrganizations'  , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 05/09/2008 Paul.  Accounts.MemberOrganizations: Correct URL_ASSIGNED_FIELD.
	-- 12/04/2012 Paul.  Accounts.MemberOrganizations: Correct ASSIGNED_USER_ID is the correct value, plus fix ID and NAME. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MemberOrganizations' and DATA_FIELD = 'ACCOUNT_NAME' and URL_FIELD = 'ACCOUNT_ID' and DELETED = 0) begin -- then
		print 'Accounts.MemberOrganizations: Correct DATA_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD         = 'NAME'
		     , URL_FIELD          = 'ID'
		     , URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Accounts.MemberOrganizations'
		   and DATA_FIELD         = 'ACCOUNT_NAME'
		   and URL_FIELD          = 'ACCOUNT_ID'
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MemberOrganizations' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.MemberOrganizations'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 05/01/2006 Paul.  Fix view name. 
if exists(select * from GRIDVIEWS where NAME = 'Accounts.MemberOrganizations' and VIEW_NAME = 'vwACCOUNTS_MEMBERORGANIZATIONS' and DELETED = 0) begin -- then
	update GRIDVIEWS
	   set VIEW_NAME        = 'vwACCOUNTS_MEMBERS'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Accounts.MemberOrganizations'
	   and VIEW_NAME        = 'vwACCOUNTS_MEMBERORGANIZATIONS'
	   and DELETED          = 0;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Opportunities', 'Accounts', 'vwACCOUNTS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Opportunities'          , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Opportunities'          , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID'    , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Opportunities'          , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Opportunities'        , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Opportunities'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Projects' and DELETED = 0) begin -- then
	print 'Rename Accounts.Projects to Accounts.Project.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME         = 'Accounts.Project'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Accounts.Projects'
	   and DELETED           = 0;
end -- if;
GO

-- 12/04/2009 Paul.  We also need to correct the GRIDVIEWS table.  It is safer to delete, then re-insert to prevent duplicate entries. 
if exists(select * from GRIDVIEWS where NAME = 'Accounts.Projects' and DELETED = 0) begin -- then
	print 'Rename Accounts.Projects to Accounts.Project.';
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Accounts.Projects'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Project', 'Accounts', 'vwACCOUNTS_PROJECTS';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Project' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Project';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Project', 'Accounts', 'vwACCOUNTS_PROJECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Project'                , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project'                , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project'                , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Project'                , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Project'              , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Project' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Project'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 05/01/2006 Paul.  View has changed. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Project' and DATA_FIELD = 'USER_NAME' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set DATA_FIELD       = 'ASSIGNED_TO_NAME'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Accounts.Project'
	   and DATA_FIELD       = 'USER_NAME'
	   and DELETED          = 0;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MyAccounts';
-- 12/29/2009 Paul.  Use global term LBL_LIST_DATE_ENTERED. 
-- 02/20/2010 Paul.  Starting index should be 0 so that edit and view links will be at the end. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MyAccounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.MyAccounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.MyAccounts', 'Accounts', 'vwACCOUNTS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.MyAccounts'             , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   ,'NAME'                   , '40%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.MyAccounts'             , 1, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  ,'PHONE'                  , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.MyAccounts'             , 2, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'           ,'DATE_ENTERED'           , '30%', 'Date';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MyAccounts' and HEADER_TEXT = 'Accounts.LBL_LIST_DATE_ENTERED' and DELETED = 0) begin -- then
		print 'Accounts.MyAccounts: Use global term LBL_LIST_DATE_ENTERED.';
		update GRIDVIEWS_COLUMNS
		   set HEADER_TEXT      = '.LBL_LIST_DATE_ENTERED'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Accounts.MyAccounts'
		   and HEADER_TEXT      = 'Accounts.LBL_LIST_DATE_ENTERED'
		   and DELETED = 0;
	end -- if;
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.MyAccounts' and COLUMN_INDEX = 0 and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX     = COLUMN_INDEX - 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Accounts.MyAccounts'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Documents', 'Accounts', 'vwACCOUNTS_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Documents'              , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents'              , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents'              , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Documents'              , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Documents'            , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Accounts.Documents'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.ProspectLists', 'Accounts', 'vwACCOUNTS_PROSPECT_LISTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Activities.MyActivities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Activities.MyActivities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Activities.MyActivities', 'Activities', 'vwACTIVITIES_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Activities.MyActivities'         , 2, 'Activities.LBL_LIST_SUBJECT'              , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ASSIGNED_USER_ID';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Activities.MyActivities'         , 3, 'Activities.LBL_LIST_DATE'                 , 'DATE_START'             , 'DATE_START'             , '10%', 'Date';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Accounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Accounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Accounts', 'Bugs', 'vwBUGS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Accounts'                   , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Accounts'                   , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Accounts'                   , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Accounts'                 , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Accounts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Accounts'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Activities.Open', 'Bugs', 'vwBUGS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.Open'            , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.Activities.Open'            , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.Open'            , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.Open'            , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'BUG_NAME'               , 'BUG_NAME'               , '20%', 'listViewTdLinkS1', 'BUG_ID'     , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'BUG_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.Activities.Open'            , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Activities.Open'          , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Activities.History', 'Bugs', 'vwBUGS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.History'         , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.Activities.History'         , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.History'         , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Activities.History'         , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'BUG_NAME'               , 'BUG_NAME'               , '20%', 'listViewTdLinkS1', 'BUG_ID'     , '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'BUG_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.Activities.History'         , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Activities.History'       , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 08/05/2010 Paul.  Correct Case Status list name. Should be case_status_dom. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Cases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Cases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Cases', 'Bugs', 'vwBUGS_CASES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases'                      , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases'                      , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Cases'                      , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.Cases'                      , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Cases'                    , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 08/05/2010 Paul.  Correct Case Status list name. Should be case_status_dom. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Cases' and DATA_FIELD = 'STATUS' and LIST_NAME = 'bug_status_dom' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Bugs.Cases: Fix case_status_dom';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME        = 'case_status_dom'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Bugs.Cases'
		   and DATA_FIELD       = 'STATUS'
		   and LIST_NAME       <> 'case_status_dom'
		   and DELETED          = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Cases' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Cases'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Contacts', 'Bugs', 'vwBUGS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Contacts'                   , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Contacts'                   , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Contacts'                   , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Contacts'                   , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Bugs.Contacts'             , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Contacts'                 , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Contacts'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Contacts', 'Calls', 'vwCALLS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Contacts'                  , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Contacts'                  , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Contacts'                  , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Contacts'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Contacts'            , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Contacts'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Contacts'            , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Leads', 'Calls', 'vwCALLS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Leads'                     , 0, 'Leads.LBL_LIST_LEAD_NAME'                 , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Leads'                     , 1, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Leads'                     , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Leads'                     , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Leads'               , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Leads'                   , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Leads'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Users', 'Calls', 'vwCALLS_USERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Users'                     , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Users'                     , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Users'                     , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Users'                     , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Calls.Users'               , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Users'                   , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Users' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Users'               , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/08/2006 Paul.  Add Notes
-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Notes' 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Notes' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Notes';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Notes', 'Calls', 'vwCALLS_NOTES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes'                     , 0, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID'         , '~/Notes/view.aspx?id={0}'   , null, 'Notes'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes'                     , 1, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.Notes'                     , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'            , 'PARENT_NAME'            , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}' , null, 'Parents' , 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.Notes'                     , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Notes'                   , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Notes' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Calls.Notes'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.MyCalls' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.MyCalls';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.MyCalls', 'Calls', 'vwCALLS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.MyCalls'                   , 2, 'Calls.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Calls/view.aspx?id={0}', null, 'Calls', 'ASSIGNED_USER_ID';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.ProspectLists', 'Campaigns', 'vwCAMPAIGNS_PROSPECT_LISTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.ProspectLists'       , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ProspectLists' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.ProspectLists'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Activities.Open', 'Cases', 'vwCASES_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.Open'           , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Activities.Open'           , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.Open'           , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.Open'           , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'CASE_NAME'              , 'CASE_NAME'              , '20%', 'listViewTdLinkS1', 'CASE_ID'    , '~/Cases/view.aspx?id={0}', null, 'Cases', 'CASE_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Activities.Open'           , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Activities.Open'         , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Activities.History', 'Cases', 'vwCASES_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.History'        , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Activities.History'        , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.History'        , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Activities.History'        , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'CASE_NAME'              , 'CASE_NAME'              , '20%', 'listViewTdLinkS1', 'CASE_ID'    , '~/Cases/view.aspx?id={0}', null, 'Cases', 'CASE_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Activities.History'        , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Activities.History'      , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Bugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Bugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Bugs', 'Cases', 'vwCASES_BUGS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Bugs'                      , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Bugs'                      , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs'                      , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs'                      , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.Bugs'                      , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Bugs'                    , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Bugs' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Bugs'                , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Contacts', 'Cases', 'vwCASES_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Contacts'                  , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Contacts'                  , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Contacts'                  , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Contacts'                  , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Cases.Contacts'            , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Contacts'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Contacts'            , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 04/10/2013 Paul.  Add Projects relationship to Cases. 
-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Project';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Project' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Project';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Project', 'Cases', 'vwCASES_PROJECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Project'                   , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Project'                   , 1, 'Project.LBL_LIST_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'   , 'ESTIMATED_START_DATE'   , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.Project'                   , 2, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'     , 'ESTIMATED_END_DATE'     , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project'                   , 3, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project'                   , 4, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Project'                   , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Project'                 , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Project' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Project'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Activities.Open', 'Contacts', 'vwCONTACTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Activities.Open'        , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Activities.Open'        , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Activities.Open'        , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PARENT_NAME'            , 'PARENT_NAME'            ,  '1%', 'listViewTdLinkS1', 'PARENT_ID' , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Activities.Open'        , 5, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Activities.Open'      , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Activities.History', 'Contacts', 'vwCONTACTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Activities.History'     , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Activities.History'     , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Activities.History'     , 3, 'Activities.LBL_LIST_RELATED_TO'           , 'PARENT_NAME'            , 'PARENT_NAME'            ,  '1%', 'listViewTdLinkS1', 'PARENT_ID' , '~/Parents/view.aspx?id={0}', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Activities.History'     , 4, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Activities.History'   , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/01/2009 Paul.  Needed to fix the list name for TYPE and PRIORITY. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Bugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Bugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Bugs', 'Contacts', 'vwCONTACTS_BUGS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Bugs'                   , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Bugs'                   , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs'                   , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs'                   , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Bugs'                   , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Bugs'                 , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 09/01/2009 Paul.  Needed to fix the list name for TYPE and PRIORITY. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Bugs' and DATA_FIELD = 'TYPE' and LIST_NAME <> 'bug_type_dom' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Contacts.Bugs: Fix bug_type_dom';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME        = 'bug_type_dom'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Contacts.Bugs'
		   and DATA_FIELD       = 'TYPE'
		   and LIST_NAME        <> 'bug_type_dom'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Bugs' and DATA_FIELD = 'PRIORITY' and LIST_NAME <> 'bug_priority_dom' and DELETED = 0) begin -- then
		print 'GRIDVIEWS_COLUMNS Contacts.Bugs: Fix bug_type_dom';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME        = 'bug_priority_dom'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Contacts.Bugs'
		   and DATA_FIELD       = 'PRIORITY'
		   and LIST_NAME        <> 'bug_priority_dom'
		   and DELETED          = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Bugs' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Bugs'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Cases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Cases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Cases', 'Contacts', 'vwCONTACTS_CASES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases'                  , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases'                  , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Cases'                  , 2, '.LBL_LIST_CONTACT_NAME'                   , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '25%', 'listViewTdLinkS1', 'CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Cases'                  , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Cases'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Cases' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Cases'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 12/04/2012 Paul.  CONTACT_ID points to the parent, not the member. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.DirectReports' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.DirectReports';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.DirectReports', 'Contacts', 'vwCONTACTS_DIRECT_REPORTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.DirectReports'          , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.DirectReports'          , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.DirectReports'          , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'         , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.DirectReports'          , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contacts.DirectReports'    , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.DirectReports'        , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 12/04/2012 Paul.  Contacts.MemberOrganizations: Correct DATA_FIELD.
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.DirectReports' and DATA_FIELD = 'DIRECT_REPORT_NAME' and URL_FIELD = 'DIRECT_REPORT_ID' and DELETED = 0) begin -- then
		print 'Contacts.DirectReports: Correct DATA_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD         = 'NAME'
		     , URL_FIELD          = 'ID'
		     , URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Contacts.DirectReports'
		   and DATA_FIELD         = 'DIRECT_REPORT_NAME'
		   and URL_FIELD          = 'DIRECT_REPORT_ID'
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.DirectReports' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.DirectReports'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Leads', 'Contacts', 'vwCONTACTS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Leads'                  , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Leads'                  , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Leads'                  , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Leads'                  , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Leads'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Leads'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Opportunities', 'Contacts', 'vwCONTACTS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Opportunities'          , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Opportunities'          , 1, '.LBL_LIST_CONTACT_NAME'                   , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '25%', 'listViewTdLinkS1', 'CONTACT_ID'    , '~/Contacts/view.aspx?id={0}'     , null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Opportunities'          , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Opportunities'        , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Opportunities'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Projects' and DELETED = 0) begin -- then
	print 'Rename Contacts.Projects to Contacts.Project.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME         = 'Contacts.Project'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Contacts.Projects'
	   and DELETED           = 0;
end -- if;
GO

-- 12/04/2009 Paul.  We also need to correct the GRIDVIEWS table.  It is safer to delete, then re-insert to prevent duplicate entries. 
if exists(select * from GRIDVIEWS where NAME = 'Contacts.Projects' and DELETED = 0) begin -- then
	print 'Rename Contacts.Projects to Contacts.Project.';
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Contacts.Projects'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Project', 'Contacts', 'vwCONTACTS_PROJECTS';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Project' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Project';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Project', 'Contacts', 'vwCONTACTS_PROJECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Project'                , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project'                , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project'                , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Project'                , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Project'              , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Project' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Project'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.MyContacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.MyContacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.MyContacts', 'Contacts', 'vwCONTACTS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.MyContacts'             , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.MyContacts'             , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.MyContacts'             , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.MyContacts'             , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contacts.MyContacts'       , 3, null, null, null, null, 0;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Documents', 'Contacts', 'vwCONTACTS_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Documents'              , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents'              , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents'              , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Documents'              , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Documents'            , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Contacts.Documents'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Documents', 'Bugs', 'vwBUGS_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.Documents'                  , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents'                  , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents'                  , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents'                  , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Documents'                  , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Documents'                , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Bugs.Documents'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Documents', 'Cases', 'vwCASES_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.Documents'                 , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents'                 , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents'                 , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents'                 , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Documents'                 , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Documents'               , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Cases.Documents'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spGRIDVIEWS_COLUMNS_SubPanels()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_SubPanels')
/



Create Procedure dbo.spGRIDVIEWS_COLUMNS_SubPanels()
language sql
  begin
-- #endif IBM_DB2 */

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Contacts', 'Emails', 'vwEMAILS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Contacts'                 , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Contacts'                 , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Contacts'                 , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Contacts'                 , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Emails.Contacts'           , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Contacts'               , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Contacts'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Users', 'Emails', 'vwEMAILS_USERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Users'                    , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Users'                    , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Users'                    , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Users'                    , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Emails.Users'              , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Users'                  , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Users' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Users'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 04/21/2006 Paul.  SugarCRM 4.2 adds serveral email relationships. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Accounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Accounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Accounts', 'Emails', 'vwEMAILS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Accounts'                 , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Accounts'                 , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Accounts'                 , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Accounts'               , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Accounts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Accounts'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 08/22/2006 Paul.  Remove SALES_STAGE from Emails.ListView.  This bug is mostlikely only in QA. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView' and DATA_FIELD = 'SALES_STAGE' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ListView: Remove SALES_STAGE';
	delete from GRIDVIEWS_COLUMNS
	where GRID_NAME  = 'Emails.ListView'
	  and DATA_FIELD = 'SALES_STAGE';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Opportunities', 'Emails', 'vwEMAILS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Opportunities'            , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '50%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Opportunities'            , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '30%', 'listViewTdLinkS1', 'ACCOUNT_ID'    , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Opportunities'            , 2, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'            , 'SALES_STAGE'            , '20%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Opportunities'          , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Opportunities'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Leads', 'Emails', 'vwEMAILS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Leads'                    , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '20%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Leads'                    , 1, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '15%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Leads'                    , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Leads'                    , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '40%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Leads'                  , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Leads' and DATA_FIELD = 'LEAD_SOURCE' and LIST_NAME = 'lead_status_dom' and DELETED = 0) begin -- then
		print 'Emails.Leads: Fix list name for LEAD_SOURCE.';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME         = 'lead_source_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where GRID_NAME         = 'Emails.Leads'
		   and DATA_FIELD        = 'LEAD_SOURCE'
		   and LIST_NAME         = 'lead_status_dom'
		   and DELETED           = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Leads'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Cases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Cases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Cases', 'Emails', 'vwEMAILS_CASES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases'                    , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '10%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases'                    , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Cases'                    , 2, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Cases'                    , 3, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Cases'                    , 4, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Cases'                  , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Cases' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Cases'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Bugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Bugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Bugs', 'Emails', 'vwEMAILS_BUGS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Bugs'                     , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '10%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Bugs'                     , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs'                     , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '20%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs'                     , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '20%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.Bugs'                     , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '20%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Bugs'                   , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Bugs' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Bugs'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Projects' and DELETED = 0) begin -- then
	print 'Rename Emails.Projects to Emails.Project.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Emails.Project'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME        = 'Emails.Projects'
	   and DELETED          = 0;
end -- if;
GO

-- 09/01/2009 Paul.  We also need to correct the GRIDVIEWS table. 
if exists(select * from GRIDVIEWS where NAME = 'Emails.Projects' and DELETED = 0) begin -- then
	print 'Rename Emails.Projects to Emails.Project.';
	-- 09/01/2009 Paul.  It is safer to delete, then re-insert to prevent duplicate entries. 
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Emails.Projects'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Project', 'Emails', 'vwEMAILS_PROJECTS';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Project' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Project';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Project', 'Emails', 'vwEMAILS_PROJECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Project'                  , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project'                  , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project'                  , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Project'                  , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Project'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Project' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.Project'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/21/2007 Paul.  View has changed a long time ago, but we are just catching it now. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Project' and DATA_FIELD = 'USER_NAME' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Project: Fix ASSIGNED_TO';
	update GRIDVIEWS_COLUMNS
	   set DATA_FIELD       = 'ASSIGNED_TO_NAME'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Emails.Project'
	   and DATA_FIELD       = 'USER_NAME'
	   and DELETED          = 0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ProjectTasks' and DELETED = 0) begin -- then
	print 'Rename Emails.ProjectTasks to Emails.ProjectTask.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME         = 'Emails.ProjectTask'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Emails.ProjectTasks'
	   and DELETED           = 0;
end -- if;
GO

-- 09/01/2009 Paul.  We also need to correct the GRIDVIEWS table. 
if exists(select * from GRIDVIEWS where NAME = 'Emails.ProjectTasks' and DELETED = 0) begin -- then
	print 'Rename Emails.ProjectTasks to Emails.ProjectTask.';
	-- 09/01/2009 Paul.  It is safer to delete, then re-insert to prevent duplicate entries. 
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Emails.ProjectTasks'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ProjectTask', 'Emails', 'vwEMAILS_PROJECT_TASKS';
end -- if;
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

Declare
	StoO_selcnt INTEGER := 0;
BEGIN
	BEGIN
-- #endif Oracle */


-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ProjectTask' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ProjectTask';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ProjectTask', 'Emails', 'vwEMAILS_PROJECT_TASKS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ProjectTask'              , 0, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ProjectTask'              , 1, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'    , 'PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.ProjectTask'              , 2, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'                 , 'STATUS'                 , '15%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ProjectTask'              , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ProjectTask'              , 4, 'ProjectTask.LBL_LIST_DATE_DUE'            , 'DATE_DUE'               , 'DATE_DUE'               , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.ProjectTask'            , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ProjectTask' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Emails.ProjectTask'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Activities.Open', 'Leads', 'vwLEADS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.Open'           , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.Activities.Open'           , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.Open'           , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.Open'           , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'LEAD_NAME'              , 'LEAD_NAME'              , '20%', 'listViewTdLinkS1', 'LEAD_ID'    , '~/Leads/view.aspx?id={0}', null, 'Leads', 'LEAD_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.Activities.Open'           , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Activities.Open'         , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Activities.History', 'Leads', 'vwLEADS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.History'        , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.Activities.History'        , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.History'        , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Activities.History'        , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'LEAD_NAME'              , 'LEAD_NAME'              , '20%', 'listViewTdLinkS1', 'LEAD_ID'    , '~/Leads/view.aspx?id={0}', null, 'Leads', 'LEAD_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.Activities.History'        , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Activities.History'      , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Documents', 'Leads', 'vwLEADS_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.Documents'                 , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents'                 , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents'                 , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents'                 , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Documents'                 , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Documents'               , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Documents'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Contacts';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly             'Leads.Contacts', 'Leads', 'vwLEADS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Leads.Contacts'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Leads.Contacts'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Leads.Contacts'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'Leads.Contacts'               , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Contacts'               , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
	-- MODIFIED_USER_ID, GRID_NAME, COLUMN_INDEX, ITEMSTYLE_WIDTH, ITEMSTYLE_CSSCLASS, ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_VERTICAL_ALIGN, ITEMSTYLE_WRAP
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Leads.Contacts'           , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailMarketing.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailMarketing.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailMarketing.ProspectLists', 'EmailMarketing', 'vwEMAIL_MARKETING_PROSPECT_LST';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'EmailMarketing.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMarketing.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailMarketing.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'CallMarketing.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS CallMarketing.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'CallMarketing.ProspectLists', 'CallMarketing', 'vwCALL_MARKETING_PROSPECT_LST';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'CallMarketing.ProspectLists'          , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CallMarketing.ProspectLists'          , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CallMarketing.ProspectLists'          , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Contacts', 'Meetings', 'vwMEETINGS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Contacts'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Contacts'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Contacts'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Contacts'               , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Contacts'         , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Contacts'             , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Contacts'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Leads', 'Meetings', 'vwMEETINGS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Leads'                  , 0, 'Leads.LBL_LIST_LEAD_NAME'                 , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Leads'                  , 1, 'Leads.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Leads'                  , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Leads'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Leads'            , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Leads'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Leads'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 02/23/2006 Paul.  Add Notes
-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Notes' 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Notes' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Notes';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Notes', 'Meetings', 'vwMEETINGS_NOTES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes'                  , 0, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID'         , '~/Notes/view.aspx?id={0}'   , null, 'Notes'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes'                  , 1, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Notes'                  , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'            , 'PARENT_NAME'            , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}' , null, 'Parents' , 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.Notes'                  , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Notes'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Notes' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Notes'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Users', 'Meetings', 'vwMEETINGS_USERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Users'                  , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Users'                  , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.Users'                  , 2, 'Users.LBL_LIST_EMAIL'                     , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Users'                  , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Meetings.Users'            , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Users'                , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Users' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Meetings.Users'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.MyMeetings' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.MyMeetings';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.MyMeetings', 'Meetings', 'vwMEETINGS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.MyMeetings'             , 2, 'Meetings.LBL_LIST_SUBJECT'                , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Meetings/view.aspx?id={0}', null, 'Meetings', 'ASSIGNED_USER_ID';
end -- if;
GO

-- 05/08/2008 Paul.  Correct Opportunities.Activities.Open URL_ASSIGNED_FIELD.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Activities.Open', 'Opportunities', 'vwOPPORTUNITIES_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.Open'   , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID'   , '~/Activities/view.aspx?id={0}'   , null, 'Activities'   , 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Activities.Open'   , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.Open'   , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID'    , '~/Contacts/view.aspx?id={0}'     , null, 'Contacts'     , 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.Open'   , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'OPPORTUNITY_NAME'       , 'OPPORTUNITY_NAME'       , '20%', 'listViewTdLinkS1', 'OPPORTUNITY_ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'OPPORTUNITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Activities.Open'   , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Activities.Open' , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.Open' and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Correct Opportunities.Activities.Open URL_ASSIGNED_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACTIVITY_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Opportunities.Activities.Open'
		   and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 05/08/2008 Paul.  Correct Opportunities.Activities.Open URL_ASSIGNED_FIELD.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Activities.History', 'Opportunities', 'vwOPPORTUNITIES_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.History', 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID'   , '~/Activities/view.aspx?id={0}'   , null, 'Activities'   , 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Activities.History', 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.History', 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID'    , '~/Contacts/view.aspx?id={0}'     , null, 'Contacts'     , 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Activities.History', 4, 'Activities.LBL_LIST_RELATED_TO'           , 'OPPORTUNITY_NAME'       , 'OPPORTUNITY_NAME'       , '20%', 'listViewTdLinkS1', 'OPPORTUNITY_ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'OPPORTUNITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Activities.History', 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Activities.History', 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.History' and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID' and DELETED = 0) begin -- then
		print 'Correct Opportunities.Activities.History URL_ASSIGNED_FIELD.';
		update GRIDVIEWS_COLUMNS
		   set URL_ASSIGNED_FIELD = 'ACTIVITY_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'Opportunities.Activities.History'
		   and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO


/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spGRIDVIEWS_COLUMNS_SubPanels()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_SubPanels')
/

Create Procedure dbo.spGRIDVIEWS_COLUMNS_SubPanels()
language sql
  begin
-- #endif IBM_DB2 */


-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Contacts', 'Opportunities', 'vwOPPORTUNITIES_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contacts'          , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Contacts'          , 1, 'Contacts.LBL_LIST_CONTACT_ROLE'           , 'CONTACT_ROLE'           , 'CONTACT_ROLE'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contacts'          , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Contacts'          , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.Contacts'    , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Contacts'        , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Contacts'             , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Leads', 'Opportunities', 'vwOPPORTUNITIES_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Leads'             , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Leads'             , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Leads'             , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '23%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Leads'             , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Leads'           , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Leads'       , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Projects' and DELETED = 0) begin -- then
	print 'Rename Opportunities.Projects to Opportunities.Project.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME         = 'Opportunities.Project'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Opportunities.Projects'
	   and DELETED           = 0;
end -- if;
GO

-- 12/04/2009 Paul.  We also need to correct the GRIDVIEWS table.  It is safer to delete, then re-insert to prevent duplicate entries. 
if exists(select * from GRIDVIEWS where NAME = 'Opportunities.Projects' and DELETED = 0) begin -- then
	print 'Rename Opportunities.Projects to Opportunities.Project.';
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Opportunities.Projects'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Project', 'Opportunities', 'vwOPPORTUNITIES_PROJECTS';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Project' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Project';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Project', 'Opportunities', 'vwOPPORTUNITIES_PROJECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Project'           , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project'           , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project'           , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Project'           , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Project'         , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Project' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Project'     , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/21/2007 Paul.  View has changed a long time ago, but we are just catching it now. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Project' and DATA_FIELD = 'USER_NAME' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Project: Fix ASSIGNED_TO';
	update GRIDVIEWS_COLUMNS
	   set DATA_FIELD       = 'ASSIGNED_TO_NAME'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Opportunities.Project'
	   and DATA_FIELD       = 'USER_NAME'
	   and DELETED          = 0;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Documents' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Documents';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Documents', 'Opportunities', 'vwOPPORTUNITIES_DOCUMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Documents'         , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID'         , '~/Documents/view.aspx?id={0}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents'         , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents'         , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents'         , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Documents'         , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Documents'       , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Documents' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Opportunities.Documents'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.Accounts' and DELETED = 0) begin -- then
	print 'Fix Projects.Accounts GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.Accounts'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.Accounts'
	   and DELETED          = 0;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Accounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Accounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Accounts', 'Project', 'vwPROJECTS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Accounts'               , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Accounts'               , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Accounts'               , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Accounts'             , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Accounts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Accounts'         , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.Activities.Open' and DELETED = 0) begin -- then
	print 'Fix Projects.Activities.Open GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.Activities.Open'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.Activities.Open'
	   and DELETED          = 0;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Activities.Open', 'Project', 'vwPROJECTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.Open'        , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.Activities.Open'        , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.Open'        , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.Open'        , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_NAME'           , 'PROJECT_NAME'           , '20%', 'listViewTdLinkS1', 'PROJECT_ID' , '~/Projects/view.aspx?id={0}', null, 'Project', 'PROJECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Activities.Open'        , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Activities.Open'      , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.Activities.History' and DELETED = 0) begin -- then
	print 'Fix Projects.Activities.History GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.Activities.History'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.Activities.History'
	   and DELETED          = 0;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Activities.History', 'Project', 'vwPROJECTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.History'     , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.Activities.History'     , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.History'     , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Activities.History'     , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_NAME'           , 'PROJECT_NAME'           , '20%', 'listViewTdLinkS1', 'PROJECT_ID' , '~/Projects/view.aspx?id={0}', null, 'Project', 'PROJECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Activities.History'     , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Activities.History'   , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.Contacts' and DELETED = 0) begin -- then
	print 'Fix Projects.Contacts GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.Contacts'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.Contacts'
	   and DELETED          = 0;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Contacts', 'Project', 'vwPROJECTS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Contacts'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Contacts'               , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Project.Contacts'         , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Contacts'             , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Contacts'         , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.Opportunities' and DELETED = 0) begin -- then
	print 'Fix Projects.Opportunities GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.Opportunities'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.Opportunities'
	   and DELETED          = 0;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Opportunities', 'Project', 'vwPROJECTS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Opportunities'          , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Opportunities'          , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%', 'listViewTdLinkS1', 'ACCOUNT_ID'    , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Opportunities'          , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Opportunities'        , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.Opportunities'    , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Projects.ProjectTask' and DELETED = 0) begin -- then
	print 'Fix Projects.ProjectTask GRID_NAME to be consistent with all Project names being singular.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME        = 'Project.ProjectTask'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Projects.ProjectTasks'
	   and DELETED          = 0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ProjectTasks' and DELETED = 0) begin -- then
	print 'Rename Project.ProjectTasks to Project.ProjectTask.';
	update GRIDVIEWS_COLUMNS
	   set GRID_NAME         = 'Project.ProjectTask'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Project.ProjectTasks'
	   and DELETED           = 0;
end -- if;
GO

-- 12/04/2009 Paul.  We also need to correct the GRIDVIEWS table.  It is safer to delete, then re-insert to prevent duplicate entries. 
if exists(select * from GRIDVIEWS where NAME = 'Project.ProjectTasks' and DELETED = 0) begin -- then
	print 'Rename Project.ProjectTasks to Project.ProjectTask.';
	update GRIDVIEWS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = 'Project.ProjectTasks'
	   and DELETED          = 0;
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ProjectTask', 'Project', 'vwPROJECTS_PROJECT_TASKS';
end -- if;
GO

-- 07/15/2006 Paul.  Fix GRID_NAME to be consistent with all Project names being singular. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ProjectTask' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ProjectTask';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ProjectTask', 'Project', 'vwPROJECTS_PROJECT_TASKS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.ProjectTask'            , 0, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ProjectTask'            , 1, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'    , 'PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ProjectTask'            , 2, 'ProjectTask.LBL_LIST_STATUS'              , 'STATUS'                 , 'STATUS'                 , '15%', 'project_task_status_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ProjectTask'            , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ProjectTask'            , 4, 'ProjectTask.LBL_LIST_DATE_DUE'            , 'DATE_DUE'               , 'DATE_DUE'               , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.ProjectTask'          , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ProjectTask' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Project.ProjectTask'      , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO


-- 06/08/2006 Paul.  Fix Project module name. 
if exists(select * from GRIDVIEWS where MODULE_NAME = 'Projects' and DELETED = 0) begin -- then
	print 'Fix Project module name.';
	update GRIDVIEWS
	   set MODULE_NAME      = 'Project'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where MODULE_NAME      = 'Projects'
	   and DELETED          = 0;
end -- if;
GO


-- 02/27/2006 Paul.  Correct problem with ProjectTasks URL. 
if exists(select * from GRIDVIEWS_COLUMNS where URL_FORMAT like '%ProjectTask/view%' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set URL_FORMAT       = replace(URL_FORMAT, 'ProjectTask/view', 'ProjectTasks/view')
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where URL_FORMAT       like '%ProjectTask/view%'
	   and DELETED          = 0;
end -- if;
GO

-- 01/29/2008 Paul.  Display relationship between prospects and emails. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.Activities.Open', 'Prospects', 'vwPROSPECTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.Open'           , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Prospects.Activities.Open'           , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.Open'           , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}'  , null, 'Contacts'  , 'CONTACT_ASSIGNED_USER_ID' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.Open'           , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'PROSPECT_NAME'          , 'PROSPECT_NAME'          , '20%', 'listViewTdLinkS1', 'PROSPECT_ID', '~/Prospects/view.aspx?id={0}' , null, 'Prospects' , 'PROSPECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.Activities.Open'           , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.Activities.Open'         , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.Open' and URL_FIELD = 'LEAD_ID' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'PROSPECT_ID'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Prospects.Activities.Open'
		   and URL_FIELD        = 'LEAD_ID'
		   and DELETED          = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.Activities.History', 'Prospects', 'vwPROSPECTS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.History'        , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID', '~/Activities/view.aspx?id={0}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Prospects.Activities.History'        , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.History'        , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}'  , null, 'Contacts'  , 'CONTACT_ASSIGNED_USER_ID' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.Activities.History'        , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROSPECT_NAME'          , 'PROSPECT_NAME'          , '20%', 'listViewTdLinkS1', 'PROSPECT_ID', '~/Prospects/view.aspx?id={0}' , null, 'Prospects' , 'PROSPECT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.Activities.History'        , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.Activities.History'      , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.History' and URL_FIELD = 'LEAD_ID' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set URL_FIELD        = 'PROSPECT_ID'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Prospects.Activities.History'
		   and URL_FIELD        = 'LEAD_ID'
		   and DELETED          = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Prospects.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 01/27/2011 Paul.  Add MyProspects. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.MyProspects' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.MyProspects';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.MyProspects', 'Prospects', 'vwPROSPECTS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.MyProspects'           , 0, 'Prospects.LBL_LIST_NAME'                  , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.MyProspects'           , 1, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'                 , 'EMAIL1'                 , '30%', 'listViewTdLinkS1', 'ID', '~/Emails/edit.aspx?PARENT_ID={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.MyProspects'           , 2, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '25%', 'Date';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.Contacts', 'ProspectLists', 'vwPROSPECT_LISTS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Contacts'          , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Contacts'          , 1, 'Contacts.LBL_LIST_TITLE'                  , 'TITLE'                  , 'TITLE'                  , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Contacts'          , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Contacts'          , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'ProspectLists.Contacts'    , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Contacts'        , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Contacts'    , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.Leads', 'ProspectLists', 'vwPROSPECT_LISTS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Leads'             , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Leads'             , 1, 'Leads.LBL_LIST_TITLE'                     , 'TITLE'                  , 'TITLE'                  , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Leads'             , 2, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Leads'             , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'ProspectLists.Leads'       , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Leads'           , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Leads'       , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Prospects' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.Prospects';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.Prospects', 'ProspectLists', 'vwPROSPECT_LISTS_PROSPECTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Prospects'         , 0, 'Prospects.LBL_LIST_PROSPECT_NAME'         , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Prospects/view.aspx?id={0}', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Prospects'         , 1, 'Prospects.LBL_LIST_TITLE'                 , 'TITLE'                  , 'TITLE'                  , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Prospects'         , 2, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Prospects'         , 3, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'ProspectLists.Prospects'   , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Prospects'       , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Prospects' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Prospects'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.Users', 'ProspectLists', 'vwPROSPECT_LISTS_USERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Users'             , 0, 'Prospects.LBL_LIST_USER_NAME'             , 'USER_NAME'              , 'USER_NAME'              , '25%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Users'             , 1, 'Prospects.LBL_LIST_EMAIL_ADDRESS'         , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Users'             , 2, '.LBL_LIST_PHONE'                          , 'PHONE_WORK'             , 'PHONE_WORK'             , '35%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'ProspectLists.Users'       , 2, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Users'           , 3, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Users' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Users'    , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 10/27/2017 Paul.  Add Accounts as email source. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Accounts';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.Accounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.Accounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.Accounts', 'ProspectLists', 'vwPROSPECT_LISTS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Accounts'          , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Accounts'          , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProspectLists.Accounts'          , 2, 'Accounts.LBL_LIST_EMAIL1'                 , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.Accounts'          , 3, '.LBL_LIST_PHONE'                          , 'PHONE_OFFICE'           , 'PHONE_OFFICE'           , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'ProspectLists.Accounts'    , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProspectLists.Accounts'        , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.MyBugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.MyBugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.MyBugs', 'Bugs', 'vwBUGS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.MyBugs'                     , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.MyBugs'                     , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.MyBugs'                     , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.MyBugs'                     , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '10%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.MyBugs'                     , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '10%', 'bug_priority_dom';
end -- if;
GO

-- 02/20/2010 Paul.  Starting index should be 0 so that edit and view links will be at the end. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.MyCases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.MyCases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.MyCases', 'Cases', 'vwCASES_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.MyCases'                   , 0, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID'        , '~/Cases/view.aspx?id={0}'   , null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.MyCases'                   , 1, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '40%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.MyCases'                   , 2, 'Cases.LBL_LIST_PRIORITY'                  , 'PRIORITY'               , 'PRIORITY'               , '10%', 'case_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.MyCases'                   , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '10%', 'case_status_dom';
end else begin
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.MyCases' and COLUMN_INDEX = 0 and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set COLUMN_INDEX     = COLUMN_INDEX - 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Cases.MyCases'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 12/29/2009 Paul.  Use global term LBL_LIST_DATE_ENTERED. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.MyLeads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.MyLeads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.MyLeads', 'Leads', 'vwLEADS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.MyLeads'                   , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.MyLeads'                   , 1, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '40%', 'Date';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.MyLeads' and HEADER_TEXT = 'Leads.LBL_LIST_DATE_ENTERED' and DELETED = 0) begin -- then
		print 'Leads.MyLeads: Use global term LBL_LIST_DATE_ENTERED.';
		update GRIDVIEWS_COLUMNS
		   set HEADER_TEXT      = '.LBL_LIST_DATE_ENTERED'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Leads.MyLeads'
		   and HEADER_TEXT      = 'Leads.LBL_LIST_DATE_ENTERED'
		   and DELETED = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.MyOpportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.MyOpportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.MyOpportunities', 'Opportunities', 'vwOPPORTUNITIES_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.MyOpportunities'   , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.MyOpportunities'   , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '40%', 'listViewTdLinkS1', 'ACCOUNT_ID'    , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.MyOpportunities'   , 2, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR'        , 'AMOUNT_USDOLLAR'        , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.MyOpportunities'   , 3, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '10%', 'Date';
end -- if;
GO

-- 05/07/2006 Paul.  Currencies should use the USD value in order to be converted properly. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.MyOpportunities' and DATA_FIELD = 'AMOUNT' and DATA_FORMAT = 'Currency' and DELETED = 0) begin -- then
	print 'Currencies should use the USD value in order to be converted properly. ';
	update GRIDVIEWS_COLUMNS
	   set DATA_FIELD       = 'AMOUNT_USDOLLAR'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where GRID_NAME        = 'Opportunities.MyOpportunities'
	   and DATA_FIELD       = 'AMOUNT'
	   and DATA_FORMAT      = 'Currency'
	   and DELETED          = 0;
end -- if;
GO

-- 01/13/2010 Paul.  Add My Projects dashlet. 
-- 08/01/2013 Paul.  Fix for Project link.  It should have been fixed on 02/18/2010. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.MyProjects' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.MyProjects';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.MyProjects', 'Project', 'vwPROJECTS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.MyProjects'              , 1, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'              , '40%', 'listViewTdLinkS1', 'ID', '~/Projects/view.aspx?id={0}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.MyProjects'              , 2, 'Project.LBL_LIST_PRIORITY'                , 'PRIORITY'               , 'PRIORITY'          , '20%', 'project_task_priority_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.MyProjects'              , 3, 'Project.LBL_LIST_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'     , 'ESTIMATED_END_DATE', '20%', 'Date';
end else begin
	-- 02/18/2010 Paul.  Project link was pointing to ProjectTask. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.MyProjects' and (URL_FORMAT = '~/ProjectTasks/view.aspx?id={0}' or URL_MODULE = 'ProjectTask') and DELETED = 0) begin -- then
		print 'Project link was pointing to ProjectTask. ';
		update GRIDVIEWS_COLUMNS
		   set URL_FORMAT       = '~/Projects/view.aspx?id={0}'
		     , URL_MODULE       = 'Project'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where GRID_NAME        = 'Project.MyProjects'
		   and (URL_FORMAT      = '~/ProjectTasks/view.aspx?id={0}' or URL_MODULE = 'ProjectTask')
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.MyProjectTasks' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.MyProjectTasks';
	-- 06/08/2006 Paul.  Fix grid view to reference ProjectTask module. 
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.MyProjectTasks', 'ProjectTask', 'vwPROJECT_TASKS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.MyProjectTasks'      , 1, 'ProjectTask.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'    , '40%', 'listViewTdLinkS1', 'ID', '~/ProjectTasks/view.aspx?id={0}', null, 'ProjectTask', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.MyProjectTasks'      , 2, 'ProjectTask.LBL_LIST_PRIORITY'            , 'PRIORITY'               , 'PRIORITY', '20%', 'project_task_priority_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.MyProjectTasks'      , 3, 'ProjectTask.LBL_LIST_DATE_DUE'            , 'DATE_DUE'               , 'DATE_DUE', '20%', 'Date';
end -- if;
GO

-- 06/08/2006 Paul.  Add Activities. 
-- 05/07/2008 Paul.  The RELATED_TO field should be PROJECT_TASK
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.Open' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.Activities.Open';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.Activities.Open', 'ProjectTask', 'vwPROJECT_TASKS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.Open'     , 2, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID'    , '~/Activities/view.aspx?id={0}' , null, 'Activities' , 'ACTIVITY_ASSIGNED_USER_ID'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.Activities.Open'     , 3, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.Open'     , 4, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID'     , '~/Contacts/view.aspx?id={0}'   , null, 'Contacts'   , 'CONTACT_ASSIGNED_USER_ID'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.Open'     , 5, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_TASK_NAME'      , 'PROJECT_TASK_NAME'      , '20%', 'listViewTdLinkS1', 'PROJECT_TASK_ID', '~/ProjectTask/view.aspx?id={0}', null, 'ProjectTask', 'PROJECT_TASK_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.Activities.Open'     , 6, 'Activities.LBL_LIST_DUE_DATE'             , 'DATE_DUE'               , 'DATE_DUE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.Activities.Open'   , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 05/07/2008 Paul.  The RELATED_TO field should be PROJECT_TASK. 
	-- 10/27/2008 Paul.  The URL_FIELD can be ACCOUNT_ID. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.Open' and (DATA_FIELD = 'ACCOUNT_NAME' or URL_FIELD = 'ACCOUNT_ID') and DELETED = 0) begin -- then
		print 'ProjectTask.Activities.Open: The RELATED_TO field should be PROJECT_TASK.';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD         = 'PROJECT_TASK_NAME'
		     , SORT_EXPRESSION    = 'PROJECT_TASK_NAME'
		     , URL_FIELD          = 'PROJECT_TASK_ID'
		     , URL_ASSIGNED_FIELD = 'PROJECT_TASK_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'ProjectTask.Activities.Open'
		   and (DATA_FIELD = 'ACCOUNT_NAME' or URL_FIELD = 'ACCOUNT_ID')
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.Open' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.Activities.Open'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/29/2008 Paul.  ACCOUNT_NAME should be PROJECT_TASK_NAME. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.History' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.Activities.History';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.Activities.History', 'ProjectTask', 'vwPROJECT_TASKS_ACTIVITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.History'  , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID'     , '~/Activities/view.aspx?id={0}' , null, 'Activities' , 'ACTIVITY_ASSIGNED_USER_ID'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.Activities.History'  , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.History'  , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID'      , '~/Contacts/view.aspx?id={0}'   , null, 'Contacts'   , 'CONTACT_ASSIGNED_USER_ID'     ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ProjectTask.Activities.History'  , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'PROJECT_TASK_NAME'      , 'PROJECT_TASK_NAME'      , '20%', 'listViewTdLinkS1', 'PROJECT_TASK_ID' , '~/ProjectTask/view.aspx?id={0}', null, 'ProjectTask', 'PROJECT_TASK_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.Activities.History'  , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.Activities.History', 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 05/07/2008 Paul.  The RELATED_TO field should be PROJECT_TASK. 
	-- 10/27/2008 Paul.  The URL_FIELD can be ACCOUNT_ID. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.History' and (DATA_FIELD = 'ACCOUNT_NAME' or URL_FIELD = 'ACCOUNT_ID') and DELETED = 0) begin -- then
		print 'ProjectTask.Activities.History: The RELATED_TO field should be PROJECT_TASK.';
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD         = 'PROJECT_TASK_NAME'
		     , SORT_EXPRESSION    = 'PROJECT_TASK_NAME'
		     , URL_FIELD          = 'PROJECT_TASK_ID'
		     , URL_ASSIGNED_FIELD = 'PROJECT_TASK_ASSIGNED_USER_ID'
		     , DATE_MODIFIED      = getdate()
		     , MODIFIED_USER_ID   = null
		 where GRID_NAME          = 'ProjectTask.Activities.History'
		   and (DATA_FIELD = 'ACCOUNT_NAME' or URL_FIELD = 'ACCOUNT_ID')
		   and DELETED            = 0;
	end -- if;
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Activities.History' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'ProjectTask.Activities.History'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.MyTasks' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.MyTasks';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.MyTasks', 'Tasks', 'vwTASKS_MyList';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.MyTasks'                   , 1, 'Tasks.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'    , '40%', 'listViewTdLinkS1', 'ID', '~/Tasks/view.aspx?id={0}', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Tasks.MyTasks'                   , 2, 'Tasks.LBL_LIST_PRIORITY'                  , 'PRIORITY'               , 'PRIORITY', '10%', 'task_priority_dom';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.MyTasks'                   , 3, 'Tasks.LBL_LIST_DUE_DATE'                  , 'DATE_DUE'               , 'DATE_DUE', '10%', 'Date';
end -- if;
GO

-- 07/11/2007 Paul.  Add CampaignTrackers and EmailMarketing modules. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.CampaignTrackers' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.CampaignTrackers';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.CampaignTrackers', 'Campaigns', 'vwCAMPAIGNS_CAMPAIGN_TRKRS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.CampaignTrackers'      , 0, 'CampaignTrackers.LBL_TRACKER_NAME'        , 'TRACKER_NAME'           , 'TRACKER_NAME'           , '20%', 'listViewTdLinkS1', 'ID'         , '~/CampaignTrackers/view.aspx?id={0}', null, 'CampaignTrackers', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.CampaignTrackers'      , 1, 'CampaignTrackers.LBL_TRACKER_URL'         , 'TRACKER_URL'            , 'TRACKER_URL'            , '50%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.CampaignTrackers'      , 2, 'CampaignTrackers.LBL_TRACKER_KEY'         , 'TRACKER_KEY'            , 'TRACKER_KEY'            , '20%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.EmailMarketing';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.EmailMarketing' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.EmailMarketing';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.EmailMarketing', 'Campaigns', 'vwCAMPAIGNS_EMAIL_MARKETING';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.EmailMarketing'        , 0, 'EmailMarketing.LBL_LIST_NAME'             , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID'         , '~/EmailMarketing/view.aspx?id={0}'  , null, 'EmailMarketing', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.EmailMarketing'        , 1, 'EmailMarketing.LBL_LIST_DATE_START'       , 'DATE_START'             , 'DATE_START'             , '20%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.EmailMarketing'        , 2, 'EmailMarketing.LBL_LIST_STATUS'           , 'STATUS'                 , 'STATUS'                 , '20%', 'call_marketing_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.EmailMarketing'        , 3, 'EmailMarketing.LBL_LIST_TEMPLATE_NAME'    , 'TEMPLATE_NAME'          , 'TEMPLATE_NAME'          , '25%', 'listViewTdLinkS1', 'TEMPLATE_ID', '~/EmailTemplates/view.aspx?id={0}'  , null, 'EmailTemplates', null;
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.CallMarketing';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.CallMarketing' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.CallMarketing';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.CallMarketing', 'Campaigns', 'vwCAMPAIGNS_CALL_MARKETING';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.CallMarketing'         , 0, 'CallMarketing.LBL_LIST_NAME'              , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID'         , '~/CallMarketing/view.aspx?id={0}'   , null, 'CallMarketing', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.CallMarketing'         , 1, 'CallMarketing.LBL_LIST_DATE_START'        , 'DATE_START'             , 'DATE_START'             , '20%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.CallMarketing'         , 2, 'CallMarketing.LBL_LIST_STATUS'            , 'STATUS'                 , 'STATUS'                 , '20%', 'call_marketing_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.CallMarketing'         , 3, 'CallMarketing.LBL_LIST_DISTRIBUTION'      , 'DISTRIBUTION'           , 'DISTRIBUTION'           , '20%', 'call_distribution_dom';
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.Leads', 'Campaigns', 'vwCAMPAIGNS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.Leads'                 , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '20%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.Leads'                 , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.Leads'                 , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '15%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.Leads'                 , 3, 'Leads.LBL_LIST_PHONE'                     , 'PHONE_WORK'             , 'PHONE_WORK'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.Leads'                 , 4, 'Leads.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                 , 'EMAIL1'                 , '10%', 'listViewTdLinkS1', 'EMAIL1'     , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.Leads'                 , 5, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.Leads'                 , 6, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.Leads'               , 7, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.Leads'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.Opportunities', 'Campaigns', 'vwCAMPAIGNS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.Opportunities'         , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'        , '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.Opportunities'         , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}'     , null, 'Accounts'     , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.Opportunities'         , 2, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'            , 'SALES_STAGE'            , '15%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.Opportunities'         , 3, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.Opportunities'         , 4, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR'        , 'AMOUNT_USDOLLAR'        , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.Opportunities'         , 5, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.Opportunities'       , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Campaigns.Opportunities'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 01/01/2008 Paul.  We need to specify the URL_MODULE. 
-- 03/18/2010 Paul.  Remove the old and shared TrackLog in favor of separate views for each panel. 
/*
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackLog' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackLog';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackLog', 'CampaignLog', 'vwCAMPAIGN_LOG_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLog'              , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLog'              , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackLog'              , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackLog'              , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLog'              , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackLog'              , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
*/
if exists(select * from GRIDVIEWS where NAME = 'Campaigns.TrackLog' and DELETED = 0) begin -- then
	update GRIDVIEWS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where NAME              = 'Campaigns.TrackLog'
	   and DELETED           = 0;
end -- if;

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackLog' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GRID_NAME         = 'Campaigns.TrackLog'
	   and DELETED           = 0;
end -- if;
GO

-- 03/18/2010 Paul.  Use separate views for each tracker panel. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackBlocked' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackBlocked';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackBlocked', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackBlocked';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackBlocked'          , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackBlocked'          , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackBlocked'          , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackBlocked'          , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackBlocked'          , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackBlocked'          , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackClickThru' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackClickThru';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackClickThru', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackClickThru';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackClickThru'        , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackClickThru'        , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackClickThru'        , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackClickThru'        , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackClickThru'        , 4, 'CampaignTrackers.LBL_TRACKER_NAME'        , 'TRACKER_NAME'           , 'TRACKER_NAME'           , '20%', 'listViewTdLinkS1', 'ID'        , '~/CampaignTrackers/view.aspx?id={0}', null, 'CampaignTrackers', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackClickThru'        , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackInvalidEmail' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackInvalidEmail';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackInvalidEmail', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackInvalid';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackInvalidEmail'     , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackInvalidEmail'     , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackInvalidEmail'     , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackInvalidEmail'     , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackInvalidEmail'     , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackInvalidEmail'     , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackLeads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackLeads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackLeads', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackLeads';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLeads'            , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLeads'            , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackLeads'            , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackLeads'            , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackLeads'            , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackLeads'            , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackRemoved' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackRemoved';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackRemoved', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackRemoved';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackRemoved'          , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackRemoved'          , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackRemoved'          , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackRemoved'          , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackRemoved'          , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackRemoved'          , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackSendError' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackSendError';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackSendError', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackSendError';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackSendError'        , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackSendError'        , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackSendError'        , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackSendError'        , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackSendError'        , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackSendError'        , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackTargeted' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackTargeted';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackTargeted', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackTargeted';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackTargeted'         , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackTargeted'         , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackTargeted'         , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackTargeted'         , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackTargeted'         , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackTargeted'         , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackViewed' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackViewed';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackViewed', 'CampaignLog', 'vwCAMPAIGN_LOG_TrackViewed';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackViewed'           , 0, 'CampaignLog.LBL_LIST_RECIPIENT_NAME'      , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackViewed'           , 1, 'CampaignLog.LBL_LIST_RECIPIENT_EMAIL'     , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '15%', 'listViewTdLinkS1', 'TARGET_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Campaigns.TrackViewed'           , 2, 'CampaignLog.LBL_ACTIVITY_TYPE'            , 'ACTIVITY_TYPE'          , 'ACTIVITY_TYPE'          , '15%', 'campainglog_activity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackViewed'           , 3, 'CampaignLog.LBL_LIST_ACTIVITY_DATE'       , 'ACTIVITY_DATE'          , 'ACTIVITY_DATE'          , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackViewed'           , 4, 'CampaignLog.LBL_RELATED'                  , 'RELATED_NAME'           , 'RELATED_NAME'           , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Emails/view.aspx?id={0}' , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackViewed'           , 5, 'CampaignLog.LBL_HITS'                     , 'HITS'                   , 'HITS'                   , '15%';
end -- if;
GO

-- 01/01/2008 Paul.  We need to specify the URL_MODULE. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.TrackQueue' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.TrackQueue';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.TrackQueue', 'EmailMan', 'vwEMAILMAN_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackQueue'            , 0, 'EmailMan.LBL_LIST_RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , 'RECIPIENT_NAME'         , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Campaigns.TrackQueue'            , 1, 'EmailMan.LBL_LIST_RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , 'RECIPIENT_EMAIL'        , '20%', 'listViewTdLinkS1', 'RELATED_ID', '~/Parents/view.aspx?id={0}' , null, 'Parents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.TrackQueue'            , 2, 'EmailMan.LBL_LIST_MESSAGE_NAME'           , 'EMAIL_MARKETING_NAME'   , 'EMAIL_MARKETING_NAME'   , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.TrackQueue'            , 3, 'EmailMan.LBL_LIST_SEND_DATE_TIME'         , 'SEND_DATE_TIME'         , 'SEND_DATE_TIME'         , '20%', 'Date';
end -- if;
GO

-- 01/05/2021 Paul.  Include IS_ADMIN for the React Client. 
-- 01/05/2021 Paul.  Don't wrap name and dates. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.Logins';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.Logins' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.Logins';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.Logins', 'Users', 'vwUSERS_LOGINS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 0, 'Users.LBL_LIST_NAME'                      , 'FULL_NAME'              , 'FULL_NAME'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 1, 'Users.LBL_LIST_USER_NAME'                 , 'USER_NAME'              , 'USER_NAME'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 2, 'Users.LBL_LIST_LOGIN_DATE'                , 'LOGIN_DATE'             , 'LOGIN_DATE'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 3, 'Users.LBL_LIST_LOGOUT_DATE'               , 'LOGOUT_DATE'            , 'LOGOUT_DATE'            , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Users.Logins'                    , 4, 'Users.LBL_LIST_LOGIN_STATUS'              , 'LOGIN_STATUS'           , 'LOGIN_STATUS'           , '10%', 'login_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Users.Logins'                    , 5, 'Users.LBL_LIST_LOGIN_TYPE'                , 'LOGIN_TYPE'             , 'LOGIN_TYPE'             , '10%', 'login_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 6, 'Users.LBL_LIST_REMOTE_HOST'               , 'REMOTE_HOST'            , 'REMOTE_HOST'            , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 7, 'Users.LBL_LIST_TARGET'                    , 'TARGET'                 , 'TARGET'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Logins'                    , 8, 'Users.LBL_LIST_ASPNET_SESSIONID'          , 'ASPNET_SESSIONID'       , 'ASPNET_SESSIONID'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Users.Logins'                    , 9, 'Users.LBL_LIST_ADMIN'                     , 'IS_ADMIN'               , 'IS_ADMIN'               , '5%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 0, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 2, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 3, null, null, null, null, 0;
end else begin
	-- 01/05/2021 Paul.  Include IS_ADMIN for the React Client. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.Logins' and DATA_FIELD = 'IS_ADMIN' and COLUMN_TYPE = 'BoundColumn' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Users.Logins'                    , 9, 'Users.LBL_LIST_ADMIN'                     , 'IS_ADMIN'               , 'IS_ADMIN'               , '5%', 'CheckBox';
		exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 0, null, null, null, null, 0;
		exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 2, null, null, null, null, 0;
		exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Users.Logins'              , 3, null, null, null, null, 0;
	end -- if;
end -- if;
GO

-- 04/24/2008 Paul.  Almost all sub panels allow sorting. 
-- 09/09/2012 Paul.  Ignore Export, Portal and PopupView. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME not like '%.ListView%' and GRID_NAME not like '%.LineItems' and GRID_NAME not like '%.Balance' and GRID_NAME not like '%.Export' and GRID_NAME not like '%.Portal' and GRID_NAME not like '%.PopupView' and GRID_NAME <> 'Workflows.WorkflowTriggerShells' and SORT_EXPRESSION is null and DELETED = 0) begin -- then
	print 'Add sorting to sub panels.';
	update GRIDVIEWS_COLUMNS
	   set SORT_EXPRESSION = DATA_FIELD
	 where DELETED = 0
	   and GRID_NAME in
		( 'Accounts.Activities.History'
		, 'Accounts.Activities.Open'
		, 'Accounts.Contacts'
		, 'Accounts.Contracts'
		, 'Accounts.CreditCards'
		, 'Accounts.Invoices'
		, 'Accounts.Leads'
		, 'Accounts.MemberOrganizations'
		, 'Accounts.MyAccounts'
		, 'Accounts.Opportunities'
		, 'Accounts.Orders'
		, 'Accounts.Payments'
		, 'Accounts.Products'
		, 'Accounts.Project'
		, 'Accounts.Quotes'
		, 'Accounts.Threads'
		, 'Activities.MyActivities'
		, 'Bugs.Accounts'
		, 'Bugs.Activities.History'
		, 'Bugs.Activities.Open'
		, 'Bugs.Cases'
		, 'Bugs.Contacts'
		, 'Bugs.MyBugs'
		, 'Bugs.Threads'
		, 'Calls.Contacts'
		, 'Calls.MyCalls'
		, 'Calls.Notes'
		, 'Calls.Users'
		, 'Campaigns.CampaignTrackers'
		, 'Campaigns.EmailMarketing'
		, 'Campaigns.Leads'
		, 'Campaigns.Opportunities'
		, 'Campaigns.ProspectLists'
		, 'Campaigns.TrackLog'
		, 'Campaigns.TrackQueue'
		, 'Cases.Activities.History'
		, 'Cases.Activities.Open'
		, 'Cases.Bugs'
		, 'Cases.Contacts'
		, 'Cases.MyCases'
		, 'Cases.Threads'
		, 'Contacts.Activities.History'
		, 'Contacts.Activities.Open'
		, 'Contacts.Bugs'
		, 'Contacts.Cases'
		, 'Contacts.DirectReports'
		, 'Contacts.Leads'
		, 'Contacts.MyContacts'
		, 'Contacts.Opportunities'
		, 'Contacts.Products'
		, 'Contacts.Project'
		, 'Contacts.Quotes'
		, 'Contracts.Contacts'
		, 'Contracts.Documents'
		, 'Contracts.Notes'
		, 'Contracts.Products'
		, 'Contracts.Quotes'
		, 'CreditCards.PopupView'
		, 'Emails.Accounts'
		, 'Emails.Bugs'
		, 'Emails.Cases'
		, 'Emails.Contacts'
		, 'Emails.Leads'
		, 'Emails.Opportunities'
		, 'Emails.Project'
		, 'Emails.ProjectTasks'
		, 'Emails.Quotes'
		, 'Emails.Users'
		, 'FlexiblePayments.StatusChanges'
		, 'FlexiblePayments.Tokens.TokenUsageLimit'
		, 'FlexiblePayments.TransactionParts'
		, 'Forums.Threads'
		, 'Invoices.Activities.History'
		, 'Invoices.Activities.Open'
		, 'Invoices.Payments'
		, 'Leads.Activities.History'
		, 'Leads.Activities.Open'
		, 'Leads.MyLeads'
		, 'Leads.Threads'
		, 'Meetings.Contacts'
		, 'Meetings.MyMeetings'
		, 'Meetings.Users'
		, 'Opportunities.Activities.History'
		, 'Opportunities.Activities.Open'
		, 'Opportunities.Contacts'
		, 'Opportunities.Contracts'
		, 'Opportunities.Leads'
		, 'Opportunities.MyOpportunities'
		, 'Opportunities.Project'
		, 'Opportunities.Quotes'
		, 'Opportunities.Threads'
		, 'Orders.Activities.History'
		, 'Orders.Activities.Open'
		, 'Orders.Invoices'
		, 'Payments.Invoices'
		, 'Payments.PaymentTransactions'
		, 'Products.Notes'
		, 'Products.RelatedProducts'
		, 'Project.Accounts'
		, 'Project.Activities.History'
		, 'Project.Activities.Open'
		, 'Project.Contacts'
		, 'Project.Opportunities'
		, 'Project.ProjectTasks'
		, 'Project.Quotes'
		, 'Project.Search'
		, 'Project.Threads'
		, 'ProjectTask.Activities.History'
		, 'ProjectTask.Activities.Open'
		, 'ProspectLists.Contacts'
		, 'ProspectLists.Leads'
		, 'ProspectLists.Prospects'
		, 'ProspectLists.Users'
		, 'Prospects.Activities.History'
		, 'Prospects.Activities.Open'
		, 'Quotes.Activities.History'
		, 'Quotes.Activities.Open'
		, 'Quotes.Contracts'
		, 'Quotes.Invoices'
		, 'Quotes.Orders'
		, 'Quotes.Project'
		, 'Threads.Posts'
		, 'Users.Logins'
		);
end -- if;
GO

-- 05/09/2008 Paul.  Correct all activities. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Activities.%' and URL_MODULE = 'Activities' and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID' and DELETED = 0) begin -- then
	print 'Correct all Activities URL_ASSIGNED_FIELD.';
	update GRIDVIEWS_COLUMNS
	   set URL_ASSIGNED_FIELD = 'ACTIVITY_ASSIGNED_USER_ID'
	     , DATE_MODIFIED      = getdate()
	     , MODIFIED_USER_ID   = null
	 where GRID_NAME          like '%.Activities.%'
	   and URL_MODULE         = 'Activities'
	   and URL_ASSIGNED_FIELD = 'ASSIGNED_USER_ID'
	   and DELETED            = 0;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.MyEmails';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.MyEmails' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.MyEmails';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.MyEmails'            , 'Emails', 'vwEMAILS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.MyEmails'            , 1, 'Emails.LBL_LIST_FROM_NAME'                , 'FROM_NAME'       , 'FROM_NAME'       , '20%', 'listViewTdLinkS1', 'ID'         , '~/Emails/preview.aspx?id={0}', null, 'Emails', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.MyEmails'            , 2, 'Emails.LBL_LIST_SUBJECT'                  , 'NAME'            , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Emails/preview.aspx?id={0}', null, 'Emails', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.MyEmails'            , 3, 'Emails.LBL_LIST_DATE_START'               , 'DATE_START'      , 'DATE_START'      , '15%', 'DateTime';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.MyEmails'            , 4, 'Emails.LBL_LIST_TO_ADDRS'                 , 'TO_ADDRS'        , 'TO_ADDRS'        , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.MyEmails'            , 4, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME', 'ASSIGNED_TO_NAME', '10%';
end -- if;
GO

-- 04/24/2011 Paul.  Convert DocumentRevisions to a dynamic layout. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.DocumentRevisions';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.DocumentRevisions' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.DocumentRevisions';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.DocumentRevisions'     , 'Documents', 'vwDOCUMENT_REVISIONS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.DocumentRevisions'     , 0, 'Documents.LBL_LIST_FILENAME'              , 'FILENAME'               , 'FILENAME'               , '25%', 'listViewTdLinkS1', 'ID', '~/Documents/Document.aspx?id={0}' , null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions'     , 1, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.DocumentRevisions'     , 2, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions'     , 3, '.LBL_LIST_CREATED'                        , 'CREATED_BY'             , 'CREATED_BY'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.DocumentRevisions'     , 4, 'Documents.LBL_REV_LIST_LOG'               , 'CHANGE_LOG'             , 'CHANGE_LOG'             , '25%';
end -- if;
GO

-- 10/18/2011 Paul.  Show prospect lists within Contacts, Leads and Prospects. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ProspectLists', 'Contacts', 'vwCONTACTS_PROSPECT_LISTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ProspectLists', 'Leads', 'vwLEADS_PROSPECT_LISTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO

-- 11/03/2017 Paul.  Add Leads/Opportunities relationship. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly             'Leads.Opportunities', 'Leads', 'vwLEADS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink   'Leads.Opportunities',  0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList   'Leads.Opportunities',  1, 'Opportunities.LBL_LIST_SALES_STAGE'       , 'SALES_STAGE'            , 'SALES_STAGE'            , '20%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'Leads.Opportunities',  2, 'Opportunities.LBL_LIST_AMOUNT'            , 'AMOUNT_USDOLLAR'        , 'AMOUNT_USDOLLAR'        , '20%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate   'Leads.Opportunities',  3, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Leads.Opportunities',  4, null, '1%', 'ID', 'Preview', 'preview_inline';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ProspectLists' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ProspectLists';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ProspectLists', 'Prospects', 'vwPROSPECTS_PROSPECT_LISTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ProspectLists'         , 0, 'ProspectLists.LBL_LIST_PROSPECT_LIST_NAME', 'NAME'                   ,'NAME'                   , '60%', 'listViewTdLinkS1', 'ID', '~/ProspectLists/view.aspx?id={0}', null, 'ProspectLists', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ProspectLists'         , 1, 'ProspectLists.LBL_LIST_ENTRIES'           , 'ENTRIES'                ,'ENTRIES'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ProspectLists'         , 2, 'ProspectLists.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'            ,'DESCRIPTION'            , '20%';
end -- if;
GO


-- 02/04/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Accounts';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Accounts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Accounts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Accounts', 'Documents', 'vwDOCUMENTS_ACCOUNTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Accounts'              , 0, 'Accounts.LBL_LIST_ACCOUNT_NAME'           , 'NAME'                   , 'NAME'                   , '30%', 'listViewTdLinkS1', 'ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts'              , 1, 'Accounts.LBL_LIST_CITY'                   , 'CITY'                   , 'CITY'                   , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts'              , 2, 'Accounts.LBL_LIST_PHONE'                  , 'PHONE'                  , 'PHONE'                  , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Accounts'              , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Accounts'            , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Accounts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Accounts'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Contacts';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Contacts' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Contacts';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Contacts', 'Documents', 'vwDOCUMENTS_CONTACTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contacts'              , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '20%', 'listViewTdLinkS1', 'ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts'              , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contacts'              , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '20%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts'              , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Documents.Contacts'        , 3, null, null, null, null, 0;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts'              , 4, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contacts'              , 5, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Contacts'            , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Contacts' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Contacts'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Leads';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Leads' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Leads';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Leads', 'Documents', 'vwDOCUMENTS_LEADS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Leads'                 , 0, 'Leads.LBL_LIST_NAME'                      , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Leads/view.aspx?id={0}', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads'                 , 1, 'Leads.LBL_LIST_REFERED_BY'                , 'REFERED_BY'             , 'REFERED_BY'             , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Leads'                 , 2, 'Leads.LBL_LIST_LEAD_SOURCE'               , 'LEAD_SOURCE'            , 'LEAD_SOURCE'            , '15%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads'                 , 3, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'   , 'LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION', '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads'                 , 4, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Leads'                 , 5, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Leads'               , 6, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Leads' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Leads'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
	-- 12/01/2012 Paul.  Fix list name for LEAD_SOURCE. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Leads' and DATA_FIELD = 'LEAD_SOURCE' and LIST_NAME = 'lead_status_dom' and DELETED = 0) begin -- then
		print 'Documents.Leads: Fix list name for LEAD_SOURCE.';
		update GRIDVIEWS_COLUMNS
		   set LIST_NAME         = 'lead_source_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where GRID_NAME         = 'Documents.Leads'
		   and DATA_FIELD        = 'LEAD_SOURCE'
		   and LIST_NAME         = 'lead_status_dom'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 06/07/2015 Paul.  Add Preview button. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Opportunities';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Opportunities' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Opportunities';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Opportunities', 'Documents', 'vwDOCUMENTS_OPPORTUNITIES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Opportunities'         , 0, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'  , 'NAME'                   , 'NAME'                   , '35%', 'listViewTdLinkS1', 'ID', '~/Opportunities/view.aspx?id={0}', null, 'Opportunities', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Opportunities'         , 1, 'Opportunities.LBL_LIST_ACCOUNT_NAME'      , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID'    , '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Opportunities'         , 2, 'Opportunities.LBL_LIST_DATE_CLOSED'       , 'DATE_CLOSED'            , 'DATE_CLOSED'            , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Opportunities'         , 3, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'      , 'SELECTED_REVISION'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Opportunities'         , 4, 'Documents.LBL_LIST_REVISION'              , 'REVISION'               , 'REVISION'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Opportunities'       , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Opportunities' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Opportunities'   , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Bugs' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Bugs';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Bugs', 'Documents', 'vwDOCUMENTS_BUGS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Bugs'                  , 0, 'Bugs.LBL_LIST_NUMBER'                     , 'BUG_NUMBER'             , 'BUG_NUMBER'             , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Bugs'                  , 1, 'Bugs.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '18%', 'listViewTdLinkS1', 'ID', '~/Bugs/view.aspx?id={0}', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs'                  , 2, 'Bugs.LBL_LIST_STATUS'                     , 'STATUS'                 , 'STATUS'                 , '18%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs'                  , 3, 'Bugs.LBL_LIST_TYPE'                       , 'TYPE'                   , 'TYPE'                   , '18%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Bugs'                  , 4, 'Bugs.LBL_LIST_PRIORITY'                   , 'PRIORITY'               , 'PRIORITY'               , '18%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Bugs'                , 5, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Bugs' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Bugs'            , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 06/07/2015 Paul.  Add Preview button. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Cases' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Cases';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Cases', 'Documents', 'vwDOCUMENTS_CASES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases'                 , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases'                 , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID'   , '~/Cases/view.aspx?id={0}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Cases'                 , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Cases'                 , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Cases'               , 4, null, '1%', 'ID', 'Preview', 'preview_inline';
end else begin
	-- 06/07/2015 Paul.  Add Preview button. 
	if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Cases' and URL_FORMAT = 'Preview' and DELETED = 0) begin -- then
		exec dbo.spGRIDVIEWS_COLUMNS_InsImageButton 'Documents.Cases'           , -1, null, '1%', 'ID', 'Preview', 'preview_inline';
	end -- if;
end -- if;
GO

-- 09/10/2012 Paul.  Add User Signatures. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.UserSignatures';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.UserSignatures' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.UserSignatures';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.UserSignatures', 'Users', 'vwUSERS_SIGNATURES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Users.UserSignatures'            , 0, 'UserSignatures.LBL_LIST_NAME'             , 'NAME'                   , 'NAME'                   , '70%', 'listViewTdLinkS1', 'ID'   , '~/Users/UserSignatures/edit.aspx?id={0}', null, 'UserSignatures', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.UserSignatures'            , 1, 'UserSignatures.LBL_LIST_PRIMARY_SIGNATURE', 'PRIMARY_SIGNATURE'      , 'PRIMARY_SIGNATURE'      , '20%';
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.ChatMessages';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.ChatMessages' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatChannels.ChatMessages';
	exec dbo.spGRIDVIEWS_InsertOnly           'ChatChannels.ChatMessages', 'ChatMessages', 'vwCHAT_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatChannels.ChatMessages',  0, 'ChatMessages.LBL_LIST_NAME'                , 'NAME'                   , 'NAME'                   , '55%', 'listViewTdLinkS1', 'ID'             , '~/ChatMessages/view.aspx?id={0}', null, 'ChatMessages', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatChannels.ChatMessages',  1, 'ChatMessages.LBL_LIST_PARENT_NAME'         , 'PARENT_NAME'            , 'PARENT_NAME'            , '15%', 'listViewTdLinkS1', 'PARENT_ID'      , '~/Parents/view.aspx?id={0}'     , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ChatChannels.ChatMessages',  2, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ChatChannels.ChatMessages',  3, '.LBL_LIST_CREATED_BY'                      , 'CREATED_BY'             , 'CREATED_BY'             , '10%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.Notes' 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.Notes' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatChannels.Notes';
	exec dbo.spGRIDVIEWS_InsertOnly           'ChatChannels.Notes', 'ChatChannels', 'vwCHAT_CHANNELS_ATTACHMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatChannels.Notes'       ,  0, 'Notes.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '60%', 'listViewTdLinkS1', 'ID'         , '~/Notes/Attachment.aspx?id={0}'   , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ChatChannels.Notes'       ,  1, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ChatChannels.Notes'       ,  2, '.LBL_LIST_CREATED_BY'                      , 'CREATED_BY'             , 'CREATED_BY'             , '20%';
end -- if;
GO

-- 04/13/2021 Paul.  The detail view relationship lists the control as Attachments, so we need to create a layout for the React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.Attachments' 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatChannels.Attachments' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatChannels.Attachments';
	exec dbo.spGRIDVIEWS_InsertOnly           'ChatChannels.Attachments', 'ChatChannels', 'vwCHAT_CHANNELS_ATTACHMENTS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatChannels.Attachments'       ,  0, 'Notes.LBL_LIST_SUBJECT'                    , 'NAME'                   , 'NAME'                   , '60%', 'listViewTdLinkS1', 'ID'         , '~/Notes/Attachment.aspx?id={0}'   , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ChatChannels.Attachments'       ,  1, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ChatChannels.Attachments'       ,  2, '.LBL_LIST_CREATED_BY'                      , 'CREATED_BY'             , 'CREATED_BY'             , '20%';
end -- if;
GO

-- 04/12/2016 Paul.  Add ZipCodes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Teams.ZipCodes';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Teams.ZipCodes' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Teams.ZipCodes';
	exec dbo.spGRIDVIEWS_InsertOnly           'Teams.ZipCodes', 'ZipCodes', 'vwTEAMS_ZIPCODES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Teams.ZipCodes'           , 0, 'ZipCodes.LBL_LIST_NAME'                     , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID', '~/Administration/ZipCodes/view.aspx?id={0}', null, 'ZipCodes', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.ZipCodes'           , 1, 'ZipCodes.LBL_LIST_CITY'                     , 'CITY'                   , 'CITY'                   , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.ZipCodes'           , 2, 'ZipCodes.LBL_LIST_STATE'                    , 'STATE'                  , 'STATE'                  , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.ZipCodes'           , 3, 'ZipCodes.LBL_LIST_COUNTRY'                  , 'COUNTRY'                , 'COUNTRY'                , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHover     'Teams.ZipCodes'           , 4, null, null, '1%', 'LONGITUDE LATITUDE', '<div style="background-color: white; padding: 10px;">
<a href="https://www.google.com/maps/?q={0},{1}" target="GoogleMaps">Google Maps</a>
</div>', 'info_inline';
end -- if;
GO

-- 09/12/2019 Paul.  Users.ACLRoles for the React Client. 
-- 11/10/2020 Paul.  Use new CheckBox type. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ACLRoles'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ACLRoles' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.ACLRoles';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.ACLRoles', 'ACLRoles', 'vwUSERS_ACL_ROLES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ACLRoles'           , 1, 'ACLRoles.LBL_LIST_NAME'                     , 'ROLE_NAME'              , 'ROLE_NAME'                     , '30%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ACLRoles'           , 2, 'ACLRoles.LBL_LIST_DESCRIPTION'              , 'DESCRIPTION'            , 'DESCRIPTION'                   , '50%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Users.ACLRoles'           , 3, 'ACLRoles.LBL_IS_PRIMARY_ROLE'               , 'IS_PRIMARY_ROLE'        , 'IS_PRIMARY_ROLE'               , '10%', 'CheckBox';
end else begin
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ACLRoles' and DATA_FIELD = 'IS_PRIMARY_ROLE' and COLUMN_TYPE = 'BoundColumn' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		  set COLUMN_TYPE       = 'TemplateColumn'
		    , DATA_FORMAT       = 'CheckBox'
		    , DATE_MODIFIED     = getdate()
		    , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME        = 'Users.ACLRoles'
		   and DATA_FIELD       = 'IS_PRIMARY_ROLE'
		   and COLUMN_TYPE      = 'BoundColumn'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 05/17/2020 Paul.  The React Client needs access to Import Maps. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Import.SavedView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Import.SavedView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Import.SavedView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Import.SavedView', 'Import', 'vwIMPORT_MAPS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Import.SavedView'         , 0, 'Import.LBL_LIST_NAME'                       , 'NAME'                   , 'NAME'                         , '95%', 'listViewTdLinkS1', 'ID'   , '~/Import/default.aspx?id={0}', null, null, null;
end -- if;
GO

-- 10/14/2020 Paul.  Teams.Users for the React Client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Teams.Users';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Teams.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Teams.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'Teams.Users', 'Users', 'vwTEAM_MEMBERSHIPS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Teams.Users'              , 0, 'Users.LBL_LIST_NAME'                        , 'FULL_NAME'              , 'FULL_NAME'              , '18%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.Users'              , 1, 'Users.LBL_LIST_USER_NAME'                   , 'USER_NAME'              , 'USER_NAME'              , '18%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Teams.Users'              , 2, 'Teams.LBL_LIST_MEMBERSHIP'                  , 'EXPLICIT_ASSIGN'        , 'EXPLICIT_ASSIGN'        , '18%', 'team_explicit_assign';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.Users'              , 3, 'Users.LBL_LIST_EMAIL'                       , 'EMAIL1'                 , 'EMAIL1'                 , '18%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Teams.Users'              , 4, '.LBL_LIST_PHONE'                            , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';
end -- if;
GO

-- 02/11/2021 Paul.  ACLRoles.Users for the React Client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.Users';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ACLRoles.Users' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ACLRoles.Users';
	exec dbo.spGRIDVIEWS_InsertOnly           'ACLRoles.Users', 'ACLRoles', 'vwACL_ROLES_USERS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ACLRoles.Users'           , 0, 'Users.LBL_LIST_NAME'                        , 'FULL_NAME'              , 'FULL_NAME'              , '22%', 'listViewTdLinkS1', 'USER_ID', '~/Users/view.aspx?id={0}', null, 'Users', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ACLRoles.Users'           , 1, 'Users.LBL_LIST_USER_NAME'                   , 'USER_NAME'              , 'USER_NAME'              , '22%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ACLRoles.Users'           , 2, 'Users.LBL_LIST_EMAIL'                       , 'EMAIL1'                 , 'EMAIL1'                 , '22%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ACLRoles.Users'           , 3, '.LBL_LIST_PHONE'                            , 'PHONE_WORK'             , 'PHONE_WORK'             , '22%';
end -- if;
GO

-- 03/27/2021 Paul.  InboundEmail.Mailbox for the React Client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'InboundEmail.Mailbox';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'InboundEmail.Mailbox' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS InboundEmail.Mailbox';
	exec dbo.spGRIDVIEWS_InsertOnly           'InboundEmail.Mailbox', 'InboundEmail', 'vwINBOUND_EMAILS';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 0, 'EmailClient.LBL_LIST_FROM'         , 'From'         , 'From'         , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 1, 'EmailClient.LBL_LIST_TO'           , 'To'           , 'To'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 2, 'EmailClient.LBL_LIST_CC'           , 'CC'           , 'CC'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 3, 'EmailClient.LBL_LIST_SUBJECT'      , 'Subject'      , 'Subject'      , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 4, 'EmailClient.LBL_LIST_DATE_RECEIVED', 'DeliveryDate' , 'DeliveryDate' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 5, 'EmailClient.LBL_LIST_SIZE'         , 'Size'         , 'Size'         , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 6, 'EmailClient.LBL_LIST_HEADERS'      , 'Headers'      , 'Headers'      , '25%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 7, 'EmailClient.LBL_LIST_PRIORITY'     , 'Priority'     , 'Priority'     , '10%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 8, 'EmailClient.LBL_LIST_BCC'          , 'Bcc'          , 'Bcc'          , '10%';
--	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'InboundEmail.Mailbox', 9, 'EmailClient.LBL_LIST_MESSAGEID'    , 'MessageID'    , 'MessageID'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'InboundEmail.Mailbox',  'Size', '{0:N0}';
	-- MODIFIED_USER_ID, GRID_NAME, COLUMN_INDEX, ITEMSTYLE_WIDTH, ITEMSTYLE_CSSCLASS, ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_VERTICAL_ALIGN, ITEMSTYLE_WRAP
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'InboundEmail.Mailbox'           , 4, null, null, null, null, 0;
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

call dbo.spGRIDVIEWS_COLUMNS_SubPanels()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_SubPanels')
/

-- #endif IBM_DB2 */

