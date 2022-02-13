

print 'DYNAMIC_BUTTONS MassUpdate defaults';

set nocount on;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Accounts MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MassUpdate'      , 0, 'Accounts'      , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MassUpdate'      , 1, 'Accounts'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MassUpdate'      , 2, 'Accounts'      , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MassUpdate'      , 3, 'Accounts'      , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Accounts.MassUpdate'      , 4, 'Accounts'      , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Bugs MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.MassUpdate'          , 0, 'Bugs'          , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.MassUpdate'          , 1, 'Bugs'          , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.MassUpdate'          , 2, 'Bugs'          , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.MassUpdate'          , 3, 'Bugs'          , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Bugs.MassUpdate'          , 4, 'Bugs'          , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Calls.MassUpdate' and DELETED = 0) begin -- then                                                       
	print 'DYNAMIC_BUTTONS Calls MassUpdate';                                                                                                                         
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.MassUpdate'         , 0, 'Calls'         , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Calls.MassUpdate'         , 1, 'Calls'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.MassUpdate'     , 0, 'Campaigns'     , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.MassUpdate'     , 1, 'Campaigns'     , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Cases MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.MassUpdate'         , 0, 'Cases'         , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.MassUpdate'         , 1, 'Cases'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.MassUpdate'         , 2, 'Cases'         , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.MassUpdate'         , 3, 'Cases'         , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Cases.MassUpdate'         , 4, 'Cases'         , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 01/11/2012 Paul.  Use generic Sync labels. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Contacts MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.MassUpdate'      , 0, 'Contacts'      , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.MassUpdate'      , 1, 'Contacts'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.MassUpdate'      , 2, 'Contacts'      , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.MassUpdate'      , 3, 'Contacts'      , 'edit'  , null, null, 'Sync'      , null, '.LBL_SYNC'           , '.LBL_SYNC'           , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Contacts.MassUpdate'      , 4, 'Contacts'      , 'edit'  , null, null, 'Unsync'    , null, '.LBL_UNSYNC'         , '.LBL_UNSYNC'         , null, 'if ( !ValidateOne() ) return false;', null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.MassUpdate' and CONTROL_TEXT = '.LBL_EXCHANGE_SYNC' and DELETED = 0) begin -- then
		print 'Contacts.MassUpdate: Fix Sync';
		update DYNAMIC_BUTTONS
		   set CONTROL_TEXT      = '.LBL_SYNC'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Contacts.MassUpdate'
		   and COMMAND_NAME      = 'Sync'
		   and CONTROL_TEXT      = '.LBL_EXCHANGE_SYNC'
		   and DELETED           = 0;
	end -- if;
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.MassUpdate' and CONTROL_TEXT = '.LBL_EXCHANGE_UNSYNC' and DELETED = 0) begin -- then
		print 'Contacts.MassUpdate: Fix Unsync';
		update DYNAMIC_BUTTONS
		   set CONTROL_TEXT      = '.LBL_UNSYNC'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Contacts.MassUpdate'
		   and COMMAND_NAME      = 'Unsync'
		   and CONTROL_TEXT      = '.LBL_EXCHANGE_UNSYNC'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Documents.MassUpdate'     , 0, 'Documents'     , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Documents.MassUpdate'     , 1, 'Documents'     , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.MassUpdate'        , 0, 'Emails'        , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.MassUpdate'        , 1, 'Emails'        , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailTemplates.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailTemplates MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailTemplates.MassUpdate', 0, 'EmailTemplates', 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'iFrames.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS iFrames MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'iFrames.MassUpdate'       , 0, 'iFrames'       , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.MassUpdate'         , 0, 'Leads'         , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.MassUpdate'         , 1, 'Leads'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.MassUpdate'         , 2, 'Leads'         , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.MassUpdate'         , 3, 'Leads'         , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Leads.MassUpdate'         , 4, 'Leads'         , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Meetings.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Meetings MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Meetings.MassUpdate'      , 0, 'Meetings'      , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Meetings.MassUpdate'      , 1, 'Meetings'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Notes.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Notes MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Notes.MassUpdate'         , 0, 'Notes'         , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Notes.MassUpdate'         , 1, 'Notes'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Opportunities MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.MassUpdate' , 0, 'Opportunities' , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.MassUpdate' , 1, 'Opportunities' , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.MassUpdate' , 2, 'Opportunities' , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.MassUpdate' , 3, 'Opportunities' , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Opportunities.MassUpdate' , 4, 'Opportunities' , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Project MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.MassUpdate'       , 0, 'Project'       , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.MassUpdate'       , 1, 'Project'       , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.MassUpdate'       , 2, 'Project'       , 'edit'  , null, null, 'Sync'      , null, '.LBL_EXCHANGE_SYNC'  , '.LBL_EXCHANGE_SYNC'  , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Project.MassUpdate'       , 3, 'Project'       , 'edit'  , null, null, 'Unsync'    , null, '.LBL_EXCHANGE_UNSYNC', '.LBL_EXCHANGE_UNSYNC', null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 06/19/2011 Paul.  Filter on MassUpdate and not Activities.Open. 
