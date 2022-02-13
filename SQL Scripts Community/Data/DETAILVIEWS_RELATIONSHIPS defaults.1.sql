

print 'DETAILVIEWS_RELATIONSHIPS defaults';
--delete from DETAILVIEWS_RELATIONSHIPS
--GO

set nocount on;
GO

-- 09/08/2007 Paul.  We need a title when we migrate to WebParts. 
-- 09/11/2007 Paul.  Make sure that the threads panels are added to the older relationships. 
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 

-- 10/20/2006 Paul.  Fix Project module name. 
-- 09/11/2007 Paul.  Add the Orders panel to the Accounts DetailView. 
-- 02/09/2008 Paul.  Add credit card management. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
-- 09/23/2008 Paul.  Move professional modules to a separate file. 
-- 11/23/2011 Paul.  DETAILVIEWS_RELATIONSHIPS defaults.1.sql was not previously being shared with the Community Edition, so CloudView was not being created. 
-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- 12/23/2015 Paul.  DETAILVIEWS_RELATIONSHIPS Cloud Services.1.sql is getting executed first, so simple not exists will block execution. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.DetailView' and CONTROL_NAME in ('Contacts', 'Opportunities', 'Leads') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Accounts.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwACCOUNTS_ACTIVITIES'   , 'ACCOUNT_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwACCOUNTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwACCOUNTS_ACTIVITIES_OPEN'   , 'ACCOUNT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwACCOUNTS_ACTIVITIES_HISTORY', 'ACCOUNT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwACCOUNTS_CONTACTS'          , 'ACCOUNT_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Opportunities'    , 'Opportunities'      ,  4, 'Opportunities.LBL_MODULE_NAME'    , 'vwACCOUNTS_OPPORTUNITIES'     , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Leads'            , 'Leads'              ,  5, 'Leads.LBL_MODULE_NAME'            , 'vwACCOUNTS_LEADS'             , 'ACCOUNT_ID', 'LEAD_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Cases'            , 'Cases'              ,  6, 'Cases.LBL_MODULE_NAME'            , 'vwACCOUNTS_CASES'             , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Accounts'         , 'MemberOrganizations',  7, 'Accounts.LBL_MODULE_NAME'         , 'vwACCOUNTS_MEMBERS'           , 'ACCOUNT_ID', 'ACCOUNT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Bugs'             , 'Bugs'               ,  8, 'Bugs.LBL_MODULE_NAME'             , 'vwACCOUNTS_BUGS'              , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Project'          , 'Projects'           ,  9, 'Project.LBL_MODULE_NAME'          , 'vwACCOUNTS_PROJECTS'          , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Documents'        , 'Documents'          , 10, 'Documents.LBL_MODULE_NAME'        , 'vwACCOUNTS_DOCUMENTS'         , 'ACCOUNT_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'ProspectLists'    , 'ProspectLists'      , 11, 'ProspectLists.LBL_MODULE_NAME'    , 'vwACCOUNTS_PROSPECT_LISTS'    , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
end else begin
	-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwACCOUNTS_DOCUMENTS'    , 'ACCOUNT_ID', 'DOCUMENT_NAME', 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Accounts.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwACCOUNTS_ACTIVITIES_OPEN'   , 'ACCOUNT_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwACCOUNTS_ACTIVITIES_HISTORY', 'ACCOUNT_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Accounts.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 11/27/2012 Paul.  Fix table name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and TABLE_NAME = 'vwACCOUNTS_ACTIVITIES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME           = 'vwACCOUNTS_ACTIVITIES_OPEN'
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Accounts.DetailView'
		   and CONTROL_NAME         = 'ActivitiesOpen'
		   and DELETED              = 0;
	end -- if;

	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.DetailView' and CONTROL_NAME = 'ActivitiesHistory' and TABLE_NAME = 'vwACCOUNTS_ACTIVITIES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME           = 'vwACCOUNTS_ACTIVITIES_HISTORY'
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Accounts.DetailView'
		   and CONTROL_NAME         = 'ActivitiesHistory'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Accounts.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwACCOUNTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
	-- 10/27/2017 Paul.  Add Accounts as email source. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.DetailView'      , 'ProspectLists'    , 'ProspectLists'      , null, 'ProspectLists.LBL_MODULE_NAME'    , 'vwACCOUNTS_PROSPECT_LISTS'    , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Roles.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Roles.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Roles.DetailView'         , 'Users'            , 'Users'              ,  0, 'Users.LBL_MODULE_NAME'            , null, null, null, null;
end -- if;
GO

-- 02/11/2021 Paul.  We have hard-coded the table info in the ACLRoles.Users layout, but correct here anyway. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ACLRoles.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS ACLRoles.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ACLRoles.DetailView'      , 'Users'            , 'Users'              ,  0, 'Users.LBL_MODULE_NAME'            , 'vwACL_ROLES_USERS', 'ROLE_ID', 'FULL_NAME', 'asc';
end else begin
	-- 02/11/2021 Paul.  We have hard-coded the table info in the ACLRoles.Users layout, but correct here anyway. 
	-- 03/02/2021 Paul.  TABLE_NAME is required for the React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ACLRoles.DetailView' and TABLE_NAME is null and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME         = 'vwACL_ROLES_USERS'
		     , PRIMARY_FIELD      = 'ROLE_ID'
		     , SORT_FIELD         = 'FULL_NAME'
		     , SORT_DIRECTION     = 'asc'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ACLRoles.DetailView'
		   and TABLE_NAME         is null
		   and DELETED            = 0;
	end -- if;
end -- if;
GO


-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Bugs.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwBUGS_ACTIVITIES', 'BUG_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwBUGS_STREAM'            , 'ID'    , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwBUGS_ACTIVITIES_OPEN'   , 'BUG_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwBUGS_ACTIVITIES_HISTORY', 'BUG_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwBUGS_CONTACTS'          , 'BUG_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Accounts'         , 'Accounts'           ,  4, 'Accounts.LBL_MODULE_NAME'         , 'vwBUGS_ACCOUNTS'          , 'BUG_ID', 'ACCOUNT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Cases'            , 'Cases'              ,  5, 'Cases.LBL_MODULE_NAME'            , 'vwBUGS_CASES'             , 'BUG_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Documents'        , 'Documents'          ,  6, 'Documents.LBL_MODULE_NAME'        , 'vwBUGS_DOCUMENTS'         , 'BUG_ID', 'DOCUMENT_NAME', 'asc';
end else begin
	-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwBUGS_DOCUMENTS' , 'BUG_ID', 'DOCUMENT_NAME', 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Bugs.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwBUGS_ACTIVITIES_OPEN'   , 'BUG_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'          , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwBUGS_ACTIVITIES_HISTORY', 'BUG_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Bugs.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 11/27/2012 Paul.  Fix table name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and TABLE_NAME = 'vwBUGS_ACTIVITIES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME           = 'vwBUGS_ACTIVITIES_OPEN'
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Bugs.DetailView'
		   and CONTROL_NAME         = 'ActivitiesOpen'
		   and DELETED              = 0;
	end -- if;

	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView' and CONTROL_NAME = 'ActivitiesHistory' and TABLE_NAME = 'vwBUGS_ACTIVITIES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME           = 'vwBUGS_ACTIVITIES_HISTORY'
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Bugs.DetailView'
		   and CONTROL_NAME         = 'ActivitiesHistory'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Bugs.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwBUGS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO


-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Calls.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Calls.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Contacts'         , 'Contacts'           ,  0, 'Contacts.LBL_MODULE_NAME'         , 'vwCALLS_CONTACTS', 'CALL_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Users'            , 'Users'              ,  1, 'Users.LBL_MODULE_NAME'            , 'vwCALLS_USERS'   , 'CALL_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Notes'            , 'Notes'              ,  2, 'Notes.LBL_MODULE_NAME'            , 'vwCALLS_NOTES'   , 'CALL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwCALLS_LEADS'   , 'CALL_ID', 'LEAD_NAME'   , 'asc';
end else begin
	-- 07/13/2006 Paul.  Add Calls.Notes to an existing installation. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Notes'            , 'Notes'              ,  2, 'Notes.LBL_MODULE_NAME'            , 'vwCALLS_NOTES'   , 'CALL_ID', 'DATE_ENTERED', 'desc';
	-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.DetailView'         , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwCALLS_LEADS'   , 'CALL_ID', 'LEAD_NAME'   , 'asc';
end -- if;
GO

-- 07/08/2007 Paul.  Add CampaignTrackers and EmailMarketing modules. 
-- 08/27/2012 Paul.  Add CallMarketing modules. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Campaigns.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Campaigns.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'                , 'vwCAMPAIGNS_STREAM'         , 'ID'    , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'ProspectLists'    , 'ProspectLists'      ,  1, 'ProspectLists.LBL_MODULE_NAME'       , 'vwCAMPAIGNS_PROSPECT_LISTS' , 'CAMPAIGN_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'CampaignTrackers' , 'CampaignTrackers'   ,  2, 'CampaignTrackers.LBL_MODULE_NAME'    , 'vwCAMPAIGNS_CAMPAIGN_TRKRS' , 'CAMPAIGN_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'EmailMarketing'   , 'EmailMarketing'     ,  3, 'EmailMarketing.LBL_MODULE_NAME'      , 'vwCAMPAIGNS_EMAIL_MARKETING', 'CAMPAIGN_ID', 'DATE_START'  , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'CallMarketing'    , 'CallMarketing'      ,  4, 'CallMarketing.LBL_MODULE_NAME'       , 'vwCAMPAIGNS_CALL_MARKETING' , 'CAMPAIGN_ID', 'DATE_START'  , 'desc';
end else begin
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'CampaignTrackers' , 'CampaignTrackers'   ,  null, 'CampaignTrackers.LBL_MODULE_NAME' , 'vwCAMPAIGNS_CAMPAIGN_TRKRS' , 'CAMPAIGN_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'EmailMarketing'   , 'EmailMarketing'     ,  null, 'EmailMarketing.LBL_MODULE_NAME'   , 'vwCAMPAIGNS_EMAIL_MARKETING', 'CAMPAIGN_ID', 'DATE_START'  , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'     , 'CallMarketing'    , 'CallMarketing'      ,  null, 'CallMarketing.LBL_MODULE_NAME'    , 'vwCAMPAIGNS_CALL_MARKETING' , 'CAMPAIGN_ID', 'DATE_START'  , 'desc';

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Campaigns.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Campaigns.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwCAMPAIGNS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'EmailMarketing.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS EmailMarketing.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'EmailMarketing.DetailView', 'ProspectLists'    , 'ProspectLists'      ,  0, 'ProspectLists.LBL_MODULE_NAME'       , 'vwEMAIL_MARKETING_PROSPECT_LST', 'EMAIL_MARKETING_ID', 'DATE_ENTERED', 'desc';
end else begin
	-- 04/13/2021 Paul.  Fix primary field for the React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'EmailMarketing.DetailView' and CONTROL_NAME = 'ProspectLists' and PRIMARY_FIELD = 'EMAILMARKETING_ID' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set PRIMARY_FIELD      = 'EMAIL_MARKETING_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'EmailMarketing.DetailView'
		   and PRIMARY_FIELD      = 'EMAILMARKETING_ID'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 08/27/2012 Paul.  Add CallMarketing modules. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'CallMarketing.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS CallMarketing.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'CallMarketing.DetailView' , 'ProspectLists'    , 'ProspectLists'      ,  0, 'ProspectLists.LBL_MODULE_NAME'       , 'vwCALL_MARKETING_PROSPECT_LST', 'CALL_MARKETING_ID', 'DATE_ENTERED', 'desc';
end else begin
	-- 04/13/2021 Paul.  Fix primary field for the React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'CallMarketing.DetailView' and CONTROL_NAME = 'ProspectLists' and PRIMARY_FIELD = 'CALLMARKETING_ID' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set PRIMARY_FIELD      = 'CALL_MARKETING_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'CallMarketing.DetailView'
		   and PRIMARY_FIELD      = 'CALLMARKETING_ID'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 04/10/2013 Paul.  Add Projects relationship to Cases. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Cases.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwCASES_ACTIVITIES'        , 'CASE_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwCASES_STREAM'            , 'ID'     , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwCASES_ACTIVITIES_OPEN'   , 'CASE_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwCASES_ACTIVITIES_HISTORY', 'CASE_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwCASES_CONTACTS'          , 'CASE_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Bugs'             , 'Bugs'               ,  4, 'Bugs.LBL_MODULE_NAME'             , 'vwCASES_BUGS'              , 'CASE_ID', 'BUG_NAME'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Threads'          , 'Threads'            ,  5, 'Threads.LBL_MODULE_NAME'          , 'vwCASES_THREADS'           , 'CASE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Documents'        , 'Documents'          ,  6, 'Documents.LBL_MODULE_NAME'        , 'vwCASES_DOCUMENTS'         , 'CASE_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Project'          , 'Projects'           ,  7, 'Project.LBL_MODULE_NAME'          , 'vwCASES_PROJECTS'          , 'CASE_ID', 'ESTIMATED_START_DATE', 'asc';
end else begin
	-- 07/15/2006 Paul.  Add Cases.Threads to an existing installation. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Threads'          , 'Threads'            ,  null, 'Threads.LBL_MODULE_NAME'       , 'vwCASES_THREADS'           , 'CASE_ID', 'DATE_ENTERED' , 'desc';
	-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwCASES_DOCUMENTS'         , 'CASE_ID', 'DOCUMENT_NAME', 'asc';
	-- 04/10/2013 Paul.  Add Projects relationship to Cases. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Project'          , 'Projects'           ,  null, 'Project.LBL_MODULE_NAME'          , 'vwCASES_PROJECTS'          , 'CASE_ID', 'ESTIMATED_START_DATE', 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Cases.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwCASES_ACTIVITIES_OPEN'   , 'CASE_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'         , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwCASES_ACTIVITIES_HISTORY', 'CASE_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Cases.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Cases.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwCASES_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO


-- 06/09/2006 Paul.  Add direct reports. 
-- 10/20/2006 Paul.  Fix Project module name. 
-- 10/12/2011 Paul.  Add ProspectLists to Contacts, Leads, Prospects.
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- 12/23/2015 Paul.  DETAILVIEWS_RELATIONSHIPS Cloud Services.1.sql is getting executed first, so simple not exists will block execution. 
-- 03/11/2016 Paul.  DATE_ENTERED is not avaiable on the activities view.  Fix old systems. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' and CONTROL_NAME in ('Leads', 'Opportunities', 'Cases') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Contacts.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwCONTACTS_ACTIVITIES'        , 'CONTACT_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwCONTACTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwCONTACTS_ACTIVITIES_OPEN'   , 'CONTACT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwCONTACTS_ACTIVITIES_HISTORY', 'CONTACT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwCONTACTS_LEADS'             , 'CONTACT_ID', 'LEAD_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Opportunities'    , 'Opportunities'      ,  4, 'Opportunities.LBL_MODULE_NAME'    , 'vwCONTACTS_OPPORTUNITIES'     , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Cases'            , 'Cases'              ,  5, 'Cases.LBL_MODULE_NAME'            , 'vwCONTACTS_CASES'             , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Bugs'             , 'Bugs'               ,  6, 'Bugs.LBL_MODULE_NAME'             , 'vwCONTACTS_BUGS'              , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Contacts'         , 'DirectReports'      ,  7, 'Contacts.LBL_MODULE_NAME'         , 'vwCONTACTS_DIRECT_REPORTS'    , 'CONTACT_ID', 'DIRECT_REPORT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Project'          , 'Projects'           ,  8, 'Project.LBL_MODULE_NAME'          , 'vwCONTACTS_PROJECTS'          , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'ProspectLists'    , 'ProspectLists'      ,  9, 'ProspectLists.LBL_MODULE_NAME'    , 'vwCONTACTS_PROSPECT_LISTS'    , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Documents'        , 'Documents'          , 10, 'Documents.LBL_MODULE_NAME'        , 'vwCONTACTS_DOCUMENTS'         , 'CONTACT_ID', 'DOCUMENT_NAME', 'asc';
	-- exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'   , 'CampaignLog'      , 'CampaignLog'        , 11, 'CampaignLog.LBL_MODULE_NAME'      , 'vwCONTACTS_CAMPAIGN_LOG'      , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
end else begin
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'ProspectLists'    , 'ProspectLists'      ,  null, 'ProspectLists.LBL_MODULE_NAME' , 'vwCONTACTS_PROSPECT_LISTS'    , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwCONTACTS_DOCUMENTS'         , 'CONTACT_ID', 'DOCUMENT_NAME', 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Contacts.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwCONTACTS_ACTIVITIES_OPEN'   , 'CONTACT_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwCONTACTS_ACTIVITIES_HISTORY', 'CONTACT_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Contacts.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Contacts.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwCONTACTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
	-- 03/11/2016 Paul.  DATE_ENTERED is not avaiable on the activities view.  Fix old systems. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and SORT_FIELD = 'DATE_ENTERED' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set SORT_FIELD         = 'DATE_DUE' 
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Contacts.DetailView'
		   and CONTROL_NAME       = 'ActivitiesOpen'
		   and SORT_FIELD         = 'DATE_ENTERED' 
		   and DELETED            = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.DetailView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD = 'DATE_ENTERED' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set SORT_FIELD         = 'DATE_MODIFIED' 
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Contacts.DetailView'
		   and CONTROL_NAME       = 'ActivitiesHistory'
		   and SORT_FIELD         = 'DATE_ENTERED' 
		   and DELETED            = 0;
	end -- if;
end -- if;
GO


-- 10/21/2006 Paul.  There is no DocumentRevisions module.  
-- 06/19/2007 Paul.  Fix Documents module name. 
-- 02/04/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
-- 09/09/2012 Paul.  Add Documents relationship to Bugs, Cases and Quotes. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- 11/23/2021 Paul.  Correct DocumentRevisions title for React client. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Documents.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'         , 'vwDOCUMENTS_STREAM'       , 'ID'         , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Documents'        , 'DocumentRevisions'  ,  1, 'DocumentRevisions.LBL_MODULE_NAME', 'vwDOCUMENT_REVISIONS'     , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Accounts'         , 'Accounts'           ,  2, 'Accounts.LBL_MODULE_NAME'     , 'vwDOCUMENTS_ACCOUNTS'     , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'     , 'vwDOCUMENTS_CONTACTS'     , 'DOCUMENT_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Leads'            , 'Leads'              ,  4, 'Leads.LBL_MODULE_NAME'        , 'vwDOCUMENTS_LEADS'        , 'DOCUMENT_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Opportunities'    , 'Opportunities'      ,  5, 'Opportunities.LBL_MODULE_NAME', 'vwDOCUMENTS_OPPORTUNITIES', 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Bugs'             , 'Bugs'               ,  6, 'Bugs.LBL_MODULE_NAME'         , 'vwDOCUMENTS_BUGS'         , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Cases'            , 'Cases'              ,  7, 'Cases.LBL_MODULE_NAME'        , 'vwDOCUMENTS_CASES'        , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
end else begin
	-- 10/20/2006 Paul.  Fix Documents module name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where MODULE_NAME = 'DocumentRevisions' and DELETED = 0) begin -- then
		print 'Fix Documents module name in DetailView relationships.';
		update DETAILVIEWS_RELATIONSHIPS
		   set MODULE_NAME      = 'Documents'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'DocumentRevisions'
		   and DELETED          = 0;
	end -- if;
	
	-- 06/19/2007 Paul.  Fix Documents module name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where MODULE_NAME = 'Document' and DELETED = 0) begin -- then
		print 'Fix Documents module name in DetailView relationships.';
		update DETAILVIEWS_RELATIONSHIPS
		   set MODULE_NAME      = 'Documents'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'Document'
		   and DELETED          = 0;
	end -- if;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Accounts'         , 'Accounts'           ,  null, 'Accounts.LBL_MODULE_NAME'     , 'vwDOCUMENTS_ACCOUNTS'     , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Contacts'         , 'Contacts'           ,  null, 'Contacts.LBL_MODULE_NAME'     , 'vwDOCUMENTS_CONTACTS'     , 'DOCUMENT_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Leads'            , 'Leads'              ,  null, 'Leads.LBL_MODULE_NAME'        , 'vwDOCUMENTS_LEADS'        , 'DOCUMENT_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Opportunities'    , 'Opportunities'      ,  null, 'Opportunities.LBL_MODULE_NAME', 'vwDOCUMENTS_OPPORTUNITIES', 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Bugs'             , 'Bugs'               ,  null, 'Bugs.LBL_MODULE_NAME'         , 'vwDOCUMENTS_BUGS'         , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'     , 'Cases'            , 'Cases'              ,  null, 'Cases.LBL_MODULE_NAME'        , 'vwDOCUMENTS_CASES'        , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	-- 11/30/2012 Paul.  Fix table name. 
	-- 03/01/2013 Paul.  Fix table name again.  It should be vwDOCUMENT_REVISIONS. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.DetailView' and TABLE_NAME = 'vwDOCUMENTS_DOCUMENTREVISIONS' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME       = 'vwDOCUMENT_REVISIONS'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Documents.DetailView'
		   and TABLE_NAME       = 'vwDOCUMENTS_DOCUMENTREVISIONS'
		   and DELETED          = 0;
	end -- if;
	-- 11/23/2021 Paul.  Correct DocumentRevisions title for React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.DetailView' and CONTROL_NAME = 'DocumentRevisions' and TITLE = 'Documents.LBL_MODULE_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TITLE            = 'DocumentRevisions.LBL_MODULE_NAME'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Documents.DetailView'
		   and CONTROL_NAME     = 'DocumentRevisions'
		   and TITLE            = 'Documents.LBL_MODULE_NAME'
		   and DELETED          = 0;
	end -- if;
	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Documents.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwDOCUMENTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO


if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Emails.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Accounts'         , 'Accounts'           ,  0, 'Accounts.LBL_MODULE_NAME'         , 'vwEMAILS_ACCOUNTS'       , 'EMAIL_ID', 'ACCOUNT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Contacts'         , 'Contacts'           ,  1, 'Contacts.LBL_MODULE_NAME'         , 'vwEMAILS_CONTACTS'       , 'EMAIL_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Opportunities'    , 'Opportunities'      ,  2, 'Opportunities.LBL_MODULE_NAME'    , 'vwEMAILS_OPPORTUNITIES'  , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwEMAILS_LEADS'          , 'EMAIL_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Cases'            , 'Cases'              ,  4, 'Cases.LBL_MODULE_NAME'            , 'vwEMAILS_CASES'          , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Users'            , 'Users'              ,  5, 'Users.LBL_MODULE_NAME'            , 'vwEMAILS_USERS'          , 'EMAIL_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Bugs'             , 'Bugs'               ,  6, 'Bugs.LBL_MODULE_NAME'             , 'vwEMAILS_BUGS'           , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Project'          , 'Projects'           ,  7, 'Project.LBL_MODULE_NAME'          , 'vwEMAILS_PROJECTS'       , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'ProjectTask'      , 'ProjectTasks'       ,  8, 'ProjectTask.LBL_MODULE_NAME'      , 'vwEMAILS_PROJECT_TASKS'  , 'EMAIL_ID', 'DATE_DUE'    , 'desc';
end else begin
	-- 04/21/2006 Paul.  SugarCRM 4.2 has several more email relationships. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Accounts'         , 'Accounts'           , null, 'Accounts.LBL_MODULE_NAME'       , 'vwEMAILS_ACCOUNTS'       , 'EMAIL_ID', 'ACCOUNT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Contacts'         , 'Contacts'           , null, 'Contacts.LBL_MODULE_NAME'       , 'vwEMAILS_CONTACTS'       , 'EMAIL_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Opportunities'    , 'Opportunities'      , null, 'Opportunities.LBL_MODULE_NAME'  , 'vwEMAILS_OPPORTUNITIES'  , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Leads'            , 'Leads'              , null, 'Leads.LBL_MODULE_NAME'          , 'vwEMAILS_LEADS'          , 'EMAIL_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Cases'            , 'Cases'              , null, 'Cases.LBL_MODULE_NAME'          , 'vwEMAILS_CASES'          , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Users'            , 'Users'              , null, 'Users.LBL_MODULE_NAME'          , 'vwEMAILS_USERS'          , 'EMAIL_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Bugs'             , 'Bugs'               , null, 'Bugs.LBL_MODULE_NAME'           , 'vwEMAILS_BUGS'           , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'Project'          , 'Projects'           , null, 'Project.LBL_MODULE_NAME'        , 'vwEMAILS_PROJECTS'       , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.DetailView'        , 'ProjectTask'      , 'ProjectTasks'       , null, 'ProjectTask.LBL_MODULE_NAME'    , 'vwEMAILS_PROJECT_TASKS'  , 'EMAIL_ID', 'DATE_DUE'    , 'desc';
	-- 11/30/2012 Paul.  Fix table name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.DetailView' and TABLE_NAME = 'vwEMAILS_PROJECTTASKS' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME       = 'vwEMAILS_PROJECT_TASKS'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Emails.DetailView'
		   and TABLE_NAME       = 'vwEMAILS_PROJECTTASKS'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO


-- 03/24/2006 Paul. MySQL does not like empty IF clauses. 
-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'EmailTemplates.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS EmailTemplates.DetailView';
-- end -- if;
-- #endif SQL_Server */
--GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Employees.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS Employees.DetailView';
-- end -- if;
-- #endif SQL_Server */
--GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'iFrames.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS iFrames.DetailView';
-- end -- if;
-- #endif SQL_Server */
--GO

-- 10/12/2011 Paul.  Add ProspectLists to Contacts, Leads, Prospects.
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- 12/23/2015 Paul.  DETAILVIEWS_RELATIONSHIPS Cloud Services.1.sql is getting executed first, so simple not exists will block execution. 
-- 11/03/2017 Paul.  Add Leads/Opportunities relationship. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.DetailView'
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.DetailView' and CONTROL_NAME in ('ActivityStream', 'ActivitiesOpen', 'ActivitiesHistory') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Leads.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwLEADS_ACTIVITIES'        , 'LEAD_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwLEADS_STREAM'            , 'ID'     , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwLEADS_ACTIVITIES_OPEN'   , 'LEAD_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwLEADS_ACTIVITIES_HISTORY', 'LEAD_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Threads'          , 'Threads'            ,  3, 'Threads.LBL_MODULE_NAME'          , 'vwLEADS_THREADS'           , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'ProspectLists'    , 'ProspectLists'      ,  4, 'ProspectLists.LBL_MODULE_NAME'    , 'vwLEADS_PROSPECT_LISTS'    , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Documents'        , 'Documents'          ,  5, 'Documents.LBL_MODULE_NAME'        , 'vwLEADS_DOCUMENTS'         , 'LEAD_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Contacts'         , 'Contacts'           ,  6, 'Contacts.LBL_MODULE_NAME'         , 'vwLEADS_CONTACTS'          , 'LEAD_ID', 'CONTACT_NAME' , 'asc';
	-- exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'    , 'CampaignLog'      , 'CampaignLog'        ,  7, 'CampaignLog.LBL_MODULE_NAME'      , 'vwLEADS_CAMPAIGN_LOG'      , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Opportunities'    , 'Opportunities'      ,  null, 'Opportunities.LBL_MODULE_NAME' , 'vwLEADS_OPPORTUNITIES'     , 'LEAD_ID', 'DATE_CLOSED' , 'desc';
end else begin
	-- 07/15/2006 Paul.  Add Leads.Threads to an existing installation. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Threads'          , 'Threads'            ,  null, 'Threads.LBL_MODULE_NAME'       , 'vwLEADS_THREADS'           , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'ProspectLists'    , 'ProspectLists'      ,  null, 'ProspectLists.LBL_MODULE_NAME' , 'vwLEADS_PROSPECT_LISTS'    , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwLEADS_DOCUMENTS'         , 'LEAD_ID', 'DOCUMENT_NAME', 'asc';
	-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Contacts'         , 'Contacts'           ,  null, 'Contacts.LBL_MODULE_NAME'      , 'vwLEADS_CONTACTS'          , 'LEAD_ID', 'CONTACT_NAME' , 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Leads.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwLEADS_ACTIVITIES_OPEN'   , 'LEAD_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwLEADS_ACTIVITIES_HISTORY', 'LEAD_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Leads.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Leads.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwLEADS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
	-- 11/03/2017 Paul.  Add Leads/Opportunities relationship. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.DetailView'       , 'Opportunities'    , 'Opportunities'      ,  null, 'Opportunities.LBL_MODULE_NAME' , 'vwLEADS_OPPORTUNITIES'     , 'LEAD_ID', 'DATE_CLOSED' , 'desc';
end -- if;
GO



-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Meetings.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Meetings.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.DetailView'      , 'Contacts'         , 'Contacts'           ,  0, 'Contacts.LBL_MODULE_NAME'         , 'vwMEETINGS_CONTACTS', 'MEETING_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.DetailView'      , 'Users'            , 'Users'              ,  1, 'Users.LBL_MODULE_NAME'            , 'vwMEETINGS_USERS'   , 'MEETING_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.DetailView'      , 'Leads'            , 'Leads'              ,  2, 'Leads.LBL_MODULE_NAME'            , 'vwMEETINGS_LEADS'   , 'MEETING_ID', 'LEAD_NAME'   , 'asc';
end else begin
	-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.DetailView'      , 'Leads'            , 'Leads'              ,  null, 'Leads.LBL_MODULE_NAME'         , 'vwMEETINGS_LEADS'   , 'MEETING_ID', 'LEAD_NAME'   , 'asc';
end -- if;
GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Notes.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS Notes.DetailView';
-- end -- if;
-- #endif SQL_Server */
--GO

