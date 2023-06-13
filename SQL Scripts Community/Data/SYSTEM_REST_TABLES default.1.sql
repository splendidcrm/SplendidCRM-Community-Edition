

print 'SYSTEM_REST_TABLES Default';
-- delete from SYSTEM_REST_TABLES;
--GO

set nocount on;
GO

-- 06/18/2011 Paul.  SYSTEM_REST_TABLES are nearly identical to SYSTEM_SYNC_TABLES,
-- but the Module tables typically refer to the base view instead of the raw table. 
-- 06/18/2011 Paul.  We do not anticipate a need access to all the system tables via the REST API. 

-- System Tables
-- 04/16/2021 Paul.  ACL_ROLES is used by the react client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ACL_ROLES'                       , 'vwACL_ROLES'                     , 'ACLRoles'                 , null                       , 0, null, 1, 0, null, 0;
-- 10/24/2011 Paul.  The HTML5 Offline Client needs access to the config table. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CONFIG'                          , 'vwCONFIG_Sync'                   , 'Config'                   , null                       , 0, null, 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CURRENCIES'                      , 'vwCURRENCIES'                    , 'Currencies'               , null                       , 0, null, 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'FIELD_VALIDATORS'                , 'vwFIELD_VALIDATORS'              , 'FieldValidators'          , null                       , 0, null, 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'FIELDS_META_DATA'                , 'vwFIELDS_META_DATA'              , null                       , null                       , 0, null, 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'LANGUAGES'                       , 'vwLANGUAGES'                     , null                       , null                       , 0, null, 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'NUMBER_SEQUENCES'                , 'vwNUMBER_SEQUENCES'              , null                       , null                       , 0, null, 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'RELEASES'                        , 'vwRELEASES'                      , 'Releases'                 , null                       , 0, null, 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TIMEZONES'                       , 'vwTIMEZONES'                     , null                       , null                       , 0, null, 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TAB_GROUPS'                      , 'TAB_GROUPS'                    , null                       , null                       , 0, null, 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'RULES'                           , 'RULES'                         , 'Rules'                    , null                       , 0, null, 1, 0, null, 0;
-- 08/08/2019 Paul.  React Client needs access to the RulesWizard. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'RULES'                           , 'vwRULES_WIZARD'                  , 'RulesWizard'              , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
GO

-- System UI Tables
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ACL_ACTIONS'                     , 'vwACL_ACTIONS'                   , 'ACLRoles'                 , null                       , 1, 'CATEGORY'   , 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ACL_ROLES_ACTIONS'               , 'vwACL_ROLES_ACTIONS_Category'  , 'ACLRoles'                 , null                       , 1, 'CATEGORY'   , 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DASHLETS'                        , 'vwDASHLETS'                      , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DETAILVIEWS'                     , 'vwDETAILVIEWS'                   , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DETAILVIEWS_FIELDS'              , 'vwDETAILVIEWS_FIELDS'            , null                       , null                       , 2, 'DETAIL_NAME', 1, 0, null, 0;
-- 08/31/2011 Paul.  DETAILVIEWS_RELATIONSHIPS does have a module associated with it. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DETAILVIEWS_RELATIONSHIPS'       , 'vwDETAILVIEWS_RELATIONSHIPS'     , 'DetailViewsRelationships' , null                       , 2, 'DETAIL_NAME', 1, 0, null, 0;
if exists(select * from vwMODULES where MODULE_NAME = 'DetailViewsRelationships' and (REST_ENABLED = 0 or REST_ENABLED is null)) begin -- then
	update MODULES
	   set REST_ENABLED         = 1
	     , MODIFIED_USER_ID     = null    
	     , DATE_MODIFIED        =  getdate()           
	     , DATE_MODIFIED_UTC    =  getutcdate()        
	 where MODULE_NAME          = 'DetailViewsRelationships'
	   and DELETED              = 0;
end -- if;
GO

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DYNAMIC_BUTTONS'                 , 'vwDYNAMIC_BUTTONS'               , 'DynamicButtons'           , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EDITVIEWS'                       , 'vwEDITVIEWS'                     , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EDITVIEWS_FIELDS'                , 'vwEDITVIEWS_FIELDS'              , null                       , null                       , 2, 'EDIT_NAME'  , 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'GRIDVIEWS'                       , 'vwGRIDVIEWS'                     , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'GRIDVIEWS_COLUMNS'               , 'vwGRIDVIEWS_COLUMNS'             , null                       , null                       , 2, 'GRID_NAME'  , 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'MODULES'                         , 'vwMODULES'                       , 'Modules'                  , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SHORTCUTS'                       , 'vwSHORTCUTS'                     , 'Shortcuts'                , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TERMINOLOGY_ALIASES'             , 'vwTERMINOLOGY_ALIASES'           , 'Terminology'              , null                       , 0, null         , 1, 0, null, 0;
-- 04/28/2021 Paul.  React needs access to the help text. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TERMINOLOGY_HELP'                , 'vwTERMINOLOGY_HELP'              , 'Terminology'              , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TERMINOLOGY'                     , 'vwTERMINOLOGY'                   , 'Terminology'              , null                       , 3, 'MODULE_NAME', 1, 0, null, 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'MODULES_GROUPS'                  , 'vwMODULES_GROUPS'                , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
-- 08/09/2019 Paul.  The zipcode table is needed by the React Client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ZIPCODES'                        , 'vwZIPCODES'                      , 'ZipCodes'                 , null                       , 0, null, 0, 0, null, 0;
GO

-- User Tables
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TAB_MENUS'                       , 'vwMODULES_TabMenu_ByUser'        , 'Modules'                  , null                       , 0, null, 1, 1, 'USER_ID'         , 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DASHLETS_USERS'                  , 'vwDASHLETS_USERS'                , null                       , 'Users'                    , 0, null, 1, 1, 'ASSIGNED_USER_ID', 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TEAMS'                           , 'vwTEAMS'                         , 'Teams'                    , null                       , 0, null, 1, 0, null, 0;
-- 04/17/2021 Paul.  Allow access to vwUSERS_TEAM_MEMBERSHIPS on community to allow precompile to run without error. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_TEAM_MEMBERSHIPS'        , 'vwUSERS_TEAM_MEMBERSHIPS'        , 'Users'                    , 'Teams'                    , 0, null, 0, 0, 'USER_ID', 1, 'USER_ID';
-- 05/14/2016 Paul.  Add Tags module. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TAGS'                            , 'vwTAGS'                          , 'Tags'                     , null                       , 0, null, 0, 0, null, 0;
-- 01/05/2021 Paul.  Everyone should be able to add a tag.  
if exists(select * from SYSTEM_REST_TABLES where TABLE_NAME = 'TAGS' and IS_SYSTEM = 1 and DELETED = 0) begin -- then
	update SYSTEM_REST_TABLES
	   set IS_SYSTEM         = 0
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'TAGS'
	   and IS_SYSTEM         = 1
	   and DELETED           = 0;
