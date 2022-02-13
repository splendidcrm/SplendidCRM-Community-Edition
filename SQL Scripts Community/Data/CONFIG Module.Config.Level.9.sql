

print 'CONFIG Asterisk';
GO

set nocount on;
GO

-- 07/15/2020 Paul.  We need a module configuration level to determine if we can modify/enable REST flag for React Client. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'Module.Config.Level', '13.0';
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

call dbo.spCONFIG_Modules()
/

call dbo.spSqlDropProcedure('spCONFIG_Modules')
/

-- #endif IBM_DB2 */

