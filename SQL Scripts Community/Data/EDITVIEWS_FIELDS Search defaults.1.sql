

print 'EDITVIEWS_FIELDS Search defaults';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.Search%'
--GO

set nocount on;
GO

-- 12/17/2007 Paul.  Add support for Date Range searches. 
-- 02/10/2008 Paul.  Numeric fields should be smaller than regular text fields. 
-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
-- 09/10/2009 Paul.  Add support for AutoComplete. 
-- 03/31/2012 Paul.  Add support for searching favorites. 

-- 05/15/2016 Paul.  Add tags to advanced search. 
-- 06/07/2017 Paul.  Add NAICSCodes module. 
-- update EDITVIEWS_FIELDS set FIELD_TYPE = 'DateRange' where EDIT_NAME like '%.Search%' and FIELD_TYPE = 'DatePicker';
-- delete from EDITVIEWS where NAME = 'Accounts.SearchAdvanced';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchAdvanced' , 'Accounts', 'vwACCOUNTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchAdvanced' ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                                                  , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  1, 'Accounts.LBL_ANY_ADDRESS'               , 'BILLING_ADDRESS_STREET SHIPPING_ADDRESS_STREET'        , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  2, 'Accounts.LBL_ANY_PHONE'                 , 'PHONE_OFFICE PHONE_FAX PHONE_ALTERNATE'                , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  3, 'Accounts.LBL_WEBSITE'                   , 'WEBSITE'                                               , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  4, 'Accounts.LBL_CITY'                      , 'BILLING_ADDRESS_CITY SHIPPING_ADDRESS_CITY'            , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  5, 'Accounts.LBL_ANY_EMAIL'                 , 'EMAIL1 EMAIL2'                                         , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  6, 'Accounts.LBL_ANNUAL_REVENUE'            , 'ANNUAL_REVENUE'                                        , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  7, 'Accounts.LBL_STATE'                     , 'BILLING_ADDRESS_STATE SHIPPING_ADDRESS_STATE'          , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  8, 'Accounts.LBL_EMPLOYEES'                 , 'EMPLOYEES'                                             , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' ,  9, 'Accounts.LBL_POSTAL_CODE'               , 'BILLING_ADDRESS_POSTALCODE SHIPPING_ADDRESS_POSTALCODE', 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchAdvanced' , 10, 'Accounts.LBL_COUNTRY'                   , 'BILLING_ADDRESS_COUNTRY SHIPPING_ADDRESS_COUNTRY'      , 0, null, 'countries_dom'   , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' , 11, 'Accounts.LBL_TICKER_SYMBOL'             , 'TICKER_SYMBOL'                                         , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' , 12, 'Accounts.LBL_SIC_CODE'                  , 'SIC_CODE'                                              , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' , 13, 'Accounts.LBL_RATING'                    , 'RATING'                                                , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchAdvanced' , 14, 'Accounts.LBL_OWNERSHIP'                 , 'OWNERSHIP'                                             , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchAdvanced' , 15, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'                                      , 0, null, 'AssignedUser'    , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchAdvanced' , 16, 'Accounts.LBL_TYPE'                      , 'ACCOUNT_TYPE'                                          , 0, null, 'account_type_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchAdvanced' , 17, 'Accounts.LBL_INDUSTRY'                  , 'INDUSTRY'                                              , 0, null, 'industry_dom'    , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Accounts.SearchAdvanced' , 18, 0, null;
	exec dbo.spEDITVIEWS_FIELDS_InsNaicsSelect  'Accounts.SearchAdvanced' , 19, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Accounts.SearchAdvanced' ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                                                  , 0, null, 150, 25, 'Accounts', null;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Accounts.SearchAdvanced' , 18, 0, null;
	end -- if;
	-- 06/07/2017 Paul.  Add NAICSCodes module. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchAdvanced' and DATA_FIELD = 'NAICS_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsNaicsSelect  'Accounts.SearchAdvanced' , 19, 0, null;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS where NAME = 'Accounts.SearchBasic';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchBasic'    , 'Accounts', 'vwACCOUNTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchBasic'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic'    ,  1, 'Accounts.LBL_BILLING_ADDRESS_CITY'      , 'BILLING_ADDRESS_CITY'       , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic'    ,  2, 'Accounts.LBL_ANY_PHONE'                 , 'PHONE_OFFICE'               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic'    ,  3, 'Accounts.LBL_BILLING_ADDRESS_STREET'    , 'BILLING_ADDRESS_STREET'     , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Accounts.SearchBasic'    ,  4, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Accounts.SearchBasic'    ,  5, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Accounts.SearchBasic'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Accounts.SearchBasic'    ,  5, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchHome'     , 'Accounts', 'vwACCOUNTS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchHome'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Accounts.SearchHome'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchPopup'    , 'Accounts', 'vwACCOUNTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchPopup'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchPopup'    ,  1, 'Accounts.LBL_BILLING_ADDRESS_CITY'      , 'BILLING_ADDRESS_CITY'       , 0, null, 100, 25, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Accounts.SearchPopup'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Accounts.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchDuplicates' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchDuplicates'    , 'Accounts', 'vwACCOUNTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchDuplicates'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                                  , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Accounts.SearchDuplicates'    ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchDuplicates'    ,  2, 'Accounts.LBL_BILLING_ADDRESS_STREET'    , 'BILLING_ADDRESS_STREET'                , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchDuplicates'    ,  3, 'Accounts.LBL_ANY_PHONE'                 , 'PHONE_OFFICE PHONE_FAX PHONE_ALTERNATE', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchDuplicates'    ,  4, 'Accounts.LBL_BILLING_ADDRESS_CITY'      , 'BILLING_ADDRESS_CITY'                  , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchDuplicates'    ,  5, 'Accounts.LBL_ANY_EMAIL'                 , 'EMAIL1 EMAIL2'                         , 0, null, 100, 25, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Accounts.SearchDuplicates'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                                  , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 08/01/2009 Paul.  The Release list returns GUIDs as the value, but the vwBUGS view returned FOUND_IN_RELEASE as the text value. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchAdvanced'     , 'Bugs', 'vwBUGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Bugs.SearchAdvanced'     ,  0, 'Bugs.LBL_BUG_NUMBER'                    , 'BUG_NUMBER'                 , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchAdvanced'     ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  2, 'Bugs.LBL_RESOLUTION'                    , 'RESOLUTION'                 , 0, null, 'bug_resolution_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  3, 'Bugs.LBL_FOUND_IN_RELEASE'              , 'FOUND_IN_RELEASE_ID'        , 0, null, 'Release'             , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  4, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 0, null, 'bug_type_dom'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  5, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, null, 'bug_status_dom'      , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  6, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchAdvanced'     ,  7, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 0, null, 'bug_priority_dom'    , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Bugs.SearchAdvanced'     ,  8, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Bugs.SearchAdvanced'     ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	-- 08/01/2009 Paul.  The Release list returns GUIDs as the value, but the vwBUGS view returned FOUND_IN_RELEASE as the text value. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchAdvanced' and DATA_FIELD = 'FOUND_IN_RELEASE' and DELETED = 0) begin -- then
		print 'Fix Bugs.SearchAdvanced FOUND_IN_RELEASE.';
		update EDITVIEWS_FIELDS
		   set DATA_FIELD       = 'FOUND_IN_RELEASE_ID'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'Bugs.SearchAdvanced'
		   and DATA_FIELD       = 'FOUND_IN_RELEASE'
		   and DELETED          = 0;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Bugs.SearchAdvanced'     ,  8, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchBasic'        , 'Bugs', 'vwBUGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Bugs.SearchBasic'        ,  0, 'Bugs.LBL_BUG_NUMBER'                    , 'BUG_NUMBER'                 , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchBasic'        ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Bugs.SearchBasic'        ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Bugs.SearchBasic'        ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchBasic'        ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Bugs.SearchBasic'        ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchHome'         , 'Bugs', 'vwBUGS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchHome'         ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchHome'         ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchPopup'        , 'Bugs', 'vwBUGS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Bugs.SearchPopup'        ,  0, 'Bugs.LBL_BUG_NUMBER'                    , 'BUG_NUMBER'                 , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchPopup'        ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Bugs.SearchPopup'        ,  1, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Bugs.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchDuplicates' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchDuplicates'   , 'Bugs', 'vwBUGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchDuplicates'   ,  0, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Bugs.SearchDuplicates'   ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Bugs.SearchDuplicates'   ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchDuplicates'   ,  3, 'Bugs.LBL_RESOLUTION'                    , 'RESOLUTION'                 , 0, null, 'bug_resolution_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchDuplicates'   ,  4, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 0, null, 'bug_type_dom'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchDuplicates'   ,  5, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, null, 'bug_status_dom'      , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Bugs.SearchDuplicates'   ,  0, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchAdvanced'    , 'Calls', 'vwCALLS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchAdvanced'    ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchAdvanced'    ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Calls.SearchAdvanced'    ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Calls.SearchAdvanced'    ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Calls.SearchAdvanced'    ,  4, 'Calls.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'call_status_dom'     , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchAdvanced'    ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchAdvanced'    ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchBasic'       , 'Calls', 'vwCALLS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchBasic'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchBasic'       ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Calls.SearchBasic'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Calls.SearchBasic'       ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchBasic'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchBasic'       ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Calls.SearchBasic'       ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchHome'        , 'Calls', 'vwCALLS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Calls.SearchHome'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Calls.SearchHome'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchPopup'       , 'Calls', 'vwCALLS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchPopup'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Calls.SearchPopup'       ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchPopup'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Campaigns.SearchAdvanced', 'Campaigns', 'vwCAMPAIGNS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Campaigns.SearchAdvanced',  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Campaigns.SearchAdvanced',  1, 'Campaigns.LBL_CAMPAIGN_START_DATE'      , 'START_DATE'                 , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Campaigns.SearchAdvanced',  2, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                   , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Campaigns.SearchAdvanced',  3, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                     , 0, null, 'campaign_status_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Campaigns.SearchAdvanced',  4, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'              , 0, null, 'campaign_type_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Campaigns.SearchAdvanced',  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'       , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Campaigns.SearchAdvanced',  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Campaigns.SearchBasic'   , 'Campaigns', 'vwCAMPAIGNS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Campaigns.SearchBasic'   ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Campaigns.SearchBasic'   ,  1, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Campaigns.SearchBasic'   ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Campaigns.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Campaigns.SearchBasic'   ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Campaigns.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Campaigns.SearchPopup'   , 'Campaigns', 'vwCAMPAIGNS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Campaigns.SearchPopup'   ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Campaigns.SearchPopup'   ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Campaigns.SearchPopup'   ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 0, null,  50, 25, 'Campaigns', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchPreview';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.SearchPreview' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.SearchPreview';
	exec dbo.spEDITVIEWS_InsertOnly             'Campaigns.SearchPreview' , 'Campaigns', 'vwCAMPAIGNS_Send', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Campaigns.SearchPreview' ,  0, 'Contacts.LBL_CONTACT_NAME'              , 'RELATED_NAME'               , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Campaigns.SearchPreview' ,  1, 'Contacts.LBL_EMAIL1'                    , 'EMAIL1'                     , 0, null, 255, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'CampaignTrackers.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS CampaignTrackers.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'CampaignTrackers.SearchBasic', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'CampaignTrackers.SearchBasic',  0, 'CampaignTrackers.LBL_EDIT_TRACKER_NAME' , 'NAME'                       , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'CampaignTrackers.SearchBasic',  1, null;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchAdvanced'    , 'Cases', 'vwCASES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchAdvanced'    ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Cases.SearchAdvanced'    ,  1, 'Cases.LBL_CASE_NUMBER'                  , 'CASE_NUMBER'                , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Cases.SearchAdvanced'    ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchAdvanced'    ,  3, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'case_status_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchAdvanced'    ,  4, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, null, 'case_priority_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchAdvanced'    ,  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'     , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Cases.SearchAdvanced'    ,  6, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchAdvanced'    ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Cases.SearchAdvanced'    ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Cases.SearchAdvanced'    ,  6, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchBasic'       , 'Cases', 'vwCASES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Cases.SearchBasic'       ,  0, 'Cases.LBL_CASE_NUMBER'                  , 'CASE_NUMBER'                , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchBasic'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Cases.SearchBasic'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Cases.SearchBasic'       ,  3, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Cases.SearchBasic'       ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchBasic'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Cases.SearchBasic'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Cases.SearchBasic'       ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchHome'        , 'Cases', 'vwCASES_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchHome'        ,  0, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, null, 'case_priority_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchHome'        ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchHome'        ,  2, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchPopup'       , 'Cases', 'vwCASES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Cases.SearchPopup'       ,  0, 'Cases.LBL_CASE_NUMBER'                  , 'CASE_NUMBER'                , 0, null,  10, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchPopup'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchPopup'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchPopup'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchPopup'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Cases.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchDuplicates' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchDuplicates'  , 'Cases', 'vwCASES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchDuplicates'  ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Cases.SearchDuplicates'  ,  1, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchDuplicates'  ,  2, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'case_status_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchDuplicates'  ,  3, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, null, 'case_priority_dom', null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchDuplicates'  ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Cases.SearchDuplicates'  ,  1, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
