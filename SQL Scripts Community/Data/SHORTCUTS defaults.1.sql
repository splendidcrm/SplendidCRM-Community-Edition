

print 'SHORTCUTS defaults';
-- delete SHORTCUTS
GO

set nocount on;
GO

-- 12/23/2007 Paul.  Use a separate IF for each module. 
-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 12/18/2015 Paul.  Change target module to ActivityStream so that we can disable on Portal. 


if not exists (select * from SHORTCUTS where MODULE_NAME = 'Home' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Contacts.LNK_NEW_CONTACT'              , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  1, 'Contacts', 'edit';
--	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Contacts.LBL_ADD_BUSINESSCARD'         , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  2, 'Contacts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Accounts.LNK_NEW_ACCOUNT'              , '~/Accounts/edit.aspx'                   , 'CreateAccounts.gif'      , 1,  3, 'Accounts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Leads.LNK_NEW_LEAD'                    , '~/Leads/edit.aspx'                      , 'CreateLeads.gif'         , 1,  4, 'Leads', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Opportunities.LNK_NEW_OPPORTUNITY'     , '~/Opportunities/edit.aspx'              , 'CreateOpportunities.gif' , 1,  5, 'Opportunities', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Cases.LNK_NEW_CASE'                    , '~/Cases/edit.aspx'                      , 'CreateCases.gif'         , 1,  6, 'Cases', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Bugs.LNK_NEW_BUG'                      , '~/Bugs/edit.aspx'                       , 'CreateBugs.gif'          , 1,  7, 'Bugs', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  8, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  9, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1, 10, 'Tasks', 'edit';
	-- 12/23/2007 Paul.  Add Compose Email. 
	exec dbo.spSHORTCUTS_InsertOnly null, 'Home'                  , 'Emails.LNK_NEW_SEND_EMAIL'             , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1, 11, 'Emails', 'edit';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Dashboard' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Contacts.LNK_NEW_CONTACT'              , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  1, 'Contacts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Accounts.LNK_NEW_ACCOUNT'              , '~/Accounts/edit.aspx'                   , 'CreateAccounts.gif'      , 1,  2, 'Accounts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Leads.LNK_NEW_LEAD'                    , '~/Leads/edit.aspx'                      , 'CreateLeads.gif'         , 1,  3, 'Leads', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Opportunities.LNK_NEW_OPPORTUNITY'     , '~/Opportunities/edit.aspx'              , 'CreateOpportunities.gif' , 1,  4, 'Opportunities', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Cases.LNK_NEW_CASE'                    , '~/Cases/edit.aspx'                      , 'CreateCases.gif'         , 1,  5, 'Cases', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dashboard'             , 'Bugs.LNK_NEW_BUG'                      , '~/Bugs/edit.aspx'                       , 'CreateBugs.gif'          , 1,  6, 'Bugs', 'edit';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'iFrames' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'iFrames'               , 'iFrames.LBL_ADD_SITE'                  , '~/iFrames/edit.aspx'                    , 'CreateiFrames.gif'       , 1,  1, 'iFrames', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'iFrames'               , 'iFrames.LBL_LIST_SITES'                , '~/iFrames/default.aspx'                 , 'iFrames.gif'             , 1,  2, 'iFrames', 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Calendar' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  4, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  5, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calendar'              , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  6, 'Tasks', 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Accounts' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , 'Accounts.LNK_NEW_ACCOUNT'              , '~/Accounts/edit.aspx'                   , 'CreateAccounts.gif'      , 1,  1, 'Accounts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , 'Accounts.LNK_ACCOUNT_LIST'             , '~/Accounts/default.aspx'                , 'Accounts.gif'            , 1,  2, 'Accounts', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , '.LBL_IMPORT'                           , '~/Accounts/import.aspx'                 , 'Import.gif'              , 1,  3, 'Accounts', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , '.LNK_ACTIVITY_STREAM'                  , '~/Accounts/stream.aspx'                 , 'ActivityStream.gif'      , 1,  4, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , 'Accounts.LNK_ARCHIVED_ACCOUNTS'        , '~/Accounts/default.aspx?ArchiveView=1'  , 'Accounts.gif'            , 1,  5, 'Accounts', 'archive';
end -- if;
GO

-- 06/19/2010 Paul.  Add Bugs Import. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Bugs' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , 'Bugs.LNK_NEW_BUG'                      , '~/Bugs/edit.aspx'                       , 'CreateBugs.gif'          , 1,  1, 'Bugs', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , 'Bugs.LNK_BUG_LIST'                     , '~/Bugs/default.aspx'                    , 'Bugs.gif'                , 1,  2, 'Bugs', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , '.LBL_IMPORT'                           , '~/Bugs/import.aspx'                     , 'Import.gif'              , 1,  3, 'Bugs', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , '.LNK_ACTIVITY_STREAM'                  , '~/Bugs/stream.aspx'                     , 'ActivityStream.gif'      , 1,  4, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , 'Bugs.LNK_ARCHIVED_BUGS'                , '~/Bugs/default.aspx?ArchiveView=1'      , 'Bugs.gif'                , 1,  5, 'Bugs', 'archive';
end -- if;
GO

-- 03/28/2009 Paul.  Fix Notes import.  It was pointing to the Notes list view.
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Activities' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Notes.LNK_NEW_NOTE'                    , '~/Notes/edit.aspx'                      , 'CreateNotes.gif'         , 1,  4, 'Notes', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Emails.LNK_NEW_EMAIL'                  , '~/Emails/edit.aspx?TYPE=archived'       , 'CreateEmails.gif'        , 1,  5, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  6, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  7, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  8, 'Tasks', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Notes.LNK_NOTE_LIST'                   , '~/Notes/default.aspx'                   , 'Notes.gif'               , 1,  9, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Emails.LNK_EMAIL_LIST'                 , '~/Emails/default.aspx'                  , 'Emails.gif'              , 1, 10, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Calendar.LNK_VIEW_CALENDAR'            , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1, 11, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Activities'            , 'Notes.LNK_IMPORT_NOTES'                , '~/Notes/import.aspx'                    , 'Import.gif'              , 1, 12, 'Notes', 'import';
end else begin
	if exists (select * from SHORTCUTS where MODULE_NAME = 'Activities' and DISPLAY_NAME = 'Notes.LNK_IMPORT_NOTES' and RELATIVE_PATH = '~/Notes/default.aspx' and DELETED = 0) begin -- then
		print 'Fixing Notes import';
		update SHORTCUTS
		   set RELATIVE_PATH    = '~/Notes/import.aspx'
		     , SHORTCUT_ACLTYPE = 'import'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'Activities'
		   and DISPLAY_NAME     = 'Notes.LNK_IMPORT_NOTES'
		   and RELATIVE_PATH    = '~/Notes/default.aspx'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Calls' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Notes.LNK_NEW_NOTE'                    , '~/Notes/edit.aspx'                      , 'CreateNotes.gif'         , 1,  4, 'Notes', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Emails.LNK_NEW_EMAIL'                  , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  5, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  6, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  7, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  8, 'Tasks', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Notes.LNK_NOTE_LIST'                   , '~/Notes/default.aspx'                   , 'Notes.gif'               , 1,  9, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Emails.LNK_EMAIL_LIST'                 , '~/Emails/default.aspx'                  , 'Emails.gif'              , 1, 10, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Calendar.LNK_VIEW_CALENDAR'            , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1, 11, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , '.LBL_IMPORT'                           , '~/Calls/import.aspx'                    , 'Import.gif'              , 1, 12, 'Calls', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Calls.LNK_ARCHIVED_CALLS'              , '~/Calls/default.aspx?ArchiveView=1'     , 'Calls.gif'               , 1, 13, 'Calls', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Cases' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , 'Cases.LNK_NEW_CASE'                    , '~/Cases/edit.aspx'                      , 'CreateCases.gif'         , 1,  1, 'Cases', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , 'Cases.LNK_CASE_LIST'                   , '~/Cases/default.aspx'                   , 'Cases.gif'               , 1,  2, 'Cases', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , '.LNK_ACTIVITY_STREAM'                  , '~/Cases/stream.aspx'                    , 'ActivityStream.gif'      , 1,  3, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , 'Cases.LNK_ARCHIVED_CASES'              , '~/Cases/default.aspx?ArchiveView=1'     , 'Cases.gif'               , 1,  4, 'Cases', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Contacts' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LNK_NEW_CONTACT'              , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  1, 'Contacts', 'edit';
--	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LBL_ADD_BUSINESSCARD'         , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  2, 'Contacts', 'edit';
--	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LNK_IMPORT_VCARD'             , '~/Contacts/edit.aspx'                   , 'CreateContacts.gif'      , 1,  3, 'Contacts', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LNK_CONTACT_LIST'             , '~/Contacts/default.aspx'                , 'Contacts.gif'            , 1,  4, 'Contacts', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , '.LBL_IMPORT'                           , '~/Contacts/import.aspx'                 , 'Import.gif'              , 1,  5, 'Contacts', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , '.LNK_ACTIVITY_STREAM'                  , '~/Contacts/stream.aspx'                 , 'ActivityStream.gif'      , 1,  6, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LNK_ARCHIVED_CONTACTS'        , '~/Contacts/default.aspx?ArchiveView=1'  , 'Contacts.gif'            , 1,  7, 'Contacts', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Emails' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_NEW_SEND_EMAIL'             , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  1, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_NEW_ARCHIVE_EMAIL'          , '~/Emails/edit.aspx?TYPE=archived'       , 'CreateEmails.gif'        , 1,  2, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_NEW_EMAIL_TEMPLATE'         , '~/EmailTemplates/edit.aspx'             , 'CreateEmails.gif'        , 1,  3, 'EmailTemplates', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_DRAFTS_EMAIL_LIST'          , '~/Emails/Drafts.aspx'                   , 'EmailFolder.gif'         , 1,  4, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_ALL_EMAIL_LIST'             , '~/Emails/default.aspx'                  , 'EmailFolder.gif'         , 1,  5, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_EMAIL_TEMPLATE_LIST'        , '~/EmailTemplates/default.aspx'          , 'EmailTemplates.gif'      , 1,  6, 'EmailTemplates', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'EmailClient.LNK_EMAIL_LIST'            , '~/EmailClient/default.aspx'             , 'EmailClient.gif'         , 1,  7, 'EmailClient', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_ARCHIVED_EMAILS'            , '~/Emails/default.aspx?ArchiveView=1'    , 'Emails.gif'              , 1,  8, 'Emails', 'archive';
end else begin
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'EmailClient.LNK_EMAIL_LIST'            , '~/EmailClient/default.aspx'             , 'EmailClient.gif'         , 1,  7, 'EmailClient', 'list';
	-- 11/27/2008 Paul.  Fix image for EmailTemplates. 
	if exists(select * from SHORTCUTS where MODULE_NAME = 'Emails' and RELATIVE_PATH = '~/EmailTemplates/default.aspx' and IMAGE_NAME = 'EmailReports.gif' and DELETED = 0) begin -- then
		update SHORTCUTS
		   set IMAGE_NAME       = 'EmailTemplates.gif'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'Emails'
		   and RELATIVE_PATH    = '~/EmailTemplates/default.aspx'
		   and IMAGE_NAME       = 'EmailReports.gif'
		   and DELETED          = 0;
	end -- if;	
end -- if;
GO

-- 08/01/2010 Paul.  Add shortcuts for EmailClient. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'EmailClient' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_NEW_SEND_EMAIL'             , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  1, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_NEW_ARCHIVE_EMAIL'          , '~/Emails/edit.aspx?TYPE=archived'       , 'CreateEmails.gif'        , 1,  2, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_NEW_EMAIL_TEMPLATE'         , '~/EmailTemplates/edit.aspx'             , 'CreateEmails.gif'        , 1,  3, 'EmailTemplates', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_DRAFTS_EMAIL_LIST'          , '~/Emails/Drafts.aspx'                   , 'EmailFolder.gif'         , 1,  4, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_ALL_EMAIL_LIST'             , '~/Emails/default.aspx'                  , 'EmailFolder.gif'         , 1,  5, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'Emails.LNK_EMAIL_TEMPLATE_LIST'        , '~/EmailTemplates/default.aspx'          , 'EmailTemplates.gif'      , 1,  6, 'EmailTemplates', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailClient'           , 'EmailClient.LNK_EMAIL_LIST'            , '~/EmailClient/default.aspx'             , 'EmailClient.gif'         , 1,  7, 'EmailClient', 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Leads' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , 'Leads.LNK_NEW_LEAD'                    , '~/Leads/edit.aspx'                      , 'CreateLeads.gif'         , 1,  1, 'Leads', 'edit';
--	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , 'Leads.LNK_IMPORT_VCARD'                , '~/Leads/edit.aspx'                      , 'CreateLeads.gif'         , 1,  2, 'Leads', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , 'Leads.LNK_LEAD_LIST'                   , '~/Leads/default.aspx'                   , 'Leads.gif'               , 1,  3, 'Leads', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , '.LBL_IMPORT'                           , '~/Leads/import.aspx'                    , 'Import.gif'              , 1,  4, 'Leads', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , '.LNK_ACTIVITY_STREAM'                  , '~/Leads/stream.aspx'                    , 'ActivityStream.gif'      , 1,  5, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , 'Leads.LNK_ARCHIVED_LEADS'              , '~/Leads/default.aspx?ArchiveView=1'     , 'Leads.gif'               , 1,  6, 'Leads', 'archive';
end -- if;
GO

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Meetings' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Notes.LNK_NEW_NOTE'                    , '~/Notes/edit.aspx'                      , 'CreateNotes.gif'         , 1,  4, 'Notes', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Emails.LNK_NEW_EMAIL'                  , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  5, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  6, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  7, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  8, 'Tasks', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Notes.LNK_NOTE_LIST'                   , '~/Notes/default.aspx'                   , 'Notes.gif'               , 1,  9, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Emails.LNK_EMAIL_LIST'                 , '~/Emails/default.aspx'                  , 'Emails.gif'              , 1, 10, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Calendar.LNK_VIEW_CALENDAR'            , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1, 11, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , '.LBL_IMPORT'                           , '~/Meetings/import.aspx'                 , 'Import.gif'              , 1, 12, 'Meetings', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Meetings.LNK_ARCHIVED_MEETINGS'        , '~/Meetings/default.aspx?ArchiveView=1'  , 'Meetings.gif'            , 1, 13, 'Meetings', 'archive';
end -- if;
GO

-- 03/04/2010 Paul.  Fix Notes import. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Notes' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_NEW_NOTE'                    , '~/Notes/edit.aspx'                      , 'CreateNotes.gif'         , 1,  4, 'Notes', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Emails.LNK_NEW_EMAIL'                  , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  5, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  6, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  7, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  8, 'Tasks', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_NOTE_LIST'                   , '~/Notes/default.aspx'                   , 'Notes.gif'               , 1,  9, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Emails.LNK_EMAIL_LIST'                 , '~/Emails/default.aspx'                  , 'Emails.gif'              , 1, 10, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Calendar.LNK_VIEW_CALENDAR'            , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1, 11, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_IMPORT_NOTES'                , '~/Notes/import.aspx'                    , 'Import.gif'              , 1, 12, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_ARCHIVED_NOTES'              , '~/Notes/default.aspx?ArchiveView=1'     , 'Notes.gif'               , 1, 13, 'Notes', 'archive';
end else begin
	if exists (select * from SHORTCUTS where MODULE_NAME = 'Notes' and DISPLAY_NAME = 'Notes.LNK_IMPORT_NOTES' and RELATIVE_PATH = '~/Notes/default.aspx' and DELETED = 0) begin -- then
		print 'Fixing Notes import';
		update SHORTCUTS
		   set RELATIVE_PATH    = '~/Notes/import.aspx'
		     , SHORTCUT_ACLTYPE = 'import'
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'Notes'
		   and DISPLAY_NAME     = 'Notes.LNK_IMPORT_NOTES'
		   and RELATIVE_PATH    = '~/Notes/default.aspx'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Opportunities' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , 'Opportunities.LNK_NEW_OPPORTUNITY'     , '~/Opportunities/edit.aspx'              , 'CreateOpportunities.gif' , 1,  1, 'Opportunities', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , 'Opportunities.LNK_OPPORTUNITY_LIST'    , '~/Opportunities/default.aspx'           , 'Opportunities.gif'       , 1,  2, 'Opportunities', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , '.LBL_IMPORT'                           , '~/Opportunities/import.aspx'            , 'Import.gif'              , 1,  3, 'Opportunities', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , '.LNK_ACTIVITY_STREAM'                  , '~/Opportunities/stream.aspx'            , 'ActivityStream.gif'      , 1,  4, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , 'Opportunities.LNK_ARCHIVED_OPPORTUNITIES', '~/Opportunities/default.aspx?ArchiveView=1', 'Opportunities.gif'  , 1,  5, 'Opportunities', 'archive';
end -- if;
GO

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Tasks' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Calls.LNK_NEW_CALL'                    , '~/Calls/edit.aspx'                      , 'CreateCalls.gif'         , 1,  1, 'Calls', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Meetings.LNK_NEW_MEETING'              , '~/Meetings/edit.aspx'                   , 'CreateMeetings.gif'      , 1,  2, 'Meetings', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Tasks.LNK_NEW_TASK'                    , '~/Tasks/edit.aspx'                      , 'CreateTasks.gif'         , 1,  3, 'Tasks', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Notes.LNK_NEW_NOTE'                    , '~/Notes/edit.aspx'                      , 'CreateNotes.gif'         , 1,  4, 'Notes', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Emails.LNK_NEW_EMAIL'                  , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  5, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Calls.LNK_CALL_LIST'                   , '~/Calls/default.aspx'                   , 'Calls.gif'               , 1,  6, 'Calls', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Meetings.LNK_MEETING_LIST'             , '~/Meetings/default.aspx'                , 'Meetings.gif'            , 1,  7, 'Meetings', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Tasks.LNK_TASK_LIST'                   , '~/Tasks/default.aspx'                   , 'Tasks.gif'               , 1,  8, 'Tasks', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Notes.LNK_NOTE_LIST'                   , '~/Notes/default.aspx'                   , 'Notes.gif'               , 1,  9, 'Notes', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Emails.LNK_EMAIL_LIST'                 , '~/Emails/default.aspx'                  , 'Emails.gif'              , 1, 10, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Calendar.LNK_VIEW_CALENDAR'            , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1, 11, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , '.LBL_IMPORT'                           , '~/Tasks/import.aspx'                    , 'Import.gif'              , 1, 12, 'Tasks', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Tasks.LNK_ARCHIVED_TASKS'              , '~/Tasks/default.aspx?ArchiveView=1'     , 'Tasks.gif'               , 1, 13, 'Tasks', 'archive';
end -- if;
GO

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
-- 12/04/2011 Paul.  Folder name is Projects. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Project' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_NEW_PROJECT'               , '~/Projects/edit.aspx'                   , 'CreateProject.gif'       , 1,  1, 'Project', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_PROJECT_LIST'              , '~/Projects/default.aspx'                , 'Project.gif'             , 1,  2, 'Project', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_NEW_PROJECT_TASK'          , '~/ProjectTasks/edit.aspx'               , 'CreateProjectTask.gif'   , 1,  3, 'ProjectTask', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_PROJECT_TASK_LIST'         , '~/ProjectTasks/default.aspx'            , 'ProjectTask.gif'         , 1,  4, 'ProjectTask', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , '.LBL_IMPORT'                           , '~/Projects/import.aspx'                 , 'Import.gif'              , 1,  5, 'Project', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_ARCHIVED_PROJECTS'         , '~/Projects/default.aspx?ArchiveView=1'  , 'Project.gif'             , 1,  6, 'Project', 'archive';
end -- if;
GO

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ProjectTask' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_NEW_PROJECT'               , '~/Projects/edit.aspx'                   , 'CreateProject.gif'        , 1,  1, 'Project', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_PROJECT_LIST'              , '~/Projects/default.aspx'                , 'Project.gif'              , 1,  2, 'Project', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_NEW_PROJECT_TASK'          , '~/ProjectTasks/edit.aspx'               , 'CreateProjectTask.gif'    , 1,  3, 'ProjectTask', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_PROJECT_TASK_LIST'         , '~/ProjectTasks/default.aspx'            , 'ProjectTask.gif'          , 1,  4, 'ProjectTask', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , '.LBL_IMPORT'                           , '~/ProjectTask/import.aspx'              , 'Import.gif'               , 1,  5, 'ProjectTask', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_ARCHIVED_PROJECT_TASKS'    , '~/ProjectTasks/default.aspx?ArchiveView=1', 'ProjectTask.gif'        , 1,  6, 'ProjectTask', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Documents' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , 'Documents.LNK_NEW_DOCUMENT'            , '~/Documents/edit.aspx'                  , 'CreateDocuments.gif'     , 1,  1, 'Documents', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , 'Documents.LNK_DOCUMENT_LIST'           , '~/Documents/default.aspx'               , 'Documents.gif'           , 1,  2, 'Documents', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , '.LNK_ACTIVITY_STREAM'                  , '~/Documents/stream.aspx'                , 'ActivityStream.gif'      , 1,  3, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , 'Documents.LNK_ARCHIVED_DOCUMENTS'      , '~/Documents/default.aspx?ArchiveView=1' , 'Documents.gif'           , 1,  4, 'Documents', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Employees' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Employees'             , 'Employees.LNK_NEW_EMPLOYEE'            , '~/Employees/edit.aspx'                  , 'CreateEmployees.gif'     , 1,  1, 'Employees', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Employees'             , 'Employees.LNK_EMPLOYEE_LIST'           , '~/Employees/default.aspx'               , 'Employees.gif'           , 1,  2, 'Employees', 'list';
end -- if;
GO

-- 03/13/2008 Paul.  Allow admin import into Users. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Users' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Users'                 , 'Users.LNK_NEW_USER'                    , '~/Users/edit.aspx'                      , 'CreateUsers.gif'         , 1,  1, 'Users', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Users'                 , 'Users.LNK_USER_LIST'                   , '~/Users/default.aspx'                   , 'Users.gif'               , 1,  2, 'Users', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Users'                 , '.LBL_IMPORT'                           , '~/Users/import.aspx'                    , 'Import.gif'              , 1,  3, 'Users', 'import';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Feeds' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Feeds'                 , 'Feeds.LNK_MY_FEED_LIST'                , '~/Feeds/MyFeeds.aspx'                   , 'Feeds.gif'               , 1,  1, 'Feeds', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Feeds'                 , 'Feeds.LNK_FEED_LIST'                   , '~/Feeds/default.aspx'                   , 'AllRSS.gif'              , 1,  2, 'Feeds', 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Administration' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Administration'        , 'Users.LNK_NEW_USER'                    , '~/Users/edit.aspx'                      , 'CreateUsers.gif'         , 1,  1, 'Users', 'edit';
end -- if;
GO

-- 08/05/2010 Paul.  Need to be able to create a release. 
-- delete from SHORTCUTS where MODULE_NAME = 'Releases';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Releases' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Releases'              , 'Releases.LBL_LIST_FORM_TITLE'          , '~/Administration/Releases/default.aspx' , 'Releases.gif'            , 1,  1, 'Releases', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Releases'              , 'Releases.LNK_NEW_RELEASE'              , '~/Administration/Releases/edit.aspx'    , 'Releases.gif'            , 1,  2, 'Releases', 'edit';
end else begin
	exec dbo.spSHORTCUTS_InsertOnly null, 'Releases'              , 'Releases.LNK_NEW_RELEASE'              , '~/Administration/Releases/edit.aspx'    , 'Releases.gif'            , 1,  2, 'Releases', 'edit';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Dropdown' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dropdown'              , 'Dropdown.LNK_NEW_DROPDOWN'             , '~/Administration/Dropdown/edit.aspx'    , 'CreateDropdown.gif'      , 1,  1, 'Dropdown', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Dropdown'              , 'Dropdown.LNK_DROPDOWNS'                , '~/Administration/Dropdown/default.aspx' , 'CreateDropdown.gif'      , 1,  2, 'Dropdown', 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'Campaigns' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_NEW_CAMPAIGN'            , '~/Campaigns/edit.aspx'                  , 'CreateCampaigns.gif'     , 1,  1, 'Campaigns', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_CAMPAIGN_LIST'           , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  2, 'Campaigns', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_NEW_PROSPECT_LIST'       , '~/ProspectLists/edit.aspx'              , 'CreateProspectLists.gif' , 1,  3, 'ProspectLists', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_PROSPECT_LIST_LIST'      , '~/ProspectLists/default.aspx'           , 'ProspectLists.gif'       , 1,  4, 'ProspectLists', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_NEW_PROSPECT'            , '~/Prospects/edit.aspx'                  , 'CreateProspects.gif'     , 1,  5, 'Prospects', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_PROSPECT_LIST'           , '~/Prospects/default.aspx'               , 'Prospects.gif'           , 1,  6, 'Prospects', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'EmailTemplates.LNK_NEW_EMAIL_TEMPLATE' , '~/EmailTemplates/edit.aspx'             , 'CreateEmails.gif'        , 1,  7, 'EmailTemplates', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'EmailTemplates.LNK_EMAIL_TEMPLATE_LIST', '~/EmailTemplates/default.aspx'          , 'EmailReports.gif'        , 1,  8, 'EmailTemplates', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Prospects.LNK_IMPORT_PROSPECT'         , '~/Prospects/import.aspx'                , 'Import.gif'              , 1,  9, 'Prospects', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , '.LNK_ACTIVITY_STREAM'                  , '~/Campaigns/stream.aspx'                , 'ActivityStream.gif'      , 1, 10, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'Campaigns.LNK_ARCHIVED_CAMPAIGNS'      , '~/Campaigns/default.aspx?ArchiveView=1' , 'Accounts.gif'            , 1, 11, 'Campaigns', 'archive';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'ProspectLists' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_NEW_CAMPAIGN'        , '~/Campaigns/edit.aspx'                  , 'CreateCampaigns.gif'     , 1,  1, 'Campaigns', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_CAMPAIGN_LIST'       , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  2, 'Campaigns', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_NEW_PROSPECT_LIST'   , '~/ProspectLists/edit.aspx'              , 'CreateProspectLists.gif' , 1,  3, 'ProspectLists', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_PROSPECT_LIST_LIST'  , '~/ProspectLists/default.aspx'           , 'ProspectLists.gif'       , 1,  4, 'ProspectLists', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_NEW_PROSPECT'        , '~/Prospects/edit.aspx'                  , 'CreateProspects.gif'     , 1,  5, 'Prospects', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_PROSPECT_LIST'       , '~/Prospects/default.aspx'               , 'Prospects.gif'           , 1,  6, 'Prospects', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , '.LNK_ACTIVITY_STREAM'                  , '~/ProspectLists/stream.aspx'            , 'ActivityStream.gif'      , 1,  7, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_ARCHIVED_PROSPECT_LISTS', '~/ProspectLists/default.aspx?ArchiveView=1', 'ProspectLists.gif' , 1,  8, 'ProspectLists', 'archive';
end -- if;
GO

-- 04/07/2008 Paul.  The Prospects import link was not enabled. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Prospects' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_NEW_CAMPAIGN'            , '~/Campaigns/edit.aspx'                  , 'CreateCampaigns.gif'     , 1,  1, 'Campaigns', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_CAMPAIGN_LIST'           , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  2, 'Campaigns', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_NEW_PROSPECT_LIST'       , '~/ProspectLists/edit.aspx'              , 'CreateProspectLists.gif' , 1,  3, 'ProspectLists', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_PROSPECT_LIST_LIST'      , '~/ProspectLists/default.aspx'           , 'ProspectLists.gif'       , 1,  4, 'ProspectLists', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_NEW_PROSPECT'            , '~/Prospects/edit.aspx'                  , 'CreateProspects.gif'     , 1,  5, 'Prospects', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_PROSPECT_LIST'           , '~/Prospects/default.aspx'               , 'Prospects.gif'           , 1,  6, 'Prospects', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , '.LBL_IMPORT'                           , '~/Prospects/import.aspx'                , 'Import.gif'              , 1,  7, 'Prospects', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , '.LNK_ACTIVITY_STREAM'                  , '~/Prospects/stream.aspx'                , 'ActivityStream.gif'      , 1,  8, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_ARCHIVED_PROSPECTS'      , '~/Prospects/default.aspx?ArchiveView=1' , 'Prospects.gif'           , 1,  9, 'Prospects', 'archive';
end else begin
	if exists (select * from SHORTCUTS where MODULE_NAME = 'Prospects' and SHORTCUT_ACLTYPE = 'import' and SHORTCUT_ENABLED = 0 and DELETED = 0) begin -- then
		print 'Enabling Prospects import';
		update SHORTCUTS
		   set SHORTCUT_ENABLED = 1
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where MODULE_NAME      = 'Prospects'
		   and SHORTCUT_ACLTYPE = 'import'
		   and SHORTCUT_ENABLED = 0
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'EmailTemplates' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_NEW_SEND_EMAIL'     , '~/Emails/edit.aspx'                     , 'CreateEmails.gif'        , 1,  1, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_NEW_ARCHIVE_EMAIL'  , '~/Emails/edit.aspx?TYPE=archived'       , 'CreateEmails.gif'        , 1,  2, 'Emails', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_NEW_EMAIL_TEMPLATE' , '~/EmailTemplates/edit.aspx'             , 'CreateEmails.gif'        , 1,  3, 'EmailTemplates', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_DRAFTS_EMAIL_LIST'  , '~/Emails/Drafts.aspx'                   , 'EmailFolder.gif'         , 1,  4, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_ALL_EMAIL_LIST'     , '~/Emails/default.aspx'                  , 'EmailFolder.gif'         , 1,  5, 'Emails', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_EMAIL_TEMPLATE_LIST', '~/EmailTemplates/default.aspx'          , 'EmailReports.gif'        , 1,  6, 'EmailTemplates', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , 'EmailTemplates.LNK_VIEW_CALENDAR'      , '~/Calendar/default.aspx'                , 'Calendar.gif'            , 1,  7, 'Calendar', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , '.LNK_ACTIVITY_STREAM'                  , '~/EmailTemplates/stream.aspx'           , 'ActivityStream.gif'      , 1,  8, 'ActivityStream'    , 'list';
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'EditCustomFields' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'EditCustomFields'      , 'EditCustomFields.LNK_SELECT_CUSTOM_FIELD'     , '~/Administration/EditCustomFields/default.aspx'         , 'Administration.gif'   , 1,  1, 'EditCustomFields'  , 'list';
end -- if;
GO

-- 09/08/2007 Paul.  All the relationships to be edited. 
-- 04/19/2010 Paul.  Add EditView Relationships. 
-- 02/28/2016 Paul.  Point to new layout editor. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'DynamicLayout' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_EDITOR'              , '~/Administration/DynamicLayout/html5/default.aspx'            , 'Administration.gif'   , 1,  1, 'DynamicLayout'     , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_DETAILVIEWS'         , '~/Administration/DynamicLayout/DetailViews/default.aspx'      , 'Administration.gif'   , 1,  2, 'DynamicLayout'     , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_EDITVIEWS'           , '~/Administration/DynamicLayout/EditViews/default.aspx'        , 'Administration.gif'   , 1,  3, 'DynamicLayout'     , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_GRIDVIEWS'           , '~/Administration/DynamicLayout/GridViews/default.aspx'        , 'Administration.gif'   , 1,  4, 'DynamicLayout'     , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_RELATIONSHIPS'       , '~/Administration/DynamicLayout/Relationships/default.aspx'    , 'Administration.gif'   , 1,  5, 'DynamicLayout'     , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_EDIT_RELATIONSHIPS'  , '~/Administration/DynamicLayout/EditRelationships/default.aspx', 'Administration.gif'   , 1,  6, 'DynamicLayout'     , 'edit';
end else begin
	if not exists (select * from SHORTCUTS where MODULE_NAME = 'DynamicLayout' and DISPLAY_NAME = 'DynamicLayout.LNK_LAYOUT_RELATIONSHIPS' and DELETED = 0) begin -- then
		exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_RELATIONSHIPS'       , '~/Administration/DynamicLayout/Relationships/default.aspx', 'Administration.gif'   , 1,  4, 'DynamicLayout'     , 'edit';
	end -- if;
	if not exists (select * from SHORTCUTS where MODULE_NAME = 'DynamicLayout' and DISPLAY_NAME = 'DynamicLayout.LNK_LAYOUT_EDIT_RELATIONSHIPS' and DELETED = 0) begin -- then
		exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_EDIT_RELATIONSHIPS'  , '~/Administration/DynamicLayout/EditRelationships/default.aspx', 'Administration.gif'   , 1,  5, 'DynamicLayout'     , 'edit';
	end -- if;
	if not exists (select * from SHORTCUTS where MODULE_NAME = 'DynamicLayout' and DISPLAY_NAME = 'DynamicLayout.LNK_LAYOUT_EDITOR' and DELETED = 0) begin -- then
		update SHORTCUTS
		   set SHORTCUT_ORDER    = SHORTCUT_ORDER + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where MODULE_NAME       = 'DynamicLayout'
		   and DELETED           = 0;
		exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicLayout'         , 'DynamicLayout.LNK_LAYOUT_EDITOR'              , '~/Administration/DynamicLayout/html5/default.aspx', 'Administration.gif'   , 1,  1, 'DynamicLayout'     , 'edit';
	end -- if;
end -- if;
GO

if not exists (select * from SHORTCUTS where MODULE_NAME = 'ACLRoles' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ACLRoles'              , 'ACLRoles.LIST_ROLES'                          , '~/Administration/ACLRoles/default.aspx'                 , 'Roles.gif'            , 1,  1, 'ACLRoles'          , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ACLRoles'              , 'ACLRoles.LIST_ROLES_BY_USER'                  , '~/Administration/ACLRoles/ByUser.aspx'                  , 'Roles.gif'            , 1,  2, 'ACLRoles'          , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ACLRoles'              , 'ACLRoles.LBL_CREATE_ROLE'                     , '~/Administration/ACLRoles/edit.aspx'                    , 'Roles.gif'            , 1,  3, 'ACLRoles'          , 'edit';
end -- if;
GO

-- 07/08/2007 Paul.  Add CampaignTrackers module. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'CampaignTrackers' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'CampaignTrackers'      , 'Campaigns.LNK_CAMPAIGN_LIST'           , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  1, 'Campaigns', 'list';
	-- 07/08/2007 Paul.  Add new shortcuts Campaigns. 
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'EmailTemplates.LNK_NEW_EMAIL_TEMPLATE' , '~/EmailTemplates/edit.aspx'             , 'CreateEmails.gif'        , 1,  7, 'EmailTemplates', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , 'EmailTemplates.LNK_EMAIL_TEMPLATE_LIST', '~/EmailTemplates/default.aspx'          , 'EmailReports.gif'        , 1,  8, 'EmailTemplates', 'list';
end -- if;
GO

-- 07/08/2007 Paul.  Add EmailMarketing module. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'EmailMarketing' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_NEW_CAMPAIGN'            , '~/Campaigns/edit.aspx'                  , 'CreateCampaigns.gif'     , 1,  1, 'Campaigns', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_CAMPAIGN_LIST'           , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  2, 'Campaigns', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_NEW_PROSPECT_LIST'       , '~/ProspectLists/edit.aspx'              , 'CreateProspectLists.gif' , 1,  3, 'ProspectLists', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_PROSPECT_LIST_LIST'      , '~/ProspectLists/default.aspx'           , 'ProspectLists.gif'       , 1,  4, 'ProspectLists', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_NEW_PROSPECT'            , '~/Prospects/edit.aspx'                  , 'CreateProspects.gif'     , 1,  5, 'Prospects', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMarketing'        , 'Campaigns.LNK_PROSPECT_LIST'           , '~/Prospects/default.aspx'               , 'Prospects.gif'           , 1,  6, 'Prospects', 'list';
end -- if;
GO

-- 08/28/2012 Paul.  Add Call Marketing. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'CallMarketing' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_NEW_CAMPAIGN'            , '~/Campaigns/edit.aspx'                  , 'CreateCampaigns.gif'     , 1,  1, 'Campaigns', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_CAMPAIGN_LIST'           , '~/Campaigns/default.aspx'               , 'Campaigns.gif'           , 1,  2, 'Campaigns', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_NEW_PROSPECT_LIST'       , '~/ProspectLists/edit.aspx'              , 'CreateProspectLists.gif' , 1,  3, 'ProspectLists', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_PROSPECT_LIST_LIST'      , '~/ProspectLists/default.aspx'           , 'ProspectLists.gif'       , 1,  4, 'ProspectLists', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_NEW_PROSPECT'            , '~/Prospects/edit.aspx'                  , 'CreateProspects.gif'     , 1,  5, 'Prospects', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CallMarketing'         , 'Campaigns.LNK_PROSPECT_LIST'           , '~/Prospects/default.aspx'               , 'Prospects.gif'           , 1,  6, 'Prospects', 'list';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'Terminology';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Terminology' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Terminology'           , 'Terminology.LBL_NEW_FORM_TITLE'             , '~/Administration/Terminology/edit.aspx'          , 'Terminology.gif', 1,  1, 'Terminology', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Terminology'           , 'Administration.LBL_MANAGE_TERMINOLOGY_TITLE', '~/Administration/Terminology/default.aspx'       , 'Terminology.gif', 1,  2, 'Terminology', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Terminology'           , '.LBL_IMPORT'                                , '~/Administration/Terminology/import.aspx'        , 'Import.gif'     , 1,  3, 'Terminology', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Terminology'           , 'Administration.LBL_IMPORT_TERMINOLOGY_TITLE', '~/Administration/Terminology/Import/default.aspx', 'Import.gif'     , 1,  4, 'Terminology', 'import';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'Shortcuts';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Shortcuts' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Shortcuts'             , 'Shortcuts.LNK_NEW_SHORTCUT'            , '~/Administration/Shortcuts/edit.aspx'     , 'CreateShortcuts.gif'   , 1,  1, 'Shortcuts' , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Shortcuts'             , 'Shortcuts.LNK_SHORTCUT_LIST'           , '~/Administration/Shortcuts/default.aspx'  , 'Shortcuts.gif'         , 1,  2, 'Shortcuts' , 'list';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'EmailMan'
if not exists (select * from SHORTCUTS where MODULE_NAME = 'EmailMan' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailMan'              , 'EmailMan.LNK_EMAIL_MAN_LIST'           , '~/Administration/EmailMan/default.aspx'   , 'EmailMan.gif'          , 1,  1, 'EmailMan' , 'edit';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'InboundEmail'
if not exists (select * from SHORTCUTS where MODULE_NAME = 'InboundEmail' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'InboundEmail'          , 'InboundEmail.LNK_LIST_MAILBOXES'       , '~/Administration/InboundEmail/default.aspx', 'InboundEmail.gif'      , 1,  1, 'InboundEmail', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'InboundEmail'          , 'InboundEmail.LNK_LIST_CREATE_NEW'      , '~/Administration/InboundEmail/edit.aspx'   , 'CreateMailboxes.gif'   , 1,  2, 'InboundEmail', 'edit';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'Schedulers'
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Schedulers' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Schedulers'            , 'Schedulers.LNK_LIST_SCHEDULER'         , '~/Administration/Schedulers/default.aspx'  , 'Schedulers.gif'        , 1,  1, 'Schedulers', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Schedulers'            , 'Schedulers.LNK_NEW_SCHEDULER'          , '~/Administration/Schedulers/edit.aspx'     , 'CreateScheduler.gif'   , 1,  2, 'Schedulers', 'edit';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'DynamicButtons';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'DynamicButtons' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicButtons'        , 'DynamicButtons.LNK_NEW_DYNAMIC_BUTTON' , '~/Administration/DynamicButtons/edit.aspx'     , 'CreateDynamicButtons.gif', 1,  1, 'DynamicButtons' , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'DynamicButtons'        , 'DynamicButtons.LNK_DYNAMIC_BUTTON_LIST', '~/Administration/DynamicButtons/default.aspx'  , 'DynamicButtons.gif'      , 1,  2, 'DynamicButtons' , 'list';
end -- if;
GO

-- 09/09/2009 Paul.  Allow direct editing of the module table. 
-- delete from SHORTCUTS where MODULE_NAME = 'Modules'
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Modules' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Modules'               , 'Modules.LBL_LIST_FORM_TITLE'           , '~/Administration/Modules/default.aspx'     , 'Administration.gif'    , 1,  1, 'Modules', 'list';
end -- if;
GO

-- 09/12/2009 Paul.  Allow editing of Field Validators. 
-- delete from SHORTCUTS where MODULE_NAME = 'FieldValidators';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'FieldValidators' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'FieldValidators'       , 'FieldValidators.LNK_NEW_FIELD_VALIDATOR' , '~/Administration/FieldValidators/edit.aspx'             , 'CreateFieldValidators.gif', 1,  1, 'FieldValidators', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'FieldValidators'       , 'FieldValidators.LNK_FIELD_VALIDATOR_LIST', '~/Administration/FieldValidators/default.aspx'          , 'FieldValidators.gif'      , 1,  2, 'FieldValidators', 'list';
end -- if;
GO

-- 03/03/2010 Paul.  We need a quick access to the config edit link. 
-- delete from SHORTCUTS where MODULE_NAME = 'Config';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Config' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Config'                , 'Config.LNK_NEW_CONFIG'                   , '~/Administration/Config/edit.aspx'                      , 'Config.gif'               , 1,  1, 'Config', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Config'                , 'Config.LNK_CONFIG_LIST'                  , '~/Administration/Config/default.aspx'                   , 'Config.gif'               , 1,  2, 'Config', 'list';
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'SmsMessages' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'SmsMessages'           , 'SmsMessages.LNK_NEW_SMS_MESSAGE'         , '~/SmsMessages/edit.aspx'                                , 'CreateSmsMessages.gif'    , 1,  1, 'SmsMessages', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'SmsMessages'           , 'SmsMessages.LNK_SMS_MESSAGES_LIST'       , '~/SmsMessages/default.aspx'                             , 'SmsMessages.gif'          , 1,  2, 'SmsMessages', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'SmsMessages'           , 'SmsMessages.LNK_ARCHIVED_SMS_MESSAGES'   , '~/SmsMessages/default.aspx?ArchiveView=1'               , 'SmsMessages.gif'          , 1,  3, 'SmsMessages', 'archive';
end -- if;
GO

-- 09/22/2013 Paul.  Add OutboundSms module. 
-- delete from SHORTCUTS where MODULE_NAME = 'OutboundSms';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'OutboundSms' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'OutboundSms'           , 'OutboundSms.LNK_NEW_OUTBOUND_SMS'        , '~/Administration/OutboundSms/edit.aspx'                 , 'CreateOutboundSms.gif'    , 1,  1, 'OutboundSms', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'OutboundSms'           , 'OutboundSms.LNK_OUTBOUND_SMS_LIST'       , '~/Administration/OutboundSms/default.aspx'              , 'OutboundSms.gif'          , 1,  2, 'OutboundSms', 'list';
end -- if;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module.
-- delete from SHORTCUTS where MODULE_NAME = 'TwitterMessages';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'TwitterMessages' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'TwitterMessages'       , 'TwitterMessages.LNK_NEW_TWITTER_MESSAGE'  , '~/TwitterMessages/edit.aspx'                            , 'CreateTwitterMessages.gif', 1,  1, 'TwitterMessages', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'TwitterMessages'       , 'TwitterMessages.LNK_TWITTER_MESSAGES_LIST', '~/TwitterMessages/default.aspx'                         , 'TwitterMessages.gif'      , 1,  2, 'TwitterMessages', 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'TwitterMessages'       , '.LBL_IMPORT'                              , '~/TwitterMessages/import.aspx'                          , 'Import.gif'               , 1,  3, 'TwitterMessages', 'import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'TwitterMessages'       , 'TwitterMessages.LNK_ARCHIVED_TWITTER_MESSAGES', '~/TwitterMessages/default.aspx?ArchiveView=1'       , 'TwitterMessages.gif'      , 1,  4, 'TwitterMessages', 'archive';
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
-- delete from SHORTCUTS where MODULE_NAME = 'ChatChannels';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ChatChannels' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatChannels'          , 'ChatChannels.LNK_CHAT_CHANNEL_LIST'       , '~/ChatChannels/default.aspx'                            , 'ChatChannels.gif'        , 1,  1, 'ChatChannels'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatChannels'          , 'ChatChannels.LNK_NEW_CHAT_CHANNEL'        , '~/ChatChannels/edit.aspx'                               , 'CreateChatChannels.gif'  , 1,  2, 'ChatChannels'    , 'edit';
end -- if;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'ChatMessages';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ChatMessages' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatMessages'          , 'ChatMessages.LNK_CHAT_MESSAGE_LIST'       , '~/ChatMessages/default.aspx'                            , 'ChatMessages.gif'        , 1,  1, 'ChatMessages'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatMessages'          , 'ChatMessages.LNK_NEW_CHAT_MESSAGE'        , '~/ChatMessages/edit.aspx'                               , 'CreateChatMessages.gif'  , 1,  2, 'ChatMessages'    , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatMessages'          , 'ChatMessages.LNK_ARCHIVED_CHAT_MESSAGES'  , '~/ChatMessages/default.aspx?ArchiveView=1'              , 'ChatMessages.gif'        , 1,  -1, 'ChatMessages'   , 'archive';
end -- if;
GO

-- 04/15/2016 Paul.  Add ZipCodes. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ZipCodes' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'ZipCodes'              , 'ZipCodes.LNK_NEW_ZIPCODE'                 , '~/Administration/ZipCodes/edit.aspx'                    , 'CreateZipCodes.gif'      , 1,  1, 'ZipCodes'        , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ZipCodes'              , 'ZipCodes.LNK_ZIPCODE_LIST'                , '~/Administration/ZipCodes/default.aspx'                 , 'ZipCodes.gif'            , 1,  2, 'ZipCodes'        , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ZipCodes'              , '.LBL_IMPORT'                              , '~/Administration/ZipCodes/import.aspx'                  , 'Import.gif'              , 1,  3, 'ZipCodes'        , 'import';
end -- if;
GO

-- 09/28/2015 Paul.  Add Activity Stream to all core modules. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Accounts' and DISPLAY_NAME = '.LNK_ACTIVITY_STREAM' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , '.LNK_ACTIVITY_STREAM'                  , '~/Accounts/stream.aspx'                 , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , '.LNK_ACTIVITY_STREAM'                  , '~/Contacts/stream.aspx'                 , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , '.LNK_ACTIVITY_STREAM'                  , '~/Leads/stream.aspx'                    , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , '.LNK_ACTIVITY_STREAM'                  , '~/Prospects/stream.aspx'                , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , '.LNK_ACTIVITY_STREAM'                  , '~/Opportunities/stream.aspx'            , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , '.LNK_ACTIVITY_STREAM'                  , '~/ProspectLists/stream.aspx'            , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Campaigns'             , '.LNK_ACTIVITY_STREAM'                  , '~/Campaigns/stream.aspx'                , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'EmailTemplates'        , '.LNK_ACTIVITY_STREAM'                  , '~/EmailTemplates/stream.aspx'           , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , '.LNK_ACTIVITY_STREAM'                  , '~/Bugs/stream.aspx'                     , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , '.LNK_ACTIVITY_STREAM'                  , '~/Cases/stream.aspx'                    , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , '.LNK_ACTIVITY_STREAM'                  , '~/Documents/stream.aspx'                , 'ActivityStream.gif'      , 1,  -1, 'ActivityStream'    , 'list';
end -- if;
GO

-- 12/18/2015 Paul.  Change target module to ActivityStream so that we can disable on Portal. 
if exists(select * from SHORTCUTS where DISPLAY_NAME = '.LNK_ACTIVITY_STREAM' and SHORTCUT_MODULE <> 'ActivityStream' and DELETED = 0) begin -- then
	update SHORTCUTS
	   set SHORTCUT_MODULE   = 'ActivityStream'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where DISPLAY_NAME      = '.LNK_ACTIVITY_STREAM'
	   and SHORTCUT_MODULE   <> 'ActivityStream'
	   and DELETED           = 0;
end -- if;
GO

-- 05/03/2016 Paul.  Full editing of currencies requires shortcuts.  But, we don't need to allow creation as the list is prepopulated. 
-- delete from SHORTCUTS where MODULE_NAME = 'Currencies';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Currencies' and DELETED = 0) begin -- then
--	exec dbo.spSHORTCUTS_InsertOnly null, 'Currencies'            , 'Currencies.LNK_NEW_CURRENCY'             , '~/Administration/Currencies/edit.aspx'                    , 'CreateCurrencies.gif'      , 1,  1, 'Currencies'   , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Currencies'            , 'Currencies.LNK_CURRENCY_LIST'            , '~/Administration/Currencies/default.aspx'                 , 'Currencies.gif'            , 1,  2, 'Currencies'   , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Currencies'            , 'CurrencyLayer.LBL_CURRENCYLAYER_SETTINGS', '~/Administration/CurrencyLayer/default.aspx'              , 'CurrencyLayer.gif'         , 1,  3, 'CurrencyLayer', 'edit';
end -- if;
GO

-- 05/12/2016 Paul.  Add Tags module. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Tags' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tags'                  , 'Tags.LNK_NEW_TAG'                        , '~/Administration/Tags/edit.aspx'                          , 'CreateTags.gif'            , 1,  1, 'Tags'         , 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tags'                  , 'Tags.LNK_TAG_LIST'                       , '~/Administration/Tags/default.aspx'                       , 'Tags.gif'                  , 1,  2, 'Tags'         , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tags'                  , '.LBL_IMPORT'                             , '~/Administration/Tags/import.aspx'                        , 'Import.gif'                , 1,  3, 'Tags'         , 'import';
end -- if;
GO

-- 09/26/2017 Paul.  Add Archive access right. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Accounts' and DISPLAY_NAME = 'Accounts.LNK_ARCHIVED_ACCOUNTS' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , 'Accounts.LNK_ARCHIVED_ACCOUNTS'               , '~/Accounts/default.aspx?ArchiveView=1'               , 'Accounts.gif'              , 1,  -1, 'Accounts'       , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , 'Bugs.LNK_ARCHIVED_BUGS'                       , '~/Bugs/default.aspx?ArchiveView=1'                   , 'Bugs.gif'                  , 1,  -1, 'Bugs'           , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , 'Calls.LNK_ARCHIVED_CALLS'                     , '~/Calls/default.aspx?ArchiveView=1'                  , 'Calls.gif'                 , 1,  -1, 'Calls'          , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , 'Cases.LNK_ARCHIVED_CASES'                     , '~/Cases/default.aspx?ArchiveView=1'                  , 'Cases.gif'                 , 1,  -1, 'Cases'          , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , 'Contacts.LNK_ARCHIVED_CONTACTS'               , '~/Contacts/default.aspx?ArchiveView=1'               , 'Contacts.gif'              , 1,  -1, 'Contacts'       , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Emails'                , 'Emails.LNK_ARCHIVED_EMAILS'                   , '~/Emails/default.aspx?ArchiveView=1'                 , 'Emails.gif'                , 1,  -1, 'Emails'         , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , 'Leads.LNK_ARCHIVED_LEADS'                     , '~/Leads/default.aspx?ArchiveView=1'                  , 'Leads.gif'                 , 1,  -1, 'Leads'          , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , 'Meetings.LNK_ARCHIVED_MEETINGS'               , '~/Meetings/default.aspx?ArchiveView=1'               , 'Meetings.gif'              , 1,  -1, 'Meetings'       , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_ARCHIVED_NOTES'                     , '~/Notes/default.aspx?ArchiveView=1'                  , 'Notes.gif'                 , 1,  -1, 'Notes'          , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , 'Opportunities.LNK_ARCHIVED_OPPORTUNITIES'     , '~/Opportunities/default.aspx?ArchiveView=1'          , 'Opportunities.gif'         , 1,  -1, 'Opportunities'  , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , 'Tasks.LNK_ARCHIVED_TASKS'                     , '~/Tasks/default.aspx?ArchiveView=1'                  , 'Tasks.gif'                 , 1,  -1, 'Tasks'          , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , 'Project.LNK_ARCHIVED_PROJECTS'                , '~/Projects/default.aspx?ArchiveView=1'               , 'Project.gif'               , 1,  -1, 'Project'        , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , 'Project.LNK_ARCHIVED_PROJECT_TASKS'           , '~/ProjectTasks/default.aspx?ArchiveView=1'           , 'ProjectTask.gif'           , 1,  -1, 'ProjectTask'    , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Documents'             , 'Documents.LNK_ARCHIVED_DOCUMENTS'             , '~/Documents/default.aspx?ArchiveView=1'              , 'Documents.gif'             , 1,  -1, 'Documents'      , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProspectLists'         , 'ProspectLists.LNK_ARCHIVED_PROSPECT_LISTS'    , '~/ProspectLists/default.aspx?ArchiveView=1'          , 'ProspectLists.gif'         , 1,  -1, 'ProspectLists'  , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , 'Prospects.LNK_ARCHIVED_PROSPECTS'             , '~/Prospects/default.aspx?ArchiveView=1'              , 'Prospects.gif'             , 1,  -1, 'Prospects'      , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'SmsMessages'           , 'SmsMessages.LNK_ARCHIVED_SMS_MESSAGES'        , '~/SmsMessages/default.aspx?ArchiveView=1'            , 'SmsMessages.gif'           , 1,  -1, 'SmsMessages'    , 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'TwitterMessages'       , 'TwitterMessages.LNK_ARCHIVED_TWITTER_MESSAGES', '~/TwitterMessages/default.aspx?ArchiveView=1'        , 'TwitterMessages.gif'       , 1,  -1, 'TwitterMessages', 'archive';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ChatMessages'          , 'ChatMessages.LNK_ARCHIVED_CHAT_MESSAGES'      , '~/ChatMessages/default.aspx?ArchiveView=1'           , 'ChatMessages.gif'          , 1,  -1, 'ChatMessages'   , 'archive';
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

call dbo.spSHORTCUTS_Defaults()
/

call dbo.spSqlDropProcedure('spSHORTCUTS_Defaults')
/

-- #endif IBM_DB2 */

