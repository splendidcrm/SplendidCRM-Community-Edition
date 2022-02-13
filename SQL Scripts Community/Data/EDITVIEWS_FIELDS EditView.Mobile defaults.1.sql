

print 'EDITVIEWS_FIELDS EditView.Mobile defaults';
--delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.EditView.Mobile'
--GO

set nocount on;
GO

-- 11/17/2007 Paul.  Add spEDITVIEWS_InsertOnly to simplify creation of Mobile views.
-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
-- 08/24/2009 Paul.  Change TEAM_NAME to TEAM_SET_NAME. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
-- 04/13/2016 Paul.  Add ZipCode lookup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.EditView.Mobile'      , 'Accounts'      , 'vwACCOUNTS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  1, 'Accounts.LBL_PHONE'                     , 'PHONE_OFFICE'               , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  2, 'Accounts.LBL_WEBSITE'                   , 'WEBSITE'                    , 0, 1, 255, 28, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  3, 'Accounts.LBL_FAX'                       , 'PHONE_FAX'                  , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  4, 'Accounts.LBL_TICKER_SYMBOL'             , 'TICKER_SYMBOL'              , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  5, 'Accounts.LBL_OTHER_PHONE'               , 'PHONE_ALTERNATE'            , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Mobile'       ,  6, 'Accounts.LBL_MEMBER_OF'                 , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  7, 'Accounts.LBL_EMAIL'                     , 'EMAIL1'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  8, 'Accounts.LBL_EMPLOYEES'                 , 'EMPLOYEES'                  , 0, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       ,  9, 'Accounts.LBL_OTHER_EMAIL_ADDRESS'       , 'EMAIL2'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 10, 'Accounts.LBL_OWNERSHIP'                 , 'OWNERSHIP'                  , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 11, 'Accounts.LBL_RATING'                    , 'RATING'                     , 0, 2,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.EditView.Mobile'       , 12, 'Accounts.LBL_INDUSTRY'                  , 'INDUSTRY'                   , 0, 1, 'industry_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 13, 'Accounts.LBL_SIC_CODE'                  , 'SIC_CODE'                   , 0, 2,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.EditView.Mobile'       , 14, 'Accounts.LBL_TYPE'                      , 'ACCOUNT_TYPE'               , 0, 1, 'account_type_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 15, 'Accounts.LBL_ANNUAL_REVENUE'            , 'ANNUAL_REVENUE'             , 0, 2,  25, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Mobile'       , 16, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Accounts.EditView.Mobile'       , 17, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Mobile'       , 18, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Accounts.EditView.Mobile'       , 19, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Accounts.EditView.Mobile'       , 20;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditView.Mobile'       , 21, 'Accounts.LBL_BILLING_ADDRESS_STREET'    , 'BILLING_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Accounts.EditView.Mobile'       , 22, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditView.Mobile'       , 23, 'Accounts.LBL_SHIPPING_ADDRESS_STREET'   , 'SHIPPING_ADDRESS_STREET'    , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 24, 'Accounts.LBL_CITY'                      , 'BILLING_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 25, 'Accounts.LBL_CITY'                      , 'SHIPPING_ADDRESS_CITY'      , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 26, 'Accounts.LBL_STATE'                     , 'BILLING_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 27, 'Accounts.LBL_STATE'                     , 'SHIPPING_ADDRESS_STATE'     , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Accounts.EditView.Mobile'       , 28, 'Accounts.LBL_POSTAL_CODE'               , 'BILLING_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Accounts.EditView.Mobile'       , 29, 'Accounts.LBL_POSTAL_CODE'               , 'SHIPPING_ADDRESS_POSTALCODE', 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 30, 'Accounts.LBL_COUNTRY'                   , 'BILLING_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Mobile'       , 31, 'Accounts.LBL_COUNTRY'                   , 'SHIPPING_ADDRESS_COUNTRY'   , 0, 4, 100, 10, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Accounts.EditView.Mobile'       , 32;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditView.Mobile'       , 33, 'Accounts.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Accounts.EditView.Mobile'       ,  6, 'Accounts.LBL_MEMBER_OF'                 , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Accounts.EditView.Mobile'       , 18, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Accounts.EditView.Mobile', 'Accounts.EditAddress.Mobile', 'Accounts.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditDescription.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Accounts.EditView.Mobile', 'Accounts.EditDescription.Mobile', 'Accounts.LBL_DESCRIPTION_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Accounts.EditView.Mobile', 'BILLING_ADDRESS_POSTALCODE';
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Accounts.EditView.Mobile', 'SHIPPING_ADDRESS_POSTALCODE';
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.EditAddress.Mobile', 'Accounts', 'vwACCOUNTS_Edit', '15%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditAddress.Mobile'    ,  0, 'Accounts.LBL_BILLING_ADDRESS_STREET'    , 'BILLING_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Accounts.EditAddress.Mobile'    ,  1, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditAddress.Mobile'    ,  2, 'Accounts.LBL_SHIPPING_ADDRESS_STREET'   , 'SHIPPING_ADDRESS_STREET'    , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  3, 'Accounts.LBL_CITY'                      , 'BILLING_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  4, 'Accounts.LBL_CITY'                      , 'SHIPPING_ADDRESS_CITY'      , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  5, 'Accounts.LBL_STATE'                     , 'BILLING_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  6, 'Accounts.LBL_STATE'                     , 'SHIPPING_ADDRESS_STATE'     , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  7, 'Accounts.LBL_POSTAL_CODE'               , 'BILLING_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  8, 'Accounts.LBL_POSTAL_CODE'               , 'SHIPPING_ADDRESS_POSTALCODE', 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    ,  9, 'Accounts.LBL_COUNTRY'                   , 'BILLING_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditAddress.Mobile'    , 10, 'Accounts.LBL_COUNTRY'                   , 'SHIPPING_ADDRESS_COUNTRY'   , 0, 4, 100, 10, null;
end -- if;
*/
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditDescription.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.EditDescription.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.EditDescription.Mobile', 'Accounts', 'vwACCOUNTS_Edit', '15%', '85%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Accounts.EditDescription.Mobile',  0, 'Accounts.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end -- if;
*/
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Bugs.EditView.Mobile'          , 'Bugs'          , 'vwBUGS_Edit'          , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Bugs.EditView.Mobile'           ,  0, 'Bugs.LBL_BUG_NUMBER'                    , 'BUG_NUMBER'                 , null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.EditView.Mobile'           ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           ,  2, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 0, 1, 'bug_priority_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.EditView.Mobile'           ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           ,  4, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, 1, 'bug_status_dom'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Bugs.EditView.Mobile'           ,  5, '.LBL_CREATED_BY'                        , 'CREATED_BY_NAME'            , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           ,  6, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 0, 1, 'bug_type_dom'        , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Bugs.EditView.Mobile'           ,  7, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED'               , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           ,  8, 'Bugs.LBL_SOURCE'                        , 'SOURCE'                     , 0, 1, 'source_dom'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Bugs.EditView.Mobile'           ,  9, '.LBL_MODIFIED_BY'                       , 'MODIFIED_BY_NAME'           , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Bugs.EditView.Mobile'           , 11, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED'              , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 12, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 13, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           , 14, 'Bugs.LBL_PRODUCT_CATEGORY'              , 'PRODUCT_CATEGORY'           , 0, 1, 'product_category_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           , 15, 'Bugs.LBL_RESOLUTION'                    , 'RESOLUTION'                 , 0, 2, 'bug_resolution_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 16, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 17, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           , 18, 'Bugs.LBL_FOUND_IN_RELEASE'              , 'FOUND_IN_RELEASE_ID'        , 0, 1, 'Release'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Mobile'           , 19, 'Bugs.LBL_FIXED_IN_RELEASE'              , 'FIXED_IN_RELEASE_ID'        , 0, 2, 'Release'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 21, null;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Bugs.EditView.Mobile'           , 22, 'Bugs.LBL_FILENAME'                      , 'ATTACHMENT'                 , 0, 2, 255, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Bugs.EditView.Mobile'           , 23, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 1, 3,   1, 70, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Bugs.EditView.Mobile'           , 24, 'Bugs.LBL_DESCRIPTION'                   , 'DESCRIPTION'                , 0, 3,   8, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.EditView.Mobile'           , 26, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Bugs.EditView.Mobile'           , 27, 'Bugs.LBL_WORK_LOG'                      , 'WORK_LOG'                   , 0, 3,   2, 80, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Bugs.EditView.Mobile'           ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.EditView.Mobile'         , 'Calls'         , 'vwCALLS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.EditView.Mobile'          ,  0, 'Calls.LBL_NAME'                         , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Mobile'          ,  1, 'Calls.LBL_STATUS'                       , 'DIRECTION'                  , 0, 2, 'call_direction_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Mobile'          ,  2, null                                     , 'STATUS'                     , 0, 2, 'call_status_dom'    , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.EditView.Mobile'          ,  3, 'Calls.LBL_DATE_TIME'                    , 'DATE_START'                 , 1, 1, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.EditView.Mobile'          ,  4, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.EditView.Mobile'          ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Calls.EditView.Mobile'          ,  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.EditView.Mobile'          ,  7, 'Calls.LBL_DURATION'                     , 'DURATION_HOURS'             , 1, 1,   2,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Mobile'          ,  8, null                                     , 'DURATION_MINUTES'           , 0, 1, 'call_minutes_dom'   , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Calls.EditView.Mobile'          ,  9, null                                     , 'Calls.LBL_HOURS_MINUTES'    , -1;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Calls.EditView.Mobile'          , 10, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.EditView.Mobile'          , 11, 'Calls.LBL_REMINDER'                     , 'SHOULD_REMIND'              , 0, 1, 'CheckBox'           , 'toggleDisplay(''should_remind_list'');', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Mobile'          , 12, null                                     , 'REMINDER_TIME'              , 0, 1, 'reminder_time_dom'  , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Calls.EditView.Mobile'          , 13, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Calls.EditView.Mobile'          , 14, 'Calls.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 3,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Calls.EditView.Mobile'          ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Campaigns.EditView.Mobile'      , 'Campaigns'     , 'vwCAMPAIGNS_Edit'     , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 1, 1,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.EditView.Mobile'      ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.EditView.Mobile'      ,  2, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                     , 1, 1, 'campaign_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.EditView.Mobile'      ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.EditView.Mobile'      ,  4, 'Campaigns.LBL_CAMPAIGN_START_DATE'      , 'START_DATE'                 , 0, 1, 'DatePicker'         , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.EditView.Mobile'      ,  6, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                   , 1, 1, 'DatePicker'         , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.EditView.Mobile'      ,  8, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'              , 1, 1, 'campaign_type_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      ,  9, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 11, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 12, 'Campaigns.LBL_CAMPAIGN_BUDGET'          , 'BUDGET'                     , 0, 1, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 13, 'Campaigns.LBL_CAMPAIGN_ACTUAL_COST'     , 'ACTUAL_COST'                , 0, 2, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 14, 'Campaigns.LBL_CAMPAIGN_EXPECTED_REVENUE', 'EXPECTED_REVENUE'           , 0, 1, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 15, 'Campaigns.LBL_CAMPAIGN_EXPECTED_COST'   , 'EXPECTED_COST'              , 0, 2, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 16, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 17, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Campaigns.EditView.Mobile'      , 18, 'Campaigns.LBL_CAMPAIGN_OBJECTIVE'       , 'OBJECTIVE'                  , 0, 3,   8, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Campaigns.EditView.Mobile'      , 19, 'Campaigns.LBL_CAMPAIGN_CONTENT'         , 'CONTENT'                    , 0, 4,   8, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 20, 'Campaigns.LBL_TRACKER_TEXT'             , 'TRACKER_TEXT'               , 0, 4, 255, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 21, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Mobile'      , 22, 'Campaigns.LBL_REFER_URL'                , 'REFER_URL'                  , 0, 4, 255, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Mobile'      , 23, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Campaigns.EditView.Mobile'      ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.EditView.Mobile'          , 'Cases'         , 'vwCASES_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Cases.EditView.Mobile'          ,  0, 'Cases.LBL_CASE_NUMBER'                  , 'CASE_NUMBER'                , null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Mobile'          ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Mobile'          ,  2, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, 1, 'case_priority_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Mobile'          ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Mobile'          ,  4, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, 1, 'case_status_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Mobile'          ,  5, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 1, 2, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Mobile'          ,  6, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 1, 3, 1, 70, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Mobile'          ,  7, 'Cases.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 3, 8, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Mobile'          ,  8, 'Cases.LBL_RESOLUTION'                   , 'RESOLUTION'                 , 0, 3, 5, 80, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Cases.EditView.Mobile'          ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Cases.EditView.Mobile'          ,  5, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 1, 2, 'ACCOUNT_NAME'        , 'Accounts', null;
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
-- 04/13/2016 Paul.  Add ZipCode lookup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.EditView.Mobile'       , 'Contacts'      , 'vwCONTACTS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Contacts.EditView.Mobile'       ,  0, 'Contacts.LBL_FIRST_NAME'                , 'SALUTATION'                 , 0, 1, 'salutation_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  1, null                                     , 'FIRST_NAME'                 , 0, 1,  25, 25, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  2, 'Contacts.LBL_OFFICE_PHONE'              , 'PHONE_WORK'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  3, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 1, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  4, 'Contacts.LBL_MOBILE_PHONE'              , 'PHONE_MOBILE'               , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Mobile'       ,  5, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, 1, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  6, 'Contacts.LBL_HOME_PHONE'                , 'PHONE_HOME'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Contacts.EditView.Mobile'       ,  7, 'Contacts.LBL_LEAD_SOURCE'               , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  8, 'Contacts.LBL_OTHER_PHONE'               , 'PHONE_OTHER'                , 0, 2,  25, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       ,  9, 'Contacts.LBL_TITLE'                     , 'TITLE'                      , 0, 1,  40, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 10, 'Contacts.LBL_FAX_PHONE'                 , 'PHONE_FAX'                  , 0, 2,  25, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 11, 'Contacts.LBL_DEPARTMENT'                , 'DEPARTMENT'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 12, 'Contacts.LBL_EMAIL_ADDRESS'             , 'EMAIL1'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 13, 'Contacts.LBL_BIRTHDATE'                 , 'BIRTHDATE'                  , 0, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 14, 'Contacts.LBL_OTHER_EMAIL_ADDRESS'       , 'EMAIL2'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Mobile'       , 15, 'Contacts.LBL_REPORTS_TO'                , 'REPORTS_TO_ID'              , 0, 1, 'REPORTS_TO_NAME'     , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 16, 'Contacts.LBL_ASSISTANT'                 , 'ASSISTANT'                  , 0, 2,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 17, 'Contacts.LBL_SYNC_CONTACT'              , 'SYNC_CONTACT'               , 0, 1, 'CheckBox'            , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 18, 'Contacts.LBL_ASSISTANT_PHONE'           , 'ASSISTANT_PHONE'            , 0, 2,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 19, 'Contacts.LBL_DO_NOT_CALL'               , 'DO_NOT_CALL'                , 0, 1, 'CheckBox'            , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 20, 'Contacts.LBL_EMAIL_OPT_OUT'             , 'EMAIL_OPT_OUT'              , 0, 2, 'CheckBox'            , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Mobile'       , 21, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Contacts.EditView.Mobile'       , 22, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Mobile'       , 23, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 24, 'Contacts.LBL_INVALID_EMAIL'             , 'INVALID_EMAIL'              , 0, 2, 'CheckBox'            , null, null, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Contacts.EditView.Mobile'       , 25;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditView.Mobile'       , 26, 'Contacts.LBL_PRIMARY_ADDRESS'           , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Mobile'       , 27, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditView.Mobile'       , 28, 'Contacts.LBL_ALTERNATE_ADDRESS'         , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 29, 'Contacts.LBL_CITY'                      , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 30, 'Contacts.LBL_CITY'                      , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 31, 'Contacts.LBL_STATE'                     , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 32, 'Contacts.LBL_STATE'                     , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Contacts.EditView.Mobile'       , 33, 'Contacts.LBL_POSTAL_CODE'               , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Contacts.EditView.Mobile'       , 34, 'Contacts.LBL_POSTAL_CODE'               , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 35, 'Contacts.LBL_COUNTRY'                   , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Mobile'       , 36, 'Contacts.LBL_COUNTRY'                   , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Contacts.EditView.Mobile'       , 37;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditView.Mobile'       , 38, 'Contacts.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Contacts.EditView.Mobile'       ,  5, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, 1, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Contacts.EditView.Mobile'       , 15, 'Contacts.LBL_REPORTS_TO'                , 'REPORTS_TO_ID'              , 0, 1, 'REPORTS_TO_NAME'     , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Contacts.EditView.Mobile'       , 23, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Contacts.EditView.Mobile', 'Contacts.EditAddress.Mobile', 'Contacts.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditDescription.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Contacts.EditView.Mobile', 'Contacts.EditDescription.Mobile', 'Contacts.LBL_DESCRIPTION_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Contacts.EditView.Mobile', 'PRIMARY_ADDRESS_POSTALCODE';
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Contacts.EditView.Mobile', 'ALT_ADDRESS_POSTALCODE';
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.EditAddress.Mobile', 'Contacts', 'vwCONTACTS_Edit', '15%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditAddress.Mobile'    ,  0, 'Contacts.LBL_PRIMARY_ADDRESS'           , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditAddress.Mobile'    ,  1, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditAddress.Mobile'    ,  2, 'Contacts.LBL_ALTERNATE_ADDRESS'         , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  3, 'Contacts.LBL_CITY'                      , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  4, 'Contacts.LBL_CITY'                      , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  5, 'Contacts.LBL_STATE'                     , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  6, 'Contacts.LBL_STATE'                     , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  7, 'Contacts.LBL_POSTAL_CODE'               , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  8, 'Contacts.LBL_POSTAL_CODE'               , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    ,  9, 'Contacts.LBL_COUNTRY'                   , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditAddress.Mobile'    , 10, 'Contacts.LBL_COUNTRY'                   , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;
end -- if;
*/
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditDescription.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.EditDescription.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.EditDescription.Mobile', 'Contacts', 'vwCONTACTS_Edit', '15%', '85%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Contacts.EditDescription.Mobile',  0, 'Contacts.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end -- if;
*/
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Documents.EditView.Mobile', 'Documents', 'Documents', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.EditView.Mobile'      ,  0, 'Documents.LBL_DOC_NAME'                 , 'DOCUMENT_NAME'              , 1, 1, 255, 40, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Documents.EditView.Mobile'      ,  1, 'Documents.LBL_FILENAME'                 , 'FILENAME'                   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Documents.EditView.Mobile'      ,  2, null                                     , 'CONTENT'                    , 1, 2, 255, 20, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.EditView.Mobile'      ,  3, 'Documents.LBL_DOC_VERSION'              , 'REVISION'                   , 1, 3,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Mobile'      ,  4, 'Documents.LBL_CATEGORY_VALUE'           , 'CATEGORY_ID'                , 0, 4, 'document_category_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Mobile'      ,  5, 'Documents.LBL_SUBCATEGORY_VALUE'        , 'SUBCATEGORY_ID'             , 0, 5, 'document_subcategory_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Mobile'      ,  6, 'Documents.LBL_DOC_STATUS'               , 'STATUS_ID'                  , 1, 6, 'document_status_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Documents.EditView.Mobile'      ,  7, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'               , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Mobile'      ,  8, 'Documents.LBL_DOC_ACTIVE_DATE'          , 'ACTIVE_DATE'                , 1, 8, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Mobile'      ,  9, 'Documents.LBL_DOC_EXP_DATE'             , 'EXP_DATE'                   , 0, 9, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Documents.EditView.Mobile'      , 10, 'Documents.LBL_DESCRIPTION'              , 'DESCRIPTION'                , 0,10,  10, 90, 3;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Emails.EditView.Mobile'        , 'Emails'        , 'vwEMAILS_Edit'        , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Emails.EditView.Mobile'         ,  0, 'Emails.LBL_DATE_AND_TIME'               , 'DATE_START'                 , 1, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Emails.EditView.Mobile'         ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 2, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Emails.EditView.Mobile'         ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Emails.EditView.Mobile'         ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Emails.EditView.Mobile'         ,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Emails.EditView.Mobile'         ,  6, 'Emails.LBL_FROM'                        , 'FROM_NAME'                  , 0, 0, 255, 40, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Emails.EditView.Mobile'         ,  7, 'Emails.LBL_TO'                          , 'TO_ADDRS'                   , 0, 0,   1, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Emails.EditView.Mobile'         ,  8, 'Emails.LBL_CC'                          , 'CC_ADDRS'                   , 0, 0,   1, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Emails.EditView.Mobile'         ,  9, 'Emails.LBL_BCC'                         , 'BCC_ADDRS'                  , 0, 0,   1, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Emails.EditView.Mobile'         , 10, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, 0,   1, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Emails.EditView.Mobile'         , 11, 'Emails.LBL_BODY'                        , 'DESCRIPTION'                , 0, 0,  20,100, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Emails.EditView.Mobile'         ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
-- 04/13/2016 Paul.  Add ZipCode lookup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Employees.EditView.Mobile'     , 'Employees'     , 'vwEMPLOYEES_Edit'     , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  1, 'Employees.LBL_TITLE'                    , 'TITLE'                      , 0, 5,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  2, 'Employees.LBL_OFFICE_PHONE'             , 'PHONE_WORK'                 , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  3, 'Employees.LBL_DEPARTMENT'               , 'DEPARTMENT'                 , 0, 5,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  4, 'Employees.LBL_MOBILE_PHONE'             , 'PHONE_MOBILE'               , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Employees.EditView.Mobile'      ,  5, 'Employees.LBL_REPORTS_TO'               , 'REPORTS_TO_ID'              , 0, 5, 'REPORTS_TO_NAME'     , 'return EmployeePopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  6, 'Employees.LBL_OTHER'                    , 'PHONE_OTHER'                , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditView.Mobile'      ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  8, 'Employees.LBL_FAX'                      , 'PHONE_FAX'                  , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      ,  9, 'Employees.LBL_EMAIL'                    , 'EMAIL1'                     , 0, 5, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 10, 'Employees.LBL_HOME_PHONE'               , 'PHONE_HOME'                 , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 11, 'Employees.LBL_OTHER_EMAIL'              , 'EMAIL2'                     , 0, 5, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditView.Mobile'      , 12, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Employees.EditView.Mobile'      , 13, 'Employees.LBL_MESSENGER_TYPE'           , 'MESSENGER_TYPE'             , 0, 5, 'messenger_type_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditView.Mobile'      , 14, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 15, 'Employees.LBL_MESSENGER_ID'             , 'MESSENGER_ID'               , 0, 5,  25, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditView.Mobile'      , 16, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Employees.EditView.Mobile'      , 17, 'Employees.LBL_NOTES'                    , 'DESCRIPTION'                , 0, 7,   4, 80, 3;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Employees.EditView.Mobile'      , 18;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Employees.EditView.Mobile'      , 19, 'Employees.LBL_PRIMARY_ADDRESS'          , 'ADDRESS_STREET'             , 0, 8,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 20, 'Employees.LBL_CITY'                     , 'ADDRESS_CITY'               , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 21, 'Employees.LBL_STATE'                    , 'ADDRESS_STATE'              , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Employees.EditView.Mobile'      , 22, 'Employees.LBL_POSTAL_CODE'              , 'ADDRESS_POSTALCODE'         , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditView.Mobile'      , 23, 'Employees.LBL_COUNTRY'                  , 'ADDRESS_COUNTRY'            , 0, 8, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditView.Mobile'      , 24, null;
end else begin
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Employees.EditView.Mobile', 'Employees.EditAddress.Mobile', 'Employees.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Employees.EditView.Mobile', 'ADDRESS_POSTALCODE';
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Employees.EditAddress.Mobile', 'Employees', 'vwEMPLOYEES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Employees.EditAddress.Mobile'   ,  0, 'Employees.LBL_PRIMARY_ADDRESS'          , 'ADDRESS_STREET'             , 0, 8,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditAddress.Mobile'   ,  1, 'Employees.LBL_CITY'                     , 'ADDRESS_CITY'               , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditAddress.Mobile'   ,  2, 'Employees.LBL_STATE'                    , 'ADDRESS_STATE'              , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditAddress.Mobile'   ,  3, 'Employees.LBL_POSTAL_CODE'              , 'ADDRESS_POSTALCODE'         , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditAddress.Mobile'   ,  4, 'Employees.LBL_COUNTRY'                  , 'ADDRESS_COUNTRY'            , 0, 8, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditAddress.Mobile'   ,  5, null;
end -- if;
*/
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.EditStatus' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.EditStatus';
	exec dbo.spEDITVIEWS_InsertOnly            'Employees.EditStatus', 'Employees', 'vwEMPLOYEES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditStatus'    ,  0, 'Employees.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, 1,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditStatus'    ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Employees.EditStatus'    ,  2, 'Employees.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, 1,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditStatus'    ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Employees.EditStatus'    ,  4, 'Employees.LBL_EMPLOYEE_STATUS'          , 'EMPLOYEE_STATUS'            , 0, 1, 'employee_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Employees.EditStatus'    ,  5, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'iFrames.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS iFrames.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'iFrames.EditView.Mobile'       , 'iFrames'       , 'vwIFRAMES_Edit'       , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iFrames.EditView.Mobile'        ,  0, 'iFrames.LBL_NAME'                       , 'NAME'                       , 1, 1, 255, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'iFrames.EditView.Mobile'        ,  1, 'iFrames.LBL_STATUS'                     , 'STATUS'                     , 0, 2, 'CheckBox'      , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iFrames.EditView.Mobile'        ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iFrames.EditView.Mobile'        ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'iFrames.EditView.Mobile'        ,  4, 'iFrames.LBL_URL'                        , 'URL'                        , 1, 1, 255, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iFrames.EditView.Mobile'        ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iFrames.EditView.Mobile'        ,  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'iFrames.EditView.Mobile'        ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'iFrames.EditView.Mobile'        ,  8, 'iFrames.LBL_PLACEMENT'                  , 'PLACEMENT'                  , 1, 2, 'DROPDOWN_PLACEMENT', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'iFrames.EditView.Mobile'        ,  9, 'iFrames.LBL_TYPE'                       , 'TYPE'                       , 1, 2, 'DROPDOWN_TYPE'     , null, null;
