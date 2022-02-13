

exec dbo.spTERMINOLOGY_LIST_ReorderAll null;
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

call dbo.spTERMINOLOGY_LIST_ReorderAll_Defaults()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_LIST_ReorderAll_Defaults')
/

-- #endif IBM_DB2 */

