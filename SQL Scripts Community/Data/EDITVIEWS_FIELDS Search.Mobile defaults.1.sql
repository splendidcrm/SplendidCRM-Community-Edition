

print 'EDITVIEWS_FIELDS Search defaults';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.Search%'
--GO

set nocount on;
GO

-- 01/28/2008 Paul.  The .Mobile file should only have mobile entries.  Remove the basic and advanced search entries. 
-- 09/10/2009 Paul.  Add support for AutoComplete. 

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchBasic.Mobile', 'Accounts', 'vwACCOUNTS_List', null, null, 1;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchBasic.Mobile',  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic.Mobile',  1, 'Accounts.LBL_BILLING_ADDRESS_CITY'      , 'BILLING_ADDRESS_CITY'       , 0, null, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic.Mobile',  2, 'Accounts.LBL_ANY_PHONE'                 , 'PHONE_OFFICE'               , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Accounts.SearchBasic.Mobile',  3, 'Accounts.LBL_BILLING_ADDRESS_STREET'    , 'BILLING_ADDRESS_STREET'     , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Accounts.SearchBasic.Mobile',  4, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Accounts.SearchBasic.Mobile',  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Calls.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchBasic.Mobile'       , 'Calls', 'vwCALLS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchBasic.Mobile'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchBasic.Mobile'       ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Calls.SearchBasic.Mobile'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchBasic.Mobile'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Calls.SearchBasic.Mobile'       ,  1, 'Calls.LBL_CONTACT_NAME'                 , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Cases.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchBasic.Mobile'       , 'Cases', 'vwCASES_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Cases.SearchBasic.Mobile'       ,  0, 'Cases.LBL_CASE_NUMBER'                  , 'CASE_NUMBER'                , 0, null,  10, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchBasic.Mobile'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchBasic.Mobile'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Cases.SearchBasic.Mobile'       ,  3, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchBasic.Mobile'       ,  1, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases'   , null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Cases.SearchBasic.Mobile'       ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Contacts.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchBasic.Mobile'    , 'Contacts', 'vwCONTACTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchBasic.Mobile'    ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchBasic.Mobile'    ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Contacts.SearchBasic.Mobile'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Contacts.SearchBasic.Mobile'    ,  3, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Contacts.SearchBasic.Mobile'    ,  2, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'               , 0, null, 150, 25, 'Accounts', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Leads.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchBasic.Mobile'   and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchBasic.Mobile'       , 'Leads', 'vwLeads_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchBasic.Mobile'       ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchBasic.Mobile'       ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Leads.SearchBasic.Mobile'       ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Leads.SearchBasic.Mobile'       ,  3, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom', null, 6;
end -- if;
GO

-- 01/24/2008 Paul.  Add Meetings.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchBasic.Mobile'    , 'Meetings', 'vwMEETINGS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchBasic.Mobile'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchBasic.Mobile'    ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Meetings.SearchBasic.Mobile'    ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchBasic.Mobile'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Meetings.SearchBasic.Mobile'    ,  1, 'Meetings.LBL_CONTACT_NAME'              , 'CONTACT_NAME'               , 0, null, 150, 25, 'Contacts', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Opportunities.SearchBasic.Mobile
-- 10/07/2010 Paul.  Increase size of NAME field. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchBasic.Mobile', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchBasic.Mobile',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchBasic.Mobile',  1, 'Opportunities.LBL_TYPE'                , 'OPPORTUNITY_TYPE'           , 0, null, 'opportunity_type_dom', null, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.SearchBasic.Mobile',  2, '.LBL_CURRENT_USER_FILTER'              , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvAutoComplete 'Opportunities.SearchBasic.Mobile',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
end -- if;
GO

-- 01/24/2008 Paul.  Add Prospects.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchBasic.Mobile'   , 'Prospects', 'vwPROSPECTS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchBasic.Mobile'   ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchBasic.Mobile'   ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Prospects.SearchBasic.Mobile'   ,  2, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
end -- if;
GO

-- 03/10/2013 Paul.  Add Project.SearchBasic.Mobile
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchBasic.Mobile' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.SearchBasic.Mobile';
	exec dbo.spEDITVIEWS_InsertOnly             'Project.SearchBasic.Mobile'     , 'Project', 'vwPROJECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Project.SearchBasic.Mobile'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchBasic.Mobile'     ,  1, '.LBL_CURRENT_USER_FILTER'               , 'CURRENT_USER_ONLY'          , 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Project.SearchBasic.Mobile'     ,  2, '.LBL_FAVORITES_FILTER'                  , 'FAVORITE_RECORD_ID'         , 0, null, 'CheckBox'    , null, null, null;
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