end -- if;
--GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.EditView.Mobile'         , 'Leads'         , 'vwLEADS_Edit'         , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.EditView.Mobile'          ,  0, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.EditView.Mobile'          ,  1, 'Leads.LBL_STATUS'                       , 'STATUS'                     , 0, 2, 'lead_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditView.Mobile'          ,  2, 'Leads.LBL_LEAD_SOURCE_DESCRIPTION'      , 'LEAD_SOURCE_DESCRIPTION'    , 0, 1,   3, 60, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditView.Mobile'          ,  3, 'Leads.LBL_STATUS_DESCRIPTION'           , 'STATUS_DESCRIPTION'         , 0, 2,   3, 60, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          ,  4, 'Leads.LBL_REFERED_BY'                   , 'REFERED_BY'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          ,  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.EditView.Mobile'          ,  8, 'Leads.LBL_FIRST_NAME'                   , 'SALUTATION'                 , 0, 1, 'salutation_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          ,  9, null                                     , 'FIRST_NAME'                 , 0, 1,  25, 25, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 10, 'Leads.LBL_OFFICE_PHONE'                 , 'PHONE_WORK'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 11, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 1, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 12, 'Leads.LBL_MOBILE_PHONE'                 , 'PHONE_MOBILE'               , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          , 13, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 14, 'Leads.LBL_HOME_PHONE'                   , 'PHONE_HOME'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 15, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, 1, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 16, 'Leads.LBL_OTHER_PHONE'                  , 'PHONE_OTHER'                , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          , 17, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 18, 'Leads.LBL_FAX_PHONE'                    , 'PHONE_FAX'                  , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 19, 'Leads.LBL_TITLE'                        , 'TITLE'                      , 0, 1,  40, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 20, 'Leads.LBL_EMAIL_ADDRESS'                , 'EMAIL1'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 21, 'Leads.LBL_DEPARTMENT'                   , 'DEPARTMENT'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 22, 'Leads.LBL_OTHER_EMAIL_ADDRESS'          , 'EMAIL2'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditView.Mobile'          , 23, 'Leads.LBL_DO_NOT_CALL'                  , 'DO_NOT_CALL'                , 0, 1, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditView.Mobile'          , 24, 'Leads.LBL_EMAIL_OPT_OUT'                , 'EMAIL_OPT_OUT'              , 0, 2, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.EditView.Mobile'          , 25, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.EditView.Mobile'          , 26, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.EditView.Mobile'          , 27, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditView.Mobile'          , 28, 'Leads.LBL_INVALID_EMAIL'                , 'INVALID_EMAIL'              , 0, 2, 'CheckBox'           , null, null, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Leads.EditView.Mobile'          , 29;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditView.Mobile'          , 30, 'Leads.LBL_PRIMARY_ADDRESS_STREET'       , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditView.Mobile'          , 31, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditView.Mobile'          , 32, 'Leads.LBL_ALT_ADDRESS_STREET'           , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 33, 'Leads.LBL_CITY'                         , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 34, 'Leads.LBL_CITY'                         , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 35, 'Leads.LBL_STATE'                        , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 36, 'Leads.LBL_STATE'                        , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 37, 'Leads.LBL_POSTAL_CODE'                  , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 38, 'Leads.LBL_POSTAL_CODE'                  , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 39, 'Leads.LBL_COUNTRY'                      , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Mobile'          , 40, 'Leads.LBL_COUNTRY'                      , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Leads.EditView.Mobile'          , 41;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditView.Mobile'          , 42, 'Leads.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Leads.EditView.Mobile'          , 27, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Leads.EditView.Mobile', 'Leads.EditAddress.Mobile', 'Leads.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditDescription.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Leads.EditView.Mobile', 'Leads.EditDescription.Mobile', 'Leads.LBL_DESCRIPTION_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Leads.EditView.Mobile', 'PRIMARY_ADDRESS_POSTALCODE';
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Leads.EditView.Mobile', 'ALT_ADDRESS_POSTALCODE';
end -- if;
--GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.EditAddress.Mobile', 'Leads', 'vwLEADS_Edit', '15%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditAddress.Mobile'       ,  0, 'Leads.LBL_PRIMARY_ADDRESS_STREET'       , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditAddress.Mobile'       ,  1, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditAddress.Mobile'       ,  2, 'Leads.LBL_ALT_ADDRESS_STREET'           , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  3, 'Leads.LBL_CITY'                         , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  4, 'Leads.LBL_CITY'                         , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  5, 'Leads.LBL_STATE'                        , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  6, 'Leads.LBL_STATE'                        , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  7, 'Leads.LBL_POSTAL_CODE'                  , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  8, 'Leads.LBL_POSTAL_CODE'                  , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       ,  9, 'Leads.LBL_COUNTRY'                      , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditAddress.Mobile'       , 10, 'Leads.LBL_COUNTRY'                      , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;
end -- if;
*/
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditDescription.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.EditDescription.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.EditDescription.Mobile', 'Leads', 'vwLEADS_Edit', '15%', '85%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Leads.EditDescription.Mobile'   ,  0, 'Leads.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end -- if;
*/
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Meetings.EditView.Mobile'      , 'Meetings'      , 'vwMEETINGS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Mobile'       ,  0, 'Meetings.LBL_NAME'                      , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.EditView.Mobile'       ,  1, 'Meetings.LBL_STATUS'                    , 'STATUS'                     , 1, 2, 'meeting_status_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Mobile'       ,  2, 'Meetings.LBL_LOCATION'                  , 'LOCATION'                   , 0, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.EditView.Mobile'       ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.EditView.Mobile'       ,  4, 'Meetings.LBL_DATE_TIME'                 , 'DATE_START'                 , 1, 1, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.EditView.Mobile'       ,  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Mobile'       ,  6, 'Meetings.LBL_DURATION'                  , 'DURATION_HOURS'             , 1, 1,   2,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.EditView.Mobile'       ,  7, null                                     , 'DURATION_MINUTES'           , 0, 1, 'meeting_minutes_dom', -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Meetings.EditView.Mobile'       ,  8, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 3, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.EditView.Mobile'       ,  9, 'Meetings.LBL_REMINDER'                  , 'SHOULD_REMIND'              , 0, 1, 'CheckBox'           , 'toggleDisplay(''should_remind_list'');', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.EditView.Mobile'       , 10, null                                     , 'REMINDER_TIME'              , 0, 1, 'reminder_time_dom'  , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Meetings.EditView.Mobile'       , 11, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Meetings.EditView.Mobile'       , 12, 'Meetings.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 3,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Meetings.EditView.Mobile'       ,  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Notes.EditView.Mobile'          , 'Notes'         , 'vwNOTES_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.EditView.Mobile'          ,  0, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_ID'                 , 0, 1, 'CONTACT_NAME'       , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Notes.EditView.Mobile'          ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 2, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.EditView.Mobile'          ,  2, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Notes.EditView.Mobile'          ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Notes.EditView.Mobile'          ,  4, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 255,100, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Notes.EditView.Mobile'          ,  5, 'Notes.LBL_FILENAME'                     , 'ATTACHMENT'                 , 0, 2, 255, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Notes.EditView.Mobile'          ,  6, null                                     , 'FILENAME'                   , -1;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Notes.EditView.Mobile'          ,  7, 'Notes.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 3,  30, 90, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Notes.EditView.Mobile'          ,  0, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_ID'                 , 0, 1, 'CONTACT_NAME'       , 'Contacts', null;
end -- if;
GO

