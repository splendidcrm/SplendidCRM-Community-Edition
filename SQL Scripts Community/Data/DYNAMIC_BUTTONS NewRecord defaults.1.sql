

print 'DYNAMIC_BUTTONS NewRecord defaults';
-- delete from DYNAMIC_BUTTONS where VIEW_NAME like 'NewRecord.%'
--GO

set nocount on;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'NewRecord.SaveOnly' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS NewRecord.SaveOnly';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.SaveOnly'  , 0, null, null  , null, null, 'NewRecord'         , null, '.LBL_SAVE_BUTTON_LABEL'     , '.LBL_SAVE_BUTTON_TITLE'     , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'NewRecord.WithCancel' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS NewRecord.WithCancel';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.WithCancel', 0, null, null  , null, null, 'NewRecord'         , null, '.LBL_SAVE_BUTTON_LABEL'     , '.LBL_SAVE_BUTTON_TITLE'     , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.WithCancel', 1, null, null  , null, null, 'NewRecord.Cancel'  , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , null, null, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'NewRecord.FullForm' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS NewRecord.FullForm';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.FullForm'  , 0, null, null  , null, null, 'NewRecord'         , null, '.LBL_SAVE_BUTTON_LABEL'     , '.LBL_SAVE_BUTTON_TITLE'     , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.FullForm'  , 1, null, null  , null, null, 'NewRecord.Cancel'  , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'NewRecord.FullForm'  , 2, null, null  , null, null, 'NewRecord.FullForm', null, '.LBL_FULL_FORM_BUTTON_LABEL', '.LBL_FULL_FORM_BUTTON_TITLE', null, null, null;
end -- if;
GO

-- 11/29/2010 Paul.  Emails have a special Send button. 
-- 07/18/2013 Paul.  Cancel should be a special event that does not redirect the page. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.NewRecord' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS Emails.NewRecord';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.NewRecord'    , 0, 'Emails', 'edit', null, null, 'Send', null, 'Emails.LBL_SEND_BUTTON_LABEL', 'Emails.LBL_SEND_BUTTON_TITLE', null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsSave   'Emails.NewRecord'    , 1, 'Emails';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.NewRecord'    , 2, null, null  , null, null, 'NewRecord.Cancel'  , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , null, null, null;
end else begin
	if exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Emails.NewRecord' and COMMAND_NAME = 'Cancel' and CONTROL_TEXT = '.LBL_CANCEL_BUTTON_LABEL' and CONTROL_TYPE = 'ButtonLink' and ONCLICK_SCRIPT is null and DELETED = 0) begin -- then
		update DYNAMIC_BUTTONS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where VIEW_NAME         = 'Emails.NewRecord'
		   and COMMAND_NAME      = 'Cancel'
		   and CONTROL_TEXT      = '.LBL_CANCEL_BUTTON_LABEL'
		   and CONTROL_TYPE      = 'ButtonLink'
		   and ONCLICK_SCRIPT is null
		   and DELETED           = 0;
		exec dbo.spDYNAMIC_BUTTONS_InsButton 'Emails.NewRecord'    , 2, null, null  , null, null, 'NewRecord.Cancel'  , null, '.LBL_CANCEL_BUTTON_LABEL'   , '.LBL_CANCEL_BUTTON_TITLE'   , null, null, null;
	end -- if;
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

call dbo.spDYNAMIC_BUTTONS_NewRecord()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_NewRecord')
/

-- #endif IBM_DB2 */