end -- if;
GO

-- 09/10/2010 Paul.  Add last name autocomplete. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchAdvanced' , 'Contacts', 'vwCONTACTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                                                              , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  1, 'Contacts.LBL_ANY_ADDRESS'               , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  2, 'Contacts.LBL_ANY_PHONE'                 , 'PHONE_WORK PHONE_MOBILE PHONE_HOME PHONE_OTHER PHONE_FAX ASSISTANT_PHONE', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Contacts.SearchAdvanced' ,  3, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                                                               , 0, null,  25, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  4, 'Contacts.LBL_CITY'                      , 'PRIMARY_ADDRESS_CITY ALT_ADDRESS_CITY'                                   , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  5, 'Contacts.LBL_ANY_EMAIL'                 , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Contacts.SearchAdvanced' ,  6, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                                                              , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  7, 'Contacts.LBL_STATE'                     , 'PRIMARY_ADDRESS_STATE ALT_ADDRESS_STATE'                                 , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Contacts.SearchAdvanced' ,  8, 'Contacts.LBL_DO_NOT_CALL'               , 'DO_NOT_CALL'                                                             , 0, null, 'CheckBox', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' ,  9, 'Contacts.LBL_ASSISTANT'                 , 'ASSISTANT'                                                               , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchAdvanced' , 10, 'Contacts.LBL_POSTAL_CODE'               , 'PRIMARY_ADDRESS_POSTALCODE ALT_ADDRESS_POSTALCODE'                       , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Contacts.SearchAdvanced' , 11, 'Contacts.LBL_COUNTRY'                   , 'PRIMARY_ADDRESS_COUNTRY ALT_ADDRESS_COUNTRY'                             , 0, null, 'countries_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Contacts.SearchAdvanced' , 12, 'Contacts.LBL_LEAD_SOURCE'               , 'LEAD_SOURCE'                                                             , 0, null, 'lead_source_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Contacts.SearchAdvanced' , 13, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'                                                        , 0, null, 'AssignedUser'   , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Contacts.SearchAdvanced' , 14, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Contacts.SearchAdvanced' ,  6, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                                                              , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Contacts.SearchAdvanced' , 14, 0, null;
	end -- if;
end -- if;
GO

