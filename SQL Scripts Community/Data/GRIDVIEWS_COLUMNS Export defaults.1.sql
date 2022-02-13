

print 'GRIDVIEWS_COLUMNS ListView defaults';
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export'
--GO

set nocount on;
GO

-- 05/24/2020 Paul.  Correct for global terms for DATE_ENTERED, DATE_MODIFIED, TEAM_NAME, ASSIGNED_TO_NAME, CREATED_BY_NAME, MODIFIED_BY_NAME
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Export'         , 'Accounts', 'vwACCOUNTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  1, 'Accounts.LBL_LIST_NAME'                       , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  2, 'Accounts.LBL_LIST_PHONE_OFFICE'               , 'PHONE_OFFICE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  3, 'Accounts.LBL_LIST_PHONE'                      , 'PHONE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  4, 'Accounts.LBL_LIST_PHONE_FAX'                  , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  5, 'Accounts.LBL_LIST_PHONE_ALTERNATE'            , 'PHONE_ALTERNATE'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  6, 'Accounts.LBL_LIST_WEBSITE'                    , 'WEBSITE'                    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  7, 'Accounts.LBL_LIST_EMAIL1'                     , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  8, 'Accounts.LBL_LIST_EMAIL2'                     , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         ,  9, 'Accounts.LBL_LIST_ANNUAL_REVENUE'             , 'ANNUAL_REVENUE'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 10, 'Accounts.LBL_LIST_EMPLOYEES'                  , 'EMPLOYEES'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 11, 'Accounts.LBL_LIST_INDUSTRY'                   , 'INDUSTRY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 12, 'Accounts.LBL_LIST_OWNERSHIP'                  , 'OWNERSHIP'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 13, 'Accounts.LBL_LIST_ACCOUNT_TYPE'               , 'ACCOUNT_TYPE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 14, 'Accounts.LBL_LIST_TICKER_SYMBOL'              , 'TICKER_SYMBOL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 15, 'Accounts.LBL_LIST_RATING'                     , 'RATING'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 16, 'Accounts.LBL_LIST_SIC_CODE'                   , 'SIC_CODE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 17, 'Accounts.LBL_LIST_BILLING_ADDRESS_STREET'     , 'BILLING_ADDRESS_STREET'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 18, 'Accounts.LBL_LIST_BILLING_ADDRESS_CITY'       , 'BILLING_ADDRESS_CITY'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 19, 'Accounts.LBL_LIST_BILLING_ADDRESS_STATE'      , 'BILLING_ADDRESS_STATE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 20, 'Accounts.LBL_LIST_BILLING_ADDRESS_POSTALCODE' , 'BILLING_ADDRESS_POSTALCODE' , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 21, 'Accounts.LBL_LIST_BILLING_ADDRESS_COUNTRY'    , 'BILLING_ADDRESS_COUNTRY'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 22, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_STREET'    , 'SHIPPING_ADDRESS_STREET'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 23, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_CITY'      , 'SHIPPING_ADDRESS_CITY'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 24, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_STATE'     , 'SHIPPING_ADDRESS_STATE'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 25, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_POSTALCODE', 'SHIPPING_ADDRESS_POSTALCODE', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 26, 'Accounts.LBL_LIST_SHIPPING_ADDRESS_COUNTRY'   , 'SHIPPING_ADDRESS_COUNTRY'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 27, 'Accounts.LBL_LIST_PARENT_NAME'                , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 28, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 29, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 30, 'Accounts.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 31, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 32, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 33, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 34, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.Export'         , 35, 'Accounts.LBL_LIST_CONTACT_NAME'               , 'CONTACT_NAME'               , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.Export'             , 'Bugs', 'vwBUGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  1, 'Bugs.LBL_LIST_BUG_NUMBER'                     , 'BUG_NUMBER'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  2, 'Bugs.LBL_LIST_NAME'                           , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  3, 'Bugs.LBL_LIST_STATUS'                         , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  4, 'Bugs.LBL_LIST_PRIORITY'                       , 'PRIORITY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  5, 'Bugs.LBL_LIST_RESOLUTION'                     , 'RESOLUTION'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  6, 'Bugs.LBL_LIST_FOUND_IN_RELEASE'               , 'FOUND_IN_RELEASE'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  7, 'Bugs.LBL_LIST_TYPE'                           , 'TYPE'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  8, 'Bugs.LBL_LIST_FIXED_IN_RELEASE'               , 'FIXED_IN_RELEASE'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             ,  9, 'Bugs.LBL_LIST_SOURCE'                         , 'SOURCE'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 10, 'Bugs.LBL_LIST_PRODUCT_CATEGORY'               , 'PRODUCT_CATEGORY'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 11, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 12, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 13, 'Bugs.LBL_LIST_DESCRIPTION'                    , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 14, 'Bugs.LBL_LIST_WORK_LOG'                       , 'WORK_LOG'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 15, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 16, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 17, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.Export'             , 18, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.Export'            , 'Calls', 'vwCALLS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  1, 'Calls.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  2, 'Calls.LBL_LIST_DURATION_HOURS'                , 'DURATION_HOURS'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  3, 'Calls.LBL_LIST_DURATION_MINUTES'              , 'DURATION_MINUTES'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  4, 'Calls.LBL_LIST_DATE_START'                    , 'DATE_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  5, 'Calls.LBL_LIST_DATE_END'                      , 'DATE_END'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  6, 'Calls.LBL_LIST_PARENT_TYPE'                   , 'PARENT_TYPE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  7, 'Calls.LBL_LIST_STATUS'                        , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  8, 'Calls.LBL_LIST_DIRECTION'                     , 'DIRECTION'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            ,  9, 'Calls.LBL_LIST_REMINDER_TIME'                 , 'REMINDER_TIME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 10, 'Calls.LBL_LIST_PARENT_NAME'                   , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 11, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 12, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 13, 'Calls.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 14, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 15, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 16, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 17, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.Export'            , 18, 'Calls.LBL_LIST_CONTACT_NAME'                  , 'CONTACT_NAME'               , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.Export'            , 'Cases', 'vwCASES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  1, 'Cases.LBL_LIST_CASE_NUMBER'                   , 'CASE_NUMBER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  2, 'Cases.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  3, 'Cases.LBL_LIST_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  4, 'Cases.LBL_LIST_STATUS'                        , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  5, 'Cases.LBL_LIST_PRIORITY'                      , 'PRIORITY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  6, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  7, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  8, 'Cases.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            ,  9, 'Cases.LBL_LIST_RESOLUTION'                    , 'RESOLUTION'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            , 10, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            , 11, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            , 12, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.Export'            , 13, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Export'         , 'Contacts', 'vwCONTACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  1, 'Contacts.LBL_LIST_SALUTATION'                 , 'SALUTATION'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  2, 'Contacts.LBL_LIST_NAME'                       , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  3, 'Contacts.LBL_LIST_FIRST_NAME'                 , 'FIRST_NAME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  4, 'Contacts.LBL_LIST_LAST_NAME'                  , 'LAST_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  5, 'Contacts.LBL_LIST_LEAD_SOURCE'                , 'LEAD_SOURCE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  6, 'Contacts.LBL_LIST_TITLE'                      , 'TITLE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  7, 'Contacts.LBL_LIST_DEPARTMENT'                 , 'DEPARTMENT'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  8, 'Contacts.LBL_LIST_REPORTS_TO_NAME'            , 'REPORTS_TO_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         ,  9, 'Contacts.LBL_LIST_BIRTHDATE'                  , 'BIRTHDATE'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 10, 'Contacts.LBL_LIST_DO_NOT_CALL'                , 'DO_NOT_CALL'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 11, 'Contacts.LBL_LIST_PHONE_HOME'                 , 'PHONE_HOME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 12, 'Contacts.LBL_LIST_PHONE_MOBILE'               , 'PHONE_MOBILE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 13, 'Contacts.LBL_LIST_PHONE_WORK'                 , 'PHONE_WORK'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 14, 'Contacts.LBL_LIST_PHONE_OTHER'                , 'PHONE_OTHER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 15, 'Contacts.LBL_LIST_PHONE_FAX'                  , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 16, 'Contacts.LBL_LIST_EMAIL1'                     , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 17, 'Contacts.LBL_LIST_EMAIL2'                     , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 18, 'Contacts.LBL_LIST_ASSISTANT'                  , 'ASSISTANT'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 19, 'Contacts.LBL_LIST_ASSISTANT_PHONE'            , 'ASSISTANT_PHONE'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 20, 'Contacts.LBL_LIST_EMAIL_OPT_OUT'              , 'EMAIL_OPT_OUT'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 21, 'Contacts.LBL_LIST_INVALID_EMAIL'              , 'INVALID_EMAIL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 22, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_STREET'     , 'PRIMARY_ADDRESS_STREET'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 23, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_CITY'       , 'PRIMARY_ADDRESS_CITY'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 24, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_STATE'      , 'PRIMARY_ADDRESS_STATE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 25, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_POSTALCODE' , 'PRIMARY_ADDRESS_POSTALCODE' , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 26, 'Contacts.LBL_LIST_PRIMARY_ADDRESS_COUNTRY'    , 'PRIMARY_ADDRESS_COUNTRY'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 27, 'Contacts.LBL_LIST_ALT_ADDRESS_STREET'         , 'ALT_ADDRESS_STREET'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 28, 'Contacts.LBL_LIST_ALT_ADDRESS_CITY'           , 'ALT_ADDRESS_CITY'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 29, 'Contacts.LBL_LIST_ALT_ADDRESS_STATE'          , 'ALT_ADDRESS_STATE'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 30, 'Contacts.LBL_LIST_ALT_ADDRESS_POSTALCODE'     , 'ALT_ADDRESS_POSTALCODE'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 31, 'Contacts.LBL_LIST_ALT_ADDRESS_COUNTRY'        , 'ALT_ADDRESS_COUNTRY'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 32, 'Contacts.LBL_LIST_PORTAL_NAME'                , 'PORTAL_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 33, 'Contacts.LBL_LIST_PORTAL_ACTIVE'              , 'PORTAL_ACTIVE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 34, 'Contacts.LBL_LIST_PORTAL_APP'                 , 'PORTAL_APP'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 35, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 36, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 37, 'Contacts.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 38, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 39, 'Contacts.LBL_LIST_ACCOUNT_NAME'               , 'ACCOUNT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 40, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 41, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.Export'         , 42, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Export'        , 'Documents', 'vwDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  1, 'Documents.LBL_LIST_NAME'                      , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  2, 'Documents.LBL_LIST_DOCUMENT_NAME'             , 'DOCUMENT_NAME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  3, 'Documents.LBL_LIST_ACTIVE_DATE'               , 'ACTIVE_DATE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  4, 'Documents.LBL_LIST_EXP_DATE'                  , 'EXP_DATE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  5, 'Documents.LBL_LIST_MAIL_MERGE_DOCUMENT'       , 'MAIL_MERGE_DOCUMENT'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  6, 'Documents.LBL_LIST_IS_TEMPLATE'               , 'IS_TEMPLATE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  7, 'Documents.LBL_LIST_TEMPLATE_TYPE'             , 'TEMPLATE_TYPE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  8, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        ,  9, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 10, 'Documents.LBL_LIST_FILENAME'                  , 'FILENAME'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 11, 'Documents.LBL_LIST_FILE_MIME_TYPE'            , 'FILE_MIME_TYPE'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 12, 'Documents.LBL_LIST_REVISION'                  , 'REVISION'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 13, 'Documents.LBL_LIST_REVISION_DATE_ENTERED'     , 'REVISION_DATE_ENTERED'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 14, 'Documents.LBL_LIST_REVISION_DATE_MODIFIED'    , 'REVISION_DATE_MODIFIED'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 15, 'Documents.LBL_LIST_REVISION_CREATED_BY'       , 'REVISION_CREATED_BY'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 16, 'Documents.LBL_LIST_REVISION_MODIFIED_BY'      , 'REVISION_MODIFIED_BY'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 17, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 18, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 19, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 20, 'Documents.LBL_LIST_REVISION_CREATED_BY_NAME'  , 'REVISION_CREATED_BY_NAME'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Export'        , 21, 'Documents.LBL_LIST_REVISION_MODIFIED_BY_NAME' , 'REVISION_MODIFIED_BY_NAME'  , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Export'           , 'Emails', 'vwEMAILS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  1, 'Emails.LBL_LIST_NAME'                         , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  2, 'Emails.LBL_LIST_DATE_START'                   , 'DATE_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  3, 'Emails.LBL_LIST_TIME_START'                   , 'TIME_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  4, 'Emails.LBL_LIST_PARENT_TYPE'                  , 'PARENT_TYPE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  5, 'Emails.LBL_LIST_FROM_ADDR'                    , 'FROM_ADDR'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  6, 'Emails.LBL_LIST_FROM_NAME'                    , 'FROM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  7, 'Emails.LBL_LIST_TYPE'                         , 'TYPE'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  8, 'Emails.LBL_LIST_STATUS'                       , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           ,  9, 'Emails.LBL_LIST_REPLY_TO_NAME'                , 'REPLY_TO_NAME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 10, 'Emails.LBL_LIST_REPLY_TO_ADDR'                , 'REPLY_TO_ADDR'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 11, 'Emails.LBL_LIST_INTENT'                       , 'INTENT'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 12, 'Emails.LBL_LIST_PARENT_NAME'                  , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 13, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 14, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 15, 'Emails.LBL_LIST_DESCRIPTION'                  , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 16, 'Emails.LBL_LIST_DESCRIPTION_HTML'             , 'DESCRIPTION_HTML'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 17, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 18, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 19, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 20, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 21, 'Emails.LBL_LIST_TYPE_TERM'                    , 'TYPE_TERM'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 22, 'Emails.LBL_LIST_CONTACT_NAME'                 , 'CONTACT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.Export'           , 23, 'Emails.LBL_LIST_ATTACHMENT_COUNT'             , 'ATTACHMENT_COUNT'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Employees.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Employees.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Employees.Export'        , 'Employees', 'vwEMPLOYEES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  1, 'Employees.LBL_LIST_FULL_NAME'                 , 'FULL_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  2, 'Employees.LBL_LIST_NAME'                      , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  3, 'Employees.LBL_LIST_USER_NAME'                 , 'USER_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  4, 'Employees.LBL_LIST_FIRST_NAME'                , 'FIRST_NAME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  5, 'Employees.LBL_LIST_LAST_NAME'                 , 'LAST_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  6, 'Employees.LBL_LIST_REPORTS_TO_NAME'           , 'REPORTS_TO_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  7, 'Employees.LBL_LIST_IS_ADMIN'                  , 'IS_ADMIN'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  8, 'Employees.LBL_LIST_PORTAL_ONLY'               , 'PORTAL_ONLY'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        ,  9, 'Employees.LBL_LIST_RECEIVE_NOTIFICATIONS'     , 'RECEIVE_NOTIFICATIONS'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 10, 'Employees.LBL_LIST_TITLE'                     , 'TITLE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 11, 'Employees.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 12, 'Employees.LBL_LIST_PHONE_HOME'                , 'PHONE_HOME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 13, 'Employees.LBL_LIST_PHONE_MOBILE'              , 'PHONE_MOBILE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 14, 'Employees.LBL_LIST_PHONE_WORK'                , 'PHONE_WORK'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 15, 'Employees.LBL_LIST_PHONE_OTHER'               , 'PHONE_OTHER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 16, 'Employees.LBL_LIST_PHONE_FAX'                 , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 17, 'Employees.LBL_LIST_EMAIL1'                    , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 18, 'Employees.LBL_LIST_EMAIL2'                    , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 19, 'Employees.LBL_LIST_STATUS'                    , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 20, 'Employees.LBL_LIST_EMPLOYEE_STATUS'           , 'EMPLOYEE_STATUS'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 21, 'Employees.LBL_LIST_MESSENGER_TYPE'            , 'MESSENGER_TYPE'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 22, 'Employees.LBL_LIST_ADDRESS_STREET'            , 'ADDRESS_STREET'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 23, 'Employees.LBL_LIST_ADDRESS_CITY'              , 'ADDRESS_CITY'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 24, 'Employees.LBL_LIST_ADDRESS_STATE'             , 'ADDRESS_STATE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 25, 'Employees.LBL_LIST_ADDRESS_COUNTRY'           , 'ADDRESS_COUNTRY'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 26, 'Employees.LBL_LIST_ADDRESS_POSTALCODE'        , 'ADDRESS_POSTALCODE'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 27, 'Employees.LBL_LIST_IS_GROUP'                  , 'IS_GROUP'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 28, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 29, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 30, 'Employees.LBL_LIST_DESCRIPTION'               , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 31, 'Employees.LBL_LIST_USER_PREFERENCES'          , 'USER_PREFERENCES'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 32, 'Employees.LBL_LIST_DEFAULT_TEAM'              , 'DEFAULT_TEAM'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 33, 'Employees.LBL_LIST_DEFAULT_TEAM_NAME'         , 'DEFAULT_TEAM_NAME'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 34, 'Employees.LBL_LIST_IS_ADMIN_DELEGATE'         , 'IS_ADMIN_DELEGATE'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 35, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 36, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 37, 'Employees.LBL_LIST_SYSTEM_GENERATED_PASSWORD' , 'SYSTEM_GENERATED_PASSWORD'  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 38, 'Employees.LBL_LIST_GOOGLEAPPS_SYNC_CONTACTS'  , 'GOOGLEAPPS_SYNC_CONTACTS'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 39, 'Employees.LBL_LIST_GOOGLEAPPS_SYNC_CALENDAR'  , 'GOOGLEAPPS_SYNC_CALENDAR'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 40, 'Employees.LBL_LIST_GOOGLEAPPS_USERNAME'       , 'GOOGLEAPPS_USERNAME'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Employees.Export'        , 41, 'Employees.LBL_LIST_GOOGLEAPPS_PASSWORD'       , 'GOOGLEAPPS_PASSWORD'        , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.Export'            , 'Leads', 'vwLEADS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  1, 'Leads.LBL_LIST_SALUTATION'                    , 'SALUTATION'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  2, 'Leads.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  3, 'Leads.LBL_LIST_FIRST_NAME'                    , 'FIRST_NAME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  4, 'Leads.LBL_LIST_LAST_NAME'                     , 'LAST_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  5, 'Leads.LBL_LIST_TITLE'                         , 'TITLE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  6, 'Leads.LBL_LIST_REFERED_BY'                    , 'REFERED_BY'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  7, 'Leads.LBL_LIST_LEAD_SOURCE'                   , 'LEAD_SOURCE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  8, 'Leads.LBL_LIST_STATUS'                        , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            ,  9, 'Leads.LBL_LIST_DEPARTMENT'                    , 'DEPARTMENT'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 10, 'Leads.LBL_LIST_DO_NOT_CALL'                   , 'DO_NOT_CALL'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 11, 'Leads.LBL_LIST_PHONE_HOME'                    , 'PHONE_HOME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 12, 'Leads.LBL_LIST_PHONE_MOBILE'                  , 'PHONE_MOBILE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 13, 'Leads.LBL_LIST_PHONE_WORK'                    , 'PHONE_WORK'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 14, 'Leads.LBL_LIST_PHONE_OTHER'                   , 'PHONE_OTHER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 15, 'Leads.LBL_LIST_PHONE_FAX'                     , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 16, 'Leads.LBL_LIST_EMAIL1'                        , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 17, 'Leads.LBL_LIST_EMAIL2'                        , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 18, 'Leads.LBL_LIST_ASSISTANT'                     , 'ASSISTANT'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 19, 'Leads.LBL_LIST_ASSISTANT_PHONE'               , 'ASSISTANT_PHONE'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 20, 'Leads.LBL_LIST_EMAIL_OPT_OUT'                 , 'EMAIL_OPT_OUT'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 21, 'Leads.LBL_LIST_INVALID_EMAIL'                 , 'INVALID_EMAIL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 22, 'Leads.LBL_LIST_PRIMARY_ADDRESS_STREET'        , 'PRIMARY_ADDRESS_STREET'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 23, 'Leads.LBL_LIST_PRIMARY_ADDRESS_CITY'          , 'PRIMARY_ADDRESS_CITY'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 24, 'Leads.LBL_LIST_PRIMARY_ADDRESS_STATE'         , 'PRIMARY_ADDRESS_STATE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 25, 'Leads.LBL_LIST_PRIMARY_ADDRESS_POSTALCODE'    , 'PRIMARY_ADDRESS_POSTALCODE' , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 26, 'Leads.LBL_LIST_PRIMARY_ADDRESS_COUNTRY'       , 'PRIMARY_ADDRESS_COUNTRY'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 27, 'Leads.LBL_LIST_ALT_ADDRESS_STREET'            , 'ALT_ADDRESS_STREET'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 28, 'Leads.LBL_LIST_ALT_ADDRESS_CITY'              , 'ALT_ADDRESS_CITY'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 29, 'Leads.LBL_LIST_ALT_ADDRESS_STATE'             , 'ALT_ADDRESS_STATE'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 30, 'Leads.LBL_LIST_ALT_ADDRESS_POSTALCODE'        , 'ALT_ADDRESS_POSTALCODE'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 31, 'Leads.LBL_LIST_ALT_ADDRESS_COUNTRY'           , 'ALT_ADDRESS_COUNTRY'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 32, 'Leads.LBL_LIST_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 33, 'Leads.LBL_LIST_CONVERTED_CONTACT_NAME'        , 'CONVERTED_CONTACT_NAME'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 34, 'Leads.LBL_LIST_CONVERTED_ACCOUNT_NAME'        , 'CONVERTED_ACCOUNT_NAME'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 35, 'Leads.LBL_LIST_OPPORTUNITY_NAME'              , 'CONVERTED_OPPORTUNITY_NAME'  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 36, 'Leads.LBL_LIST_OPPORTUNITY_AMOUNT'            , 'CONVERTED_OPPORTUNITY_AMOUNT', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 37, 'Leads.LBL_LIST_CAMPAIGN_NAME'                 , 'CAMPAIGN_NAME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 38, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 39, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 40, 'Leads.LBL_LIST_STATUS_DESCRIPTION'            , 'STATUS_DESCRIPTION'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 41, 'Leads.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 42, 'Leads.LBL_LIST_ACCOUNT_DESCRIPTION'           , 'ACCOUNT_DESCRIPTION'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 43, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 44, 'Leads.LBL_LIST_LEAD_SOURCE_DESCRIPTION'       , 'LEAD_SOURCE_DESCRIPTION'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 45, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 46, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.Export'            , 47, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end else begin
	-- 10/26/2015 Paul.  CONVERTED_OPPORTUNITY_NAME is the correct value. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Export' and DATA_FIELD = 'OPPORTUNITY_NAME' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD        = 'CONVERTED_OPPORTUNITY_NAME'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Leads.Export'
		   and DATA_FIELD        = 'OPPORTUNITY_NAME'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.Export' and DATA_FIELD = 'OPPORTUNITY_AMOUNT' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DATA_FIELD        = 'CONVERTED_OPPORTUNITY_AMOUNT'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Leads.Export'
		   and DATA_FIELD        = 'OPPORTUNITY_AMOUNT'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.Export'         , 'Meetings', 'vwMEETINGS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  1, 'Meetings.LBL_LIST_NAME'                       , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  2, 'Meetings.LBL_LIST_LOCATION'                   , 'LOCATION'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  3, 'Meetings.LBL_LIST_DURATION_HOURS'             , 'DURATION_HOURS'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  4, 'Meetings.LBL_LIST_DURATION_MINUTES'           , 'DURATION_MINUTES'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  5, 'Meetings.LBL_LIST_DATE_START'                 , 'DATE_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  6, 'Meetings.LBL_LIST_DATE_END'                   , 'DATE_END'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  7, 'Meetings.LBL_LIST_PARENT_TYPE'                , 'PARENT_TYPE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  8, 'Meetings.LBL_LIST_STATUS'                     , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         ,  9, 'Meetings.LBL_LIST_REMINDER_TIME'              , 'REMINDER_TIME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 10, 'Meetings.LBL_LIST_PARENT_NAME'                , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 11, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 12, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 13, 'Meetings.LBL_LIST_DESCRIPTION'                , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 14, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 15, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 16, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 17, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.Export'         , 18, 'Meetings.LBL_LIST_CONTACT_NAME'               , 'CONTACT_NAME'               , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Notes.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Notes.Export'            , 'Notes', 'vwNOTES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  1, 'Notes.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  2, 'Notes.LBL_LIST_PARENT_TYPE'                   , 'PARENT_TYPE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  3, 'Notes.LBL_LIST_PORTAL_FLAG'                   , 'PORTAL_FLAG'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  4, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  5, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  6, 'Notes.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  7, 'Notes.LBL_LIST_FILENAME'                      , 'FILENAME'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  8, 'Notes.LBL_LIST_FILE_MIME_TYPE'                , 'FILE_MIME_TYPE'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            ,  9, 'Notes.LBL_LIST_ATTACHMENT_READY'              , 'ATTACHMENT_READY'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 10, 'Notes.LBL_LIST_PARENT_NAME'                   , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 11, 'Notes.LBL_LIST_CONTACT_NAME'                  , 'CONTACT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 12, 'Notes.LBL_LIST_CONTACT_PHONE'                 , 'CONTACT_PHONE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 13, 'Notes.LBL_LIST_CONTACT_EMAIL'                 , 'CONTACT_EMAIL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 14, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 15, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.Export'            , 16, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Export'    , 'Opportunities', 'vwOPPORTUNITIES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  1, 'Opportunities.LBL_LIST_NAME'                  , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  2, 'Opportunities.LBL_LIST_OPPORTUNITY_TYPE'      , 'OPPORTUNITY_TYPE'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  3, 'Opportunities.LBL_LIST_LEAD_SOURCE'           , 'LEAD_SOURCE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  4, 'Opportunities.LBL_LIST_AMOUNT'                , 'AMOUNT'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  5, 'Opportunities.LBL_LIST_AMOUNT_BACKUP'         , 'AMOUNT_BACKUP'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  6, 'Opportunities.LBL_LIST_AMOUNT_USDOLLAR'       , 'AMOUNT_USDOLLAR'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  7, 'Opportunities.LBL_LIST_DATE_CLOSED'           , 'DATE_CLOSED'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  8, 'Opportunities.LBL_LIST_NEXT_STEP'             , 'NEXT_STEP'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    ,  9, 'Opportunities.LBL_LIST_SALES_STAGE'           , 'SALES_STAGE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 10, 'Opportunities.LBL_LIST_PROBABILITY'           , 'PROBABILITY'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 11, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 12, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 13, 'Opportunities.LBL_LIST_CAMPAIGN_NAME'         , 'CAMPAIGN_NAME'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 14, 'Opportunities.LBL_LIST_DESCRIPTION'           , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 15, 'Opportunities.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 16, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 17, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 18, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.Export'    , 19, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Export'          , 'Project', 'vwPROJECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  1, 'Project.LBL_LIST_NAME'                        , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'      , 'TOTAL_ESTIMATED_EFFORT'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'         , 'TOTAL_ACTUAL_EFFORT'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  4, 'Project.LBL_LIST_ESTIMATED_START_DATE'        , 'ESTIMATED_START_DATE'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  5, 'Project.LBL_LIST_ESTIMATED_END_DATE'          , 'ESTIMATED_END_DATE'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  6, 'Project.LBL_LIST_STATUS'                      , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  7, 'Project.LBL_LIST_PRIORITY'                    , 'PRIORITY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  8, 'Project.LBL_LIST_IS_TEMPLATE'                 , 'IS_TEMPLATE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          ,  9, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 10, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 11, 'Project.LBL_LIST_DESCRIPTION'                 , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 12, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 13, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 14, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.Export'          , 15, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ProjectTask.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ProjectTask.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'ProjectTask.Export'      , 'ProjectTask', 'vwPROJECT_TASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  1, 'ProjectTask.LBL_LIST_NAME'                    , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  2, 'ProjectTask.LBL_LIST_STATUS'                  , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  3, 'ProjectTask.LBL_LIST_DATE_DUE'                , 'DATE_DUE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  4, 'ProjectTask.LBL_LIST_TIME_DUE'                , 'TIME_DUE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  5, 'ProjectTask.LBL_LIST_DATE_START'              , 'DATE_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  6, 'ProjectTask.LBL_LIST_TIME_START'              , 'TIME_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  7, 'ProjectTask.LBL_LIST_PRIORITY'                , 'PRIORITY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  8, 'ProjectTask.LBL_LIST_ORDER_NUMBER'            , 'ORDER_NUMBER'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      ,  9, 'ProjectTask.LBL_LIST_TASK_NUMBER'             , 'TASK_NUMBER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 10, 'ProjectTask.LBL_LIST_MILESTONE_FLAG'          , 'MILESTONE_FLAG'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 11, 'ProjectTask.LBL_LIST_ESTIMATED_EFFORT'        , 'ESTIMATED_EFFORT'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 12, 'ProjectTask.LBL_LIST_ACTUAL_EFFORT'           , 'ACTUAL_EFFORT'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 13, 'ProjectTask.LBL_LIST_UTILIZATION'             , 'UTILIZATION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 14, 'ProjectTask.LBL_LIST_PERCENT_COMPLETE'        , 'PERCENT_COMPLETE'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 15, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 16, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 17, 'ProjectTask.LBL_LIST_DESCRIPTION'             , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 18, 'ProjectTask.LBL_LIST_PROJECT_NAME'            , 'PROJECT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 19, 'ProjectTask.LBL_LIST_DEPENDS_ON_NAME'         , 'DEPENDS_ON_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 20, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 21, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 22, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 23, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ProjectTask.Export'      , 24, 'ProjectTask.LBL_LIST_CAN_CLOSE'               , 'CAN_CLOSE'                  , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.Export'        , 'Prospects', 'vwPROSPECTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  1, 'Prospects.LBL_LIST_SALUTATION'                , 'SALUTATION'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  2, 'Prospects.LBL_LIST_NAME'                      , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  3, 'Prospects.LBL_LIST_FIRST_NAME'                , 'FIRST_NAME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  4, 'Prospects.LBL_LIST_LAST_NAME'                 , 'LAST_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  5, 'Prospects.LBL_LIST_TITLE'                     , 'TITLE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  6, 'Prospects.LBL_LIST_DEPARTMENT'                , 'DEPARTMENT'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  7, 'Prospects.LBL_LIST_BIRTHDATE'                 , 'BIRTHDATE'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  8, 'Prospects.LBL_LIST_DO_NOT_CALL'               , 'DO_NOT_CALL'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        ,  9, 'Prospects.LBL_LIST_PHONE_HOME'                , 'PHONE_HOME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 10, 'Prospects.LBL_LIST_PHONE_MOBILE'              , 'PHONE_MOBILE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 11, 'Prospects.LBL_LIST_PHONE_WORK'                , 'PHONE_WORK'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 12, 'Prospects.LBL_LIST_PHONE_OTHER'               , 'PHONE_OTHER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 13, 'Prospects.LBL_LIST_PHONE_FAX'                 , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 14, 'Prospects.LBL_LIST_EMAIL1'                    , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 15, 'Prospects.LBL_LIST_EMAIL2'                    , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 16, 'Prospects.LBL_LIST_ASSISTANT'                 , 'ASSISTANT'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 17, 'Prospects.LBL_LIST_ASSISTANT_PHONE'           , 'ASSISTANT_PHONE'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 18, 'Prospects.LBL_LIST_EMAIL_OPT_OUT'             , 'EMAIL_OPT_OUT'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 19, 'Prospects.LBL_LIST_INVALID_EMAIL'             , 'INVALID_EMAIL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 20, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_STREET'    , 'PRIMARY_ADDRESS_STREET'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 21, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_CITY'      , 'PRIMARY_ADDRESS_CITY'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 22, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_STATE'     , 'PRIMARY_ADDRESS_STATE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 23, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_POSTALCODE', 'PRIMARY_ADDRESS_POSTALCODE' , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 24, 'Prospects.LBL_LIST_PRIMARY_ADDRESS_COUNTRY'   , 'PRIMARY_ADDRESS_COUNTRY'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 25, 'Prospects.LBL_LIST_ALT_ADDRESS_STREET'        , 'ALT_ADDRESS_STREET'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 26, 'Prospects.LBL_LIST_ALT_ADDRESS_CITY'          , 'ALT_ADDRESS_CITY'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 27, 'Prospects.LBL_LIST_ALT_ADDRESS_STATE'         , 'ALT_ADDRESS_STATE'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 28, 'Prospects.LBL_LIST_ALT_ADDRESS_POSTALCODE'    , 'ALT_ADDRESS_POSTALCODE'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 29, 'Prospects.LBL_LIST_ALT_ADDRESS_COUNTRY'       , 'ALT_ADDRESS_COUNTRY'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 30, 'Prospects.LBL_LIST_CONVERTED_LEAD_NAME'       , 'CONVERTED_LEAD_NAME'        , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 31, 'Prospects.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 32, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 33, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 34, 'Prospects.LBL_LIST_DESCRIPTION'               , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 35, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 36, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 37, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.Export'        , 38, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.Export'            , 'Tasks', 'vwTASKS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  1, 'Tasks.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  2, 'Tasks.LBL_LIST_STATUS'                        , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  3, 'Tasks.LBL_LIST_DATE_DUE_FLAG'                 , 'DATE_DUE_FLAG'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  4, 'Tasks.LBL_LIST_DATE_DUE'                      , 'DATE_DUE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  5, 'Tasks.LBL_LIST_TIME_DUE'                      , 'TIME_DUE'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  6, 'Tasks.LBL_LIST_DATE_START_FLAG'               , 'DATE_START_FLAG'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  7, 'Tasks.LBL_LIST_DATE_START'                    , 'DATE_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  8, 'Tasks.LBL_LIST_TIME_START'                    , 'TIME_START'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            ,  9, 'Tasks.LBL_LIST_PARENT_TYPE'                   , 'PARENT_TYPE'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 10, 'Tasks.LBL_LIST_PRIORITY'                      , 'PRIORITY'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 11, 'Tasks.LBL_LIST_PARENT_NAME'                   , 'PARENT_NAME'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 12, 'Tasks.LBL_LIST_CONTACT_NAME'                  , 'CONTACT_NAME'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 13, 'Tasks.LBL_LIST_CONTACT_PHONE'                 , 'CONTACT_PHONE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 14, 'Tasks.LBL_LIST_CONTACT_EMAIL'                 , 'CONTACT_EMAIL'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 15, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 16, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 17, 'Tasks.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 18, '.LBL_LIST_TEAM_NAME'                          , 'TEAM_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 19, '.LBL_LIST_ASSIGNED_TO_NAME'                   , 'ASSIGNED_TO_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 20, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 21, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.Export'            , 22, 'Tasks.LBL_LIST_CAN_CLOSE'                     , 'CAN_CLOSE'                  , null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Users.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Users.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'Users.Export'            , 'Users', 'vwUSERS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  1, 'Users.LBL_LIST_FULL_NAME'                     , 'FULL_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  2, 'Users.LBL_LIST_NAME'                          , 'NAME'                       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  3, 'Users.LBL_LIST_USER_NAME'                     , 'USER_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  4, 'Users.LBL_LIST_FIRST_NAME'                    , 'FIRST_NAME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  5, 'Users.LBL_LIST_LAST_NAME'                     , 'LAST_NAME'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  6, 'Users.LBL_LIST_REPORTS_TO_NAME'               , 'REPORTS_TO_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  7, 'Users.LBL_LIST_IS_ADMIN'                      , 'IS_ADMIN'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  8, 'Users.LBL_LIST_PORTAL_ONLY'                   , 'PORTAL_ONLY'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            ,  9, 'Users.LBL_LIST_RECEIVE_NOTIFICATIONS'         , 'RECEIVE_NOTIFICATIONS'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 10, 'Users.LBL_LIST_TITLE'                         , 'TITLE'                      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 11, 'Users.LBL_LIST_DEPARTMENT'                    , 'DEPARTMENT'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 12, 'Users.LBL_LIST_PHONE_HOME'                    , 'PHONE_HOME'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 13, 'Users.LBL_LIST_PHONE_MOBILE'                  , 'PHONE_MOBILE'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 14, 'Users.LBL_LIST_PHONE_WORK'                    , 'PHONE_WORK'                 , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 15, 'Users.LBL_LIST_PHONE_OTHER'                   , 'PHONE_OTHER'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 16, 'Users.LBL_LIST_PHONE_FAX'                     , 'PHONE_FAX'                  , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 17, 'Users.LBL_LIST_EMAIL1'                        , 'EMAIL1'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 18, 'Users.LBL_LIST_EMAIL2'                        , 'EMAIL2'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 19, 'Users.LBL_LIST_STATUS'                        , 'STATUS'                     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 20, 'Users.LBL_LIST_EMPLOYEE_STATUS'               , 'EMPLOYEE_STATUS'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 21, 'Users.LBL_LIST_MESSENGER_TYPE'                , 'MESSENGER_TYPE'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 22, 'Users.LBL_LIST_ADDRESS_STREET'                , 'ADDRESS_STREET'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 23, 'Users.LBL_LIST_ADDRESS_CITY'                  , 'ADDRESS_CITY'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 24, 'Users.LBL_LIST_ADDRESS_STATE'                 , 'ADDRESS_STATE'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 25, 'Users.LBL_LIST_ADDRESS_COUNTRY'               , 'ADDRESS_COUNTRY'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 26, 'Users.LBL_LIST_ADDRESS_POSTALCODE'            , 'ADDRESS_POSTALCODE'         , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 27, 'Users.LBL_LIST_IS_GROUP'                      , 'IS_GROUP'                   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 28, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'               , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 29, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'              , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 30, 'Users.LBL_LIST_DESCRIPTION'                   , 'DESCRIPTION'                , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 31, 'Users.LBL_LIST_USER_PREFERENCES'              , 'USER_PREFERENCES'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 32, 'Users.LBL_LIST_DEFAULT_TEAM_NAME'             , 'DEFAULT_TEAM_NAME'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 33, 'Users.LBL_LIST_IS_ADMIN_DELEGATE'             , 'IS_ADMIN_DELEGATE'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 34, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 35, '.LBL_LIST_MODIFIED_BY_NAME'                   , 'MODIFIED_BY_NAME'           , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 36, 'Users.LBL_LIST_GOOGLEAPPS_SYNC_CONTACTS'      , 'GOOGLEAPPS_SYNC_CONTACTS'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 37, 'Users.LBL_LIST_GOOGLEAPPS_SYNC_CALENDAR'      , 'GOOGLEAPPS_SYNC_CALENDAR'   , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Users.Export'            , 38, 'Users.LBL_LIST_GOOGLEAPPS_USERNAME'           , 'GOOGLEAPPS_USERNAME'        , null, null;
