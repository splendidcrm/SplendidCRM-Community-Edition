

print 'DYNAMIC_BUTTONS MassUpdate Archive';
GO

set nocount on;
GO

-- 09/26/2017 Paul.  Add Archive access right. 
-- delete from DYNAMIC_BUTTONS where COMMAND_NAME like 'Archive.%';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.MassUpdate' and COMMAND_NAME = 'Archive.MoveData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Accounts.MassUpdate'                   , -1, N'Button', 'Accounts'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Bugs.MassUpdate'                       , -1, N'Button', 'Bugs'           , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Calls.MassUpdate'                      , -1, N'Button', 'Calls'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Cases.MassUpdate'                      , -1, N'Button', 'Cases'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contacts.MassUpdate'                   , -1, N'Button', 'Contacts'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Documents.MassUpdate'                  , -1, N'Button', 'Documents'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Emails.MassUpdate'                     , -1, N'Button', 'Emails'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Leads.MassUpdate'                      , -1, N'Button', 'Leads'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Meetings.MassUpdate'                   , -1, N'Button', 'Meetings'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Notes.MassUpdate'                      , -1, N'Button', 'Notes'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Opportunities.MassUpdate'              , -1, N'Button', 'Opportunities'  , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Project.MassUpdate'                    , -1, N'Button', 'Project'        , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Prospects.MassUpdate'                  , -1, N'Button', 'Prospects'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Tasks.MassUpdate'                      , -1, N'Button', 'Tasks'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'SmsMessages.MassUpdate'                , -1, N'Button', 'SmsMessages'    , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'TwitterMessages.MassUpdate'            , -1, N'Button', 'TwitterMessages', 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'ChatMessages.MassUpdate'               , -1, N'Button', 'ChatMessages'   , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where COMMAND_NAME = 'Archive.RecoverData';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.MassUpdate.ArchiveView' and COMMAND_NAME = 'Archive.RecoverData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Accounts.MassUpdate.ArchiveView'       , -1, N'Button', 'Accounts'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Bugs.MassUpdate.ArchiveView'           , -1, N'Button', 'Bugs'           , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Calls.MassUpdate.ArchiveView'          , -1, N'Button', 'Calls'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Cases.MassUpdate.ArchiveView'          , -1, N'Button', 'Cases'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contacts.MassUpdate.ArchiveView'       , -1, N'Button', 'Contacts'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Documents.MassUpdate.ArchiveView'      , -1, N'Button', 'Documents'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Emails.MassUpdate.ArchiveView'         , -1, N'Button', 'Emails'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Leads.MassUpdate.ArchiveView'          , -1, N'Button', 'Leads'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Meetings.MassUpdate.ArchiveView'       , -1, N'Button', 'Meetings'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Notes.MassUpdate.ArchiveView'          , -1, N'Button', 'Notes'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Opportunities.MassUpdate.ArchiveView'  , -1, N'Button', 'Opportunities'  , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Project.MassUpdate.ArchiveView'        , -1, N'Button', 'Project'        , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Prospects.MassUpdate.ArchiveView'      , -1, N'Button', 'Prospects'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Tasks.MassUpdate.ArchiveView'          , -1, N'Button', 'Tasks'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'SmsMessages.MassUpdate.ArchiveView'    , -1, N'Button', 'SmsMessages'    , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'TwitterMessages.MassUpdate.ArchiveView', -1, N'Button', 'TwitterMessages', 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'ChatMessages.MassUpdate.ArchiveView'   , -1, N'Button', 'ChatMessages'   , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.ArchiveView' and COMMAND_NAME = 'Archive.RecoverData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Accounts.ArchiveView'                  , -1, N'Button', 'Accounts'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Bugs.ArchiveView'                      , -1, N'Button', 'Bugs'           , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Calls.ArchiveView'                     , -1, N'Button', 'Calls'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Cases.ArchiveView'                     , -1, N'Button', 'Cases'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contacts.ArchiveView'                  , -1, N'Button', 'Contacts'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Documents.ArchiveView'                 , -1, N'Button', 'Documents'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Emails.ArchiveView'                    , -1, N'Button', 'Emails'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Leads.ArchiveView'                     , -1, N'Button', 'Leads'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Meetings.ArchiveView'                  , -1, N'Button', 'Meetings'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Notes.ArchiveView'                     , -1, N'Button', 'Notes'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Opportunities.ArchiveView'             , -1, N'Button', 'Opportunities'  , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Project.ArchiveView'                   , -1, N'Button', 'Project'        , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Prospects.ArchiveView'                 , -1, N'Button', 'Prospects'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Tasks.ArchiveView'                     , -1, N'Button', 'Tasks'          , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'SmsMessages.ArchiveView'               , -1, N'Button', 'SmsMessages'    , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'TwitterMessages.ArchiveView'           , -1, N'Button', 'TwitterMessages', 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'ChatMessages.ArchiveView'              , -1, N'Button', 'ChatMessages'   , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Accounts.DetailView' and COMMAND_NAME = 'Archive.MoveData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Accounts.DetailView'                   , -1, N'Button', 'Accounts'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Bugs.DetailView'                       , -1, N'Button', 'Bugs'           , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Calls.DetailView'                      , -1, N'Button', 'Calls'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Cases.DetailView'                      , -1, N'Button', 'Cases'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contacts.DetailView'                   , -1, N'Button', 'Contacts'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Documents.DetailView'                  , -1, N'Button', 'Documents'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Emails.DetailView'                     , -1, N'Button', 'Emails'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Leads.DetailView'                      , -1, N'Button', 'Leads'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Meetings.DetailView'                   , -1, N'Button', 'Meetings'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Notes.DetailView'                      , -1, N'Button', 'Notes'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Opportunities.DetailView'              , -1, N'Button', 'Opportunities'  , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Project.DetailView'                    , -1, N'Button', 'Project'        , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Prospects.DetailView'                  , -1, N'Button', 'Prospects'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Tasks.DetailView'                      , -1, N'Button', 'Tasks'          , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'SmsMessages.DetailView'                , -1, N'Button', 'SmsMessages'    , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'TwitterMessages.DetailView'            , -1, N'Button', 'TwitterMessages', 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'ChatMessages.DetailView'               , -1, N'Button', 'ChatMessages'   , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
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

call dbo.spDYNAMIC_BUTTONS_Archive()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_Archive')
/

-- #endif IBM_DB2 */

