

print 'DYNAMIC_BUTTONS EditView defaults';
-- delete from DYNAMIC_BUTTONS where VIEW_NAME like '%.EditView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
--	exec dbo.spDYNAMIC_BUTTONS_InsButton  '.EditView'                      , 0, null, 'edit', null, null, 'Save'     , null, '.LBL_SAVE_BUTTON_LABEL'     , '.LBL_SAVE_BUTTON_TITLE'     , '.LBL_SAVE_BUTTON_KEY'     , null, null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton  '.EditView'                      , 1, null, null  , null, null, 'Cancel'   , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , '.LBL_CANCEL_BUTTON_KEY'   , null, null;

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   '.EditView'                       , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel '.EditView'                       , 1, null, 0;  -- EditView Cancel is always visible. 
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Accounts.EditView'        , 'Accounts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Bugs.EditView'            , 'Bugs'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Calls.EditView'           , 'Calls'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Campaigns.EditView'       , 'Campaigns'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'CampaignTrackers.EditView', 'CampaignTrackers';
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Cases.EditView'           , 'Cases'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Contacts.EditView'        , 'Contacts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Documents.EditView'       , 'Documents'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'EmailMarketing.EditView'  , 'EmailMarketing'  ;
-- 08/27/2012 Paul.  Add CallMarketing modules. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'CallMarketing.EditView'   , 'CallMarketing'   ;
--exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Emails.EditView'          , 'Emails'          ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'EmailTemplates.EditView'  , 'EmailTemplates'  ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Employees.EditView'       , 'Employees'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Help.EditView'            , 'Help'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'iFrames.EditView'         , 'iFrames'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Leads.EditView'           , 'Leads'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Meetings.EditView'        , 'Meetings'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Notes.EditView'           , 'Notes'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Opportunities.EditView'   , 'Opportunities'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Project.EditView'         , 'Project'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ProjectTask.EditView'     , 'ProjectTask'     ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ProspectLists.EditView'   , 'ProspectLists'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Prospects.EditView'       , 'Prospects'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Tasks.EditView'           , 'Tasks'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Users.EditView'           , 'Users'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'DynamicButtons.EditView'  , 'DynamicButtons'  ;
-- 09/09/2009 Paul.  Allow direct editing of the module table. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Modules.EditView'         , 'Modules'         ;
-- 09/12/2009 Paul.  Allow editing of Field Validators. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'FieldValidators.EditView' , 'FieldValidators' ;
-- 05/17/2010 Paul.  Allow editing of Languages. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Languages.EditView'       , 'Languages'       ;
GO

-- 04/22/2008 Paul.  Add buttons for ConvertView. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Leads.ConvertView'        , 'Leads'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Prospects.ConvertView'    , 'Prospects'       ;
GO

-- 03/03/2010 Paul.  Document Revisions needs the Cancel to be a post-back so that it can redirect to the parent document. 
-- 05/30/2011 Paul.  There is no DocumentRevisions module, so the access rights must be for Documents. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'DocumentRevisions.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'DocumentRevisions.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS DocumentRevisions.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave       'DocumentRevisions.EditView'  , 0, 'DocumentRevisions';
	exec dbo.spDYNAMIC_BUTTONS_InsCancelEdit 'DocumentRevisions.EditView'  , 1, 'DocumentRevisions';
end else begin
	update DYNAMIC_BUTTONS
	   set MODULE_NAME       = 'Documents'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where VIEW_NAME         = 'DocumentRevisions.EditView'
	   and MODULE_NAME       = 'DocumentRevisions'
	   and DELETED           = 0;
end -- if;
GO

-- 11/10/2010 Paul.  Convert EmailButtons.ascx to DynamicButtons. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.EditView'                 , 0, 'Emails'          , 'edit', null              , null, 'Send'                    , null, 'Emails.LBL_SEND_BUTTON_LABEL'                , 'Emails.LBL_SEND_BUTTON_TITLE'                , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'Emails.EditView'                 , 1, 'Emails'          ;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Emails.EditView'                 , 2, 'Emails'          , 0;
end else begin
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.EditView' and COMMAND_NAME = 'Send' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Emails.EditView'
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.EditView'                 , 0, 'Emails'          , 'edit', null              , null, 'Send'                    , null, 'Emails.LBL_SEND_BUTTON_LABEL'                , 'Emails.LBL_SEND_BUTTON_TITLE'                , null, null, null;
	end -- if;
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.EditView' and COMMAND_NAME = 'Save' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Emails.EditView'
		   and CONTROL_INDEX     > 0
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsSave   'Emails.EditView'                 , 1, 'Emails'          ;
	end -- if;
