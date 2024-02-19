

print 'DYNAMIC_BUTTONS DetailView defaults';
-- delete from DYNAMIC_BUTTONS where VIEW_NAME like '%.DetailView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 07/19/2010 Paul.  Remove all references to button keys.  They conflict with the browser keys. 
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.DetailView', 0, null, 'edit'  , null, null, 'Edit'     , null, '.LBL_EDIT_BUTTON_LABEL'     , '.LBL_EDIT_BUTTON_TITLE'     , null, null, null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.DetailView', 1, null, 'edit'  , null, null, 'Duplicate', null, '.LBL_DUPLICATE_BUTTON_LABEL', '.LBL_DUPLICATE_BUTTON_TITLE', null, null, null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.DetailView', 2, null, 'delete', null, null, 'Delete'   , null, '.LBL_DELETE_BUTTON_LABEL'   , '.LBL_DELETE_BUTTON_TITLE'   , null, 'return ConfirmDelete();', null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.DetailView', 3, null, null    , null, null, 'Cancel'   , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , null, null, null;

-- 09/06/2011 Paul.  Add View Log as a default. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      '.DetailView'                     , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate '.DetailView'                     , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    '.DetailView'                     , 2, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    '.DetailView'                     , 3, null, 1;  -- DetailView Cancel is only visible on mobile. 
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   '.DetailView'                     , 4, null;
end -- if;
GO

-- 12/19/2019 Paul.  React needs a list for the buttons to display when record is not visible because it is archived. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.ArchiveExists' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton    '.ArchiveExists', 0, null, 'view'  , null, null, 'Archive.ViewData'     , null, '.LBL_VIEW_ARCHIVED_DATA'     , '.LBL_VIEW_ARCHIVED_DATA'     , null, null, null;
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Accounts.DetailView'        , 'Accounts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Bugs.DetailView'            , 'Bugs'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Calls.DetailView'           , 'Calls'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'CampaignTrackers.DetailView', 'CampaignTrackers';
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Cases.DetailView'           , 'Cases'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Contacts.DetailView'        , 'Contacts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Documents.DetailView'       , 'Documents'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'EmailMarketing.DetailView'  , 'EmailMarketing'  ;
-- 08/27/2012 Paul.  Add CallMarketing modules. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'CallMarketing.DetailView'   , 'CallMarketing'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Emails.DetailView'          , 'Emails'          ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'EmailTemplates.DetailView'  , 'EmailTemplates'  ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Meetings.DetailView'        , 'Meetings'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Notes.DetailView'           , 'Notes'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Opportunities.DetailView'   , 'Opportunities'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Project.DetailView'         , 'Project'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'ProjectTask.DetailView'     , 'ProjectTask'     ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'ProspectLists.DetailView'   , 'ProspectLists'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Tasks.DetailView'           , 'Tasks'           ;
-- 09/12/2009 Paul.  Allow editing of Field Validators. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'FieldValidators.DetailView' , 'FieldValidators' ;
-- 09/10/2012 Paul.  Add User Signatures. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'UserSignatures.DetailView'  , 'UserSignatures'  ;
GO

-- 09/09/2009 Paul.  Allow direct editing of the module table. 
--exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Modules.DetailView'         , 'Modules'         ;
-- 05/28/2012 Paul.  Modules cannot be duplicated, deleted or audited. 
-- 09/26/2017 Paul.  Add Archive access right. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Modules.DetailView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'Modules.DetailView'              , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Modules.DetailView'              , 1, null, 0;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Modules.DetailView'              , 2, 'Modules', 'edit', null, null, 'Archive.Build', null, 'Modules.LBL_BUILD_ARCHIVE_TABLE', 'Modules.LBL_BUILD_ARCHIVE_TABLE', null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Modules.DetailView' and COMMAND_NAME = 'Delete' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Modules.DetailView:  Remove duplicate, delete and audit. ';
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		where VIEW_NAME          = 'Modules.DetailView'
		  and DELETED            = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsEdit      'Modules.DetailView'              , 0, null;
		exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Modules.DetailView'              , 1, null, 0;
	end -- if;
	-- 09/26/2017 Paul.  Add Archive access right. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Modules.DetailView' and COMMAND_NAME = 'Archive.Build' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Modules.DetailView'              , 2, 'Modules', 'edit', null, null, 'Archive.Build', null, 'Modules.LBL_BUILD_ARCHIVE_TABLE', 'Modules.LBL_BUILD_ARCHIVE_TABLE', null, null, null;
	end -- if;
end -- if;
GO