-- 03/21/2012 Paul.  Make sure to add the delete back. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.MassUpdate' and COMMAND_NAME = 'MassDelete' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProjectTask MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.MassUpdate'   , 0, 'ProjectTask'   , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProjectTask.MassUpdate'   , 1, 'ProjectTask'   , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProspectLists MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.MassUpdate' , 0, 'ProspectLists' , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ProspectLists.MassUpdate' , 1, 'ProspectLists' , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 06/19/2011 Paul.  Filter on MassUpdate and not Activities.Open. 
-- 03/21/2012 Paul.  Make sure to add the delete back. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.MassUpdate' and COMMAND_NAME = 'MassDelete' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.MassUpdate'     , 0, 'Prospects'     , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.MassUpdate'     , 1, 'Prospects'     , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Prospects.MassUpdate'     , 2, 'Prospects'     , 'edit'  , null, null, 'MassMerge' , null, '.LBL_MERGE'          , '.LBL_MERGE'          , null, 'if ( !ValidateTwo() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Tasks MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Tasks.MassUpdate'         , 0, 'Tasks'         , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Tasks.MassUpdate'         , 1, 'Tasks'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Releases MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Releases.MassUpdate'      , 0, 'Releases'      , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Releases.MassUpdate'      , 1, 'Releases'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ACLRoles MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ACLRoles.MassUpdate'      , 0, 'ACLRoles'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailMan MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailMan.MassUpdate'      , 0, 'EmailMan'      , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS InboundEmail MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.MassUpdate'  , 0, 'InboundEmail'  , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Roles.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Roles MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Roles.MassUpdate'         , 0, 'Roles'         , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Terminology.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Terminology MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Terminology.MassUpdate'   , 0, 'Terminology'   , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'SmsMessages.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS SmsMessages MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'SmsMessages.MassUpdate'    , 0, 'SmsMessages'    , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'SmsMessages.MassUpdate'    , 1, 'SmsMessages'    , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS TwitterMessages MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.MassUpdate', 0, 'TwitterMessages', 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.MassUpdate', 1, 'TwitterMessages', 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons.
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS  MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.MassUpdate'      , 0, null, null, null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Currencies.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Currencies MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Currencies.MassUpdate'      , 0, 'Currencies'      , 'edit'  , null, null, 'MassUpdate', null, '.LBL_UPDATE'         , '.LBL_UPDATE'         , null, 'if ( !ValidateOne() ) return false;', null;
end -- if;
GO

-- 03/30/2021 Paul.  Add EmailMan for React client. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.MassUpdate' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Currencies MassUpdate';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailMan.MassUpdate'        , 0, 'EmailMan'        , 'delete', null, null, 'MassDelete', null, '.LBL_DELETE'         , '.LBL_DELETE'         , null, 'if ( !ValidateOne() ) return false;', null;
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

call dbo.spDYNAMIC_BUTTONS_MassUpdate()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_MassUpdate')
/

-- #endif IBM_DB2 */