-- 10/20/2006 Paul.  Fix Project module name. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 08/08/2015 Paul.  Opportunities Leads panel does not make sense as an Opportunity can only have one Lead. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Opportunities.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwOPPORTUNITIES_ACTIVITIES'        , 'OPPORTUNITY_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwOPPORTUNITIES_STREAM'            , 'ID'            , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwOPPORTUNITIES_ACTIVITIES_OPEN'   , 'OPPORTUNITY_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwOPPORTUNITIES_ACTIVITIES_HISTORY', 'OPPORTUNITY_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwOPPORTUNITIES_CONTACTS'          , 'OPPORTUNITY_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Project'          , 'Projects'           ,  4, 'Project.LBL_MODULE_NAME'          , 'vwOPPORTUNITIES_PROJECTS'          , 'OPPORTUNITY_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Documents'        , 'Documents'          ,  5, 'Documents.LBL_MODULE_NAME'        , 'vwOPPORTUNITIES_DOCUMENTS'         , 'OPPORTUNITY_ID', 'DATE_ENTERED' , 'desc';
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Leads'            , 'Leads'              ,  6, 'Leads.LBL_MODULE_NAME'            , 'vwOPPORTUNITIES_LEADS'             , 'OPPORTUNITY_ID', 'LEAD_NAME'    , 'asc';
end else begin
	-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities.
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Documents'        , 'Documents'          ,  null, 'Documents.LBL_MODULE_NAME'     , 'vwOPPORTUNITIES_DOCUMENTS'         , 'OPPORTUNITY_ID', 'DOCUMENT_NAME', 'asc';

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Opportunities.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwOPPORTUNITIES_ACTIVITIES_OPEN'   , 'OPPORTUNITY_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView' , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwOPPORTUNITIES_ACTIVITIES_HISTORY', 'OPPORTUNITY_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Opportunities.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;
	-- 08/08/2015 Paul.  Opportunities Leads panel does not make sense as an Opportunity can only have one Lead. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.DetailView' and CONTROL_NAME = 'Leads' and RELATIONSHIP_ENABLED = 1 and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Opportunities.DetailView'
		   and CONTROL_NAME         = 'Leads'
		   and RELATIONSHIP_ENABLED = 1
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Opportunities.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwOPPORTUNITIES_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO


-- 10/20/2006 Paul.  Fix ProjectTask module name. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Project.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwPROJECTS_ACTIVITIES'        , 'PROJECT_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwPROJECTS_ACTIVITIES_OPEN'   , 'PROJECT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'           , 'vwPROJECTS_ACTIVITIES_HISTORY', 'PROJECT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'ProjectTask'      , 'ProjectTasks'       ,  2, 'ProjectTask.LBL_MODULE_NAME'      , 'vwPROJECTS_PROJECT_TASKS'     , 'PROJECT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwPROJECTS_CONTACTS'          , 'PROJECT_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Accounts'         , 'Accounts'           ,  4, 'Accounts.LBL_MODULE_NAME'         , 'vwPROJECTS_ACCOUNTS'          , 'PROJECT_ID', 'ACCOUNT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Opportunities'    , 'Opportunities'      ,  5, 'Opportunities.LBL_MODULE_NAME'    , 'vwPROJECTS_OPPORTUNITIES'     , 'PROJECT_ID', 'DATE_ENTERED' , 'desc';
end else begin
	-- 11/30/2012 Paul.  Fix table name. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.DetailView' and TABLE_NAME = 'vwPROJECT_PROJECTTASKS' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME       = 'vwPROJECTS_PROJECT_TASKS'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Project.DetailView'
		   and TABLE_NAME       = 'vwPROJECT_PROJECTTASKS'
		   and DELETED          = 0;
	end -- if;

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Project.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwPROJECTS_ACTIVITIES_OPEN'   , 'PROJECT_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwPROJECTS_ACTIVITIES_HISTORY', 'PROJECT_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Project.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;
end -- if;
GO

-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 04/14/2021 Paul.  Views should be for Project Tasks not Projects. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS ProjectTask.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.DetailView'   , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwPROJECT_TASKS_ACTIVITIES'        , 'PROJECT_TASK_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.DetailView'   , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwPROJECT_TASKS_ACTIVITIES_OPEN'   , 'PROJECT_TASK_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.DetailView'   , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'           , 'vwPROJECT_TASKS_ACTIVITIES_HISTORY', 'PROJECT_TASK_ID', 'DATE_MODIFIED', 'desc';
end else begin
	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProjectTask.DetailView'
		   and DELETED            = 0;
		-- 04/14/2021 Paul.  Views should be for Project Tasks not Projects. 
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.DetailView'   , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwPROJECT_TASKS_ACTIVITIES_OPEN'   , 'PROJECT_TASK_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.DetailView'   , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwPROJECT_TASKS_ACTIVITIES_HISTORY', 'PROJECT_TASK_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'ProjectTask.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;
	-- 04/14/2021 Paul.  Views should be for Project Tasks not Projects. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and TABLE_NAME = 'vwPROJECTS_ACTIVITIES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME         = 'vwPROJECT_TASKS_ACTIVITIES'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProjectTask.DetailView'
		   and TABLE_NAME         = 'vwPROJECTS_ACTIVITIES'
		   and DELETED            = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and TABLE_NAME = 'vwPROJECTS_ACTIVITIES_OPEN' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME         = 'vwPROJECT_TASKS_ACTIVITIES_OPEN'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProjectTask.DetailView'
		   and TABLE_NAME         = 'vwPROJECTS_ACTIVITIES_OPEN'
		   and DELETED            = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and TABLE_NAME = 'vwPROJECTS_ACTIVITIES_HISTORY' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME         = 'vwPROJECT_TASKS_ACTIVITIES_HISTORY'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProjectTask.DetailView'
		   and TABLE_NAME         = 'vwPROJECTS_ACTIVITIES_HISTORY'
		   and DELETED            = 0;
	end -- if;
	-- 04/14/2021 Paul.  Some old systems may have bad value for PRIMARY_FIELD. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.DetailView' and PRIMARY_FIELD = 'PROJECTTASK_ID' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set PRIMARY_FIELD      = 'PROJECT_TASK_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProjectTask.DetailView'
		   and PRIMARY_FIELD      = 'PROJECTTASK_ID'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- 10/12/2011 Paul.  Add ProspectLists to Contacts, Leads, Prospects.
-- 01/29/2008 Paul.  Display relationship between prospects and emails. 
-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Prospects.DetailView';
	--exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'Activities'       , 'Activities'         ,  0, 'Activities.LBL_MODULE_NAME'       , 'vwPROSPECTS_ACTIVITIES'        , 'PROSPECT_ID', 'DATE_MODIFIED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwPROSPECTS_STREAM'            , 'ID'         , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  1, 'Activities.LBL_OPEN_ACTIVITIES'   , 'vwPROSPECTS_ACTIVITIES_OPEN'   , 'PROSPECT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwPROSPECTS_ACTIVITIES_HISTORY', 'PROSPECT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'ProspectLists'    , 'ProspectLists'      ,  3, 'ProspectLists.LBL_MODULE_NAME'    , 'vwPROSPECTS_PROSPECT_LISTS'    , 'PROSPECT_ID', 'DATE_ENTERED' , 'desc';
	-- exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'    , 'CampaignLog'      , 'CampaignLog'        ,  4, 'CampaignLog.LBL_MODULE_NAME'      , 'vwPROSPECTS_CAMPAIGN_LOG'      , 'PROSPECT_ID', 'DATE_ENTERED' , 'desc';
