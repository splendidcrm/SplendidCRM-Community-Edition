

print 'DYNAMIC_BUTTONS MassUpdate Archive Professional';
GO

set nocount on;
GO

-- 09/26/2017 Paul.  Add Archive access right. 
-- delete from DYNAMIC_BUTTONS where COMMAND_NAME like 'Archive.%';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contracts.MassUpdate' and COMMAND_NAME = 'Archive.MoveData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contracts.MassUpdate'                  , -1, N'Button', 'Contracts'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Quotes.MassUpdate'                     , -1, N'Button', 'Quotes'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Orders.MassUpdate'                     , -1, N'Button', 'Orders'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Invoices.MassUpdate'                   , -1, N'Button', 'Invoices'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'KBDocuments.MassUpdate'                , -1, N'Button', 'KBDocuments'    , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
end -- if;
GO

-- delete from DYNAMIC_BUTTONS where COMMAND_NAME = 'Archive.RecoverData';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contracts.MassUpdate.ArchiveView' and COMMAND_NAME = 'Archive.RecoverData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contracts.MassUpdate.ArchiveView'      , -1, N'Button', 'Contracts'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Quotes.MassUpdate.ArchiveView'         , -1, N'Button', 'Quotes'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Orders.MassUpdate.ArchiveView'         , -1, N'Button', 'Orders'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Invoices.MassUpdate.ArchiveView'       , -1, N'Button', 'Invoices'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'KBDocuments.MassUpdate.ArchiveView'    , -1, N'Button', 'KBDocuments'    , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, 'if ( !ValidateOne() ) return false;', null, 1;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contracts.ArchiveView' and COMMAND_NAME = 'Archive.RecoverData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contracts.ArchiveView'                 , -1, N'Button', 'Contracts'      , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Quotes.ArchiveView'                    , -1, N'Button', 'Quotes'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Orders.ArchiveView'                    , -1, N'Button', 'Orders'         , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Invoices.ArchiveView'                  , -1, N'Button', 'Invoices'       , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'KBDocuments.ArchiveView'               , -1, N'Button', 'KBDocuments'    , 'archive', null, null, '.LBL_RECOVER_DATA', '.LBL_RECOVER_DATA', null, N'button', null, null, 'Archive.RecoverData', null, null, null, null, 1;
end -- if;
GO

if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'Contracts.DetailView' and COMMAND_NAME = 'Archive.MoveData' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Contracts.DetailView'                  , -1, N'Button', 'Contracts'      , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Quotes.DetailView'                     , -1, N'Button', 'Quotes'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Orders.DetailView'                     , -1, N'Button', 'Orders'         , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'Invoices.DetailView'                   , -1, N'Button', 'Invoices'       , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
	exec dbo.spDYNAMIC_BUTTONS_InsertOnly 'KBDocuments.DetailView'                , -1, N'Button', 'KBDocuments'    , 'archive', null, null, '.LBL_ARCHIVE_DATA', '.LBL_ARCHIVE_DATA', null, N'button', null, null, 'Archive.MoveData', null, null, null, null, 1;
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

call dbo.spDYNAMIC_BUTTONS_Archive_Pro()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_Archive_Pro')
/

-- #endif IBM_DB2 */

