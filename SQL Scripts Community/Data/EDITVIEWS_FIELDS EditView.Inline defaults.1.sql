

print 'EDITVIEWS_FIELDS EditView.Inline defaults';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.EditView.Inline'
--GO

set nocount on;
GO

-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.EditView.Inline'       , 'Accounts'      , 'vwACCOUNTS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  1, 'Accounts.LBL_PHONE'                     , 'PHONE_OFFICE'               , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  2, 'Accounts.LBL_WEBSITE'                   , 'WEBSITE'                    , 0, 1, 255, 28, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  3, 'Accounts.LBL_OTHER_PHONE'               , 'PHONE_ALTERNATE'            , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Inline'       ,  4, 'Accounts.LBL_MEMBER_OF'                 , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  5, 'Accounts.LBL_FAX'                       , 'PHONE_FAX'                  , 0, 2,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.EditView.Inline'       ,  6, 'Accounts.LBL_INDUSTRY'                  , 'INDUSTRY'                   , 0, 1, 'industry_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.EditView.Inline'       ,  7, 'Accounts.LBL_ACCOUNT_TYPE'              , 'ACCOUNT_TYPE'               , 0, 1, 'account_type_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  8, 'Accounts.LBL_EMAIL'                     , 'EMAIL1'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Accounts.EditView.Inline'       ,  8, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.EditView.Inline'       ,  9, 'Accounts.LBL_OTHER_EMAIL_ADDRESS'       , 'EMAIL2'                     , 0, 2, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Accounts.EditView.Inline'       ,  9, 'Email Address'                          , 'EMAIL2'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Inline'       , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.EditView.Inline'       , 11, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
end -- if;
GO

-- 03/05/2011 Paul.  Subject should be a required field. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Bugs.EditView.Inline'           , 'Bugs'          , 'vwBUGS_Edit'          , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  0, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 0, 1, 'bug_priority_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  1, 'Bugs.LBL_SOURCE'                        , 'SOURCE'                     , 0, 1, 'source_dom'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  2, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 0, 1, 'bug_type_dom'        , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  3, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, 1, 'bug_status_dom'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  4, 'Bugs.LBL_PRODUCT_CATEGORY'              , 'PRODUCT_CATEGORY'           , 0, 1, 'product_category_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.EditView.Inline'           ,  5, 'Bugs.LBL_FOUND_IN_RELEASE'              , 'FOUND_IN_RELEASE_ID'        , 0, 1, 'Release'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.EditView.Inline'           ,  6, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.EditView.Inline'           ,  7, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Bugs.EditView.Inline'           ,  8, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 1, 1, 200, 25, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Bugs.EditView.Inline'           ,  9, 'Bugs.LBL_DESCRIPTION'                   , 'DESCRIPTION'                , 0, 1,   4, 60, 3;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.EditView.Inline' and DATA_FIELD = 'NAME' and (DATA_REQUIRED = 0 or UI_REQUIRED = 0) and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_REQUIRED     = 1
		     , UI_REQUIRED       = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Bugs.EditView.Inline'
		   and DATA_FIELD        = 'NAME'
		   and (DATA_REQUIRED = 0 or UI_REQUIRED = 0)
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.EditView.Inline'          , 'Calls'         , 'vwCALLS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.EditView.Inline'          ,  0, 'Calls.LBL_NAME'                         , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Inline'          ,  1, 'Calls.LBL_STATUS'                       , 'DIRECTION'                  , 0, 1, 'call_direction_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Inline'          ,  2, null                                     , 'STATUS'                     , 0, 1, 'call_status_dom'    , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.EditView.Inline'          ,  3, 'Calls.LBL_DATE_TIME'                    , 'DATE_START'                 , 1, 1, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.EditView.Inline'          ,  4, 'Calls.LBL_DURATION'                     , 'DURATION_HOURS'             , 1, 1,   2,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.EditView.Inline'          ,  5, null                                     , 'DURATION_MINUTES'           , 0, 1, 'call_minutes_dom'   , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Calls.EditView.Inline'          ,  6, null                                     , 'Calls.LBL_HOURS_MINUTES'    , -1;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Calls.EditView.Inline'          ,  7, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Calls.EditView.Inline'          ,  8, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.EditView.Inline'          ,  9, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.EditView.Inline'          , 10, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Calls.EditView.Inline'          , 11, 'Calls.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1,   4, 60, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.EditView.Inline'          , 'Cases'         , 'vwCASES_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Inline'          ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 1, 70, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Inline'          ,  1, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, 1, 'case_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Inline'          ,  2, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, 1, 'case_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline'          ,  3, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME'       , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline'          ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline'          ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Inline'          ,  6, 'Cases.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1, 4, 80, 3;
end -- if;
GO

