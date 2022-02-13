

print 'DETAILVIEWS_FIELDS DetailView defaults';
--delete from DETAILVIEWS_FIELDS where DETAIL_NAME like '%.DetailView.Mobile'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/28/2009 Paul.  Restore TEAM_NAME and expect it to be converted automatically when DynamicTeams is enabled. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Accounts.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Accounts.DetailView.Mobile'      , 'Accounts'      , 'vwACCOUNTS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  0, 'Accounts.LBL_ACCOUNT_NAME'       , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  1, 'Accounts.LBL_PHONE'              , 'PHONE_OFFICE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Mobile',  2, 'Accounts.LBL_WEBSITE'            , 'WEBSITE'                          , '{0}'        , 'WEBSITE'             , '{0}'                        , '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  3, 'Accounts.LBL_FAX'                , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  4, 'Accounts.LBL_TICKER_SYMBOL'      , 'TICKER_SYMBOL'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  5, 'Accounts.LBL_OTHER_PHONE'        , 'PHONE_ALTERNATE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Mobile',  6, 'Accounts.LBL_MEMBER_OF'          , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'           , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Mobile',  7, 'Accounts.LBL_EMAIL'              , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile',  8, 'Accounts.LBL_EMPLOYEES'          , 'EMPLOYEES'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Mobile',  9, 'Accounts.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 10, 'Accounts.LBL_OWNERSHIP'          , 'OWNERSHIP'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 11, 'Accounts.LBL_RATING'             , 'RATING'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.DetailView.Mobile', 12, 'Accounts.LBL_INDUSTRY'           , 'INDUSTRY'                         , '{0}'        , 'industry_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 13, 'Accounts.LBL_SIC_CODE'           , 'SIC_CODE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.DetailView.Mobile', 14, 'Accounts.LBL_TYPE'               , 'ACCOUNT_TYPE'                     , '{0}'        , 'account_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 15, 'Accounts.LBL_ANNUAL_REVENUE'     , 'ANNUAL_REVENUE'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 16, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 17, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 18, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 19, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 20, 'Accounts.LBL_BILLING_ADDRESS'    , 'BILLING_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Mobile', 21, 'Accounts.LBL_SHIPPING_ADDRESS'   , 'SHIPPING_ADDRESS_HTML'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Accounts.DetailView.Mobile', 22, 'TextBox', 'Accounts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Bugs.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Bugs.DetailView.Mobile'          , 'Bugs'          , 'vwBUGS_Edit'          , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  0, 'Bugs.LBL_BUG_NUMBER'              , 'BUG_NUMBER'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   ,  2, 'Bugs.LBL_PRIORITY'                , 'PRIORITY'                         , '{0}'        , 'bug_priority_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  3, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   ,  4, 'Bugs.LBL_STATUS'                  , 'STATUS'                           , '{0}'        , 'bug_status_dom'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  5, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   ,  6, 'Bugs.LBL_TYPE'                    , 'TYPE'                             , '{0}'        , 'bug_type_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  7, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   ,  8, 'Bugs.LBL_SOURCE'                  , 'SOURCE'                           , '{0}'        , 'source_dom'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   ,  9, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   , 10, 'Bugs.LBL_PRODUCT_CATEGORY'        , 'PRODUCT_CATEGORY'                 , '{0}'        , 'product_category_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Mobile'   , 11, 'Bugs.LBL_RESOLUTION'              , 'RESOLUTION'                       , '{0}'        , 'bug_resolution_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   , 12, 'Bugs.LBL_FOUND_IN_RELEASE'        , 'FOUND_IN_RELEASE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   , 13, 'Bugs.LBL_FIXED_IN_RELEASE'        , 'FIXED_IN_RELEASE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.DetailView.Mobile'   , 14, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.DetailView.Mobile'   , 15, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Mobile'   , 16, 'Bugs.LBL_SUBJECT'                 , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Bugs.DetailView.Mobile'   , 17, 'TextBox', 'Bugs.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.DetailView.Mobile'   , 18, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.DetailView.Mobile'   , 19, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Bugs.DetailView.Mobile'   , 20, 'TextBox', 'Bugs.LBL_WORK_LOG', 'WORK_LOG', null, null, null, null, null, 3, null;
end else begin
	-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Bugs.DetailView.Mobile'   ,  5, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
