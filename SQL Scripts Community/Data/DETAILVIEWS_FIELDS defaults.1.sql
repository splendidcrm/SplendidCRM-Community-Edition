

print 'DETAILVIEWS_FIELDS defaults';
--delete from DETAILVIEWS_FIELDS where DETAIL_NAME like '%.DetailView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 11/17/2007 Paul.  Add spDETAILVIEWS_InsertOnly to simplify creation of Mobile views.
-- 11/23/2006 Paul.  Add TEAM_ID for team management. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/28/2009 Paul.  Restore TEAM_NAME and expect it to be converted automatically when DynamicTeams is enabled. 
-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 08/02/2010 Paul.  Only add the LinkedIn icon if the javascript has been defined. 
-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
-- 11/11/2010 Paul.  Lets remove LinkedIn as this error will make us look bad. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents, EmailTemplates. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 06/07/2017 Paul.  Add NAICSCodes module. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Accounts.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Accounts.DetailView', 'Accounts'      , 'vwACCOUNTS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Accounts.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_ACCOUNT_NAME'       , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_PHONE'              , 'PHONE_OFFICE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Accounts.DetailView', -1, 'Accounts.LBL_WEBSITE'            , 'WEBSITE'                          , '{0}'        , 'WEBSITE'             , '{0}'                        , '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_FAX'                , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Accounts.DetailView', -1, 'Accounts.LBL_EMAIL'              , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_OTHER_PHONE'        , 'PHONE_ALTERNATE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Accounts.DetailView', -1, 'Accounts.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Accounts.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Accounts.DetailView', -1, 'Accounts.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Accounts.DetailView', -1, 'Accounts.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Accounts.DetailView', -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_BILLING_ADDRESS'    , 'BILLING_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_SHIPPING_ADDRESS'   , 'SHIPPING_ADDRESS_HTML'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Accounts.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Accounts.DetailView', -1, 'TextBox', 'Accounts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Accounts.DetailView', -1, '.LBL_LAYOUT_TAB_MORE_INFORMATION', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Accounts.DetailView', -1, 'Accounts.LBL_TYPE'               , 'ACCOUNT_TYPE'                     , '{0}'        , 'account_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Accounts.DetailView', -1, 'Accounts.LBL_INDUSTRY'           , 'INDUSTRY'                         , '{0}'        , 'industry_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_ANNUAL_REVENUE'     , 'ANNUAL_REVENUE'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_EMPLOYEES'          , 'EMPLOYEES'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Accounts.DetailView', -1, 'Accounts.LBL_MEMBER_OF'          , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'           , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_OWNERSHIP'          , 'OWNERSHIP'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_SIC_CODE'           , 'SIC_CODE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_NAICS_SET_NAME'     , 'NAICS_SET_NAME'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_TICKER_SYMBOL'      , 'TICKER_SYMBOL'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, 'Accounts.LBL_RATING'             , 'RATING'                           , '{0}'        , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Accounts.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Accounts.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Accounts.DetailView', 16, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 08/02/2010 Paul.  Only add the LinkedIn icon if the javascript has been defined. 
	-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
	/*
	if exists(select * from CONFIG where NAME = 'external_scripts' and VALUE like '%linkedin%' and DELETED = 0) begin -- then
		if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and DATA_FIELD = 'NAME' and FIELD_TYPE = 'JavaScript' and DELETED = 0) begin -- then
			print 'Accounts.DetailView: Add LinkedIn icon.';
			update DETAILVIEWS_FIELDS
			   set FIELD_INDEX       = FIELD_INDEX + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			 where DETAIL_NAME       = 'Accounts.DetailView'
			   and FIELD_INDEX      >= 1
			   and DELETED           = 0;
			exec dbo.spDETAILVIEWS_FIELDS_InsJavaScript 'Accounts.DetailView',  1, null                              , 'NAME'                             , 'ID NAME'    , 'if (typeof(LinkedIn) != "undefined") new LinkedIn.CompanyInsiderPopup("spn{0}_NAME","{1}");', 'spn{0}_NAME', -1;
		end -- if;
	end -- if;
	*/
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Accounts.DetailView'
		   and FIELD_INDEX      >= 20
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Accounts.DetailView', 20, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Accounts.DetailView', 21, null;
	end -- if;
	-- 06/07/2017 Paul.  Add NAICSCodes module. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Accounts.DetailView', 21, 'Accounts.LBL_NAICS_SET_NAME'     , 'NAICS_SET_NAME'                   , '{0}'        , null;
	-- 10/27/2017 Paul.  Add Accounts as email source. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and DATA_FIELD = 'DO_NOT_CALL' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Accounts.DetailView'
		   and FIELD_INDEX      >= 10
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Accounts.DetailView', 10, 'Accounts.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Accounts.DetailView', 11, 'Accounts.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	end -- if;
end -- if;
GO

-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Bugs.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Bugs.DetailView'    , 'Bugs'          , 'vwBUGS_Edit'          , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Bugs.DetailView'    , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, 'Bugs.LBL_BUG_NUMBER'              , 'BUG_NUMBER'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_PRIORITY'                , 'PRIORITY'                         , '{0}'        , 'bug_priority_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, 'Bugs.LBL_SUBJECT'                 , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_STATUS'                  , 'STATUS'                           , '{0}'        , 'bug_status_dom'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_TYPE'                    , 'TYPE'                             , '{0}'        , 'bug_type_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_SOURCE'                  , 'SOURCE'                           , '{0}'        , 'source_dom'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_PRODUCT_CATEGORY'        , 'PRODUCT_CATEGORY'                 , '{0}'        , 'product_category_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Bugs.DetailView'    , -1, 'Bugs.LBL_RESOLUTION'              , 'RESOLUTION'                       , '{0}'        , 'bug_resolution_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, 'Bugs.LBL_FOUND_IN_RELEASE'        , 'FOUND_IN_RELEASE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, 'Bugs.LBL_FIXED_IN_RELEASE'        , 'FIXED_IN_RELEASE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Bugs.DetailView'    , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Bugs.DetailView'    , -1, 'TextBox', 'Bugs.LBL_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Bugs.DetailView'    , -1, 'TextBox', 'Bugs.LBL_WORK_LOG'     , 'WORK_LOG'   , null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Bugs.DetailView'    , -1, '.LBL_LAYOUT_TAB_OTHER'            , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Bugs.DetailView'    , -1, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Bugs.DetailView'   ,  3, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Bugs.DetailView'   ,  5, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView'   , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvTags      'Bugs.DetailView'   , 14, null;
end -- if;
GO


-- 03/22/2013 Paul.  Add Recurrence fields. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Calls.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Calls.DetailView'   , 'Calls'         , 'vwCALLS_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Calls.DetailView'   , -1, '.LBL_LAYOUT_TAB_OVERVIEW'         , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calls.LBL_SUBJECT'                , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Calls.DetailView'   , -1, 'Calls.LBL_STATUS'                 , 'DIRECTION STATUS'                                                             , '{0} {1}'        , 'call_direction_dom call_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calls.LBL_DATE_TIME'              , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Calls.DetailView'   , -1, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calls.LBL_DURATION'               , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Calls.DetailView'   , -1, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Calls.DetailView'   , -1, 'TextBox', 'Calls.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Calls.DetailView'   , -1, 'Calls.LBL_LAYOUT_TAB_RECURRENCE'  , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Calls.DetailView'   , -1, 'Calls.LBL_REPEAT_TYPE'            , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calendar.LBL_REPEAT_END_AFTER'    , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calendar.LBL_REPEAT_INTERVAL'     , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, 'Calls.LBL_REPEAT_UNTIL'           , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Calls.DetailView'   , -1, '.LBL_LAYOUT_TAB_OTHER'            , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Calls.DetailView'   , -1, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Calls.DetailView'  ,  5, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView'  , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	end -- if;
	-- 03/22/2013 Paul.  Add Recurrence fields. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView' and DATA_FIELD = 'REPEAT_TYPE' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.DetailView'  , -1, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.DetailView'  , -1, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Calls.DetailView'  , -1, 'Calls.LBL_REPEAT_TYPE'            , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView'  , -1, 'Calendar.LBL_REPEAT_END_AFTER'    , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView'  , -1, 'Calendar.LBL_REPEAT_INTERVAL'     , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView'  , -1, 'Calls.LBL_REPEAT_UNTIL'           , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;
	end -- if;
end -- if;
GO

-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Campaigns.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Campaigns.DetailView', 'Campaigns'     , 'vwCAMPAIGNS_Edit'     , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Campaigns.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'               , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_NAME'                     , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                           , '{0}'        , 'campaign_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_START_DATE'      , 'START_DATE'                       , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'                    , '{0}'        , 'campaign_type_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Campaigns.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                        , '{0}'        , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Campaigns.DetailView', -1, 'Campaigns.LBL_LAYOUT_TAB_BUDGET'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Campaigns.DetailView', -1, 'Campaigns.LBL_CURRENCY'                 , 'CURRENCY_ID'                      , '{0}'        , 'Currencies', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_IMPRESSIONS'     , 'IMPRESSIONS'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_BUDGET'          , 'BUDGET_USDOLLAR'                  , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_ACTUAL_COST'     , 'ACTUAL_COST_USDOLLAR'             , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_EXPECTED_REVENUE', 'EXPECTED_REVENUE_USDOLLAR'        , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_EXPECTED_COST'   , 'EXPECTED_COST_USDOLLAR'           , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_OBJECTIVE'       , 'OBJECTIVE'                        , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, 'Campaigns.LBL_CAMPAIGN_CONTENT'         , 'CONTENT'                          , '{0}'        , 3;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Campaigns.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'                  , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Campaigns.DetailView', -1, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Campaigns.DetailView',  4, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                        , '{0}'        , null;

	-- 07/24/2008 Paul.  Use the common term. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_LABEL = 'Campaigns.LBL_ASSIGNED_TO' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Campaigns.DetailView: Use common field label.';
		update DETAILVIEWS_FIELDS
		   set DATA_LABEL       = '.LBL_ASSIGNED_TO'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_LABEL       = 'Campaigns.LBL_ASSIGNED_TO'
		   and DELETED          = 0;
	end -- if;
	-- 07/11/2007 Paul.  Tracker information has been moved to a relationship panel. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_LABEL = 'Campaigns.LBL_TRACKER_URL' and FIELD_INDEX = 22 and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Campaigns.DetailView: Remove tracking.';
		update DETAILVIEWS_FIELDS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_LABEL       in ('Campaigns.LBL_TRACKER_URL', 'Campaigns.LBL_TRACKER_TEXT', 'Campaigns.LBL_REFER_URL', 'Campaigns.LBL_TRACKER_COUNT')
		   and DELETED          = 0;
	end -- if;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'IMPRESSIONS' and DELETED = 0) begin -- then
		print 'Add Impressions to Campaign.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 2
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME  = 'Campaigns.DetailView'
		   and FIELD_INDEX >= 17
		   and DELETED      = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView', 17, 'Campaigns.LBL_CAMPAIGN_IMPRESSIONS'     , 'IMPRESSIONS'                      , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.DetailView', 18, null;
	end -- if;
	-- 12/25/2007 Paul.  The currency values should be in USD so that it will get converted automatically. 	
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'BUDGET' and DELETED = 0) begin -- then
		print 'Convert Campaigns BUDGET to BUDGET_USDOLLAR.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD       = 'BUDGET_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_FIELD       = 'BUDGET'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'ACTUAL_COST' and DELETED = 0) begin -- then
		print 'Convert Campaigns ACTUAL_COST to ACTUAL_COST_USDOLLAR.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD       = 'ACTUAL_COST_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_FIELD       = 'ACTUAL_COST'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'EXPECTED_REVENUE' and DELETED = 0) begin -- then
		print 'Convert Campaigns EXPECTED_REVENUE to EXPECTED_REVENUE_USDOLLAR.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD       = 'EXPECTED_REVENUE_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_FIELD       = 'EXPECTED_REVENUE'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'EXPECTED_COST' and DELETED = 0) begin -- then
		print 'Convert Campaigns EXPECTED_COST to EXPECTED_COST_USDOLLAR.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD       = 'EXPECTED_COST_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.DetailView'
		   and DATA_FIELD       = 'EXPECTED_COST'
		   and DELETED          = 0;
	end -- if;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.DetailView', -1, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 05/06/2006 Paul.  Fix Campaign date format.  Don't show time as it is not important. 
