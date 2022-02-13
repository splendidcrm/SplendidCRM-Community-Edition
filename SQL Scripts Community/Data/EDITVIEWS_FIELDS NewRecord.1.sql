

print 'EDITVIEWS_FIELDS NewRecord';
-- delete from EDITVIEWS where NAME like '%.NewRecord'
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.NewRecord'
--GO

set nocount on;
GO

-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Accounts.NewRecord'       , 'Accounts', 'vwACCOUNTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.NewRecord'       ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 1, 1, 150, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.NewRecord'       ,  1, 'Accounts.LBL_PHONE'                     , 'PHONE_OFFICE'               , 0, 1,  25, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Accounts.NewRecord'       ,  1, 'Phone Number'                           , 'PHONE_OFFICE'               , '.ERR_INVALID_PHONE_NUMBER';
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Accounts.NewRecord'       ,  2, 'Accounts.LBL_WEBSITE'                   , 'WEBSITE'                    , 0, 1, 255, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.NewRecord'       ,  3, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Accounts.NewRecord'       ,  4, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Bugs.NewRecord'           , 'Bugs', 'vwBUGS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Bugs.NewRecord'           ,  0, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 1, 1, 255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.NewRecord'           ,  1, 'Bugs.LBL_TYPE'                          , 'TYPE'                       , 1, 1, 'bug_type_dom'        , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.NewRecord'           ,  2, 'Bugs.LBL_FOUND_IN_RELEASE'              , 'FOUND_IN_RELEASE_ID'        , 1, 1, 'Release'             , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Bugs.NewRecord'           ,  3, 'Bugs.LBL_PRIORITY'                      , 'PRIORITY'                   , 1, 1, 'bug_priority_dom'    , null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.NewRecord'           ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Bugs.NewRecord'           ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.NewRecord'          , 'Calls', 'vwCALLS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.NewRecord'          ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.NewRecord'          ,  1, 'Calls.LBL_DATE'                         , 'DATE_START'                 , 1, 1, 'DateTimeNewRecord', null, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.NewRecord'          ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.NewRecord'          ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Campaigns.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Campaigns.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Campaigns.NewRecord'      , 'Campaigns', 'vwCAMPAIGNS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Campaigns.NewRecord'      ,  0, 'Campaigns.LBL_NAME'                     , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.NewRecord'      ,  1, 'Campaigns.LBL_CAMPAIGN_STATUS'          , 'STATUS'                     , 1, 1, 'campaign_status_dom' , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Campaigns.NewRecord'      ,  2, 'Campaigns.LBL_CAMPAIGN_END_DATE'        , 'END_DATE'                   , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Campaigns.NewRecord'      ,  3, 'Campaigns.LBL_CAMPAIGN_TYPE'            , 'CAMPAIGN_TYPE'              , 1, 1, 'campaign_type_dom'   , null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.NewRecord'      ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Campaigns.NewRecord'      ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- 10/27/2012 Paul.  Label should be Cases.LBL_NAME and not Campaigns.LBL_NAME. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Cases.NewRecord'          , 'Cases', 'vwCASES_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Cases.NewRecord'          ,  0, 'Cases.LBL_NAME'                         , 'NAME'                       , 1, 1,  255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.NewRecord'          ,  1, 'Cases.LBL_ACCOUNT_NAME'                 , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.NewRecord'          ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.NewRecord'          ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Contacts.NewRecord'       , 'Contacts', 'vwCONTACTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.NewRecord'       ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.NewRecord'       ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.NewRecord'       ,  2, 'Contacts.LBL_OFFICE_PHONE'              , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Contacts.NewRecord'       ,  3, 'Contacts.LBL_EMAIL_ADDRESS'             , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Contacts.NewRecord'       ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.NewRecord'       ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.NewRecord'       ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Leads.NewRecord'          , 'Leads', 'vwLEADS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.NewRecord'          ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.NewRecord'          ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.NewRecord'          ,  2, 'Leads.LBL_OFFICE_PHONE'                 , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Leads.NewRecord'          ,  3, 'Leads.LBL_EMAIL_ADDRESS'                , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Leads.NewRecord'          ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.NewRecord'          ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Leads.NewRecord'          ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Meetings.NewRecord'       , 'Meetings', 'vwMEETINGS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Meetings.NewRecord'       ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Meetings.NewRecord'       ,  1, 'Meetings.LBL_DATE'                      , 'DATE_START'                 , 1, 1, 'DateTimeNewRecord', null, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.NewRecord'       ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Meetings.NewRecord'       ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Notes.NewRecord'          , 'Notes', 'vwNOTES_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Notes.NewRecord'          ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 1, 1, 255, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Notes.NewRecord'          ,  1, 'Notes.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 1,  4, 25, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.NewRecord'          ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Notes.NewRecord'          ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- 10/06/2010 Paul.  Size of NAME field was increased to 150. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Opportunities.NewRecord'  , 'Opportunities', 'vwOPPORTUNITIES_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.NewRecord'  ,  0, 'Opportunities.LBL_OPPORTUNITY_NAME'     , 'NAME'                       , 1, 1, 150, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.NewRecord'  ,  1, 'Opportunities.LBL_ACCOUNT_NAME'         , 'ACCOUNT_ID'                 , 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Opportunities.NewRecord'  ,  2, 'Opportunities.LBL_DATE_CLOSED'          , 'DATE_CLOSED'                , 1, 1, 'DatePicker'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Opportunities.NewRecord'  ,  3, 'Opportunities.LBL_SALES_STAGE'          , 'SALES_STAGE'                , 1, 1, 'sales_stage_dom'     , null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Opportunities.NewRecord'  ,  4, 'Opportunities.LBL_AMOUNT'               , 'AMOUNT'                     , 1, 1,  25, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.NewRecord'  ,  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.NewRecord'  ,  6, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- 01/13/2010 Paul.  New Project fields in SugarCRM. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Project.NewRecord'        , 'Project', 'vwPROJECTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Project.NewRecord'        ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.NewRecord'        ,  1, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.NewRecord'        ,  2, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.NewRecord'        ,  3, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.NewRecord'        ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Project.NewRecord'        ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end else begin
	if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.NewRecord' and DATA_FIELD = 'ESTIMATED_START_DATE' and DELETED = 0) begin -- then
		print 'EDITVIEWS_FIELDS Project.NewRecord: Add start date and end date';
		update EDITVIEWS_FIELDS
		   set FIELD_INDEX  = FIELD_INDEX + 3
		 where EDIT_NAME  = 'Project.NewRecord'
		   and FIELD_INDEX >= 1
		   and DELETED      = 0;
		exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.NewRecord'        ,  1, 'Project.LBL_ESTIMATED_START_DATE'       , 'ESTIMATED_START_DATE'       , 0, 1, 'DatePicker'               , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsControl     'Project.NewRecord'        ,  2, 'Project.LBL_ESTIMATED_END_DATE'         , 'ESTIMATED_END_DATE'         , 0, 1, 'DatePicker'               , null, null, null;
		exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Project.NewRecord'        ,  3, 'Project.LBL_PRIORITY'                   , 'PRIORITY'                   , 0, 1, 'projects_priority_options', null, null;
	end -- if;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'ProjectTask.NewRecord'    , 'ProjectTask', 'vwPROJECT_TASKS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProjectTask.NewRecord'    ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 1, 1,  50, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.NewRecord'    ,  1, 'ProjectTask.LBL_PARENT_ID'              , 'PROJECT_ID'                 , 1, 1, 'PROJECT_NAME', 'Project', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProjectTask.NewRecord'    ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME' , 'Users'  , null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProspectLists.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProspectLists.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'ProspectLists.NewRecord'  , 'ProspectLists' , 'vwPROSPECT_LISTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'ProspectLists.NewRecord'  ,  0, 'ProspectLists.LBL_NAME'                 , 'NAME'                       , 1, 1,  50, null, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.NewRecord'  ,  1, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ProspectLists.NewRecord'  ,  2, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.NewRecord' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.NewRecord';
	exec dbo.spEDITVIEWS_InsertOnly            'Prospects.NewRecord'      , 'Prospects', 'vwPROSPECTS_Edit', '100%', '0%', 1;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.NewRecord'      ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.NewRecord'      ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 1, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.NewRecord'      ,  2, 'Prospects.LBL_OFFICE_PHONE'             , 'PHONE_WORK'                 , 0, 1,  25, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Prospects.NewRecord'      ,  3, 'Prospects.LBL_EMAIL_ADDRESS'            , 'EMAIL1'                     , 0, 1, 100, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsValidator   'Prospects.NewRecord'      ,  3, 'Email Address'                          , 'EMAIL1'                     , '.ERR_INVALID_EMAIL_ADDRESS';
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.NewRecord'      ,  4, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME', 'Users', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Prospects.NewRecord'      ,  5, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'       , 'Teams', null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.NewPhoneCall';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.NewPhoneCall' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.NewPhoneCall';
	exec dbo.spEDITVIEWS_InsertOnly            'Calls.NewPhoneCall'       , 'Calls', 'vwCALLS_Edit', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.NewPhoneCall'       ,  0, 'Calls.LBL_NAME'                         , 'NAME'                       , 1, 1,  50, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsControl     'Calls.NewPhoneCall'       ,  1, 'Calls.LBL_DATE_TIME'                    , 'DATE_START'                 , 1, 1, 'DateTimeEdit'       , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.NewPhoneCall'       ,  2, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO_NAME'   , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Calls.NewPhoneCall'       ,  3, 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;
	exec dbo.spEDITVIEWS_FIELDS_InsLabel       'Calls.NewPhoneCall'       ,  4, null                                     , 'Calls.LBL_HOURS_MINUTES'    , -1;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'Calls.NewPhoneCall'       ,  5, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