-- 09/10/2010 Paul.  Add last name autocomplete. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchBasic'    , 'Contacts', 'vwCONTACTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchBasic'    ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Contacts.SearchBasic'    ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Contacts.SearchBasic'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Contacts.SearchBasic'    ,  3, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Contacts.SearchBasic'    ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Contacts.SearchBasic'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Contacts.SearchBasic'    ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchHome'     , 'Contacts', 'vwCONTACTS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Contacts.SearchHome'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Contacts.SearchHome'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchPopup';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchPopup'    , 'Contacts', 'vwCONTACTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchPopup'    ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchPopup'    ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Contacts.SearchPopup'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Contacts.SearchPopup'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
	-- 06/23/2008 Paul.  Convert change button to a text field. Popups should not have popups. 
	if exists (select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchPopup' and FIELD_TYPE = 'ChangeButton' and DATA_FIELD = 'ACCOUNT_ID' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DELETED          = 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'Contacts.SearchPopup'
		   and FIELD_TYPE       = 'ChangeButton'
		   and DATA_FIELD       = 'ACCOUNT_ID'
		   and DELETED          = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchPopup'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, null;
	end -- if;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Contacts.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchDuplicates' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchDuplicates', 'Contacts', 'vwCONTACTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'Contacts.SearchDuplicates',  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Contacts.SearchDuplicates',  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  4, 'Contacts.LBL_ANY_ADDRESS'               , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  5, 'Contacts.LBL_ANY_PHONE'                 , 'PHONE_WORK PHONE_MOBILE PHONE_HOME PHONE_OTHER PHONE_FAX ASSISTANT_PHONE', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  6, 'Contacts.LBL_CITY'                      , 'PRIMARY_ADDRESS_CITY ALT_ADDRESS_CITY'                                   , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchDuplicates',  7, 'Contacts.LBL_ANY_EMAIL'                 , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'Contacts.SearchDuplicates',  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'     , 'Accounts', null;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to advanced search. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Documents.SearchAdvanced', 'Documents', 'vwDOCUMENTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Documents.SearchAdvanced',  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchAdvanced',  1, 'Documents.LBL_SF_CATEGORY'              , 'CATEGORY_ID'                , 0, null, 'document_category_dom'   , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchAdvanced',  2, 'Documents.LBL_SF_SUBCATEGORY'           , 'SUBCATEGORY_ID'             , 0, null, 'document_subcategory_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Documents.SearchAdvanced',  3, 'Documents.LBL_SF_ACTIVE_DATE'           , 'ACTIVE_DATE'                , 0, null, 'DateRange'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Documents.SearchAdvanced',  4, 'Documents.LBL_SF_EXP_DATE'              , 'EXP_DATE'                   , 0, null, 'DateRange'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Documents.SearchAdvanced',  5, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Documents.SearchAdvanced',  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Documents.SearchAdvanced',  5, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Documents.SearchBasic'   , 'Documents', 'vwDOCUMENTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Documents.SearchBasic'   ,  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchBasic'   ,  1, 'Documents.LBL_SF_CATEGORY'              , 'CATEGORY_ID'                , 0, null, 'document_category_dom'   , null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchBasic'   ,  2, 'Documents.LBL_SF_SUBCATEGORY'           , 'SUBCATEGORY_ID'             , 0, null, 'document_subcategory_dom', null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Documents.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Documents.SearchBasic'   ,  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Documents.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Documents.SearchPopup'   , 'Documents', 'vwDOCUMENTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Documents.SearchPopup'   ,  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchPopup'   ,  1, 'Documents.LBL_SF_CATEGORY'              , 'CATEGORY_ID'                , 0, null, 'document_category_dom'   , null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Documents.SearchPopup'   ,  2, 'Documents.LBL_SF_SUBCATEGORY'           , 'SUBCATEGORY_ID'             , 0, null, 'document_subcategory_dom', null, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Documents.SearchPopup'   ,  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailMarketing.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailMarketing.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'EmailMarketing.SearchBasic', 'EmailMarketing', 'vwEMAIL_MARKETING_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'EmailMarketing.SearchBasic',  0, 'EmailMarketing.LBL_NAME'              , 'NAME'                       , 0, null,  50, 25, null;
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'CallMarketing.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS CallMarketing.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'CallMarketing.SearchBasic' , 'CallMarketing', 'vwCALL_MARKETING_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'CallMarketing.SearchBasic' ,  0, 'CallMarketing.LBL_NAME'               , 'NAME'                       , 0, null,  50, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Emails.SearchBasic'      , 'Emails', 'vwEMAILS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchBasic'      ,  0, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, null,  50, 25, 'Emails'  , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchBasic'      ,  1, 'Emails.LBL_CONTACT_NAME'                , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Emails.SearchBasic'      ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Emails.SearchBasic'      ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Emails.SearchBasic'      ,  0, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, null,  50, 25, 'Emails'  , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Emails.SearchBasic'      ,  1, 'Emails.LBL_CONTACT_NAME'                , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Emails.SearchBasic'      ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 01/17/2008 Paul.  Add advanced view even though nothing has been added
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Emails.SearchAdvanced'   , 'Emails', 'vwEMAILS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchAdvanced'   ,  0, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, null,  50, 25, 'Emails'  , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchAdvanced'   ,  1, 'Emails.LBL_CONTACT_NAME'                , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Emails.SearchAdvanced'   ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Emails.SearchAdvanced'   ,  0, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, null,  50, 25, 'Emails'  , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Emails.SearchAdvanced'   ,  1, 'Emails.LBL_CONTACT_NAME'                , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Emails.SearchPopup'      , 'Emails', 'vwEMAILS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Emails.SearchPopup'      ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Emails.SearchPopup'      ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchPopup'      ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Emails.SearchPopup'      ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailTemplates.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailTemplates.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'EmailTemplates.SearchBasic', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'EmailTemplates.SearchBasic',  0, 'EmailTemplates.LBL_NAME'              , 'NAME'                       , 0, null,  50, 25, 'EmailTemplates', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'EmailTemplates.SearchBasic',  1, 'EmailTemplates.LBL_DESCRIPTION'       , 'DESCRIPTION'                , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'EmailTemplates.SearchBasic',  2, '.LBL_FAVORITES_FILTER'                , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'EmailTemplates.SearchBasic',  0, 'EmailTemplates.LBL_NAME'              , 'NAME'                       , 0, null,  50, 25, 'EmailTemplates', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailTemplates.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'EmailTemplates.SearchBasic',  2, '.LBL_FAVORITES_FILTER'                , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EmailTemplates.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EmailTemplates.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'EmailTemplates.SearchPopup', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'EmailTemplates.SearchPopup',  0, 'EmailTemplates.LBL_NAME'              , 'NAME'                       , 0, null,  50, 25, 'EmailTemplates', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'EmailTemplates.SearchPopup',  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'EmailTemplates.SearchPopup',  0, 'EmailTemplates.LBL_NAME'              , 'NAME'                       , 0, null,  50, 25, 'EmailTemplates', null;
end -- if;
GO

-- 05/26/2020 Paul.  Correct case of EMPLOYEE_STATUS list. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Employees.SearchAdvanced', 'Employees', 'vwEMPLOYEES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  0, 'Employees.LBL_FIRST_NAME'               , 'FIRST_NAME'                                              , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Employees.SearchAdvanced',  2, 'Employees.LBL_USER_NAME'                , 'USER_NAME'                                               , 0, null,  20, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  1, 'Employees.LBL_LAST_NAME'                , 'LAST_NAME'                                               , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Employees.SearchAdvanced',  4, 'Employees.LBL_EMPLOYEE_STATUS'          , 'EMPLOYEE_STATUS'                                         , 0, null, 'employee_status_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  3, 'Employees.LBL_TITLE'                    , 'TITLE'                                                   , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  5, 'Employees.LBL_ANY_PHONE'                , 'PHONE_WORK PHONE_MOBILE PHONE_OTHER PHONE_FAX PHONE_HOME', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  7, 'Employees.LBL_DEPARTMENT'               , 'DEPARTMENT'                                              , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  6, 'Employees.LBL_ANY_EMAIL'                , 'EMAIL1 EMAIL2'                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  8, 'Employees.LBL_ADDRESS'                  , 'ADDRESS_STREET'                                          , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced',  9, 'Employees.LBL_CITY'                     , 'ADDRESS_CITY'                                            , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced', 10, 'Employees.LBL_STATE'                    , 'ADDRESS_STATE'                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchAdvanced', 11, 'Employees.LBL_POSTAL_CODE'              , 'ADDRESS_POSTALCODE'                                      , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Employees.SearchAdvanced', 12, 'Employees.LBL_COUNTRY'                  , 'ADDRESS_COUNTRY'                                         , 0, null, 'countries_dom'   , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Employees.SearchAdvanced',  2, 'Employees.LBL_USER_NAME'                , 'USER_NAME'                                               , 0, null,  20, 25, 'Users', null;
	-- 05/26/2020 Paul.  Correct case of EMPLOYEE_STATUS list. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchAdvanced' and CACHE_NAME collate SQL_Latin1_General_CP1_CS_AS = 'Employee_status_dom' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set CACHE_NAME        = 'employee_status_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Employees.SearchAdvanced'
		   and CACHE_NAME collate SQL_Latin1_General_CP1_CS_AS = 'Employee_status_dom'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 05/26/2020 Paul.  Correct case of EMPLOYEE_STATUS list. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Employees.SearchBasic'   , 'Employees', 'vwEMPLOYEES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchBasic'   ,  0, 'Employees.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchBasic'   ,  1, 'Employees.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchBasic'   ,  2, 'Employees.LBL_DEPARTMENT'               , 'DEPARTMENT'                 , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Employees.SearchBasic'   ,  3, 'Employees.LBL_EMPLOYEE_STATUS'          , 'EMPLOYEE_STATUS'            , 1, null, 'employee_status_dom'   , null, null;
end else begin
	-- 01/17/2008 Paul.  ListBoxes that are not UI_REQUIRED default to querying for data that is NULL.  That is bad in his area. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchBasic' and DATA_FIELD = 'EMPLOYEE_STATUS' and UI_REQUIRED = 0 and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_REQUIRED    = 1
		     , UI_REQUIRED      = 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'Employees.SearchBasic'
		   and DATA_FIELD       = 'EMPLOYEE_STATUS'
		   and UI_REQUIRED      = 0
		   and DELETED          = 0;
	end -- if;
	-- 05/26/2020 Paul.  Correct case of EMPLOYEE_STATUS list. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchBasic' and CACHE_NAME collate SQL_Latin1_General_CP1_CS_AS = 'Employee_status_dom' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set CACHE_NAME        = 'employee_status_dom'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Employees.SearchBasic'
		   and CACHE_NAME collate SQL_Latin1_General_CP1_CS_AS = 'Employee_status_dom'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Employees.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Employees.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Employees.SearchPopup'   , 'Employees', 'vwEMPLOYEES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchPopup'   ,  0, 'Employees.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Employees.SearchPopup'   ,  1, 'Employees.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Employees.SearchPopup'   ,  2, 'Employees.LBL_USER_NAME'                , 'USER_NAME'                  , 0, null,  20, 25, 'Users', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Employees.SearchPopup'   ,  2, 'Employees.LBL_USER_NAME'                , 'USER_NAME'                  , 0, null,  20, 25, 'Users', null;
end -- if;
GO

-- 04/20/2008 Paul.  The Feeds layout should have been SearchBasic and not SearchPopup. 
if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Feeds.SearchPopup' and DELETED = 0) begin -- then
	delete from EDITVIEWS_FIELDS
	 where EDIT_NAME = 'Feeds.SearchPopup';
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Feeds.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Feeds.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Feeds.SearchBasic'       , 'Feeds', 'vwFEEDS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Feeds.SearchBasic'       ,  0, 'Feeds.LBL_TITLE'                        , 'TITLE'                      , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Feeds.SearchBasic'       ,  1, null;
end -- if;
GO

-- 12/13/2007 Paul.  Leads do not have an ASSISTANT_PHONE field. 
-- 01/28/2008 Paul.  ACCOUNT_NAME should be a text box since it is not linked to the accounts table. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchAdvanced'   and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchAdvanced'    , 'Leads', 'vwLeads_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                                                              , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  1, 'Leads.LBL_ANY_ADDRESS'                  , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  2, 'Leads.LBL_ANY_PHONE'                    , 'PHONE_HOME PHONE_MOBILE PHONE_WORK PHONE_OTHER PHONE_FAX'                , 0, 2,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  3, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                                                               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  4, 'Leads.LBL_CITY'                         , 'PRIMARY_ADDRESS_CITY ALT_ADDRESS_CITY'                                   , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  5, 'Leads.LBL_ANY_EMAIL'                    , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Leads.SearchAdvanced'    ,  6, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                                                            , 0, null,  25, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  7, 'Leads.LBL_STATE'                        , 'PRIMARY_ADDRESS_STATE ALT_ADDRESS_STATE'                                 , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchAdvanced'    ,  8, 'Leads.LBL_POSTAL_CODE'                  , 'PRIMARY_ADDRESS_POSTALCODE ALT_ADDRESS_POSTALCODE'                       , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Leads.SearchAdvanced'    ,  9, 'Leads.LBL_DO_NOT_CALL'                  , 'DO_NOT_CALL'                                                             , 0, null, 'CheckBox'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchAdvanced'    , 10, 'Leads.LBL_COUNTRY'                      , 'PRIMARY_ADDRESS_COUNTRY ALT_ADDRESS_COUNTRY'                             , 0, null, 'countries_dom'  , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchAdvanced'    , 11, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                                                             , 0, null, 'lead_source_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchAdvanced'    , 12, 'Leads.LBL_STATUS'                       , 'STATUS'                                                                  , 0, null, 'lead_status_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchAdvanced'    , 13, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'                                                        , 0, null, 'AssignedUser'   , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Leads.SearchAdvanced'    , 14, 0, null;
end else begin
	-- 01/28/2008 Paul. Fix account search.  It should be a text box. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchAdvanced' and DATA_FIELD = 'ACCOUNT_ID' and DELETED = 0) begin -- then
		print 'Fix account search in Leads.SearchAdvanced.';
		update EDITVIEWS_FIELDS
		   set FIELD_TYPE        = 'TextBox'
		     , DATA_FIELD        = 'ACCOUNT_NAME'
		     , DISPLAY_FIELD     = null
		     , ONCLICK_SCRIPT    = null
		     , FORMAT_SIZE       = 25
		     , FORMAT_MAX_LENGTH = 25
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Leads.SearchAdvanced'
		   and DATA_FIELD        = 'ACCOUNT_ID'
		   and DELETED           = 0;
	end -- if;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Leads.SearchAdvanced'    ,  6, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                                                            , 0, null,  25, 25, 'Accounts', null;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Leads.SearchAdvanced'    , 14, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchBasic'   and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchBasic'       , 'Leads', 'vwLeads_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchBasic'       ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchBasic'       ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Leads.SearchBasic'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchBasic'       ,  3, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Leads.SearchBasic'       ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Leads.SearchBasic'       ,  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchHome'        , 'Leads', 'vwLEADS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchHome'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchHome'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchPopup'   and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchPopup'       , 'Leads', 'vwLeads_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchPopup'       ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchPopup'       ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchPopup'       ,  3, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchPopup'       ,  4, 'Leads.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'lead_status_dom', null, 6;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Leads.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchDuplicates'   and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchDuplicates'  , 'Leads', 'vwLeads_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                                                              , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                                                               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Leads.SearchDuplicates'  ,  2, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                                                            , 0, null,  25, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Leads.SearchDuplicates'  ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  4, 'Leads.LBL_ANY_ADDRESS'                  , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  5, 'Leads.LBL_ANY_PHONE'                    , 'PHONE_HOME PHONE_MOBILE PHONE_WORK PHONE_OTHER PHONE_FAX'                , 0, 2,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  6, 'Leads.LBL_CITY'                         , 'PRIMARY_ADDRESS_CITY ALT_ADDRESS_CITY'                                   , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchDuplicates'  ,  7, 'Leads.LBL_ANY_EMAIL'                    , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Leads.SearchDuplicates'  ,  2, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                                                            , 0, null,  25, 25, 'Accounts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchAdvanced' , 'Meetings', 'vwMEETINGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchAdvanced' ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchAdvanced' ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Meetings.SearchAdvanced' ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Meetings.SearchAdvanced' ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Meetings.SearchAdvanced' ,  4, 'Meetings.LBL_STATUS'                    , 'STATUS'                     , 0, null, 'call_status_dom'     , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchAdvanced' ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchAdvanced' ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchBasic'    , 'Meetings', 'vwMEETINGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchBasic'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchBasic'    ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Meetings.SearchBasic'    ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Meetings.SearchBasic'    ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchBasic'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchBasic'    ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Meetings.SearchBasic'    ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchHome'     , 'Meetings', 'vwMEETINGS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Meetings.SearchHome'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Meetings.SearchHome'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchPopup'    , 'Meetings', 'vwMEETINGS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchPopup'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Meetings.SearchPopup'    ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchPopup'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Notes.SearchAdvanced'    , 'Notes', 'vwNOTES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Notes.SearchAdvanced'    ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Notes.SearchAdvanced'    ,  1, 'Notes.LBL_FILENAME'                     , 'FILENAME'                   , 0, null, 150, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Notes.SearchBasic'       , 'Notes', 'vwNOTES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Notes.SearchBasic'       ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Notes'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Notes.SearchBasic'       ,  1, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Notes.SearchBasic'       ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Notes.SearchBasic'       ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Notes'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Notes.SearchBasic'       ,  1, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Notes.SearchBasic'       ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 10/07/2010 Paul.  Increase size of NAME field. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchAdvanced', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchAdvanced',  0, 'Opportunities.LBL_OPPORTUNITY_NAME' , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Opportunities.SearchAdvanced',  1, 'Opportunities.LBL_AMOUNT'           , 'AMOUNT'                     , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.SearchAdvanced',  2, 'Opportunities.LBL_DATE_CLOSED'      , 'DATE_CLOSED'                , 0, null, 'DateRange'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Opportunities.SearchAdvanced',  3, 'Opportunities.LBL_PROBABILITY'      , 'PROBABILITY'                , 0, null,   3, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Opportunities.SearchAdvanced',  4, 'Opportunities.LBL_NEXT_STEP'        , 'NEXT_STEP'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchAdvanced',  5, 'Opportunities.LBL_LEAD_SOURCE'      , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom'     , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchAdvanced',  6, 'Opportunities.LBL_SALES_STAGE'      , 'SALES_STAGE'                , 0, null, 'sales_stage_dom'     , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchAdvanced',  7, 'Opportunities.LBL_TYPE'             , 'OPPORTUNITY_TYPE'           , 0, null, 'opportunity_type_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchAdvanced',  8, '.LBL_ASSIGNED_TO'                   , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Opportunities.SearchAdvanced',  9, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchAdvanced',  0, 'Opportunities.LBL_OPPORTUNITY_NAME' , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Opportunities.SearchAdvanced',  9, 0, null;
	end -- if;
end -- if;
GO

-- 10/07/2010 Paul.  Increase size of NAME field. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchBasic', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchBasic',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchBasic',  1, 'Opportunities.LBL_TYPE'                , 'OPPORTUNITY_TYPE'           , 0, null, 'opportunity_type_dom', null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.SearchBasic',  2, '.LBL_CURRENT_USER_FILTER'              , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.SearchBasic',  3, '.LBL_FAVORITES_FILTER'                 , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchBasic',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.SearchBasic',  3, '.LBL_FAVORITES_FILTER'                 , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchHome', 'Opportunities', 'vwOPPORTUNITIES_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchHome',  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchHome',  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

-- 10/07/2010 Paul.  Increase size of NAME field. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchPopup', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchPopup',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchPopup',  1, 'Opportunities.LBL_ACCOUNT_NAME'        , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts'     , null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchPopup',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchPopup',  1, 'Opportunities.LBL_ACCOUNT_NAME'        , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts'     , null;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- 10/07/2010 Paul.  Increase size of NAME field. 
-- delete from EDITVIEWS where NAME = 'Opportunities.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchDuplicates' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchDuplicates', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchDuplicates',  0, 'Opportunities.LBL_OPPORTUNITY_NAME' , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Opportunities.SearchDuplicates',  1, 'Opportunities.LBL_NEXT_STEP'        , 'NEXT_STEP'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Opportunities.SearchDuplicates',  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchDuplicates',  3, 'Opportunities.LBL_LEAD_SOURCE'      , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom'     , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchDuplicates',  4, 'Opportunities.LBL_SALES_STAGE'      , 'SALES_STAGE'                , 0, null, 'sales_stage_dom'     , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchDuplicates',  5, 'Opportunities.LBL_TYPE'             , 'OPPORTUNITY_TYPE'           , 0, null, 'opportunity_type_dom', null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchDuplicates',  0, 'Opportunities.LBL_OPPORTUNITY_NAME' , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Project.SearchAdvanced'  , 'Project', 'vwPROJECTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Project.SearchAdvanced'  ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchAdvanced'  ,  1, 'Project.LBL_ESTIMATED_START_DATE'       , 'START_DATE'                 , 0, null, 'DateRange'                , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchAdvanced'  ,  2, 'Project.LBL_ESTIMATED_END_DATE'         , 'END_DATE'                   , 0, null, 'DateRange'                , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Project.SearchAdvanced'  ,  3, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, null, 'project_status_dom'       , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Project.SearchAdvanced'  ,  4, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, null, 'projects_priority_options', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Project.SearchAdvanced'  ,  5, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Project.SearchAdvanced'  ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	-- 05/15/2016 Paul.  Field name is not ESTIMATED_START_DATE. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchAdvanced' and DATA_FIELD = 'START_DATE' and DELETED = 0) begin -- then
		print 'EDITVIEWS_FIELDS Project.SearchAdvanced: Add start date and end date';
		update EDITVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 4
		 where EDIT_NAME  = 'Project.NewRecord'
		   and FIELD_INDEX >= 1
		   and DELETED      = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchAdvanced'  ,  1, 'Project.LBL_ESTIMATED_START_DATE'       , 'START_DATE'                 , 0, null, 'DateRange'                , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchAdvanced'  ,  2, 'Project.LBL_ESTIMATED_END_DATE'         , 'END_DATE'                   , 0, null, 'DateRange'                , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Project.SearchAdvanced'  ,  3, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, null, 'project_status_dom'       , null, 6;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Project.SearchAdvanced'  ,  4, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, null, 'projects_priority_options', null, 6;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_CnvTagSelect    'Project.SearchAdvanced'  ,  5, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Project.SearchBasic'     , 'Project', 'vwPROJECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Project.SearchBasic'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchBasic'     ,  1, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchBasic'     ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Project.SearchBasic'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchBasic'     ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Project.SearchPopup'     , 'Project', 'vwPROJECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Project.SearchPopup'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Project.SearchPopup'     ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Project.SearchPopup'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'ProjectTask.SearchAdvanced', 'ProjectTask', 'vwPROJECT_TASKS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProjectTask.SearchAdvanced',  0, 'ProjectTask.LBL_NAME'                 , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'ProjectTask.SearchAdvanced',  1, 'ProjectTask.LBL_PROJECT_NAME'         , 'PROJECT_ID'                 , 0, null, 'PROJECT_NAME'     , 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ProjectTask.SearchAdvanced',  2, '.LBL_ASSIGNED_TO'                     , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser' , null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'ProjectTask.SearchAdvanced',  0, 'ProjectTask.LBL_NAME'                 , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup  'ProjectTask.SearchAdvanced',  1, 'ProjectTask.LBL_PROJECT_NAME'         , 'PROJECT_ID'                 , 0, null, 'PROJECT_NAME'     , 'Project', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ProjectTask.SearchBasic' , 'ProjectTask', 'vwPROJECT_TASKS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProjectTask.SearchBasic' ,  0, 'ProjectTask.LBL_NAME'                   , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProjectTask.SearchBasic' ,  1, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProjectTask.SearchBasic' ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'ProjectTask.SearchBasic' ,  0, 'ProjectTask.LBL_NAME'                   , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProjectTask.SearchBasic' ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'ProjectTask.SearchHome'  , 'ProjectTask', 'vwPROJECT_TASKS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ProjectTask.SearchHome'  ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ProjectTask.SearchHome'  ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'ProjectTask.SearchPopup' , 'ProjectTask', 'vwPROJECT_TASKS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProjectTask.SearchPopup' ,  0, 'ProjectTask.LBL_NAME'                   , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'ProjectTask.SearchPopup' ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'ProjectTask.SearchPopup' ,  0, 'ProjectTask.LBL_NAME'                   , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
end -- if;
GO

-- 01/20/2008 Paul.  ListBoxes do not always work well when searching as the default is NULL, which typically displays nothing. 
-- 09/14/2008 Paul.  The default code for LIST_TYPE had 6 in the colspan field. 
-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ProspectLists.SearchBasic', 'ProspectLists', 'vwPROSPECT_LISTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProspectLists.SearchBasic',  0, 'ProspectLists.LBL_NAME'                , 'NAME'                       , 0, null, 100, 25, 'ProspectLists', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ProspectLists.SearchBasic',  1, 'ProspectLists.LBL_LIST_TYPE'           , 'LIST_TYPE'                  , 0, null, 'prospect_list_type_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProspectLists.SearchBasic',  2, '.LBL_CURRENT_USER_FILTER'              , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProspectLists.SearchBasic',  3, '.LBL_FAVORITES_FILTER'                 , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'ProspectLists.SearchBasic',  4, 0, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'ProspectLists.SearchBasic',  0, 'ProspectLists.LBL_NAME'                , 'NAME'                       , 0, null, 100, 25, 'ProspectLists', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'ProspectLists.SearchBasic',  3, '.LBL_FAVORITES_FILTER'                 , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchBasic' and DATA_FIELD = 'LIST_TYPE' and FORMAT_ROWS is null and DELETED = 0) begin -- then
		print 'ProspectLists search should have a listbox instead of a dropdown list. ';
		update EDITVIEWS_FIELDS
		   set FORMAT_ROWS      = 6
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'ProspectLists.SearchBasic'
		   and DATA_FIELD       = 'LIST_TYPE' 
		   and FORMAT_ROWS is null
		   and DELETED          = 0;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchBasic' and DATA_FIELD = 'LIST_TYPE' and COLSPAN = 6 and DELETED = 0) begin -- then
		print 'ProspectLists search had a bug in the LIST_TYPE data. ';
		update EDITVIEWS_FIELDS
		   set COLSPAN          = null
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'ProspectLists.SearchBasic'
		   and DATA_FIELD       = 'LIST_TYPE' 
		   and COLSPAN          = 6
		   and DELETED          = 0;
	end -- if;
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchBasic' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'ProspectLists.SearchBasic',  4, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'ProspectLists.SearchPopup', 'ProspectLists', 'vwPROSPECT_LISTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProspectLists.SearchPopup',  0, 'ProspectLists.LBL_NAME'                , 'NAME'                       , 0, null, 100, 25, 'ProspectLists', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'ProspectLists.SearchPopup',  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'ProspectLists.SearchPopup',  0, 'ProspectLists.LBL_NAME'                , 'NAME'                       , 0, null, 100, 25, 'ProspectLists', null;
end -- if;
GO

