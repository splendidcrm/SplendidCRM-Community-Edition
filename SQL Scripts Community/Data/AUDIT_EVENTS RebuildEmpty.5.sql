

	-- 01/22/2010 Paul.  Only rebuild if the table is empty. 
	if not exists(select * from AUDIT_EVENTS) begin -- then
		exec dbo.spAUDIT_EVENTS_Rebuild ;
	end -- i;f
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

call dbo.spAUDIT_EVENTS_RebuildEmpty()
/

call dbo.spSqlDropProcedure('spAUDIT_EVENTS_RebuildEmpty')
/

-- #endif IBM_DB2 */