-- 04/20/2010 Paul.  Use an alternate view for Accounts Inline Edit as Account field is not needed. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.EditView.Inline.Accounts';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.EditView.Inline.Accounts' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.EditView.Inline.Accounts';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.EditView.Inline.Accounts' , 'Cases'         , 'vwCASES_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Inline.Accounts' ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 1, 70, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Inline.Accounts' ,  1, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, 1, 'case_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.EditView.Inline.Accounts' ,  2, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, 1, 'case_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Cases.EditView.Inline.Accounts' ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline.Accounts' ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline.Accounts' ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Cases.EditView.Inline.Accounts' ,  6, 'Cases.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1, 4, 80, 3;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.EditView.Inline'       , 'Contacts'      , 'vwCONTACTS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  1, 'Contacts.LBL_OFFICE_PHONE'              , 'PHONE_WORK'                 , 0, 1,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  2, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 1, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  3, 'Contacts.LBL_MOBILE_PHONE'              , 'PHONE_MOBILE'               , 0, 1,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Inline'       ,  4, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, 1, 'ACCOUNT_NAME'       , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  5, 'Contacts.LBL_FAX_PHONE'                 , 'PHONE_FAX'                  , 0, 1,  25, 30, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  6, 'Contacts.LBL_TITLE'                     , 'TITLE'                      , 0, 1,  40, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       ,  7, 'Contacts.LBL_DEPARTMENT'                , 'DEPARTMENT'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Contacts.EditView.Inline'       ,  8, 'Contacts.LBL_LEAD_SOURCE'               , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Contacts.EditView.Inline'       ,  9, 'Contacts.LBL_DO_NOT_CALL'               , 'DO_NOT_CALL'                , 0, 1, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       , 10, 'Contacts.LBL_EMAIL_ADDRESS'             , 'EMAIL1'                     , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Contacts.EditView.Inline'       , 10, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.EditView.Inline'       , 11, 'Contacts.LBL_OTHER_EMAIL_ADDRESS'       , 'EMAIL2'                     , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Contacts.EditView.Inline'       , 11, 'Email Address'                          , 'EMAIL2'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Inline'       , 12, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Inline'       , 13, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
end -- if;
GO