end -- if;
GO

-- 05/24/2020 Paul.  Correct for global terms for DATE_ENTERED, DATE_MODIFIED, TEAM_NAME, ASSIGNED_TO_NAME, CREATED_BY_NAME, MODIFIED_BY_NAME
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'DATE_ENTERED' and HEADER_TEXT <> '.LBL_LIST_DATE_ENTERED' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_DATE_ENTERED'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'DATE_ENTERED'
	   and HEADER_TEXT       <> '.LBL_LIST_DATE_ENTERED'
	   and DELETED           =  0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'DATE_MODIFIED' and HEADER_TEXT <> '.LBL_LIST_DATE_MODIFIED' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_DATE_MODIFIED'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'DATE_MODIFIED'
	   and HEADER_TEXT       <> '.LBL_LIST_DATE_MODIFIED'
	   and DELETED           =  0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'TEAM_NAME' and HEADER_TEXT <> '.LBL_LIST_TEAM_NAME' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_TEAM_NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'TEAM_NAME'
	   and HEADER_TEXT       <> '.LBL_LIST_TEAM_NAME'
	   and DELETED           =  0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'ASSIGNED_TO_NAME' and HEADER_TEXT <> '.LBL_LIST_ASSIGNED_TO_NAME' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_ASSIGNED_TO_NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'ASSIGNED_TO_NAME'
	   and HEADER_TEXT       <> '.LBL_LIST_ASSIGNED_TO_NAME'
	   and DELETED           =  0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'CREATED_BY_NAME' and HEADER_TEXT <> '.LBL_LIST_CREATED_BY_NAME' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_CREATED_BY_NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'CREATED_BY_NAME'
	   and HEADER_TEXT       <> '.LBL_LIST_CREATED_BY_NAME'
	   and DELETED           =  0;