-- 10/06/2010 Paul.  Size of NAME field was increased to 150. 
-- 12/12/2009 Paul.  The Accounts popup was pointing to the Contacts module. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.EditView.Mobile' , 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Mobile'  ,  0, 'Opportunities.LBL_OPPORTUNITY_NAME'     , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Mobile'  ,  1, 'Opportunities.LBL_CURRENCY'             , 'CURRENCY_ID'                , 0, 2, 'Currencies'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Mobile'  ,  2, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Mobile'  ,  3, 'Opportunities.LBL_AMOUNT'               , 'AMOUNT'                     , 1, 2,  25, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Mobile'  ,  4, 'Opportunities.LBL_TYPE'                 , 'OPPORTUNITY_TYPE'           , 0, 1, 'opportunity_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.EditView.Mobile'  ,  5, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 1, 2, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Mobile'  ,  6, 'Opportunities.LBL_LEAD_SOURCE'          , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Mobile'  ,  7, 'Opportunities.LBL_NEXT_STEP'            , 'NEXT_STEP'                  , 0, 2,  25, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Mobile'  ,  8, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'           , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Mobile'  ,  9, 'Opportunities.LBL_PROBABILITY'          , 'PROBABILITY'                , 0, 2,   3,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Mobile'  , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Mobile'  , 11, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 0, 2, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Opportunities.EditView.Mobile'  , 12, 'Opportunities.LBL_DESCRIPTION'          , 'DESCRIPTION'                , 0, 3,   8, 60, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Opportunities.EditView.Mobile'  ,  2, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Opportunities.EditView.Mobile'  , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	-- 12/12/2009 Paul.  The Accounts popup was pointing to the Contacts module. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Mobile' and DATA_FIELD = 'ACCOUNT_ID' and MODULE_TYPE = 'Contacts' and DELETED = 0) begin -- then
		print 'Opportunities.EditView.Mobile: Fix to point to Accounts module.';
		update EDITVIEWS_FIELDS
		   set MODULE_TYPE      = 'Accounts'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'Opportunities.EditView.Mobile'
		   and DATA_FIELD       = 'ACCOUNT_ID'
		   and MODULE_TYPE      = 'Contacts'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.EditView.Mobile';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Project.EditView.Mobile'       , 'Project'       , 'vwPROJECTS_Edit'      , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Project.EditView.Mobile'        ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Project.EditView.Mobile'        ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Mobile'        ,  2, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Mobile'        ,  3, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Mobile'        ,  4, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, 1, 'project_status_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Mobile'        ,  5, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.EditView.Mobile'        ,  6, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.EditView.Mobile'        ,  7, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Project.EditView.Mobile'        ,  8, 'Project.LBL_DESCRIPTION'                , 'DESCRIPTION'                , 0, 3,   8, 60, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Project.EditView.Mobile'        ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.EditView.Mobile' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'EDITVIEWS_FIELDS Project.EditView.Mobile: Add start date and end date';
		update EDITVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 4
		 where EDIT_NAME  = 'Project.EditView.Mobile'
		   and FIELD_INDEX >= 2
		   and DELETED      = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Mobile'        ,  2, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Mobile'        ,  3, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Mobile'        ,  4, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, 1, 'project_status_dom'       , null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Mobile'        ,  5, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
	end -- if;
