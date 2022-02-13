

print 'TERMINOLOGY_ALIASES defaults';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CREATED_BY_ID'                 , 'Accounts'     , null, 'LBL_CREATED_BY_ID'            , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ID_C'                          , 'Accounts'     , null, 'LBL_ID_C'                     , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ASSIGNED_USER_ID'              , 'Accounts'     , null, 'LBL_ASSIGNED_USER_ID'         , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_MODIFIED_BY'                   , 'Accounts'     , null, 'LBL_MODIFIED_BY'              , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_MODIFIED_USER_ID'              , 'Accounts'     , null, 'LBL_MODIFIED_USER_ID'         , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TEAM_ID'                       , 'Accounts'     , null, 'LBL_TEAM_ID'                  , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TEAM_NAME'                     , 'Accounts'     , null, 'LBL_TEAM_NAME'                , null           , null;

exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_NAME'                          , 'Bugs'         , null, 'LBL_SUBJECT'                  , 'Bugs'         , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DATE_START'                    , 'Calls'        , null, 'LBL_DATE_TIME'                , 'Calls'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_TYPE'                   , 'Calls'        , null, 'LBL_PARENT_TYPE'              , 'Notes'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_NAME'                   , 'Calls'        , null, 'LBL_PARENT_NAME'              , 'Accounts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_START_DATE'                    , 'Campaigns'    , null, 'LBL_CAMPAIGN_START_DATE'      , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_END_DATE'                      , 'Campaigns'    , null, 'LBL_CAMPAIGN_END_DATE'        , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_STATUS'                        , 'Campaigns'    , null, 'LBL_CAMPAIGN_STATUS'          , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_BUDGET'                        , 'Campaigns'    , null, 'LBL_CAMPAIGN_BUDGET'          , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXPECTED_COST'                 , 'Campaigns'    , null, 'LBL_CAMPAIGN_EXPECTED_COST'   , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ACTUAL_COST'                   , 'Campaigns'    , null, 'LBL_CAMPAIGN_ACTUAL_COST'     , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXPECTED_REVENUE'              , 'Campaigns'    , null, 'LBL_CAMPAIGN_EXPECTED_REVENUE', 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_NAME'                 , 'Campaigns'    , null, 'LBL_CURRENCY'                 , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_SYMBOL'               , 'Campaigns'    , null, 'LBL_LIST_SYMBOL'              , 'Currencies'   , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_CONVERSION_RATE'      , 'Campaigns'    , null, 'LBL_LIST_RATE'                , 'Currencies'   , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_NAME'                          , 'Cases'        , null, 'LBL_SUBJECT'                  , 'Cases'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_NAME'                 , 'Contracts'    , null, 'LBL_CURRENCY'                 , 'Contracts'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_SYMBOL'               , 'Contracts'    , null, 'LBL_LIST_SYMBOL'              , 'Currencies'   , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CURRENCY_CONVERSION_RATE'      , 'Contracts'    , null, 'LBL_LIST_RATE'                , 'Currencies'   , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TOTAL_CONTRACT_VALUE'          , 'Contracts'    , null, 'LBL_CONTRACT_VALUE'           , 'Contracts'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TOTAL_CONTRACT_VALUE_USDOLLAR' , 'Contracts'    , null, 'LBL_US_DOLLAR'                , 'Currencies'   , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DOCUMENT_NAME'                 , 'Documents'    , null, 'LBL_DOC_NAME'                 , 'Documents'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXP_DATE'                      , 'Documents'    , null, 'LBL_DOC_EXP_DATE'             , 'Documents'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_FILE_MIME_TYPE'                , 'Documents'    , null, 'LBL_FILE_MIME_TYPE'           , 'Notes'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REVISION_DATE_ENTERED'         , 'Documents'    , null, 'LBL_LAST_REV_DATE'            , 'Documents'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REVISION_DATE_MODIFIED'        , 'Documents'    , null, 'LBL_DATE_MODIFIED'            , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REVISION_CREATED_BY'           , 'Documents'    , null, 'LBL_LAST_REV_CREATOR'         , 'Documents'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REVISION_MODIFIED_BY'          , 'Documents'    , null, 'LBL_MODIFIED_BY'              , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_NAME'                          , 'Emails'       , null, 'LBL_SUBJECT'                  , 'Emails'       , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DATE_START'                    , 'Emails'       , null, 'LBL_DATE_AND_TIME'            , 'Emails'       , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TIME_START'                    , 'Emails'       , null, 'LBL_DATE_AND_TIME'            , 'Emails'       , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_TYPE'                   , 'Emails'       , null, 'LBL_PARENT_TYPE'              , 'Notes'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_FROM_ADDR'                     , 'Emails'       , null, 'LBL_FROM'                     , 'Emails'       , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REPLY_TO_ADDR'                 , 'Emails'       , null, 'LBL_TO'                       , 'Emails'       , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_NAME'                   , 'Emails'       , null, 'LBL_PARENT_NAME'              , 'Accounts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_HOME'                    , 'Leads'        , null, 'LBL_HOME_PHONE'               , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_MOBILE'                  , 'Leads'        , null, 'LBL_MOBILE_PHONE'             , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_WORK'                    , 'Leads'        , null, 'LBL_OFFICE_PHONE'             , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_OTHER'                   , 'Leads'        , null, 'LBL_OTHER_PHONE'              , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_FAX'                     , 'Leads'        , null, 'LBL_FAX_PHONE'                , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL1'                        , 'Leads'        , null, 'LBL_EMAIL_ADDRESS'            , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL2'                        , 'Leads'        , null, 'LBL_OTHER_EMAIL_ADDRESS'      , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CONVERTED_CONTACT_NAME'        , 'Leads'        , null, 'LBL_CONVERTED_CONTACT'        , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CONVERTED_ACCOUNT_NAME'        , 'Leads'        , null, 'LBL_CONVERTED_ACCOUNT'        , 'Leads'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CAMPAIGN_NAME'                 , 'Leads'        , null, 'LBL_NAME'                     , 'Campaigns'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DATE_START'                    , 'Meetings'     , null, 'LBL_DATE_TIME'                , 'Meetings'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_TYPE'                   , 'Meetings'     , null, 'LBL_PARENT_TYPE'              , 'Notes'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_NAME'                   , 'Meetings'     , null, 'LBL_PARENT_NAME'              , 'Accounts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_OPPORTUNITY_TYPE'              , 'Opportunities', null, 'LBL_TYPE'                     , 'Opportunities', null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_AMOUNT_USDOLLAR'               , 'Opportunities', null, 'LBL_AMOUNT'                   , 'Opportunities', null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_HOME'                    , 'Prospects'    , null, 'LBL_HOME_PHONE'               , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_MOBILE'                  , 'Prospects'    , null, 'LBL_MOBILE_PHONE'             , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_WORK'                    , 'Prospects'    , null, 'LBL_OFFICE_PHONE'             , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_OTHER'                   , 'Prospects'    , null, 'LBL_OTHER_PHONE'              , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_FAX'                     , 'Prospects'    , null, 'LBL_FAX_PHONE'                , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL1'                        , 'Prospects'    , null, 'LBL_EMAIL_ADDRESS'            , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL2'                        , 'Prospects'    , null, 'LBL_OTHER_EMAIL_ADDRESS'      , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CONVERTED_LEAD_NAME'           , 'Prospects'    , null, 'LBL_CONVERTED_LEAD'           , 'Prospects'    , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DATE_DUE'                      , 'Tasks'        , null, 'LBL_DUE_DATE_AND_TIME'        , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TIME_DUE'                      , 'Tasks'        , null, 'LBL_DUE_DATE_AND_TIME'        , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DATE_START'                    , 'Tasks'        , null, 'LBL_START_DATE_AND_TIME'      , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_TIME_START'                    , 'Tasks'        , null, 'LBL_START_DATE_AND_TIME'      , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_TYPE'                   , 'Tasks'        , null, 'LBL_PARENT_TYPE'              , 'Notes'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PARENT_NAME'                   , 'Tasks'        , null, 'LBL_PARENT_NAME'              , 'Accounts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CONTACT_PHONE'                 , 'Tasks'        , null, 'LBL_PHONE'                    , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_CONTACT_EMAIL'                 , 'Tasks'        , null, 'LBL_EMAIL'                    , 'Tasks'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_FULL_NAME'                     , 'Users'        , null, 'LBL_NAME'                     , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_HOME'                    , 'Users'        , null, 'LBL_HOME_PHONE'               , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_MOBILE'                  , 'Users'        , null, 'LBL_MOBILE_PHONE'             , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_WORK'                    , 'Users'        , null, 'LBL_OFFICE_PHONE'             , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_OTHER'                   , 'Users'        , null, 'LBL_OTHER'                    , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_FAX'                     , 'Users'        , null, 'LBL_FAX'                      , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL1'                        , 'Users'        , null, 'LBL_EMAIL'                    , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL2'                        , 'Users'        , null, 'LBL_OTHER_EMAIL'              , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL1'                        , 'Campaigns'    , null, 'LBL_LIST_EMAIL_ADDRESS'       , 'Contacts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_RELATED_NAME'                  , 'Campaigns'    , null, 'LBL_LIST_CONTACT_NAME'        , 'Contacts'     , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_RELATED_TYPE'                  , 'Campaigns'    , null, 'LBL_LIST_LIST_TYPE'           , 'ProspectLists', null;


exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_FULL_NAME'                     , 'UserLogins'   , null, 'LBL_NAME'                     , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_IS_ADMIN'                      , 'UserLogins'   , null, 'LBL_IS_ADMIN'                 , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_STATUS'                        , 'UserLogins'   , null, 'LBL_STATUS'                   , 'Users'        , null;
GO

exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_STATUS'                        , 'Employees'    , null, 'LBL_STATUS'                   , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_REPORTS_TO_NAME'               , 'Employees'    , null, 'LBL_REPORTS_TO_NAME'          , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_RECEIVE_NOTIFICATIONS'         , 'Employees'    , null, 'LBL_RECEIVE_NOTIFICATIONS'    , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PORTAL_ONLY'                   , 'Employees'    , null, 'LBL_PORTAL_ONLY'              , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_WORK'                    , 'Employees'    , null, 'LBL_PHONE_WORK'               , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_OTHER'                   , 'Employees'    , null, 'LBL_PHONE_OTHER'              , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_MOBILE'                  , 'Employees'    , null, 'LBL_PHONE_MOBILE'             , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_HOME'                    , 'Employees'    , null, 'LBL_PHONE_HOME'               , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_PHONE_FAX'                     , 'Employees'    , null, 'LBL_PHONE_FAX'                , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_IS_ADMIN'                      , 'Employees'    , null, 'LBL_IS_ADMIN'                 , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_FULL_NAME'                     , 'Employees'    , null, 'LBL_FULL_NAME'                , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL2'                        , 'Employees'    , null, 'LBL_EMAIL2'                   , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EMAIL1'                        , 'Employees'    , null, 'LBL_EMAIL1'                   , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_DESCRIPTION'                   , 'Employees'    , null, 'LBL_DESCRIPTION'              , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ADDRESS_STREET'                , 'Employees'    , null, 'LBL_ADDRESS_STREET'           , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ADDRESS_STATE'                 , 'Employees'    , null, 'LBL_ADDRESS_STATE'            , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ADDRESS_POSTALCODE'            , 'Employees'    , null, 'LBL_ADDRESS_POSTALCODE'       , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ADDRESS_COUNTRY'               , 'Employees'    , null, 'LBL_ADDRESS_COUNTRY'          , 'Users'        , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_ADDRESS_CITY'                  , 'Employees'    , null, 'LBL_ADDRESS_CITY'             , 'Users'        , null;

-- 08/10/2012 Paul.  LBL_EXCHANGE_FOLDER is a global. 
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Accounts'     , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Bugs'         , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Cases'        , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Contacts'     , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Leads'        , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Opportunities', null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
exec dbo.spTERMINOLOGY_ALIASES_InsertOnly null, 'LBL_EXCHANGE_FOLDER'               , 'Project'      , null, 'LBL_EXCHANGE_FOLDER'          , null           , null;
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

call dbo.spTERMINOLOGY_ALIASES_Defaults()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ALIASES_Defaults')
/

-- #endif IBM_DB2 */

