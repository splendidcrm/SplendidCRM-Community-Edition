

print 'DYNAMIC_BUTTONS EditView SaveDuplicate';

set nocount on;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Accounts.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Bugs.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Campaigns.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Cases.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Contacts.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Documents.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailTemplates.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'EmailTemplates.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Leads.EditView', -1, null;
end -- if;
GO

-- 03/22/2016 Paul.  Duplicate check during conversion. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.ConvertView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Leads.ConvertView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Opportunities.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Project.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'ProjectTask.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'ProspectLists.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Prospects.EditView', -1, null;
end -- if;
GO

-- 03/22/2016 Paul.  Duplicate check during conversion. 
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.ConvertView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Prospects.ConvertView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.EditView' and COMMAND_NAME = 'SaveDuplicate' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveDuplicate 'Tasks.EditView', -1, null;
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

call dbo.spDYNAMIC_BUTTONS_EditViewSaveDup()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_EditViewSaveDup')
/

-- #endif IBM_DB2 */