end -- if;
GO

if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like '%.Export' and DATA_FIELD = 'MODIFIED_BY_NAME' and HEADER_TEXT <> '.LBL_LIST_MODIFIED_BY_NAME' and DELETED = 0) begin -- then
	update GRIDVIEWS_COLUMNS
	   set HEADER_TEXT       = '.LBL_LIST_MODIFIED_BY_NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where GRID_NAME         like '%.Export'
	   and DATA_FIELD        =  'MODIFIED_BY_NAME'
	   and HEADER_TEXT       <> '.LBL_LIST_MODIFIED_BY_NAME'
	   and DELETED           =  0;
end -- if;
GO

-- 03/23/2021 Paul.  Add ZipCodes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.Export'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ZipCodes.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ZipCodes.Export';
	exec dbo.spGRIDVIEWS_InsertOnly             'ZipCodes.Export', 'ZipCodes', 'vwZIPCODES';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.Export', 1, 'ZipCodes.LBL_LIST_NAME'                , 'NAME'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.Export', 2, 'ZipCodes.LBL_LIST_CITY'                , 'CITY'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.Export', 3, 'ZipCodes.LBL_LIST_STATE'               , 'STATE'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound       'ZipCodes.Export', 4, 'ZipCodes.LBL_LIST_COUNTRY'             , 'COUNTRY'          , null, null;
