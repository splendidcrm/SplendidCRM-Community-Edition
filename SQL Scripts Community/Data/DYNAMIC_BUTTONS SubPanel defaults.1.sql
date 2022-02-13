

print 'DYNAMIC_BUTTONS SubPanel defaults';

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 06/21/2010 Paul.  Remove the KEY data. 
-- 06/21/2010 Paul.  Add Search buttons. 
-- 10/14/2010 Paul.  Change Track Email to Archive Email. 
-- 03/15/2016 Paul.  Search Related. 

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Accounts SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.Open'        , 0, 'Accounts'        , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.Open'        , 1, 'Accounts'        , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.Open'        , 2, 'Accounts'        , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.Open'        , 3, 'Accounts'        , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.Open'        , 4, 'Accounts'        , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Activities.Open'        , 5, 'Accounts'        , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.History'     , 0, 'Accounts'        , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.History'     , 1, 'Accounts'        , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Activities.History'     , 2, 'Accounts'        , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Bugs'                   , 0, 'Accounts'        , 'edit', 'Bugs'            , 'edit', 'Bugs.Create'             , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Bugs'                   , 1, 'Accounts'        , 'edit', 'Bugs'            , 'list', 'BugPopup();'             , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Bugs'                   , 2, 'Accounts'        , 'view', 'Bugs'            , 'list', 'Bugs.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Cases'                  , 0, 'Accounts'        , 'edit', 'Cases'           , 'edit', 'Cases.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Cases'                  , 1, 'Accounts'        , 'edit', 'Cases'           , 'list', 'CasePopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Cases'                  , 2, 'Accounts'        , 'view', 'Cases'           , 'list', 'Cases.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Contacts'               , 0, 'Accounts'        , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Contacts'               , 1, 'Accounts'        , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Contacts'               , 2, 'Accounts'        , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MemberOrganizations'    , 0, 'Accounts'        , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.MemberOrganizations'    , 1, 'Accounts'        , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MemberOrganizations'    , 2, 'Accounts'        , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Opportunities'          , 0, 'Accounts'        , 'edit', 'Opportunities'   , 'edit', 'Opportunities.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Opportunities'          , 1, 'Accounts'        , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Opportunities'          , 2, 'Accounts'        , 'view', 'Opportunities'   , 'list', 'Opportunities.Search'    , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Project'                , 0, 'Accounts'        , 'edit', 'Project'         , 'edit', 'Project.Create'          , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Project'                , 1, 'Accounts'        , 'view', 'Project'         , 'list', 'Project.Search'          , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Accounts.ProspectLists';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.ProspectLists'         , 0, 'Accounts'         , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.ProspectLists'         , 1, 'Accounts'         , 'edit', 'ProspectLists'   , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.Documents'              , 0, 'Accounts'        , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Documents'              , 1, 'Accounts'        , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 03/24/2011 Paul.  Not sure why Bugs.Accounts buttons were not created earlier, but add them now. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Bugs SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.Open'            , 0, 'Bugs'            , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.Open'            , 1, 'Bugs'            , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.Open'            , 2, 'Bugs'            , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.Open'            , 3, 'Bugs'            , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.Open'            , 4, 'Bugs'            , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Activities.Open'            , 5, 'Bugs'            , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.History'         , 0, 'Bugs'            , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.History'         , 1, 'Bugs'            , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Activities.History'         , 2, 'Bugs'            , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Cases'                      , 0, 'Bugs'            , 'edit', 'Cases'           , 'edit', 'Cases.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Cases'                      , 1, 'Bugs'            , 'edit', 'Cases'           , 'list', 'CasePopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Cases'                      , 2, 'Bugs'            , 'view', 'Cases'           , 'list', 'Cases.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Contacts'                   , 0, 'Bugs'            , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Contacts'                   , 1, 'Bugs'            , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Contacts'                   , 2, 'Bugs'            , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Accounts'                   , 0, 'Bugs'            , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Accounts'                   , 1, 'Bugs'            , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Accounts'                   , 2, 'Bugs'            , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end else begin
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.Accounts' and COMMAND_NAME like '%.Create' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Accounts'                   , 0, 'Bugs'            , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
		exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Accounts'                   , 1, 'Bugs'            , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Accounts'                   , 2, 'Bugs'            , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	end -- if;
end -- if;
GO