end -- if;
GO

-- 01/19/2010 Paul.  We need to be able to format a Float field to prevent too many decimal places. 
-- 11/03/2011 Paul.  Change field name to match stored procedure. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'ProjectTask.EditView.Mobile'   , 'ProjectTask'   , 'vwPROJECT_TASKS_Edit' , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Mobile'    ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'                , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Mobile'    ,  2, 'ProjectTask.LBL_STATUS'                 , 'STATUS'                     , 0, 2, 'project_task_status_options'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Mobile'    ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'                       , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    ,  4, 'ProjectTask.LBL_TASK_NUMBER'            , 'TASK_NUMBER'                , 0, 3,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Mobile'    ,  5, 'ProjectTask.LBL_DEPENDS_ON_ID'          , 'DEPENDS_ON_ID'              , 0,13, 'DEPENDS_ON_NAME'                 , 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Mobile'    ,  6, 'ProjectTask.LBL_PRIORITY'               , 'PRIORITY'                   , 0, 4, 'project_task_priority_options'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Mobile'    ,  7, 'ProjectTask.LBL_MILESTONE_FLAG'         , 'MILESTONE_FLAG'             , 0,14, 'CheckBox'                        , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    ,  8, 'ProjectTask.LBL_ORDER_NUMBER'           , 'ORDER_NUMBER'               , 0, 5,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Mobile'    ,  9, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 0,15, 'PROJECT_NAME'                    , 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    , 10, 'ProjectTask.LBL_PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'           , 0, 6,   3,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Mobile'    , 11, 'ProjectTask.LBL_UTILIZATION'            , 'UTILIZATION'                , 0,18, 'project_task_utilization_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Mobile'    , 12, 'ProjectTask.LBL_DATE_START'             , 'DATE_TIME_START'            , 0, 7, 'DateTimeEdit'                    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    , 13, 'ProjectTask.LBL_ESTIMATED_EFFORT'       , 'ESTIMATED_EFFORT'           , 0,19,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Mobile'    , 14, 'ProjectTask.LBL_DATE_DUE'               , 'DATE_TIME_DUE'              , 0, 8, 'DateTimeEdit'                    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Mobile'    , 15, 'ProjectTask.LBL_ACTUAL_EFFORT'          , 'ACTUAL_EFFORT'              , 0,20,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'ProjectTask.EditView.Mobile'    , 16, 'ProjectTask.LBL_DESCRIPTION'            , 'DESCRIPTION'                , 0,21,   8, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Mobile', 'ESTIMATED_EFFORT', 'f1';
	exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Mobile', 'ACTUAL_EFFORT'   , 'f1';
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'ProjectTask.EditView.Mobile'    ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'                , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'ProjectTask.EditView.Mobile'    ,  5, 'ProjectTask.LBL_DEPENDS_ON_ID'          , 'DEPENDS_ON_ID'              , 0,13, 'DEPENDS_ON_NAME'                 , 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'ProjectTask.EditView.Mobile'    ,  9, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 0,15, 'PROJECT_NAME'                    , 'Project', null;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Mobile' and DATA_FIELD = 'ESTIMATED_EFFORT' and DATA_FORMAT is null and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Mobile', 'ESTIMATED_EFFORT', 'f1';
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Mobile' and DATA_FIELD = 'ACTUAL_EFFORT' and DATA_FORMAT is null and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Mobile', 'ACTUAL_EFFORT'   , 'f1';
	end -- if;
	-- 11/03/2011 Paul.  Change field name to match stored procedure. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Mobile' and DATA_FIELD = 'DATE_DUE' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_DUE'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'ProjectTask.EditView.Mobile'
		   and DATA_FIELD        = 'DATE_DUE'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Mobile' and DATA_FIELD = 'DATE_START' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_START'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'ProjectTask.EditView.Mobile'
		   and DATA_FIELD        = 'DATE_START'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'ProspectLists.EditView.Mobile' , 'ProspectLists' , 'vwPROSPECT_LISTS_Edit' , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProspectLists.EditView.Mobile'  ,  0, 'ProspectLists.LBL_NAME'                 , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.EditView.Mobile'  ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'      , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProspectLists.EditView.Mobile'  ,  2, 'ProspectLists.LBL_LIST_TYPE'            , 'LIST_TYPE'                  , 1, 1, 'prospect_list_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProspectLists.EditView.Mobile'  ,  3, 'ProspectLists.LBL_DOMAIN_NAME'          , 'DOMAIN_NAME'                , 0, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.EditView.Mobile'  ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'             , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'ProspectLists.EditView.Mobile'  ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'ProspectLists.EditView.Mobile'  ,  6, 'ProspectLists.LBL_DESCRIPTION'          , 'DESCRIPTION'                , 0, 3,   8, 80, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'ProspectLists.EditView.Mobile'  ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'      , 'Users', null;
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
-- 04/13/2016 Paul.  Add ZipCode lookup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.EditView.Mobile'     , 'Prospects'     , 'vwPROSPECTS_Edit'     , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Prospects.EditView.Mobile'      ,  0, 'Prospects.LBL_FIRST_NAME'               , 'SALUTATION'                 , 0, 1, 'salutation_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  1, null                                     , 'FIRST_NAME'                 , 0, 1,  25, 25, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  2, 'Prospects.LBL_OFFICE_PHONE'             , 'PHONE_WORK'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  3, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 1, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  4, 'Prospects.LBL_MOBILE_PHONE'             , 'PHONE_MOBILE'               , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.EditView.Mobile'      ,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  6, 'Prospects.LBL_HOME_PHONE'               , 'PHONE_HOME'                 , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.EditView.Mobile'      ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  8, 'Prospects.LBL_OTHER_PHONE'              , 'PHONE_OTHER'                , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      ,  9, 'Prospects.LBL_TITLE'                    , 'TITLE'                      , 0, 1,  40, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 10, 'Prospects.LBL_FAX_PHONE'                , 'PHONE_FAX'                  , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 11, 'Prospects.LBL_DEPARTMENT'               , 'DEPARTMENT'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 12, 'Prospects.LBL_EMAIL_ADDRESS'            , 'EMAIL1'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditView.Mobile'      , 13, 'Prospects.LBL_BIRTHDATE'                , 'BIRTHDATE'                  , 0, 1, 'DatePicker'         , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 14, 'Prospects.LBL_OTHER_EMAIL_ADDRESS'      , 'EMAIL2'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.EditView.Mobile'      , 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 16, 'Prospects.LBL_ASSISTANT'                , 'ASSISTANT'                  , 0, 2,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.EditView.Mobile'      , 17, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 18, 'Prospects.LBL_ASSISTANT_PHONE'          , 'ASSISTANT_PHONE'            , 0, 2,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditView.Mobile'      , 19, 'Prospects.LBL_DO_NOT_CALL'              , 'DO_NOT_CALL'                , 0, 1, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditView.Mobile'      , 20, 'Prospects.LBL_EMAIL_OPT_OUT'            , 'EMAIL_OPT_OUT'              , 0, 2, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.EditView.Mobile'      , 21, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.EditView.Mobile'      , 22, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.EditView.Mobile'      , 23, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditView.Mobile'      , 24, 'Prospects.LBL_INVALID_EMAIL'            , 'INVALID_EMAIL'              , 0, 2, 'CheckBox'           , null, null, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Prospects.EditView.Mobile'      , 25;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditView.Mobile'      , 26, 'Prospects.LBL_PRIMARY_ADDRESS_STREET'   , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditView.Mobile'      , 27, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditView.Mobile'      , 28, 'Prospects.LBL_ALT_ADDRESS_STREET'       , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 29, 'Prospects.LBL_CITY'                     , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 30, 'Prospects.LBL_CITY'                     , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 31, 'Prospects.LBL_STATE'                    , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 32, 'Prospects.LBL_STATE'                    , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Prospects.EditView.Mobile'      , 33, 'Prospects.LBL_POSTAL_CODE'              , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Prospects.EditView.Mobile'      , 34, 'Prospects.LBL_POSTAL_CODE'              , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 35, 'Prospects.LBL_COUNTRY'                  , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Mobile'      , 36, 'Prospects.LBL_COUNTRY'                  , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Prospects.EditView.Mobile'      , 37;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditView.Mobile'      , 38, 'Prospects.LBL_DESCRIPTION'              , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Prospects.EditView.Mobile'      , 23, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Prospects.EditView.Mobile', 'Prospects.EditAddress.Mobile', 'Prospects.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditDescription.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Prospects.EditView.Mobile', 'Prospects.EditDescription.Mobile', 'Prospects.LBL_DESCRIPTION_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Prospects.EditView.Mobile', 'PRIMARY_ADDRESS_POSTALCODE';
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Prospects.EditView.Mobile', 'ALT_ADDRESS_POSTALCODE';
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.EditAddress.Mobile', 'Prospects', 'vwPROSPECTS_Edit', '15%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditAddress.Mobile'   ,  0, 'Prospects.LBL_PRIMARY_ADDRESS_STREET'   , 'PRIMARY_ADDRESS_STREET'     , 0, 3,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Prospects.EditAddress.Mobile'   ,  1, null                                     , null                         , 0, null, 'AddressButtons', null, null, 5;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditAddress.Mobile'   ,  2, 'Prospects.LBL_ALT_ADDRESS_STREET'       , 'ALT_ADDRESS_STREET'         , 0, 4,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  3, 'Prospects.LBL_CITY'                     , 'PRIMARY_ADDRESS_CITY'       , 0, 3, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  4, 'Prospects.LBL_CITY'                     , 'ALT_ADDRESS_CITY'           , 0, 4, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  5, 'Prospects.LBL_STATE'                    , 'PRIMARY_ADDRESS_STATE'      , 0, 3, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  6, 'Prospects.LBL_STATE'                    , 'ALT_ADDRESS_STATE'          , 0, 4, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  7, 'Prospects.LBL_POSTAL_CODE'              , 'PRIMARY_ADDRESS_POSTALCODE' , 0, 3,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  8, 'Prospects.LBL_POSTAL_CODE'              , 'ALT_ADDRESS_POSTALCODE'     , 0, 4,  20, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   ,  9, 'Prospects.LBL_COUNTRY'                  , 'PRIMARY_ADDRESS_COUNTRY'    , 0, 3, 100, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditAddress.Mobile'   , 10, 'Prospects.LBL_COUNTRY'                  , 'ALT_ADDRESS_COUNTRY'        , 0, 4, 100, 10, null;
end -- if;
*/
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditDescription.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.EditDescription.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.EditDescription.Mobile', 'Prospects', 'vwPROSPECTS_Edit', '15%', '85%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Prospects.EditDescription.Mobile',  0, 'Prospects.LBL_DESCRIPTION'              , 'DESCRIPTION'                , 0, 5,   8, 60, null;
end -- if;
*/
GO