end -- if;
GO

-- 06/07/2017 Paul.  Add NAICSCodes module. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'NAICS_CODES'                     , 'vwNAICS_CODES'                   , 'NAICSCodes'               , null                       , 0, null, 1, 0, null, 0;
-- 12/31/2017 Paul.  We should not sync the USERS view directly as it can contain encrypted passwords. 
-- Use vwUSERS_Sync instead as it filters these fields. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'USERS'                           , 'vwUSERS_Sync'                    , 'Users'                    , null                       , 0, null, 1, 0, null, 0;
if exists(select * from SYSTEM_REST_TABLES where TABLE_NAME = 'USERS' and VIEW_NAME = 'vwUSERS' and DELETED = 0) begin -- then
	update SYSTEM_REST_TABLES
	   set VIEW_NAME         = 'vwUSERS_Sync'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'USERS'
	   and VIEW_NAME         = 'vwUSERS'
	   and DELETED           = 0;
end -- if;
-- 10/04/2020 Paul.  The React Client needs access to users for assigned to selection. 
-- Do not tie to the users module as a user that cannot access the Users module can still select a user.  
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_ASSIGNED_TO_List'        , 'vwUSERS_ASSIGNED_TO_List'        , null                       , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwTEAMS_ASSIGNED_TO_List'        , 'vwTEAMS_ASSIGNED_TO_List'        , null                       , null                       , 0, null, 0, 1, 'MEMBERSHIP_USER_ID', 0, null;

-- 09/09/2019 Paul.  Add a restricted Employees view for the React Client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMPLOYEES_Sync'                , 'vwEMPLOYEES_Sync'                , 'Employees'                , null                       , 0, null, 0, 0, null, 0;

-- Module Tables
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ACCOUNTS'                        , 'vwACCOUNTS'                      , 'Accounts'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'BUGS'                            , 'vwBUGS'                          , 'Bugs'                     , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CALLS'                           , 'vwCALLS'                         , 'Calls'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CAMPAIGNS'                       , 'vwCAMPAIGNS'                     , 'Campaigns'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
-- 08/02/2019 Paul.  React Client needs access to other campaign views. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_Roi'                 , 'vwCAMPAIGNS_Roi'                 , 'Campaigns'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_Activity'            , 'vwCAMPAIGNS_Activity'            , 'Campaigns'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_PROSPECT_LISTS'      , 'vwCAMPAIGNS_PROSPECT_LISTS'      , 'Campaigns'                , 'ProspectLists'            , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_CAMPAIGN_TRKRS'      , 'vwCAMPAIGNS_CAMPAIGN_TRKRS'      , 'Campaigns'                , 'CampaignTrackers'         , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_EMAIL_MARKETING'     , 'vwCAMPAIGNS_EMAIL_MARKETING'     , 'Campaigns'                , 'EmailMarketing'           , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_CALL_MARKETING'      , 'vwCAMPAIGNS_CALL_MARKETING'      , 'Campaigns'                , 'CallMarketing'            , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_LEADS'               , 'vwCAMPAIGNS_LEADS'               , 'Campaigns'                , 'Leads'                    , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_OPPORTUNITIES'       , 'vwCAMPAIGNS_OPPORTUNITIES'       , 'Campaigns'                , 'Opportunities'            , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILMAN_List'                 , 'vwEMAILMAN_List'                 , 'Campaigns'                , null                       , 0, null, 0, 0, null, 0, null;
-- 02/16/2022 Paul.  Enable Campaign Email Marketing preview. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGNS_Send'                , 'vwCAMPAIGNS_Send'                , 'Campaigns'                , null                       , 0, null, 0, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackTargeted'    , 'vwCAMPAIGN_LOG_TrackTargeted'    , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackViewed'      , 'vwCAMPAIGN_LOG_TrackViewed'      , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackClickThru'   , 'vwCAMPAIGN_LOG_TrackClickThru'   , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackLeads'       , 'vwCAMPAIGN_LOG_TrackLeads'       , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackContacts'    , 'vwCAMPAIGN_LOG_TrackContacts'    , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackInvalid'     , 'vwCAMPAIGN_LOG_TrackInvalid'     , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackSendError'   , 'vwCAMPAIGN_LOG_TrackSendError'   , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackRemoved'     , 'vwCAMPAIGN_LOG_TrackRemoved'     , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_LOG_TrackBlocked'     , 'vwCAMPAIGN_LOG_TrackBlocked'     , 'CampaignLog'              , null                       , 0, null, 0, 0, null, 1, 'CAMPAIGN_ID';
-- 05/03/2020 Paul.  The React Client needs access to recipient emails for the Emails.EditView. 
-- delete from SYSTEM_REST_TABLES where TABLE_NAME = 'vwQUEUE_EMAIL_ADDRESS';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwQUEUE_EMAIL_ADDRESS'           , 'vwQUEUE_EMAIL_ADDRESS'           , null                       , null                       , 0, null, 0, 0, null, 1, 'PARENT_ID';

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CASES'                           , 'vwCASES'                         , 'Cases'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CONTACTS'                        , 'vwCONTACTS'                      , 'Contacts'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
-- 11/24/2021 Paul.  DocumentRevisions has layouts, so we need to define a separate module for it on order for the React Client to function. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DOCUMENTS'                       , 'vwDOCUMENTS'                     , 'Documents'                , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DOCUMENT_REVISIONS'              , 'vwDOCUMENT_REVISIONS'            , 'DocumentRevisions'        , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EMAIL_TEMPLATES'                 , 'vwEMAIL_TEMPLATES'               , 'EmailTemplates'           , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EMAILS'                          , 'vwEMAILS'                        , 'Emails'                   , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'FEEDS'                           , 'vwFEEDS'                         , 'Feeds'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'IFRAMES'                         , 'vwIFRAMES'                       , 'iFrames'                  , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'IMAGES'                          , 'vwIMAGES'                        , 'Images'                   , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'LEADS'                           , 'vwLEADS'                         , 'Leads'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'MEETINGS'                        , 'vwMEETINGS'                      , 'Meetings'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'NOTES'                           , 'vwNOTES'                         , 'Notes'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'OPPORTUNITIES'                   , 'vwOPPORTUNITIES'                 , 'Opportunities'            , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'PROJECT'                         , 'vwPROJECT'                       , 'Project'                  , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'PROJECT_TASK'                    , 'vwPROJECT_TASK'                  , 'ProjectTask'              , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'PROSPECT_LISTS'                  , 'vwPROSPECT_LISTS'                , 'ProspectLists'            , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'PROSPECTS'                       , 'vwPROSPECTS'                     , 'Prospects'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TASKS'                           , 'vwTASKS'                         , 'Tasks'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
-- 07/19/2020 Paul.  The react Client needs access to SmsMessages and TwitterMessages. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SMS_MESSAGES'                    , 'vwSMS_MESSAGES'                  , 'SmsMessages'              , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'TWITTER_MESSAGES'                , 'vwTWITTER_MESSAGES'              , 'TwitterMessages'          , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
GO

