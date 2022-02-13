

print 'DYNAMIC_BUTTONS ListView defaults';
-- delete from DYNAMIC_BUTTONS where VIEW_NAME like '%.ListView'
--GO

set nocount on;
GO


-- 07/16/2010 Paul.  Exchange can have different buttons than Imap. 
-- 09/12/2010 Paul.  Fix delete to be SQL-92 compliant. 
if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView' and DELETED = 0) begin -- then
	delete from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView';
end -- if;
GO

-- 01/25/2013 Paul.  Module name should be EmailClient, not Emails. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView.Exchange' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailClient.ListView.Exchange';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.ListView.Exchange' , 0, 'EmailClient'       , 'view'  , null, null, 'CheckMail'           , null, 'Emails.LBL_BUTTON_CHECK'                       , 'Emails.LBL_BUTTON_CHECK'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.ListView.Exchange' , 1, 'EmailClient'       , 'edit'  , null, null, 'Compose'             , null, 'Emails.LNK_NEW_SEND_EMAIL'                     , 'Emails.LNK_NEW_SEND_EMAIL'                     , null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView.Exchange' and MODULE_NAME = 'Emails' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set MODULE_NAME       = 'EmailClient'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'EmailClient.ListView.Exchange'
		   and MODULE_NAME       = 'Emails'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 01/25/2013 Paul.  Module name should be EmailClient, not Emails. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView.Imap' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailClient.ListView.Imap';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.ListView.Imap'      , 0, 'EmailClient'      , 'view'  , null, null, 'CheckMail'           , null, 'Emails.LBL_BUTTON_CHECK'                       , 'Emails.LBL_BUTTON_CHECK'                       , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.ListView.Imap'      , 1, 'EmailClient'      , 'edit'  , null, null, 'Compose'             , null, 'Emails.LNK_NEW_SEND_EMAIL'                     , 'Emails.LNK_NEW_SEND_EMAIL'                     , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'EmailClient.ListView.Imap'      , 2, 'EmailClient'      , 'edit'  , null, null, 'Settings'            , null, 'EmailClient.LBL_SETTINGS_BUTTON_LABEL'         , 'EmailClient.LBL_SETTINGS_BUTTON_TITLE'         , null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailClient.ListView.Imap' and MODULE_NAME = 'Emails' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set MODULE_NAME       = 'EmailClient'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'EmailClient.ListView.Imap'
		   and MODULE_NAME       = 'Emails'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.ImportView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.ImportView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS TwitterMessages.ImportView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.ImportView'      , 0, 'TwitterMessages' , 'edit'  , null, null, 'Search'              , null, 'TwitterMessages.LBL_BUTTON_SEARCH'           , 'TwitterMessages.LBL_BUTTON_SEARCH'           , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.ImportView'      , 1, 'TwitterMessages' , 'edit'  , null, null, 'SignIn'              , null, 'TwitterMessages.LBL_BUTTON_SIGNIN'           , 'TwitterMessages.LBL_BUTTON_SIGNIN'           , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.ImportView'      , 2, 'TwitterMessages' , 'edit'  , null, null, 'SignOut'             , null, 'TwitterMessages.LBL_BUTTON_SIGNOUT'          , 'TwitterMessages.LBL_BUTTON_SIGNOUT'          , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton    'TwitterMessages.ImportView'      , 3, 'TwitterMessages' , 'edit'  , null, null, 'Import'              , null, '.LBL_IMPORT'                                 , '.LBL_IMPORT'                                 , null, null, null;
end -- if;
GO

-- 06/06/2015 Paul.  New CheckAll buttons for Seven theme. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'CheckAll.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'CheckAll.ListView', 0, null, null, null, null, 'SelectPage' , '#' , null, '.LBL_SELECT_PAGE' , '.LBL_SELECT_PAGE' , null, null, null, 'SplendidGrid_CheckAll(1); return false';
	exec dbo.spDYNAMIC_BUTTONS_InsButton     'CheckAll.ListView', 1, null, null, null, null, 'SelectAll'  ,       null, '.LBL_SELECT_ALL'  , '.LBL_SELECT_ALL'  , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'CheckAll.ListView', 2, null, null, null, null, 'DeselectAll', '#' , null, '.LBL_DESELECT_ALL', '.LBL_DESELECT_ALL', null, null, null, 'SplendidGrid_CheckAll(0); return false;';
	update DYNAMIC_BUTTONS
	   set CONTROL_CSSCLASS = 'DataGridOtherButton'
	 where VIEW_NAME = 'CheckAll.ListView';
