

print 'EDITVIEWS_FIELDS MassUpdate';
--delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.MassUpdate'
--GO

set nocount on;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.MassUpdate'     , 'Accounts', 'vwACCOUNTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.MassUpdate'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.MassUpdate'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.MassUpdate'     ,  2, 'Accounts.LBL_TYPE'                      , 'ACCOUNT_TYPE'               , 0, null, 'account_type_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Accounts.MassUpdate'     ,  3, 'Accounts.LBL_INDUSTRY'                  , 'INDUSTRY'                   , 0, null, 'industry_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Accounts.MassUpdate'     ,  4, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Accounts.MassUpdate'     ,  5, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Bugs.MassUpdate'         , 'Bugs', 'vwBUGS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.MassUpdate'         ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.MassUpdate'         ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  2, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, null, 'bug_status_dom'      , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  3, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 0, null, 'bug_priority_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  4, 'Bugs.LBL_RESOLUTION'                    , 'RESOLUTION'                 , 0, null, 'bug_resolution_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  5, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 0, null, 'bug_type_dom'        , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  6, 'Bugs.LBL_SOURCE'                        , 'SOURCE'                     , 0, null, 'source_dom'          , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.MassUpdate'         ,  7, 'Bugs.LBL_PRODUCT_CATEGORY'              , 'PRODUCT_CATEGORY'           , 0, null, 'product_category_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Bugs.MassUpdate'         ,  8, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Bugs.MassUpdate'         ,  9, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.MassUpdate'        , 'Calls', 'vwCALLS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.MassUpdate'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.MassUpdate'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.MassUpdate'        ,  2, 'Calls.LBL_DATE_TIME'                    , 'DATE_START'                 , 0, null, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.MassUpdate'        ,  3, 'Calls.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'call_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.MassUpdate'        ,  4, 'Calls.LBL_DIRECTION'                    , 'DIRECTION'                  , 0, null, 'call_direction_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Calls.MassUpdate'        ,  5, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.MassUpdate'        , 'Cases', 'vwCASES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.MassUpdate'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.MassUpdate'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.MassUpdate'        ,  2, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'       , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.MassUpdate'        ,  3, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'case_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Cases.MassUpdate'        ,  4, 'Cases.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, null, 'case_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Cases.MassUpdate'        ,  5, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.MassUpdate'     , 'Contacts', 'vwCONTACTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.MassUpdate'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.MassUpdate'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Contacts.MassUpdate'     ,  2, 'Contacts.LBL_LEAD_SOURCE'               , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.MassUpdate'     ,  3, 'Contacts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'       , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Contacts.MassUpdate'     ,  4, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.MassUpdate'     ,  5, 'Contacts.LBL_REPORTS_TO'                , 'REPORTS_TO_ID'              , 0, null, 'REPORTS_TO_NAME'    , 'Contacts', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Documents.MassUpdate'     , 'Documents', 'vwDOCUMENTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Documents.MassUpdate'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Documents.MassUpdate'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.MassUpdate'     ,  2, 'Documents.LBL_DOC_ACTIVE_DATE'          , 'ACTIVE_DATE'                , 0, null, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Documents.MassUpdate'     ,  3, 'Documents.LBL_DOC_EXP_DATE'             , 'EXP_DATE'                   , 0, null, 'DatePicker'              , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.MassUpdate'     ,  4, 'Documents.LBL_CATEGORY_VALUE'           , 'CATEGORY_ID'                , 0, null, 'document_category_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.MassUpdate'     ,  5, 'Documents.LBL_SUBCATEGORY_VALUE'        , 'SUBCATEGORY_ID'             , 0, null, 'document_subcategory_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Documents.MassUpdate'     ,  6, 'Documents.LBL_DOC_STATUS'               , 'STATUS_ID'                  , 0, null, 'document_status_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Documents.MassUpdate'     ,  7, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Emails.MassUpdate'       , 'Emails', 'vwEMAILS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Emails.MassUpdate'       ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Emails.MassUpdate'       ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.MassUpdate'        , 'Leads', 'vwLEADS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.MassUpdate'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.MassUpdate'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.MassUpdate'        ,  2, 'Leads.LBL_LEAD_SOURCE'                  , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Leads.MassUpdate'        ,  3, 'Leads.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'lead_status_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Leads.MassUpdate'        ,  4, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Leads.MassUpdate'        ,  5, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Meetings.MassUpdate'     , 'Meetings', 'vwMEETINGS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.MassUpdate'     ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.MassUpdate'     ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.MassUpdate'     ,  2, 'Meetings.LBL_DATE_TIME'                 , 'DATE_START'                 , 0, null, 'DateTimePicker'     , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Meetings.MassUpdate'     ,  3, 'Meetings.LBL_STATUS'                    , 'STATUS'                     , 0, null, 'meeting_status_dom' , null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Notes.MassUpdate'        , 'Notes', 'vwNOTES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.MassUpdate'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.MassUpdate'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Notes.MassUpdate'        ,  2, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, null, 'PARENT_NAME'        , 'return ParentPopup();', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.MassUpdate'        ,  3, 'Notes.LBL_CONTACT_NAME'                 , 'CONTACT_ID'                 , 0, null, 'CONTACT_NAME'       , 'Contacts', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.MassUpdate', 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.MassUpdate',  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.MassUpdate',  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.MassUpdate',  2, 'Opportunities.LBL_TYPE'                 , 'OPPORTUNITY_TYPE'           , 0, null, 'opportunity_type_dom', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.MassUpdate',  3, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 0, null, 'ACCOUNT_NAME'        , 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.MassUpdate',  4, 'Opportunities.LBL_LEAD_SOURCE'          , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.MassUpdate',  5, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 0, null, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.MassUpdate',  6, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 0, null, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Opportunities.MassUpdate',  7, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Project.MassUpdate'      , 'Project', 'vwPROJECTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.MassUpdate'      ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.MassUpdate'      ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.MassUpdate'      ,  2, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, null, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.MassUpdate'      ,  3, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, null, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.MassUpdate'      ,  4, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, null, 'project_status_dom'       , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.MassUpdate'      ,  5, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, null, 'projects_priority_options', null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Project.MassUpdate'      ,  6, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Project.MassUpdate'      ,  7, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'ProjectTask.MassUpdate'  , 'ProjectTask', 'vwPROJECT_TASKS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.MassUpdate'  ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.MassUpdate'  ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.MassUpdate'  ,  2, 'ProjectTask.LBL_PRIORITY'               , 'PRIORITY'                   , 0, null, 'project_task_priority_options'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'ProjectTask.MassUpdate'  ,  3, 'ProjectTask.LBL_STATUS'                 , 'STATUS'                     , 0, null, 'project_task_status_options'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.MassUpdate'  ,  4, 'ProjectTask.LBL_DATE_DUE'               , 'DATE_TIME_DUE'              , 0, null, 'DateTimeEdit'                    , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'ProjectTask.MassUpdate'  ,  5, 'ProjectTask.LBL_DATE_START'             , 'DATE_TIME_START'            , 0, null, 'DateTimeEdit'                    , null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'ProspectLists.MassUpdate', 'ProspectLists', 'vwPROSPECT_LISTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.MassUpdate',  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.MassUpdate',  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'ProspectLists.MassUpdate',  2, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'ProspectLists.MassUpdate',  3, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.MassUpdate'    , 'Prospects', 'vwPROSPECT_LISTS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.MassUpdate'    ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.MassUpdate'    ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'Prospects.MassUpdate'    ,  2, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Prospects.MassUpdate'    ,  3, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Tasks.MassUpdate'        , 'Tasks', 'vwTASKS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.MassUpdate'        ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Tasks.MassUpdate'        ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView'          ,  2, 'Tasks.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'task_status_dom'    , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Tasks.EditView'          ,  3, 'Tasks.LBL_PRIORITY'                     , 'PRIORITY'                   , 0, null, 'task_priority_dom'  , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView'          ,  4, 'Tasks.LBL_DUE_DATE_AND_TIME'            , 'DATE_TIME_DUE'              , 0, null, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Tasks.EditView'          ,  5, 'Tasks.LBL_START_DATE_AND_TIME'          , 'DATE_TIME_START'            , 0, null, 'DateTimeEdit'       , null, null, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'SmsMessages.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS SmsMessages.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'SmsMessages.MassUpdate'  , 'SmsMessages', 'vwSMS_MESSAGES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'SmsMessages.MassUpdate'  ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'SmsMessages.MassUpdate'  ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'TwitterMessages.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS TwitterMessages.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'TwitterMessages.MassUpdate', 'TwitterMessages', 'vwTWITTER_MESSAGES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'TwitterMessages.MassUpdate',  0, '.LBL_ASSIGNED_TO'                     , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'TwitterMessages.MassUpdate',  1, 'Teams.LBL_TEAM'                       , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
end -- if;
GO

-- 02/22/2021 Paul.  Releases.MassUpdate for the React client. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Releases.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Releases.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Releases.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'Releases.MassUpdate'     , 'Releases', 'vwRELEASES_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Releases.MassUpdate'     ,  0, 'Releases.LBL_STATUS'                     , 'STATUS'                     , 0, null, 'release_status_dom'   , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Releases.MassUpdate'     ,  1, null;
end -- if;
GO

-- 05/25/2021 Paul.  Provide a way to re-assign. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'RulesWizard.MassUpdate';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'RulesWizard.MassUpdate' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS RulesWizard.MassUpdate';
	exec dbo.spEDITVIEWS_InsertOnly            'RulesWizard.MassUpdate'  , 'RulesWizard', 'vwRULES_WIZARD_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'RulesWizard.MassUpdate'  ,  0, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, null, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'RulesWizard.MassUpdate'  ,  1, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, null, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect   'RulesWizard.MassUpdate'  ,  2, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'RulesWizard.MassUpdate'  ,  3, null;
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

call dbo.spEDITVIEWS_FIELDS_MassUpdate()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_MassUpdate')
/

-- #endif IBM_DB2 */