if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'START_DATE' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Campaigns.DetailView: Fix START_DATE formatting.';
	update DETAILVIEWS_FIELDS
	   set DATA_FORMAT      = '{0:d}'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Campaigns.DetailView'
	   and DATA_FIELD       = 'START_DATE'
	   and DATA_FORMAT      = '{0}'
	   and DELETED          = 0;
end -- if;
GO

-- 05/06/2006 Paul.  Fix Campaign date format.  Don't show time as it is not important. 
if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.DetailView' and DATA_FIELD = 'END_DATE' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Campaigns.DetailView: Fix END_DATE formatting.';
	update DETAILVIEWS_FIELDS
	   set DATA_FORMAT      = '{0:d}'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Campaigns.DetailView'
	   and DATA_FIELD       = 'END_DATE'
	   and DATA_FORMAT      = '{0}'
	   and DELETED          = 0;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.RoiDetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.RoiDetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Campaigns.RoiDetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Campaigns.RoiDetailView'     , 'Campaigns'     , 'vwCAMPAIGNS_Roi'     , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  1, 'Campaigns.LBL_NAME'                           , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  2, '.LBL_ASSIGNED_TO'                             , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Campaigns.RoiDetailView',  3, 'Campaigns.LBL_CAMPAIGN_STATUS'                , 'STATUS'                           , '{0}'        , 'campaign_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  4, 'Teams.LBL_TEAM'                               , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  5, 'Campaigns.LBL_CAMPAIGN_START_DATE'            , 'START_DATE'                       , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  6, '.LBL_DATE_MODIFIED'                           , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  7, 'Campaigns.LBL_CAMPAIGN_END_DATE'              , 'END_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView',  8, '.LBL_DATE_ENTERED'                            , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Campaigns.RoiDetailView',  9, 'Campaigns.LBL_CAMPAIGN_TYPE'                  , 'CAMPAIGN_TYPE'                    , '{0}'        , 'campaign_type_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.RoiDetailView', 10, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.RoiDetailView', 11, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.RoiDetailView', 12, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 13, 'Campaigns.LBL_CAMPAIGN_BUDGET'                , 'BUDGET_USDOLLAR'                  , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 14, 'Campaigns.LBL_CAMPAIGN_IMPRESSIONS'           , 'IMPRESSIONS'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 15, 'Campaigns.LBL_CAMPAIGN_EXPECTED_COST'         , 'EXPECTED_COST_USDOLLAR'           , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 16, 'Campaigns.LBL_CAMPAIGN_OPPORTUNITIES_WON'     , 'OPPORTUNITIES_WON'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Campaigns.RoiDetailView', 17, 'Line', null, null, null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 18, 'Campaigns.LBL_CAMPAIGN_ACTUAL_COST'           , 'ACTUAL_COST_USDOLLAR'             , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 19, 'Campaigns.LBL_CAMPAIGN_COST_PER_IMPRESSION'   , 'COST_PER_IMPRESSION'              , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 20, 'Campaigns.LBL_CAMPAIGN_EXPECTED_REVENUE'      , 'EXPECTED_REVENUE_USDOLLAR'        , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Campaigns.RoiDetailView', 21, 'Campaigns.LBL_CAMPAIGN_COST_PER_CLICK_THROUGH', 'COST_PER_CLICK_THROUGH'           , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.RoiDetailView', 22, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Campaigns.RoiDetailView', 23, null;
end else begin
	-- 07/24/2008 Paul.  Use the common term. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Campaigns.RoiDetailView' and DATA_LABEL = 'Campaigns.LBL_ASSIGNED_TO' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Campaigns.RoiDetailView: Use common field label.';
		update DETAILVIEWS_FIELDS
		   set DATA_LABEL       = '.LBL_ASSIGNED_TO'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Campaigns.RoiDetailView'
		   and DATA_LABEL       = 'Campaigns.LBL_ASSIGNED_TO'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 09/15/2006 Paul.  Add Assigned To to Case DetailView.
-- 07/08/2007 Paul.  The CASE_NUMBER field was adde to the edit view a long time ago, but we are just now adding it to the detail view. 
-- 04/02/2012 Paul.  Add TYPE and WORK_LOG. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Cases.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Cases.DetailView'   , 'Cases'         , 'vwCASES_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Cases.DetailView'   , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, 'Cases.LBL_CASE_NUMBER'           , 'CASE_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Cases.DetailView'   , -1, 'Cases.LBL_PRIORITY'              , 'PRIORITY'                         , '{0}'        , 'case_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Cases.DetailView'   , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Cases.DetailView'   , -1, 'Cases.LBL_STATUS'                , 'STATUS'                           , '{0}'        , 'case_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Cases.DetailView'   , -1, 'Cases.LBL_TYPE'                  , 'TYPE'                             , '{0}'        , 'case_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Cases.DetailView'   , -1, 'Cases.LBL_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Cases.DetailView'   , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, 'Cases.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Cases.DetailView'   , -1, 'TextBox', 'Cases.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Cases.DetailView'   , -1, 'TextBox', 'Cases.LBL_RESOLUTION' , 'RESOLUTION' , null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Cases.DetailView'   , -1, 'TextBox', 'Cases.LBL_WORK_LOG'   , 'WORK_LOG'   , null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Cases.DetailView'   , -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Cases.DetailView'   , -1, '.LBL_LAYOUT_TAB_MORE_INFORMATION', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Cases.DetailView'   , -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Cases.DetailView'   , -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Cases.DetailView'  ,  3, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Cases.DetailView'  ,  8, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 07/08/2007 Paul.  Add CASE_NUMBER field to empty slot in original list. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Cases.DetailView'  ,  6, 'Cases.LBL_CASE_NUMBER'            , 'CASE_NUMBER'                      , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView'  , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 02/09/2006 Paul.  SugarCRM uses the CONTACTS_USERS table to allow each user to choose the contacts they want syncd with Outlook. 
-- 03/07/2006 Paul.  IBM DB2 is having trouble ignoring single quotes in comments. 
-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
-- 05/14/2016 Paul.  Add Tags module. 
-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contacts.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Contacts.DetailView', 'Contacts'      , 'vwCONTACTS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Contacts.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_NAME'               , 'FIRST_NAME LAST_NAME'             , '{0} {1}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Contacts.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_DEPARTMENT'         , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Contacts.DetailView', -1, 'Contacts.LBL_ACCOUNT_NAME'       , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_FAX_PHONE'          , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Contacts.DetailView', -1, 'Contacts.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_HOME_PHONE'         , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Contacts.DetailView', -1, 'Contacts.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_OTHER_PHONE'        , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Contacts.DetailView', -1, 'Contacts.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Contacts.DetailView', -1, 'Contacts.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Contacts.DetailView', -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_ALTERNATE_ADDRESS'  , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Contacts.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Contacts.DetailView', -1, 'TextBox', 'Contacts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Contacts.DetailView', -1, '.LBL_LAYOUT_TAB_MORE_INFORMATION', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Contacts.DetailView', -1, 'Contacts.LBL_LEAD_SOURCE'        , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Contacts.DetailView', -1, 'Contacts.LBL_REPORTS_TO'         , 'REPORTS_TO_NAME'                  , '{0}'        , 'REPORTS_TO_ID'       , '~/Contacts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_ASSISTANT'          , 'ASSISTANT'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_ASSISTANT_PHONE'    , 'ASSISTANT_PHONE'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, 'Contacts.LBL_BIRTHDATE'          , 'BIRTHDATE'                        , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Contacts.DetailView', -1, 'Contacts.LBL_SYNC_CONTACT'       , 'SYNC_CONTACT'                     , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Contacts.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Contacts.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Contacts.DetailView', 20, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Contacts.DetailView',  2, '.LBL_LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 08/02/2010 Paul.  Only add the LinkedIn icon if the javascript has been defined. 
	-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
	/*
	if exists(select * from CONFIG where NAME = 'external_scripts' and VALUE like '%linkedin%' and DELETED = 0) begin -- then
		-- 08/16/2010 Paul.  Fix DATA_FIELD to prevent multiple inserts. 
		if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DATA_FIELD = 'ACCOUNT_NAME' and FIELD_TYPE = 'JavaScript' and DELETED = 0) begin -- then
			print 'Contacts.DetailView: Add LinkedIn icon.';
			update DETAILVIEWS_FIELDS
			   set FIELD_INDEX       = FIELD_INDEX + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			 where DETAIL_NAME       = 'Contacts.DetailView'
			   and FIELD_INDEX      >= 5
			   and DELETED           = 0;
			exec dbo.spDETAILVIEWS_FIELDS_InsJavaScript 'Contacts.DetailView',  5, null                              , 'ACCOUNT_NAME'                     , 'ID ACCOUNT_NAME', 'if (typeof(LinkedIn) != "undefined") new LinkedIn.CompanyInsiderPopup("spn{0}_ACCOUNT_NAME","{1}");', 'spn{0}_ACCOUNT_NAME', -1;
		end -- if;
	end -- if;
	*/
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Contacts.DetailView'
		   and FIELD_INDEX      >= 24
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Contacts.DetailView', 24, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Contacts.DetailView', 25, null;
	end -- if;
	-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DATA_FIELD = 'NAME' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD        = 'FIRST_NAME LAST_NAME'
		     , DATA_FORMAT       = '{0} {1}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Contacts.DetailView'
		   and DATA_FIELD        = 'NAME'
		   and DATA_FORMAT       = '{0}' 
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 01/11/2007 Paul.  Fix REPORTS_TO link.  It was point to the Accounts module. 
if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and URL_FIELD = 'REPORTS_TO_ID' and URL_FORMAT = '~/Accounts/view.aspx?ID={0}' and DELETED = 0) begin -- then
	print 'Fixing Contacts.DetailView REPORTS_TO_ID URL_FORMAT';
	update DETAILVIEWS_FIELDS
	   set URL_FORMAT       = '~/Contacts/view.aspx?ID={0}'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Contacts.DetailView'
	   and URL_FIELD        = 'REPORTS_TO_ID'
	   and URL_FORMAT       = '~/Accounts/view.aspx?ID={0}' 
	   and DELETED          = 0;
end -- if;
GO