end -- if;
GO


-- 06/05/2015 Paul.  New buttons for Seven theme. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Accounts.ListView', 0, 'Accounts', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Bugs.ListView', 0, 'Bugs', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Calls.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Calls.ListView', 0, 'Calls', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Campaigns.ListView', 0, 'Campaigns', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Cases.ListView', 0, 'Cases', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Contacts.ListView', 0, 'Contacts', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Documents.ListView', 0, 'Documents', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Emails.ListView', 0, 'Emails', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailTemplates.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'EmailTemplates.ListView', 0, 'EmailTemplates', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Forums.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Forums.ListView', 0, 'Forums', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'iFrames.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'iFrames.ListView', 0, 'iFrames', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Leads.ListView', 0, 'Leads', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Meetings.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Meetings.ListView', 0, 'Meetings', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Notes.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Notes.ListView', 0, 'Notes', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Opportunities.ListView', 0, 'Opportunities', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Project.ListView', 0, 'Project', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ProjectTask.ListView', 0, 'ProjectTask', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ProspectLists.ListView', 0, 'ProspectLists', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Prospects.ListView', 0, 'Prospects', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'RulesWizard.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'RulesWizard.ListView', 0, 'RulesWizard', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'SmsMessages.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'SmsMessages.ListView', 0, 'SmsMessages', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO


if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Tasks.ListView', 0, 'Tasks', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'TwitterMessages.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'TwitterMessages.ListView', 0, 'TwitterMessages', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ACLRoles.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ACLRoles.ListView', 0, 'ACLRoles', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'BusinessRules.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'BusinessRules.ListView', 0, 'BusinessRules', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Dropdown.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Dropdown.ListView', 0, 'Dropdown', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'DynamicButtons.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'DynamicButtons.ListView', 0, 'DynamicButtons', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Employees.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Employees.ListView', 0, 'Employees', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'FieldValidators.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'FieldValidators.ListView', 0, 'FieldValidators', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ForumTypes.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ForumTypes.ListView', 0, 'ForumTypes', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'InboundEmail.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'InboundEmail.ListView', 0, 'InboundEmail', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'OutboundEmail.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'OutboundEmail.ListView', 0, 'OutboundEmail', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'OutboundSms.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'OutboundSms.ListView', 0, 'OutboundSms', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Releases.ListView', 0, 'Releases', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Schedulers.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Schedulers.ListView', 0, 'Schedulers', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Shortcuts.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Shortcuts.ListView', 0, 'Shortcuts', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Terminology.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Terminology.ListView', 0, 'Terminology', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Users.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Users.ListView', 0, 'Users', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

-- 05/07/2017 Paul.  Add HTML5 Dashboard. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Dashboard.MainView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Dashboard.MainView', 0, 'Dashboard', 'edit', null, null, 'Create', 'edit.aspx', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

-- 02/21/2021 Paul.  Languages buttons for React client. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Languages.ListView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Languages.ListView', 0, null, null  , null, null, 'Add'   , null, '.LBL_ADD_BUTTON_LABEL'   , '.LBL_ADD_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Languages.ListView', 1, null, null  , null, null, 'Cancel', null, '.LBL_CANCEL_BUTTON_LABEL', '.LBL_CANCEL_BUTTON_TITLE', null, null, null;
end -- if;
GO

-- 03/30/2021 Paul.  Add EmailMan for React client. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailMan.ListView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'EmailMan.ListView', 0, null, null  , null, null, 'SendQueued'   , null, '.LBL_CAMPAIGNS_SEND_QUEUED'   , '.LBL_CAMPAIGNS_SEND_QUEUED'   , null, null, null;
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

call dbo.spDYNAMIC_BUTTONS_ListView()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_ListView')
/

-- #endif IBM_DB2 */