-- 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.Documents'                  , 0, 'Bugs'            , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Documents'                  , 1, 'Bugs'            , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Calls.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then                                                       
	print 'DYNAMIC_BUTTONS Calls SubPanel';                                                                                                                         
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.Contacts'                  , 0, 'Calls'           , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Calls.Contacts'                  , 1, 'Calls'           , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.Contacts'                  , 2, 'Calls'           , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.Notes'                     , 0, 'Calls'           , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.Notes'                     , 1, 'Calls'           , 'view', 'Notes'           , 'list', 'Notes.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.CampaignTrackers' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.CampaignTrackers'      , 0, 'Campaigns'       , 'edit', 'CampaignTrackers', 'edit', 'CampaignTrackers.Create' , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.EmailMarketing'        , 0, 'Campaigns'       , 'edit', 'EmailMarketing'  , 'edit', 'EmailMarketing.Create'   , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Campaigns.EmailMarketing'        , 1, 'Campaigns'       , 'edit', 'EmailMarketing'  , 'edit', 'CampaignPreview();'      , null, 'Campaigns.LBL_PREVIEW_BUTTON_LABEL'          , 'Campaigns.LBL_PREVIEW_BUTTON_TITLE'          , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.ProspectLists'         , 0, 'Campaigns'       , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Campaigns.ProspectLists'         , 1, 'Campaigns'       , 'edit', 'ProspectLists'   , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 08/27/2012 Paul.  Add CallMarketing modules. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.CallMarketing' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.CallMarketing SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.CallMarketing'         , 0, 'Campaigns'       , 'edit', 'CallMarketing'   , 'edit', 'CallMarketing.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
end -- if;
GO

-- 05/16/2010 Paul.  The preview buttons were not getting created on older systems. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.PreviewView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.PreviewView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.PreviewView'           , 0, 'Campaigns'       , 'edit', null              , null  , 'Preview.Production'      , null, 'Campaigns.LBL_PREVIEW_PRODUCTION_LABEL'      , 'Campaigns.LBL_PREVIEW_PRODUCTION_TITLE'      , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.PreviewView'           , 1, 'Campaigns'       , 'edit', null              , null  , 'Preview.Test'            , null, 'Campaigns.LBL_PREVIEW_TEST_LABEL'            , 'Campaigns.LBL_PREVIEW_TEST_TITLE'            , null, null, null;
end -- if;
GO

-- 08/22/2012 Paul.  Allow prospect list to be created from the tracked users. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.Trackers' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.Trackers'              , 0, 'Campaigns'       , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, 'Campaigns.LNK_NEW_PROSPECT_LIST'             , 'Campaigns.LNK_NEW_PROSPECT_LIST'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackBlocked'     , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackClickThru'   , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackContacts'    , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackInvalidEmail', 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackLeads'       , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackRemoved'     , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackSendError'   , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackTargeted'    , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.TrackViewed'      , 'Campaigns';
	exec dbo.spDYNAMIC_BUTTONS_CopyDefault  'Campaigns.Trackers', 'Campaigns.Leads'            , 'Campaigns';
end -- if;
GO

