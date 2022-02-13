

print 'EDITVIEWS_FIELDS PopupView.Inline';
-- delete from EDITVIEWS where NAME like '%.PopupView.Inline'
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.PopupView.Inline'
--GO

set nocount on;
GO

-- 02/21/2010 Paul.  Using three columns seems too large for our default popup window size.  Drop to two columns. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.PopupView.Inline'       , 'Accounts', 'vwACCOUNTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.PopupView.Inline'       ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 1, 1, 150, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.PopupView.Inline'       ,  1, 'Accounts.LBL_PHONE'                     , 'PHONE_OFFICE'               , 0, 1,  25, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Accounts.PopupView.Inline'       ,  1, 'Phone Number'                           , 'PHONE_OFFICE'               , '.ERR_INVALID_PHONE_NUMBER';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.PopupView.Inline'       ,  2, 'Accounts.LBL_WEBSITE'                   , 'WEBSITE'                    , 0, 1, 255, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Bugs.PopupView.Inline'           , 'Bugs', 'vwBUGS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Bugs.PopupView.Inline'           ,  0, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 1, 1, 255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.PopupView.Inline'           ,  1, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 1, 1, 'bug_type_dom'        , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.PopupView.Inline'           ,  2, 'Bugs.LBL_FOUND_IN_RELEASE'              , 'FOUND_IN_RELEASE_ID'        , 1, 1, 'Release'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.PopupView.Inline'           ,  3, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 1, 1, 'bug_priority_dom'    , null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.PopupView.Inline'          , 'Calls', 'vwCALLS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.PopupView.Inline'          ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.PopupView.Inline'          ,  1, 'Calls.LBL_DATE'                         , 'DATE_START'                 , 1, 1, 'DateTimeNewRecord', null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Campaigns.PopupView.Inline'      , 'Campaigns', 'vwCAMPAIGNS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.PopupView.Inline'      ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.PopupView.Inline'      ,  1, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                     , 1, 1, 'campaign_status_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.PopupView.Inline'      ,  2, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                   , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.PopupView.Inline'      ,  3, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'              , 1, 1, 'campaign_type_dom'   , null, null;
end -- if;
GO

-- 10/27/2012 Paul.  Label should be Cases.LBL_NAME and not Campaigns.LBL_NAME. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.PopupView.Inline'          , 'Cases', 'vwCASES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Cases.PopupView.Inline'          ,  0, 'Cases.LBL_NAME'                         , 'NAME'                       , 1, 1,  255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.PopupView.Inline'          ,  1, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
end -- if;
GO

-- 08/03/2010 Paul.  Add Account field so that the contact can be properly assigned. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.PopupView.Inline'       , 'Contacts', 'vwCONTACTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.PopupView.Inline'       ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.PopupView.Inline'       ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.PopupView.Inline'       ,  2, 'Contacts.LBL_OFFICE_PHONE'              , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.PopupView.Inline'       ,  3, 'Contacts.LBL_EMAIL_ADDRESS'             , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Contacts.PopupView.Inline'       ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.PopupView.Inline'       ,  4, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, 1, 'ACCOUNT_NAME'       , 'Accounts', null;
end else begin
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.PopupView.Inline'       ,  4, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, 1, 'ACCOUNT_NAME'       , 'Accounts', null;
end -- if;
GO