-- 12/09/2010 Paul.  Help Edit should be a post-back so that we can allow the creation of entries. 
-- 12/30/2010 Paul.  Fix edit tooltip. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Help.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Help.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Help.DetailView'                 , 0, 'Help'            , 'edit', null              , null, 'Edit'                    , null, '.LBL_EDIT_BUTTON_LABEL'                      , '.LBL_EDIT_BUTTON_TITLE'                      , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Help.DetailView'                 , 1, 'Help'            , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , null                                        , 'Cancel(); return false;', null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Help.DetailView' and COMMAND_NAME = 'Cancel' and CONTROL_TEXT = '.LBL_CANCEL_BUTTON_LABEL' and CONTROL_TYPE = 'ButtonLink' and ONCLICK_SCRIPT is null and DELETED = 0) begin -- then
		print 'Help cancel needs to be a javascript event.';
		update DYNAMIC_BUTTONS
		   set DELETED       = 1
		     , DATE_MODIFIED = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME     = 'Help.DetailView'
		   and COMMAND_NAME  = 'Cancel'
		   and CONTROL_TEXT  = '.LBL_CANCEL_BUTTON_LABEL'
		   and CONTROL_TYPE  = 'ButtonLink'
		   and ONCLICK_SCRIPT is null
		   and DELETED       = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Help.DetailView'                 , 1, 'Help'            , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , null                                        , 'Cancel(); return false;', null;
	end -- if;
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Help.DetailView' and CONTROL_TEXT = '.LBL_EDIT_BUTTON_LABEL' and URL_FORMAT is not null and DELETED = 0) begin -- then
		print 'Help Edit should be post-back';
		update DYNAMIC_BUTTONS
		   set DELETED       = 1
		     , DATE_MODIFIED = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME     = 'Help.DetailView'
		   and CONTROL_TEXT  = '.LBL_EDIT_BUTTON_LABEL'
		   and URL_FORMAT is not null
		   and DELETED       = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Help.DetailView'                 , 0, 'Help'            , 'edit', null              , null, 'Edit'                    , null, '.LBL_EDIT_BUTTON_LABEL'                      , '.LBL_TEST_BUTTON_TITLE'                      , null                                        , null, null;
	end -- if;
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Help.DetailView' and CONTROL_TOOLTIP = '.LBL_TEST_BUTTON_TITLE' and DELETED = 0) begin -- then
		print 'Help.DetailView: Fix edit tooltip';
		update DYNAMIC_BUTTONS
		   set CONTROL_TOOLTIP = '.LBL_EDIT_BUTTON_TITLE'
		     , DATE_MODIFIED   = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME       = 'Help.DetailView'
		   and CONTROL_TOOLTIP = '.LBL_TEST_BUTTON_TITLE'
		   and DELETED        = 0;
	end -- if;
end -- if;
GO

-- 08/27/2012 Paul.  Add CallMarketing modules. 
-- 01/08/2013 Paul.  ViewLog was missing, but exists so it prevented GenerateCalls from getting inserted. 
-- 06/23/2013 Paul.  Duplicate should be a deep copy of the campaign. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'Campaigns.DetailView'            , 0, 'Campaigns'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 1, 'Campaigns'       , 'edit'  , null, null, 'Duplicate'           , null, '.LBL_DUPLICATE_BUTTON_LABEL'                 , '.LBL_DUPLICATE_BUTTON_TITLE'                 , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    'Campaigns.DetailView'            , 2, 'Campaigns'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Campaigns.DetailView'            , 3, 'Campaigns'       , 1   ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Campaigns.DetailView'            , 4, 'Campaigns'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 5, 'Campaigns'       , 'edit'  , null, null, 'SendTest'            , null, 'Campaigns.LBL_TEST_BUTTON_LABEL'             , 'Campaigns.LBL_TEST_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 6, 'Campaigns'       , 'edit'  , null, null, 'SendEmail'           , null, 'Campaigns.LBL_QUEUE_BUTTON_LABEL'            , 'Campaigns.LBL_QUEUE_BUTTON_TITLE'            , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 7, 'Campaigns'       , 'edit'  , null, null, 'MailMerge'           , null, '.LBL_MAILMERGE'                              , '.LBL_MAILMERGE'                              , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 8, 'Campaigns'       , 'edit'  , null, null, 'GenerateCalls'       , null, 'Campaigns.LBL_GENERATE_CALLS'                , 'Campaigns.LBL_GENERATE_CALLS'                , null, null, null;
end else begin
	-- 04/04/2008 Paul.  DeleteTest is only displayed in ROI and Track views. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.DetailView' and COMMAND_NAME = 'DeleteTest') begin -- then
		delete from DYNAMIC_BUTTONS
		 where VIEW_NAME    = 'Campaigns.DetailView'
		   and COMMAND_NAME = 'DeleteTest';
	end -- if;
	-- 08/27/2012 Paul.  Add CallMarketing modules. 
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 8, 'Campaigns'       , 'edit'  , null, null, 'GenerateCalls'       , null, 'Campaigns.LBL_GENERATE_CALLS'                , 'Campaigns.LBL_GENERATE_CALLS'                , null, null, null;
	-- 06/23/2013 Paul.  Duplicate should be a deep copy of the campaign. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.DetailView' and COMMAND_NAME = 'Duplicate' and CONTROL_TYPE = 'ButtonLink' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Campaigns.DetailView'
		   and COMMAND_NAME      = 'Duplicate'
		   and CONTROL_TYPE      = 'ButtonLink'
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.DetailView'            , 1, 'Campaigns'       , 'edit'  , null, null, 'Duplicate'           , null, '.LBL_DUPLICATE_BUTTON_LABEL'                 , '.LBL_DUPLICATE_BUTTON_TITLE'                 , null, null, null;
	end -- if;
end -- if;
GO

