

print 'DYNAMIC_BUTTONS Popup defaults';
-- delete from DYNAMIC_BUTTONS where VIEW_NAME like '%.PopupView'
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.PopupView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .PopupView';
	exec dbo.spDYNAMIC_BUTTONS_InsPopupClear  '.PopupView', 0, null, 'list';
	exec dbo.spDYNAMIC_BUTTONS_InsPopupCancel '.PopupView', 1, null, 'list';
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Accounts.PopupView'         , 'Accounts'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Bugs.PopupView'             , 'Bugs'             ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Calls.PopupView'            , 'Calls'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Campaign.PopupView'         , 'Campaigns'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Cases.PopupView'            , 'Cases'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Contacts.PopupView'         , 'Contacts'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Documents.PopupView'        , 'Documents'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'EmailTemplates.PopupView'   , 'EmailTemplates'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Employees.PopupView'        , 'Employees'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Leads.PopupView'            , 'Leads'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Meetings.PopupView'         , 'Meetings'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Opportunities.PopupView'    , 'Opportunities'    ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Project.PopupView'          , 'Project'          ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'ProjectTask.PopupView'      , 'ProjectTask'      ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'ProspectLists.PopupView'    , 'ProspectLists'    ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Prospects.PopupView'        , 'Prospects'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Tasks.PopupView'            , 'Tasks'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Users.PopupView'            , 'Users'            ;

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Contacts.PopupEmail'        , 'Contacts'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'Emails.PopupEmailAddresses' , 'Emails'           ;
-- 11/23/2014 Paul.  Add ChatChannels module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'ChatChannels.PopupView'     , 'ChatChannels'     ;
GO

-- 11/22/2012 Paul.  EmailTemplates.PopupView uses standard PopupView buttons. 
/*
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailTemplates.PopupView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailTemplates.PopupView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton      'EmailTemplates.PopupView', 0, 'EmailTemplates', 'list', null, null, 'Create', null, '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_LABEL', '.LBL_CREATE_BUTTON_KEY', null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopupClear  'EmailTemplates.PopupView', 1, 'EmailTemplates', 'list';
	exec dbo.spDYNAMIC_BUTTONS_InsPopupCancel 'EmailTemplates.PopupView', 2, 'EmailTemplates', 'list';
end -- if;
*/
GO

-- 08/05/2010 Paul.  Change MultiSelect to use default buttons. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '.PopupMultiSelect' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS .PopupMultiSelect';
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     '.PopupMultiSelect', 0, null, 'list', null, null, 'SelectChecked();', null, '.LBL_SELECT_BUTTON_LABEL', '.LBL_SELECT_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsPopup     '.PopupMultiSelect', 1, null, 'list', null, null, 'Cancel();'       , null, '.LBL_DONE_BUTTON_LABEL'  , '.LBL_DONE_BUTTON_TITLE'  , null, null, null;
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Accounts.PopupMultiSelect'        , 'Accounts'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Bugs.PopupMultiSelect'            , 'Bugs'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Cases.PopupMultiSelect'           , 'Cases'           ;
-- 08/27/2008 Paul.  Add buttons to Contacts multi-select.  They were completely missing. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Contacts.PopupMultiSelect'        , 'Contacts'        ;
-- 04/29/2013 Paul.  Add buttons to Leads multi-select.  They were inadvertently deleted. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Leads.PopupMultiSelect'           , 'Leads'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Opportunities.PopupMultiSelect'   , 'Opportunities'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Project.PopupMultiSelect'         , 'Project'         ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'ProjectTask.PopupMultiSelect'     , 'ProjectTask'     ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'ProspectLists.PopupMultiSelect'   , 'ProspectLists'   ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Prospects.PopupMultiSelect'       , 'Prospects'       ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Users.PopupMultiSelect'           , 'Users'           ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'ACLRoles.PopupMultiSelect'        , null              ;
-- 05/04/2016 Paul.  Single role selection in layout editor. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView'       , 'ACLRoles.PopupView'               , null              ;
GO

-- 04/27/2012 Paul.  New images popup for use with CKEditor. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailImages.PopupView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS EmailImages.PopupView';
	exec dbo.spDYNAMIC_BUTTONS_InsPopupCancel 'EmailImages.PopupView', 1, null, 'list';
end -- if;
GO

-- 04/12/2016 Paul.  Add ZipCodes module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView'       , 'ZipCodes.PopupView'               , 'ZipCodes'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'ZipCodes.PopupMultiSelect'        , 'ZipCodes'        ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView'       , 'ZipCodes.PopupAddressView'        , 'ZipCodes'        ;
-- 05/12/2016 Paul.  Add Tags module. 
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView'       , 'Tags.PopupView'                   , 'Tags'            ;
exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupMultiSelect', 'Tags.PopupMultiSelect'            , 'Tags'            ;
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

call dbo.spDYNAMIC_BUTTONS_Popup()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_Popup')
/

-- #endif IBM_DB2 */