-- 03/30/2016 Paul.  Convert requires special processing. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_Convert'                 , 'vwLEADS_Convert'                 , 'Leads'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_Convert'             , 'vwPROSPECTS_Convert'             , 'Prospects'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
GO

-- 05/01/2020 Paul.  The React Client needs to build the PopupEmailAddresses list manually. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_EmailList'            , 'vwCONTACTS_EmailList'            , 'Contacts'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_EmailList'               , 'vwLEADS_EmailList'               , 'Leads'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_EmailList'           , 'vwPROSPECTS_EmailList'           , 'Prospects'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_EmailList'            , 'vwACCOUNTS_EmailList'            , 'Accounts'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
-- 10/20/2020 Paul.  The React Client uses vwACTIVITIES_MyList in the dashlets. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACTIVITIES_MyList'             , 'vwACTIVITIES_MyList'             , 'Activities'               , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
GO

-- Relationship Tables
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_ACTIVITIES'             , 'vwACCOUNTS_ACTIVITIES'           , 'Accounts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_ACTIVITIES_HISTORY'     , 'vwACCOUNTS_ACTIVITIES_HISTORY'   , 'Accounts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_ACTIVITIES_OPEN'        , 'vwACCOUNTS_ACTIVITIES_OPEN'      , 'Accounts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_BUGS'                   , 'vwACCOUNTS_BUGS'                 , 'Accounts'                 , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_CASES'                  , 'vwACCOUNTS_CASES'                , 'Accounts'                 , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_CONTACTS'               , 'vwACCOUNTS_CONTACTS'             , 'Accounts'                 , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_DOCUMENTS'              , 'vwACCOUNTS_DOCUMENTS'            , 'Accounts'                 , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_LEADS'                  , 'vwACCOUNTS_LEADS'                , 'Accounts'                 , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_MEMBERS'                , 'vwACCOUNTS_MEMBERS'              , 'Accounts'                 , 'Accounts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_OPPORTUNITIES'          , 'vwACCOUNTS_OPPORTUNITIES'        , 'Accounts'                 , 'Opportunities'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_PROJECTS'               , 'vwACCOUNTS_PROJECTS'             , 'Accounts'                 , 'Project'                  , 0, null, 0, 0, null, 1;
-- 04/13/2021 Paul.  Accounts/ProspectLists is relatively new. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_PROSPECT_LISTS'         , 'vwACCOUNTS_PROSPECT_LISTS'       , 'Accounts'                 , 'ProspectLists'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_USERS'                  , 'vwACCOUNTS_USERS'                , 'Accounts'                 , 'Users'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_ACTIVITIES'                 , 'vwBUGS_ACTIVITIES'               , 'Bugs'                     , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_ACTIVITIES_HISTORY'         , 'vwBUGS_ACTIVITIES_HISTORY'       , 'Bugs'                     , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_ACTIVITIES_OPEN'            , 'vwBUGS_ACTIVITIES_OPEN'          , 'Bugs'                     , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_ACCOUNTS'                   , 'vwBUGS_ACCOUNTS'                 , 'Bugs'                     , 'Accounts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_CASES'                      , 'vwBUGS_CASES'                    , 'Bugs'                     , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_CONTACTS'                   , 'vwBUGS_CONTACTS'                 , 'Bugs'                     , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_DOCUMENTS'                  , 'vwBUGS_DOCUMENTS'                , 'Bugs'                     , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_USERS'                      , 'vwBUGS_USERS'                    , 'Bugs'                     , 'Users'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALLS_CONTACTS'                  , 'vwCALLS_CONTACTS'                , 'Calls'                    , 'Contacts'                 , 0, null, 0, 0, null, 1;
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALLS_LEADS'                     , 'vwCALLS_LEADS'                   , 'Calls'                    , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALLS_NOTES'                     , 'vwCALLS_NOTES'                   , 'Calls'                    , 'Notes'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALLS_USERS'                     , 'vwCALLS_USERS'                   , 'Calls'                    , 'Users'                    , 0, null, 0, 0, null, 1;
-- 04/10/2021 Paul.  vwCAMPAIGN_TRKRS is not a relationship table. 
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCAMPAIGN_TRKRS'                  , 'vwCAMPAIGN_TRKRS'                , 'CampaignTrackers'         , null                       , 0, null, 0, 0, null, 1;
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwCAMPAIGN_TRKRS') begin -- then
	update SYSTEM_REST_TABLES
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'vwCAMPAIGN_TRKRS'
	   and DELETED           = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CAMPAIGN_TRKRS'                    , 'vwCAMPAIGN_TRKRS'                , 'CampaignTrackers'         , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_ACTIVITIES'                , 'vwCASES_ACTIVITIES'              , 'Cases'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_ACTIVITIES_HISTORY'        , 'vwCASES_ACTIVITIES_HISTORY'      , 'Cases'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_ACTIVITIES_OPEN'           , 'vwCASES_ACTIVITIES_OPEN'         , 'Cases'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_BUGS'                      , 'vwCASES_BUGS'                    , 'Cases'                    , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_CONTACTS'                  , 'vwCASES_CONTACTS'                , 'Cases'                    , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_DOCUMENTS'                 , 'vwCASES_DOCUMENTS'               , 'Cases'                    , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_KBDOCUMENTS'               , 'vwCASES_KBDOCUMENTS'             , 'Cases'                    , 'KBDocuments'              , 0, null, 0, 0, null, 1;