end -- if;
GO

-- 03/23/2021 Paul.  Add support for NAICS Codes. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.Export'
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'NAICSCodes.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS NAICSCodes.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'NAICSCodes.Export', 'NAICSCodes', 'vwNAICS_CODES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NAICSCodes.Export', 0, 'NAICSCodes.LBL_LIST_NAME'              , 'NAME'             , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'NAICSCodes.Export', 1, 'NAICSCodes.LBL_LIST_DESCRIPTION'       , 'DESCRIPTION'      , null, null;
end -- if;
GO

-- 04/02/2021 Paul.  Add support for UserLogins. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserLogins.Export';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'UserLogins.Export' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS UserLogins.Export';
	exec dbo.spGRIDVIEWS_InsertOnly           'UserLogins.Export', 'Users', 'vwUSERS_LOGINS', 'DATE_MODIFIED', 'desc';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 0, 'Users.LBL_LIST_NAME'                  , 'NAME'            , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 1, 'Users.LBL_LIST_USER_NAME'             , 'USER_NAME'       , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 2, 'Users.LBL_LIST_LOGIN_DATE'            , 'LOGIN_DATE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 3, 'Users.LBL_LIST_LOGOUT_DATE'           , 'LOGOUT_DATE'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 4, 'Users.LBL_LIST_LOGIN_STATUS'          , 'LOGIN_STATUS'    , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 5, 'Users.LBL_LIST_LOGIN_TYPE'            , 'LOGIN_TYPE'      , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 6, 'Users.LBL_LIST_REMOTE_HOST'           , 'REMOTE_HOST'     , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 7, 'Users.LBL_LIST_TARGET'                , 'TARGET'          , null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 8, 'Users.LBL_LIST_ASPNET_SESSIONID'      , 'ASPNET_SESSIONID', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'UserLogins.Export', 9, 'Users.LBL_LIST_IS_ADMIN'              , 'IS_ADMIN'        , null, null;
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

call dbo.spGRIDVIEWS_COLUMNS_Export()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_Export')
/

-- #endif IBM_DB2 */