-- 11/03/2011 Paul.  Change field name to match stored procedure. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Tasks.EditView.Mobile'         , 'Tasks'         , 'vwTASKS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tasks.EditView.Mobile'          ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView.Mobile'          ,  1, 'Tasks.LBL_STATUS'                       , 'STATUS'                     , 1, 2, 'task_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView.Mobile'          ,  2, 'Tasks.LBL_DUE_DATE_AND_TIME'            , 'DATE_TIME_DUE'              , 0, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Tasks.EditView.Mobile'          ,  3, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 2, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView.Mobile'          ,  4, 'Tasks.LBL_START_DATE_AND_TIME'          , 'DATE_TIME_START'            , 0, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Mobile'          ,  5, 'Tasks.LBL_CONTACT'                      , 'CONTACT_ID'                 , 0, 2, 'CONTACT_NAME'       , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView.Mobile'          ,  6, 'Tasks.LBL_PRIORITY'                     , 'PRIORITY'                   , 1, 1, 'task_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tasks.EditView.Mobile'          ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Mobile'          ,  8, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tasks.EditView.Mobile'          ,  9, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Mobile'          , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tasks.EditView.Mobile'          , 11, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Tasks.EditView.Mobile'          , 12, 'Tasks.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 3,   8, 60, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Tasks.EditView.Mobile'          ,  5, 'Tasks.LBL_CONTACT'                      , 'CONTACT_ID'                 , 0, 2, 'CONTACT_NAME'       , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Tasks.EditView.Mobile'          , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	-- 11/03/2011 Paul.  Change field name to match stored procedure. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Mobile' and DATA_FIELD = 'DATE_DUE' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_DUE'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Tasks.EditView.Mobile'
		   and DATA_FIELD        = 'DATE_DUE'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Mobile' and DATA_FIELD = 'DATE_START' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_START'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Tasks.EditView.Mobile'
		   and DATA_FIELD        = 'DATE_START'
		   and DELETED           = 0;
	end -- if;