end -- if;
GO

-- 11/22/2012 Paul.  EmailMan.Preview is created in DYNAMIC_BUTTONS DetailView defaults.1.sql. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.InboundView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails.InboundView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.InboundView'              , 0, 'Emails'          , 'edit', null              , null, 'Forward'                 , null, 'Emails.LBL_BUTTON_FORWARD'                   , 'Emails.LBL_BUTTON_FORWARD_TITLE'             , 'Emails.LBL_BUTTON_REPLY_KEY'               , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.InboundView'              , 1, 'Emails'          , 'edit', null              , null, 'Reply'                   , null, 'Emails.LBL_BUTTON_REPLY'                     , 'Emails.LBL_BUTTON_REPLY_TITLE'               , 'Emails.LBL_BUTTON_FORWARD_KEY'             , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete 'Emails.InboundView'              , 2, 'Emails'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.InboundView'              , 3, 'Emails'          , 'edit', null              , null, 'ShowRaw'                 , null, 'Emails.LBL_BUTTON_RAW_LABEL'                 , 'Emails.LBL_BUTTON_RAW_TITLE'                 , 'Emails.LBL_BUTTON_RAW_KEY'                 , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.InboundView'              , 4, 'Emails'          , 'edit', null              , null, 'HideRaw'                 , null, 'Emails.LBL_BUTTON_RAW_LABEL_HIDE'            , 'Emails.LBL_BUTTON_RAW_LABEL_HIDE'            , 'Emails.LBL_BUTTON_RAW_KEY'                 , null, null;
end -- if;
*/
GO

-- 11/22/2012 Paul.  Import.ImportView is not a standard EditView. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Import.ImportView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Import.ImportView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Import.ImportView'               , 0, null              , null  , null              , null, 'Import'                  , null, 'Reports.LBL_IMPORT_BUTTON_LABEL'             , 'Reports.LBL_IMPORT_BUTTON_TITLE'             , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Import.ImportView'               , 1, null              , 0;
end -- if;
*/
GO

-- 05/01/2016 Paul.  Currencies now has full EditView/DetailView/ListView layouts. 
-- 03/19/2019 Paul.  Remove Clear button. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Currencies.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Currencies.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'Currencies.EditView'             , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Currencies.EditView'             , 1, null, 0;  -- EditView Cancel is always visible. 
end else begin
	-- 05/01/2016 Paul.  Currencies now has full EditView/DetailView/ListView layouts. 
	update DYNAMIC_BUTTONS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where VIEW_NAME         = 'Currencies.EditView'
	   and COMMAND_NAME      = 'Clear'
	   and DELETED           = 0;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Currencies.EditView'             , 1, null, 0;  -- EditView Cancel is always visible. 
end -- if;
GO

-- Administration
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.AdminEditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .AdminEditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave    '.AdminEditView'                 , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsSaveNew '.AdminEditView'                 , 1, null;
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ACLRoles.EditView'         , 'ACLRoles'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Config.EditView'           , 'Config'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ConfigureSettings.EditView', 'ConfigureSettings';
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Dropdown.EditView'         , 'Dropdown'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'EmailMan.EditView'         , 'EmailMan'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Schedulers.EditView'       , 'Schedulers'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Shortcuts.EditView'        , 'Shortcuts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Terminology.EditView'      , 'Terminology'      ;
-- 04/12/2016 Paul.  Add ZipCodes. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ZipCodes.EditView'         , 'ZipCodes'         ;
-- 05/12/2016 Paul.  Add Tags module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Tags.EditView'             , 'Tags'             ;
-- 06/07/2017 Paul.  Add support for NAICS Codes. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'NAICSCodes.EditView'       , 'NAICSCodes'       ;
GO

-- 11/22/2012 Paul.  Currencies is not a standard AdminEditView. 

-- 08/05/2010 Paul.  Releases will now use standard Save/Cancel buttons. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'Releases.EditView'         , 'Releases'         ;
if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.EditView' and COMMAND_NAME = 'SaveNew' and DELETED = 0) begin -- then
	update DYNAMIC_BUTTONS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where VIEW_NAME         = 'Releases.EditView'
	   and COMMAND_NAME      = 'SaveNew'
	   and DELETED           = 0;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Releases.EditView'               , 1, null              , 0;
end -- if;
GO

