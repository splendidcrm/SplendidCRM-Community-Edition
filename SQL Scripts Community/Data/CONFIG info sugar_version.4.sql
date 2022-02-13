

-- 07/16/2005 Paul.  Version 3.0.1. 
-- 09/16/2005 Paul.  Version 3.5.0. 
-- 11/21/2005 Paul.  Version 3.5.1. 
-- 06/06/2005 Paul.  Version 4.2.0
-- 01/01/2008 Paul.  Version 4.5.0
-- 08/31/2010 Paul.  Version 6.0.0 compatibility due to addition of email client. 
if not exists(select *
                from CONFIG
               where CATEGORY = 'info'
                 and NAME     = 'sugar_version'
                 and cast(VALUE as varchar(255)) = '6.0.0'
             ) begin -- then
	print 'CONFIG info sugar_version 6.0.0';
	exec dbo.spCONFIG_Update null, 'info', 'sugar_version', '6.0.0';
end -- if;
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

call dbo.spCONFIG_SugarVersion()
/

call dbo.spSqlDropProcedure('spCONFIG_SugarVersion')
/

-- #endif IBM_DB2 */