-- 04/04/2008 Paul.  Create separate views for TrackDetailView and RoiDetailView. 
if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.RoiView' and DELETED = 0) begin -- then
	delete from DYNAMIC_BUTTONS
	 where VIEW_NAME = 'Campaigns.RoiView';
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.LinkView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.LinkView';
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.LinkView'              , 0, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/track.aspx?ID={0}', 'ID', 'Campaigns.LBL_TRACK_BUTTON_LABEL'            , 'Campaigns.LBL_TRACK_BUTTON_TITLE'          , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.LinkView'              , 1, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/roi.aspx?ID={0}'  , 'ID', 'Campaigns.LBL_TRACK_ROI_BUTTON_LABEL'        , 'Campaigns.LBL_TRACK_ROI_BUTTON_LABEL'      , null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.RoiDetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.RoiDetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.RoiDetailView'         , 1, 'Campaigns'       , 'edit'  , null, null, 'DeleteTest'          , null, 'Campaigns.LBL_TRACK_DELETE_BUTTON_LABEL'     , 'Campaigns.LBL_TRACK_DELETE_BUTTON_TITLE'     , null                                        , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.RoiLinkView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.RoiLinkView';
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.RoiLinkView'           , 0, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/track.aspx?ID={0}', 'ID', 'Campaigns.LBL_TRACK_BUTTON_LABEL'            , 'Campaigns.LBL_TRACK_BUTTON_TITLE'          , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.RoiLinkView'           , 1, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/view.aspx?ID={0}' , 'ID', 'Campaigns.LBL_TODETAIL_BUTTON_LABEL'         , 'Campaigns.LBL_TODETAIL_BUTTON_TITLE'       , null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.TrackDetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.TrackDetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Campaigns.TrackDetailView'       , 1, 'Campaigns'       , 'edit'  , null, null, 'DeleteTest'          , null, 'Campaigns.LBL_TRACK_DELETE_BUTTON_LABEL'     , 'Campaigns.LBL_TRACK_DELETE_BUTTON_TITLE'     , null                                        , null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.TrackLinkView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns.TrackLinkView';
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.TrackLinkView'         , 0, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/roi.aspx?ID={0}'  , 'ID', 'Campaigns.LBL_TRACK_ROI_BUTTON_LABEL'        , 'Campaigns.LBL_TRACK_ROI_BUTTON_LABEL'      , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink 'Campaigns.TrackLinkView'         , 1, 'Campaigns'       , 'view'  , null, null, '~/Campaigns/view.aspx?ID={0}' , 'ID', 'Campaigns.LBL_TODETAIL_BUTTON_LABEL'         , 'Campaigns.LBL_TODETAIL_BUTTON_TITLE'       , null, null, null, null;
end -- if;
GO

-- 08/17/2010 Paul.  Add Reply All button. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.InboundView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails.InboundView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 0, 'Emails'          , 'edit'  , null, null, 'Forward'             , null, 'Emails.LBL_BUTTON_FORWARD'                   , 'Emails.LBL_BUTTON_FORWARD_TITLE'             , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 1, 'Emails'          , 'edit'  , null, null, 'Reply'               , null, 'Emails.LBL_BUTTON_REPLY'                     , 'Emails.LBL_BUTTON_REPLY_TITLE'               , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 2, 'Emails'          , 'edit'  , null, null, 'Reply All'           , null, 'Emails.LBL_BUTTON_REPLY_ALL'                 , 'Emails.LBL_BUTTON_REPLY_ALL'                 , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 3, 'Emails'          , 'delete', null, null, 'Delete'              , null, '.LBL_DELETE_BUTTON_LABEL'                    , '.LBL_DELETE_BUTTON_TITLE'                    , null                                        , 'return ConfirmDelete();', null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 3, 'Emails'          , 'view'  , null, null, 'ShowRaw'             , null, 'Emails.LBL_BUTTON_RAW_LABEL'                 , 'Emails.LBL_BUTTON_RAW_TITLE'                 , null                                        , null, null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 4, 'Emails'          , 'view'  , null, null, 'HideRaw'             , null, 'Emails.LBL_BUTTON_RAW_LABEL_HIDE'            , 'Emails.LBL_BUTTON_RAW_LABEL_HIDE'            , null                                        , null, null;
end else begin
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.InboundView' and COMMAND_NAME = 'Reply All' and DELETED = 0) begin -- then
		print 'Emails.InboundView: Add Reply All';
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX     = CONTROL_INDEX + 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Emails.InboundView'
		   and CONTROL_INDEX    >= 2
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'Emails.InboundView'              , 2, 'Emails'          , 'edit'  , null, null, 'Reply All'           , null, 'Emails.LBL_BUTTON_REPLY_ALL'                 , 'Emails.LBL_BUTTON_REPLY_ALL'                 , null                                        , null, null;
	end -- if;
end -- if;
GO

-- 04/29/2008 Paul.  The Cancel button should always be displayed, not just on a mobile device.
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Import.ImportView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Import.ImportView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Import.ImportView'               , 0, null              , 'import', null, null, 'Import.Run'          , null, 'Import.LBL_RUN_BUTTON_LABEL'                 , 'Import.LBL_RUN_BUTTON_TITLE'                 , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Import.ImportView'               , 1, null              , 'import', null, null, 'Import.Preview'      , null, 'Import.LBL_PREVIEW_BUTTON_LABEL'             , 'Import.LBL_PREVIEW_BUTTON_TITLE'             , null                                        , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Import.ImportView'               , 2, null              , 0;
end -- if;
GO