-- 02/09/2006 Paul.  SugarCRM introduced a Sync Contact checkbox.  For existing systems, replace the blank before Assistant Phone with Sync Contact.
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and DATA_FIELD = 'SYNC_CONTACT' and DELETED = 0) begin -- then
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 16 and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_TYPE       = 'CheckBox'
		     , DATA_LABEL       = 'Contacts.LBL_SYNC_CONTACT'
		     , DATA_FIELD       = 'SYNC_CONTACT'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Contacts.DetailView'
		   and FIELD_TYPE       = 'Blank'
		   and FIELD_INDEX      = 16 
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 05/18/2011 Paul.  We need to allow the user to upload a mail-merge template without the Word plug-in. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents. 
-- 01/22/2013 Paul.  Add PRIMARY_MODULE so that mail merge templates can be uploaded. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Documents.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Documents.DetailView', 'Documents'     , 'vwDOCUMENTS_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Documents.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Documents.DetailView', -1, 'Documents.LBL_DOWNNLOAD_FILE'    , 'FILENAME'                         , '{0}'        , 'DOCUMENT_REVISION_ID'    , '~/Documents/Document.aspx?ID={0}', '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Documents.DetailView', -1, 'Documents.LBL_DOC_STATUS'        , 'STATUS_ID'                        , '{0}'        , 'document_status_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_DOC_NAME'          , 'DOCUMENT_NAME'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_DOC_VERSION'       , 'REVISION'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Documents.DetailView', -1, 'Documents.LBL_TEMPLATE_TYPE'     , 'TEMPLATE_TYPE'                    , '{0}'        , 'document_template_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Documents.DetailView', -1, 'Documents.LBL_IS_TEMPLATE'       , 'IS_TEMPLATE'                      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_DOC_ACTIVE_DATE'   , 'ACTIVE_DATE'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_DOC_EXP_DATE'      , 'EXP_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Documents.DetailView', -1, 'Documents.LBL_CATEGORY_VALUE'    , 'CATEGORY_ID'                      , '{0}'        , 'document_category_dom'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Documents.DetailView', -1, 'Documents.LBL_SUBCATEGORY_VALUE' , 'SUBCATEGORY_ID'                   , '{0}'        , 'document_subcategory_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_LAST_REV_CREATOR'  , 'REVISION_CREATED_BY_NAME'         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Documents.LBL_LAST_REV_DATE'     , 'REVISION_DATE_ENTERED'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Documents.DetailView', -1, 'Documents.LBL_PRIMARY_MODULE'    , 'PRIMARY_MODULE'                   , '{0}'        , 'Modules'                 , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Documents.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Documents.DetailView', -1, 'TextBox', 'Documents.LBL_DOC_DESCRIPTION', 'DESCRIPTION', '10,90', null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Documents.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Documents.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Documents.DetailView',  5, 'Teams.LBL_TEAM'                 , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView', -1, 'Teams.LBL_TEAM'                 , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 05/18/2011 Paul.  We need to allow the user to upload a mail-merge template without the Word plug-in. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView' and DATA_FIELD = 'TEMPLATE_TYPE' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS: Add TEMPLATE_TYPE to Documents.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()     
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Documents.DetailView'
		   and FIELD_INDEX      >= 2
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView',  2, 'Documents.LBL_TEMPLATE_TYPE'    , 'TEMPLATE_TYPE'                    , '{0}'        , 'document_template_type_dom', null;
		exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Documents.DetailView',  3, 'Documents.LBL_IS_TEMPLATE'      , 'IS_TEMPLATE'                      , null;
	end -- if;
	-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView', 15, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                , '{0}'        , null;
	-- 01/22/2013 Paul.  Add PRIMARY_MODULE so that mail merge templates can be uploaded. 
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView', 16, 'Documents.LBL_PRIMARY_MODULE'    , 'PRIMARY_MODULE'                  , '{0}'        , 'Modules'                 , null;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Documents.DetailView'
		   and FIELD_INDEX      >= 12
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Documents.DetailView', 12, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Documents.DetailView', 13, null;
	end -- if;
end -- if;
GO