-- 04/10/2013 Paul.  Add Projects relationship to Cases. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.Project' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Cases SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.Open'           , 0, 'Cases'           , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.Open'           , 1, 'Cases'           , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.Open'           , 2, 'Cases'           , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.Open'           , 3, 'Cases'           , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.Open'           , 4, 'Cases'           , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Activities.Open'           , 5, 'Cases'           , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.History'        , 0, 'Cases'           , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.History'        , 1, 'Cases'           , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Activities.History'        , 2, 'Cases'           , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Bugs'                      , 0, 'Cases'           , 'edit', 'Bugs'            , 'edit', 'Bugs.Create'             , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Bugs'                      , 1, 'Cases'           , 'edit', 'Bugs'            , 'list', 'BugPopup();'             , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Bugs'                      , 2, 'Cases'           , 'view', 'Bugs'            , 'list', 'Bugs.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Contacts'                  , 0, 'Cases'           , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Contacts'                  , 1, 'Cases'           , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Contacts'                  , 2, 'Cases'           , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Project'                   , 0, 'Cases'           , 'edit', 'Project'         , 'edit', 'Project.Create'          , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Project'                   , 1, 'Cases'           , 'edit', 'Project'         , 'list', 'ProjectPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Project'                   , 2, 'Cases'           , 'view', 'Project'         , 'list', 'Project.Search'          , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end else begin
	-- 05/28/2008 Paul.  Fix access rights for DYNAMIC_BUTTONS Cases.* 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME like 'Cases.%' and MODULE_NAME = 'Campaigns') begin -- then
		print 'Fix access rights for DYNAMIC_BUTTONS Cases.* ';
		update DYNAMIC_BUTTONS
		   set MODULE_NAME      = 'Cases'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where VIEW_NAME        like 'Cases.%'
		   and MODULE_NAME      = 'Campaigns'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.Documents'                 , 0, 'Cases'           , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Documents'                 , 1, 'Cases'           , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 08/11/2014 Paul. Add buttons for Sms Messages. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.Bugs' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Contacts SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 0, 'Contacts'        , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 1, 'Contacts'        , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 2, 'Contacts'        , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 3, 'Contacts'        , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 4, 'Contacts'        , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 5, 'Contacts'        , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Activities.Open'        , 6, 'Contacts'        , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.History'     , 0, 'Contacts'        , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.History'     , 1, 'Contacts'        , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.History'     , 2, 'Contacts'        , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Bugs'                   , 0, 'Contacts'        , 'edit', 'Bugs'            , 'edit', 'Bugs.Create'             , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Bugs'                   , 1, 'Contacts'        , 'edit', 'Bugs'            , 'list', 'BugPopup();'             , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Bugs'                   , 2, 'Contacts'        , 'view', 'Bugs'            , 'list', 'Bugs.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Cases'                  , 0, 'Contacts'        , 'edit', 'Cases'           , 'edit', 'Cases.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Cases'                  , 1, 'Contacts'        , 'edit', 'Cases'           , 'list', 'CasePopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Cases'                  , 2, 'Contacts'        , 'view', 'Cases'           , 'list', 'Cases.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.DirectReports'          , 0, 'Contacts'        , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.DirectReports'          , 1, 'Contacts'        , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.DirectReports'          , 2, 'Contacts'        , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Opportunities'          , 0, 'Contacts'        , 'edit', 'Opportunities'   , 'edit', 'Opportunities.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Opportunities'          , 1, 'Contacts'        , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Opportunities'          , 2, 'Contacts'        , 'view', 'Opportunities'   , 'list', 'Opportunities.Search'    , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Project'                , 0, 'Contacts'        , 'edit', 'Project'         , 'edit', 'Project.Create'          , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Project'                , 1, 'Contacts'        , 'view', 'Project'         , 'list', 'Project.Search'          , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end else begin
	-- 08/11/2014 Paul. Add buttons for Sms Messages. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.Activities.Open' and COMMAND_NAME like 'SmsMessages.Create' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Contacts.Activities.Open: Add SmsMessages.Create. ';
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Contacts.Activities.Open'
		   and CONTROL_INDEX     >= 4
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Activities.Open'        , 4, 'Contacts'       , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	end -- if;
	-- 08/11/2014 Paul.  Cleanup access rights for SearchOpen. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.Activities.Open' and COMMAND_NAME = 'Activities.SearchOpen' and TARGET_NAME is not null and TARGET_ACCESS_TYPE is not null and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Contacts.Activities.Open: Cleanup access rights for SearchOpen. ';
		update DYNAMIC_BUTTONS
		   set TARGET_NAME        = null
		     , TARGET_ACCESS_TYPE = null
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Contacts.Activities.Open'
		   and COMMAND_NAME       = 'Activities.SearchOpen'
		   and TARGET_NAME        is not null
		   and TARGET_ACCESS_TYPE is not null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 10/18/2011 Paul.  Show prospect lists within Contacts, Leads and Prospects. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Contacts.ProspectLists';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.ProspectLists'         , 0, 'Contacts'         , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.ProspectLists'         , 1, 'Contacts'         , 'edit', 'ProspectLists'   , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.Documents'              , 0, 'Contacts'        , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Documents'              , 1, 'Contacts'        , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.DocumentRevisions' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents.DocumentRevisions SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Documents.DocumentRevisions'     , 0, 'Documents'       , 'edit', 'Documents'       , 'edit', 'Documents.CreateRevision', null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
end -- if;
GO