-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 05/21/2014 Paul.  ViewLog has been missing for a long time. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' ;
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit       'Leads.DetailView'                , 0, 'Leads'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate  'Leads.DetailView'                , 1, 'Leads'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete     'Leads.DetailView'                , 2, 'Leads'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Leads.DetailView'                , 3, 'Leads'           , 'view', 'Contacts', 'edit', 'Convert'       , 'convert.aspx?ID={0}', 'ID', 'Leads.LBL_CONVERTLEAD', 'Leads.LBL_CONVERTLEAD_TITLE', null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel     'Leads.DetailView'                , 4, 'Leads'           , 1;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog    'Leads.DetailView'                , 5, 'Leads'           ;
end -- if;
GO

-- 08/08/2008 Paul.  Prospects need to be manually created so that the convert button can be added. 
-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 05/21/2014 Paul.  ViewLog has been missing for a long time. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.DetailView' ;
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit       'Prospects.DetailView'            , 0, 'Prospects'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate  'Prospects.DetailView'            , 1, 'Prospects'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete     'Prospects.DetailView'            , 2, 'Prospects'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Prospects.DetailView'            , 3, 'Prospects'       , 'view', 'Leads'   , 'edit', 'Convert'       , 'convert.aspx?ID={0}', 'ID', 'Prospects.LBL_CONVERT_BUTTON_LABEL', 'Prospects.LBL_CONVERT_BUTTON_TITLE', null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel     'Prospects.DetailView'            , 4, 'Prospects'       , 1;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog    'Prospects.DetailView'            , 5, 'Prospects'       ;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Feeds.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Feeds.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Feeds.DetailView'                , 0, 'Feeds'           , null, null, null, 'Add'                     , null, 'Feeds.LBL_ADD_FAV_BUTTON_LABEL'              , 'Feeds.LBL_ADD_FAV_BUTTON_TITLE'              , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Feeds.DetailView'                , 1, 'Feeds'           , null, null, null, 'Delete'                  , null, 'Feeds.LBL_DELETE_FAV_BUTTON_LABEL'           , 'Feeds.LBL_DELETE_FAV_BUTTON_TITLE'           , null, null, null;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Employees.DetailView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Employees.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Employees.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'Employees.DetailView'            , 0, 'Employees';
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate 'Employees.DetailView'            , 1, 'Employees';
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Employees.DetailView'            , 2, 'Employees'       , null, null, null, 'ResetDefaults'           , null, 'Employees.LBL_RESET_PREFERENCES'             , 'Employees.LBL_RESET_PREFERENCES'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Employees.DetailView'            , 2, null, 1;
end -- if;
GO

-- 09/02/2008 Paul.  We need to have two edit buttons, one for the My Account and one for the administrator. 
-- 10/18/2008 Paul.  Admin User Edit needs the User ID.
-- 11/29/2008 Paul.  Needed to add the ID to the text field. 
-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
-- 08/11/2020 Paul.  Employees module may be disabled, so create a Users version of LBL_RESET_PREFERENCES. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView'
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Users.DetailView';
--	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Users.DetailView'               , 0, 'Users'           , 'edit', null, null, 'EditMyAccount'         , 'EditMyAccount.aspx', null, '.LBL_EDIT_BUTTON_LABEL'     , '.LBL_EDIT_BUTTON_TITLE'     , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Users.DetailView'               , 1, 'Users'           , 'edit', null, null, 'Edit'                  , 'edit.aspx?ID={0}'  , 'ID', '.LBL_EDIT_BUTTON_LABEL'     , '.LBL_EDIT_BUTTON_TITLE'     , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton     'Users.DetailView'               , 2, 'Users'           , null, null, null, 'ChangePassword'          , null, 'Users.LBL_CHANGE_PASSWORD_BUTTON_LABEL'      , 'Users.LBL_CHANGE_PASSWORD_BUTTON_TITLE'      , null, 'PasswordPopup(); return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate  'Users.DetailView'               , 3, 'Users';
	exec dbo.spDYNAMIC_BUTTONS_InsButton     'Users.DetailView'               , 4, 'Users'           , null, null, null, 'ResetDefaults'           , null, 'Users.LBL_RESET_PREFERENCES'                 , 'Users.LBL_RESET_PREFERENCES'                 , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel     'Users.DetailView'               , 5, null, 1;