end -- if;
GO


if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Calls.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Calls.DetailView.Mobile'         , 'Calls'         , 'vwCALLS_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  0, 'Calls.LBL_SUBJECT'                , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Calls.DetailView.Mobile'  ,  1, 'Calls.LBL_STATUS'                 , 'DIRECTION STATUS'                                                             , '{0} {1}'        , 'call_direction_dom call_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  2, 'Calls.LBL_DATE_TIME'              , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Calls.DetailView.Mobile'  ,  3, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  4, 'Calls.LBL_DURATION'               , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  5, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  6, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME'                                            , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  7, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Mobile'  ,  8, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'                                              , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.DetailView.Mobile'  ,  9, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Calls.DetailView.Mobile'  , 10, 'TextBox', 'Calls.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Campaigns.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Campaigns.DetailView.Mobile'     , 'Campaigns'     , 'vwCAMPAIGNS_Edit'     , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  1, 'Campaigns.LBL_NAME'                     , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Campaigns.DetailView.Mobile',  3, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                           , '{0}'        , 'campaign_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  4, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  5, 'Campaigns.LBL_CAMPAIGN_START_DATE'      , 'START_DATE'                       , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  6, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  7, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile',  8, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Campaigns.DetailView.Mobile',  9, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'                    , '{0}'        , 'campaign_type_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView.Mobile', 10, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView.Mobile', 11, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView.Mobile', 12, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 13, 'Campaigns.LBL_CAMPAIGN_BUDGET'          , 'BUDGET'                           , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 14, 'Campaigns.LBL_CAMPAIGN_ACTUAL_COST'     , 'ACTUAL_COST'                      , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 15, 'Campaigns.LBL_CAMPAIGN_EXPECTED_REVENUE', 'EXPECTED_REVENUE'                 , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 16, 'Campaigns.LBL_CAMPAIGN_EXPECTED_COST'   , 'EXPECTED_COST'                    , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Campaigns.DetailView.Mobile', 17, 'Line', null, null, null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView.Mobile', 18, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView.Mobile', 19, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 20, 'Campaigns.LBL_CAMPAIGN_OBJECTIVE'       , 'OBJECTIVE'                        , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView.Mobile', 21, 'Campaigns.LBL_CAMPAIGN_CONTENT'         , 'CONTENT'                          , '{0}'        , 3;
end else begin
	-- 07/24/2008 Paul.  Use the common term. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView.Mobile' and DATA_LABEL = 'Campaigns.LBL_ASSIGNED_TO' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Campaigns.DetailView.Mobile: Use common field label.';
		update DETAILVIEWS_FIELDS
		   set DATA_LABEL       = '.LBL_ASSIGNED_TO'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView.Mobile'
		   and DATA_LABEL       = 'Campaigns.LBL_ASSIGNED_TO'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Cases.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Cases.DetailView.Mobile'         , 'Cases'         , 'vwCASES_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  0, 'Cases.LBL_CASE_NUMBER'            , 'CASE_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.DetailView.Mobile'  ,  2, 'Cases.LBL_PRIORITY'               , 'PRIORITY'                         , '{0}'        , 'case_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  3, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.DetailView.Mobile'  ,  4, 'Cases.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'case_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Cases.DetailView.Mobile'  ,  5, 'Cases.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Cases.DetailView.Mobile'  ,  6, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  7, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  8, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  ,  9, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Mobile'  , 10, 'Cases.LBL_SUBJECT'                , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.DetailView.Mobile'  , 11, 'TextBox', 'Cases.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.DetailView.Mobile'  , 12, 'TextBox', 'Cases.LBL_RESOLUTION'  , 'RESOLUTION' , null, null, null, null, null, 3, null;
end else begin
	-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Cases.DetailView.Mobile'  ,  8, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
end -- if;
GO