-- 04/13/2021 Paul.  Missing view. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_PROJECTS'                  , 'vwCASES_PROJECTS'                , 'Cases'                    , 'Project'                  , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_USERS'                     , 'vwCASES_USERS'                   , 'Cases'                    , 'Users'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_ACTIVITIES'             , 'vwCONTACTS_ACTIVITIES'           , 'Contacts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_ACTIVITIES_HISTORY'     , 'vwCONTACTS_ACTIVITIES_HISTORY'   , 'Contacts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_ACTIVITIES_OPEN'        , 'vwCONTACTS_ACTIVITIES_OPEN'      , 'Contacts'                 , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_DIRECT_REPORTS'         , 'vwCONTACTS_DIRECT_REPORTS'       , 'Contacts'                 , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_DOCUMENTS'              , 'vwCONTACTS_DOCUMENTS'            , 'Contacts'                 , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_LEADS'                  , 'vwCONTACTS_LEADS'                , 'Contacts'                 , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_OPPORTUNITIES'          , 'vwCONTACTS_OPPORTUNITIES'        , 'Contacts'                 , 'Opportunities'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_PROJECTS'               , 'vwCONTACTS_PROJECTS'             , 'Contacts'                 , 'Project'                  , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_PROSPECT_LISTS'         , 'vwCONTACTS_PROSPECT_LISTS'       , 'Contacts'                 , 'ProspectLists'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_BUGS'                   , 'vwCONTACTS_BUGS'                 , 'Contacts'                 , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_CASES'                  , 'vwCONTACTS_CASES'                , 'Contacts'                 , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_USERS'                  , 'vwCONTACTS_USERS'                , 'Contacts'                 , 'Users'                    , 0, null, 0, 0, null, 1;

-- 09/15/2012 Paul.  New tables for Accounts, Bugs, Cases, Contacts, Contracts, Leads, Opportunities, Quotes. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_ACCOUNTS'              , 'vwDOCUMENTS_ACCOUNTS'            , 'Documents'                , 'Accounts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_BUGS'                  , 'vwDOCUMENTS_BUGS'                , 'Documents'                , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_CASES'                 , 'vwDOCUMENTS_CASES'               , 'Documents'                , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_CONTACTS'              , 'vwDOCUMENTS_CONTACTS'            , 'Documents'                , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_LEADS'                 , 'vwDOCUMENTS_LEADS'               , 'Documents'                , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENTS_OPPORTUNITIES'         , 'vwDOCUMENTS_OPPORTUNITIES'       , 'Documents'                , 'Opportunities'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwDOCUMENT_REVISIONS'              , 'vwDOCUMENT_REVISIONS'            , 'Documents'                , null                       , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAIL_IMAGES'                    , 'vwEMAIL_IMAGES'                  , 'Images'                   , null                       , 0, null, 0, 0, null, 0;
-- 04/10/2021 Paul.  vwEMAIL_MARKETING is not a relationship table. 
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAIL_MARKETING'                 , 'vwEMAIL_MARKETING'               , 'EmailMarketing'           , null                       , 0, null, 0, 0, null, 1;
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwEMAIL_MARKETING') begin -- then
	update SYSTEM_REST_TABLES
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'vwEMAIL_MARKETING'
	   and DELETED           = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EMAIL_MARKETING'                   , 'vwEMAIL_MARKETING'               , 'EmailMarketing'           , null                       , 0, null, 0, 0, null, 0;

-- 04/13/2021 Paul.  vwEMAIL_MARKETING_PROSPECT_LST is the correct table name. 
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwEMAIL_MARKETING_PROSPECT_LISTS') begin -- then
	update SYSTEM_REST_TABLES
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'vwEMAIL_MARKETING_PROSPECT_LISTS'
	   and DELETED           = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAIL_MARKETING_PROSPECT_LST'    , 'vwEMAIL_MARKETING_PROSPECT_LST'  , 'EmailMarketing'           , 'ProspectLists'            , 0, null, 0, 0, null, 1;

-- 08/28/2012 Paul.  Add Call Marketing. 
-- 04/10/2021 Paul.  vwCALL_MARKETING is not a relationship table. 
--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALL_MARKETING'                  , 'vwCALL_MARKETING'                , 'CallMarketing'            , null                       , 0, null, 0, 0, null, 1;
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwCALL_MARKETING') begin -- then
	update SYSTEM_REST_TABLES
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'vwCALL_MARKETING'
	   and DELETED           = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CALL_MARKETING'                    , 'vwCALL_MARKETING'                , 'CallMarketing'            , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;

-- 04/13/2021 Paul.  vwCALL_MARKETING_PROSPECT_LST is the correct table name. 
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwCALL_MARKETING_PROSPECT_LISTS') begin -- then
	update SYSTEM_REST_TABLES
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where TABLE_NAME        = 'vwCALL_MARKETING_PROSPECT_LISTS'
	   and DELETED           = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALL_MARKETING_PROSPECT_LST'     , 'vwCALL_MARKETING_PROSPECT_LST'   , 'CallMarketing'            , 'ProspectLists'            , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_ACCOUNTS'                 , 'vwEMAILS_ACCOUNTS'               , 'Emails'                   , 'Accounts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_BUGS'                     , 'vwEMAILS_BUGS'                   , 'Emails'                   , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_CASES'                    , 'vwEMAILS_CASES'                  , 'Emails'                   , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_CONTACTS'                 , 'vwEMAILS_CONTACTS'               , 'Emails'                   , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_LEADS'                    , 'vwEMAILS_LEADS'                  , 'Emails'                   , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_OPPORTUNITIES'            , 'vwEMAILS_OPPORTUNITIES'          , 'Emails'                   , 'Opportunities'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_PROJECT_TASKS'            , 'vwEMAILS_PROJECT_TASKS'          , 'Emails'                   , 'ProjectTask'              , 0, null, 0, 0, null, 1;