end else begin
	-- 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView' and COMMAND_NAME = 'EditMyAccount' and DELETED = 0) begin -- then
		print 'Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list.';
		update DYNAMIC_BUTTONS
		   set DELETED       = 1
		     , DATE_MODIFIED = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME     = 'Users.DetailView'
		   and COMMAND_NAME  = 'EditMyAccount'
		   and DELETED       = 0;
	end -- if;
	/*
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView' and COMMAND_NAME = 'EditMyAccount' and DELETED = 0) begin -- then
		print 'User Edit needs to be different for the My Account.';
		update DYNAMIC_BUTTONS
		   set CONTROL_INDEX = CONTROL_INDEX + 1
		     , DATE_MODIFIED = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME     = 'Users.DetailView'
		   and DELETED       = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Users.DetailView'               , 0, 'Users'           , 'edit', null, null, 'EditMyAccount'         , 'EditMyAccount.aspx', null, '.LBL_EDIT_BUTTON_LABEL'     , '.LBL_EDIT_BUTTON_TITLE'     , null, null, null, null;
	end -- if;
	*/
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView' and COMMAND_NAME = 'Edit' and (URL_FORMAT = 'edit.aspx' or TEXT_FIELD is null) and DELETED = 0) begin -- then
		print 'Admin User Edit needs the User ID.';
		update DYNAMIC_BUTTONS
		   set URL_FORMAT    = 'edit.aspx?ID={0}'
		     , TEXT_FIELD    = 'ID'
		     , DATE_MODIFIED = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME     = 'Users.DetailView'
		   and COMMAND_NAME  = 'Edit'
		   and (URL_FORMAT    = 'edit.aspx' or TEXT_FIELD is null)
		   and DELETED       = 0;
	end -- if;
	-- 08/11/2020 Paul.  Employees module may be disabled, so create a Users version of LBL_RESET_PREFERENCES. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView' and COMMAND_NAME = 'ResetDefaults' and CONTROL_TEXT = 'Employees.LBL_RESET_PREFERENCES' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set CONTROL_TEXT      = 'Users.LBL_RESET_PREFERENCES'
		     , CONTROL_TOOLTIP   = 'Users.LBL_RESET_PREFERENCES'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Users.DetailView'
		   and COMMAND_NAME      = 'ResetDefaults'
		   and CONTROL_TEXT      = 'Employees.LBL_RESET_PREFERENCES'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
-- 08/11/2020 Paul.  Employees module may be disabled, so create a Users version of LBL_RESET_PREFERENCES. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView.MyAccount' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Users.DetailView.MyAccount';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Users.DetailView.MyAccount'     , 0, 'Users'           , 'edit', null, null, 'EditMyAccount'         , 'EditMyAccount.aspx', null, '.LBL_EDIT_BUTTON_LABEL'     , '.LBL_EDIT_BUTTON_TITLE'     , null, null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton     'Users.DetailView.MyAccount'     , 1, 'Users'           , null, null, null, 'ChangePassword'          , null, 'Users.LBL_CHANGE_PASSWORD_BUTTON_LABEL'      , 'Users.LBL_CHANGE_PASSWORD_BUTTON_TITLE'      , null, 'PasswordPopup(); return false;', null;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate  'Users.DetailView.MyAccount'     , 2, 'Users';
	exec dbo.spDYNAMIC_BUTTONS_InsButton     'Users.DetailView.MyAccount'     , 3, 'Users'           , null, null, null, 'ResetDefaults'           , null, 'Users.LBL_RESET_PREFERENCES'                 , 'Users.LBL_RESET_PREFERENCES'                 , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel     'Users.DetailView.MyAccount'     , 4, null, 1;
end else begin
	-- 08/11/2020 Paul.  Employees module may be disabled, so create a Users version of LBL_RESET_PREFERENCES. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.DetailView.MyAccount' and COMMAND_NAME = 'ResetDefaults' and CONTROL_TEXT = 'Employees.LBL_RESET_PREFERENCES' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set CONTROL_TEXT      = 'Users.LBL_RESET_PREFERENCES'
		     , CONTROL_TOOLTIP   = 'Users.LBL_RESET_PREFERENCES'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Users.DetailView.MyAccount'
		   and COMMAND_NAME      = 'ResetDefaults'
		   and CONTROL_TEXT      = 'Employees.LBL_RESET_PREFERENCES'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- Administration
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.AdminDetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .AdminDetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      '.AdminDetailView'                , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    '.AdminDetailView'                , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    '.AdminDetailView'                , 2, null, 1;
end -- if;
GO

-- 01/31/2012 Paul.  ACLRoles should not have a View Change Log. 
-- 08/15/2017 Paul.  Add Export button. 
--exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView'     , 'ACLRoles.DetailView'        , 'ACLRoles'        ;
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ACLRoles.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'ACLRoles.DetailView'             , 0, 'ACLRoles'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate 'ACLRoles.DetailView'             , 1, 'ACLRoles'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    'ACLRoles.DetailView'             , 2, 'ACLRoles'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'ACLRoles.DetailView'             , 4, 'ACLRoles'       , 'edit'  , null, null, 'Export'       , null, '.LBL_EXPORT_BUTTON_LABEL'                , '.LBL_EXPORT_BUTTON_TITLE'                , null, null, null;
end else begin
	-- 01/31/2012 Paul.  The ViewLog command was preventing the FieldSecurity command from begin created. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.DetailView' and COMMAND_NAME = 'ViewLog' and DELETED = 0) begin -- then
		print 'ACLRoles.DetailView: Remove View Change Log';
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , MODIFIED_USER_ID  = null
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'ACLRoles.DetailView'
		   and COMMAND_NAME      = 'ViewLog'
		   and DELETED           = 0;
	end -- if;
	-- 08/15/2017 Paul.  Add Export button. 
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.DetailView' and COMMAND_NAME = 'Export' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'ACLRoles.DetailView'             , -1, 'ACLRoles'       , 'edit'  , null, null, 'Export'       , null, '.LBL_EXPORT_BUTTON_LABEL'                , '.LBL_EXPORT_BUTTON_TITLE'                , null, null, null;
	end -- if;