-- 01/21/2006 Paul.  Attachments are in a separate table. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Emails.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Emails.DetailView'  , 'Emails'        , 'vwEMAILS_Edit'        , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Emails.DetailView'  , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_DATE_SENT'            , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Emails.DetailView'  , -1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_FROM'                 , 'FROM_NAME FROM_ADDR'              , '{0} &lt;{1}&gt;', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_CC'                   , 'CC_ADDRS'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_TO'                   , 'TO_ADDRS'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_BCC'                  , 'BCC_ADDRS'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, 'Emails.LBL_SUBJECT'              , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Emails.DetailView'  , -1, 'TextBox', 'Emails.LBL_BODY'      , 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Emails.DetailView'  , -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Emails.DetailView'  , -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Emails.DetailView'  ,  2, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView'  , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 07/03/2007 Paul.  Display the full sender information. 
if exists (select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView' and DELETED = 0 and DATA_LABEL = 'Emails.LBL_FROM' and DATA_FIELD = 'FROM_NAME') begin -- then
	print 'Fix Email From to include full information.';
	update DETAILVIEWS_FIELDS
	   set DATA_FIELD       = 'FROM_NAME FROM_ADDR'
	     , DATA_FORMAT      = '{0} &lt;{1}&gt;'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'Emails.DetailView'
	   and DELETED          = 0
	   and DATA_LABEL       = 'Emails.LBL_FROM'
	   and DATA_FIELD       = 'FROM_NAME';
end -- if;
GO

-- 01/21/2006 Paul.  Attachments are in a separate table. 
if exists (select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView' and DELETED = 0 and FIELD_INDEX = 12 and DATA_LABEL = 'Emails.LBL_ATTACHMENTS') begin -- then
	delete from DETAILVIEWS_FIELDS
	 where DETAIL_NAME = 'Emails.DetailView'
	   and DELETED     = 0
	   and FIELD_INDEX = 12
	   and DATA_LABEL  = 'Emails.LBL_ATTACHMENTS';
end -- if;
GO

-- 04/21/2006 Paul.  Change BODY to BODY_HTML. 
-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents, EmailTemplates. 
-- 05/13/2020 Paul.  Convert BODY_HTML to TextBox from String to better support React Client. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS EmailTemplates.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'EmailTemplates.DetailView', 'EmailTemplates', 'vwEMAIL_TEMPLATES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'EmailTemplates.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, 'EmailTemplates.LBL_NAME'         , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'EmailTemplates.DetailView', -1, 'TextBox', 'EmailTemplates.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, 'EmailTemplates.LBL_SUBJECT'      , 'SUBJECT'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'EmailTemplates.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'EmailTemplates.DetailView', -1, 'TextBox', 'EmailTemplates.LBL_BODY', 'BODY_HTML', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'EmailTemplates.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'EmailTemplates.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'EmailTemplates.DetailView',  5, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and DATA_FIELD = 'ASSIGNED_TO_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailTemplates.DetailView',  -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	end -- if;
	-- 05/13/2020 Paul.  Convert BODY_HTML to TextBox from string to better support React Client. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and DATA_FIELD = 'BODY_HTML' and FIELD_TYPE = 'String' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_TYPE       = 'TextBox'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'EmailTemplates.DetailView'
		   and DELETED          = 0
		   and DATA_LABEL       = 'EmailTemplates.LBL_BODY'
		   and DATA_FIELD       = 'BODY_HTML'
		   and FIELD_TYPE       = 'String';
	end -- if;
end -- if;
GO

-- 04/21/2006 Paul.  Change BODY to BODY_HTML. 
if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailTemplates.DetailView' and DELETED = 0 and FIELD_INDEX = 6 and DATA_LABEL = 'EmailTemplates.LBL_BODY' and DATA_FIELD = 'BODY') begin -- then
	update DETAILVIEWS_FIELDS
	   set DATA_FIELD       = 'BODY_HTML'
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = null
	 where DETAIL_NAME      = 'EmailTemplates.DetailView'
	   and DELETED          = 0
	   and FIELD_INDEX      = 6
	   and DATA_LABEL       = 'EmailTemplates.LBL_BODY'
	   and DATA_FIELD       = 'BODY';
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Employees.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Employees.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Employees.DetailView'     , 'Employees'     , 'vwEMPLOYEES_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Employees.DetailView',  1, 'Employees.LBL_EMPLOYEE_STATUS'   , 'EMPLOYEE_STATUS'                  , '{0}'        , 'employee_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView',  2, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView',  3, 'Employees.LBL_NAME'              , 'FULL_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView',  4, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView',  5, 'Employees.LBL_TITLE'             , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView',  6, 'Employees.LBL_OFFICE_PHONE'      , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView',  7, 'Employees.LBL_DEPARTMENT'        , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView',  8, 'Employees.LBL_MOBILE_PHONE'      , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView',  9, 'Employees.LBL_REPORTS_TO'        , 'REPORTS_TO_NAME'                  , '{0}'        , 'REPORTS_TO_ID'       , '~/Employees/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView', 10, 'Employees.LBL_OTHER'             , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView', 11, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView', 12, 'Employees.LBL_FAX'               , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView', 13, 'Employees.LBL_EMAIL'             , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView', 14, 'Employees.LBL_HOME_PHONE'        , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Employees.DetailView', 15, 'Employees.LBL_OTHER_EMAIL'       , 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView', 16, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Employees.DetailView', 17, 'Employees.LBL_MESSENGER_TYPE'    , 'MESSENGER_TYPE'                   , '{0}'        , 'messenger_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView', 18, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView', 19, 'Employees.LBL_MESSENGER_ID'      , 'MESSENGER_ID'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView', 20, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Employees.DetailView', 21, 'Employees.LBL_ADDRESS'           , 'ADDRESS_HTML'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Employees.DetailView', 22, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Employees.DetailView', 23, 'TextBox', 'Employees.LBL_NOTES', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO


/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spDETAILVIEWS_FIELDS_Defaults()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_Defaults')
/

Create Procedure dbo.spDETAILVIEWS_FIELDS_Defaults()
language sql
  begin
-- #endif IBM_DB2 */

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'iFrames.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS iFrames.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'iFrames.DetailView'       , 'iFrames'       , 'vwIFRAMES_Edit'       , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'iFrames.DetailView' ,  0, 'iFrames.LBL_NAME'                , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'iFrames.DetailView' ,  1, 'iFrames.LBL_STATUS'              , 'STATUS'                           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'iFrames.DetailView' ,  2, 'iFrames.LBL_URL'                 , 'URL'                              , '{0}'        , 'URL', '{0}', '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'iFrames.DetailView' ,  3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'iFrames.DetailView' ,  4, 'iFrames.LBL_PLACEMENT'           , 'PLACEMENT'                        , '{0}'        , 'DROPDOWN_PLACEMENT', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'iFrames.DetailView' ,  5, 'iFrames.LBL_TYPE'                , 'TYPE'                             , '{0}'        , 'DROPDOWN_TYPE'     , null;
end -- if;
GO

-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
-- 04/02/2012 Paul.  Add WEBSITE. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Leads.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Leads.DetailView'   , 'Leads'         , 'vwLEADS_Edit'         , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Leads.DetailView'   , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_NAME'                   , 'FIRST_NAME LAST_NAME'             , '{0} {1}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Leads.DetailView'   , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_TITLE'                  , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_OFFICE_PHONE'           , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_DEPARTMENT'             , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_MOBILE_PHONE'           , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Leads.DetailView'   , -1, 'Leads.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_FAX_PHONE'              , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Leads.DetailView'   , -1, 'Leads.LBL_EMAIL_ADDRESS'          , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_HOME_PHONE'             , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Leads.DetailView'   , -1, 'Leads.LBL_OTHER_EMAIL_ADDRESS'    , 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_OTHER_PHONE'            , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Leads.DetailView'   , -1, 'Leads.LBL_EMAIL_OPT_OUT'          , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Leads.DetailView'   , -1, 'Leads.LBL_DO_NOT_CALL'            , 'DO_NOT_CALL'                      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Leads.DetailView'   , -1, 'Accounts.LBL_WEBSITE'             , 'WEBSITE'                          , '{0}'        , 'WEBSITE', '{0}', '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Leads.DetailView'   , -1, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Leads.DetailView'   , -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_PRIMARY_ADDRESS'        , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_ALTERNATE_ADDRESS'      , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Leads.DetailView'   , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Leads.DetailView'   , -1, 'TextBox', 'Leads.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Leads.DetailView'   , -1, '.LBL_LAYOUT_TAB_MORE_INFORMATION', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Leads.DetailView'   , -1, 'Leads.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'lead_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Leads.DetailView'   , -1, 'Leads.LBL_LEAD_SOURCE'            , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_STATUS_DESCRIPTION'     , 'STATUS_DESCRIPTION'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_LEAD_SOURCE_DESCRIPTION', 'LEAD_SOURCE_DESCRIPTION'          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, 'Leads.LBL_REFERED_BY'             , 'REFERED_BY'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Leads.DetailView'   , -1, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Leads.DetailView'   , -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Leads.DetailView'   , -1, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

--	exec dbo.spDETAILVIEWS_FIELDS_InsButton     'Leads.DetailView'   , 10, null                               , '.LBL_VCARD'                       , 'vCard'      , null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Leads.DetailView'   , 22, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Leads.DetailView'   , 10, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView'   , -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 08/02/2010 Paul.  Only add the LinkedIn icon if the javascript has been defined. 
	-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
	/*
	if exists(select * from CONFIG where NAME = 'external_scripts' and VALUE like '%linkedin%' and DELETED = 0) begin -- then
		-- 08/16/2010 Paul.  Fix DATA_FIELD to prevent multiple inserts. 
		if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DATA_FIELD = 'ACCOUNT_NAME' and FIELD_TYPE = 'JavaScript' and DELETED = 0) begin -- then
			print 'Leads.DetailView: Add LinkedIn icon.';
			update DETAILVIEWS_FIELDS
			   set FIELD_INDEX       = FIELD_INDEX + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			 where DETAIL_NAME       = 'Leads.DetailView'
			   and FIELD_INDEX      >= 1
			   and DELETED           = 0;
			exec dbo.spDETAILVIEWS_FIELDS_InsJavaScript 'Leads.DetailView'   , 13, null                               , 'ACCOUNT_NAME'                     , 'ID ACCOUNT_NAME', 'if (typeof(LinkedIn) != "undefined") new LinkedIn.CompanyInsiderPopup("spn{0}_ACCOUNT_NAME","{1}");', 'spn{0}_ACCOUNT_NAME', -1;
		end -- if;
	end -- if;
	*/
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DATA_FIELD = 'WEBSITE' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Leads.DetailView'   , -1, 'Accounts.LBL_WEBSITE'             , 'WEBSITE'                          , '{0}'        , 'WEBSITE', '{0}', '_blank', null;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Leads.DetailView'
		   and FIELD_INDEX      >= 26
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Leads.DetailView', 26, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Leads.DetailView', 27, null;
	end -- if;
	-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView' and DATA_FIELD = 'NAME' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD        = 'FIRST_NAME LAST_NAME'
		     , DATA_FORMAT       = '{0} {1}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Leads.DetailView'
		   and DATA_FIELD        = 'NAME'
		   and DATA_FORMAT       = '{0}' 
		   and DELETED           = 0;
	end -- if;
end -- if;
GO


/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spDETAILVIEWS_FIELDS_Defaults()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_Defaults')
/

Create Procedure dbo.spDETAILVIEWS_FIELDS_Defaults()
language sql
  begin
-- #endif IBM_DB2 */


-- 03/22/2013 Paul.  Add Recurrence fields. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Meetings.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Meetings.DetailView', 'Meetings'      , 'vwMEETINGS_Edit'      , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Meetings.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Meetings.LBL_SUBJECT'             , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Meetings.DetailView', -1, 'Meetings.LBL_STATUS'              , 'STATUS'                                                                       , '{0}'            , 'meeting_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Meetings.LBL_DATE_TIME'           , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Meetings.LBL_LOCATION'            , 'LOCATION'                                                                     , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Meetings.LBL_DURATION'            , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Meetings.DetailView', -1, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Meetings.DetailView', -1, 'TextBox', 'Meetings.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Meetings.DetailView', -1, 'Meetings.LBL_LAYOUT_TAB_RECURRENCE', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Meetings.DetailView', -1, 'Calls.LBL_REPEAT_TYPE'            , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Calendar.LBL_REPEAT_END_AFTER'    , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Calendar.LBL_REPEAT_INTERVAL'     , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, 'Calls.LBL_REPEAT_UNTIL'           , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Meetings.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'            , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Meetings.DetailView', -1, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Meetings.DetailView',  6, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView', -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	end -- if;
	-- 03/22/2013 Paul.  Add Recurrence fields. 
	-- 12/06/2021 Paul.  This set of corrections should have been for Meetings as Calls already handled above. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView' and DATA_FIELD = 'REPEAT_TYPE' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Meetings.DetailView'  , -1, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Meetings.DetailView'  , -1, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Meetings.DetailView'  , -1, 'Meetings.LBL_REPEAT_TYPE'         , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView'  , -1, 'Calendar.LBL_REPEAT_END_AFTER'    , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView'  , -1, 'Calendar.LBL_REPEAT_INTERVAL'     , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView'  , -1, 'Meetings.LBL_REPEAT_UNTIL'        , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;
	end -- if;
end -- if;
GO

-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID to Notes, Documents. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Notes.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Notes.DetailView'         , 'Notes'         , 'vwNOTES_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Notes.DetailView'   , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, 'Notes.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Notes.DetailView'   , -1, 'Notes.LBL_FILENAME'              , 'FILENAME'                         , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Notes.DetailView'   , -1, 'Notes.LBL_CONTACT_NAME'          , 'CONTACT_NAME'                     , '{0}'        , 'CONTACT_ID'        , '~/Contacts/view.aspx?ID={0}'   , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Notes.DetailView'   , -1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, 'Notes.LBL_PHONE'                 , 'CONTACT_PHONE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Notes.DetailView'   , -1, 'Notes.LBL_EMAIL_ADDRESS'         , 'CONTACT_EMAIL'                    , '{0}'        , 'CONTACT_EMAIL'     , 'mailto:{0}'                    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Notes.DetailView'   , -1, 'TextBox', 'Notes.LBL_NOTE'       , 'DESCRIPTION', '30,90', null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Notes.DetailView'   , -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Notes.DetailView'   , -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	-- 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Notes.DetailView'   ,  7, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Notes.DetailView'   ,  6, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView'   , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 07/22/2010 Paul.  Add Campaign Popup to Opportunities. 
-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Opportunities.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Opportunities.DetailView', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Opportunities.DetailView', -1, '.LBL_LAYOUT_TAB_BASIC'             , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Opportunities.LBL_OPPORTUNITY_NAME', 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Opportunities.DetailView', -1, 'Opportunities.LBL_ACCOUNT_NAME'    , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'          , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Opportunities.LBL_AMOUNT'          , 'AMOUNT_USDOLLAR'                  , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Opportunities.LBL_DATE_CLOSED'     , 'DATE_CLOSED'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Opportunities.DetailView', -1, 'Opportunities.LBL_SALES_STAGE'     , 'SALES_STAGE'                      , '{0}'        , 'sales_stage_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Opportunities.DetailView', -1, 'Opportunities.LBL_TYPE'            , 'OPPORTUNITY_TYPE'                 , '{0}'        , 'opportunity_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Opportunities.LBL_PROBABILITY'     , 'PROBABILITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Opportunities.DetailView', -1, 'Opportunities.LBL_LEAD_SOURCE'     , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Opportunities.LBL_NEXT_STEP'       , 'NEXT_STEP'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Opportunities.DetailView', -1, 'Opportunities.LBL_CAMPAIGN_NAME'   , 'CAMPAIGN_NAME'                    , '{0}'        , 'CAMPAIGN_ID'         , '~/Campaigns/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Opportunities.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Opportunities.DetailView', -1, 'Opportunities.LBL_LEAD_NAME'       , 'LEAD_NAME'                        , '{0}'        , 'LEAD_ID'             , '~/Leads/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Opportunities.DetailView', -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, '.LBL_ASSIGNED_TO'                  , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, '.LBL_LAST_ACTIVITY_DATE'           , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Opportunities.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Opportunities.DetailView', -1, 'TextBox', 'Opportunities.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Opportunities.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'             , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, '.LBL_DATE_ENTERED'                 , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Opportunities.DetailView', -1, '.LBL_DATE_MODIFIED'                , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

--	exec dbo.spDETAILVIEWS_FIELDS_InsJavaScript 'Opportunities.DetailView',  3, null                                , 'ACCOUNT_NAME'                     , 'ID ACCOUNT_NAME', 'if (typeof(LinkedIn) != "undefined") new LinkedIn.CompanyInsiderPopup("spn{0}_ACCOUNT_NAME","{1}");', 'spn{0}_ACCOUNT_NAME', -1;
end else begin
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Opportunities.DetailView',  8, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound      'Opportunities.DetailView', 12, '.LBL_LAST_ACTIVITY_DATE'           , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 12/25/2007 Paul.  The amount should be AMOUNT_USDOLLAR so that it will get converted automatically. 	
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'AMOUNT' and DELETED = 0) begin -- then
		print 'Convert Opportunities AMOUNT to AMOUNT_USDOLLAR.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD       = 'AMOUNT_USDOLLAR'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Opportunities.DetailView'
		   and DATA_FIELD       = 'AMOUNT'
		   and DELETED          = 0;
	end -- if;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView', -1, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 07/22/2010 Paul.  Add Campaign Popup. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'CAMPAIGN_NAME' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS: Add Campaign to Opportunities.';
		if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 12 and DELETED = 0) begin -- then
			update DETAILVIEWS_FIELDS
			   set DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			     , DELETED           = 1
			 where DETAIL_NAME       = 'Opportunities.DetailView'
			   and FIELD_TYPE        = 'Blank'
			   and FIELD_INDEX       = 12
			   and DELETED           = 0;
		end else begin
			update DETAILVIEWS_FIELDS
			   set FIELD_INDEX       = FIELD_INDEX + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			 where DETAIL_NAME       = 'Opportunities.DetailView'
			   and FIELD_INDEX      >= 12
			   and DELETED           = 0;
		end -- if;
		exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.DetailView', 12, 'Opportunities.LBL_CAMPAIGN_NAME'   , 'CAMPAIGN_NAME'                    , '{0}'        , 'CAMPAIGN_ID'         , '~/Campaigns/view.aspx?ID={0}', null, null;
	end -- if;
	-- 08/02/2010 Paul.  Only add the LinkedIn icon if the javascript has been defined. 
	-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
	/*
	if exists(select * from CONFIG where NAME = 'external_scripts' and VALUE like '%linkedin%' and DELETED = 0) begin -- then
		-- 08/16/2010 Paul.  Fix DATA_FIELD to prevent multiple inserts. 
		if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'ACCOUNT_NAME' and FIELD_TYPE = 'JavaScript' and DELETED = 0) begin -- then
			print 'Opportunities.DetailView: Add LinkedIn icon.';
			update DETAILVIEWS_FIELDS
			   set FIELD_INDEX       = FIELD_INDEX + 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()     
			     , MODIFIED_USER_ID  = null
			 where DETAIL_NAME       = 'Opportunities.DetailView'
			   and FIELD_INDEX      >= 3
			   and DELETED           = 0;
			exec dbo.spDETAILVIEWS_FIELDS_InsJavaScript 'Opportunities.DetailView',  3, null                                , 'ACCOUNT_NAME'                     , 'ID ACCOUNT_NAME', 'if (typeof(LinkedIn) != "undefined") new LinkedIn.CompanyInsiderPopup("spn{0}_ACCOUNT_NAME","{1}");', 'spn{0}_ACCOUNT_NAME', -1;
		end -- if;
	end -- if;
	*/
	-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'LEAD_NAME' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS: Add Leads to Opportunities.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()     
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Opportunities.DetailView'
		   and FIELD_INDEX      >= 3
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Opportunities.DetailView',  3, 'Opportunities.LBL_LEAD_NAME'       , 'LEAD_NAME'                        , '{0}'        , 'LEAD_ID'             , '~/Leads/view.aspx?ID={0}', null, null;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Opportunities.DetailView'
		   and FIELD_INDEX      >= 16
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Opportunities.DetailView', 16, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Opportunities.DetailView', 17, null;
	end -- if;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- 01/13/2010 Paul.  SugarCRM nolonger displayes the effort fields. 
-- 12/09/2010 Paul.  Need to fix STATUS and PRIORITY. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Project.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Project.DetailView' , 'Project'       , 'vwPROJECTS_Edit'      , '20%', '20%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Project.DetailView' , -1, '.LBL_LAYOUT_TAB_OVERVIEW'            , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, 'Project.LBL_NAME'                    , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Project.DetailView' , -1, 'ProjectTask.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'project_status_dom'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, 'ProjectTask.LBL_ESTIMATED_START_DATE', 'ESTIMATED_START_DATE'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Project.DetailView' , -1, 'ProjectTask.LBL_PRIORITY'            , 'PRIORITY'                         , '{0}'        , 'projects_priority_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, 'ProjectTask.LBL_ESTIMATED_END_DATE'  , 'ESTIMATED_END_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Project.DetailView' , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, '.LBL_LAST_ACTIVITY_DATE'             , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Project.DetailView' , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Project.DetailView' , -1, 'TextBox', 'Project.LBL_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Project.DetailView' , -1, '.LBL_LAYOUT_TAB_OTHER'               , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, '.LBL_DATE_ENTERED'                   , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Project.DetailView' , -1, '.LBL_DATE_MODIFIED'                  , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	--exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Project.DetailView',  1, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Project.DetailView',  1, '.LBL_LAST_ACTIVITY_DATE'             , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Project.DetailView: Add start date and end date.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 4
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME  = 'Project.DetailView'
		   and FIELD_INDEX >= 2
		   and DELETED      = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView',  2, 'ProjectTask.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'projects_priority_options', null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView',  3, 'ProjectTask.LBL_PRIORITY'            , 'PRIORITY'                         , '{0}'        , 'project_status_dom'       , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView',  4, 'ProjectTask.LBL_ESTIMATED_START_DATE', 'ESTIMATED_START_DATE'             , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView',  5, 'ProjectTask.LBL_ESTIMATED_END_DATE'  , 'ESTIMATED_END_DATE'               , '{0}'        , null;
	end -- if;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView', -1, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 12/09/2010 Paul.  Need to fix STATUS and PRIORITY. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DATA_FIELD = 'STATUS' and LIST_NAME = 'projects_priority_options' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Project.DetailView: Fix STATUS list.';
		update DETAILVIEWS_FIELDS
		   set LIST_NAME         = 'project_status_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Project.DetailView'
		   and DATA_FIELD        = 'STATUS'
		   and LIST_NAME         = 'projects_priority_options'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DATA_FIELD = 'PRIORITY' and LIST_NAME = 'project_status_dom' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS Project.DetailView: Fix STATUS list.';
		update DETAILVIEWS_FIELDS
		   set LIST_NAME         = 'projects_priority_options'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Project.DetailView'
		   and DATA_FIELD        = 'PRIORITY'
		   and LIST_NAME         = 'project_status_dom'
		   and DELETED           = 0;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Project.DetailView'
		   and FIELD_INDEX      >= 8
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Project.DetailView',  8, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Project.DetailView',  9, null;
	end -- if;