-- 05/15/2016 Paul.  Add tags to advanced search. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchAdvanced'  and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchAdvanced', 'Prospects', 'vwPROSPECTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                                                              , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                                                               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  2, 'Prospects.LBL_ANY_PHONE'                , 'PHONE_HOME PHONE_MOBILE PHONE_WORK PHONE_OTHER PHONE_FAX ASSISTANT_PHONE', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  3, 'Prospects.LBL_ANY_EMAIL'                , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  4, 'Prospects.LBL_ASSISTANT'                , 'ASSISTANT'                                                               , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Prospects.SearchAdvanced',  5, 'Prospects.LBL_DO_NOT_CALL'              , 'DO_NOT_CALL'                                                             , 0, null, 'CheckBox'    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  6, 'Prospects.LBL_ANY_ADDRESS'              , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  7, 'Prospects.LBL_STATE'                    , 'PRIMARY_ADDRESS_STATE ALT_ADDRESS_STATE'                                 , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchAdvanced',  8, 'Prospects.LBL_POSTAL_CODE'              , 'PRIMARY_ADDRESS_POSTALCODE ALT_ADDRESS_POSTALCODE'                       , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Prospects.SearchAdvanced',  9, 'Prospects.LBL_COUNTRY'                  , 'PRIMARY_ADDRESS_COUNTRY ALT_ADDRESS_COUNTRY'                             , 0, null, 'countries_dom', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Prospects.SearchAdvanced', 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'                                                        , 0, null, 'AssignedUser' , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Prospects.SearchAdvanced', 11, 0, null;
end else begin
	-- 05/15/2016 Paul.  Add tags to advanced search. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchAdvanced' and DATA_FIELD = 'TAG_SET_NAME') begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    'Prospects.SearchAdvanced', 11, 0, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchBasic'   , 'Prospects', 'vwPROSPECTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchBasic'   ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchBasic'   ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Prospects.SearchBasic'   ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Prospects.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Prospects.SearchBasic'   ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchPopup'   , 'Prospects', 'vwPROSPECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchPopup'   ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchPopup'   ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  25, 25, null;