end -- if;
GO


exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.AdminDetailView', 'Config.DetailView'          , 'Config'          ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView'     , 'Schedulers.DetailView'      , 'Schedulers'      ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView'     , 'Terminology.DetailView'     , 'Terminology'     ;
-- 09/04/2010 Paul.  Create full editing for Releases. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView'     , 'Releases.DetailView'        , 'Releases'        ;
-- 01/23/2012 Paul.  NumberSequences will now use standard Save/Cancel buttons. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView'     , 'NumberSequences.DetailView' , 'NumberSequences' ;
-- 04/12/2016 Paul.  Add ZipCodes. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.AdminDetailView', 'ZipCodes.DetailView'        , 'ZipCodes'        ;
-- 05/12/2016 Paul.  Add Tags module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.AdminDetailView', 'Tags.DetailView'            , 'Tags'            ;
-- 06/07/2017 Paul.  Add support for NAICS Codes. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.AdminDetailView', 'NAICSCodes.DetailView'      , 'NAICSCodes'      ;
GO


if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.Preview' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailMan.Preview';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailMan.Preview'                , 0, 'EmailMan'        , null, null, null, 'Send'                    , null, 'Emails.LBL_SEND_BUTTON_LABEL'                , 'Emails.LBL_SEND_BUTTON_TITLE'                , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    'EmailMan.Preview'                , 1, 'EmailMan'        ;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.Mailbox' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS InboundEmail.Mailbox';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 0, 'InboundEmail'    , null, null, null, 'Mailbox.CheckMail'       , null, 'Emails.LBL_BUTTON_CHECK'                     , 'Emails.LBL_BUTTON_CHECK_TITLE'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 1, 'InboundEmail'    , null, null, null, 'Mailbox.CheckBounce'     , null, 'Emails.LBL_BUTTON_BOUNCE'                    , 'Emails.LBL_BUTTON_BOUNCE_TITLE'              , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.Mailbox'            , 2, 'InboundEmail'    , null, null, null, 'Mailbox.CheckInbound'    , null, 'Administration.LBL_OOTB_IE'                  , 'Administration.LBL_OOTB_IE'                  , null, null, null;
end -- if;
GO

-- 07/19/2010 Paul.  Add test button to InboundEmail.DetailView. 
-- 07/18/2023 Paul.  Provide a way to archive imported messages. 
-- 07/19/2023 Paul.  Not ready to implement archive. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.DetailView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS InboundEmail.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'InboundEmail.DetailView'         , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate 'InboundEmail.DetailView'         , 1, null;
	exec dbo.spDYNAMIC_BUTTONS_InsDelete    'InboundEmail.DetailView'         , 2, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'InboundEmail.DetailView'         , 3, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.DetailView'         , 4, 'InboundEmail'    , 'edit'  , null, null, 'Test'                , null, 'EmailMan.LBL_TEST_BUTTON_LABEL'              , 'EmailMan.LBL_TEST_BUTTON_TITLE'              , null, null, null;
--	exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.DetailView'         , 5, 'InboundEmail'    , 'edit'  , null, null, 'Archive'             , null, 'EmailMan.LBL_ARCHIVE_BUTTON_LABEL'           , 'EmailMan.LBL_ARCHIVE_BUTTON_TITLE'              , null, null, null;
end else begin
	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.DetailView' and COMMAND_NAME = 'Test' and DELETED = 0) begin -- then
		exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.DetailView'         , 4, 'InboundEmail'    , 'edit'  , null, null, 'Test'                , null, 'EmailMan.LBL_TEST_BUTTON_LABEL'              , 'EmailMan.LBL_TEST_BUTTON_TITLE'              , null, null, null;
	end -- if;
	-- 07/18/2023 Paul.  Provide a way to archive imported messages. 
--	if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.DetailView' and COMMAND_NAME = 'Archive' and DELETED = 0) begin -- then
--		exec dbo.spDYNAMIC_BUTTONS_InsButton    'InboundEmail.DetailView'         , 5, 'InboundEmail'    , 'edit'  , null, null, 'Archive'             , null, 'EmailMan.LBL_ARCHIVE_BUTTON_LABEL'           , 'EmailMan.LBL_ARCHIVE_BUTTON_TITLE'           , null, null, null;
--	end -- if;
end -- if;
GO



-- 04/27/2010 Paul.  Add vCard buttons. 
-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Contacts.DetailView: vCard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Contacts.DetailView'             , 5, 'Contacts' , 'export', 'Contacts' , 'view', 'vCard' , 'vCard.aspx?ID={0}', 'ID', '.LBL_EXPORT_VCARD', '.LBL_EXPORT_VCARD', null, 'vCard', null, null;
end else begin
	-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and MODULE_ACCESS_TYPE = 'view' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set MODULE_ACCESS_TYPE = 'export'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Contacts.DetailView'
		   and URL_FORMAT         = 'vCard.aspx?ID={0}'
		   and MODULE_ACCESS_TYPE = 'view'
		   and DELETED            = 0;
	end -- if;
end -- if;