end -- if;
GO

-- 01/19/2010 Paul.  Now that ESTIMATED_EFFORT is a float, we need to format the value. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProjectTask.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'ProjectTask.DetailView', 'ProjectTask'   , 'vwPROJECT_TASKS_Edit' , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'ProjectTask.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'Project.LBL_NAME'                , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'ProjectTask.DetailView', -1, 'ProjectTask.LBL_STATUS'          , 'STATUS'                           , '{0}'        , 'project_task_status_options'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_DATE_START'      , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_DATE_DUE'        , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'ProjectTask.DetailView', -1, 'ProjectTask.LBL_PRIORITY'        , 'PRIORITY'                         , '{0}'        , 'project_task_priority_options'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_PERCENT_COMPLETE', 'PERCENT_COMPLETE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'ProjectTask.DetailView', -1, 'ProjectTask.LBL_PARENT_ID'       , 'PROJECT_NAME'                     , '{0}'        , 'PROJECT_ID'                      , '~/Projects/view.aspx?ID={0}'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_TASK_NUMBER'     , 'TASK_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'ProjectTask.DetailView', -1, 'TextBox', 'ProjectTask.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'ProjectTask.DetailView', -1, 'ProjectTask.LBL_LAYOUT_TAB_TIMELINE', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_ESTIMATED_EFFORT', 'ESTIMATED_EFFORT'                 , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_ACTUAL_EFFORT'   , 'ACTUAL_EFFORT'                    , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, 'ProjectTask.LBL_ORDER_NUMBER'    , 'ORDER_NUMBER'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'ProjectTask.DetailView', -1, 'ProjectTask.LBL_MILESTONE_FLAG'  , 'MILESTONE_FLAG'                   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'ProjectTask.DetailView', -1, 'ProjectTask.LBL_UTILIZATION'     , 'UTILIZATION'                      , '{0}'        , 'project_task_utilization_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'ProjectTask.DetailView', -1, 'ProjectTask.LBL_DEPENDS_ON_ID'   , 'DEPENDS_ON_NAME'                  , '{0}'        , 'DEPENDS_ON_ID'                   , '~/ProjectTasks/view.aspx?ID={0}', null, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'ProjectTask.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProjectTask.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'ProjectTask.DetailView',  3, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView' and DATA_FIELD = 'ESTIMATED_EFFORT' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS ProjectTask.DetailView: ESTIMATED_EFFORT format F1';
		update DETAILVIEWS_FIELDS
		   set DATA_FORMAT      = '{0:f1}'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'ProjectTask.DetailView'
		   and DATA_FIELD       = 'ESTIMATED_EFFORT'
		   and DATA_FORMAT      = '{0}'
		   and DELETED          = 0;
	end -- if;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView' and DATA_FIELD = 'ACTUAL_EFFORT' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS ProjectTask.DetailView: ACTUAL_EFFORT format F1';
		update DETAILVIEWS_FIELDS
		   set DATA_FORMAT      = '{0:f1}'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'ProjectTask.DetailView'
		   and DATA_FIELD       = 'ACTUAL_EFFORT'
		   and DATA_FORMAT      = '{0}'
		   and DELETED          = 0;
	end -- if;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 08/12/2007 Paul.  Add List Type and Domain Name to support Campaign management.
-- 05/14/2016 Paul.  Add Tags module. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProspectLists.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'ProspectLists.DetailView', 'ProspectLists' , 'vwPROSPECT_LISTS_Edit', '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'ProspectLists.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, 'ProspectLists.LBL_NAME'          , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'ProspectLists.DetailView', -1, 'ProspectLists.LBL_DYNAMIC_LIST'  , 'DYNAMIC_LIST'                     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'ProspectLists.DetailView', -1, 'ProspectLists.LBL_LIST_TYPE'     , 'LIST_TYPE'                        , '{0}'        , 'prospect_list_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, 'ProspectLists.LBL_DOMAIN_NAME'   , 'DOMAIN_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'ProspectLists.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'ProspectLists.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'ProspectLists.DetailView', -1, 'TextBox', 'ProspectLists.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'ProspectLists.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'ProspectLists.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	-- 08/12/2007 Paul.  Keep index at 3 as it refers to a value before List Type was added. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'ProspectLists.DetailView',  3, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
		print 'DETAILVIEWS_FIELDS ProspectLists.DetailView: Add DYNAMIC_LIST';
		update DETAILVIEWS_FIELDS
		   set DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		     , DELETED          = 1
		 where DETAIL_NAME      = 'ProspectLists.DetailView'
		   and FIELD_TYPE       = 'Blank'
		   and FIELD_INDEX      = 1
		   and DELETED          = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'ProspectLists.DetailView',  1, 'ProspectLists.LBL_DYNAMIC_LIST'      , 'DYNAMIC_LIST'                     , null;
	end -- if;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView', -1, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'ProspectLists.DetailView'
		   and FIELD_INDEX      >= 10
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags      'ProspectLists.DetailView', 10, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'ProspectLists.DetailView', 11, null;
	end -- if;
end -- if;
GO

-- 08/12/2007 Paul.  Add List Type and Domain Name to support Campaign management.
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProspectLists.DetailView' and DATA_FIELD = 'LIST_TYPE' and DELETED = 0) begin -- then
	print 'Add List Type to Prospect List.';
	update DETAILVIEWS_FIELDS
	   set FIELD_INDEX  = FIELD_INDEX + 2
	 where DETAIL_NAME  = 'ProspectLists.DetailView'
	   and FIELD_INDEX >= 2
	   and DELETED      = 0;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProspectLists.DetailView',  2, 'ProspectLists.LBL_LIST_TYPE'         , 'LIST_TYPE'                        , '{0}'        , 'prospect_list_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProspectLists.DetailView',  3, 'ProspectLists.LBL_DOMAIN_NAME'       , 'DOMAIN_NAME'                      , '{0}'        , null;
end -- if;
GO

-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 05/14/2016 Paul.  Add Tags module. 
-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Prospects.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Prospects.DetailView', 'Prospects'     , 'vwPROSPECTS_Edit'     , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Prospects.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_NAME'               , 'FIRST_NAME LAST_NAME'             , '{0} {1}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Prospects.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_DEPARTMENT'         , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Prospects.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_FAX_PHONE'          , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Prospects.DetailView', -1, 'Prospects.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_HOME_PHONE'         , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Prospects.DetailView', -1, 'Prospects.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_OTHER_PHONE'        , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Prospects.DetailView', -1, 'Prospects.LBL_EMAIL_OPT_OUT'      , 'EMAIL_OPT_OUT'                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   'Prospects.DetailView', -1, 'Prospects.LBL_DO_NOT_CALL'        , 'DO_NOT_CALL'                      , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsSeparator  'Prospects.DetailView', -1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_ALTERNATE_ADDRESS'  , 'ALT_ADDRESS_HTML'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Prospects.DetailView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Prospects.DetailView', -1, 'TextBox', 'Prospects.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Prospects.DetailView', -1, '.LBL_LAYOUT_TAB_MORE_INFORMATION', 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_ASSISTANT'          , 'ASSISTANT'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_ASSISTANT_PHONE'    , 'ASSISTANT_PHONE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, 'Prospects.LBL_BIRTHDATE'          , 'BIRTHDATE'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Prospects.DetailView', -1, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Prospects.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, '.LBL_DATE_ENTERED'                , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Prospects.DetailView', -1, '.LBL_DATE_MODIFIED'               , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Prospects.DetailView', 22, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Prospects.DetailView',  2, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView', -1, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
	-- 05/14/2016 Paul.  Add Tags module. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView' and DATA_FIELD = 'TAG_SET_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX       = FIELD_INDEX + 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Prospects.DetailView'
		   and FIELD_INDEX      >= 28
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsTags       'Prospects.DetailView', 28, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Prospects.DetailView', 29, null;
	end -- if;
	-- 06/30/2018 Paul.  Separate NAME into FIRST_NAME LAST_NAME so that either can be erased. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView' and DATA_FIELD = 'NAME' and DATA_FORMAT = '{0}' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD        = 'FIRST_NAME LAST_NAME'
		     , DATA_FORMAT       = '{0} {1}'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where DETAIL_NAME       = 'Prospects.DetailView'
		   and DATA_FIELD        = 'NAME'
		   and DATA_FORMAT       = '{0}' 
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Tasks.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'Tasks.DetailView'         , 'Tasks'         , 'vwTASKS_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Tasks.DetailView'   , -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Tasks.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Tasks.DetailView'   , -1, 'Tasks.LBL_STATUS'                , 'STATUS'                           , '{0}'        , 'task_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Tasks.LBL_START_DATE_AND_TIME'   , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Tasks.DetailView'   , -1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'        , '~/Parents/view.aspx?ID={0}' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Tasks.LBL_DUE_DATE_AND_TIME'     , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'Tasks.DetailView'   , -1, 'Tasks.LBL_CONTACT'               , 'CONTACT_NAME'                     , '{0}'        , 'CONTACT_ID'       , '~/Contacts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'Tasks.DetailView'   , -1, 'Tasks.LBL_PRIORITY'              , 'PRIORITY'                         , '{0}'        , 'task_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Tasks.LBL_EMAIL'                 , 'CONTACT_EMAIL'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      'Tasks.DetailView'   , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Tasks.LBL_PHONE'                 , 'CONTACT_PHONE'                    , '{0}'        , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    'Tasks.DetailView'   , -1, 'TextBox', 'Tasks.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'Tasks.DetailView'   , -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'Tasks.DetailView'   , -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;

end else if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView' and FIELD_TYPE = 'Header' and DATA_LABEL = '.LBL_LAYOUT_TAB_OVERVIEW' and DELETED = 0) begin -- then
	-- 04/20/2022 Paul.  The following maintenance does not apply if this was a new Pacific layout. 

	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Tasks.DetailView'   ,  8, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	-- 02/24/2010 Paul.  When upgrading from and old version, the Team ID will not exist. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView' and DATA_FIELD = 'TEAM_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView'   , -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 09/04/2006 Paul.  Remove from EMAIL and OTHER_EMAIL.  This data goes in the EmailOptions panel. 
