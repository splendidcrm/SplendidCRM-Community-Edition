

print 'DYNAMIC_BUTTONS MassUpdate RulesWizard';
GO

set nocount on;
GO

-- 08/16/2017 Paul.  Update button target access rights so RulesWizard can be disabled by a role. 

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'RulesWizard.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'RulesWizard.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS RulesWizard.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'RulesWizard.EditView'    , 0, 'RulesWizard'     , 'edit', null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'        , '.LBL_SAVE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'RulesWizard.EditView'    , 1, null              , null  , null              , null, 'Filter.Preview'          , null, 'RulesWizard.LBL_PREVIEW_FILTER', 'RulesWizard.LBL_PREVIEW_FILTER', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'RulesWizard.EditView'    , 2, null              , null  , null              , null, 'Rules.Preview'           , null, 'RulesWizard.LBL_PREVIEW_RULES' , 'RulesWizard.LBL_PREVIEW_RULES' , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'RulesWizard.EditView'    , 3, null              , null  , null              , null, 'Rules.Submit'            , null, 'RulesWizard.LBL_SUBMIT_RULES'  , 'RulesWizard.LBL_SUBMIT_RULES'  , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'RulesWizard.EditView'    , 4, 'RulesWizard'     , 0;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.MassUpdate' and COMMAND_NAME = 'RulesWizard';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Accounts MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Accounts.MassUpdate'      , -1, 'Accounts'      , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Accounts'     , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Bugs MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Bugs.MassUpdate'          , -1, 'Bugs'          , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Bugs'         , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Calls.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then                                                       
	print 'DYNAMIC_BUTTONS Calls MassUpdate RulesWizard';                                                                                                                         
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Calls.MassUpdate'         , -1, 'Calls'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Calls'        , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Campaigns MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Campaigns.MassUpdate'     , -1, 'Campaigns'     , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Campaigns'    , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Cases MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Cases.MassUpdate'         , -1, 'Cases'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Cases'        , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Contacts MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Contacts.MassUpdate'      , -1, 'Contacts'      , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Contacts'     , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Documents MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Documents.MassUpdate'     , -1, 'Documents'     , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Documents'    , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Emails.MassUpdate'        , -1, 'Emails'        , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Emails'       , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Leads MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Leads.MassUpdate'         , -1, 'Leads'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Leads'        , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Meetings.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Meetings MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Meetings.MassUpdate'      , -1, 'Meetings'      , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Meetings'     , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Notes.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Notes MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Notes.MassUpdate'         , -1, 'Notes'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Notes'        , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Opportunities MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Opportunities.MassUpdate' , -1, 'Opportunities' , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Opportunities', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Project MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Project.MassUpdate'       , -1, 'Project'       , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Project'      , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

-- 03/21/2012 Paul.  Delete any excess Rules Wizard buttons. 
if exists(select count(*)
            from vwDYNAMIC_BUTTONS
           where VIEW_NAME    = 'ProjectTask.MassUpdate'
             and COMMAND_NAME = 'RulesWizard'
             and DEFAULT_VIEW = 0
           group by MODULE_NAME, VIEW_NAME, COMMAND_NAME, CONTROL_TEXT
           having count(*) > 1) begin -- then
	print 'DYNAMIC_BUTTONS ProjectTask MassUpdate: Remove duplicate RulesWizard buttons';
	update DYNAMIC_BUTTONS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where VIEW_NAME         = 'ProjectTask.MassUpdate'
	   and COMMAND_NAME      = 'RulesWizard'
	   and DELETED           = 0;
end -- if;
GO

-- 03/21/2012 Paul.  Filter was not properly checking Prospects.MassUpdate. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProjectTask MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ProjectTask.MassUpdate'   , -1, 'ProjectTask'   , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=ProjectTask'  , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS ProspectLists MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'ProspectLists.MassUpdate' , -1, 'ProspectLists' , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=ProspectLists', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

-- 03/21/2012 Paul.  Delete any excess Rules Wizard buttons. 
if exists(select count(*)
            from vwDYNAMIC_BUTTONS
           where VIEW_NAME    = 'Prospects.MassUpdate'
             and COMMAND_NAME = 'RulesWizard'
             and DEFAULT_VIEW = 0
           group by MODULE_NAME, VIEW_NAME, COMMAND_NAME, CONTROL_TEXT
           having count(*) > 1) begin -- then
	print 'DYNAMIC_BUTTONS Prospects MassUpdate: Remove duplicate RulesWizard buttons';
	update DYNAMIC_BUTTONS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where VIEW_NAME         = 'Prospects.MassUpdate'
	   and COMMAND_NAME      = 'RulesWizard'
	   and DELETED           = 0;