-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contacts.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Contacts.DetailView.Mobile'      , 'Contacts'      , 'vwCONTACTS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  0, 'Contacts.LBL_NAME'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  1, 'Contacts.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  2, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  3, 'Contacts.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Mobile',  4, 'Contacts.LBL_ACCOUNT_NAME'       , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  5, 'Contacts.LBL_HOME_PHONE'         , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Contacts.DetailView.Mobile',  6, 'Contacts.LBL_LEAD_SOURCE'        , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  7, 'Contacts.LBL_OTHER_PHONE'        , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  8, 'Contacts.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile',  9, 'Contacts.LBL_FAX_PHONE'          , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 10, 'Contacts.LBL_DEPARTMENT'         , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Mobile', 11, 'Contacts.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 12, 'Contacts.LBL_BIRTHDATE'          , 'BIRTHDATE'                        , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Mobile', 13, 'Contacts.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Mobile', 14, 'Contacts.LBL_REPORTS_TO'         , 'REPORTS_TO_NAME'                  , '{0}'        , 'REPORTS_TO_ID'       , '~/Contacts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 15, 'Contacts.LBL_ASSISTANT'          , 'ASSISTANT'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.DetailView.Mobile', 16, 'Contacts.LBL_SYNC_CONTACT'       , 'SYNC_CONTACT'                     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 17, 'Contacts.LBL_ASSISTANT_PHONE'    , 'ASSISTANT_PHONE'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.DetailView.Mobile', 18, 'Contacts.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.DetailView.Mobile', 19, 'Contacts.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 20, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 21, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 22, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 23, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 24, 'Contacts.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Mobile', 25, 'Contacts.LBL_ALTERNATE_ADDRESS'  , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Contacts.DetailView.Mobile', 26, 'TextBox', 'Contacts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Contacts.DetailView.Mobile',  2, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Documents.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Documents.DetailView.Mobile'     , 'Documents'     , 'vwDOCUMENTS_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  0, 'Documents.LBL_DOC_NAME'         , 'DOCUMENT_NAME'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  1, 'Documents.LBL_DOC_VERSION'      , 'REVISION'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Mobile',  2, 'Documents.LBL_CATEGORY_VALUE'   , 'CATEGORY_ID'                      , '{0}'        , 'document_category_dom'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Mobile',  3, 'Documents.LBL_SUBCATEGORY_VALUE', 'SUBCATEGORY_ID'                   , '{0}'        , 'document_subcategory_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Mobile',  4, 'Documents.LBL_DOC_STATUS'       , 'STATUS_ID'                        , '{0}'        , 'document_status_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  5, 'Teams.LBL_TEAM'                 , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  6, 'Documents.LBL_LAST_REV_CREATOR' , 'REVISION_CREATED_BY_NAME'         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  7, 'Documents.LBL_LAST_REV_DATE'    , 'REVISION_DATE_ENTERED'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  8, 'Documents.LBL_DOC_ACTIVE_DATE'  , 'ACTIVE_DATE'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Mobile',  9, 'Documents.LBL_DOC_EXP_DATE'     , 'EXP_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Documents.DetailView.Mobile', 10, 'TextBox', 'Documents.LBL_DOC_DESCRIPTION', 'DESCRIPTION', '10,90', null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Documents.DetailView.Mobile', 11, 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Documents.DetailView.Mobile', 12, 'Documents.LBL_DOWNNLOAD_FILE'    , 'FILENAME'                        , '{0}'        , 'DOCUMENT_REVISION_ID'    , '~/Documents/Document.aspx?ID={0}', '_blank', 3;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Emails.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Emails.DetailView.Mobile'        , 'Emails'        , 'vwEMAILS_Edit'        , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  0, 'Emails.LBL_DATE_SENT'            , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Emails.DetailView.Mobile'  ,  1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  2, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  3, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  4, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  5, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  6, 'Emails.LBL_FROM'                 , 'FROM_NAME FROM_ADDR'              , '{0} &lt;{1}&gt;', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  7, 'Emails.LBL_TO'                   , 'TO_ADDRS'                         , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  8, 'Emails.LBL_CC'                   , 'CC_ADDRS'                         , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  ,  9, 'Emails.LBL_BCC'                  , 'BCC_ADDRS'                        , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Mobile'  , 10, 'Emails.LBL_SUBJECT'              , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Emails.DetailView.Mobile'  , 11, 'TextBox', 'Emails.LBL_BODY', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS EmailTemplates.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'EmailTemplates.DetailView.Mobile', 'EmailTemplates', 'vwEMAIL_TEMPLATES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  0, 'EmailTemplates.LBL_NAME'         , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'EmailTemplates.DetailView.Mobile',  2, 'TextBox', 'EmailTemplates.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  3, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  4, 'EmailTemplates.LBL_SUBJECT'      , 'SUBJECT'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  5, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView.Mobile',  6, 'EmailTemplates.LBL_BODY'         , 'BODY_HTML'                        , '{0}'        , 3;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Employees.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Employees.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Employees.DetailView.Mobile'     , 'Employees'     , 'vwEMPLOYEES_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Employees.DetailView.Mobile',  1, 'Employees.LBL_EMPLOYEE_STATUS'   , 'EMPLOYEE_STATUS'                  , '{0}'        , 'employee_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile',  2, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile',  3, 'Employees.LBL_NAME'              , 'FULL_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile',  4, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile',  5, 'Employees.LBL_TITLE'             , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile',  6, 'Employees.LBL_OFFICE_PHONE'      , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile',  7, 'Employees.LBL_DEPARTMENT'        , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile',  8, 'Employees.LBL_MOBILE_PHONE'      , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView.Mobile',  9, 'Employees.LBL_REPORTS_TO'        , 'REPORTS_TO_NAME'                  , '{0}'        , 'REPORTS_TO_ID'       , '~/Employees/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile', 10, 'Employees.LBL_OTHER'             , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile', 11, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile', 12, 'Employees.LBL_FAX'               , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView.Mobile', 13, 'Employees.LBL_EMAIL'             , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile', 14, 'Employees.LBL_HOME_PHONE'        , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView.Mobile', 15, 'Employees.LBL_OTHER_EMAIL'       , 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile', 16, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Employees.DetailView.Mobile', 17, 'Employees.LBL_MESSENGER_TYPE'    , 'MESSENGER_TYPE'                   , '{0}'        , 'messenger_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile', 18, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile', 19, 'Employees.LBL_MESSENGER_ID'      , 'MESSENGER_ID'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile', 20, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView.Mobile', 21, 'Employees.LBL_ADDRESS'           , 'ADDRESS_HTML'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView.Mobile', 22, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Employees.DetailView.Mobile', 23, 'TextBox', 'Employees.LBL_NOTES', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Leads.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Leads.DetailView.Mobile'         , 'Leads'         , 'vwLEADS_Edit'         , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.DetailView.Mobile'   ,  0, 'Leads.LBL_LEAD_SOURCE'            , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.DetailView.Mobile'   ,  1, 'Leads.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'lead_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  2, 'Leads.LBL_LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION'          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  3, 'Leads.LBL_STATUS_DESCRIPTION'     , 'STATUS_DESCRIPTION'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  4, 'Leads.LBL_REFERED_BY'             , 'REFERED_BY'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.DetailView.Mobile'   ,  5, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.DetailView.Mobile'   ,  6, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  7, 'Leads.LBL_OFFICE_PHONE'           , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  8, 'Leads.LBL_NAME'                   , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   ,  9, 'Leads.LBL_MOBILE_PHONE'           , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 10, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 11, 'Leads.LBL_HOME_PHONE'             , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.DetailView.Mobile'   , 12, 'Leads.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 13, 'Leads.LBL_OTHER_PHONE'            , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.DetailView.Mobile'   , 14, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 15, 'Leads.LBL_FAX_PHONE'              , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 16, 'Leads.LBL_TITLE'                  , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.DetailView.Mobile'   , 17, 'Leads.LBL_EMAIL_ADDRESS'          , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 18, 'Leads.LBL_DEPARTMENT'             , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.DetailView.Mobile'   , 19, 'Leads.LBL_OTHER_EMAIL_ADDRESS'    , 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Leads.DetailView.Mobile'   , 20, 'Leads.LBL_DO_NOT_CALL'            , 'DO_NOT_CALL'                      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Leads.DetailView.Mobile'   , 21, 'Leads.LBL_EMAIL_OPT_OUT'          , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 22, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 23, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 24, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 25, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 26, 'Leads.LBL_PRIMARY_ADDRESS'        , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Mobile'   , 27, 'Leads.LBL_ALTERNATE_ADDRESS'      , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Leads.DetailView.Mobile'   , 28, 'TextBox', 'Leads.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Leads.DetailView.Mobile'   , 10, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Meetings.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Meetings.DetailView.Mobile'      , 'Meetings'      , 'vwMEETINGS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  0, 'Meetings.LBL_SUBJECT'             , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Meetings.DetailView.Mobile',  1, 'Meetings.LBL_STATUS'              , 'STATUS'                                                                       , '{0}'            , 'meeting_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  2, 'Meetings.LBL_LOCATION'            , 'LOCATION'                                                                     , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Meetings.DetailView.Mobile',  3, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  4, 'Meetings.LBL_DATE_TIME'           , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  5, 'Meetings.LBL_DURATION'            , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  6, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  7, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME'                                            , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  8, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Mobile',  9, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'                                              , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Meetings.DetailView.Mobile', 10, 'TextBox', 'Meetings.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Notes.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Notes.DetailView.Mobile'         , 'Notes'         , 'vwNOTES_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Mobile'   ,  0, 'Notes.LBL_CONTACT_NAME'          , 'CONTACT_NAME'                     , '{0}'        , 'CONTACT_ID'        , '~/Contacts/view.aspx?ID={0}'   , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Mobile'   ,  1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Mobile'   ,  2, 'Notes.LBL_PHONE'                 , 'CONTACT_PHONE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Mobile'   ,  3, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Mobile'   ,  4, 'Notes.LBL_EMAIL_ADDRESS'         , 'CONTACT_EMAIL'                    , '{0}'        , 'CONTACT_EMAIL'     , 'mailto:{0}'                    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Mobile'   ,  5, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Mobile'   ,  6, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Notes.DetailView.Mobile'   ,  7, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Mobile'   ,  8, 'Notes.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Mobile'   ,  9, 'Notes.LBL_FILENAME'              , 'FILENAME'                         , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}', null, 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Notes.DetailView.Mobile'   , 10, 'TextBox', 'Notes.LBL_NOTE', 'DESCRIPTION', '30,90', null, null, null, null, 3, null;
end -- if;
GO