-- 02/04/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.Accounts' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents.Accounts SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Documents.Accounts'              , 0, 'Documents'       , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.Contacts' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents.Contacts SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Documents.Contacts'              , 0, 'Documents'       , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.Leads' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents.Leads SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Documents.Leads'                 , 0, 'Documents'       , 'edit', 'Leads'           , 'list', 'LeadPopup();'           , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.Opportunities' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents.Opportunities SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Documents.Opportunities'         , 0, 'Documents'       , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 12/04/2008 Paul.  ProspectList needs a Select button, not a Create button. 
-- 01/26/2020 Paul.  Target needs to have plural module name, ProspectLists. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMarketing.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailMarketing SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'EmailMarketing.ProspectLists'    , 0, 'EmailMarketing'  , 'edit', 'ProspectLists'    , 'list', 'ProspectListPopup();return false'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMarketing.ProspectLists' and COMMAND_NAME like 'ProspectListPopup();' and DELETED = 0) begin -- then
		print 'Fix EmailMarketing.ProspectLists popup.';
		update DYNAMIC_BUTTONS
		   set ONCLICK_SCRIPT    = 'ProspectListPopup();return false;'
		     , CONTROL_TEXT      = '.LBL_SELECT_BUTTON_LABEL'
		     , CONTROL_TOOLTIP   = '.LBL_SELECT_BUTTON_TITLE'
		     , CONTROL_ACCESSKEY = '.LBL_SELECT_BUTTON_KEY'
		     , COMMAND_NAME      = null
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'EmailMarketing.ProspectLists'
		   and COMMAND_NAME      = 'ProspectListPopup();'
		   and DELETED           = 0;
	end -- if;
	-- 01/26/2020 Paul.  Target needs to have plural module name, ProspectLists. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMarketing.ProspectLists' and TARGET_NAME like 'ProspectList' and DELETED = 0) begin -- then
		print 'Fix EmailMarketing.ProspectLists popup.';
		update DYNAMIC_BUTTONS
		   set TARGET_NAME       = 'ProspectLists'
		     , DATE_MODIFIED     = getdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'EmailMarketing.ProspectLists'
		   and TARGET_NAME       = 'ProspectList'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 08/27/2012 Paul.  Add CallMarketing modules. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'CallMarketing.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS CallMarketing SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'CallMarketing.ProspectLists'     , 0, 'CallMarketing'   , 'edit', 'ProspectList'    , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.Accounts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Accounts'                 , 0, 'Emails'          , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Accounts'                 , 1, 'Emails'          , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Accounts'                 , 2, 'Emails'          , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Bugs'                     , 0, 'Emails'          , 'edit', 'Bugs'            , 'edit', 'Bugs.Create'             , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Bugs'                     , 1, 'Emails'          , 'edit', 'Bugs'            , 'list', 'BugPopup();'             , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Bugs'                     , 2, 'Emails'          , 'view', 'Bugs'            , 'list', 'Bugs.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Cases'                    , 0, 'Emails'          , 'edit', 'Cases'           , 'edit', 'Cases.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Cases'                    , 1, 'Emails'          , 'edit', 'Cases'           , 'list', 'CasePopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Cases'                    , 2, 'Emails'          , 'view', 'Cases'           , 'list', 'Cases.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Contacts'                 , 0, 'Emails'          , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Contacts'                 , 1, 'Emails'          , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Contacts'                 , 2, 'Emails'          , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Leads'                    , 0, 'Emails'          , 'edit', 'Leads'           , 'edit', 'Leads.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Leads'                    , 1, 'Emails'          , 'edit', 'Leads'           , 'list', 'LeadPopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Leads'                    , 2, 'Emails'          , 'view', 'Leads'           , 'list', 'Leads.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Opportunities'            , 0, 'Emails'          , 'edit', 'Opportunities'   , 'edit', 'Opportunities.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Opportunities'            , 1, 'Emails'          , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Opportunities'            , 2, 'Emails'          , 'view', 'Opportunities'   , 'list', 'Opportunities.Search'    , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Project'                  , 0, 'Emails'          , 'edit', 'Project'         , 'edit', 'Project.Create'          , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Project'                  , 1, 'Emails'          , 'edit', 'Project'         , 'list', 'ProjectPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Project'                  , 2, 'Emails'          , 'view', 'Project'         , 'list', 'Project.Search'          , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.ProjectTask'              , 0, 'Emails'          , 'edit', 'ProjectTask'     , 'edit', 'ProjectTask.Create'      , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.ProjectTask'              , 1, 'Emails'          , 'edit', 'ProjectTask'     , 'list', 'ProjectTaskPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.ProjectTask'              , 2, 'Emails'          , 'view', 'ProjectTask'     , 'list', 'ProjectTask.Search'      , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.Users'                    , 0, 'Emails'          , 'edit', 'Users'           , 'edit', 'Users.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Emails.Users'                    , 1, 'Emails'          , 'edit', 'Users'           , 'list', 'UserPopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Activities.Open' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 0, 'Leads'           , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 1, 'Leads'           , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 2, 'Leads'           , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 3, 'Leads'           , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 4, 'Leads'           , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'           , 5, 'Leads'           , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.Activities.Open'           , 6, 'Leads'           , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.History'        , 0, 'Leads'           , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.History'        , 1, 'Leads'           , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.History'        , 2, 'Leads'           , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end else begin
	-- 08/11/2014 Paul. Add buttons for Sms Messages. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Activities.Open' and COMMAND_NAME like 'SmsMessages.Create' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Leads.Activities.Open: Add SmsMessages.Create. ';
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Leads.Activities.Open'
		   and CONTROL_INDEX     >= 4
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Activities.Open'        , 4, 'Leads'       , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	end -- if;
	-- 08/11/2014 Paul.  Cleanup access rights for SearchOpen. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Activities.Open' and COMMAND_NAME = 'Activities.SearchOpen' and TARGET_NAME is not null and TARGET_ACCESS_TYPE is not null and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Leads.Activities.Open: Cleanup access rights for SearchOpen. ';
		update DYNAMIC_BUTTONS
		   set TARGET_NAME        = null
		     , TARGET_ACCESS_TYPE = null
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Leads.Activities.Open'
		   and COMMAND_NAME       = 'Activities.SearchOpen'
		   and TARGET_NAME        is not null
		   and TARGET_ACCESS_TYPE is not null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 10/18/2011 Paul.  Show prospect lists within Contacts, Leads and Prospects. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads.ProspectLists';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.ProspectLists'            , 0, 'Leads'            , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.ProspectLists'            , 1, 'Leads'            , 'edit', 'ProspectLists'   , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Documents'                 , 0, 'Leads'           , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.Documents'                 , 1, 'Leads'           , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 08/07/2015 Paul.  Add Leads/Contacts relationship. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Contacts' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Contacts'                  , 0, 'Leads'           , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.Contacts'                  , 1, 'Leads'           , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Contacts'                  , 2, 'Leads'           , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;
end -- if;
GO

