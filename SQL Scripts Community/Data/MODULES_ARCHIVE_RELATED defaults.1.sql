

print 'MODULES_ARCHIVE_RELATED defaults';
GO

set nocount on;
GO


if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Activities') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'Calls'          ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'Meetings'       ,  1;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'Notes'          ,  2;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'Tasks'          ,  3;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'Emails'         ,  4;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'SmsMessages'    ,  5;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'TwitterMessages',  6;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Activities', 'ChatMessages'   ,  7;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Accounts') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Bugs'         ,  1;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Cases'        ,  2;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Contacts'     ,  3;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Documents'    ,  4;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Leads'        ,  5;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Opportunities',  6;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Accounts', 'Project'      ,  7;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Contacts') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Bugs'         ,  1;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Cases'        ,  2;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Documents'    ,  3;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Leads'        ,  4;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Opportunities',  5;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Contacts', 'Project'      ,  6;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Leads') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Leads'   , 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Leads'   , 'Documents'    ,  1;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Leads'   , 'Opportunities',  2;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Prospects') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Prospects', 'Activities'  ,  0;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Opportunities') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Opportunities', 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Opportunities', 'Project'      ,  1;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Cases') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Cases'   , 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Cases'   , 'Bugs'         ,  1;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Cases'   , 'Documents'    ,  2;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Cases'   , 'Project'      ,  3;
end -- if;
GO

if not exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = 'Bugs') begin -- then
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Bugs'    , 'Activities'   ,  0;
	exec dbo.spMODULES_ARCHIVE_RELATED_InsertOnly 'Bugs'    , 'Documents'    ,  1;
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

call dbo.spMODULES_ARCHIVE_RELATED_Defaults()
/

call dbo.spSqlDropProcedure('spMODULES_ARCHIVE_RELATED_Defaults')
/

-- #endif IBM_DB2 */