-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Opportunities.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Opportunities.DetailView.Mobile' , 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile',  0, 'Opportunities.LBL_OPPORTUNITY_NAME', 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile',  1, 'Opportunities.LBL_AMOUNT'          , 'AMOUNT'                           , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.DetailView.Mobile',  2, 'Opportunities.LBL_ACCOUNT_NAME'    , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'          , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.DetailView.Mobile',  3, 'Opportunities.LBL_LEAD_NAME'       , 'LEAD_NAME'                        , '{0}'        , 'LEAD_ID'             , '~/Leads/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile',  4, 'Opportunities.LBL_DATE_CLOSED'     , 'DATE_CLOSED'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Mobile',  5, 'Opportunities.LBL_TYPE'            , 'OPPORTUNITY_TYPE'                 , '{0}'        , 'opportunity_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile',  6, 'Opportunities.LBL_NEXT_STEP'       , 'NEXT_STEP'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Mobile',  7, 'Opportunities.LBL_LEAD_SOURCE'     , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Mobile',  8, 'Opportunities.LBL_SALES_STAGE'     , 'SALES_STAGE'                      , '{0}'        , 'sales_stage_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile',  9, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile', 10, 'Opportunities.LBL_PROBABILITY'     , 'PROBABILITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile', 11, '.LBL_ASSIGNED_TO'                  , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile', 12, '.LBL_DATE_MODIFIED'                , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile', 13, '.LBL_LAST_ACTIVITY_DATE'           , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Mobile', 14, '.LBL_DATE_ENTERED'                 , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Opportunities.DetailView.Mobile', 15, 'TextBox', 'Opportunities.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	-- 02/26/2016 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Opportunities.DetailView.Mobile', 12, '.LBL_LAST_ACTIVITY_DATE'           , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView.Mobile' and DATA_FIELD = 'LEAD_NAME' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS: Add Leads to Opportunities.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()     
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Opportunities.DetailView.Mobile'
		   and FIELD_INDEX      >= 3
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Opportunities.DetailView.Mobile',  3, 'Opportunities.LBL_LEAD_NAME'       , 'LEAD_NAME'                        , '{0}'        , 'LEAD_ID'             , '~/Leads/view.aspx?ID={0}', null, null;
	end -- if;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Project.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Project.DetailView.Mobile'    , 'Project'       , 'vwPROJECTS_Edit'      , '20%', '20%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  0, 'Project.LBL_NAME'                    , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Project.DetailView.Mobile',  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Mobile',  2, 'ProjectTask.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'projects_priority_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Mobile',  3, 'ProjectTask.LBL_PRIORITY'            , 'PRIORITY'                         , '{0}'        , 'project_status_dom'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  4, 'ProjectTask.LBL_ESTIMATED_START_DATE', 'ESTIMATED_START_DATE'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  5, 'ProjectTask.LBL_ESTIMATED_END_DATE'  , 'ESTIMATED_END_DATE'               , '{0}'        , null;