-- 04/13/2021 Paul.  Fix related module for the react client. 
if exists(select * from vwSYSTEM_REST_TABLES where TABLE_NAME = 'vwEMAILS_PROJECT_TASKS' and MODULE_NAME_RELATED = 'Tasks') begin -- then
	update SYSTEM_REST_TABLES
	   set MODULE_NAME_RELATED = 'ProjectTask'
	     , DATE_MODIFIED       = getdate()
	     , DATE_MODIFIED_UTC   = getdate()
	     , MODIFIED_USER_ID    = null
	 where TABLE_NAME          = 'vwEMAILS_PROJECT_TASKS'
	   and MODULE_NAME_RELATED = 'Tasks'
	   and DELETED             = 0;
end -- if;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_PROJECTS'                 , 'vwEMAILS_PROJECTS'               , 'Emails'                   , 'Project'                  , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_PROSPECTS'                , 'vwEMAILS_PROSPECTS'              , 'Emails'                   , 'Prospects'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_TASKS'                    , 'vwEMAILS_TASKS'                  , 'Emails'                   , 'Tasks'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwEMAILS_USERS'                    , 'vwEMAILS_USERS'                  , 'Emails'                   , 'Users'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwKBDOCUMENTS_CASES'               , 'vwKBDOCUMENTS_CASES'             , 'KBDocuments'              , 'Cases'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_ACTIVITIES'                , 'vwLEADS_ACTIVITIES'              , 'Leads'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_ACTIVITIES_HISTORY'        , 'vwLEADS_ACTIVITIES_HISTORY'      , 'Leads'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_ACTIVITIES_OPEN'           , 'vwLEADS_ACTIVITIES_OPEN'         , 'Leads'                    , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_DOCUMENTS'                 , 'vwLEADS_DOCUMENTS'               , 'Leads'                    , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_PROSPECT_LISTS'            , 'vwLEADS_PROSPECT_LISTS'          , 'Leads'                    , 'ProspectLists'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_USERS'                     , 'vwLEADS_USERS'                   , 'Leads'                    , 'Users'                    , 0, null, 0, 0, null, 1;
-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_CONTACTS'                  , 'vwLEADS_CONTACTS'                , 'Leads'                    , 'Contacts'                 , 0, null, 0, 0, null, 1;
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_OPPORTUNITIES'             , 'vwLEADS_OPPORTUNITIES'           , 'Leads'                    , 'Opportunities'            , 0, null, 0, 0, null, 1;


exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMEETINGS_CONTACTS'               , 'vwMEETINGS_CONTACTS'             , 'Meetings'                 , 'Contacts'                 , 0, null, 0, 0, null, 1;
-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMEETINGS_LEADS'                  , 'vwMEETINGS_LEADS'                , 'Meetings'                 , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMEETINGS_USERS'                  , 'vwMEETINGS_USERS'                , 'Meetings'                 , 'Users'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwNOTE_ATTACHMENTS'                , 'vwNOTE_ATTACHMENTS'              , 'Notes'                    , null                       , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_ACTIVITIES'        , 'vwOPPORTUNITIES_ACTIVITIES'      , 'Opportunities'            , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_ACTIVITIES_HISTORY', 'vwOPPORTUNITIES_ACTIVITIES_HISTORY', 'Opportunities'          , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_ACTIVITIES_OPEN'   , 'vwOPPORTUNITIES_ACTIVITIES_OPEN' , 'Opportunities'            , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_CONTACTS'          , 'vwOPPORTUNITIES_CONTACTS'        , 'Opportunities'            , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_DOCUMENTS'         , 'vwOPPORTUNITIES_DOCUMENTS'       , 'Opportunities'            , 'Documents'                , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_LEADS'             , 'vwOPPORTUNITIES_LEADS'           , 'Opportunities'            , 'Leads'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_PROJECTS'          , 'vwOPPORTUNITIES_PROJECTS'        , 'Opportunities'            , 'Project'                  , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_CONTACTS'          , 'vwOPPORTUNITIES_CONTACTS'        , 'Opportunities'            , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_USERS'             , 'vwOPPORTUNITIES_USERS'           , 'Opportunities'            , 'Users'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECT_RELATION'                , 'vwPROJECT_RELATION'              , 'Project'                  , null                       , 0, null, 0, 0, null, 1;