-- 11/03/2017 Paul.  Add Leads/Opportunities relationship. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.Opportunities' and COMMAND_NAME = 'Leads.Opportunities' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Opportunities'          , 0, 'Leads'        , 'edit', 'Opportunities'   , 'edit', 'Opportunities.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.Opportunities'          , 1, 'Leads'        , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.Opportunities'          , 2, 'Leads'        , 'view', 'Opportunities'   , 'list', 'Opportunities.Search'    , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Meetings.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Meetings SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Meetings.Contacts'               , 0, 'Meetings'        , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Meetings.Contacts'               , 1, 'Meetings'        , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Meetings.Contacts'               , 2, 'Meetings'        , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Opportunities SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.Open'   , 0, 'Opportunities'   , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.Open'   , 1, 'Opportunities'   , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.Open'   , 2, 'Opportunities'   , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.Open'   , 3, 'Opportunities'   , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.Open'   , 4, 'Opportunities'   , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Opportunities.Activities.Open'   , 5, 'Opportunities'   , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.History', 0, 'Opportunities'   , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.History', 1, 'Opportunities'   , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Activities.History', 2, 'Opportunities'   , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Contacts'          , 0, 'Opportunities'   , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Opportunities.Contacts'          , 1, 'Opportunities'   , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Contacts'          , 2, 'Opportunities'   , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Project'           , 0, 'Opportunities'   , 'edit', 'Project'         , 'edit', 'Project.Create'          , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Project'           , 1, 'Opportunities'   , 'view', 'Project'         , 'list', 'Project.Search'          , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 01/31/2012 Paul.  Add Documents relationship to Accounts, Contacts, Leads and Opportunities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.Documents' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.Documents'         , 0, 'Opportunities'   , 'edit', 'Documents'       , 'edit', 'Documents.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Opportunities.Documents'         , 1, 'Opportunities'   , 'edit', 'Documents'       , 'list', 'DocumentPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Products.Notes' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Products SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Products.Notes'                  , 0, 'Products'        , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Threads.LBL_NEW_BUTTON_LABEL'                , 'Threads.LBL_NEW_BUTTON_TITLE'                , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Products.Notes'                  , 1, 'Products'        , 'view', 'Notes'           , 'list', 'Notes.Search'             , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Products.RelatedProducts'        , 0, 'Products'        , 'edit', 'Products'        , 'list', 'ProductPopup();'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Project SubPanel';
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Accounts'                , 0, 'Project'         , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Project.Accounts'                , 0, 'Project'         , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Accounts'                , 1, 'Project'         , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.Open'         , 0, 'Project'         , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.Open'         , 1, 'Project'         , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.Open'         , 2, 'Project'         , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.Open'         , 3, 'Project'         , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Project.Activities.Open'         , 4, 'Project'         , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.History'      , 0, 'Project'         , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.History'      , 1, 'Project'         , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Activities.History'      , 2, 'Project'         , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Contacts'                , 0, 'Project'         , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Project.Contacts'                , 0, 'Project'         , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Contacts'                , 1, 'Project'         , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Opportunities'           , 0, 'Project'         , 'edit', 'Opportunities'   , 'edit', 'Opportunities.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Project.Opportunities'           , 1, 'Project'         , 'edit', 'Opportunities'   , 'list', 'OpportunityPopup();'     , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.Opportunities'           , 2, 'Project'         , 'view', 'Opportunities'   , 'list', 'Opportunities.Search'    , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.ProjectTask'             , 0, 'Project'         , 'edit', 'ProjectTask'     , 'edit', 'ProjectTask.Create'      , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.ProjectTask'             , 1, 'Project'         , 'view', 'ProjectTask'     , 'list', 'ProjectTask.Search'      , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.Activities.Open' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProjectTask SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.Open'     , 0, 'ProjectTask'     , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.Open'     , 1, 'ProjectTask'     , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.Open'     , 2, 'ProjectTask'     , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.Open'     , 3, 'ProjectTask'     , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.Open'     , 4, 'ProjectTask'     , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProjectTask.Activities.Open'     , 5, 'ProjectTask'     , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.History'  , 0, 'ProjectTask'     , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.History'  , 1, 'ProjectTask'     , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.Activities.History'  , 2, 'ProjectTask'     , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 09/06/2012 Paul.  Add missing buttons to Leads and Prospects. 
-- 09/06/2012 Paul.  Add import buttons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Contacts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProspectLists SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Contacts'          , 0, 'ProspectLists'   , 'edit', 'Contacts'        , 'edit', 'Contacts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Contacts'          , 1, 'ProspectLists'   , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Contacts'          , 2, 'ProspectLists'   , 'view', 'Contacts'        , 'list', 'Contacts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Contacts'          , 3, 'ProspectLists'   , 'edit', 'Contacts'        , 'edit', 'Contacts.Import'         , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Leads'             , 0, 'ProspectLists'   , 'edit', 'Leads'           , 'edit', 'Leads.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Leads'             , 1, 'ProspectLists'   , 'edit', 'Leads'           , 'list', 'LeadPopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Leads'             , 2, 'ProspectLists'   , 'view', 'Leads'           , 'list', 'Leads.Search'            , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Leads'             , 3, 'ProspectLists'   , 'edit', 'Leads'           , 'edit', 'Leads.Import'            , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , 0, 'ProspectLists'   , 'edit', 'Prospects'       , 'edit', 'Prospects.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Prospects'         , 1, 'ProspectLists'   , 'edit', 'Prospects'       , 'list', 'ProspectPopup();'        , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , 2, 'ProspectLists'   , 'view', 'Prospects'       , 'list', 'Prospects.Search'        , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , 3, 'ProspectLists'   , 'edit', 'Prospects'       , 'edit', 'Prospects.Import'        , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Users'             , 0, 'ProspectLists'   , 'edit', 'Users'           , 'list', 'UserPopup();'            , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end else begin
	-- 05/28/2008 Paul.  The Select button was not being inserted. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Contacts' and CONTROL_INDEX = 1 and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Contacts'          , 1, 'ProspectLists'   , 'edit', 'Contacts'        , 'list', 'ContactPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	end -- if;
	-- 09/06/2012 Paul.  Add missing buttons to Leads and Prospects. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Leads' and COMMAND_NAME = 'Leads.Create' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Leads'             , -1, 'ProspectLists'   , 'edit', 'Leads'           , 'edit', 'Leads.Create'            , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Prospects' and COMMAND_NAME = 'Prospects.Create' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , -1, 'ProspectLists'   , 'edit', 'Prospects'       , 'edit', 'Prospects.Create'        , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Prospects' and COMMAND_NAME = 'Prospects.Search' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , -1, 'ProspectLists'   , 'view', 'Prospects'       , 'list', 'Prospects.Search'        , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	end -- if;

	-- 09/06/2012 Paul.  Add import buttons. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Contacts' and COMMAND_NAME = 'Contacts.Import' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Contacts'          , -1, 'ProspectLists'   , 'edit', 'Contacts'        , 'edit', 'Contacts.Import'         , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Leads' and COMMAND_NAME = 'Leads.Import' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Leads'             , -1, 'ProspectLists'   , 'edit', 'Leads'           , 'edit', 'Leads.Import'            , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Prospects' and COMMAND_NAME = 'Prospects.Import' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Prospects'         , -1, 'ProspectLists'   , 'edit', 'Prospects'       , 'edit', 'Prospects.Import'        , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;
	end -- if;
