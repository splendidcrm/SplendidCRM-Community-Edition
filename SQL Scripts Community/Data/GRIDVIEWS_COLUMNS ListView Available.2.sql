

print 'GRIDVIEWS_COLUMNS ListView Available';
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME like '%.ListView.Available'
--GO

set nocount on;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.ListView.Available'        , 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_WEBSITE'                            , 'WEBSITE'                    , 'WEBSITE'                    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_PHONE_FAX'                          , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_ACCOUNT_TYPE'                       , 'ACCOUNT_TYPE'               , 'ACCOUNT_TYPE'               , '10%', 'account_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_PHONE_ALTERNATE'                    , 'PHONE_ALTERNATE'            , 'PHONE_ALTERNATE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_EMAIL1'                             , 'EMAIL1'                     , 'EMAIL1'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_EMPLOYEES'                          , 'EMPLOYEES'                  , 'EMPLOYEES'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_EMAIL2'                             , 'EMAIL2'                     , 'EMAIL2'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_EMAIL_OPT_OUT'                      , 'EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'              , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_OWNERSHIP'                          , 'OWNERSHIP'                  , 'OWNERSHIP'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_RATING'                             , 'RATING'                     , 'RATING'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_INDUSTRY'                           , 'INDUSTRY'                   , 'INDUSTRY'                   , '10%', 'industry_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SIC_CODE'                           , 'SIC_CODE'                   , 'SIC_CODE'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_PARENT_NAME'                        , 'PARENT_NAME'                , 'PARENT_NAME'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_ANNUAL_REVENUE'                     , 'ANNUAL_REVENUE'             , 'ANNUAL_REVENUE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_EXCHANGE_FOLDER'                    , 'EXCHANGE_FOLDER'            , 'EXCHANGE_FOLDER'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_NAICS_SET_NAME'                     , 'NAICS_SET_NAME'             , 'NAICS_SET_NAME'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_BILLING_ADDRESS_STREET'             , 'BILLING_ADDRESS_STREET'     , 'BILLING_ADDRESS_STREET'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_STREET'            , 'SHIPPING_ADDRESS_STREET'    , 'SHIPPING_ADDRESS_STREET'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_CITY'              , 'SHIPPING_ADDRESS_CITY'      , 'SHIPPING_ADDRESS_CITY'      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_STATE'             , 'SHIPPING_ADDRESS_STATE'     , 'SHIPPING_ADDRESS_STATE'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_BILLING_ADDRESS_POSTALCODE'         , 'BILLING_ADDRESS_POSTALCODE' , 'BILLING_ADDRESS_POSTALCODE' , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_POSTALCODE'        , 'SHIPPING_ADDRESS_POSTALCODE', 'SHIPPING_ADDRESS_POSTALCODE', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_BILLING_ADDRESS_COUNTRY'            , 'BILLING_ADDRESS_COUNTRY'    , 'BILLING_ADDRESS_COUNTRY'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ListView.Available'        , null, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_COUNTRY'           , 'SHIPPING_ADDRESS_COUNTRY'   , 'SHIPPING_ADDRESS_COUNTRY'   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.ListView.Available'        , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.ListView.Available'        , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.ListView.Available'            , 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView.Available'            , null, 'Bugs.LBL_LIST_LAST_ACTIVITY_DATE'                     , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.ListView.Available'            , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView.Available'            , null, 'Bugs.LBL_LIST_SOURCE'                                 , 'SOURCE'                     , 'SOURCE'                     , '10%', 'source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.ListView.Available'            , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView.Available'            , null, 'Bugs.LBL_LIST_PRODUCT_CATEGORY'                       , 'PRODUCT_CATEGORY'           , 'PRODUCT_CATEGORY'           , '10%', 'product_category_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ListView.Available'            , null, 'Bugs.LBL_LIST_RESOLUTION'                             , 'RESOLUTION'                 , 'RESOLUTION'                 , '10%', 'bug_resolution_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ListView.Available'            , null, 'Bugs.LBL_LIST_FIXED_IN_RELEASE'                       , 'FIXED_IN_RELEASE'           , 'FIXED_IN_RELEASE'           , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.ListView.Available'           , 'Calls', 'vwCALLS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_DIRECTION STATUS'                      , 'DIRECTION STATUS'           , 'DIRECTION STATUS'           , '10%', 'call_direction_dom call_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_DURATION_HOURS'                        , 'DURATION_HOURS'             , 'DURATION_HOURS'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_DURATION_MINUTES'                      , 'DURATION_MINUTES'           , 'DURATION_MINUTES'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ListView.Available'           , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ListView.Available'           , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_REPEAT_TYPE'                           , 'REPEAT_TYPE'                , 'REPEAT_TYPE'                , '10%', 'repeat_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_REPEAT_COUNT'                          , 'REPEAT_COUNT'               , 'REPEAT_COUNT'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_REPEAT_INTERVAL'                       , 'REPEAT_INTERVAL'            , 'REPEAT_INTERVAL'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ListView.Available'           , null, 'Calls.LBL_LIST_REPEAT_UNTIL'                          , 'REPEAT_UNTIL'               , 'REPEAT_UNTIL'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Campaigns.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Campaigns.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Campaigns.ListView.Available'       , 'Campaigns', 'vwCAMPAIGNS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_START_DATE'                        , 'START_DATE'                 , 'START_DATE'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.ListView.Available'       , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Campaigns.ListView.Available'       , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_BUDGET_USDOLLAR'                   , 'BUDGET_USDOLLAR'            , 'BUDGET_USDOLLAR'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_ACTUAL_COST_USDOLLAR'              , 'ACTUAL_COST_USDOLLAR'       , 'ACTUAL_COST_USDOLLAR'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_EXPECTED_REVENUE_USDOLLAR'         , 'EXPECTED_REVENUE_USDOLLAR'  , 'EXPECTED_REVENUE_USDOLLAR'  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_EXPECTED_COST_USDOLLAR'            , 'EXPECTED_COST_USDOLLAR'     , 'EXPECTED_COST_USDOLLAR'     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_IMPRESSIONS'                       , 'IMPRESSIONS'                , 'IMPRESSIONS'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_OBJECTIVE'                         , 'OBJECTIVE'                  , 'OBJECTIVE'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Campaigns.ListView.Available'       , null, 'Campaigns.LBL_LIST_CONTENT'                           , 'CONTENT'                    , 'CONTENT'                    , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.ListView.Available'           , 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ListView.Available'           , null, 'Cases.LBL_LIST_TYPE'                                  , 'TYPE'                       , 'TYPE'                       , '10%', 'case_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.ListView.Available'           , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ListView.Available'           , null, 'Cases.LBL_LIST_LAST_ACTIVITY_DATE'                    , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.ListView.Available'           , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ListView.Available'        , 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_FIRST_NAME'                         , 'FIRST_NAME'                 , 'FIRST_NAME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_LAST_NAME'                          , 'LAST_NAME'                  , 'LAST_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_LAST_ACTIVITY_DATE'                 , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PHONE_MOBILE'                       , 'PHONE_MOBILE'               , 'PHONE_MOBILE'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PHONE_HOME'                         , 'PHONE_HOME'                 , 'PHONE_HOME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_LEAD_SOURCE'                        , 'LEAD_SOURCE'                , 'LEAD_SOURCE'                , '10%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PHONE_OTHER'                        , 'PHONE_OTHER'                , 'PHONE_OTHER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PHONE_FAX'                          , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_DEPARTMENT'                         , 'DEPARTMENT'                 , 'DEPARTMENT'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_BIRTHDATE'                          , 'BIRTHDATE'                  , 'BIRTHDATE'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_EMAIL2'                             , 'EMAIL2'                     , 'EMAIL2'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_REPORTS_TO_NAME'                    , 'REPORTS_TO_NAME'            , 'REPORTS_TO_NAME'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_ASSISTANT'                          , 'ASSISTANT'                  , 'ASSISTANT'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_SYNC_CONTACT'                       , 'SYNC_CONTACT'               , 'SYNC_CONTACT'               , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_ASSISTANT_PHONE'                    , 'ASSISTANT_PHONE'            , 'ASSISTANT_PHONE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_DO_NOT_CALL'                        , 'DO_NOT_CALL'                , 'DO_NOT_CALL'                , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_EMAIL_OPT_OUT'                      , 'EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'              , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView.Available'        , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ListView.Available'        , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_HTML'               , 'PRIMARY_ADDRESS_HTML'       , 'PRIMARY_ADDRESS_HTML'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_ALT_ADDRESS_HTML'                   , 'ALT_ADDRESS_HTML'           , 'ALT_ADDRESS_HTML'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_PROBABILITY'                        , 'PROBABILITY'                , 'PROBABILITY'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ListView.Available'        , null, 'Contacts.LBL_LIST_SCORE'                              , 'SCORE'                      , 'SCORE'                      , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.ListView.Available'       , 'Documents', 'vwDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_DOCUMENT_NAME'                     , 'DOCUMENT_NAME'              , 'DOCUMENT_NAME'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_TEMPLATE_TYPE'                     , 'TEMPLATE_TYPE'              , 'TEMPLATE_TYPE'              , '10%', 'document_template_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_IS_TEMPLATE'                       , 'IS_TEMPLATE'                , 'IS_TEMPLATE'                , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_STATUS_ID'                         , 'STATUS_ID'                  , 'STATUS_ID'                  , '10%', 'document_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_FILENAME'                          , 'FILENAME'                   , 'FILENAME'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.ListView.Available'       , null, 'Documents.LBL_LIST_PRIMARY_MODULE'                    , 'PRIMARY_MODULE'             , 'PRIMARY_MODULE'             , '10%', 'Modules';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ListView.Available'          , 'Emails', 'vwEMAILS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_DATE_START'                           , 'DATE_START'                 , 'DATE_START'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_TEAM_NAME'                            , 'TEAM_NAME'                  , 'TEAM_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ListView.Available'          , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ListView.Available'          , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_FROM_NAME'                            , 'FROM_NAME'                  , 'FROM_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_FROM_ADDR'                            , 'FROM_ADDR'                  , 'FROM_ADDR'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_TO_ADDRS'                             , 'TO_ADDRS'                   , 'TO_ADDRS'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_CC_ADDRS'                             , 'CC_ADDRS'                   , 'CC_ADDRS'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ListView.Available'          , null, 'Emails.LBL_LIST_BCC_ADDRS'                            , 'BCC_ADDRS'                  , 'BCC_ADDRS'                  , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'EmailTemplates.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS EmailTemplates.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'EmailTemplates.ListView.Available'  , 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailTemplates.ListView.Available'  , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'EmailTemplates.ListView.Available'  , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.ListView.Available'  , null, 'EmailTemplates.LBL_LIST_SUBJECT'                      , 'SUBJECT'                    , 'SUBJECT'                    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.ListView.Available'  , null, 'EmailTemplates.LBL_LIST_TEAM_NAME'                    , 'TEAM_NAME'                  , 'TEAM_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'EmailTemplates.ListView.Available'  , null, 'EmailTemplates.LBL_LIST_ASSIGNED_TO_NAME'             , 'ASSIGNED_TO_NAME'           , 'ASSIGNED_TO_NAME'           , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.ListView.Available'       , 'Employees', 'vwEMPLOYEES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_TITLE'                             , 'TITLE'                      , 'TITLE'                      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_PHONE_MOBILE'                      , 'PHONE_MOBILE'               , 'PHONE_MOBILE'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_PHONE_OTHER'                       , 'PHONE_OTHER'                , 'PHONE_OTHER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_PHONE_FAX'                         , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_PHONE_HOME'                        , 'PHONE_HOME'                 , 'PHONE_HOME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_EMAIL2'                            , 'EMAIL2'                     , 'EMAIL2'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_MESSENGER_TYPE'                    , 'MESSENGER_TYPE'             , 'MESSENGER_TYPE'             , '10%', 'messenger_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_MESSENGER_ID'                      , 'MESSENGER_ID'               , 'MESSENGER_ID'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.ListView.Available'       , null, 'Employees.LBL_LIST_ADDRESS_HTML'                      , 'ADDRESS_HTML'               , 'ADDRESS_HTML'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ListView.Available'           , 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_WEBSITE'                               , 'WEBSITE'                    , 'WEBSITE'                    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_LEAD_SOURCE'                           , 'LEAD_SOURCE'                , 'LEAD_SOURCE'                , '10%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'               , 'LEAD_SOURCE_DESCRIPTION'    , 'LEAD_SOURCE_DESCRIPTION'    , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_STATUS_DESCRIPTION'                    , 'STATUS_DESCRIPTION'         , 'STATUS_DESCRIPTION'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_REFERED_BY'                            , 'REFERED_BY'                 , 'REFERED_BY'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_FIRST_NAME'                            , 'FIRST_NAME'                 , 'FIRST_NAME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_LAST_NAME'                             , 'LAST_NAME'                  , 'LAST_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PHONE_MOBILE'                          , 'PHONE_MOBILE'               , 'PHONE_MOBILE'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_LAST_ACTIVITY_DATE'                    , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PHONE_HOME'                            , 'PHONE_HOME'                 , 'PHONE_HOME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PHONE_OTHER'                           , 'PHONE_OTHER'                , 'PHONE_OTHER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PHONE_FAX'                             , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_TITLE'                                 , 'TITLE'                      , 'TITLE'                      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_DEPARTMENT'                            , 'DEPARTMENT'                 , 'DEPARTMENT'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_EMAIL2'                                , 'EMAIL2'                     , 'EMAIL2'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_DO_NOT_CALL'                           , 'DO_NOT_CALL'                , 'DO_NOT_CALL'                , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_EMAIL_OPT_OUT'                         , 'EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'              , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.ListView.Available'           , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.ListView.Available'           , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PRIMARY_ADDRESS_HTML'                  , 'PRIMARY_ADDRESS_HTML'       , 'PRIMARY_ADDRESS_HTML'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_ALT_ADDRESS_HTML'                      , 'ALT_ADDRESS_HTML'           , 'ALT_ADDRESS_HTML'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_PROBABILITY'                           , 'PROBABILITY'                , 'PROBABILITY'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ListView.Available'           , null, 'Leads.LBL_LIST_SCORE'                                 , 'SCORE'                      , 'SCORE'                      , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.ListView.Available'        , 'Meetings', 'vwMEETINGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_LOCATION'                           , 'LOCATION'                   , 'LOCATION'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_DURATION_HOURS'                     , 'DURATION_HOURS'             , 'DURATION_HOURS'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_DURATION_MINUTES'                   , 'DURATION_MINUTES'           , 'DURATION_MINUTES'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ListView.Available'        , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ListView.Available'        , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_REPEAT_TYPE'                        , 'REPEAT_TYPE'                , 'REPEAT_TYPE'                , '10%', 'repeat_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_REPEAT_COUNT'                       , 'REPEAT_COUNT'               , 'REPEAT_COUNT'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_REPEAT_INTERVAL'                    , 'REPEAT_INTERVAL'            , 'REPEAT_INTERVAL'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ListView.Available'        , null, 'Meetings.LBL_LIST_REPEAT_UNTIL'                       , 'REPEAT_UNTIL'               , 'REPEAT_UNTIL'               , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Notes.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Notes.ListView.Available'           , 'Notes', 'vwNOTES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView.Available'           , null, 'Notes.LBL_LIST_CONTACT_PHONE'                         , 'CONTACT_PHONE'              , 'CONTACT_PHONE'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Notes.ListView.Available'           , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView.Available'           , null, 'Notes.LBL_LIST_CONTACT_EMAIL'                         , 'CONTACT_EMAIL'              , 'CONTACT_EMAIL'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Notes.ListView.Available'           , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ListView.Available'           , null, 'Notes.LBL_LIST_TEAM_NAME'                             , 'TEAM_NAME'                  , 'TEAM_NAME'                  , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.ListView.Available'   , 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView.Available'   , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_LAST_ACTIVITY_DATE'            , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_CAMPAIGN_NAME'                 , 'CAMPAIGN_NAME'              , 'CAMPAIGN_NAME'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ListView.Available'   , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_OPPORTUNITY_TYPE'              , 'OPPORTUNITY_TYPE'           , 'OPPORTUNITY_TYPE'           , '10%', 'opportunity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_NEXT_STEP'                     , 'NEXT_STEP'                  , 'NEXT_STEP'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_LEAD_SOURCE'                   , 'LEAD_SOURCE'                , 'LEAD_SOURCE'                , '10%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_PROBABILITY'                   , 'PROBABILITY'                , 'PROBABILITY'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_ML_PROBABILITY'                , 'ML_PROBABILITY'             , 'ML_PROBABILITY'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ListView.Available'   , null, 'Opportunities.LBL_LIST_SCORE'                         , 'SCORE'                      , 'SCORE'                      , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ListView.Available'         , 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ListView.Available'         , null, 'Project.LBL_LIST_LAST_ACTIVITY_DATE'                  , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ListView.Available'         , null, 'Project.LBL_LIST_PRIORITY'                            , 'PRIORITY'                   , 'PRIORITY'                   , '10%', 'projects_priority_options';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.ListView.Available'     , 'ProjectTask', 'vwPROJECT_TASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_TASK_NUMBER'                     , 'TASK_NUMBER'                , 'TASK_NUMBER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_DEPENDS_ON_NAME'                 , 'DEPENDS_ON_NAME'            , 'DEPENDS_ON_NAME'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_PRIORITY'                        , 'PRIORITY'                   , 'PRIORITY'                   , '10%', 'project_task_priority_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_MILESTONE_FLAG'                  , 'MILESTONE_FLAG'             , 'MILESTONE_FLAG'             , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'                , 'PERCENT_COMPLETE'           , 'PERCENT_COMPLETE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_UTILIZATION'                     , 'UTILIZATION'                , 'UTILIZATION'                , '10%', 'project_task_utilization_options';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_DATE_START'                      , 'DATE_START'                 , 'DATE_START'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_ESTIMATED_EFFORT'                , 'ESTIMATED_EFFORT'           , 'ESTIMATED_EFFORT'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.ListView.Available'     , null, 'ProjectTask.LBL_LIST_ACTUAL_EFFORT'                   , 'ACTUAL_EFFORT'              , 'ACTUAL_EFFORT'              , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProspectLists.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProspectLists.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProspectLists.ListView.Available'   , 'ProspectLists', 'vwPROSPECT_LISTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProspectLists.ListView.Available'   , null, 'ProspectLists.LBL_LIST_DYNAMIC_LIST'                  , 'DYNAMIC_LIST'               , 'DYNAMIC_LIST'               , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView.Available'   , null, 'ProspectLists.LBL_LIST_DOMAIN_NAME'                   , 'DOMAIN_NAME'                , 'DOMAIN_NAME'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView.Available'   , null, 'ProspectLists.LBL_LIST_CREATED_BY_NAME'               , 'CREATED_BY_NAME'            , 'CREATED_BY_NAME'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProspectLists.ListView.Available'   , null, 'ProspectLists.LBL_LIST_MODIFIED_BY_NAME'              , 'MODIFIED_BY_NAME'           , 'MODIFIED_BY_NAME'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProspectLists.ListView.Available'   , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ProspectLists.ListView.Available'   , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ListView.Available'       , 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_FIRST_NAME'                        , 'FIRST_NAME'                 , 'FIRST_NAME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_LAST_NAME'                         , 'LAST_NAME'                  , 'LAST_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_LAST_ACTIVITY_DATE'                , 'LAST_ACTIVITY_DATE'         , 'LAST_ACTIVITY_DATE'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PHONE_MOBILE'                      , 'PHONE_MOBILE'               , 'PHONE_MOBILE'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PHONE_HOME'                        , 'PHONE_HOME'                 , 'PHONE_HOME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PHONE_OTHER'                       , 'PHONE_OTHER'                , 'PHONE_OTHER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PHONE_FAX'                         , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_DEPARTMENT'                        , 'DEPARTMENT'                 , 'DEPARTMENT'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_BIRTHDATE'                         , 'BIRTHDATE'                  , 'BIRTHDATE'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_EMAIL2'                            , 'EMAIL2'                     , 'EMAIL2'                     , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_ASSISTANT'                         , 'ASSISTANT'                  , 'ASSISTANT'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_ASSISTANT_PHONE'                   , 'ASSISTANT_PHONE'            , 'ASSISTANT_PHONE'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_DO_NOT_CALL'                       , 'DO_NOT_CALL'                , 'DO_NOT_CALL'                , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_EMAIL_OPT_OUT'                     , 'EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'              , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_INVALID_EMAIL'                     , 'INVALID_EMAIL'              , 'INVALID_EMAIL'              , '10%', 'CheckBox';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ListView.Available'       , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ListView.Available'       , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_HTML'              , 'PRIMARY_ADDRESS_HTML'       , 'PRIMARY_ADDRESS_HTML'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_ALT_ADDRESS_HTML'                  , 'ALT_ADDRESS_HTML'           , 'ALT_ADDRESS_HTML'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_PROBABILITY'                       , 'PROBABILITY'                , 'PROBABILITY'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ListView.Available'       , null, 'Prospects.LBL_LIST_SCORE'                             , 'SCORE'                      , 'SCORE'                      , '10%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SmsMessages.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SmsMessages.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'SmsMessages.ListView.Available'     , 'SmsMessages', 'vwSMS_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView.Available'     , null, 'SmsMessages.LBL_LIST_FROM_LOCATION'                   , 'FROM_LOCATION'              , 'FROM_LOCATION'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView.Available'     , null, 'SmsMessages.LBL_LIST_TO_LOCATION'                     , 'TO_LOCATION'                , 'TO_LOCATION'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ListView.Available'     , null, 'SmsMessages.LBL_LIST_TEAM_NAME'                       , 'TEAM_NAME'                  , 'TEAM_NAME'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SmsMessages.ListView.Available'     , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SmsMessages.ListView.Available'     , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.ListView.Available'           , 'Tasks', 'vwTASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Tasks.ListView.Available'           , null, 'Tasks.LBL_LIST_STATUS'                                , 'STATUS'                     , 'STATUS'                     , '10%', 'task_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView.Available'           , null, 'Tasks.LBL_LIST_DATE_START'                            , 'DATE_START'                 , 'DATE_START'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Tasks.ListView.Available'           , null, 'Tasks.LBL_LIST_PRIORITY'                              , 'PRIORITY'                   , 'PRIORITY'                   , '10%', 'task_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView.Available'           , null, 'Tasks.LBL_LIST_CONTACT_EMAIL'                         , 'CONTACT_EMAIL'              , 'CONTACT_EMAIL'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ListView.Available'           , null, 'Tasks.LBL_LIST_CONTACT_PHONE'                         , 'CONTACT_PHONE'              , 'CONTACT_PHONE'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.ListView.Available'           , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.ListView.Available'           , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS TwitterMessages.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'TwitterMessages.ListView.Available' , 'TwitterMessages', 'vwTWITTER_MESSAGES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView.Available' , null, 'TwitterMessages.LBL_LIST_DESCRIPTION'                 , 'DESCRIPTION'                , 'DESCRIPTION'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ListView.Available' , null, 'TwitterMessages.LBL_LIST_TWITTER_FULL_NAME'           , 'TWITTER_FULL_NAME'          , 'TWITTER_FULL_NAME'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ListView.Available' , null, '.LBL_LIST_DATE_MODIFIED'                              , 'DATE_MODIFIED'              , 'DATE_MODIFIED'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ListView.Available' , null, '.LBL_LIST_DATE_ENTERED'                               , 'DATE_ENTERED'               , 'DATE_ENTERED'               , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.ListView.Available' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.ListView.Available';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.ListView.Available'           , 'Users', 'vwUSERS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Users.ListView.Available'           , null, 'Users.LBL_LIST_EMPLOYEE_STATUS'                       , 'EMPLOYEE_STATUS'            , 'EMPLOYEE_STATUS'            , '10%', 'employee_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_TITLE'                                 , 'TITLE'                      , 'TITLE'                      , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_PHONE_MOBILE'                          , 'PHONE_MOBILE'               , 'PHONE_MOBILE'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_PHONE_OTHER'                           , 'PHONE_OTHER'                , 'PHONE_OTHER'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_EXTENSION'                             , 'EXTENSION'                  , 'EXTENSION'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_PHONE_FAX'                             , 'PHONE_FAX'                  , 'PHONE_FAX'                  , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_PHONE_HOME'                            , 'PHONE_HOME'                 , 'PHONE_HOME'                 , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.ListView.Available'           , null, 'Users.LBL_LIST_ADDRESS_HTML'                          , 'ADDRESS_HTML'               , 'ADDRESS_HTML'               , '10%';
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

call dbo.spGRIDVIEWS_COLUMNS_ListViewsAvailable()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ListViewsAvailable')
/

-- #endif IBM_DB2 */