-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads.DetailView: vCard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Leads.DetailView'                , 5, 'Leads'    , 'export', 'Leads'    , 'view', 'vCard' , 'vCard.aspx?ID={0}', 'ID', '.LBL_EXPORT_VCARD', '.LBL_EXPORT_VCARD', null, 'vCard', null, null;
end else begin
	-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and MODULE_ACCESS_TYPE = 'view' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set MODULE_ACCESS_TYPE = 'export'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Leads.DetailView'
		   and URL_FORMAT         = 'vCard.aspx?ID={0}'
		   and MODULE_ACCESS_TYPE = 'view'
		   and DELETED            = 0;
	end -- if;
end -- if;

-- 08/22/2010 Paul.  Add ONCLICK_SCRIPT to spDYNAMIC_BUTTONS_InsButtonLink. 
-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects.DetailView: vCard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Prospects.DetailView'            , 5, 'Prospects', 'export', 'Prospects', 'view', 'vCard' , 'vCard.aspx?ID={0}', 'ID', '.LBL_EXPORT_VCARD', '.LBL_EXPORT_VCARD', null, 'vCard', null, null;
end else begin
	-- 04/23/2016 Paul.  Export vCard should use export security rule not view security rule. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.DetailView' and URL_FORMAT = 'vCard.aspx?ID={0}' and MODULE_ACCESS_TYPE = 'view' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set MODULE_ACCESS_TYPE = 'export'
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where VIEW_NAME          = 'Prospects.DetailView'
		   and URL_FORMAT         = 'vCard.aspx?ID={0}'
		   and MODULE_ACCESS_TYPE = 'view'
		   and DELETED            = 0;
	end -- if;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.DetailView';
-- 06/01/2010 Paul.  Embed the buttons directly so that the create button can be a popup or hover. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailClient.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 0, 'Emails'          , 'edit'  , null, null, 'Reply'               , null, 'Emails.LBL_BUTTON_REPLY'                     , 'Emails.LBL_BUTTON_REPLY_TITLE'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 1, 'Emails'          , 'edit'  , null, null, 'ReplyAll'            , null, 'Emails.LBL_BUTTON_REPLY_ALL'                 , 'Emails.LBL_BUTTON_REPLY_ALL_TITLE'           , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 2, 'Emails'          , 'edit'  , null, null, 'Forward'             , null, 'Emails.LBL_BUTTON_FORWARD'                   , 'Emails.LBL_BUTTON_FORWARD_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 3, 'Emails'          , 'delete', null, null, 'Delete'              , null, '.LBL_DELETE_BUTTON_LABEL'                    , '.LBL_DELETE_BUTTON_TITLE'                    , null, 'return ConfirmDelete();', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 4, 'Emails'          , 'view'  , null, null, 'ShowHeaders'         , null, 'Emails.LBL_BUTTON_VIEW_HEADERS'              , 'Emails.LBL_BUTTON_VIEW_HEADERS'              , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 5, 'Emails'          , 'import', null, null, 'Import'              , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                 , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.DetailView'          , 6, 'Emails'          , 'edit'  , null, null, null                  , null, 'EmailClient.LBL_EMAIL_QUICK_CREATE'          , 'EmailClient.LBL_EMAIL_QUICK_CREATE'          , null, null, null;
end -- if;
*/
GO

-- 07/28/2010 Paul.  Move View Change Log to a button. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.DetailView' and COMMAND_NAME = 'ViewLog' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Accounts.DetailView'        , 4, 'Accounts'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Bugs.DetailView'            , 4, 'Bugs'            ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Calls.DetailView'           , 4, 'Calls'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Campaigns.DetailView'       , 4, 'Campaigns'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Cases.DetailView'           , 4, 'Cases'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Contacts.DetailView'        , 4, 'Contacts'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Documents.DetailView'       , 4, 'Documents'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'EmailTemplates.DetailView'  , 4, 'EmailTemplates'  ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Leads.DetailView'           , 4, 'Leads'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Meetings.DetailView'        , 4, 'Meetings'        ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Notes.DetailView'           , 4, 'Notes'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Opportunities.DetailView'   , 4, 'Opportunities'   ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Project.DetailView'         , 4, 'Project'         ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'ProjectTask.DetailView'     , 4, 'ProjectTask'     ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'ProspectLists.DetailView'   , 5, 'ProspectLists'   ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Prospects.DetailView'       , 4, 'Prospects'       ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Tasks.DetailView'           , 4, 'Tasks'           ;
end -- if;
GO

-- 05/21/2014 Paul.  ViewLog has been missing for a long time. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.DetailView' and COMMAND_NAME = 'ViewLog' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Leads.DetailView'           , 5, 'Leads'           ;
	exec dbo.spDYNAMIC_BUTTONS_InsViewLog   'Prospects.DetailView'       , 5, 'Prospects'       ;
end -- if;
GO

-- 11/02/2010 Paul.  Add PreviewView buttons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.PreviewView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails.PreviewView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.PreviewView'              , 0, null              , null  , null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'                      , '.LBL_SAVE_BUTTON_TITLE'                      , '.LBL_SAVE_BUTTON_KEY'                      , null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.PreviewView'              , 1, null              , null  , null              , null, 'Cancel'                  , null, '.LBL_CANCEL_BUTTON_LABEL'                    , '.LBL_CANCEL_BUTTON_TITLE'                    , '.LBL_CANCEL_BUTTON_KEY'                    , null, null;
end -- if;
GO

