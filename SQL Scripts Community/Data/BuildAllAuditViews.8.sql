

set nocount on;
GO

-- 06/02/2009 Paul.  This view must be run after the data for the MODULES table has been loaded. 
-- 12/19/2017 Paul.  Don't create the audit tables on an Offline Client database. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_SYNC_CONFIG' and TABLE_TYPE = 'BASE TABLE') begin -- then
	exec dbo.spSqlBuildAllAuditViews ;
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

call dbo.spMODULES_BuildAllAuditViews()
/

call dbo.spSqlDropProcedure('spMODULES_BuildAllAuditViews')
/

-- #endif IBM_DB2 */

