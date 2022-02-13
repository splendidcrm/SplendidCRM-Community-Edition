

set nocount on;
GO

-- 05/16/2014 Paul.  We were using the @VIEW_NAME when we should have used @TABLE_NAME. 
if exists (select * from SYSTEM_REST_TABLES where TABLE_NAME = 'CONTACTS' and HAS_CUSTOM = 0 and DELETED = 0) begin -- then
	print 'SYSTEM_REST_TABLES: Fix HAS_CUSTOM. ';
	update SYSTEM_REST_TABLES
	   set HAS_CUSTOM        = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where HAS_CUSTOM        = 0
	   and TABLE_NAME        not like 'vw%'
	   and exists (select * from vwSqlTables where vwSqlTables.TABLE_NAME = SYSTEM_REST_TABLES.TABLE_NAME + '_CSTM')
	   and DELETED           = 0;
end -- if;
GO

-- 06/27/2014 Paul.  User Signatures should not have MODULE_NAME_RELATED specified. 
if exists(select * from SYSTEM_REST_TABLES where TABLE_NAME = 'vwUSERS_SIGNATURES' and MODULE_NAME_RELATED is not null) begin -- then
	print 'SYSTEM_REST_TABLES: Fix vwUSERS_SIGNATURES. ';
	update SYSTEM_REST_TABLES
	   set MODULE_NAME_RELATED = null
	     , DATE_MODIFIED       = getdate()
	     , DATE_MODIFIED_UTC   = getutcdate()
	 where TABLE_NAME          = 'vwUSERS_SIGNATURES'
	   and MODULE_NAME_RELATED is not null;
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

call dbo.spSYSTEM_REST_TABLES_maintenance()
/

call dbo.spSqlDropProcedure('spSYSTEM_REST_TABLES_maintenance')
/

-- #endif IBM_DB2 */