end -- if;
GO

-- 10/27/2017 Paul.  Add Accounts as email source. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.Accounts' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Accounts'          , 0, 'ProspectLists'   , 'edit', 'Accounts'        , 'edit', 'Accounts.Create'         , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProspectLists.Accounts'          , 1, 'ProspectLists'   , 'edit', 'Accounts'        , 'list', 'AccountPopup();'         , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Accounts'          , 2, 'ProspectLists'   , 'view', 'Accounts'        , 'list', 'Accounts.Search'         , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.Accounts'          , 3, 'ProspectLists'   , 'edit', 'Accounts'        , 'edit', 'Accounts.Import'         , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.Activities.Open' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 0, 'Prospects'       , 'edit', 'Tasks'           , 'edit', 'Tasks.Create'            , null, 'Activities.LBL_NEW_TASK_BUTTON_LABEL'        , 'Activities.LBL_NEW_TASK_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 1, 'Prospects'       , 'edit', 'Meetings'        , 'edit', 'Meetings.Create'         , null, 'Activities.LBL_SCHEDULE_MEETING_BUTTON_LABEL', 'Activities.LBL_SCHEDULE_MEETING_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 2, 'Prospects'       , 'edit', 'Calls'           , 'edit', 'Calls.Create'            , null, 'Activities.LBL_SCHEDULE_CALL_BUTTON_LABEL'   , 'Activities.LBL_SCHEDULE_CALL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 3, 'Prospects'       , 'edit', 'Emails'          , 'edit', 'Emails.Compose'          , null, '.LBL_COMPOSE_EMAIL_BUTTON_LABEL'             , '.LBL_COMPOSE_EMAIL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 4, 'Prospects'       , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'       , 5, 'Prospects'       , 'view', null              , null  , 'Activities.SearchOpen'   , null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Prospects.Activities.Open'       , 6, 'Prospects'       , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.History'    , 0, 'Prospects'       , 'edit', 'Notes'           , 'edit', 'Notes.Create'            , null, 'Activities.LBL_NEW_NOTE_BUTTON_LABEL'        , 'Activities.LBL_NEW_NOTE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.History'    , 1, 'Prospects'       , 'edit', 'Emails'          , 'edit', 'Emails.Archive'          , null, 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'   , 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.History'    , 2, 'Prospects'       , 'view', 'Emails'          , 'list', 'Activities.SearchHistory', null, '.LBL_SEARCH_BUTTON_LABEL'                    , '.LBL_SEARCH_BUTTON_TITLE'                    , null, null, null;
end else begin
	-- 08/11/2014 Paul. Add buttons for Sms Messages. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.Activities.Open' and COMMAND_NAME like 'SmsMessages.Create' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Prospects.Activities.Open: Add SmsMessages.Create. ';
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Prospects.Activities.Open'
		   and CONTROL_INDEX     >= 4
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.Activities.Open'        , 4, 'Prospects'       , 'edit', 'SmsMessages'     , 'edit', 'SmsMessages.Create'      , null, 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , 'SmsMessages.LNK_NEW_SMS_MESSAGE'             , null, null, null;
	end -- if;
	-- 08/11/2014 Paul.  Cleanup access rights for SearchOpen. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.Activities.Open' and COMMAND_NAME = 'Activities.SearchOpen' and TARGET_NAME is not null and TARGET_ACCESS_TYPE is not null and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Prospects.Activities.Open: Cleanup access rights for SearchOpen. ';
		update DYNAMIC_BUTTONS
		   set TARGET_NAME        = null
		     , TARGET_ACCESS_TYPE = null
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Prospects.Activities.Open'
		   and COMMAND_NAME       = 'Activities.SearchOpen'
		   and TARGET_NAME        is not null
		   and TARGET_ACCESS_TYPE is not null
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 10/18/2011 Paul.  Show prospect lists within Contacts, Leads and Prospects. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.ProspectLists' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects.ProspectLists';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.ProspectLists'         , 0, 'Prospects'       , 'edit', 'ProspectLists'   , 'edit', 'ProspectLists.Create'    , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Prospects.ProspectLists'         , 1, 'Prospects'       , 'edit', 'ProspectLists'   , 'list', 'ProspectListPopup();'    , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.Users' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ACLRoles SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ACLRoles.Users'                  , 0, 'ACLRoles'        , 'edit', 'Users'           , 'edit', 'UserMultiSelect();'      , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.ACLRoles' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Users SubPanel';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Users.ACLRoles'                  , 0, 'Users'           , 'edit', 'ACLRoles'        , 'edit', 'RoleMultiSelect();'      , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;

	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Users.Teams'                     , 0, 'Users'           , 'edit', 'Teams'           , 'edit', 'TeamMultiSelect();'      , null, '.LBL_SELECT_BUTTON_LABEL'                    , '.LBL_SELECT_BUTTON_TITLE'                    , null, null, null;