end -- if;                                                           
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
-- 04/13/2016 Paul.  Add ZipCode lookup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Users.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Users.EditView.Mobile'         , 'Users'         , 'vwUSERS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Users.EditView.Mobile'          ,  1, 'Users.LBL_EMPLOYEE_STATUS'              , 'EMPLOYEE_STATUS'            , 0, 5, 'employee_status_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          ,  3, 'Users.LBL_TITLE'                        , 'TITLE'                      , 0, 5,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          ,  4, 'Users.LBL_OFFICE_PHONE'                 , 'PHONE_WORK'                 , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          ,  5, 'Users.LBL_DEPARTMENT'                   , 'DEPARTMENT'                 , 0, 5,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          ,  6, 'Users.LBL_MOBILE_PHONE'                 , 'PHONE_MOBILE'               , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Users.EditView.Mobile'          ,  7, 'Contacts.LBL_REPORTS_TO'                , 'REPORTS_TO_ID'              , 0, 5, 'REPORTS_TO_NAME'        , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          ,  8, 'Users.LBL_OTHER'                        , 'PHONE_OTHER'                , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          ,  9, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 10, 'Users.LBL_FAX'                          , 'PHONE_FAX'                  , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          , 11, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 12, 'Users.LBL_HOME_PHONE'                   , 'PHONE_HOME'                 , 0, 6,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Users.EditView.Mobile'          , 13, 'Users.LBL_MESSENGER_TYPE'               , 'MESSENGER_TYPE'             , 0, 5, 'messenger_type_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          , 14, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 15, 'Users.LBL_MESSENGER_ID'                 , 'MESSENGER_ID'               , 0, 5,  25, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          , 16, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Users.EditView.Mobile'          , 17, 'Users.LBL_NOTES'                        , 'DESCRIPTION'                , 0, 7,   4, 80, 3;

	exec dbo.spEDITVIEWS_FIELDS_InsSeparator   'Users.EditView.Mobile'          , 18;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Users.EditView.Mobile'          , 19, 'Users.LBL_PRIMARY_ADDRESS'              , 'ADDRESS_STREET'             , 0, 8,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 20, 'Users.LBL_CITY'                         , 'ADDRESS_CITY'               , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 21, 'Users.LBL_STATE'                        , 'ADDRESS_STATE'              , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsZipCode     'Users.EditView.Mobile'          , 22, 'Users.LBL_POSTAL_CODE'                  , 'ADDRESS_POSTALCODE'         , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditView.Mobile'          , 23, 'Users.LBL_COUNTRY'                      , 'ADDRESS_COUNTRY'            , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditView.Mobile'          , 24, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'Users.EditView.Mobile'          ,  7, 'Contacts.LBL_REPORTS_TO'                , 'REPORTS_TO_ID'              , 0, 5, 'REPORTS_TO_NAME'        , 'Users', null;
	-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.EditAddress.Mobile' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_MergeView      'Users.EditView.Mobile', 'Users.EditAddress.Mobile', 'Users.LBL_ADDRESS_INFORMATION', null;
	end -- if;
	-- 04/13/2016 Paul.  Add ZipCode lookup. 
	exec dbo.spEDITVIEWS_FIELDS_CnvZipCodePopup 'Users.EditView.Mobile', 'ADDRESS_POSTALCODE';