-- 08/17/2012 Paul.  Allow document to be created in Documents Popup. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Documents.PopupView.Inline'      , 'Documents', 'vwDOCUMENTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.PopupView.Inline'      ,  0, 'Documents.LBL_DOC_NAME'                 , 'DOCUMENT_NAME'              , 1, 1, 255, 40, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Documents.PopupView.Inline'      ,  1, 'Documents.LBL_FILENAME'                 , 'FILENAME'                   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsFile        'Documents.PopupView.Inline'      ,  2, null                                     , 'CONTENT'                    , 1, 1, 255, 20, -1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Documents.PopupView.Inline'      ,  3, 'Documents.LBL_DOC_VERSION'              , 'REVISION'                   , 1, 1,  25, 20, null;
	-- 05/18/2011 Paul.  We need to allow the user to upload a mail-merge template without the Word plug-in. 
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.PopupView.Inline'      ,  4, 'Documents.LBL_TEMPLATE_TYPE'            , 'TEMPLATE_TYPE'              , 0, 1, 'document_template_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.PopupView.Inline'      ,  5, 'Documents.LBL_IS_TEMPLATE'              , 'IS_TEMPLATE'                , 0, 1, 'CheckBox'      , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.PopupView.Inline'      ,  6, 'Documents.LBL_CATEGORY_VALUE'           , 'CATEGORY_ID'                , 0, 1, 'document_category_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.PopupView.Inline'      ,  7, 'Documents.LBL_SUBCATEGORY_VALUE'        , 'SUBCATEGORY_ID'             , 0, 1, 'document_subcategory_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.PopupView.Inline'      ,  8, 'Documents.LBL_DOC_STATUS'               , 'STATUS_ID'                  , 1, 1, 'document_status_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Documents.PopupView.Inline'      ,  9, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'               , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.PopupView.Inline'      , 10, 'Documents.LBL_DOC_ACTIVE_DATE'          , 'ACTIVE_DATE'                , 1, 1, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.PopupView.Inline'      , 11, 'Documents.LBL_DOC_EXP_DATE'             , 'EXP_DATE'                   , 0, 1, 'DatePicker'              , null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.PopupView.Inline'          , 'Leads', 'vwLEADS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.PopupView.Inline'          ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.PopupView.Inline'          ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.PopupView.Inline'          ,  2, 'Leads.LBL_OFFICE_PHONE'                 , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.PopupView.Inline'          ,  3, 'Leads.LBL_EMAIL_ADDRESS'                , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Leads.PopupView.Inline'          ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Meetings.PopupView.Inline'       , 'Meetings', 'vwMEETINGS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.PopupView.Inline'       ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.PopupView.Inline'       ,  1, 'Meetings.LBL_DATE'                      , 'DATE_START'                 , 1, 1, 'DateTimeNewRecord', null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Notes.PopupView.Inline'          , 'Notes', 'vwNOTES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Notes.PopupView.Inline'          ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Notes.PopupView.Inline'          ,  1, 'Notes.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1,  4, 25, null;
end -- if;
GO

-- 10/06/2010 Paul.  Size of NAME field was increased to 150. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.PopupView.Inline'  , 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.PopupView.Inline'  ,  0, 'Opportunities.LBL_OPPORTUNITY_NAME'     , 'NAME'                       , 1, 1, 150, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.PopupView.Inline'  ,  1, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.PopupView.Inline'  ,  2, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.PopupView.Inline'  ,  3, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 1, 1, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.PopupView.Inline'  ,  4, 'Opportunities.LBL_AMOUNT'               , 'AMOUNT'                     , 1, 1,  25, null, null;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Project.PopupView.Inline'        , 'Project', 'vwPROJECTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Project.PopupView.Inline'        ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.PopupView.Inline'        ,  1, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.PopupView.Inline'        ,  2, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.PopupView.Inline'        ,  3, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.PopupView.Inline'        ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME' , 'Users', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'ProjectTask.PopupView.Inline'    , 'ProjectTask', 'vwPROJECT_TASKS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.PopupView.Inline'    ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.PopupView.Inline'    ,  1, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 1, 1, 'PROJECT_NAME', 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.PopupView.Inline'    ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME' , 'Users'  , null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'ProspectLists.PopupView.Inline'  , 'ProspectLists' , 'vwPROSPECT_LISTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProspectLists.PopupView.Inline'  ,  0, 'ProspectLists.LBL_NAME'                 , 'NAME'                       , 1, 1,  50, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.PopupView.Inline'      , 'Prospects', 'vwPROSPECTS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.PopupView.Inline'      ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.PopupView.Inline'      ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.PopupView.Inline'      ,  2, 'Prospects.LBL_OFFICE_PHONE'             , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.PopupView.Inline'      ,  3, 'Prospects.LBL_EMAIL_ADDRESS'            , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Prospects.PopupView.Inline'      ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
end -- if;
GO