end -- if;
GO

-- 11/22/2012 Paul.  EmailMan.Preview is created in DYNAMIC_BUTTONS DetailView defaults.1.sql. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.Preview' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailMan.Preview';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailMan.Preview'                , 0, null              , null    , null, null, 'Send'                , null, 'Emails.LBL_SEND_BUTTON_LABEL'                , 'Emails.LBL_SEND_BUTTON_TITLE'                , 'Emails.LBL_SEND_BUTTON_KEY'                , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailMan.Preview'                , 1, null              , null    , null, null, 'Delete'              , null, '.LBL_DELETE_BUTTON_LABEL'                    , '.LBL_DELETE_BUTTON_TITLE'                    , '.LBL_DELETE_BUTTON_KEY'                    , 'return ConfirmDelete();', null;
end -- if;
*/
GO

-- 11/22/2012 Paul.  InboundEmail.Mailbox is created in DYNAMIC_BUTTONS DetailView defaults.1.sql. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.Mailbox' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS InboundEmail.Mailbox';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 0, null              , null    , null, null, 'Mailbox.CheckMail'   , null, 'Emails.LBL_BUTTON_CHECK'                     , 'Emails.LBL_BUTTON_CHECK_TITLE'               , 'Emails.LBL_BUTTON_CHECK_KEY'                , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 1, null              , null    , null, null, 'Mailbox.CheckBounce' , null, 'Emails.LBL_BUTTON_BOUNCE'                    , 'Emails.LBL_BUTTON_BOUNCE_TITLE'              , 'Emails.LBL_BUTTON_BOUNCE_KEY'               , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 2, null              , null    , null, null, 'Mailbox.CheckInbound', null, 'Administration.LBL_OOTB_IE'                  , 'Administration.LBL_OOTB_IE'                  , '.LBL_DELETE_BUTTON_KEY'                     , null, null;
end -- if;
*/
GO


-- 04/28/2008 Paul.  Popups should return false so that the button does not actually submit the form. 
if exists(select * from DYNAMIC_BUTTONS where ONCLICK_SCRIPT like '%Popup();' and ONCLICK_SCRIPT not like '%return %') begin -- then
	print 'Popups should return false so that the button does not actually submit the form. ';
	update DYNAMIC_BUTTONS
	   set ONCLICK_SCRIPT = ONCLICK_SCRIPT + 'return false;'
	 where ONCLICK_SCRIPT like '%Popup();'
	   and ONCLICK_SCRIPT not like '%return %'
	   and DELETED = 0;
end -- if;
GO

-- 05/09/2008 Paul.  There should always be a return false in a popup. 
if exists(select * from DYNAMIC_BUTTONS where ONCLICK_SCRIPT in('CampaignPreview();', 'UserMultiSelect();', 'RoleMultiSelect();', 'TeamMultiSelect();') and ONCLICK_SCRIPT not like '%return %') begin -- then
	print 'Popups should return false so that the button does not actually submit the form. ';
	update DYNAMIC_BUTTONS
	   set ONCLICK_SCRIPT = ONCLICK_SCRIPT + 'return false;'
	 where ONCLICK_SCRIPT in('CampaignPreview();', 'UserMultiSelect();', 'RoleMultiSelect();', 'TeamMultiSelect();')
	   and ONCLICK_SCRIPT not like '%return %'
	   and DELETED = 0;