end -- if;
GO

-- 09/02/2012 Paul.  Merge layout so that there is only one table to render in the HTML5 Client. 
/*
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.EditAddress.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Users.EditAddress.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'Users.EditAddress.Mobile', 'Users', 'vwUSERS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Users.EditAddress.Mobile'       ,  0, 'Users.LBL_PRIMARY_ADDRESS'              , 'ADDRESS_STREET'             , 0, 8,   2, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditAddress.Mobile'       ,  1, 'Users.LBL_CITY'                         , 'ADDRESS_CITY'               , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditAddress.Mobile'       ,  2, 'Users.LBL_STATE'                        , 'ADDRESS_STATE'              , 0, 8, 100, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditAddress.Mobile'       ,  3, 'Users.LBL_POSTAL_CODE'                  , 'ADDRESS_POSTALCODE'         , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Users.EditAddress.Mobile'       ,  4, 'Users.LBL_COUNTRY'                      , 'ADDRESS_COUNTRY'            , 0, 8,  20, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Users.EditAddress.Mobile'       ,  5, null;
end -- if;
*/
GO

-- 08/27/2009 Paul.  Remove ConvertView as it is not currently supported on the mobile platform. 

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ACLRoles.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ACLRoles.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'ACLRoles.EditView.Mobile', 'ACLRoles', 'vwACL_ROLES_Edit', '15%', '85%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ACLRoles.EditView.Mobile'       ,  0, 'ACLRoles.LBL_NAME'                      , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'ACLRoles.EditView.Mobile'       ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'ACLRoles.EditView.Mobile'       ,  2, 'ACLRoles.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 2,   8, 60, null;
end -- if;
GO