-- 01/23/2012 Paul.  NumberSequences will now use standard Save/Cancel buttons. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'NumberSequences.EditView' , 'NumberSequences';
GO

-- 07/16/2010 Paul.  Add a separate set of buttons for the Imap SettingsView.  We will use the same set for Pop3.
-- 01/24/2013 Paul.  Change view name to EmailClient.SettingsView. 
if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.SettingsView.Imap' and DELETED = 0) begin -- then
	update DYNAMIC_BUTTONS
	   set VIEW_NAME         = 'EmailClient.SettingsView'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where VIEW_NAME         = 'InboundEmail.SettingsView.Imap'
	   and DELETED           = 0;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.SettingsView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.SettingsView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailClient.SettingsView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'EmailClient.SettingsView'        , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'EmailClient.SettingsView'        , 2, null              , 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'EmailClient.SettingsView'        , 3, null              , null  , null          , null, 'Gmail'                   , null, 'EmailMan.LBL_EMAIL_GMAIL_DEFAULTS'           , 'EmailMan.LBL_EMAIL_GMAIL_DEFAULTS'          , null, 'GmailDefaults(); return false;', null;
end -- if;
GO

-- 07/19/2010 Paul.  Add Test button to InboundEmail
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS InboundEmail.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'InboundEmail.EditView'           , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'InboundEmail.EditView'           , 2, null              , 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'InboundEmail.EditView'           , 3, null              , null  , null              , null, 'Test'                    , null, 'EmailMan.LBL_TEST_BUTTON_LABEL'              , 'EmailMan.LBL_TEST_BUTTON_TITLE'              , null, null, null;
end else begin
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.EditView' and COMMAND_NAME = 'Test' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton 'InboundEmail.EditView'           , 3, null              , null  , null              , null, 'Test'                    , null, 'EmailMan.LBL_TEST_BUTTON_LABEL'              , 'EmailMan.LBL_TEST_BUTTON_TITLE'              , null, null, null;
	end -- if;
end -- if;
GO


-- 07/07/2010 Paul.  Add SMTP test button. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailMan.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'EmailMan.ConfigView'             , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'EmailMan.ConfigView'             , 2, null              , 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'EmailMan.ConfigView'             , 3, null              , null  , null              , null, 'Test'                    , null, 'EmailMan.LBL_TEST_BUTTON_LABEL'              , 'EmailMan.LBL_TEST_BUTTON_TITLE'              , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'DynamicLayout.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS DynamicLayout.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'DynamicLayout.EditView'          , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'DynamicLayout.EditView'          , 2, null              , 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'DynamicLayout.EditView'          , 3, null              , null  , null              , null, 'New'                     , null, '.LBL_NEW_BUTTON_LABEL'                       , '.LBL_NEW_BUTTON_TITLE'                       , '.LBL_NEW_BUTTON_KEY'                       , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'DynamicLayout.EditView'          , 4, null              , null  , null              , null, 'Defaults'                , null, '.LBL_DEFAULTS_BUTTON_LABEL'                  , '.LBL_DEFAULTS_BUTTON_TITLE'                  , '.LBL_DEFAULTS_BUTTON_KEY'                  , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EditCustomFields.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EditCustomFields.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'EditCustomFields.EditView'       , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'EditCustomFields.EditView'       , 2, null              , 0;
end -- if;
GO

-- 05/09/2008 Paul.  The Updater Cancel needs to be processed as a Command. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Updater.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Updater.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Updater.EditView'                , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Updater.EditView'                , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Updater.EditView' and CONTROL_TYPE = 'ButtonLink' and  COMMAND_NAME = 'Cancel' and DELETED = 0) begin -- then
		print 'Updater.EditView: Cancel should be a Button.';
		update DYNAMIC_BUTTONS
		   set CONTROL_TYPE     = 'Button'
		     , URL_FORMAT       = null
		     , TEXT_FIELD       = null
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where VIEW_NAME        = 'Updater.EditView'
		   and CONTROL_TYPE     = 'ButtonLink'
		   and COMMAND_NAME     = 'Cancel'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 04/15/2011 Paul.  Add facebook panel. 