end -- if;
GO

-- 09/10/2012 Paul.  Add User Signatures. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.UserSignatures' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Users.UserSignatures';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Users.UserSignatures'            , 0, null              , null  , 'UserSignatures'  , 'edit', 'UserSignatures.Create'   , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , null, null, null;
end -- if;
GO

-- 10/14/2013 Paul.  LBL_TRACK_EMAIL_BUTTON_LABEL was replaced with LBL_ARCHIVE_EMAIL_BUTTON_LABEL. 
if exists(select * from DYNAMIC_BUTTONS where CONTROL_TEXT = 'Activities.LBL_TRACK_EMAIL_BUTTON_LABEL' and DELETED = 0) begin -- then
	print 'Fix Activities.LBL_TRACK_EMAIL_BUTTON_LABEL.';
	update DYNAMIC_BUTTONS
	   set CONTROL_TEXT      = 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_LABEL'
	     , CONTROL_TOOLTIP   = 'Activities.LBL_ARCHIVE_EMAIL_BUTTON_TITLE'
	     , CONTROL_ACCESSKEY = null
	     , COMMAND_NAME      = null
	     , DATE_MODIFIED     = getdate()
	     , MODIFIED_USER_ID  = null
	 where CONTROL_TEXT      = 'Activities.LBL_TRACK_EMAIL_BUTTON_LABEL'
	   and DELETED           = 0;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ChatChannels.ChatMessages' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ChatChannels.ChatMessages';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ChatChannels.ChatMessages'      , 0, 'ChatChannels', 'edit', 'ChatMessages'   , 'edit', 'ChatMessages.Create', null, '.LBL_NEW_BUTTON_LABEL', '.LBL_NEW_BUTTON_TITLE', null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ChatMessages.Notes' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then                                                       
	print 'DYNAMIC_BUTTONS ChatMessages SubPanel';                                                                                                                         
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ChatMessages.Notes'             , 0, 'ChatMessages', 'edit', 'Notes'          , 'edit', 'Notes.Create'       , null, '.LBL_NEW_BUTTON_LABEL'   , '.LBL_NEW_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ChatMessages.Notes'             , 1, 'ChatMessages', 'view', 'Notes'          , 'list', 'Notes.Search'       , null, '.LBL_SEARCH_BUTTON_LABEL', '.LBL_SEARCH_BUTTON_TITLE', null, null, null;
end -- if;
GO

-- 09/30/2015 Paul.  Add ActivityStream buttons. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'ActivityStream.Subpanel'
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ActivityStream.Subpanel' and COMMAND_NAME like '%.Search' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ActivityStream.Subpanel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ActivityStream.Subpanel'        , 0, 'Accounts'    , 'edit', 'ActivityStream' , 'edit', 'ActivityStream.Create', null, 'ActivityStream.LBL_POST_BUTTON', 'ActivityStream.LBL_POST_BUTTON', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ActivityStream.Subpanel'        , 1, 'Accounts'    , 'view', 'ActivityStream' , 'list', 'ActivityStream.Search', null, '.LBL_SEARCH_BUTTON_LABEL'      , '.LBL_SEARCH_BUTTON_TITLE'      , null, null, null;
end -- if;
GO

-- 03/15/2016 Paul.  Cleanup access rights for SearchOpen. 
if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME like '%.Activities.Open' and COMMAND_NAME = 'Activities.SearchOpen' and TARGET_NAME is not null and TARGET_ACCESS_TYPE is not null and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS %.Activities.Open: Cleanup access rights for SearchOpen. ';
	update DYNAMIC_BUTTONS
	   set TARGET_NAME        = null
	     , TARGET_ACCESS_TYPE = null
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC  = getutcdate()
	     , MODIFIED_USER_ID   = null
	 where VIEW_NAME          like '%.Activities.Open'
	   and COMMAND_NAME       = 'Activities.SearchOpen'
	   and TARGET_NAME        is not null
	   and TARGET_ACCESS_TYPE is not null
	   and DELETED          = 0;
end -- if;
GO

-- 03/15/2016 Paul.  Add links to related popup. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.Activities.Open' and ONCLICK_SCRIPT like 'ActivitiesRelatedPopup();%' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Accounts.Activities.Open'        , 5, 'Accounts'        , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Bugs.Activities.Open'            , 5, 'Bugs'            , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Cases.Activities.Open'           , 5, 'Cases'           , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Contacts.Activities.Open'        , 6, 'Contacts'        , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Leads.Activities.Open'           , 6, 'Leads'           , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Opportunities.Activities.Open'   , 5, 'Opportunities'   , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Project.Activities.Open'         , 4, 'Project'         , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'ProjectTask.Activities.Open'     , 5, 'ProjectTask'     , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     'Prospects.Activities.Open'       , 6, 'Prospects'       , 'view', 'Activities'      , 'list', 'ActivitiesRelatedPopup();', null, 'Activities.LBL_SEARCH_RELATED'               , 'Activities.LBL_SEARCH_RELATED'               , null, null, null;
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

call dbo.spDYNAMIC_BUTTONS_SubPanel()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_SubPanel')
/

-- #endif IBM_DB2 */