--	exec dbo.spEDITVIEWS_FIELDS_InsBound       'Calls.NewPhoneCall'       ,  6, 'Calls.LBL_DURATION'                     , 'DURATION_HOURS'             , 1, 1,   2,  2, null;
--	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   'Calls.NewPhoneCall'       ,  7, null                                     , 'DURATION_MINUTES'           , 0, 1, 'call_minutes_dom'   , -1, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank       'Calls.NewPhoneCall'       ,  6, null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'Calls.NewPhoneCall'       ,  7, 'Calls.LBL_DESCRIPTION'                  , 'DESCRIPTION'                , 0, 3,   8, 100, 3;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'ActivityStream.NewRecord';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ActivityStream.NewRecord' and DELETED = 0) begin -- then
	exec dbo.spEDITVIEWS_InsertOnly            'ActivityStream.NewRecord' , 'ActivityStream', 'vwActivityStream', '15%', '35%', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   'ActivityStream.NewRecord' ,  0, null                                     , 'NAME'                       , 0, 1,  2, 125, 3;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'ActivityStream.NewRecord' ,  1, '.LBL_ASSIGNED_TO'                       , 'USER_ID'                    , 0, 1, 'USER_NAME'          , 'Users', null;
	exec dbo.spEDITVIEWS_FIELDS_InsChange      'ActivityStream.NewRecord' ,  2, 'PARENT_TYPE'                            , 'PARENT_ID'                  , 0, 1, 'PARENT_NAME'        , 'return ParentPopup();', null;
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

call dbo.spEDITVIEWS_FIELDS_NewRecord()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_NewRecord')
/

-- #endif IBM_DB2 */