end -- if;
GO

-- 12/28/2008 Paul.  Add duplicate searching. 
-- delete from EDITVIEWS where NAME = 'Prospects.SearchDuplicates';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchDuplicates';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchDuplicates'  and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchDuplicates';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchDuplicates', 'Prospects', 'vwPROSPECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                                                              , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                                                               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  2, 'Prospects.LBL_ANY_ADDRESS'              , 'PRIMARY_ADDRESS_STREET ALT_ADDRESS_STREET'                               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  3, 'Prospects.LBL_ANY_PHONE'                , 'PHONE_HOME PHONE_MOBILE PHONE_WORK PHONE_OTHER PHONE_FAX ASSISTANT_PHONE', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  4, 'Prospects.LBL_CITY'                     , 'PRIMARY_ADDRESS_CITY ALT_ADDRESS_CITY'                                   , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchDuplicates',  5, 'Prospects.LBL_ANY_EMAIL'                , 'EMAIL1 EMAIL2'                                                           , 0, null, 100, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Tasks.SearchAdvanced'    , 'Tasks', 'vwTASKS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchAdvanced'    ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchAdvanced'    ,  1, 'Tasks.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Tasks.SearchAdvanced'    ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Tasks.SearchAdvanced'    ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Tasks.SearchAdvanced'    ,  4, 'Tasks.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'task_status_dom'     , null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Tasks.SearchAdvanced'    ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Tasks.SearchAdvanced'    ,  1, 'Tasks.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Tasks.SearchBasic'       , 'Tasks', 'vwTASKS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchBasic'       ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchBasic'       ,  1, 'Tasks.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Tasks.SearchBasic'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Tasks.SearchBasic'       ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Tasks.SearchBasic'       ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Tasks.SearchBasic'       ,  1, 'Tasks.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null,  50, 25, 'Contacts', null;
	-- 12/29/2016 Paul.  Need to prevent duplicate fields.  
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchBasic' and DATA_FIELD = 'FAVORITE_RECORD_ID' and DELETED = 0) begin -- then
		exec dbo.spEDITVIEWS_FIELDS_InsControl      'Tasks.SearchBasic'       ,  3, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Tasks.SearchHome'        , 'Tasks', 'vwTASKS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Tasks.SearchHome'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Tasks.SearchHome'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Tasks.SearchPopup'       , 'Tasks', 'vwTASKS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchPopup'       ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Tasks.SearchPopup'       ,  1, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchPopup'       ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Users.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'Users.SearchAdvanced'    , 'Users', 'vwUSERS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  0, 'Users.LBL_FIRST_NAME'                   , 'FIRST_NAME'                                              , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Users.SearchAdvanced'    ,  1, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                                               , 0, null,  20, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  2, 'Users.LBL_LAST_NAME'                    , 'LAST_NAME'                                               , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Users.SearchAdvanced'    ,  3, 'Users.LBL_STATUS'                       , 'STATUS'                                                  , 0, null, 'user_status_dom'   , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Users.SearchAdvanced'    ,  4, 'Users.LBL_ADMIN'                        , 'IS_ADMIN'                                                , 0, null, 'CheckBox', null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  5, 'Users.LBL_TITLE'                        , 'TITLE'                                                   , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Users.SearchAdvanced'    ,  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  7, 'Users.LBL_DEPARTMENT'                   , 'DEPARTMENT'                                              , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  8, 'Users.LBL_ANY_PHONE'                    , 'PHONE_HOME PHONE_MOBILE PHONE_WORK PHONE_OTHER PHONE_FAX', 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    ,  9, 'Users.LBL_ADDRESS'                      , 'ADDRESS_STREET'                                          , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    , 10, 'Users.LBL_ANY_EMAIL'                    , 'EMAIL1 EMAIL2'                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    , 11, 'Users.LBL_STATE'                        , 'ADDRESS_STATE'                                           , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    , 12, 'Users.LBL_CITY'                         , 'ADDRESS_CITY'                                            , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchAdvanced'    , 13, 'Users.LBL_POSTAL_CODE'                  , 'ADDRESS_POSTALCODE'                                      , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Users.SearchAdvanced'    , 14, 'Users.LBL_COUNTRY'                      , 'ADDRESS_COUNTRY'                                         , 0, null, 'countries_dom', null, 6;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Users.SearchAdvanced'    ,  1, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                                               , 0, null,  20, 25, 'Users', null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Users.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Users.SearchBasic'       , 'Users', 'vwUSERS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchBasic'       ,  0, 'Users.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchBasic'       ,  1, 'Users.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchBasic'       ,  2, 'Users.LBL_DEPARTMENT'                   , 'DEPARTMENT'                 , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Users.SearchBasic'       ,  3, 'Users.LBL_STATUS'                       , 'STATUS'                     , 1, null, 'user_status_dom'   , null, null;
