

print 'SHORTCUTS imports';
-- delete SHORTCUTS
GO

set nocount on;
GO


if not exists (select * from SHORTCUTS where MODULE_NAME = 'Accounts' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Accounts Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Accounts'              , '.LBL_IMPORT'                           , '~/Accounts/import.aspx'                 , 'Import.gif'              , 1,  3, 'Accounts', 'import';
end -- if;
-- 06/19/2010 Paul.  Add Bugs Import. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Bugs' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Bugs Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Bugs'                  , '.LBL_IMPORT'                           , '~/Bugs/import.aspx'                     , 'Import.gif'              , 1,  3, 'Bugs', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Contacts' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Contacts Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Contacts'              , '.LBL_IMPORT'                           , '~/Contacts/import.aspx'                 , 'Import.gif'              , 1,  5, 'Contacts', 'import';
end -- if;
-- 03/04/2010 Paul.  Fix Notes import. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Notes' and DISPLAY_NAME = 'Notes.LNK_IMPORT_NOTES' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Notes Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Notes'                 , 'Notes.LNK_IMPORT_NOTES'                , '~/Notes/import.aspx'                    , 'Import.gif'              , 1, 12, 'Notes', 'list';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Opportunities' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Opportunities Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Opportunities'         , '.LBL_IMPORT'                           , '~/Opportunities/import.aspx'            , 'Import.gif'              , 1,  3, 'Opportunities', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Leads' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Leads Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Leads'                 , '.LBL_IMPORT'                           , '~/Leads/import.aspx'                    , 'Import.gif'              , 1,  4, 'Leads', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Prospects' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Prospects Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Prospects'             , '.LBL_IMPORT'                           , '~/Prospects/import.aspx'                , 'Import.gif'              , 0,  7, 'Prospects', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Cases' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Cases Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Cases'                 , '.LBL_IMPORT'                           , '~/Cases/import.aspx'                    , 'Import.gif'              , 1,  3, 'Cases', 'import';
end -- if;
-- 03/03/2008 Paul.  Allow import into ProductTemplates. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ProductTemplates' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: ProductTemplates Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProductTemplates'      , '.LBL_IMPORT'                           , '~/Administration/ProductTemplates/import.aspx'          , 'Import.gif'           , 1,  6, 'ProductTemplates'  , 'import';
end -- if;
-- 03/13/2008 Paul.  Allow admin import into Users. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Users' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Users Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Users'                 , '.LBL_IMPORT'                           , '~/Users/import.aspx'                    , 'Import.gif'              , 1,  3, 'Users', 'import';
end -- if;

-- 11/14/2011 Paul.  Allow import into Calls, Meetings, Project, ProjectTask, Tasks. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Calls' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Calls Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Calls'                 , '.LBL_IMPORT'                           , '~/Calls/import.aspx'                    , 'Import.gif'              , 1, 12, 'Calls', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Meetings' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Meetings Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Meetings'              , '.LBL_IMPORT'                           , '~/Meetings/import.aspx'                 , 'Import.gif'              , 1, 12, 'Meetings', 'import';
end -- if;
-- 12/04/2011 Paul.  Folder name is Projects. 
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Project' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Project Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Project'               , '.LBL_IMPORT'                           , '~/Projects/import.aspx'                 , 'Import.gif'              , 1,  5, 'Project', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'ProjectTask' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: ProjectTask Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'ProjectTask'           , '.LBL_IMPORT'                           , '~/ProjectTask/import.aspx'              , 'Import.gif'              , 1,  5, 'ProjectTask', 'import';
end -- if;
if not exists (select * from SHORTCUTS where MODULE_NAME = 'Tasks' and DISPLAY_NAME = '.LBL_IMPORT' and DELETED = 0) begin -- then
	print 'SHORTCUTS: Tasks Import';
	exec dbo.spSHORTCUTS_InsertOnly null, 'Tasks'                 , '.LBL_IMPORT'                           , '~/Tasks/import.aspx'                    , 'Import.gif'              , 1, 12, 'Tasks', 'import';
end -- if;


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

call dbo.spSHORTCUTS_Imports()
/

call dbo.spSqlDropProcedure('spSHORTCUTS_Imports')
/

-- #endif IBM_DB2 */