-- 08/24/2013 Paul.  Add EXTENSION_C in preparation for Asterisk click-to-call. 
-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
-- 01/04/2018 Paul.  Change to Employees.LBL_REPORTS_TO. 
-- 10/29/2020 Paul.  Change to Users.LBL_REPORTS_TO as the Employees module may be disabled. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Users.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Users.DetailView'         , 'Users'         , 'vwUSERS_Edit'         , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Users.DetailView'   ,  1, 'Users.LBL_EMPLOYEE_STATUS'       , 'EMPLOYEE_STATUS'                  , '{0}'        , 'employee_status_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.DetailView'   ,  2, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  3, 'Users.LBL_TITLE'                 , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  4, 'Users.LBL_OFFICE_PHONE'          , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  5, 'Users.LBL_DEPARTMENT'            , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  6, 'Users.LBL_MOBILE_PHONE'          , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Users.DetailView'   ,  7, 'Users.LBL_REPORTS_TO'            , 'REPORTS_TO_NAME'                  , '{0}'        , 'REPORTS_TO_ID'       , '~/Users/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  8, 'Users.LBL_OTHER'                 , 'PHONE_OTHER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   ,  9, 'Users.LBL_EXTENSION'             , 'EXTENSION'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   , 10, 'Users.LBL_FAX'                   , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   , 11, 'Users.LBL_FACEBOOK_ID'           , 'FACEBOOK_ID'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   , 12, 'Users.LBL_HOME_PHONE'            , 'PHONE_HOME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Users.DetailView'   , 13, 'Users.LBL_MESSENGER_TYPE'        , 'MESSENGER_TYPE'                   , '{0}'        , 'messenger_type_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.DetailView'   , 14, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   , 15, 'Users.LBL_MESSENGER_ID'          , 'MESSENGER_ID'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.DetailView'   , 16, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.DetailView'   , 17, 'Users.LBL_ADDRESS'               , 'ADDRESS_HTML'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.DetailView'   , 18, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Users.DetailView'   , 19, 'TextBox', 'Users.LBL_NOTES', 'DESCRIPTION', null, null, null, null, null, 3, null;
end else begin
	-- 01/21/2008 Paul.  Some older systems still have EMAIL1 and EMAIL2 in the main. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD in ('EMAIL1', 'EMAIL2') and DELETED = 0) begin -- then
		print 'Remove EMAIL1 and EMAIL2 from Users Main panel.';
		update DETAILVIEWS_FIELDS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Users.DetailView'
		   and DATA_FIELD       in ('EMAIL1', 'EMAIL2')
		   and DELETED          = 0;
	end -- if;
	-- 08/24/2013 Paul.  Add EXTENSION_C in preparation for Asterisk click-to-call. 
	-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD = 'EXTENSION_C' and DELETED = 0) begin -- then
		-- 01/21/2018 Paul.  If there already exists an EXTENSION field, then convert to blank. 
		if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD = 'EXTENSION' and DELETED = 0) begin -- then
			update DETAILVIEWS_FIELDS
			   set FIELD_TYPE       = 'Blank'
			     , DATA_FIELD       = null
			     , DATA_LABEL       = null
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			     , MODIFIED_USER_ID = null
			 where DETAIL_NAME      = 'Users.DetailView'
			   and DATA_FIELD       = 'EXTENSION_C'
			   and DELETED          = 0;
		end else begin
			update DETAILVIEWS_FIELDS
			   set DATA_FIELD       = 'EXTENSION'
			     , DATA_LABEL       = 'Users.LBL_EXTENSION'
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			     , MODIFIED_USER_ID = null
			 where DETAIL_NAME      = 'Users.DetailView'
			   and DATA_FIELD       = 'EXTENSION_C'
			   and DELETED          = 0;
		end -- if;
	end -- if;
	-- 01/17/2018 Paul.  We noticed multiple EXTENSION records, so check and fix. 
	if exists(select count(*) from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD = 'EXTENSION' and DEFAULT_VIEW = 0 and DELETED = 0 group by DETAIL_NAME, DATA_FIELD having count(*) > 1) begin -- then
		print 'Users.DetailView: Multiple EXTENSION fields encountered. ';
		update DETAILVIEWS_FIELDS
		   set FIELD_TYPE       = 'Blank'
		     , DATA_FIELD       = null
		     , DATA_LABEL       = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Users.DetailView'
		   and DATA_FIELD       = 'EXTENSION'
		   and DELETED          = 0;
	end -- if;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD = 'EXTENSION' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Users.DetailView'  ,  9, 'Users.LBL_EXTENSION'              , 'EXTENSION'                        , '{0}'        , null;
	end -- if;
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Users.DetailView'  , 11, 'Users.LBL_FACEBOOK_ID'            , 'FACEBOOK_ID'                      , '{0}'        , null;
	-- 01/04/2018 Paul.  Change to Employees.LBL_REPORTS_TO. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.DetailView' and DATA_FIELD = 'REPORTS_TO_NAME' and DATA_LABEL in ('Contacts.LBL_REPORTS_TO', 'Users.LBL_REPORTS_TO') and DELETED = 0) begin -- then
		-- 02/03/2018 Paul.  This is where the EXTENSION duplicate field problem was re-created. 
		update DETAILVIEWS_FIELDS
		   set DATA_LABEL       = 'Employees.LBL_REPORTS_TO'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Users.DetailView'
		   and DATA_FIELD       = 'REPORTS_TO_NAME'
		   and DATA_LABEL       in ('Contacts.LBL_REPORTS_TO', 'Users.LBL_REPORTS_TO')
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 08/05/2006 Paul.  Convert MailOptions to a dynamic view so that fields can be easily removed. 
-- 08/05/2006 Paul.  SplendidCRM does not support anything other than the build-in .NET mail.
-- 01/20/2008 Paul.  Add EMAIL1 so that users can be the target of a campaign. 
-- 07/09/2010 Paul.  Remove MAIL_FROMNAME and MAIL_FROMADDRESS. 
-- 12/15/2012 Paul.  Remove MAIL_FROMNAME and MAIL_FROMADDRESS from creation section. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.MailOptions';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.MailOptions' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Users.MailOptions';
	exec dbo.spDETAILVIEWS_InsertOnly          'Users.MailOptions', 'Users', 'vwUSERS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  1, 'Users.LBL_EMAIL'                 , 'EMAIL1'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  2, 'Users.LBL_OTHER_EMAIL'           , 'EMAIL2'                           , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  3, 'Users.LBL_MAIL_FROMNAME'         , 'MAIL_FROMNAME'                    , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  4, 'Users.LBL_MAIL_FROMADDRESS'      , 'MAIL_FROMADDRESS'                 , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Users.MailOptions'  ,  5, 'Users.LBL_MAIL_SENDTYPE'         , 'MAIL_SENDTYPE'                    , '{0}'        , 'notifymail_sendtype'  , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.MailOptions'  ,  6, null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  7, 'Users.LBL_MAIL_SMTPSERVER'       , 'MAIL_SMTPSERVER'                  , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  8, 'Users.LBL_MAIL_SMTPPORT'         , 'MAIL_SMTPPORT'                    , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  9, 'Users.LBL_MAIL_SMTPAUTH_REQ'     , 'MAIL_SMTPAUTH_REQ'                , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Users.MailOptions'  , 10, null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  , 11, 'Users.LBL_MAIL_SMTPUSER'         , 'MAIL_SMTPUSER'                    , '{0}'        , null;
--	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  , 12, 'Users.LBL_MAIL_SMTPPASS'         , 'MAIL_SMTPPASS'                    , '******'     , null;
end else begin
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.MailOptions' and DATA_FIELD = 'EMAIL1' and DELETED = 0) begin -- then
		print 'Add EMAIL1 to Users.';
		update DETAILVIEWS_FIELDS
		   set FIELD_INDEX      = FIELD_INDEX + 2
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Users.MailOptions'
		   and FIELD_INDEX     >= 1
		   and DELETED          = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  1, 'Users.LBL_EMAIL'                 , 'EMAIL1'                           , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Users.MailOptions'  ,  2, 'Users.LBL_OTHER_EMAIL'           , 'EMAIL2'                           , '{0}'        , null;
	end -- if;
	-- 07/09/2010 Paul.  Remove MAIL_FROMNAME and MAIL_FROMADDRESS.
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Users.MailOptions' and DATA_FIELD in ('MAIL_FROMNAME', 'MAIL_FROMADDRESS') and DELETED = 0) begin -- then
		print 'Remove MAIL_FROMNAME and MAIL_FROMADDRESS.';
		update DETAILVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Users.MailOptions'
		   and DATA_FIELD        in ('MAIL_FROMNAME', 'MAIL_FROMADDRESS')
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 12/10/2007 Paul.  Removed references to TestCases, TestPlans and TestRuns.