-- 07/22/2010 Paul. LBL_OTHER_EMAIL_ADDRESS. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.EditView.Inline'          , 'Leads'         , 'vwLEADS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.EditView.Inline'          ,  0, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.EditView.Inline'          ,  1, 'Leads.LBL_STATUS'                       , 'STATUS'                     , 0, 1, 'lead_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  2, 'Leads.LBL_REFERED_BY'                   , 'REFERED_BY'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  3, 'Leads.LBL_OFFICE_PHONE'                 , 'PHONE_WORK'                 , 0, 1,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  4, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  5, 'Leads.LBL_MOBILE_PHONE'                 , 'PHONE_MOBILE'               , 0, 1,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  6, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 1, 1,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  7, 'Leads.LBL_FAX_PHONE'                    , 'PHONE_FAX'                  , 0, 1,  25, 20, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          ,  8, 'Leads.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_NAME'               , 0, 1, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Leads.EditView.Inline'          ,  9, 'Leads.LBL_DO_NOT_CALL'                  , 'DO_NOT_CALL'                , 0, 1, 'CheckBox'           , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          , 10, 'Leads.LBL_EMAIL_ADDRESS'                , 'EMAIL1'                     , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Leads.EditView.Inline'          , 10, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          , 11, 'Leads.LBL_OTHER_EMAIL_ADDRESS'          , 'EMAIL2'                     , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Leads.EditView.Inline'          , 11, 'Email Address'                          , 'EMAIL2'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.EditView.Inline'          , 12, 'Leads.LBL_DEPARTMENT'                   , 'DEPARTMENT'                 , 0, 1, 100, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.EditView.Inline'          , 13, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.EditView.Inline'          , 14, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
end else begin
	-- 07/22/2010 Paul.  Fix label for EMAIL2. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.EditView.Inline' and DATA_LABEL = 'Leads.LBL_EMAIL_ADDRESS' and DATA_FIELD = 'EMAIL2' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_LABEL        = 'Leads.LBL_OTHER_EMAIL_ADDRESS'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Leads.EditView.Inline'
		   and DATA_LABEL        = 'Leads.LBL_EMAIL_ADDRESS'
		   and DATA_FIELD        = 'EMAIL2'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Meetings.EditView.Inline'       , 'Meetings'      , 'vwMEETINGS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Inline'       ,  0, 'Meetings.LBL_NAME'                      , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.EditView.Inline'       ,  1, 'Meetings.LBL_STATUS'                    , 'STATUS'                     , 1, 2, 'meeting_status_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Inline'       ,  2, 'Meetings.LBL_LOCATION'                  , 'LOCATION'                   , 0, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Meetings.EditView.Inline'       ,  3, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 3, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.EditView.Inline'       ,  4, 'Meetings.LBL_DATE_TIME'                 , 'DATE_START'                 , 1, 1, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.EditView.Inline'       ,  5, 'Meetings.LBL_DURATION'                  , 'DURATION_HOURS'             , 1, 1,   2,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.EditView.Inline'       ,  6, null                                     , 'DURATION_MINUTES'           , 0, 1, 'meeting_minutes_dom', -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Meetings.EditView.Inline'       ,  7, null                                     , 'Calls.LBL_HOURS_MINUTES'    , -1;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.EditView.Inline'       ,  8, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.EditView.Inline'       ,  9, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Meetings.EditView.Inline'       , 10, 'Meetings.LBL_DESCRIPTION'               , 'DESCRIPTION'                , 0, 3,   8, 60, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Notes.EditView.Inline'          , 'Notes'         , 'vwNOTES_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.EditView.Inline'          ,  0, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_ID'                 , 0, 1, 'CONTACT_NAME'       , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Notes.EditView.Inline'          ,  1, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.EditView.Inline'          ,  2, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Notes.EditView.Inline'          ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Notes.EditView.Inline'          ,  4, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 255,100, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Notes.EditView.Inline'          ,  5, 'Notes.LBL_FILENAME'                     , 'ATTACHMENT'                 , 0, 1, 255, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Notes.EditView.Inline'          ,  6, 'Notes.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1,   4, 90, 3;
end -- if;
GO

-- 10/06/2010 Paul.  Size of NAME field was increased to 150. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.EditView.Inline'  , 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline'  ,  0, 'Opportunities.LBL_OPPORTUNITY_NAME'     , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline'  ,  1, 'Opportunities.LBL_CURRENCY'             , 'CURRENCY_ID'                , 0, 1, 'Currencies'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline'  ,  2, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline'  ,  3, 'Opportunities.LBL_AMOUNT'               , 'AMOUNT'                     , 1, 1,  25, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline'  ,  4, 'Opportunities.LBL_TYPE'                 , 'OPPORTUNITY_TYPE'           , 0, 1, 'opportunity_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline'  ,  5, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 0, 1, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline'  ,  6, 'Opportunities.LBL_LEAD_SOURCE'          , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline'  ,  7, 'Opportunities.LBL_PROBABILITY'          , 'PROBABILITY'                , 0, 1,   3,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.EditView.Inline'  ,  8, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Opportunities.EditView.Inline'  ,  9, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline'  , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline'  , 11, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'           , 'Teams', null;
end -- if;
GO

-- 04/20/2010 Paul.  Use an alternate view for Accounts Inline Edit as Account field is not needed. 
-- 10/06/2010 Paul.  Size of NAME field was increased to 150. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.EditView.Inline.Accounts' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.EditView.Inline.Accounts';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.EditView.Inline.Accounts'  , 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline.Accounts'  ,  0, 'Opportunities.LBL_OPPORTUNITY_NAME'     , 'NAME'                       , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline.Accounts'  ,  1, 'Opportunities.LBL_CURRENCY'             , 'CURRENCY_ID'                , 0, 1, 'Currencies'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Opportunities.EditView.Inline.Accounts'  ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline.Accounts'  ,  3, 'Opportunities.LBL_AMOUNT'               , 'AMOUNT'                     , 1, 1,  25, 15, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline.Accounts'  ,  4, 'Opportunities.LBL_TYPE'                 , 'OPPORTUNITY_TYPE'           , 0, 1, 'opportunity_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline.Accounts'  ,  5, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 0, 1, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.EditView.Inline.Accounts'  ,  6, 'Opportunities.LBL_LEAD_SOURCE'          , 'LEAD_SOURCE'                , 0, 1, 'lead_source_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.EditView.Inline.Accounts'  ,  7, 'Opportunities.LBL_PROBABILITY'          , 'PROBABILITY'                , 0, 1,   3,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.EditView.Inline.Accounts'  ,  8, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Opportunities.EditView.Inline.Accounts'  ,  9, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline.Accounts'  , 10, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'    , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline.Accounts'  , 11, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'           , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Project.EditView.Inline'        , 'Project'       , 'vwPROJECTS_Edit'      , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Project.EditView.Inline'        ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Inline'        ,  1, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, 1, 'project_status_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Inline'        ,  2, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.EditView.Inline'        ,  3, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.EditView.Inline'        ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'         , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.EditView.Inline'        ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'                , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.EditView.Inline'        ,  6, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Project.EditView.Inline'        ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Project.EditView.Inline'        ,  8, 'Project.LBL_DESCRIPTION'                , 'DESCRIPTION'                , 0, 1,   4, 60, 3;
end -- if;
GO