end else begin
	-- 01/17/2008 Paul.  ListBoxes that are not UI_REQUIRED default to querying for data that is NULL.  That is bad in his area. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.SearchBasic' and DATA_FIELD = 'STATUS' and UI_REQUIRED = 0 and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_REQUIRED    = 1
		     , UI_REQUIRED      = 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'Users.SearchBasic'
		   and DATA_FIELD       = 'STATUS'
		   and UI_REQUIRED      = 0
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 03/22/2010 Paul.  Allow searching one Email1. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Users.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Users.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'Users.SearchPopup'       , 'Users', 'vwUSERS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchPopup'       ,  0, 'Users.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchPopup'       ,  1, 'Users.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Users.SearchPopup'       ,  2, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  20, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchPopup'       ,  3, 'Users.LBL_EMAIL1'                       , 'EMAIL1'                     , 0, null, 255, 25, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Users.SearchPopup'       ,  2, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  20, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Users.SearchPopup'       ,  3, 'Users.LBL_EMAIL1'                       , 'EMAIL1'                     , 0, null, 255, 25, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Shortcuts.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Shortcuts.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Shortcuts.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Shortcuts.SearchBasic'   , 'Shortcuts', 'vwSHORTCUTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Shortcuts.SearchBasic'   ,  0, 'Shortcuts.LBL_MODULE_NAME'              , 'MODULE_NAME'                , 1, null, 'Modules'           , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Shortcuts.SearchBasic'   ,  1, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'UserLogins.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'UserLogins.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS UserLogins.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'UserLogins.SearchBasic'  , 'Users', 'vwUSERS_LOGINS', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'UserLogins.SearchBasic'  ,  0, 'Users.LBL_NAME'                         , 'FULL_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'UserLogins.SearchBasic'  ,  1, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  30, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'UserLogins.SearchBasic'  ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'UserLogins.SearchBasic'  ,  3, 'Users.LBL_REMOTE_HOST'                  , 'REMOTE_HOST'                , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'UserLogins.SearchBasic'  ,  4, 'Users.LBL_TARGET'                       , 'TARGET'                     , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'UserLogins.SearchBasic'  ,  5, 'Users.LBL_ASPNET_SESSIONID'             , 'ASPNET_SESSIONID'           , 0, null,  75, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'UserLogins.SearchBasic'  ,  6, 'Users.LBL_LOGIN_DATE'                   , 'LOGIN_DATE'                 , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'UserLogins.SearchBasic'  ,  7, 'Users.LBL_LOGOUT_DATE'                  , 'LOGOUT_DATE'                , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'UserLogins.SearchBasic'  ,  8, 'Users.LBL_LOGIN_STATUS'                 , 'LOGIN_STATUS'               , 0, null, 'login_status_dom'   , null, 3;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'UserLogins.SearchBasic'  ,  1, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  30, 25, 'Users', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SystemLog.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SystemLog.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SystemLog.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'SystemLog.SearchBasic'   , 'SystemLog', 'vwSYSTEM_LOG', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'SystemLog.SearchBasic'   ,  0, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED'               , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'SystemLog.SearchBasic'   ,  1, 'SystemLog.LBL_ERROR_TYPE'               , 'ERROR_TYPE'                 , 0, null, 'system_log_type_dom', null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  2, 'SystemLog.LBL_SERVER_HOST'              , 'SERVER_HOST'                , 0, null,  60, 25, null;

	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  3, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  60, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  4, 'SystemLog.LBL_RELATIVE_PATH'            , 'LBL_RELATIVE_PATH'          , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  5, 'SystemLog.LBL_REMOTE_HOST'              , 'REMOTE_HOST'                , 0, null,  60, 25, null;

	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  6, 'SystemLog.LBL_MESSAGE'                  , 'MESSAGE'                    , 0, null, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  7, 'SystemLog.LBL_FILE_NAME'                , 'FILE_NAME'                  , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemLog.SearchBasic'   ,  8, 'SystemLog.LBL_METHOD'                   , 'METHOD'                     , 0, null, 100, 25, null;
end -- if;
GO

-- 11/22/2009 Paul.  Search fields need to be added to the main server. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SystemSyncLog.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SystemSyncLog.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SystemSyncLog.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'SystemSyncLog.SearchBasic'   , 'SystemSyncLog', 'vwSYSTEM_SYNC_LOG', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'SystemSyncLog.SearchBasic'   ,  0, '.LBL_DATE_ENTERED'                      , 'DATE_ENTERED'               , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'SystemSyncLog.SearchBasic'   ,  1, 'SystemLog.LBL_ERROR_TYPE'               , 'ERROR_TYPE'                 , 0, null, 'system_log_type_dom', null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'SystemSyncLog.SearchBasic'   ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemSyncLog.SearchBasic'   ,  3, 'SystemLog.LBL_MESSAGE'                  , 'MESSAGE'                    , 0, null, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemSyncLog.SearchBasic'   ,  4, 'SystemLog.LBL_FILE_NAME'                , 'FILE_NAME'                  , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SystemSyncLog.SearchBasic'   ,  5, 'SystemLog.LBL_METHOD'                   , 'METHOD'                     , 0, null, 100, 25, null;
end -- if;
GO

