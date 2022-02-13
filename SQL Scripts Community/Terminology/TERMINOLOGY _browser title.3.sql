

if not exists(select * from TERMINOLOGY where NAME = 'LBL_BROWSER_TITLE' and LANG = 'en-US' and MODULE_NAME is null and DISPLAY_NAME = 'SplendidCRM' and DELETED = 0) begin -- then
	exec dbo.spTERMINOLOGY_Update 'LBL_BROWSER_TITLE', 'en-US', null, null, null, 'SplendidCRM';
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

call dbo.spTERMINOLOGY_browser_title()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_browser_title')
/

-- #endif IBM_DB2 */