-- 01/13/2010 Paul.  SugarCRM nolonger displayes the effort fields. 
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  6, 'Project.LBL_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT'           , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  7, 'Project.LBL_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  6, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  7, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Project.DetailView.Mobile',  8, 'TextBox', 'Project.LBL_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Project.DetailView.Mobile',  1, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView.Mobile' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Project.DetailView.Mobile: Add start date and end date.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 4
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME  = 'Project.DetailView.Mobile'
		   and FIELD_INDEX >= 2
		   and DELETED      = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Mobile',  2, 'ProjectTask.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'projects_priority_options', null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Mobile',  3, 'ProjectTask.LBL_PRIORITY'            , 'PRIORITY'                         , '{0}'        , 'project_status_dom'       , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  4, 'ProjectTask.LBL_ESTIMATED_START_DATE', 'ESTIMATED_START_DATE'             , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Mobile',  5, 'ProjectTask.LBL_ESTIMATED_END_DATE'  , 'ESTIMATED_END_DATE'               , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 01/19/2010 Paul.  Now that ESTIMATED_EFFORT is a float, we need to format the value. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProjectTask.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'ProjectTask.DetailView.Mobile'   , 'ProjectTask'   , 'vwPROJECT_TASKS_Edit' , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile',  0, 'Project.LBL_NAME'                , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile',  1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Mobile',  2, 'ProjectTask.LBL_STATUS'          , 'STATUS'                           , '{0}'        , 'project_task_status_options'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile',  3, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile',  4, 'ProjectTask.LBL_TASK_NUMBER'     , 'TASK_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ProjectTask.DetailView.Mobile',  5, 'ProjectTask.LBL_DEPENDS_ON_ID'   , 'DEPENDS_ON_NAME'                  , '{0}'        , 'DEPENDS_ON_ID'                   , '~/ProjectTasks/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Mobile',  6, 'ProjectTask.LBL_PRIORITY'        , 'PRIORITY'                         , '{0}'        , 'project_task_priority_options'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'ProjectTask.DetailView.Mobile',  7, 'ProjectTask.LBL_MILESTONE_FLAG'  , 'MILESTONE_FLAG'                   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile',  8, 'ProjectTask.LBL_ORDER_NUMBER'    , 'ORDER_NUMBER'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ProjectTask.DetailView.Mobile',  9, 'ProjectTask.LBL_PARENT_ID'       , 'PROJECT_NAME'                     , '{0}'        , 'PROJECT_ID'                      , '~/Projects/view.aspx?ID={0}'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile', 10, 'ProjectTask.LBL_PERCENT_COMPLETE', 'PERCENT_COMPLETE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Mobile', 11, 'ProjectTask.LBL_UTILIZATION'     , 'UTILIZATION'                      , '{0}'        , 'project_task_utilization_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile', 12, 'ProjectTask.LBL_DATE_START'      , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile', 13, 'ProjectTask.LBL_ESTIMATED_EFFORT', 'ESTIMATED_EFFORT'                 , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile', 14, 'ProjectTask.LBL_DATE_DUE'        , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Mobile', 15, 'ProjectTask.LBL_ACTUAL_EFFORT'   , 'ACTUAL_EFFORT'                    , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'ProjectTask.DetailView.Mobile', 16, 'TextBox', 'ProjectTask.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView.Mobile' and DATA_FIELD = 'ESTIMATED_EFFORT' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS ProjectTask.DetailView.Mobile: ESTIMATED_EFFORT format F1';
		update DETAILVIEWS_FIELDS
		   set DATA_FORMAT      = '{0:f1}'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'ProjectTask.DetailView.Mobile'
		   and DATA_FIELD       = 'ESTIMATED_EFFORT'
		   and DATA_FORMAT      = '{0}'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView.Mobile' and DATA_FIELD = 'ACTUAL_EFFORT' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS ProjectTask.DetailView.Mobile: ACTUAL_EFFORT format F1';
		update DETAILVIEWS_FIELDS
		   set DATA_FORMAT      = '{0:f1}'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'ProjectTask.DetailView.Mobile'
		   and DATA_FIELD       = 'ACTUAL_EFFORT'
		   and DATA_FORMAT      = '{0}'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProspectLists.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'ProspectLists.DetailView.Mobile' , 'ProspectLists' , 'vwPROSPECT_LISTS_Edit', '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  0, 'ProspectLists.LBL_NAME'              , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'ProspectLists.DetailView.Mobile',  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProspectLists.DetailView.Mobile',  2, 'ProspectLists.LBL_LIST_TYPE'         , 'LIST_TYPE'                        , '{0}'        , 'prospect_list_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  3, 'ProspectLists.LBL_DOMAIN_NAME'       , 'DOMAIN_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  4, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  5, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  6, '.LBL_CREATED_BY'                     , 'CREATED_BY_NAME'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  7, '.LBL_MODIFIED_BY'                    , 'MODIFIED_BY_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  8, '.LBL_DATE_ENTERED'                   , 'DATE_ENTERED'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView.Mobile',  9, '.LBL_DATE_MODIFIED'                  , 'DATE_MODIFIED'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'ProspectLists.DetailView.Mobile', 10, 'TextBox', 'ProspectLists.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Prospects.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Prospects.DetailView.Mobile'     , 'Prospects'     , 'vwPROSPECTS_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  0, 'Prospects.LBL_NAME'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  1, 'Prospects.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile',  2, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  3, 'Prospects.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile',  4, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  5, 'Prospects.LBL_HOME_PHONE'         , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile',  6, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  7, 'Prospects.LBL_OTHER_PHONE'        , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  8, 'Prospects.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile',  9, 'Prospects.LBL_FAX_PHONE'          , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 10, 'Prospects.LBL_DEPARTMENT'         , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.DetailView.Mobile', 11, 'Prospects.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 12, 'Prospects.LBL_BIRTHDATE'          , 'BIRTHDATE'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.DetailView.Mobile', 13, 'Prospects.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile', 14, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 15, 'Prospects.LBL_ASSISTANT'          , 'ASSISTANT'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile', 16, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 17, 'Prospects.LBL_ASSISTANT_PHONE'    , 'ASSISTANT_PHONE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.DetailView.Mobile', 18, 'Prospects.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.DetailView.Mobile', 19, 'Prospects.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.DetailView.Mobile', 20, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.DetailView.Mobile', 21, 'Prospects.LBL_INVALID_EMAIL'      , 'INVALID_EMAIL'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 22, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 23, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 24, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 25, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 26, 'Prospects.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Mobile', 27, 'Prospects.LBL_ALTERNATE_ADDRESS'  , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Prospects.DetailView.Mobile', 28, 'TextBox', 'Prospects.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Tasks.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'Tasks.DetailView.Mobile'         , 'Tasks'         , 'vwTASKS_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  0, 'Tasks.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.DetailView.Mobile'   ,  1, 'Tasks.LBL_STATUS'                , 'STATUS'                           , '{0}'        , 'task_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  2, 'Tasks.LBL_DUE_DATE_AND_TIME'     , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Tasks.DetailView.Mobile'   ,  3, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'        , '~/Parents/view.aspx?ID={0}' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  4, 'Tasks.LBL_START_DATE_AND_TIME'   , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Tasks.DetailView.Mobile'   ,  5, 'Tasks.LBL_CONTACT'               , 'CONTACT_NAME'                     , '{0}'        , 'CONTACT_ID'       , '~/Contacts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.DetailView.Mobile'   ,  6, 'Tasks.LBL_PRIORITY'              , 'PRIORITY'                         , '{0}'        , 'task_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  7, 'Tasks.LBL_EMAIL'                 , 'CONTACT_EMAIL'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  8, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   ,  9, 'Tasks.LBL_PHONE'                 , 'CONTACT_PHONE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   , 10, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   , 11, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Tasks.DetailView.Mobile'   , 12, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Mobile'   , 13, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Tasks.DetailView.Mobile'   , 14, 'TextBox', 'Tasks.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CampaignTrackers.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS CampaignTrackers.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'CampaignTrackers.DetailView.Mobile', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView.Mobile',  0, 'CampaignTrackers.LBL_EDIT_CAMPAIGN_NAME'   , 'CAMPAIGN_NAME'             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView.Mobile',  1, 'CampaignTrackers.LBL_EDIT_TRACKER_NAME'    , 'TRACKER_NAME'              , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'CampaignTrackers.DetailView.Mobile',  2, 'CampaignTrackers.LBL_EDIT_OPT_OUT'         , 'IS_OPTOUT'                                , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView.Mobile',  3, 'CampaignTrackers.LBL_EDIT_TRACKER_URL'     , 'TRACKER_URL'               , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView.Mobile',  4, 'CampaignTrackers.LBL_EDIT_TRACKER_KEY'     , 'TRACKER_KEY'               , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView.Mobile',  5, 'CampaignTrackers.LBL_EDIT_MESSAGE_URL'     , 'MESSAGE_URL'               , '{0}'        , 3;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMarketing.DetailView.Mobile' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS EmailMarketing.DetailView.Mobile';
	exec dbo.spDETAILVIEWS_InsertOnly          'EmailMarketing.DetailView.Mobile', 'EmailMarketing', 'vwEMAIL_MARKETING_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  0, 'EmailMarketing.LBL_NAME'                   , 'NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'EmailMarketing.DetailView.Mobile'  ,  1, 'EmailMarketing.LBL_STATUS'                 , 'STATUS'                    , '{0}'        , 'email_marketing_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  2, 'EmailMarketing.LBL_FROM_MAILBOX_NAME'      , 'FROM_ADDR'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  3, 'EmailMarketing.LBL_FROM_NAME'              , 'FROM_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  4, 'EmailMarketing.LBL_START_DATE_TIME'        , 'DATE_START'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  5, 'EmailMarketing.LBL_TEMPLATE'               , 'TEMPLATE_NAME'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView.Mobile'  ,  6, 'EmailMarketing.LBL_MESSAGE_FOR'            , 'ALL_PROSPECT_LISTS'        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'EmailMarketing.DetailView.Mobile'  ,  7, null;
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

call dbo.spDETAILVIEWS_FIELDS_DetailViewMobile()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_DetailViewMobile')
/

-- #endif IBM_DB2 */

