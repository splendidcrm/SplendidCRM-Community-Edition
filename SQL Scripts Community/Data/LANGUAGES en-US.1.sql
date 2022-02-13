

print 'LANGUAGES en-us';
GO

-- 05/19/2008 Paul.  Unicode strings must be marked as such, otherwise unicode will go in as ???.
exec dbo.spLANGUAGES_InsertOnly N'en-US',  1033, 1, N'English (United States)', N'English (United States)';
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

call dbo.spLANGUAGES_en_US()
/

call dbo.spSqlDropProcedure('spLANGUAGES_en_US')
/

-- #endif IBM_DB2 */

