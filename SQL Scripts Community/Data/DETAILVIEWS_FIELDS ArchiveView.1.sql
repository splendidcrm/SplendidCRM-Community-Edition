

print 'DETAILVIEWS_FIELDS ArchiveView';
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME like '%.ArchiveView'
--GO

set nocount on;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Accounts.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Accounts.ArchiveView', 'Accounts', 'vwACCOUNTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_ACCOUNT_NAME'               , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_PHONE'                      , 'PHONE_OFFICE'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_WEBSITE'                    , 'WEBSITE'                               , '{0}'        , 'WEBSITE'             , '{0}'                        , '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_FAX'                        , 'PHONE_FAX'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_TICKER_SYMBOL'              , 'TICKER_SYMBOL'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_OTHER_PHONE'                , 'PHONE_ALTERNATE'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_MEMBER_OF'                  , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'           , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_EMAIL'                      , 'EMAIL1'                                , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_EMPLOYEES'                  , 'EMPLOYEES'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_OTHER_EMAIL_ADDRESS'        , 'EMAIL2'                                , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_OWNERSHIP'                  , 'OWNERSHIP'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_RATING'                     , 'RATING'                                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_INDUSTRY'                   , 'INDUSTRY'                              , '{0}'        , 'industry_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SIC_CODE'                   , 'SIC_CODE'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.ArchiveView'       , -1, 'Accounts.LBL_TYPE'                       , 'ACCOUNT_TYPE'                          , '{0}'        , 'account_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_ANNUAL_REVENUE'             , 'ANNUAL_REVENUE'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Accounts.ArchiveView'       , -1, null;                                     
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_NAICS_SET_NAME'             , 'NAICS_SET_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_BILLING_ADDRESS_STREET'     , 'BILLING_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SHIPPING_ADDRESS_STREET'    , 'SHIPPING_ADDRESS_STREET'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_BILLING_ADDRESS_CITY'       , 'BILLING_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SHIPPING_ADDRESS_CITY'      , 'SHIPPING_ADDRESS_CITY'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_BILLING_ADDRESS_STATE'      , 'BILLING_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SHIPPING_ADDRESS_STATE'     , 'SHIPPING_ADDRESS_STATE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_BILLING_ADDRESS_POSTALCODE' , 'BILLING_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SHIPPING_ADDRESS_POSTALCODE', 'SHIPPING_ADDRESS_POSTALCODE'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_BILLING_ADDRESS_COUNTRY'    , 'BILLING_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView'       , -1, 'Accounts.LBL_SHIPPING_ADDRESS_COUNTRY'   , 'SHIPPING_ADDRESS_COUNTRY'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Accounts.ArchiveView'       , -1, 'TextBox', 'Accounts.LBL_DESCRIPTION'     , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Bugs.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Bugs.ArchiveView', 'Bugs', 'vwBUGS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, 'Bugs.LBL_BUG_NUMBER'                     , 'BUG_NUMBER'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_PRIORITY'                       , 'PRIORITY'                              , '{0}'        , 'bug_priority_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_STATUS'                         , 'STATUS'                                , '{0}'        , 'bug_status_dom'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_TYPE'                           , 'TYPE'                                  , '{0}'        , 'bug_type_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_SOURCE'                         , 'SOURCE'                                , '{0}'        , 'source_dom'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_PRODUCT_CATEGORY'               , 'PRODUCT_CATEGORY'                      , '{0}'        , 'product_category_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.ArchiveView'           , -1, 'Bugs.LBL_RESOLUTION'                     , 'RESOLUTION'                            , '{0}'        , 'bug_resolution_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, 'Bugs.LBL_FOUND_IN_RELEASE'               , 'FOUND_IN_RELEASE'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, 'Bugs.LBL_FIXED_IN_RELEASE'               , 'FIXED_IN_RELEASE'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Bugs.ArchiveView'           , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.ArchiveView'           , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.ArchiveView'           , -1, 'Bugs.LBL_SUBJECT'                        , 'NAME'                                  , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Bugs.ArchiveView'           , -1, 'TextBox', 'Bugs.LBL_DESCRIPTION'         , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.ArchiveView'           , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Bugs.ArchiveView'           , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Bugs.ArchiveView'           , -1, 'TextBox', 'Bugs.LBL_WORK_LOG'            , 'WORK_LOG', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Calls.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Calls.ArchiveView', 'Calls', 'vwCALLS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calls.LBL_SUBJECT'                       , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Calls.ArchiveView'          , -1, 'Calls.LBL_STATUS'                        , 'DIRECTION STATUS'                                                             , '{0} {1}'        , 'call_direction_dom call_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calls.LBL_DATE_TIME'                     , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Calls.ArchiveView'          , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calls.LBL_DURATION'                      , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME'                                       , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'                                         , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                                                              , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Calls.ArchiveView'          , -1, 'TextBox', 'Calls.LBL_DESCRIPTION'        , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Calls.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Calls.ArchiveView'          , -1, 'Calls.LBL_REPEAT_TYPE'                   , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calendar.LBL_REPEAT_END_AFTER'           , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calendar.LBL_REPEAT_INTERVAL'            , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.ArchiveView'          , -1, 'Calls.LBL_REPEAT_UNTIL'                  , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Cases.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Cases.ArchiveView', 'Cases', 'vwCASES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, 'Cases.LBL_CASE_NUMBER'                   , 'CASE_NUMBER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.ArchiveView'          , -1, 'Cases.LBL_PRIORITY'                      , 'PRIORITY'                              , '{0}'        , 'case_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.ArchiveView'          , -1, 'Cases.LBL_STATUS'                        , 'STATUS'                                , '{0}'        , 'case_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Cases.ArchiveView'          , -1, 'Cases.LBL_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'                          , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.ArchiveView'          , -1, 'Cases.LBL_TYPE'                          , 'TYPE'                                  , '{0}'        , 'case_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.ArchiveView'          , -1, 'Cases.LBL_SUBJECT'                       , 'NAME'                                  , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.ArchiveView'          , -1, 'TextBox', 'Cases.LBL_DESCRIPTION'        , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.ArchiveView'          , -1, 'TextBox', 'Cases.LBL_RESOLUTION'         , 'RESOLUTION' , null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.ArchiveView'          , -1, 'TextBox', 'Cases.LBL_WORK_LOG'           , 'WORK_LOG'   , null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contacts.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Contacts.ArchiveView', 'Contacts', 'vwCONTACTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_NAME'                       , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_OFFICE_PHONE'               , 'PHONE_WORK'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_MOBILE_PHONE'               , 'PHONE_MOBILE'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ACCOUNT_NAME'               , 'ACCOUNT_NAME'                          , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_HOME_PHONE'                 , 'PHONE_HOME'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Contacts.ArchiveView'       , -1, 'Contacts.LBL_LEAD_SOURCE'                , 'LEAD_SOURCE'                           , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_OTHER_PHONE'                , 'PHONE_OTHER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_TITLE'                      , 'TITLE'                                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_FAX_PHONE'                  , 'PHONE_FAX'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_DEPARTMENT'                 , 'DEPARTMENT'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView'       , -1, 'Contacts.LBL_EMAIL_ADDRESS'              , 'EMAIL1'                                , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_BIRTHDATE'                  , 'BIRTHDATE'                             , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView'       , -1, 'Contacts.LBL_OTHER_EMAIL_ADDRESS'        , 'EMAIL2'                                , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView'       , -1, 'Contacts.LBL_REPORTS_TO'                 , 'REPORTS_TO_NAME'                       , '{0}'        , 'REPORTS_TO_ID'       , '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ASSISTANT'                  , 'ASSISTANT'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.ArchiveView'       , -1, 'Contacts.LBL_SYNC_CONTACT'               , 'SYNC_CONTACT'                          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ASSISTANT_PHONE'            , 'ASSISTANT_PHONE'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.ArchiveView'       , -1, 'Contacts.LBL_DO_NOT_CALL'                , 'DO_NOT_CALL'                           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Contacts.ArchiveView'       , -1, 'Contacts.LBL_EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'                         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Contacts.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Contacts.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_PRIMARY_ADDRESS_STREET'     , 'PRIMARY_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_PRIMARY_ADDRESS_CITY'       , 'PRIMARY_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_PRIMARY_ADDRESS_STATE'      , 'PRIMARY_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_PRIMARY_ADDRESS_POSTALCODE' , 'PRIMARY_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_PRIMARY_ADDRESS_COUNTRY'    , 'PRIMARY_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ALT_ADDRESS_STREET'         , 'ALT_ADDRESS_STREET'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ALT_ADDRESS_CITY'           , 'ALT_ADDRESS_CITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ALT_ADDRESS_STATE'          , 'ALT_ADDRESS_STATE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ALT_ADDRESS_POSTALCODE'     , 'ALT_ADDRESS_POSTALCODE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView'       , -1, 'Contacts.LBL_ALT_ADDRESS_COUNTRY'        , 'ALT_ADDRESS_COUNTRY'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Contacts.ArchiveView'       , -1, 'TextBox', 'Contacts.LBL_DESCRIPTION'     , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Documents.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Documents.ArchiveView', 'Documents', 'vwDOCUMENTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_DOC_NAME'                  , 'DOCUMENT_NAME'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_DOC_VERSION'               , 'REVISION'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.ArchiveView'      , -1, 'Documents.LBL_TEMPLATE_TYPE'             , 'TEMPLATE_TYPE'                         , '{0}'        , 'document_template_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Documents.ArchiveView'      , -1, 'Documents.LBL_IS_TEMPLATE'               , 'IS_TEMPLATE'                           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.ArchiveView'      , -1, 'Documents.LBL_CATEGORY_VALUE'            , 'CATEGORY_ID'                           , '{0}'        , 'document_category_dom'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.ArchiveView'      , -1, 'Documents.LBL_SUBCATEGORY_VALUE'         , 'SUBCATEGORY_ID'                        , '{0}'        , 'document_subcategory_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.ArchiveView'      , -1, 'Documents.LBL_DOC_STATUS'                , 'STATUS_ID'                             , '{0}'        , 'document_status_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_LAST_REV_CREATOR'          , 'REVISION_CREATED_BY_NAME'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_LAST_REV_DATE'             , 'REVISION_DATE_ENTERED'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_DOC_ACTIVE_DATE'           , 'ACTIVE_DATE'                           , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, 'Documents.LBL_DOC_EXP_DATE'              , 'EXP_DATE'                              , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Documents.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Documents.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Documents.ArchiveView'      , -1, 'TextBox', 'Documents.LBL_DOC_DESCRIPTION', 'DESCRIPTION', '10,90', null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Documents.ArchiveView'      , -1, 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Documents.ArchiveView'      , -1, 'Documents.LBL_DOWNNLOAD_FILE'            , 'FILENAME'                             , '{0}'        , 'DOCUMENT_REVISION_ID'    , '~/Documents/Document.aspx?ID={0}', '_blank', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.ArchiveView'      , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.ArchiveView'      , -1, 'Documents.LBL_PRIMARY_MODULE'            , 'PRIMARY_MODULE'                       , '{0}'        , 'Modules'                 , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Emails.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Emails.ArchiveView', 'Emails', 'vwEMAILS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_DATE_SENT'                    , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Emails.ArchiveView'         , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_FROM'                         , 'FROM_NAME FROM_ADDR'                   , '{0} &lt;{1}&gt;', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_TO'                           , 'TO_ADDRS'                              , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_CC'                           , 'CC_ADDRS'                              , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_BCC'                          , 'BCC_ADDRS'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.ArchiveView'         , -1, 'Emails.LBL_SUBJECT'                      , 'NAME'                                  , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Emails.ArchiveView'         , -1, 'TextBox', 'Emails.LBL_BODY'              , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Leads.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Leads.ArchiveView', 'Leads', 'vwLEADS_ARCHIVE', '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.ArchiveView'          , -1, 'Leads.LBL_LEAD_SOURCE'                   , 'LEAD_SOURCE'                           , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.ArchiveView'          , -1, 'Leads.LBL_STATUS'                        , 'STATUS'                                , '{0}'        , 'lead_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_LEAD_SOURCE_DESCRIPTION'       , 'LEAD_SOURCE_DESCRIPTION'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_STATUS_DESCRIPTION'            , 'STATUS_DESCRIPTION'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_REFERED_BY'                    , 'REFERED_BY'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_OFFICE_PHONE'                  , 'PHONE_WORK'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_NAME'                          , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_MOBILE_PHONE'                  , 'PHONE_MOBILE'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_HOME_PHONE'                    , 'PHONE_HOME'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView'          , -1, 'Leads.LBL_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'                          , '{0}'        , 'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_OTHER_PHONE'                   , 'PHONE_OTHER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView'          , -1, 'Accounts.LBL_WEBSITE'                    , 'WEBSITE'                               , '{0}'        , 'WEBSITE', '{0}', '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_FAX_PHONE'                     , 'PHONE_FAX'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_TITLE'                         , 'TITLE'                                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView'          , -1, 'Leads.LBL_EMAIL_ADDRESS'                 , 'EMAIL1'                                , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_DEPARTMENT'                    , 'DEPARTMENT'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView'          , -1, 'Leads.LBL_OTHER_EMAIL_ADDRESS'           , 'EMAIL2'                                , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Leads.ArchiveView'          , -1, 'Leads.LBL_DO_NOT_CALL'                   , 'DO_NOT_CALL'                           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Leads.ArchiveView'          , -1, 'Leads.LBL_EMAIL_OPT_OUT'                 , 'EMAIL_OPT_OUT'                         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Leads.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Leads.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_PRIMARY_ADDRESS_STREET'        , 'PRIMARY_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_PRIMARY_ADDRESS_CITY'          , 'PRIMARY_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_PRIMARY_ADDRESS_STATE'         , 'PRIMARY_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_PRIMARY_ADDRESS_POSTALCODE'    , 'PRIMARY_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_PRIMARY_ADDRESS_COUNTRY'       , 'PRIMARY_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_ALT_ADDRESS_STREET'            , 'ALT_ADDRESS_STREET'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_ALT_ADDRESS_CITY'              , 'ALT_ADDRESS_CITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_ALT_ADDRESS_STATE'             , 'ALT_ADDRESS_STATE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_ALT_ADDRESS_POSTALCODE'        , 'ALT_ADDRESS_POSTALCODE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView'          , -1, 'Leads.LBL_ALT_ADDRESS_COUNTRY'           , 'ALT_ADDRESS_COUNTRY'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Leads.ArchiveView'          , -1, 'TextBox', 'Leads.LBL_DESCRIPTION'        , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Meetings.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Meetings.ArchiveView', 'Meetings', 'vwMEETINGS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Meetings.LBL_SUBJECT'                    , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Meetings.ArchiveView'       , -1, 'Meetings.LBL_STATUS'                     , 'STATUS'                                                                       , '{0}'            , 'meeting_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Meetings.LBL_LOCATION'                   , 'LOCATION'                                                                     , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Meetings.ArchiveView'       , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Meetings.LBL_DATE_TIME'                  , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Meetings.LBL_DURATION'                   , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME'                                       , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'                                         , '{0} {1} {2}'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                                                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                                                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Meetings.ArchiveView'       , -1, 'TextBox', 'Meetings.LBL_DESCRIPTION'     , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Meetings.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Meetings.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Meetings.ArchiveView'       , -1, 'Calls.LBL_REPEAT_TYPE'                   , 'REPEAT_TYPE'                                                                  , '{0}'            , 'repeat_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Calendar.LBL_REPEAT_END_AFTER'           , 'REPEAT_COUNT Calendar.LBL_REPEAT_OCCURRENCES'                                 , '{0} {1}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Calendar.LBL_REPEAT_INTERVAL'            , 'REPEAT_INTERVAL'                                                              , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.ArchiveView'       , -1, 'Calls.LBL_REPEAT_UNTIL'                  , 'REPEAT_UNTIL'                                                                 , '{0}'            , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Notes.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Notes.ArchiveView', 'Notes', 'vwNOTES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.ArchiveView'          , -1, 'Notes.LBL_CONTACT_NAME'                  , 'CONTACT_NAME'                          , '{0}'        , 'CONTACT_ID'        , '~/Contacts/view.aspx?ID={0}&ArchiveView=1'   , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.ArchiveView'          , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}&ArchiveView=1'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, 'Notes.LBL_PHONE'                         , 'CONTACT_PHONE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.ArchiveView'          , -1, 'Notes.LBL_EMAIL_ADDRESS'                 , 'CONTACT_EMAIL'                         , '{0}'        , 'CONTACT_EMAIL'     , 'mailto:{0}'                    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.ArchiveView'          , -1, 'Notes.LBL_SUBJECT'                       , 'NAME'                                  , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.ArchiveView'          , -1, 'Notes.LBL_FILENAME'                      , 'FILENAME'                              , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}', null, 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Notes.ArchiveView'          , -1, 'TextBox', 'Notes.LBL_NOTE'               , 'DESCRIPTION', '30,90', null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Opportunities.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Opportunities.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_ARCHIVE' , '20%', '30%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_OPPORTUNITY_NAME'      , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_AMOUNT'                , 'AMOUNT_USDOLLAR'                       , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                          , '{0}'        , 'ACCOUNT_ID'          , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_LEAD_NAME'             , 'LEAD_NAME'                             , '{0}'        , 'LEAD_ID'             , '~/Leads/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_DATE_CLOSED'           , 'DATE_CLOSED'                           , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_TYPE'                  , 'OPPORTUNITY_TYPE'                      , '{0}'        , 'opportunity_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_NEXT_STEP'             , 'NEXT_STEP'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_LEAD_SOURCE'           , 'LEAD_SOURCE'                           , '{0}'        , 'lead_source_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_SALES_STAGE'           , 'SALES_STAGE'                           , '{0}'        , 'sales_stage_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_PROBABILITY'           , 'PROBABILITY'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.ArchiveView'  , -1, 'Opportunities.LBL_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'                         , '{0}'        , 'CAMPAIGN_ID'         , '~/Campaigns/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.ArchiveView'  , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Opportunities.ArchiveView'  , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Opportunities.ArchiveView'  , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Opportunities.ArchiveView'  , -1, 'TextBox', 'Opportunities.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Project.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Project.ArchiveView', 'Project', 'vwPROJECTS_ARCHIVE', '20%', '20%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, 'Project.LBL_NAME'                        , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.ArchiveView'        , -1, 'ProjectTask.LBL_STATUS'                  , 'STATUS'                                , '{0}'        , 'project_status_dom'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.ArchiveView'        , -1, 'ProjectTask.LBL_PRIORITY'                , 'PRIORITY'                              , '{0}'        , 'projects_priority_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, 'ProjectTask.LBL_ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, 'ProjectTask.LBL_ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.ArchiveView'        , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Project.ArchiveView'        , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Project.ArchiveView'        , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Project.ArchiveView'        , -1, 'TextBox', 'Project.LBL_DESCRIPTION'      , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProjectTask.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ProjectTask.ArchiveView', 'ProjectTask', 'vwPROJECT_TASKS_ARCHIVE' , '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'Project.LBL_NAME'                        , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_STATUS'                  , 'STATUS'                                , '{0}'        , 'project_task_status_options'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_TASK_NUMBER'             , 'TASK_NUMBER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_DEPENDS_ON_ID'           , 'DEPENDS_ON_NAME'                       , '{0}'        , 'DEPENDS_ON_ID'                   , '~/ProjectTasks/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_PRIORITY'                , 'PRIORITY'                              , '{0}'        , 'project_task_priority_options'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_MILESTONE_FLAG'          , 'MILESTONE_FLAG'                        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_ORDER_NUMBER'            , 'ORDER_NUMBER'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_PARENT_ID'               , 'PROJECT_NAME'                          , '{0}'        , 'PROJECT_ID'                      , '~/Projects/view.aspx?ID={0}&ArchiveView=1'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_PERCENT_COMPLETE'        , 'PERCENT_COMPLETE'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_UTILIZATION'             , 'UTILIZATION'                           , '{0}'        , 'project_task_utilization_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_DATE_START'              , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_ESTIMATED_EFFORT'        , 'ESTIMATED_EFFORT'                      , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_DATE_DUE'                , 'DATE_DUE'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.ArchiveView'    , -1, 'ProjectTask.LBL_ACTUAL_EFFORT'           , 'ACTUAL_EFFORT'                         , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'ProjectTask.ArchiveView'    , -1, 'TextBox', 'ProjectTask.LBL_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Prospects.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Prospects.ArchiveView', 'Prospects', 'vwPROSPECTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_NAME'                      , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_OFFICE_PHONE'              , 'PHONE_WORK'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_MOBILE_PHONE'              , 'PHONE_MOBILE'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_HOME_PHONE'                , 'PHONE_HOME'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_OTHER_PHONE'               , 'PHONE_OTHER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_TITLE'                     , 'TITLE'                                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_FAX_PHONE'                 , 'PHONE_FAX'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_DEPARTMENT'                , 'DEPARTMENT'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.ArchiveView'      , -1, 'Prospects.LBL_EMAIL_ADDRESS'             , 'EMAIL1'                                , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_BIRTHDATE'                 , 'BIRTHDATE'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.ArchiveView'      , -1, 'Prospects.LBL_OTHER_EMAIL_ADDRESS'       , 'EMAIL2'                                , '{0}'        , 'EMAIL2', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ASSISTANT'                 , 'ASSISTANT'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ASSISTANT_PHONE'           , 'ASSISTANT_PHONE'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.ArchiveView'      , -1, 'Prospects.LBL_DO_NOT_CALL'               , 'DO_NOT_CALL'                           , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.ArchiveView'      , -1, 'Prospects.LBL_EMAIL_OPT_OUT'             , 'EMAIL_OPT_OUT'                         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox  'Prospects.ArchiveView'      , -1, 'Prospects.LBL_INVALID_EMAIL'             , 'INVALID_EMAIL'                         , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Prospects.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_PRIMARY_ADDRESS_STREET'    , 'PRIMARY_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_PRIMARY_ADDRESS_CITY'      , 'PRIMARY_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_PRIMARY_ADDRESS_STATE'     , 'PRIMARY_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_PRIMARY_ADDRESS_POSTALCODE', 'PRIMARY_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_PRIMARY_ADDRESS_COUNTRY'   , 'PRIMARY_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ALT_ADDRESS_STREET'        , 'ALT_ADDRESS_STREET'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ALT_ADDRESS_CITY'          , 'ALT_ADDRESS_CITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ALT_ADDRESS_STATE'         , 'ALT_ADDRESS_STATE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ALT_ADDRESS_POSTALCODE'    , 'ALT_ADDRESS_POSTALCODE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView'      , -1, 'Prospects.LBL_ALT_ADDRESS_COUNTRY'       , 'ALT_ADDRESS_COUNTRY'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Prospects.ArchiveView'      , -1, 'TextBox', 'Prospects.LBL_DESCRIPTION'    , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Tasks.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Tasks.ArchiveView', 'Tasks', 'vwTASKS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Tasks.LBL_SUBJECT'                       , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.ArchiveView'          , -1, 'Tasks.LBL_STATUS'                        , 'STATUS'                                , '{0}'        , 'task_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Tasks.LBL_DUE_DATE_AND_TIME'             , 'DATE_DUE'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Tasks.ArchiveView'          , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'        , '~/Parents/view.aspx?ID={0}&ArchiveView=1' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Tasks.LBL_START_DATE_AND_TIME'           , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Tasks.ArchiveView'          , -1, 'Tasks.LBL_CONTACT'                       , 'CONTACT_NAME'                          , '{0}'        , 'CONTACT_ID'       , '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.ArchiveView'          , -1, 'Tasks.LBL_PRIORITY'                      , 'PRIORITY'                              , '{0}'        , 'task_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Tasks.LBL_EMAIL'                         , 'CONTACT_EMAIL'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, 'Tasks.LBL_PHONE'                         , 'CONTACT_PHONE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Tasks.ArchiveView'          , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.ArchiveView'          , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Tasks.ArchiveView'          , -1, 'TextBox', 'Tasks.LBL_DESCRIPTION'        , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'SmsMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS SmsMessages.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'SmsMessages.ArchiveView', 'SmsMessages', 'vwSMS_MESSAGES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_DATE_START'              , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'SmsMessages.ArchiveView'    , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_FROM_NUMBER'             , 'FROM_NUMBER'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_FROM_LOCATION'           , 'FROM_LOCATION'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_TO_NUMBER'               , 'TO_NUMBER'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_TO_LOCATION'             , 'TO_LOCATION'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_NAME'                    , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'SmsMessages.ArchiveView'    , -1, 'SmsMessages.LBL_STATUS'                  , 'STATUS'                                , '{0}'        , 'dom_sms_status', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.ArchiveView'    , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'TwitterMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS TwitterMessages.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'TwitterMessages.ArchiveView', 'TwitterMessages', 'vwTWITTER_MESSAGES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, 'TwitterMessages.LBL_NAME'                , 'DESCRIPTION'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'TwitterMessages.ArchiveView', -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, 'TwitterMessages.LBL_DATE_START'          , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'TwitterMessages.ArchiveView', -1, 'TwitterMessages.LBL_STATUS'              , 'STATUS'                                , '{0}'        , 'dom_twitter_status', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, 'TwitterMessages.LBL_TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, 'TwitterMessages.LBL_TWITTER_FULL_NAME'   , 'TWITTER_FULL_NAME'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.ArchiveView', -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ChatMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ChatMessages.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ChatMessages.ArchiveView', 'ChatMessages', 'vwCHAT_MESSAGES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.ArchiveView'   , -1, 'ChatMessages.LBL_NAME'                   , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.ArchiveView'   , -1, 'ChatMessages.LBL_CHAT_CHANNEL_NAME'      , 'CHAT_CHANNEL_NAME'                     , '{0}'        , 'CHAT_CHANNEL_ID'   , '~/ChatChannels/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.ArchiveView'   , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.ArchiveView'   , -1, '.LBL_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.ArchiveView'   , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ChatMessages.ArchiveView'   , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.ArchiveView'   , -1, 'Notes.LBL_FILENAME'                      , 'FILENAME'                              , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}&ArchiveView=1' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'ChatMessages.ArchiveView'   , -1, 'PARENT_TYPE'                             , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}&ArchiveView=1'     , null, null;
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

call dbo.spDETAILVIEWS_FIELDS_ArchiveView()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_ArchiveView')
/

-- #endif IBM_DB2 */