end else begin
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'ProspectLists'    , 'ProspectLists'      ,  null, 'ProspectLists.LBL_MODULE_NAME' ;

	-- 08/13/2009 Paul.  All the user to reorder the activities panels by creating separate controls for open and history. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.DetailView' and CONTROL_NAME = 'ActivitiesOpen' and DELETED = 0) begin -- then
		-- 11/30/2012 Paul.  Enable separate controls for Open and History while disabling the combined Activities control. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Prospects.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'Activities'       , 'ActivitiesOpen'     ,  0, 'Activities.LBL_OPEN_ACTIVITIES', 'vwPROSPECTS_ACTIVITIES_OPEN'   , 'PROSPECT_ID', 'DATE_DUE'     , 'desc';
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'       , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'        , 'vwPROSPECTS_ACTIVITIES_HISTORY', 'PROSPECT_ID', 'DATE_MODIFIED', 'desc';
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 0
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = 'Prospects.DetailView'
		   and CONTROL_NAME         = 'Activities'
		   and DELETED              = 0;
	end -- if;

	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'Prospects.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwPROSPECTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
end -- if;
GO

-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProspectLists.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS ProspectLists.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwPROSPECT_LISTS_STREAM'         , 'ID'              , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Prospects'        , 'Prospects'          ,  1, 'Prospects.LBL_MODULE_NAME'        , 'vwPROSPECT_LISTS_PROSPECTS'      , 'PROSPECT_LIST_ID', 'PROSPECT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Contacts'         , 'Contacts'           ,  2, 'Contacts.LBL_MODULE_NAME'         , 'vwPROSPECT_LISTS_CONTACTS'       , 'PROSPECT_LIST_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwPROSPECT_LISTS_LEADS'          , 'PROSPECT_LIST_ID', 'LEAD_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Users'            , 'Users'              ,  4, 'Users.LBL_MODULE_NAME'            , 'vwPROSPECT_LISTS_USERS'          , 'PROSPECT_LIST_ID', 'FULL_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Accounts'         , 'Accounts'           ,  5, 'Accounts.LBL_MODULE_NAME'         , 'vwPROSPECT_LISTS_ACCOUNTS'       , 'PROSPECT_LIST_ID', 'ACCOUNT_NAME' , 'asc';
end else begin
	-- 10/01/2015 Paul.  Add the ActivityStream at the top. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProspectLists.DetailView' and CONTROL_NAME = 'ActivityStream' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProspectLists.DetailView'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView'      , 'ActivityStream'   , 'ActivityStream'     ,  0, '.LBL_ACTIVITY_STREAM'             , 'vwPROSPECT_LISTS_STREAM'            , 'ID'        , 'STREAM_DATE desc, STREAM_VERSION desc' , 'desc';
	end -- if;
	-- 10/27/2017 Paul.  Add Accounts as email source. 
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProspectLists.DetailView' , 'Accounts'         , 'Accounts'           ,  5, 'Accounts.LBL_MODULE_NAME'         , 'vwPROSPECT_LISTS_ACCOUNTS'       , 'PROSPECT_LIST_ID', 'ACCOUNT_NAME' , 'asc';
	-- 04/13/2021 Paul.  Fix some bad data for the React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProspectLists.DetailView' and PRIMARY_FIELD = 'PROSPECTLIST_ID' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set PRIMARY_FIELD      = 'PROSPECT_LIST_ID'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'ProspectLists.DetailView'
		   and PRIMARY_FIELD      = 'PROSPECTLIST_ID'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS Prospects.DetailView';
-- 	-- exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.DetailView'     , 'CampaignLog'      , 'CampaignLog'        ,  0, 'CampaignLog.LBL_MODULE_NAME'        , 'vwPROSPECTS_CAMPAIGN_LOG'      , 'PROSPECT_ID', 'DATE_ENTERED' , 'desc';
-- end -- if;
-- #endif SQL_Server */
--GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Tasks.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS Tasks.DetailView';
-- end -- if;
-- #endif SQL_Server */
--GO

-- #if SQL_Server /*
-- if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Users.DetailView' and DELETED = 0) begin -- then
-- 	print 'DETAILVIEWS_RELATIONSHIPS Users.DetailView';
-- 10/24/2014 Paul.  Keep the user panels manual so that we can apply the MyAccount flag. 
-- 	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Users.DetailView' , 'UserSignatures', 'Signatures',  0, 'UserSignatures.LBL_MY_SIGNATURES', 'vwUSERS_SIGNATURES'      , 'USER_ID', 'NAME'      , 'asc';
-- 	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Users.DetailView' , 'ACLRoles'      , 'Roles'     ,  1, 'Roles.LBL_MODULE_NAME'           , 'vwUSERS_ACL_ROLES'       , 'USER_ID', 'ROLE_NAME' , 'asc';
-- 	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Users.DetailView' , 'Teams'         , 'Teams'     ,  2, 'Users.LBL_MY_TEAMS'              , 'vwUSERS_TEAM_MEMBERSHIPS', 'USER_ID', 'TEAM_NAME' , 'asc';
-- 	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Users.DetailView' , 'Users'         , 'Logins'    ,  3, 'Users.LBL_LOGINS'                , 'vwUSERS_LOGINS'          , 'USER_ID', 'LOGIN_DATE', 'desc';
-- end -- if;
-- #endif SQL_Server */
--GO

-- 10/20/2006 Paul.  Fix ProjectTask module name. 
-- 11/05/2007 Paul.  Add Accounts, Calls and Meetings to home page. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView';
-- 01/01/2008 Paul.  We should not need to fix the calendar on a clean install. 
-- 01/17/2008 Paul.  Home.DetailView has been replaced with Left, Body and Right panels. 
/*
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Calendar'         , '~/Activities/MyActivities'      ,  0, 'Activities.LBL_UPCOMING'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Opportunities'    , '~/Opportunities/MyOpportunities',  1, 'Opportunities.LBL_TOP_OPPORTUNITIES'  , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Cases'            , '~/Cases/MyCases'                ,  2, 'Cases.LBL_LIST_MY_CASES'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Leads'            , '~/Leads/MyLeads'                ,  3, 'Leads.LBL_LIST_MY_LEADS'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Tasks'            , '~/Tasks/MyTasks'                ,  4, 'Tasks.LBL_LIST_MY_TASKS'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Bugs'             , '~/Bugs/MyBugs'                  ,  5, 'Bugs.LBL_LIST_MY_BUGS'                , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'ProjectTask'      , '~/ProjectTasks/MyProjectTasks'  ,  6, 'ProjectTask.LBL_LIST_MY_PROJECT_TASKS', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Accounts'         , '~/Accounts/MyAccounts'          ,  7, 'Accounts.LBL_LIST_MY_ACCOUNTS'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Calls'            , '~/Calls/MyCalls'                ,  8, 'Calls.LBL_LIST_MY_CALLS'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView'          , 'Meetings'         , '~/Meetings/MyMeetings'          ,  9, 'Meetings.LBL_LIST_MY_MEETINGS'        , null, null, null, null;
end -- if;
*/
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView' and DELETED = 0) begin -- then
	print 'Deleting DETAILVIEWS_RELATIONSHIPS Home.DetailView';
	update DETAILVIEWS_RELATIONSHIPS
	   set DELETED          = 1
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Home.DetailView'
	   and DELETED          = 0;
end -- if;
GO

-- 12/05/2006 Paul.  Fix Activities in DetailView relationships.  Treat as Calendar as it only includes Calls and Meetings
-- 01/17/2008 Paul.  Home.DetailView has been replaced with Left, Body and Right panels. 
/*
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView' and MODULE_NAME = 'Activities' and DELETED = 0) begin -- then
	print 'Fix Activities in DetailView relationships.  ';
	update DETAILVIEWS_RELATIONSHIPS
	   set MODULE_NAME      = 'Calendar'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Home.DetailView'
	   and MODULE_NAME      = 'Activities'
	   and DELETED          = 0;
end -- if;
*/
GO

