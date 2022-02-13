

print 'DYNAMIC_BUTTONS EditView SaveConcurrency';

set nocount on;
GO

-- delete from DYNAMIC_BUTTONS where COMMAND_NAME = 'SaveConcurrency';

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Accounts.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Bugs.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Bugs.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Campaigns.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Campaigns.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Cases.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Cases.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contacts.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Contacts.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Documents.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Documents.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'EmailTemplates.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'EmailTemplates.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Leads.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Leads.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Opportunities.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Opportunities.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Project.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Project.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProjectTask.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'ProjectTask.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'ProspectLists.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'ProspectLists.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Prospects.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Prospects.EditView', -1, null;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Tasks.EditView' and COMMAND_NAME = 'SaveConcurrency' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsSaveConcurrency 'Tasks.EditView', -1, null;
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