-- 08/05/2010 Paul.  Add search for Releases. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Releases.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Releases.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Releases.SearchBasic'    , 'Releases', 'vwRELEASES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Releases.SearchBasic'    ,  0, 'Releases.LBL_NAME'                      , 'NAME'                       , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Releases.SearchBasic'    ,  1, null;
end -- if;
GO


-- 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
-- The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Emails.SearchHome'       , 'Emails', 'vwEMAILS_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Emails.SearchHome'       ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, -4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Emails.SearchHome'       ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, -4;
end -- if;
GO

-- 03/05/2011 Paul.  Add search for Config. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Config.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Config.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Config.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Config.SearchBasic'      , 'Config', 'vwCONFIG_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Config.SearchBasic'      ,  0, 'Config.LBL_NAME'                        , 'NAME'                       , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Config.SearchBasic'      ,  1, 'Config.LBL_VALUE'                       , 'VALUE'                      , 0, null, 200, 35, null;
end -- if;
GO

-- 04/11/2011 Paul.  Add support for Dynamic Layout popups. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.DetailView.PopupView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.DetailView.PopupView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS DynamicLayout.DetailView.PopupView';
	exec dbo.spEDITVIEWS_InsertOnly             'DynamicLayout.DetailView.PopupView', 'DynamicLayout', 'vwDETAILVIEWS_FIELDS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.DetailView.PopupView',  0, 'DynamicLayout.LBL_DETAIL_NAME'     , 'DETAIL_NAME'             , 0, null,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.DetailView.PopupView',  1, 'DynamicLayout.LBL_LIST_DATA_FIELD' , 'DATA_FIELD'              , 0, null,  50, 35, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.EditView.PopupView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.EditView.PopupView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS DynamicLayout.EditView.PopupView';
	exec dbo.spEDITVIEWS_InsertOnly             'DynamicLayout.EditView.PopupView', 'DynamicLayout', 'vwEDITVIEWS_FIELDS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.EditView.PopupView',  0, 'DynamicLayout.LBL_EDIT_NAME'       , 'EDIT_NAME'               , 0, null,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.EditView.PopupView',  1, 'DynamicLayout.LBL_LIST_DATA_FIELD' , 'DATA_FIELD'              , 0, null,  50, 35, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.GridView.PopupView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'DynamicLayout.GridView.PopupView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS DynamicLayout.GridView.PopupView';
	exec dbo.spEDITVIEWS_InsertOnly             'DynamicLayout.GridView.PopupView', 'DynamicLayout', 'vwGRIDVIEWS_COLUMNS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.GridView.PopupView',  0, 'DynamicLayout.LBL_GRID_NAME'       , 'GRID_NAME'               , 0, null,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'DynamicLayout.GridView.PopupView',  1, 'DynamicLayout.LBL_LIST_DATA_FIELD' , 'DATA_FIELD'              , 0, null,  50, 35, null;
end -- if;
GO

-- 06/22/2013 Paul.  Add search for Modules. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Modules.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Modules.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Modules.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Modules.SearchBasic'     , 'Modules', 'vwMODULES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Modules.SearchBasic'     ,  0, 'Modules.LBL_MODULE_NAME'                , 'MODULE_NAME'                , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Modules.SearchBasic'     ,  1, 'Modules.LBL_TABLE_NAME'                 , 'TABLE_NAME'                 , 0, null,  50, 35, null;
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
-- 01/06/2018 Paul.  The module type was missing from auto complete. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SmsMessages.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'SmsMessages.SearchBasic', 'SmsMessages', 'vwSMS_MESSAGES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'SmsMessages.SearchBasic'   ,  0, 'SmsMessages.LBL_NAME'                   , 'NAME'                       , 0, null, 140, 25, 'SmsMessages', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchBasic'   ,  1, 'SmsMessages.LBL_FROM_NUMBER'            , 'FROM_NUMBER'                , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchBasic'   ,  2, 'SmsMessages.LBL_TO_NUMBER'              , 'TO_NUMBER'                  , 0, null,  50, 25, null;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchBasic' and DATA_FIELD = 'NAME' and FIELD_TYPE = 'ModuleAutoComplete' and MODULE_TYPE is null and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set MODULE_TYPE      = 'SmsMessages'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'SmsMessages.SearchBasic'
		   and DATA_FIELD       = 'NAME'
		   and FIELD_TYPE       = 'ModuleAutoComplete'
		   and MODULE_TYPE      is null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 01/06/2018 Paul.  The module type was missing from auto complete. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SmsMessages.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'SmsMessages.SearchAdvanced', 'SmsMessages', 'vwSMS_MESSAGES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'SmsMessages.SearchAdvanced',  0, 'SmsMessages.LBL_NAME'                   , 'NAME'                       , 0, null, 140, 25, 'SmsMessages', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchAdvanced',  1, 'SmsMessages.LBL_FROM_NUMBER'            , 'FROM_NUMBER'                , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchAdvanced',  2, 'SmsMessages.LBL_TO_NUMBER'              , 'TO_NUMBER'                  , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'SmsMessages.SearchAdvanced',  3, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox' , 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'SmsMessages.SearchAdvanced',  4, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox' , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'SmsMessages.SearchAdvanced',  5, 'SmsMessages.LBL_DATE_START'             , 'DATE_START'                 , 0, null, 'DateRange', null, null, null;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchAdvanced' and DATA_FIELD = 'NAME' and FIELD_TYPE = 'ModuleAutoComplete' and MODULE_TYPE is null and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set MODULE_TYPE      = 'SmsMessages'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'SmsMessages.SearchAdvanced'
		   and DATA_FIELD       = 'NAME'
		   and FIELD_TYPE       = 'ModuleAutoComplete'
		   and MODULE_TYPE      is null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 01/06/2018 Paul.  The module type was missing from auto complete. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchPopup';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SmsMessages.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'SmsMessages.SearchPopup'   , 'Emails', 'vwEMAILS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchPopup'   ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'SmsMessages.SearchPopup'   ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'SmsMessages.SearchPopup'   ,  2, 'Contacts.LBL_SMS_OPT_IN'                , 'SMS_OPT_IN'                 , 1, null, 'dom_sms_opt_in_search', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'SmsMessages.SearchPopup'   ,  3, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 01/06/2018 Paul.  The module type was missing from auto complete. 
-- 10/22/2013 Paul.  Add TwitterMessages module. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS TwitterMessages.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'TwitterMessages.SearchBasic', 'TwitterMessages', 'vwTWITTER_MESSAGES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'TwitterMessages.SearchBasic'   ,  0, 'TwitterMessages.LBL_NAME'                   , 'NAME'                       , 0, null, 140, 25, 'TwitterMessages', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'TwitterMessages.SearchBasic'   ,  1, 'TwitterMessages.LBL_TWITTER_SCREEN_NAME'    , 'TWITTER_SCREEN_NAME'        , 0, null,  20, 25, null;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchBasic' and DATA_FIELD = 'NAME' and FIELD_TYPE = 'ModuleAutoComplete' and MODULE_TYPE is null and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set MODULE_TYPE      = 'TwitterMessages'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'TwitterMessages.SearchBasic'
		   and DATA_FIELD       = 'NAME'
		   and FIELD_TYPE       = 'ModuleAutoComplete'
		   and MODULE_TYPE      is null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 01/06/2018 Paul.  The module type was missing from auto complete. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS TwitterMessages.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly             'TwitterMessages.SearchAdvanced', 'TwitterMessages', 'vwTWITTER_MESSAGES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'TwitterMessages.SearchAdvanced',  0, 'TwitterMessages.LBL_NAME'                   , 'NAME'                       , 0, null, 140, 25, 'TwitterMessages', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'TwitterMessages.SearchAdvanced',  1, 'TwitterMessages.LBL_TWITTER_SCREEN_NAME'    , 'TWITTER_SCREEN_NAME'        , 0, null,  20, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'TwitterMessages.SearchAdvanced',  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'TwitterMessages.SearchAdvanced',  3, '.LBL_CURRENT_USER_FILTER'                   , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox' , 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'TwitterMessages.SearchAdvanced',  4, '.LBL_FAVORITES_FILTER'                      , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox' , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'TwitterMessages.SearchAdvanced',  5, 'TwitterMessages.LBL_DATE_START'             , 'DATE_START'                 , 0, null, 'DateRange', null, null, null;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.SearchAdvanced' and DATA_FIELD = 'NAME' and FIELD_TYPE = 'ModuleAutoComplete' and MODULE_TYPE is null and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set MODULE_TYPE      = 'TwitterMessages'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where EDIT_NAME        = 'TwitterMessages.SearchAdvanced'
		   and DATA_FIELD       = 'NAME'
		   and FIELD_TYPE       = 'ModuleAutoComplete'
		   and MODULE_TYPE      is null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ChatChannels.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ChatChannels.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ChatChannels.SearchBasic'      , 'ChatChannels', 'vwCHAT_CHANNELS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ChatChannels.SearchBasic'      ,  0, 'ChatChannels.LBL_NAME'                      , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ChatChannels.SearchBasic'      ,  1, '.LBL_ASSIGNED_TO'                           , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 6;
end -- if;
GO