-- 12/28/2007 Paul.  UnifiedSearch should be customizable. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.UnifiedSearch';
-- 01/01/2008 Paul.  We should not need to fix the search on a clean install. 
-- 08/15/2012 Paul.  Add SearchBugs to Home.UnifiedSearch. 
-- 12/08/2014 Paul.  Add ChatMessages. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.UnifiedSearch' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.UnifiedSearch';
	exec dbo.spDETAILVIEWS_InsertOnly               'Home.UnifiedSearch'       , 'Home'              , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Contacts'         , '~/Contacts/SearchContacts'          , 0, 'Contacts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Accounts'         , '~/Accounts/SearchAccounts'          , 1, 'Accounts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Leads'            , '~/Leads/SearchLeads'                , 2, 'Leads.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Opportunities'    , '~/Opportunities/SearchOpportunities', 3, 'Opportunities.LBL_LIST_FORM_TITLE', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Prospects'        , '~/Prospects/SearchProspects'        , 4, 'Prospects.LBL_LIST_FORM_TITLE'    , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Cases'            , '~/Cases/SearchCases'                , 5, 'Cases.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Project'          , '~/Projects/SearchProjects'          , 6, 'Project.LBL_LIST_FORM_TITLE'      , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Bugs'             , '~/Bugs/SearchBugs'                  , 7, 'Bugs.LBL_LIST_FORM_TITLE'         , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'ChatMessages'     , '~/ChatMessages/SearchChatMessages'  , 8, 'ChatMessages.LBL_LIST_FORM_TITLE' , null, null, null, null;
end else begin
	-- 08/15/2012 Paul.  Fix Project.LBL_LIST_FORM_TITLE. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.UnifiedSearch' and TITLE = 'Projects.LBL_LIST_FORM_TITLE' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TITLE             = 'Project.LBL_LIST_FORM_TITLE'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Home.UnifiedSearch'
		   and TITLE             = 'Projects.LBL_LIST_FORM_TITLE'
		   and DELETED           = 0;
	end -- if;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'Bugs'             , '~/Bugs/SearchBugs'                  , 7, 'Bugs.LBL_LIST_FORM_TITLE'         , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.UnifiedSearch'       , 'ChatMessages'     , '~/ChatMessages/SearchChatMessages'  , 8, 'ChatMessages.LBL_LIST_FORM_TITLE' , null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView.Left' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.DetailView.Left';
	exec dbo.spDETAILVIEWS_InsertOnly               'Home.DetailView.Left'     , 'Home'             , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Left'     , 'Home'             , '~/Contacts/NewRecord'               , 0, 'Contacts.LBL_NEW_FORM_TITLE'      , null, null, null, null;
end -- if;
GO

-- 09/27/2009 Paul.  Use the new Silverlight Charts for the pipeline. 
-- 01/10/2015 Paul.  Use the HTML5 charts on new installations. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView.Body' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.DetailView.Body';
	exec dbo.spDETAILVIEWS_InsertOnly               'Home.DetailView.Body'     , 'Home'             , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Calls'            , '~/Calls/MyCalls'                ,  0, 'Calls.LBL_LIST_MY_CALLS'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Meetings'         , '~/Meetings/MyMeetings'          ,  1, 'Meetings.LBL_LIST_MY_MEETINGS'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Leads'            , '~/Leads/MyLeads'                ,  2, 'Leads.LBL_LIST_MY_LEADS'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Opportunities'    , '~/Opportunities/html5/MyPipelineBySalesStage', 3, 'Home.LBL_PIPELINE_FORM_TITLE'         , null, null, null, null;
-- 01/17/2008 Paul.  Disabled. 
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Contacts'         , '~/Contacts/MyContacts'           , 4, 'Contacts.LBL_LIST_MY_CONTACTS'        , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Activities'       , '~/Activities/MyActivities'      ,  5, 'Activities.LBL_UPCOMING'              , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Tasks'            , '~/Tasks/MyTasks'                ,  6, 'Tasks.LBL_LIST_MY_TASKS'              , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Bugs'             , '~/Bugs/MyBugs'                  ,  7, 'Bugs.LBL_LIST_MY_BUGS'                , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'ProjectTasks'     , '~/ProjectTasks/MyProjectTasks'  ,  8, 'ProjectTask.LBL_LIST_MY_PROJECT_TASKS', null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Body'     , 'Calendar'         , '~/Calendar/MyCalendar'          ,  9, 'Calendar.LBL_MODULE_TITLE'            , null, null, null, null;
end -- if;
GO

-- 09/20/2009 Paul.  Move Team Notices to the Professional file. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.DetailView.Right' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.DetailView.Right';
	exec dbo.spDETAILVIEWS_InsertOnly               'Home.DetailView.Right'    , 'Home'             , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Right'    , 'Cases'            , '~/Cases/MyCases'                    , 1, 'Cases.LBL_LIST_MY_CASES'            , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Right'    , 'Opportunities'    , '~/Opportunities/MyOpportunities'    , 2, 'Opportunities.LBL_TOP_OPPORTUNITIES', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.DetailView.Right'    , 'Accounts'         , '~/Accounts/MyAccounts'              , 3, 'Accounts.LBL_LIST_MY_ACCOUNTS'      , null, null, null, null;
end -- if;
GO

-- 01/17/2008 Paul.  We are replacing WebParts with a DetailView relationship. 
-- 09/27/2009 Paul.  Use the new Silverlight Charts. 
-- 01/10/2015 Paul.  Use the HTML5 charts on new installations. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Dashboard.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Dashboard.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly               'Dashboard.DetailView'     , 'Dashboard'        , 'vwDASHBOARD_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Dashboard.DetailView'     , 'Opportunities'    , '~/Dashboard/html5/PipelineBySalesStage'    , 0, 'Dashboard.LBL_SALES_STAGE_FORM_TITLE', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Dashboard.DetailView'     , 'Opportunities'    , '~/Dashboard/html5/OppByLeadSourceByOutcome', 1, 'Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Dashboard.DetailView'     , 'Opportunities'    , '~/Dashboard/html5/PipelineByMonthByOutcome', 2, 'Dashboard.LBL_YEAR_BY_OUTCOME'       , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Dashboard.DetailView'     , 'Opportunities'    , '~/Dashboard/html5/OppByLeadSource'         , 3, 'Dashboard.LBL_LEAD_SOURCE_FORM_TITLE', null, null, null, null;
end -- if;
GO

-- 10/20/2006 Paul.  Fix Project module name. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where MODULE_NAME = 'Projects' and DELETED = 0) begin -- then
	print 'Fix Project module name in DetailView relationships.';
	update DETAILVIEWS_RELATIONSHIPS
	   set MODULE_NAME      = 'Project'
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where MODULE_NAME      = 'Projects'
	   and DELETED          = 0;
end -- if;
GO