-- 09/22/2013 Paul.  Add SmsMessages module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'SmsMessages.DetailView'     , 'SmsMessages'     ;

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'SmsMessages.InboundView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS SmsMessages.InboundView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'SmsMessages.InboundView'         , 0, 'SmsMessages'     , 'edit'  , null, null, 'Forward'             , null, 'SmsMessages.LBL_BUTTON_FORWARD'              , 'SmsMessages.LBL_BUTTON_FORWARD'              , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'SmsMessages.InboundView'         , 1, 'SmsMessages'     , 'edit'  , null, null, 'Reply'               , null, 'SmsMessages.LBL_BUTTON_REPLY'                , 'SmsMessages.LBL_BUTTON_REPLY'                , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'SmsMessages.InboundView'         , 2, 'SmsMessages'     , 'delete', null, null, 'Delete'              , null, '.LBL_DELETE_BUTTON_LABEL'                    , '.LBL_DELETE_BUTTON_TITLE'                    , null, 'return ConfirmDelete();', null;
end -- if;

-- 09/22/2013 Paul.  Add OutboundSms module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'OutboundSms.DetailView'     , 'OutboundSms'     ;
GO

-- 10/22/2013 Paul.  Add TwitterMessages module.
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'TwitterMessages.DetailView' , 'TwitterMessages' ;

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.InboundView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.InboundView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS TwitterMessages.InboundView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.InboundView'     , 0, 'TwitterMessages' , 'edit'  , null, null, 'Retweet'             , null, 'TwitterMessages.LBL_BUTTON_RETWEET'          , 'TwitterMessages.LBL_BUTTON_RETWEET'          , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.InboundView'     , 1, 'TwitterMessages' , 'edit'  , null, null, 'SignIn'              , null, 'TwitterMessages.LBL_BUTTON_SIGNIN'           , 'TwitterMessages.LBL_BUTTON_SIGNIN'           , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.InboundView'     , 2, 'TwitterMessages' , 'edit'  , null, null, 'SignOut'             , null, 'TwitterMessages.LBL_BUTTON_SIGNOUT'          , 'TwitterMessages.LBL_BUTTON_SIGNOUT'          , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.InboundView'     , 3, 'TwitterMessages' , 'delete', null, null, 'Delete'              , null, '.LBL_DELETE_BUTTON_LABEL'                    , '.LBL_DELETE_BUTTON_TITLE'                    , null, 'return ConfirmDelete();', null;
end -- if;
GO

-- 11/05/2014 Paul.  Add ChatChannels module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'ChatChannels.DetailView'    , 'ChatChannels'    ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'ChatMessages.DetailView'    , 'ChatMessages'    ;
GO

-- 04/04/2016 Paul.  Add buttons for related activities. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.DetailView' and URL_FORMAT like '~/Activities/popup.aspx%' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Accounts.DetailView'     , -1, 'Accounts'     , 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Contacts.DetailView'     , -1, 'Contacts'     , 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Leads.DetailView'        , -1, 'Leads'        , 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Opportunities.DetailView', -1, 'Opportunities', 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Cases.DetailView'        , -1, 'Cases'        , 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Bugs.DetailView'         , -1, 'Bugs'         , 'view', null, null, 'ViewRelatedActivities'       , '~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1', 'ID', '.LBL_VIEW_RELATED_ACTIVITIES', '.LBL_VIEW_RELATED_ACTIVITIES', null, 'RelatedActivities', null, null;
end -- if;
GO

-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Currencies.DetailView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Currencies.DetailView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Currencies.DetailView';
	exec dbo.spDYNAMIC_BUTTONS_InsEdit      'Currencies.DetailView'           , 0, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel    'Currencies.DetailView'           , 1, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Currencies.DetailView'           , 2, 'Currencies'      , 'edit'  , null, null, 'Currencies.MakeDefault', null, 'Currencies.LBL_MAKE_DEFAULT', 'Currencies.LBL_MAKE_DEFAULT', null, 'return ConfirmChange();', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Currencies.DetailView'           , 3, 'Currencies'      , 'edit'  , null, null, 'Currencies.MakeBase'   , null, 'Currencies.LBL_MAKE_BASE'   , 'Currencies.LBL_MAKE_BASE'   , null, 'return ConfirmChange();', null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'Currencies.DetailView'           , 4, 'Currencies'      , 'edit'  , null, null, 'Currencies.UpdateRate' , null, 'Currencies.LBL_UPDATE_RATE' , 'Currencies.LBL_UPDATE_RATE' , null, null, null;
end -- if;
GO

-- 04/01/2019 Paul.  Add Shortcuts module for Admin API. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Shortcuts.DetailView'      , 'Shortcuts'      ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'DynamicButtons.DetailView' , 'DynamicButtons' ;
-- 02/21/2021 Paul.  Languages for React client. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'Languages.DetailView'      , 'Languages'      ;
-- 02/21/2021 Paul.  iFrames for React client. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.DetailView', 'iFrames.DetailView'        , 'iFrames'        ;
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

call dbo.spDYNAMIC_BUTTONS_DetailView()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_DetailView')
/

-- #endif IBM_DB2 */