-- 09/15/2012 Paul.  New tables for Accounts, Bugs, Cases, Contacts, Opportunities, ProjectTask, Threads, Quotes. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_ACTIVITIES'             , 'vwPROJECTS_ACTIVITIES'           , 'Project'                  , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_ACTIVITIES_HISTORY'     , 'vwPROJECTS_ACTIVITIES_HISTORY'   , 'Project'                  , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_ACTIVITIES_OPEN'        , 'vwPROJECTS_ACTIVITIES_OPEN'      , 'Project'                  , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_ACCOUNTS'               , 'vwPROJECTS_ACCOUNTS'             , 'Project'                  , 'Accounts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_BUGS'                   , 'vwPROJECTS_BUGS'                 , 'Project'                  , 'Bugs'                     , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_CASES'                  , 'vwPROJECTS_CASES'                , 'Project'                  , 'Cases'                    , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_CONTACTS'               , 'vwPROJECTS_CONTACTS'             , 'Project'                  , 'Contacts'                 , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_OPPORTUNITIES'          , 'vwPROJECTS_OPPORTUNITIES'        , 'Project'                  , 'Opportunities'            , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_PROJECT_TASKS'          , 'vwPROJECTS_PROJECT_TASKS'        , 'Project'                  , 'ProjectTask'              , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_USERS'                  , 'vwPROJECT_USERS'                 , 'Project'                  , 'Users'                    , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECT_TASKS_ACTIVITIES'        , 'vwPROJECT_TASKS_ACTIVITIES'      , 'ProjectTask'              , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECT_TASKS_ACTIVITIES_HISTORY', 'vwPROJECT_TASKS_ACTIVITIES_HISTORY', 'ProjectTask'            , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECT_TASKS_ACTIVITIES_OPEN'   , 'vwPROJECT_TASKS_ACTIVITIES_OPEN' , 'ProjectTask'              , 'Activities'               , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_ACTIVITIES'            , 'vwPROSPECTS_ACTIVITIES'          , 'Prospects'                , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_ACTIVITIES_HISTORY'    , 'vwPROSPECTS_ACTIVITIES_HISTORY'  , 'Prospects'                , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_ACTIVITIES_OPEN'       , 'vwPROSPECTS_ACTIVITIES_OPEN'     , 'Prospects'                , 'Activities'               , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_PROSPECT_LISTS'        , 'vwPROSPECTS_PROSPECT_LISTS'      , 'Prospects'                , 'ProspectLists'            , 0, null, 0, 0, null, 1;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LIST_CAMPAIGNS'         , 'vwPROSPECT_LIST_CAMPAIGNS'       , 'ProspectLists'            , 'Campaigns'                , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LISTS_PROSPECTS'        , 'vwPROSPECT_LISTS_PROSPECTS'      , 'ProspectLists'            , 'Prospects'                , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
if exists(select * from SYSTEM_REST_TABLES where TABLE_NAME = 'vwPROSPECT_LISTS_PROSPECTS' and MODULE_NAME_RELATED is null) begin -- then
	update SYSTEM_REST_TABLES
	   set MODULE_NAME_RELATED  = 'Prospects'
	     , REQUIRED_FIELDS      = 'PROSPECT_LIST_ID'
	     , MODIFIED_USER_ID     = null    
	     , DATE_MODIFIED        =  getdate()           
	     , DATE_MODIFIED_UTC    =  getutcdate()        
	 where TABLE_NAME           = 'vwPROSPECT_LISTS_PROSPECTS'
	   and MODULE_NAME_RELATED  is null
	   and DELETED              = 0;
end -- if;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LISTS_CONTACTS'         , 'vwPROSPECT_LISTS_CONTACTS'       , 'ProspectLists'            , 'Contacts'                 , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LISTS_LEADS'            , 'vwPROSPECT_LISTS_LEADS'          , 'ProspectLists'            , 'Leads'                    , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LISTS_USERS'            , 'vwPROSPECT_LISTS_USERS'          , 'ProspectLists'            , 'Users'                    , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
-- 04/14/2021 Paul.  Relatively new relationship for the React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECT_LISTS_ACCOUNTS'         , 'vwPROSPECT_LISTS_ACCOUNTS'       , 'ProspectLists'            , 'Accounts'                 , 0, null, 0, 0, null, 1, 'PROSPECT_LIST_ID';
if exists(select * from SYSTEM_REST_TABLES where TABLE_NAME like 'vwPROSPECT_LISTS_%' and REQUIRED_FIELDS is null) begin -- then
	update SYSTEM_REST_TABLES
	   set REQUIRED_FIELDS      = 'PROSPECT_LIST_ID'
	     , MODIFIED_USER_ID     = null    
	     , DATE_MODIFIED        =  getdate()           
	     , DATE_MODIFIED_UTC    =  getutcdate()        
	 where TABLE_NAME           like 'vwPROSPECT_LISTS_%'
	   and REQUIRED_FIELDS is null
	   and DELETED              = 0;
end -- if;

--exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_FEEDS'                     , 'vwUSERS_FEEDS'                   , 'Users'                    , 'Feeds'                    , 0, null, 0, 1, 'USER_ID', 1;
-- 09/15/2012 Paul.  Add UserSignatures. 
-- 06/27/2014 Paul.  User Signatures should not have MODULE_NAME_RELATED specified.  USER_ID will be a required field. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_SIGNATURES'                , 'vwUSERS_SIGNATURES'              , 'Users'                    , 'UserSignatures'           , 0, null, 0, 0, 'USER_ID', 1, 'USER_ID';
-- 05/28/2020 Paul.  The React Client needs to be able to save signatures.  Remove the USER_ID requirement so that it will be easy to view and edit.  Not so critical data that viewing all signatures would be a problem. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'USERS_SIGNATURES'                  , 'vwUSERS_SIGNATURES'              , 'UserSignatures'           , null                       , 0, null, 0, 0, null, 0, null;

-- 09/12/2019 Paul.  Users.ACLRoles is used in the React Client.  USER_ID will be a required field. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_ACL_ROLES'                 , 'vwUSERS_ACL_ROLES'               , 'Users'                    , null                       , 0, null, 0, 0, 'USER_ID', 1, 'USER_ID';
-- 09/13/2019 Paul.  Users.Logins is used in the React Client.  USER_ID will be a required field. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_LOGINS'                    , 'vwUSERS_LOGINS'                  , 'Users'                    , null                       , 0, null, 0, 0, 'USER_ID', 1, 'USER_ID';

-- 01/19/2013 Paul.  Activities need access to the vwPARENTS view in order to allow click through the parent link on the list view. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPARENTS'                         , 'vwPARENTS'                       , null                       , null                       , 0, null, 0, 0, 'PARENT_ASSIGNED_USER_ID', 1;
-- 10/12/2019 Paul.  Fix corrupt data. 
if exists(select * from SYSTEM_REST_TABLES where MODULE_NAME_RELATED = 'nulll') begin -- then
	update SYSTEM_REST_TABLES
	   set MODULE_NAME_RELATED  = null
	     , MODIFIED_USER_ID     = null    
	     , DATE_MODIFIED        =  getdate()           
	     , DATE_MODIFIED_UTC    =  getutcdate()        
	 where MODULE_NAME_RELATED  = 'nulll'
	   and DELETED              = 0;
end -- if;
GO

-- 02/23/2013 Paul.  In order to show the Calendar module, we need to enable it as a REST table. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'ACTIVITIES'                        , 'vwACTIVITIES_List'               , 'Calendar'                 , null                       , 0, null, 0, 1, null, 0;
-- 09/09/2019 Paul.  React client needs separate access to activities view. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACTIVITIES'                      , 'vwACTIVITIES'                    , 'Activities'               , null                       , 0, null, 0, 1, null, 0;