-- 10/20/2006 Paul.  Fix ProjectTask module name. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where MODULE_NAME = 'ProjectTasks' and DELETED = 0) begin -- then
	print 'Fix ProjectTask module name in DetailView relationships.';
	update DETAILVIEWS_RELATIONSHIPS
	   set MODULE_NAME      = 'ProjectTask'
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where MODULE_NAME      = 'ProjectTasks'
	   and DELETED          = 0;
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Campaigns.TrackDetailView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Campaigns.TrackDetailView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Campaigns.TrackDetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Campaigns.TrackDetailView';
	exec dbo.spDETAILVIEWS_InsertOnly               'Campaigns.TrackDetailView' , 'Campaigns', 'vwCAMPAIGNS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackQueue'         ,  0, 'Campaigns.LBL_MESSAGE_QUEUE_TITLE'            , 'vwEMAILMAN_List'              , 'CAMPAIGN_ID', 'SEND_DATE_TIME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackTargeted'      ,  1, 'Campaigns.LBL_LOG_ENTRIES_TARGETED_TITLE'     , 'vwCAMPAIGN_LOG_TrackTargeted' , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackViewed'        ,  2, 'Campaigns.LBL_LOG_ENTRIES_VIEWED_TITLE'       , 'vwCAMPAIGN_LOG_TrackViewed'   , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackClickThru'     ,  3, 'Campaigns.LBL_LOG_ENTRIES_LINK_TITLE'         , 'vwCAMPAIGN_LOG_TrackClickThru', 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackLeads'         ,  4, 'Campaigns.LBL_LOG_ENTRIES_LEAD_TITLE'         , 'vwCAMPAIGN_LOG_TrackLeads'    , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackContacts'      ,  5, 'Campaigns.LBL_LOG_ENTRIES_CONTACT_TITLE'      , 'vwCAMPAIGN_LOG_TrackContacts' , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackInvalidEmail'  ,  6, 'Campaigns.LBL_LOG_ENTRIES_INVALID_EMAIL_TITLE', 'vwCAMPAIGN_LOG_TrackInvalid'  , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackSendError'     ,  7, 'Campaigns.LBL_LOG_ENTRIES_SEND_ERROR_TITLE'   , 'vwCAMPAIGN_LOG_TrackSendError', 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackRemoved'       ,  8, 'Campaigns.LBL_LOG_ENTRIES_REMOVED_TITLE'      , 'vwCAMPAIGN_LOG_TrackRemoved'  , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Campaigns'        , 'TrackBlocked'       ,  9, 'Campaigns.LBL_LOG_ENTRIES_BLOCKEDD_TITLE'     , 'vwCAMPAIGN_LOG_TrackBlocked'  , 'CAMPAIGN_ID', 'ACTIVITY_DATE' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Leads'            , 'Leads'              , 10, 'Campaigns.LBL_CAMPAIGN_LEAD_SUBPANEL_TITLE'   , 'vwCAMPAIGNS_LEADS'            , 'CAMPAIGN_ID', 'LEAD_NAME'     , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Campaigns.TrackDetailView' , 'Opportunities'    , 'Opportunities'      , 11, 'Campaigns.LBL_OPPORTUNITY_SUBPANEL_TITLE'     , 'vwCAMPAIGNS_OPPORTUNITIES'    , 'CAMPAIGN_ID', 'DATE_ENTERED'  , 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Administration.ListView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Administration.ListView';
	exec dbo.spDETAILVIEWS_InsertOnly               'Administration.ListView'   , 'Administration'   , 'vwADMINISTRATION', '20%', '30%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'NetworkView'        ,  0, 'Administration.LBL_SPLENDIDCRM_NETWORK_TITLE' , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'SystemView'         ,  1, 'Administration.LBL_ADMINISTRATION_HOME_TITLE' , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'UsersView'          ,  2, 'Administration.LBL_USERS_TITLE'               , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'StudioView'         ,  3, 'Administration.LBL_STUDIO_TITLE'              , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'EmailsView'         ,  4, 'Administration.LBL_EMAIL_TITLE'               , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'BugsView'           ,  5, 'Administration.LBL_BUG_TITLE'                 , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'CloudView'          ,  12, 'Administration.LBL_CLOUD_SERVICES_TITLE'     , null, null, null, null;
end -- if;
GO

-- 04/15/2011 Paul.  Add Cloud Services to the bottom of all panels. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Administration.ListView' and CONTROL_NAME = 'CloudView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Administration.ListView CloudView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'CloudView'          ,  12, 'Administration.LBL_CLOUD_SERVICES_TITLE'     , null, null, null, null;
end -- if;
GO

-- 07/05/2012 Paul.  Create normalized and indexed phone fields for fast call center lookups. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.PhoneSearch';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Home.PhoneSearch' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Home.PhoneSearch';
	exec dbo.spDETAILVIEWS_InsertOnly               'Home.PhoneSearch'         , 'Home'             , 'vwPHONE_NUMBERS', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.PhoneSearch'         , 'Calls'            , '~/Calls/NewPhoneCall'               , 0, 'Calls.LBL_NEW_FORM_TITLE'         , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.PhoneSearch'         , 'Contacts'         , '~/Contacts/SearchPhones'            , 1, 'Contacts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.PhoneSearch'         , 'Accounts'         , '~/Accounts/SearchPhones'            , 2, 'Accounts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.PhoneSearch'         , 'Leads'            , '~/Leads/SearchPhones'               , 3, 'Leads.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Home.PhoneSearch'         , 'Prospects'        , '~/Prospects/SearchPhones'           , 4, 'Prospects.LBL_LIST_FORM_TITLE'    , null, null, null, null;
end -- if;
GO

-- 11/27/2012 Paul.  Fix table name. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where CONTROL_NAME = 'ActivitiesOpen' and TABLE_NAME like '%ACTIVITIESOPEN' and DELETED = 0) begin -- then
	update DETAILVIEWS_RELATIONSHIPS
	   set TABLE_NAME           = replace(TABLE_NAME, 'ACTIVITIESOPEN', 'ACTIVITIES_OPEN')
	     , DATE_MODIFIED        = getdate()
	     , DATE_MODIFIED_UTC    = getutcdate()
	     , MODIFIED_USER_ID     = null
	 where CONTROL_NAME         = 'ActivitiesOpen'
	   and TABLE_NAME           like '%ACTIVITIESOPEN'
	   and DELETED              = 0;
end -- if;

if exists(select * from DETAILVIEWS_RELATIONSHIPS where CONTROL_NAME = 'ActivitiesHistory' and TABLE_NAME like '%ACTIVITIESHISTORY' and DELETED = 0) begin -- then
	update DETAILVIEWS_RELATIONSHIPS
	   set TABLE_NAME           = replace(TABLE_NAME, 'ACTIVITIESHISTORY', 'ACTIVITIES_HISTORY')
	     , DATE_MODIFIED        = getdate()
	     , DATE_MODIFIED_UTC    = getutcdate()
	     , MODIFIED_USER_ID     = null
	 where CONTROL_NAME         = 'ActivitiesHistory'
	   and TABLE_NAME           like '%ACTIVITIESHISTORY'
	   and DELETED              = 0;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ChatChannels.DetailView';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ChatChannels.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS ChatChannels.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ChatChannels.DetailView', 'ChatMessages', 'ChatMessages',  0, 'ChatMessages.LBL_MODULE_NAME', 'vwCHAT_CHANNELS_CHAT_MESSAGES', 'CHAT_CHANNEL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ChatChannels.DetailView', 'Notes'       , 'Attachments' ,  1, 'ChatChannels.LBL_ATTACHMENTS', 'vwCHAT_CHANNELS_ATTACHMENTS'  , 'CHAT_CHANNEL_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

-- 09/11/2021 Paul.  The React client requires relationship. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Terminology.ImportView';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Terminology.ImportView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Terminology.ImportView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Terminology.ImportView', 'Terminology', 'SplendidLanguagePacks',  0, 'Terminology.LBL_SPLENDIDCRM_LANGUAGE_PACKS', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Terminology.ImportView', 'Terminology', 'LanguagePacks'        ,  1, 'Terminology.LBL_SUGARCRM_LANGUAGE_PACKS'   , null, null, null, null;
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_Defaults()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_Defaults')
/

-- #endif IBM_DB2 */