-- 12/09/2010 Paul.  Add layout for ProjectTask. 
-- 03/05/2011 Paul.  Restore Project parent so that this view can be used in other areas. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Inline';
-- 11/03/2011 Paul.  Change field name to match stored procedure. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'ProjectTask.EditView.Inline'   , 'ProjectTask'   , 'vwPROJECT_TASKS_Edit' , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Inline'    ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'                , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Inline'    ,  2, 'ProjectTask.LBL_STATUS'                 , 'STATUS'                     , 0, 1, 'project_task_status_options'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Inline'    ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'                       , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    ,  4, 'ProjectTask.LBL_TASK_NUMBER'            , 'TASK_NUMBER'                , 0, 1,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Inline'    ,  5, 'ProjectTask.LBL_DEPENDS_ON_ID'          , 'DEPENDS_ON_ID'              , 0, 1, 'DEPENDS_ON_NAME'                 , 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Inline'    ,  6, 'ProjectTask.LBL_PRIORITY'               , 'PRIORITY'                   , 0, 1, 'project_task_priority_options'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Inline'    ,  7, 'ProjectTask.LBL_MILESTONE_FLAG'         , 'MILESTONE_FLAG'             , 0, 1, 'CheckBox'      , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    ,  8, 'ProjectTask.LBL_ORDER_NUMBER'           , 'ORDER_NUMBER'               , 0, 1,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.EditView.Inline'    ,  9, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 1, 1, 'PROJECT_NAME'                    , 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    , 10, 'ProjectTask.LBL_PERCENT_COMPLETE'       , 'PERCENT_COMPLETE'           , 0, 1,   3,  4, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.EditView.Inline'    , 11, 'ProjectTask.LBL_UTILIZATION'            , 'UTILIZATION'                , 0, 1, 'project_task_utilization_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Inline'    , 12, 'ProjectTask.LBL_DATE_START'             , 'DATE_TIME_START'            , 0, 1, 'DateTimeEdit'                    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    , 13, 'ProjectTask.LBL_ESTIMATED_EFFORT'       , 'ESTIMATED_EFFORT'           , 0, 1,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.EditView.Inline'    , 14, 'ProjectTask.LBL_DATE_DUE'               , 'DATE_TIME_DUE'              , 0, 1, 'DateTimeEdit'                    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.EditView.Inline'    , 15, 'ProjectTask.LBL_ACTUAL_EFFORT'          , 'ACTUAL_EFFORT'              , 0, 1,   4,  5, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'ProjectTask.EditView.Inline'    , 16, 'ProjectTask.LBL_DESCRIPTION'            , 'DESCRIPTION'                , 0, 1,   8, 60, 3;
	exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Inline', 'ESTIMATED_EFFORT', 'f1';
	exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat null, 'ProjectTask.EditView.Inline', 'ACTUAL_EFFORT'   , 'f1';
end else begin
	exec dbo.spEDITVIEWS_FIELDS_CnvModulePopup 'ProjectTask.EditView.Inline'    ,  9, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 1, 1, 'PROJECT_NAME'                    , 'Project', null;
	-- 11/03/2011 Paul.  Change field name to match stored procedure. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Inline' and DATA_FIELD = 'DATE_DUE' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_DUE'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'ProjectTask.EditView.Inline'
		   and DATA_FIELD        = 'DATE_DUE'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.EditView.Inline' and DATA_FIELD = 'DATE_START' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_START'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'ProjectTask.EditView.Inline'
		   and DATA_FIELD        = 'DATE_START'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Inline';