-- 11/17/2014 Paul.  Add ChatChannels module. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CHAT_CHANNELS'                     , 'vwCHAT_CHANNELS'                 , 'ChatChannels'             , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CHAT_MESSAGES'                     , 'vwCHAT_MESSAGES'                 , 'ChatMessages'             , null                       , 0, null, 0, 0, 'PARENT_ASSIGNED_USER_ID', 0;
-- 04/13/2021 Paul.  Missing tables. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCHAT_CHANNELS_CHAT_MESSAGES'     , 'vwCHAT_CHANNELS_CHAT_MESSAGES'   , 'ChatChannels'             , 'ChatMessages'             , 0, null, 0, 0, null, 1;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCHAT_CHANNELS_ATTACHMENTS'       , 'vwCHAT_CHANNELS_ATTACHMENTS'     , 'ChatChannels'             , 'Notes'                    , 0, null, 0, 0, null, 1;

-- delete from SYSTEM_REST_TABLES where TABLE_NAME = 'CHAT_DASHBOARD';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'CHAT_DASHBOARD'                    , 'vwCHAT_MESSAGES_List'            , 'ChatDashboard'            , null                       , 0, null, 0, 1, null, 0;
GO

-- 05/12/2017 Paul.  Add HTML5 Dashboard. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DASHBOARD_APPS'                    , 'vwDASHBOARD_APPS'                , null                       , null                       , 1, 'MODULE_NAME', 1, 0, null, 0;
-- update SYSTEM_REST_TABLES set ASSIGNED_FIELD_NAME = null, IS_ASSIGNED = 0, DATE_MODIFIED = getdate() where TABLE_NAME = 'DASHBOARDS' and ASSIGNED_FIELD_NAME = 'ASSIGNED_USER_ID'
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DASHBOARDS'                        , 'vwDASHBOARDS'                    , 'Dashboard'                , null                       , 0, null, 0, 0, null, 0;
-- delete from SYSTEM_REST_TABLES where TABLE_NAME = 'DASHBOARDS_PANELS';
-- update SYSTEM_REST_TABLES set ASSIGNED_FIELD_NAME = null, IS_ASSIGNED = 0, DATE_MODIFIED = getdate() where TABLE_NAME = 'DASHBOARDS_PANELS' and ASSIGNED_FIELD_NAME = 'PARENT_ASSIGNED_USER_ID'
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'DASHBOARDS_PANELS'                 , 'vwDASHBOARDS_PANELS'             , 'DashboardPanels'          , null                       , 1, 'MODULE_NAME', 0, 0, null, 0;

exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_ByLeadSource'      , 'vwOPPORTUNITIES_ByLeadSource'    , 'Opportunities'            , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_ByLeadOutcome'     , 'vwOPPORTUNITIES_ByLeadOutcome'   , 'Opportunities'            , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_Pipeline'          , 'vwOPPORTUNITIES_Pipeline'        , 'Opportunities'            , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_PipelineMonth'     , 'vwOPPORTUNITIES_PipelineMonth'   , 'Opportunities'            , null                       , 0, null, 0, 0, null, 0;

-- 06/13/2017 Paul.  HTML5 My Dashboard views. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACCOUNTS_MyList'                 , 'vwACCOUNTS_MyList'               , 'Accounts'                 , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUGS_MyList'                     , 'vwBUGS_MyList'                   , 'Bugs'                     , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCALLS_MyList'                    , 'vwCALLS_MyList'                  , 'Calls'                    , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCASES_MyList'                    , 'vwCASES_MyList'                  , 'Cases'                    , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_MyList'                 , 'vwCONTACTS_MyList'               , 'Contacts'                 , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_MyList'                    , 'vwLEADS_MyList'                  , 'Leads'                    , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMEETINGS_MyList'                 , 'vwMEETINGS_MyList'               , 'Meetings'                 , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwOPPORTUNITIES_MyList'            , 'vwOPPORTUNITIES_MyList'          , 'Opportunities'            , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTS_MyList'                 , 'vwPROJECTS_MyList'               , 'Project'                  , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROJECTTASKS_MyList'             , 'vwPROJECTTASKS_MyList'           , 'ProjectTask'              , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_MyList'                , 'vwPROSPECTS_MyList'              , 'Prospects'                , null                       , 0, null, 0, 0, null, 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwTASKS_MyList'                    , 'vwTASKS_MyList'                  , 'Tasks'                    , null                       , 0, null, 0, 0, null, 0;
GO

-- 07/31/2017 Paul.  Add My Favorites dashlets. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SUGARFAVORITES'                    , 'vwSUGARFAVORITES'                , null                       , null                       , 1, 'FAVORITE_MODULE', 0, 1, 'FAVORITE_USER_ID', 0;
-- 05/07/019 Paul.  Allow access to SAVED_SEARCH for the React client. 
-- delete from SYSTEM_REST_TABLES where TABLE_NAME = 'SAVED_SEARCH';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SAVED_SEARCH'                      , 'vwSAVED_SEARCH'                  , null                       , null                       , 0, 'SEARCH_MODULE', 0, 1, 'ASSIGNED_USER_ID', 0;

-- 09/17/2019 Paul.  Allow access to SystemLog for the React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SYSTEM_LOG'                        , 'vwSYSTEM_LOG'                    , 'SystemLog'                , null                       , 0, null, 1, 0, null, 0;
-- 03/10/2021 Paul.  Instead of allowing access to all tables to an admin, require that the table be registerd and admin acces to module. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SYSTEM_SYNC_LOG'                   , 'vwSYSTEM_SYNC_LOG'               , 'SystemSyncLog'            , null                       , 0, null, 1, 0, null, 0;
GO