-- 06/06/2011 Paul.  The Facebook Cancel needs to be processed as a Command. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Facebook.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Facebook.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Facebook.EditView'               , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Facebook.EditView'               , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Facebook.EditView' and CONTROL_TYPE = 'ButtonLink' and  COMMAND_NAME = 'Cancel' and DELETED = 0) begin -- then
		print 'Facebook.EditView: Cancel should be a Button.';
		update DYNAMIC_BUTTONS
		   set CONTROL_TYPE     = 'Button'
		     , URL_FORMAT       = null
		     , TEXT_FIELD       = null
		     , DATE_MODIFIED    = getdate()
		     , MODIFIED_USER_ID = null
		 where VIEW_NAME        = 'Facebook.EditView'
		   and CONTROL_TYPE     = 'ButtonLink'
		   and COMMAND_NAME     = 'Cancel'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 04/09/2019 Paul.  Add Facebook.ConfigView for the React app. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Facebook.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Facebook.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Facebook.ConfigView'             , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Facebook.ConfigView'             , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.EditView' and COMMAND_NAME = 'Facebook' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Users.EditView Facebook';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Users.EditView'                  , 2, null              , null  , null              , null, 'Facebook'                , null, 'Users.LBL_FACEBOOK_GET_ID'                   , 'Users.LBL_FACEBOOK_GET_ID'                   , null, 'FBlogin();', null;
end -- if;
GO

-- 04/22/2012 Paul.  Add buttons for LinkedIn, Twitter and Salesforce. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'LinkedIn.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS LinkedIn.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'LinkedIn.EditView'               , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'LinkedIn.EditView'               , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 04/09/2019 Paul.  Add LinkedIn.ConfigView for the React app. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'LinkedIn.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS LinkedIn.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'LinkedIn.ConfigView'             , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'LinkedIn.ConfigView'             , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Twitter.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Twitter.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Twitter.EditView'                , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Twitter.EditView'                , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 04/09/2019 Paul.  Add Twitter.ConfigView for the React app. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Twitter.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Twitter.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Twitter.ConfigView'              , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Twitter.ConfigView'              , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Salesforce.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Salesforce.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Salesforce.EditView'             , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Salesforce.EditView'             , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 04/09/2019 Paul.  Add Salesforce.ConfigView for the React app. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Salesforce.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Salesforce.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Salesforce.ConfigView'           , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Salesforce.ConfigView'           , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'PasswordManager.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS PasswordManager.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'PasswordManager.EditView'        , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'PasswordManager.EditView'        , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 09/10/2012 Paul.  Add User Signatures. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'UserSignatures.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'UserSignatures.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS UserSignatures.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'UserSignatures.EditView'         , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'UserSignatures.EditView'         , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 12/26/2012 Paul.  Add send invites button. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Calls.EditView' and COMMAND_NAME = 'Save.SendInvites' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Calls.EditView'                  , 2, null              , null  , null              , null, 'Save.SendInvites'        , null, 'Calls.LBL_SAVE_INVITE_BUTTON_LABEL'          , 'Calls.LBL_SAVE_INVITE_BUTTON_TITLE'          , null, null, null;
end -- if;

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Meetings.EditView' and COMMAND_NAME = 'Save.SendInvites' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Meetings.EditView'               , 2, null              , null  , null              , null, 'Save.SendInvites'        , null, 'Meetings.LBL_SAVE_INVITE_BUTTON_LABEL'       , 'Meetings.LBL_SAVE_INVITE_BUTTON_TITLE'       , null, null, null;
end -- if;
GO

-- 06/06/2011 Paul.  The BusinessMode Cancel needs to be processed as a Command. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'BusinessMode.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS BusinessMode.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'BusinessMode.EditView'           , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'BusinessMode.EditView'           , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 09/17/2013 Paul.  Add Twilio. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Twilio.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Twilio.EditView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.EditView'  , 0, null, 'edit', null, null, 'Save'     , null, '.LBL_SAVE_BUTTON_LABEL'        , '.LBL_SAVE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.EditView'  , 1, null, null  , null, null, 'Cancel'   , null, '.LBL_CANCEL_BUTTON_LABEL'      , '.LBL_CANCEL_BUTTON_TITLE'      , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.EditView'  , 2, null, null  , null, null, 'Test'     , null, 'Twilio.LBL_TEST_BUTTON_LABEL'  , 'Twilio.LBL_TEST_BUTTON_LABEL'  , null, null, null;
end -- if;
GO