-- 11/03/2011 Paul.  Change field name to match stored procedure. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Tasks.EditView.Inline'          , 'Tasks'         , 'vwTASKS_Edit'         , '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tasks.EditView.Inline'          ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView.Inline'          ,  1, 'Tasks.LBL_STATUS'                       , 'STATUS'                     , 1, 1, 'task_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView.Inline'          ,  2, 'Tasks.LBL_DUE_DATE_AND_TIME'            , 'DATE_TIME_DUE'              , 0, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Tasks.EditView.Inline'          ,  3, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView.Inline'          ,  4, 'Tasks.LBL_START_DATE_AND_TIME'          , 'DATE_TIME_START'            , 0, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Inline'          ,  5, 'Tasks.LBL_CONTACT'                      , 'CONTACT_ID'                 , 0, 1, 'CONTACT_NAME'       , 'Contacts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView.Inline'          ,  6, 'Tasks.LBL_PRIORITY'                     , 'PRIORITY'                   , 1, 1, 'task_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tasks.EditView.Inline'          ,  7, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Inline'          ,  8, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.EditView.Inline'          ,  9, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Tasks.EditView.Inline'          , 10, 'Tasks.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1,   4, 60, 3;
end else begin
	-- 11/03/2011 Paul.  Change field name to match stored procedure. 
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Inline' and DATA_FIELD = 'DATE_DUE' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_DUE'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Tasks.EditView.Inline'
		   and DATA_FIELD        = 'DATE_DUE'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.EditView.Inline' and DATA_FIELD = 'DATE_START' and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set DATA_FIELD        = 'DATE_TIME_START'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Tasks.EditView.Inline'
		   and DATA_FIELD        = 'DATE_START'
		   and DELETED           = 0;
	end -- if;
end -- if;                                                           
GO