-- 11/25/2020 Paul.  We need a way to call a generic procedure.  Security is still managed through SYSTEM_REST_TABLES. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spTERMINOLOGY_LIST_Insert'         , 'spTERMINOLOGY_LIST_Insert'       , 'Terminology'              , null                       , 0, null, 1, 0, null, 0, 'LANG LIST_NAME';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spTERMINOLOGY_LIST_Delete'         , 'spTERMINOLOGY_LIST_Delete'       , 'Terminology'              , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spTERMINOLOGY_LIST_MoveItem'       , 'spTERMINOLOGY_LIST_MoveItem'     , 'Terminology'              , null                       , 0, null, 1, 0, null, 0, 'LANG LIST_NAME';
-- 02/20/2021 Paul.  Configure Tabs. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_TAB_ORDER_MoveItem'      , 'spMODULES_TAB_ORDER_MoveItem'    , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'OLD_INDEX NEW_INDEX';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_TAB_Show'                , 'spMODULES_TAB_Show'              , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_TAB_Hide'                , 'spMODULES_TAB_Hide'              , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_TAB_ShowMobile'          , 'spMODULES_TAB_ShowMobile'        , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_TAB_HideMobile'          , 'spMODULES_TAB_HideMobile'        , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_Enable'                  , 'spMODULES_Enable'                , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_Disable'                 , 'spMODULES_Disable'               , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'ID';
-- 02/21/2021 Paul.  Languages. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spLANGUAGES_Enable'                 , 'spLANGUAGES_Enable'             , 'Languages'                , null                       , 0, null, 1, 0, null, 0, 'NAME';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spLANGUAGES_Disable'                , 'spLANGUAGES_Disable'            , 'Languages'                , null                       , 0, null, 1, 0, null, 0, 'NAME';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spLANGUAGES_Delete'                 , 'spLANGUAGES_Delete'             , 'Languages'                , null                       , 0, null, 1, 0, null, 0, 'NAME';

-- 01/19/2021 Paul.  System tables need by the React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwACL_ROLES_USERS'                 , 'vwACL_ROLES_USERS'               , 'ACLRoles'                 , 'Users'                    , 0, null, 1, 0, null, 1, null;
-- 01/29/2021 Paul.  Add EditCustomFields to React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwFIELDS_META_DATA_List'           , 'vwFIELDS_META_DATA_List'         , 'EditCustomFields'         , null                       , 0, null, 1, 0, null, 0, null;
-- 02/18/2021 Paul.  System tables need by the React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMODULES_RenameTabs'              , 'vwMODULES_RenameTabs'            , null                       , null                       , 0, null, 1, 0, null, 0, 'LANG';
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwMODULES_CONFIGURE_TABS'          , 'vwMODULES_CONFIGURE_TABS'        , null                       , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwSYSTEM_CURRENCY_LOG'             , 'vwSYSTEM_CURRENCY_LOG'           , null                       , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwBUSINESS_RULES'                  , 'vwBUSINESS_RULES'                , null                       , null                       , 0, null, 1, 0, null, 0, null;
GO

-- 03/11/2021 Paul.  All system tables will require registration. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'SCHEDULERS'                        , 'vwSCHEDULERS'                    , 'Schedulers'               , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'MODULES_ARCHIVE_RULES'             , 'vwMODULES_ARCHIVE_RULES'         , 'ModulesArchiveRules'      , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'USERS_LOGINS'                      , 'vwUSERS_LOGINS'                  , 'UserLogins'               , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'AUDIT_EVENTS'                      , 'vwAUDIT_EVENTS'                  , 'AuditEvents'              , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'FIELD_VALIDATORS'                  , 'vwFIELD_VALIDATORS'              , 'FieldValidators'          , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'NUMBER_SEQUENCES'                  , 'vwNUMBER_SEQUENCES'              , 'NumberSequences'          , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'FORUM_TOPICS'                      , 'vwFORUM_TOPICS'                  , 'ForumTopics'              , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'INBOUND_EMAILS'                    , 'vwINBOUND_EMAILS'                , 'InboundEmail'             , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'EMAILMAN'                          , 'vwEMAILMAN'                      , 'EmailMan'                 , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'OUTBOUND_SMS'                      , 'vwOUTBOUND_SMS'                  , 'OutboundSms'              , null                       , 0, null, 1, 0, null, 0, null;
-- 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spMODULES_UpdateRelativePath'    , 'spMODULES_UpdateRelativePath'    , 'Modules'                  , null                       , 0, null, 1, 0, null, 0, 'MODULE_NAME RELATIVE_PATH';

-- 09/09/2021 Paul.  System tables need by the React client. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwFULLTEXT_Properties'             , 'vwFULLTEXT_Properties'           , 'FullTextSearch'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwFULLTEXT_DOCUMENT_TYPES'         , 'vwFULLTEXT_DOCUMENT_TYPES'       , 'FullTextSearch'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwFULLTEXT_INDEXES'                , 'vwFULLTEXT_INDEXES'              , 'FullTextSearch'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwFULLTEXT_CATALOGS'               , 'vwFULLTEXT_CATALOGS'             , 'FullTextSearch'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spFULLTEXT_ConfigCatalog'          , 'spFULLTEXT_ConfigCatalog'        , 'FullTextSearch'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spSqlBackupDatabase'               , 'spSqlBackupDatabase'             , 'Administration'           , null                       , 0, null, 1, 0, null, 0, null;
-- 06/11/2023 Paul.  Add support for Purge Demo Data. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spSqlPurgeDemoData'                , 'spSqlPurgeDemoData'              , 'Administration'           , null                       , 0, null, 1, 0, null, 0, null;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'spSCHEDULERS_UpdateStatus'         , 'spSCHEDULERS_UpdateStatus'       , 'Schedulers'               , null                       , 0, null, 1, 0, null, 0, null;
GO

-- 02/05/2023 Paul.  The React Client needs to build the PopupSmsAddresses list manually. 
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwCONTACTS_SmsNumbers'             , 'vwCONTACTS_SmsNumbers'           , 'Contacts'                 , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwLEADS_SmsNumbers'                , 'vwLEADS_SmsNumbers'              , 'Leads'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwPROSPECTS_SmsNumbers'            , 'vwPROSPECTS_SmsNumbers'          , 'Prospects'                , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
exec dbo.spSYSTEM_REST_TABLES_InsertOnly null, 'vwUSERS_SmsNumbers'                , 'vwUSERS_SmsNumbers'              , 'Users'                    , null                       , 0, null, 0, 1, 'ASSIGNED_USER_ID', 0;
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

call dbo.spSYSTEM_REST_TABLES_Default()
/

call dbo.spSqlDropProcedure('spSYSTEM_REST_TABLES_Default')
/

-- #endif IBM_DB2 */