-- 04/11/2019 Paul.  Add Twilio.ConfigView for the React app. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Twilio.ConfigView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Twilio.ConfigView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.ConfigView', 0, null, 'edit', null, null, 'Save'     , null, '.LBL_SAVE_BUTTON_LABEL'        , '.LBL_SAVE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.ConfigView', 1, null, null  , null, null, 'Cancel'   , null, '.LBL_CANCEL_BUTTON_LABEL'      , '.LBL_CANCEL_BUTTON_TITLE'      , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'Twilio.ConfigView', 2, null, null  , null, null, 'Test'     , null, 'Twilio.LBL_TEST_BUTTON_LABEL'  , 'Twilio.LBL_TEST_BUTTON_LABEL'  , null, null, null;
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'SmsMessages.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'SmsMessages.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS SmsMessages.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'SmsMessages.EditView'            , 0, 'SmsMessages'     , 'edit', null              , null, 'Send'                    , null, 'SmsMessages.LBL_BUTTON_SEND'                , 'SmsMessages.LBL_BUTTON_SEND'                , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'SmsMessages.EditView'            , 1, 'SmsMessages'     ;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'SmsMessages.EditView'            , 2, 'SmsMessages'     , 0;
end -- if;

-- 09/22/2013 Paul.  Add OutboundSms module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'OutboundSms.EditView'      , 'OutboundSms'      ;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module.
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS TwitterMessages.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'TwitterMessages.EditView'        , 0, 'TwitterMessages' , 'edit', null              , null, 'Send'                    , null, 'TwitterMessages.LBL_BUTTON_SEND'            , 'TwitterMessages.LBL_BUTTON_SEND'            , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'TwitterMessages.EditView'        , 1, 'TwitterMessages' , 'edit', null              , null, 'SignIn'                  , null, 'TwitterMessages.LBL_BUTTON_SIGNIN'          , 'TwitterMessages.LBL_BUTTON_SIGNIN'          , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'TwitterMessages.EditView'        , 2, 'TwitterMessages' , 'edit', null              , null, 'SignOut'                 , null, 'TwitterMessages.LBL_BUTTON_SIGNOUT'         , 'TwitterMessages.LBL_BUTTON_SIGNOUT'         , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'TwitterMessages.EditView'        , 3, 'TwitterMessages' ;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'TwitterMessages.EditView'        , 4, 'TwitterMessages' , 0;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ChatChannels.EditView'     , 'ChatChannels'     ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.EditView', 'ChatMessages.EditView'     , 'ChatMessages'     ;
GO

-- 10/18/2016 Paul.  Add FullTextSearch module.
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'FullTextSearch.ConfigView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'FullTextSearch.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS TwitterMessages.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'FullTextSearch.ConfigView'       , 0, 'FullTextSearch'  , 'edit', null              , null, 'Enable'                  , null, 'FullTextSearch.LBL_ENABLE_BUTTON'           , 'FullTextSearch.LBL_ENABLE_BUTTON'           , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'FullTextSearch.ConfigView'       , 1, 'FullTextSearch'  , 'edit', null              , null, 'Disable'                 , null, 'FullTextSearch.LBL_DISABLE_BUTTON'          , 'FullTextSearch.LBL_DISABLE_BUTTON'          , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'FullTextSearch.ConfigView'       , 2, 'FullTextSearch'  , 'edit', null              , null, 'Test'                    , null, 'FullTextSearch.LBL_TEST_BUTTON'             , 'FullTextSearch.LBL_TEST_BUTTON'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'FullTextSearch.ConfigView'       , 3, 'FullTextSearch'  , 'edit', null              , null, 'RebuildIndex'            , null, 'FullTextSearch.LBL_REBUILD_INDEX_BUTTON'    , 'FullTextSearch.LBL_REBUILD_INDEX_BUTTON'    , null, null, null;
	-- 12/06/2021 Paul.  Cancel should be for FullTextSearch. 
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'FullTextSearch.ConfigView'       , 4, 'FullTextSearch' , 0;
end else begin
	-- 12/06/2021 Paul.  Cancel should be for FullTextSearch. 
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'FullTextSearch.ConfigView'       , 4, 'FullTextSearch' , 0;
end -- if;
GO

-- 05/07/2017 Paul.  Add HTML5 Dashboard. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Dashboard.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'Dashboard.EditView', 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'Dashboard.EditView', 1, null, 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Dashboard.EditView', 2, null, null  , null, null, 'Delete', null, '.LBL_DELETE_BUTTON_LABEL', '.LBL_DELETE_BUTTON_TITLE', null, null, null;
end -- if;
GO

-- 03/24/2021 Paul.  Add CampaignEmailSettings support to React Client. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.ConfigView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.ConfigView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Campaigns.ConfigView'            , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Campaigns.ConfigView'            , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
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

call dbo.spDYNAMIC_BUTTONS_EditView()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_EditView')
/

-- #endif IBM_DB2 */