-- 03/01/2019 Paul.  Remove bad data. 
if exists(select * from EDITVIEWS where NAME = 'CampaignTrackers.DetailView') begin -- then
	delete from EDITVIEWS
	 where NAME = 'CampaignTrackers.DetailView';
end -- if;

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'CampaignTrackers.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS CampaignTrackers.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'CampaignTrackers.EditView.Mobile', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'CampaignTrackers.EditView.Mobile',  0, 'CampaignTrackers.LBL_EDIT_CAMPAIGN_NAME'   , 'CAMPAIGN_NAME'             , 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CampaignTrackers.EditView.Mobile',  1, 'CampaignTrackers.LBL_EDIT_TRACKER_NAME'    , 'TRACKER_NAME'              , 1, 2,  30, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'CampaignTrackers.EditView.Mobile',  2, 'CampaignTrackers.LBL_EDIT_OPT_OUT'         , 'IS_OPTOUT'                 , 0, 1, 'CheckBox', 'IS_OPTOUT_Clicked();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CampaignTrackers.EditView.Mobile',  3, 'CampaignTrackers.LBL_EDIT_TRACKER_URL'     , 'TRACKER_URL'               , 1, 2, 255, 90, 3;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMarketing.EditView.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailMarketing.EditView.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly            'EmailMarketing.EditView.Mobile', 'EmailMarketing', 'vwEMAIL_MARKETING_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMarketing.EditView.Mobile'  ,  0, 'EmailMarketing.LBL_NAME'                   , 'NAME'                      , 1, 1, 255, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'EmailMarketing.EditView.Mobile'  ,  1, 'EmailMarketing.LBL_STATUS_TEXT'            , 'STATUS'                    , 1, 2, 'email_marketing_status_dom'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMarketing.EditView.Mobile'  ,  2, 'EmailMarketing.LBL_FROM_MAILBOX_NAME'      , 'FROM_ADDR'                 , 0, 1, 100, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'EmailMarketing.EditView.Mobile'  ,  3, 'EmailMarketing.LBL_FROM_NAME'              , 'FROM_NAME'                 , 1, 2, 100, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'EmailMarketing.EditView.Mobile'  ,  4, 'EmailMarketing.LBL_START_DATE_TIME'        , 'DATE_START'                , 1, 1, 'DateTimeEdit' , null, null, null;
	-- 08/29/2009 Paul.  Don't convert the ChangeButton to a ModulePopup. 
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'EmailMarketing.EditView.Mobile'  ,  5, 'EmailMarketing.LBL_TEMPLATE'               , 'TEMPLATE_ID'               , 1, 2, 'TEMPLATE_NAME', 'return EmailTemplatePopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'EmailMarketing.EditView.Mobile'  ,  6, 'EmailMarketing.LBL_MESSAGE_FOR'            , 'ALL_PROSPECT_LISTS'        , 0, 1, 'CheckBox'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'EmailMarketing.EditView.Mobile'  ,  7, null;
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

call dbo.spEDITVIEWS_FIELDS_EditViewMobileDefaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_EditViewMobileDefaults')
/

-- #endif IBM_DB2 */