-- 02/13/2016 Paul.  Fix module name. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ChatChannels.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ChatChannels.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'ChatChannels.SearchPopup'      , 'ChatChannels', 'vwCHAT_CHANNELS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ChatChannels.SearchPopup'      ,  0, 'ChatChannels.LBL_NAME'                      , 'NAME'                       , 0, null, 150, 25, 'ChatChannels', null;
end -- if;

if exists(select * from EDITVIEWS where NAME = 'ChatChannels.SearchPopup' and MODULE_NAME = 'Accounts') begin -- then
	update EDITVIEWS
	   set MODULE_NAME       = 'ChatChannels'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'ChatChannels.SearchPopup'
	   and MODULE_NAME       = 'Accounts';
end -- if;
GO

-- 03/15/2016 Paul.  Make better use of the activities list by showing all. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchAdvanced';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchAdvanced' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchAdvanced';
	exec dbo.spEDITVIEWS_InsertOnly            'Activities.SearchAdvanced'    , 'Activities', 'vwACTIVITIES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Activities.SearchAdvanced'    ,  0, 'Activities.LBL_SUBJECT'                 , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Activities.SearchAdvanced'    ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Activities.SearchAdvanced'    ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchAdvanced'    ,  3, 'Activities.LBL_ACTIVITY_TYPE'           , 'ACTIVITY_TYPE'              , 0, null, 'activities_dom'      , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchAdvanced'    ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchAdvanced'    ,  5, 'Activities.LBL_STATUS'                  , 'STATUS'                     , 0, null, 'activity_status_dom' , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly            'Activities.SearchBasic'       , 'Activities', 'vwACTIVITIES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Activities.SearchBasic'       ,  0, 'Activities.LBL_SUBJECT'                 , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Activities.SearchBasic'       ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Activities.SearchBasic'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.PopupView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly            'Activities.SearchPopup'       , 'Activities', 'vwACTIVITIES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Activities.SearchPopup'       ,  0, 'Activities.LBL_SUBJECT'                 , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Activities.SearchPopup'       ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Activities.SearchPopup'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchPopup'       ,  3, 'Activities.LBL_ACTIVITY_TYPE'           , 'ACTIVITY_TYPE'              , 0, null, 'activities_dom'      , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchPopup'       ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Activities.SearchPopup'       ,  5, 'Activities.LBL_STATUS'                  , 'STATUS'                     , 0, null, 'activity_status_dom' , null, 6;
end -- if;
GO

-- 04/13/2016 Paul.  Add ZipCodes. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ZipCodes.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ZipCodes.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ZipCodes.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ZipCodes.SearchBasic', 'ZipCodes', 'vwZIPCODES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchBasic'        ,  0, 'ZipCodes.LBL_NAME'                      , 'NAME'                       , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchBasic'        ,  1, 'ZipCodes.LBL_CITY'                      , 'CITY'                       , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchBasic'        ,  2, 'ZipCodes.LBL_STATE'                     , 'STATE'                      , 0, null, 255, 25, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ZipCodes.SearchPopup';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ZipCodes.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ZipCodes.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'ZipCodes.SearchPopup', 'ZipCodes', 'vwZIPCODES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchPopup'        ,  0, 'ZipCodes.LBL_NAME'                      , 'NAME'                       , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchPopup'        ,  1, 'ZipCodes.LBL_CITY'                      , 'CITY'                       , 0, null, 255, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ZipCodes.SearchPopup'        ,  2, 'ZipCodes.LBL_STATE'                     , 'STATE'                      , 0, null, 255, 25, null;
end -- if;
GO

-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
-- delete from EDITVIEWS where NAME = 'Currencies.SearchBasic';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Currencies.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Currencies.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Currencies.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'Currencies.SearchBasic'      , 'Currencies', 'vwCURRENCIES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Currencies.SearchBasic'      ,  0, 'Currencies.LBL_NAME'                    , 'NAME'                       , 0, null,  36, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Currencies.SearchBasic'      ,  1, 'Currencies.LBL_ISO4217'                 , 'ISO4217'                    , 0, null,  36, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Currencies.SearchBasic'      ,  2, 'Currencies.LBL_STATUS'                  , 'STATUS'                     , 0, null, 'currency_status_dom' , null, 2;
end -- if;
GO

-- 03/30/2021 Paul.  Roles needed for React client. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ACLRoles.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ACLRoles.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ACLRoles.SearchBasic'        , 'ACLRoles', 'vwACL_ROLES', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ACLRoles.SearchBasic'        ,  0, 'ACLRoles.LBL_NAME'                     , 'NAME'                        , 0, null, 100, 25, null;
end -- if;
GO

-- 06/02/2021 Paul.  Roles needed for React client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ACLRoles.SearchByUser';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ACLRoles.SearchByUser' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ACLRoles.SearchByUser';
	exec dbo.spEDITVIEWS_InsertOnly             'ACLRoles.SearchByUser'       , 'ACLRoles', 'vwACL_ROLES', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ACLRoles.SearchByUser'       ,  0, '.LBL_ASSIGNED_TO'                      , 'ID'                         , 0, null, 'AssignedUser' , null, null;
end -- if;
GO

-- 08/01/2016 Paul.  Roles needed for BPMN. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ACLRoles.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ACLRoles.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'ACLRoles.SearchPopup'        , 'ACLRoles', 'vwACL_ROLES', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ACLRoles.SearchPopup'        ,  0, 'ACLRoles.LBL_NAME'                     , 'NAME'                        , 0, null, 100, 25, null;
end -- if;
GO

-- 06/07/2017 Paul.  Add support for NAICS Codes. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'NAICSCodes.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS NAICSCodes.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'NAICSCodes.SearchBasic'      , 'NAICSCodes', 'vwNAICS_CODES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'NAICSCodes.SearchBasic'      ,  0, 'NAICSCodes.LBL_NAME'                     , 'NAME'                      , 0, null,  10, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'NAICSCodes.SearchBasic'      ,  1, 'NAICSCodes.LBL_DESCRIPTION'              , 'DESCRIPTION'               , 0, null, 400, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'NAICSCodes.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS NAICSCodes.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'NAICSCodes.SearchPopup'      , 'NAICSCodes', 'vwNAICS_CODES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'NAICSCodes.SearchPopup'      ,  0, 'NAICSCodes.LBL_NAME'                     , 'NAME'                      , 0, null,  10, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'NAICSCodes.SearchPopup'      ,  1, 'NAICSCodes.LBL_DESCRIPTION'              , 'DESCRIPTION'               , 0, null, 400, 25, null;
end -- if;
GO

-- 07/31/2017 Paul.  Add Activities.SearchHome
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchHome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchHome';
	exec dbo.spEDITVIEWS_InsertOnly             'Activities.SearchHome'   , 'Activities', 'vwACTIVITIES_MyList', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Activities.SearchHome'   ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Activities.SearchHome'   ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'Teams'               , null, 4;
end -- if;
GO

-- 01/20/2010 Paul.  Add ability to search the new Audit Events table. 
-- 03/28/2019 Paul.  Move AuditEvents.SearchBasic to default file for Community edition. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'AuditEvents.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'AuditEvents.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS AuditEvents.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'AuditEvents.SearchBasic'   , 'AuditEvents', 'vwAUDIT_EVENTS', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'AuditEvents.SearchBasic'   ,  0, 'Users.LBL_NAME'                         , 'FULL_NAME'                  , 0, null,  30, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'AuditEvents.SearchBasic'   ,  1, 'Users.LBL_USER_NAME'                    , 'USER_NAME'                  , 0, null,  30, 25, 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'AuditEvents.SearchBasic'   ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'AuditEvents.SearchBasic'   ,  3, '.LBL_DATE_MODIFIED'                     , 'DATE_MODIFIED'              , 0, null, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'AuditEvents.SearchBasic'   ,  4, 'Audit.LBL_AUDIT_ACTION'                 , 'AUDIT_ACTION'               , 1, null, 'audit_action_dom'   , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'AuditEvents.SearchBasic'   ,  5, 'Audit.LBL_MODULE_NAME'                  , 'MODULE_NAME'                , 1, null, 'Modules'            , null, 4;
end -- if;
GO

-- 08/24/2019 Paul.  Add ActivityStream.SearchBasic. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ActivityStream.SearchHome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ActivityStream.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ActivityStream.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'ActivityStream.SearchBasic', 'ActivityStream', 'vwACTIVITY_STREAM', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'ActivityStream.SearchBasic',  0, 'ActivityStream.LBL_ACTION'              , 'STREAM_ACTION'              , 0, null, 'activity_stream_action'        , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'ActivityStream.SearchBasic',  0, 'ActivityStream.LBL_NAME'                , 'NAME'                       , 0, null, 400, 50, null;
end -- if;
GO

-- 01/29/2021 Paul.  Add EditCustomFields to React client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'EditCustomFields.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS EditCustomFields.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'EditCustomFields.SearchBasic', 'EditCustomFields', 'vwFIELDS_META_DATA_List', '15%', '85%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'EditCustomFields.SearchBasic',  5, 'EditCustomFields.LBL_MODULE_SELECT'   , 'CUSTOM_MODULE'              , 1, null, 'CustomEditModules'            , null, null;
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

call dbo.spEDITVIEWS_FIELDS_SearchDefaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_SearchDefaults')
/

-- #endif IBM_DB2 */