-- 08/05/2010 Paul.  Add ability to create credit card in popup. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'CreditCards.PopupView.Inline' and DELETED = 0) begin -- then 
	print 'EDITVIEWS_FIELDS CreditCards.PopupView.Inline'; 
	exec dbo.spEDITVIEWS_InsertOnly 'CreditCards.PopupView.Inline', 'CreditCards', 'vwCREDIT_CARDS_Edit', '15%', '35%', null; 
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline',  0, 'CreditCards.LBL_NAME'              , 'NAME'              , 1, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'CreditCards.PopupView.Inline',  1, 'CreditCards.LBL_CARD_TYPE'         , 'CARD_TYPE'         , 1, 1, 'credit_card_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline',  2, 'CreditCards.LBL_CARD_NUMBER'       , 'CARD_NUMBER'       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'CreditCards.PopupView.Inline',  3, 'CreditCards.LBL_EXPIRATION_DATE'   , 'EXPIRATION_MONTH'  , 1, 1, 'dom_cal_month_long'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'CreditCards.PopupView.Inline',  4, null                                , 'EXPIRATION_YEAR'   , 1, 1, 'credit_card_year'    , -1, null;

	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline',  5, 'CreditCards.LBL_SECURITY_CODE'     , 'SECURITY_CODE'     , 0, 1, 10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'CreditCards.PopupView.Inline',  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'CreditCards.PopupView.Inline',  7, 'CreditCards.LBL_IS_PRIMARY'        , 'IS_PRIMARY'        , 0, 1, 'CheckBox'            , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline',  8, 'CreditCards.LBL_ADDRESS_STREET'    , 'ADDRESS_STREET'    , 0, 1, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline',  9, 'CreditCards.LBL_ADDRESS_CITY'      , 'ADDRESS_CITY'      , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline', 10, 'CreditCards.LBL_ADDRESS_STATE'     , 'ADDRESS_STATE'     , 0, 1, 100, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline', 11, 'CreditCards.LBL_ADDRESS_POSTALCODE', 'ADDRESS_POSTALCODE', 0, 1,  20, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'CreditCards.PopupView.Inline', 12, 'CreditCards.LBL_ADDRESS_COUNTRY'   , 'ADDRESS_COUNTRY'   , 0, 1, 100, 35, null;
end -- if;
GO

-- 08/26/2010 Paul.  Create inline editing for Releases. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Releases.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Releases.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Releases.PopupView.Inline', 'Releases', 'vwRELEASES', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Releases.PopupView.Inline'       ,  0, 'Releases.LBL_NAME'                      , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Releases.PopupView.Inline'       ,  1, 'Releases.LBL_STATUS'                    , 'STATUS'                     , 1, 1, 'release_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Releases.PopupView.Inline'       ,  2, 'Releases.LBL_LIST_ORDER'                , 'LIST_ORDER'                 , 1, 1,  10, 10, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Releases.PopupView.Inline'       ,  3, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Releases.PopupView.Inline'       ,  3, 'Integer'                                , 'LIST_ORDER'                 , '.ERR_INVALID_PHONE_NUMBER';
end -- if;
GO

-- 11/23/2014 Paul.  Add ChatChannels module. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ChatChannels.PopupView.Inline';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ChatChannels.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ChatChannels.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'ChatChannels.PopupView.Inline'   , 'ChatChannels', 'vwCHAT_CHANNELS_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ChatChannels.PopupView.Inline'   ,  0, 'ChatChannels.LBL_NAME'                  , 'NAME'                       , 1, 1, 150, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'ChatChannels.PopupView.Inline'   ,  1, null;
end -- if;
GO

-- 05/12/2016 Paul.  Add support for Tags. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.PopupView.Inline'
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tags.PopupView.Inline' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tags.PopupView.Inline';
	exec dbo.spEDITVIEWS_InsertOnly            'Tags.PopupView.Inline', 'Tags', 'vwTAGS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Tags.PopupView.Inline'           ,  0, 'Tags.LBL_NAME'                          , 'NAME'                       , 1, 1, 255, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Tags.PopupView.Inline'           ,  1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Tags.PopupView.Inline'           ,  2, 'Tags.LBL_DESCRIPTION'                   , 'DESCRIPTION'                , 0, 2,   4, 60, null;
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

call dbo.spEDITVIEWS_FIELDS_PopupViewInline()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_PopupViewInline')
/

-- #endif IBM_DB2 */

