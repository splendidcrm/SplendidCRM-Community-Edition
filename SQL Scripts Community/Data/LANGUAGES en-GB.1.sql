

print 'LANGUAGES en-GB';
GO

-- 05/19/2008 Paul.  Unicode strings must be marked as such, otherwise unicode will go in as ???.
-- 03/19/2019 Paul.  Default to inactive. 
exec dbo.spLANGUAGES_InsertOnly N'en-GB'     ,  2057, 0, N'English (United Kingdom)', N'English (United Kingdom)';
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

call dbo.spLANGUAGES_en_GB()
/

call dbo.spSqlDropProcedure('spLANGUAGES_en_GB')
/

-- #endif IBM_DB2 */