-- 10/21/2010 Paul.  Allow inline insert of ProspectList. 
-- 03/10/2014 Paul.  Add LIST_TYPE as it is a required field. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'ProspectLists.EditView.Inline'  , 'ProspectLists' , 'vwPROSPECT_LISTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProspectLists.EditView.Inline'  ,  0, 'ProspectLists.LBL_NAME'                 , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProspectLists.EditView.Inline'  ,  1, 'ProspectLists.LBL_LIST_TYPE'            , 'LIST_TYPE'                  , 1, 1, 'prospect_list_type_dom', null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.EditView.Inline'  ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.EditView.Inline'  ,  2, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end else begin
	-- 03/10/2014 Paul.  Add LIST_TYPE as it is a required field. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.EditView.Inline' and DATA_FIELD = 'LIST_TYPE' and DELETED = 0) begin -- then
		update EDITVIEWS
		   set LABEL_WIDTH       = '15%'
		     , FIELD_WIDTH       = '35%'
		     , DATA_COLUMNS      = 2
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where NAME              = 'ProspectLists.EditView.Inline'
		   and LABEL_WIDTH       = '100%'
		   and DELETED           = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProspectLists.EditView.Inline'  ,  -1, 'ProspectLists.LBL_LIST_TYPE'            , 'LIST_TYPE'                  , 1, 1, 'prospect_list_type_dom', null, null;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.EditView.Inline'      , 'Prospects', 'vwPROSPECTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Inline'      ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Inline'      ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Inline'      ,  2, 'Prospects.LBL_OFFICE_PHONE'             , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.EditView.Inline'      ,  3, 'Prospects.LBL_EMAIL_ADDRESS'            , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Prospects.EditView.Inline'      ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.EditView.Inline'      ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.EditView.Inline'      ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- 03/05/2011 Paul.  Allow inline creation of Campaigns.
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Campaigns.EditView.Inline'      , 'Campaigns'     , 'vwCAMPAIGNS_Edit'     , '20%', '30%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 1, 1,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Campaigns.EditView.Inline'      ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.EditView.Inline'      ,  2, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                     , 1, 1, 'campaign_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.EditView.Inline'      ,  3, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'              , 1, 1, 'campaign_type_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.EditView.Inline'      ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.EditView.Inline'      ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.EditView.Inline'      ,  6, 'Campaigns.LBL_CAMPAIGN_START_DATE'      , 'START_DATE'                 , 0, 1, 'DatePicker'         , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.EditView.Inline'      ,  7, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                   , 1, 1, 'DatePicker'         , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.EditView.Inline'      ,  8, 'Campaigns.LBL_CURRENCY'                 , 'CURRENCY_ID'                , 1, 1, 'Currencies'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      ,  9, 'Campaigns.LBL_CAMPAIGN_IMPRESSIONS'     , 'IMPRESSIONS'                , 0, 2, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 10, 'Campaigns.LBL_CAMPAIGN_BUDGET'          , 'BUDGET'                     , 0, 1, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 11, 'Campaigns.LBL_CAMPAIGN_ACTUAL_COST'     , 'ACTUAL_COST'                , 0, 2, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 12, 'Campaigns.LBL_CAMPAIGN_EXPECTED_REVENUE', 'EXPECTED_REVENUE'           , 0, 1, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 13, 'Campaigns.LBL_CAMPAIGN_EXPECTED_COST'   , 'EXPECTED_COST'              , 0, 2, 25, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Campaigns.EditView.Inline'      , 14, 'Campaigns.LBL_CAMPAIGN_OBJECTIVE'       , 'OBJECTIVE'                  , 0, 3,   4, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Campaigns.EditView.Inline'      , 15, 'Campaigns.LBL_CAMPAIGN_CONTENT'         , 'CONTENT'                    , 0, 4,   4, 80, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 16, 'Campaigns.LBL_TRACKER_TEXT'             , 'TRACKER_TEXT'               , 0, 4, 255, 50, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.EditView.Inline'      , 17, 'Campaigns.LBL_REFER_URL'                , 'REFER_URL'                  , 0, 4, 255, 50, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.EditView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.EditView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.EditView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Documents.EditView.Inline'      , 'Documents', 'vwDOCUMENTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.EditView.Inline'      ,  0, 'Documents.LBL_DOC_NAME'                 , 'DOCUMENT_NAME'              , 1, 1, 255, 40, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Documents.EditView.Inline'      ,  1, 'Documents.LBL_FILENAME'                 , 'FILENAME'                   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Documents.EditView.Inline'      ,  2, null                                     , 'CONTENT'                    , 1, 1, 255, 20, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.EditView.Inline'      ,  3, 'Documents.LBL_DOC_VERSION'              , 'REVISION'                   , 1, 1,  25, 20, null;
	-- 05/18/2011 Paul.  We need to allow the user to upload a mail-merge template without the Word plug-in. 
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Inline'      ,  4, 'Documents.LBL_TEMPLATE_TYPE'            , 'TEMPLATE_TYPE'              , 0, 1, 'document_template_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Inline'      ,  5, 'Documents.LBL_IS_TEMPLATE'              , 'IS_TEMPLATE'                , 0, 1, 'CheckBox'      , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Inline'      ,  6, 'Documents.LBL_CATEGORY_VALUE'           , 'CATEGORY_ID'                , 0, 1, 'document_category_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Inline'      ,  7, 'Documents.LBL_SUBCATEGORY_VALUE'        , 'SUBCATEGORY_ID'             , 0, 1, 'document_subcategory_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Inline'      ,  8, 'Documents.LBL_DOC_STATUS'               , 'STATUS_ID'                  , 1, 1, 'document_status_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Documents.EditView.Inline'      ,  9, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'               , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Inline'      , 10, 'Documents.LBL_DOC_ACTIVE_DATE'          , 'ACTIVE_DATE'                , 1, 1, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Inline'      , 11, 'Documents.LBL_DOC_EXP_DATE'             , 'EXP_DATE'                   , 0, 1, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Documents.EditView.Inline'      , 12, 'Documents.LBL_DESCRIPTION'              , 'DESCRIPTION'                , 0, 1,  10, 90, 3;
end else begin
	-- 05/18/2011 Paul.  We need to allow the user to upload a mail-merge template without the Word plug-in. 
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.EditView.Inline' and DATA_FIELD = 'TEMPLATE_TYPE' and DELETED = 0) begin -- then
		print 'Add TEMPLATE_TYPE to Documents.';
		update EDITVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 2
		 where EDIT_NAME  = 'Documents.EditView.Inline'
		   and FIELD_INDEX >= 4
		   and DELETED      = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.EditView.Inline'      ,  4, 'Documents.LBL_TEMPLATE_TYPE'            , 'TEMPLATE_TYPE'              , 0, 3, 'document_template_type_dom', null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.EditView.Inline'      ,  5, 'Documents.LBL_IS_TEMPLATE'              , 'IS_TEMPLATE'                , 0, 3, 'CheckBox'      , null, null, null;
	end -- if;
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

call dbo.spEDITVIEWS_FIELDS_InlineDefaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_InlineDefaults')
/

-- #endif IBM_DB2 */