end -- if;
GO

-- 03/21/2012 Paul.  Filter was not properly checking Prospects.MassUpdate. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Prospects MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Prospects.MassUpdate'     , -1, 'Prospects'     , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Prospects'    , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end -- if;
GO

-- 02/24/2021 Paul.  The React client does not work well with ../.  It replaces with ~/ and that is not correct for admin pages. 
-- 10/27/2011 Paul.  Fix location of RulesWizard. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Releases MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Releases.MassUpdate'      , -1, 'Releases'      , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '~/RulesWizard/edit.aspx?Module=Releases', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.MassUpdate' and COMMAND_NAME = 'RulesWizard' and URL_FORMAT = '../Administration/RulesWizard/edit.aspx?Module=Releases' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Releases MassUpdate RulesWizard: Fix URL Format.';
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Releases.MassUpdate'
		   and COMMAND_NAME      = 'RulesWizard'
		   and URL_FORMAT        = '../Administration/RulesWizard/edit.aspx?Module=Releases'
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Releases.MassUpdate'      , -1, 'Releases'      , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '~/RulesWizard/edit.aspx?Module=Releases', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
	end -- if;
	-- 02/24/2021 Paul.  The React client does not work well with ../.  It replaces with ~/ and that is not correct for admin pages. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Releases.MassUpdate' and URL_FORMAT like '../../RulesWizard%' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set URL_FORMAT        = replace(URL_FORMAT, '../../', '~/')
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Releases.MassUpdate'
		   and URL_FORMAT        like '../../RulesWizard%'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 12/30/2010 Paul.  Add buttons for Tasks. 
-- 10/27/2011 Paul.  Fix location of RulesWizard. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Tasks MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Tasks.MassUpdate'         , -1, 'Tasks'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Tasks', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.MassUpdate' and COMMAND_NAME = 'RulesWizard' and URL_FORMAT = '../Administration/RulesWizard/edit.aspx?Module=Releases' and DELETED = 0) begin -- then
		print 'DYNAMIC_BUTTONS Tasks MassUpdate RulesWizard: Fix URL Format.';
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where VIEW_NAME         = 'Tasks.MassUpdate'
		   and COMMAND_NAME      = 'RulesWizard'
		   and URL_FORMAT        = '../Administration/RulesWizard/edit.aspx?Module=Releases'
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Tasks.MassUpdate'         , -1, 'Tasks'         , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '../RulesWizard/edit.aspx?Module=Tasks', null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
	end -- if;
end -- if;
GO

-- 11/10/2010 Paul.  Professional modules. 
-- 12/30/2010 Paul.  Move professional modules to a separate file. 

-- 03/29/2012 Paul.  Add Rules Wizard support to Terminology module. 
-- 02/24/2021 Paul.  The React client does not work well with ../.  It replaces with ~/ and that is not correct for admin pages. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'Terminology.MassUpdate' and COMMAND_NAME = 'RulesWizard';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Terminology.MassUpdate' and COMMAND_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Terminology MassUpdate RulesWizard';
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink 'Terminology.MassUpdate'   , -1, 'Terminology'   , 'edit', 'RulesWizard', 'edit', 'RulesWizard', '~/RulesWizard/edit.aspx?Module=Terminology'  , null, 'RulesWizard.LBL_RULES_WIZARD_BUTTON_LABEL', 'RulesWizard.LBL_RULES_WIZARD_BUTTON_TITLE', null, null, null, null;
end else begin
	-- 02/24/2021 Paul.  The React client does not work well with ../.  It replaces with ~/ and that is not correct for admin pages. 
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Terminology.MassUpdate' and URL_FORMAT like '../../RulesWizard%' and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set URL_FORMAT        = replace(URL_FORMAT, '../../', '~/')
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Terminology.MassUpdate'
		   and URL_FORMAT        like '../../RulesWizard%'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- 08/16/2017 Paul.  Update button target access rights so RulesWizard can be disabled by a role. 
if exists(select * from DYNAMIC_BUTTONS where COMMAND_NAME = 'RulesWizard' and TARGET_NAME is null and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS RulesWizard: Update target access rights.';
	update DYNAMIC_BUTTONS
	   set TARGET_NAME        = 'RulesWizard'
	     , TARGET_ACCESS_TYPE = 'edit'
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC  = getutcdate()
	 where COMMAND_NAME       = 'RulesWizard'
	   and TARGET_NAME        is null
	   and DELETED            = 0;
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

call dbo.spDYNAMIC_BUTTONS_RulesWizard()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_RulesWizard')
/

-- #endif IBM_DB2 */