if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ACLRoles.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ACLRoles.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ACLRoles.DetailView', 'ACLRoles', 'vwACL_ROLES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ACLRoles.DetailView' ,  0, 'ACLRoles.LBL_NAME'              , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'ACLRoles.DetailView' ,  1, 'TextBox', 'ACLRoles.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- 07/07/2007 Paul.  Convert to TextBox to take advantage of new code that converts \r\n to <br />.
-- 05/14/2016 Paul.  This is old but still valid for upgrades.  Reduce usage by filtering by Accounts.DetailView. 
if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView' and FIELD_TYPE = 'String' and DATA_FIELD = 'DESCRIPTION') begin -- then
	print 'Fix DETAILVIEWS_FIELDS: Convert to TextBox to take advantage of new code that converts \r\n to <br />.';
	update DETAILVIEWS_FIELDS
	   set FIELD_TYPE       = 'TextBox'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where FIELD_TYPE       = 'String'
	   and (1 = 0
	        or (DETAIL_NAME = 'Accounts.DetailView'         and DATA_LABEL = 'Accounts.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Roles.DetailView'            and DATA_LABEL = 'Roles.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Bugs.DetailView'             and DATA_LABEL = 'Bugs.LBL_DESCRIPTION'             and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Bugs.DetailView'             and DATA_LABEL = 'Bugs.LBL_WORK_LOG'                and DATA_FIELD = 'WORK_LOG'   )
	        or (DETAIL_NAME = 'Calls.DetailView'            and DATA_LABEL = 'Calls.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Cases.DetailView'            and DATA_LABEL = 'Cases.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Cases.DetailView'            and DATA_LABEL = 'Cases.LBL_RESOLUTION'             and DATA_FIELD = 'RESOLUTION' )
	        or (DETAIL_NAME = 'Contacts.DetailView'         and DATA_LABEL = 'Contacts.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Emails.DetailView'           and DATA_LABEL = 'Emails.LBL_BODY'                  and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'EmailTemplates.DetailView'   and DATA_LABEL = 'EmailTemplates.LBL_DESCRIPTION'   and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Employees.DetailView'        and DATA_LABEL = 'Employees.LBL_NOTES'              and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Leads.DetailView'            and DATA_LABEL = 'Leads.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Meetings.DetailView'         and DATA_LABEL = 'Meetings.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Opportunities.DetailView'    and DATA_LABEL = 'Opportunities.LBL_DESCRIPTION'    and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Project.DetailView'          and DATA_LABEL = 'Project.LBL_DESCRIPTION'          and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'ProjectTask.DetailView'      and DATA_LABEL = 'ProjectTask.LBL_DESCRIPTION'      and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'ProspectLists.DetailView'    and DATA_LABEL = 'ProspectLists.LBL_DESCRIPTION'    and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Prospects.DetailView'        and DATA_LABEL = 'Prospects.LBL_DESCRIPTION'        and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Users.DetailView'            and DATA_LABEL = 'Users.LBL_NOTES'                  and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Tasks.DetailView'            and DATA_LABEL = 'Tasks.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'TestPlans.DetailView'        and DATA_LABEL = 'TestPlans.LBL_DESCRIPTION'        and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'TestCases.DetailView'        and DATA_LABEL = 'TestCases.LBL_DESCRIPTION'        and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'TestCases.DetailView'        and DATA_LABEL = 'TestCases.LBL_EXPECTED_RESULTS'   and DATA_FIELD = 'EXPECTED_RESULTS')
	        or (DETAIL_NAME = 'ACLRoles.DetailView'         and DATA_LABEL = 'ACLRoles.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Contracts.DetailView'        and DATA_LABEL = 'Contracts.LBL_DESCRIPTION'        and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'ProductTemplates.DetailView' and DATA_LABEL = 'ProductTemplates.LBL_DESCRIPTION' and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Quotes.DetailView'           and DATA_LABEL = 'Quotes.LBL_DESCRIPTION'           and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Teams.DetailView'            and DATA_LABEL = 'Teams.LBL_DESCRIPTION'            and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Orders.DetailView'           and DATA_LABEL = 'Orders.LBL_DESCRIPTION'           and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Invoices.DetailView'         and DATA_LABEL = 'Invoices.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'Payments.DetailView'         and DATA_LABEL = 'Payments.LBL_DESCRIPTION'         and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'TeamNotices.DetailView'      and DATA_LABEL = 'TeamNotices.LBL_DESCRIPTION'      and DATA_FIELD = 'DESCRIPTION')
	        or (DETAIL_NAME = 'WorkflowAlertTemplates.DetailView' and DATA_LABEL = 'WorkflowAlertTemplates.LBL_DESCRIPTION'      and DATA_FIELD = 'DESCRIPTION')
	       );
end -- if;
GO

-- 07/08/2007 Paul.  Add CampaignTrackers module. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CampaignTrackers.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS CampaignTrackers.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'CampaignTrackers.DetailView', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView',  0, 'CampaignTrackers.LBL_EDIT_CAMPAIGN_NAME'   , 'CAMPAIGN_NAME'             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView',  1, 'CampaignTrackers.LBL_EDIT_TRACKER_NAME'    , 'TRACKER_NAME'              , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'CampaignTrackers.DetailView',  2, 'CampaignTrackers.LBL_EDIT_OPT_OUT'         , 'IS_OPTOUT'                                , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView',  3, 'CampaignTrackers.LBL_EDIT_TRACKER_URL'     , 'TRACKER_URL'               , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView',  4, 'CampaignTrackers.LBL_EDIT_TRACKER_KEY'     , 'TRACKER_KEY'               , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CampaignTrackers.DetailView',  5, 'CampaignTrackers.LBL_EDIT_MESSAGE_URL'     , 'MESSAGE_URL'               , '{0}'        , 3;
end -- if;
GO

-- 07/08/2007 Paul.  Add EmailMarketing module. 
-- 01/12/2012 Paul.  FROM_ADDR is null.  Use RETURN_PATH instead. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMarketing.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMarketing.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS EmailMarketing.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'EmailMarketing.DetailView', 'EmailMarketing', 'vwEMAIL_MARKETING_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  0, 'EmailMarketing.LBL_NAME'                   , 'NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'EmailMarketing.DetailView'  ,  1, 'EmailMarketing.LBL_STATUS'                 , 'STATUS'                    , '{0}'        , 'email_marketing_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  2, 'EmailMarketing.LBL_FROM_MAILBOX_NAME'      , 'RETURN_PATH'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  3, 'EmailMarketing.LBL_FROM_NAME'              , 'FROM_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  4, 'EmailMarketing.LBL_START_DATE_TIME'        , 'DATE_START'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  5, 'EmailMarketing.LBL_TEMPLATE'               , 'TEMPLATE_NAME'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  6, 'EmailMarketing.LBL_ALL_PROSPECT_LISTS'     , 'ALL_PROSPECT_LISTS'        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  7, 'EmailMarketing.LBL_REPLY_TO_NAME'          , 'REPLY_TO_NAME'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'EmailMarketing.DetailView'  ,  8, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  9, 'EmailMarketing.LBL_REPLY_TO_ADDR'          , 'REPLY_TO_ADDR'             , '{0}'        , null;
end else begin
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMarketing.DetailView' and DATA_FIELD = 'FROM_ADDR' and DELETED = 0) begin -- then
		print 'EmailMarketing.DetailView: Fix RETURN_PATH.';
		update DETAILVIEWS_FIELDS
		   set DATA_FIELD        = 'RETURN_PATH'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'EmailMarketing.DetailView'
		   and DATA_FIELD        = 'FROM_ADDR'
		   and DELETED           = 0;
	end -- if;
	-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'EmailMarketing.DetailView' and DATA_FIELD = 'REPLY_TO_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'EmailMarketing.DetailView'  ,  7, 'EmailMarketing.LBL_REPLY_TO_NAME'          , 'REPLY_TO_NAME'             , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'EmailMarketing.DetailView'  ,  8, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'EmailMarketing.DetailView'  ,  9, 'EmailMarketing.LBL_REPLY_TO_ADDR'          , 'REPLY_TO_ADDR'             , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CallMarketing.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'CallMarketing.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS CallMarketing.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'CallMarketing.DetailView', 'CallMarketing', 'vwCALL_MARKETING_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  0, 'CallMarketing.LBL_NAME'                    , 'NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'CallMarketing.DetailView'   ,  1, 'CallMarketing.LBL_STATUS'                  , 'STATUS'                    , '{0}'        , 'call_marketing_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  2, 'CallMarketing.LBL_SUBJECT'                 , 'SUBJECT'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'CallMarketing.DetailView'   ,  3, 'CallMarketing.LBL_DISTRIBUTION'            , 'DISTRIBUTION'              , '{0}'        , 'call_distribution_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  4, '.LBL_ASSIGNED_TO'                          , 'ASSIGNED_TO_NAME'          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  5, 'Teams.LBL_TEAM'                            , 'TEAM_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  6, 'CallMarketing.LBL_DATE_START'              , 'DATE_START'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  7, 'CallMarketing.LBL_DURATION'                , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  8, 'CallMarketing.LBL_DATE_END'                , 'DATE_END'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'CallMarketing.DetailView'   ,  9, 'CallMarketing.LBL_ALL_PROSPECT_LISTS'      , 'ALL_PROSPECT_LISTS'        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'CallMarketing.DetailView'   , 10, 'TextBox', 'Calls.LBL_DESCRIPTION'          , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- 10/21/2010 Paul.  The Test button in InboundEmail was failing because the PORT was not available. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- delete from DETAILVIEWS where NAME = 'InboundEmail.DetailView';
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'InboundEmail.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'InboundEmail.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS InboundEmail.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'InboundEmail.DetailView', 'InboundEmail', 'vwINBOUND_EMAILS_Edit', '25%', '25%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  0, 'InboundEmail.LBL_NAME'          , 'NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  1, 'InboundEmail.LBL_SERVER_URL'    , 'SERVER_URL'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'InboundEmail.DetailView',  2, 'InboundEmail.LBL_STATUS'        , 'STATUS'                    , '{0}'        , 'user_status_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  3, 'InboundEmail.LBL_LOGIN'         , 'EMAIL_USER'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  4, 'InboundEmail.LBL_PORT'          , 'PORT'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  5, 'InboundEmail.LBL_MAILBOX'       , 'MAILBOX'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'InboundEmail.DetailView',  6, 'InboundEmail.LBL_MAILBOX_TYPE'  , 'MAILBOX_TYPE'              , '{0}'        , 'dom_mailbox_type'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'InboundEmail.DetailView',  7, 'InboundEmail.LBL_SERVER_TYPE'   , 'SERVICE'                   , '{0}'        , 'dom_email_server_type'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView',  8, 'InboundEmail.LBL_GROUP_QUEUE'   , 'GROUP_NAME'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'InboundEmail.DetailView',  9, 'InboundEmail.LBL_MAILBOX_SSL'   , 'MAILBOX_SSL'                              , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView', 10, 'InboundEmail.LBL_AUTOREPLY'     , 'TEMPLATE_NAME'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'InboundEmail.DetailView', 11, 'InboundEmail.LBL_MARK_READ'     , 'MARK_READ'                                , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'InboundEmail.DetailView', 12, 'InboundEmail.LBL_ONLY_SINCE'    , 'ONLY_SINCE'                               , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView', 13, 'InboundEmail.LBL_FROM_NAME'     , 'FROM_NAME FROM_ADDR'       , '{0} &lt;{1}&gt;', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'InboundEmail.DetailView', 14, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView', 15, 'InboundEmail.LBL_REPLY_TO_NAME' , 'REPLY_TO_NAME REPLY_TO_ADDR', '{0} &lt;{1}&gt;', null;
end else begin
	exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'InboundEmail.DetailView',  4, 'InboundEmail.LBL_PORT'          , 'PORT'                      , '{0}'        , null;
	-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'InboundEmail.DetailView' and DATA_FIELD = 'REPLY_TO_NAME' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'InboundEmail.DetailView', 14, null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'InboundEmail.DetailView', 15, 'InboundEmail.LBL_REPLY_TO_NAME'          , 'REPLY_TO_NAME REPLY_TO_ADDR', '{0} &lt;{1}&gt;', null;
	end -- if;
end -- if;
GO

-- 09/09/2009 Paul.  Allow direct editing of the module table. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView';
-- 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
-- 04/01/2010 Paul.  Add Exchange Sync flag. 
-- 12/12/2010 Paul.  Missing last parameter in spDETAILVIEWS_InsertOnly. 
-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Modules.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Modules.DetailView' , 'Modules', 'vwMODULES', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  0, 'Modules.LBL_MODULE_NAME'           , 'MODULE_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  1, 'Modules.LBL_DISPLAY_NAME'          , 'DISPLAY_NAME'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  2, 'Modules.LBL_RELATIVE_PATH'         , 'RELATIVE_PATH'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  3, 'Modules.LBL_TABLE_NAME'            , 'TABLE_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  4, 'Modules.LBL_TAB_ORDER'             , 'TAB_ORDER'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  5, 'Modules.LBL_PORTAL_ENABLED'        , 'PORTAL_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  6, 'Modules.LBL_MODULE_ENABLED'        , 'MODULE_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  7, 'Modules.LBL_TAB_ENABLED'           , 'TAB_ENABLED'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  8, 'Modules.LBL_IS_ADMIN'              , 'IS_ADMIN'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  9, 'Modules.LBL_CUSTOM_ENABLED'        , 'CUSTOM_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 10, 'Modules.LBL_REPORT_ENABLED'        , 'REPORT_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 11, 'Modules.LBL_IMPORT_ENABLED'        , 'IMPORT_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 12, 'Modules.LBL_MOBILE_ENABLED'        , 'MOBILE_ENABLED'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 13, 'Modules.LBL_CUSTOM_PAGING'         , 'CUSTOM_PAGING'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 14, 'Modules.LBL_MASS_UPDATE_ENABLED'   , 'MASS_UPDATE_ENABLED'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 15, 'Modules.LBL_DEFAULT_SEARCH_ENABLED', 'DEFAULT_SEARCH_ENABLED'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 16, 'Modules.LBL_EXCHANGE_SYNC'         , 'EXCHANGE_SYNC'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 17, 'Modules.LBL_EXCHANGE_FOLDERS'      , 'EXCHANGE_FOLDERS'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 18, 'Modules.LBL_EXCHANGE_CREATE_PARENT', 'EXCHANGE_CREATE_PARENT'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 19, 'Modules.LBL_REST_ENABLED'          , 'REST_ENABLED'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 20, 'Modules.LBL_DUPLICATE_CHECHING_ENABLED', 'DUPLICATE_CHECHING_ENABLED'   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 21, 'Modules.LBL_RECORD_LEVEL_SECURITY_ENABLED', 'RECORD_LEVEL_SECURITY_ENABLED'        , '{0}'        , null;
end else begin
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'MASS_UPDATE_ENABLED' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 14, 'Modules.LBL_MASS_UPDATE_ENABLED' , 'MASS_UPDATE_ENABLED'              , '{0}'        , null;
		exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Modules.DetailView' , 15, null;
	end -- if;
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'DEFAULT_SEARCH_ENABLED' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Modules.DetailView' , 15, 'Modules.LBL_DEFAULT_SEARCH_ENABLED' , 'DEFAULT_SEARCH_ENABLED'        , '{0}'        , null;
	end -- if;
	-- 04/01/2010 Paul.  Add Exchange Sync flag. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'EXCHANGE_SYNC' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 16, 'Modules.LBL_EXCHANGE_SYNC'       , 'EXCHANGE_SYNC'                    , '{0}'        , null;
	end -- if;
	-- 04/04/2010 Paul.  Add Exchange Folders flag. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'EXCHANGE_FOLDERS' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 17, 'Modules.LBL_EXCHANGE_FOLDERS'    , 'EXCHANGE_FOLDERS'                 , '{0}'        , null;
	end -- if;
	-- 04/05/2010 Paul.  Add Exchange Create Parent flag. Need to be able to disable Account creation. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'EXCHANGE_CREATE_PARENT' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 18, 'Modules.LBL_EXCHANGE_CREATE_PARENT', 'EXCHANGE_CREATE_PARENT'         , '{0}'        , null;
	end -- if;
	-- 06/23/2010 Paul.  Allow display of the Portal flag. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'PORTAL_ENABLED' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Modules.DetailView'
		   and FIELD_TYPE        = 'Blank'
		   and FIELD_INDEX       = 5
		   and DELETED           = 0;
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' ,  5, 'Modules.LBL_PORTAL_ENABLED'        , 'PORTAL_ENABLED'                   , '{0}'        , null;
	end -- if;
	-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'REST_ENABLED' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 19, 'Modules.LBL_REST_ENABLED'          , 'REST_ENABLED'                     , '{0}'        , null;
	end -- if;
	-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'DUPLICATE_CHECHING_ENABLED' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Modules.DetailView' , 20, 'Modules.LBL_DUPLICATE_CHECHING_ENABLED', 'DUPLICATE_CHECHING_ENABLED', '{0}'        , null;
	end -- if;
	-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
	if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Modules.DetailView' and DATA_FIELD = 'RECORD_LEVEL_SECURITY_ENABLED' and DELETED = 0) begin -- then
		exec dbo.spDETAILVIEWS_FIELDS_CnvBound     'Modules.DetailView' , 21, 'Modules.LBL_RECORD_LEVEL_SECURITY_ENABLED', 'RECORD_LEVEL_SECURITY_ENABLED'     , '{0}'        , null;
	end -- if;
end -- if;
GO

-- 09/12/2009 Paul.  Allow editing of Field Validators. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'FieldValidators.DetailView';
-- 12/12/2010 Paul.  Missing last parameter in spDETAILVIEWS_InsertOnly. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'FieldValidators.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS FieldValidators.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'FieldValidators.DetailView', 'FieldValidators', 'vwFIELD_VALIDATORS', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  0, 'FieldValidators.LBL_NAME'              , 'NAME'              , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  1, 'FieldValidators.LBL_VALIDATION_TYPE'   , 'VALIDATION_TYPE'   , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  2, 'FieldValidators.LBL_REGULAR_EXPRESSION', 'REGULAR_EXPRESSION', '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  3, 'FieldValidators.LBL_DATA_TYPE'         , 'DATA_TYPE'         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  4, 'FieldValidators.LBL_MININUM_VALUE'     , 'MININUM_VALUE'     , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  5, 'FieldValidators.LBL_MAXIMUM_VALUE'     , 'MAXIMUM_VALUE'     , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'FieldValidators.DetailView',  6, 'FieldValidators.LBL_COMPARE_OPERATOR'  , 'COMPARE_OPERATOR'  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'FieldValidators.DetailView',  7, null;
end -- if;
GO

-- 09/04/2010 Paul.  Create full editing for Releases. 
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Releases.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Releases.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Releases.DetailView' , 'Releases', 'vwRELEASES', '15%', '85%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Releases.DetailView' ,  0, 'Releases.LBL_NAME'                  , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Releases.DetailView' ,  1, 'Releases.LBL_STATUS'                , 'STATUS'                           , '{0}'        , 'release_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Releases.DetailView' ,  2, 'Releases.LBL_LIST_ORDER'            , 'LIST_ORDER'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Releases.DetailView' ,  3, null;
end else begin
	-- 01/19/2013 Paul.  DESCRIPTION field does not apply.  Fix for Personal Editions. 
	if exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Releases.DetailView' and DATA_FIELD = 'DESCRIPTION' and DELETED = 0) begin -- then
		update DETAILVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Releases.DetailView'
		   and DATA_FIELD        = 'DESCRIPTION'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 01/23/2012 Paul.  Create full editing for number sequences. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'NumberSequences.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'NumberSequences.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS NumberSequences.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'NumberSequences.DetailView' , 'NumberSequences', 'vwNUMBER_SEQUENCES', '15%', '35%', 2;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  0, 'NumberSequences.LBL_NAME'           , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  1, 'NumberSequences.LBL_CURRENT_VALUE'  , 'CURRENT_VALUE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  2, 'NumberSequences.LBL_ALPHA_PREFIX'   , 'ALPHA_PREFIX'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  3, 'NumberSequences.LBL_ALPHA_SUFFIX'   , 'ALPHA_SUFFIX'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  4, 'NumberSequences.LBL_SEQUENCE_STEP'  , 'SEQUENCE_STEP'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NumberSequences.DetailView' ,  5, 'NumberSequences.LBL_NUMERIC_PADDING', 'NUMERIC_PADDING'                  , '{0}'        , null;
end -- if;
GO

-- 09/10/2012 Paul.  Add User Signatures. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'UserSignatures.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'UserSignatures.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS UserSignatures.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'UserSignatures.DetailView'  , 'UserSignatures', 'vwUSERS_SIGNATURES', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'UserSignatures.DetailView'  ,  0, 'UserSignatures.LBL_NAME'             , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'UserSignatures.DetailView'  ,  1, 'UserSignatures.LBL_PRIMARY_SIGNATURE', 'PRIMARY_SIGNATURE'                , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'UserSignatures.DetailView'  ,  2, 'UserSignatures.LBL_SIGNATURE_HTML'   , 'SIGNATURE_HTML'                   , '{0}'        , 3;
end -- if;
GO

-- 09/22/2013 Paul.  Add OutboundSms module. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'OutboundSms.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'OutboundSms.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS OutboundSms.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'OutboundSms.DetailView', 'OutboundSms', 'vwOUTBOUND_SMS_Edit', '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OutboundSms.DetailView'     ,  0, 'OutboundSms.LBL_NAME'                , 'NAME'                             , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'OutboundSms.DetailView'     ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OutboundSms.DetailView'     ,  2, 'OutboundSms.LBL_FROM_NUMBER'         , 'FROM_NUMBER'                      , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'OutboundSms.DetailView'     ,  3, null;
end -- if;
GO

-- 09/25/2013 Paul.  Add SmsMessages module. 
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'SmsMessages.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'SmsMessages.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS SmsMessages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'SmsMessages.DetailView', 'SmsMessages'        , 'vwSMS_MESSAGES_Edit'        , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'SmsMessages.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'        , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_NAME'            , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'SmsMessages.DetailView', -1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_DATE_START'      , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'SmsMessages.DetailView', -1, 'SmsMessages.LBL_STATUS'          , 'STATUS'                           , '{0}'        , 'dom_sms_status', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_FROM_NUMBER'     , 'FROM_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_FROM_LOCATION'   , 'FROM_LOCATION'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_TO_NUMBER'       , 'TO_NUMBER'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'SmsMessages.LBL_TO_LOCATION'     , 'TO_LOCATION'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'SmsMessages.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'           , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'SmsMessages.DetailView', -1, '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
end -- if;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module.
-- 04/15/2022 Paul.  Reorganize layout using Pacific tabs. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'TwitterMessages.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'TwitterMessages.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS TwitterMessages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly           'TwitterMessages.DetailView', 'TwitterMessages', 'vwTWITTER_MESSAGES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'TwitterMessages.DetailView', -1, '.LBL_LAYOUT_TAB_OVERVIEW'               , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, 'TwitterMessages.LBL_NAME'               , 'DESCRIPTION'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  'TwitterMessages.DetailView', -1, 'PARENT_TYPE'                            , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, 'TwitterMessages.LBL_DATE_START'         , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  'TwitterMessages.DetailView', -1, 'TwitterMessages.LBL_STATUS'             , 'STATUS'                                , '{0}'        , 'dom_twitter_status', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, 'TwitterMessages.LBL_TWITTER_SCREEN_NAME', 'TWITTER_SCREEN_NAME'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, 'TwitterMessages.LBL_TWITTER_FULL_NAME'  , 'TWITTER_FULL_NAME'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                             , '{0}'        , null;

	exec dbo.spDETAILVIEWS_FIELDS_InsHeader     'TwitterMessages.DetailView', -1, '.LBL_LAYOUT_TAB_OTHER'                  , 3, 'tab-only';
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound      'TwitterMessages.DetailView', -1, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ChatChannels.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ChatChannels.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ChatChannels.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ChatChannels.DetailView', 'ChatChannels', 'vwCHAT_CHANNELS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatChannels.DetailView'    ,  0, 'ChatChannels.LBL_NAME'                  , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatChannels.DetailView'    ,  1, 'PARENT_TYPE'                            , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}'     , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatChannels.DetailView'    ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatChannels.DetailView'    ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatChannels.DetailView'    ,  4, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatChannels.DetailView'    ,  5, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ChatMessages.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ChatMessages.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ChatMessages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ChatMessages.DetailView', 'ChatMessages', 'vwCHAT_MESSAGES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.DetailView'    ,  0, 'ChatMessages.LBL_NAME'                  , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.DetailView'    ,  1, 'ChatMessages.LBL_CHAT_CHANNEL_NAME'     , 'CHAT_CHANNEL_NAME'                     , '{0}'        , 'CHAT_CHANNEL_ID'   , '~/ChatChannels/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.DetailView'    ,  2, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.DetailView'    ,  3, '.LBL_CREATED_BY_NAME'                   , 'CREATED_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.DetailView'    ,  4, 'Notes.LBL_FILENAME'                     , 'FILENAME'                              , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.DetailView'    ,  5, 'PARENT_TYPE'                            , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}'     , null, null;
end -- if;
GO

-- 04/12/2016 Paul.  Add ZipCodes. 
-- delete from ETAILVIEWS_FIELDS where DETAIL_NAME = 'ZipCodes.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ZipCodes.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ZipCodes.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ZipCodes.DetailView', 'ZipCodes', 'vwZIPCODES', '15%', '35', 2;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  0, 'ZipCodes.LBL_NAME'                      , 'NAME'                                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  1, 'ZipCodes.LBL_COUNTRY'                   , 'COUNTRY'                                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  2, 'ZipCodes.LBL_CITY'                      , 'CITY'                                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  3, 'ZipCodes.LBL_LONGITUDE'                 , 'LONGITUDE'                                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  4, 'ZipCodes.LBL_STATE'                     , 'STATE'                                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ZipCodes.DetailView',  5, 'ZipCodes.LBL_LATITUDE'                  , 'LATITUDE'                                      , '{0}'        , null;
end -- if;
GO

-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Currencies.DetailView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Currencies.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Currencies.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Currencies.DetailView', 'Currencies', 'vwCURRENCIES_Edit', '15%', '35', 2;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Currencies.DetailView',  0, 'Currencies.LBL_NAME'                  , 'NAME'                                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Currencies.DetailView',  1, 'Currencies.LBL_ISO4217'               , 'ISO4217'                                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Currencies.DetailView',  2, 'Currencies.LBL_CONVERSION_RATE'       , 'CONVERSION_RATE'                               , '{0:F3}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Currencies.DetailView',  3, 'Currencies.LBL_SYMBOL'                , 'SYMBOL'                                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Currencies.DetailView',  4, 'Currencies.LBL_STATUS'                , 'STATUS'                                        , '{0}'        , 'currency_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Currencies.DetailView',  5, 'Currencies.LBL_DEFAULT_CURRENCY'      , 'IS_DEFAULT'                                    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Currencies.DetailView',  6, '.LBL_DATE_MODIFIED'                   , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Currencies.DetailView',  7, 'Currencies.LBL_BASE_CURRENCY'         , 'IS_BASE'                                       , null;
end -- if;
GO

-- 05/11/2016 Paul.  Add support for Tags. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tags.DetailView'
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tags.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Tags.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Tags.DetailView', 'Tags', 'vwTAGS_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tags.DetailView'     ,  0, 'Tags.LBL_NAME'                   , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Tags.DetailView'     ,  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Tags.DetailView'     ,  2, 'TextBox', 'Tags.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- 06/07/2017 Paul.  Add support for NAICS Codes. 
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'NAICSCodes.DetailView'
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'NAICSCodes.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS NAICSCodes.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'NAICSCodes.DetailView', 'Teams', 'vwNAICS_CODES_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'NAICSCodes.DetailView',  0, 'NAICSCodes.LBL_NAME'                  , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'NAICSCodes.DetailView',  1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'NAICSCodes.DetailView',  2, 'TextBox', 'NAICSCodes.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
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

call dbo.spDETAILVIEWS_FIELDS_Defaults()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_Defaults')
/

-- #endif IBM_DB2 */

