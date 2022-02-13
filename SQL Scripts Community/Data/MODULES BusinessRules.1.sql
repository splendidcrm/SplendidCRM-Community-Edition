

print 'MODULES BusinessRules';
GO

set nocount on;
GO

-- 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
exec dbo.spMODULES_InsertOnly null, 'BusinessRules', 'BusinessRules.LBL_LIST_FORM_TITLE', '~/Administration/BusinessRules/', 1, 0, 0, 0, 0, 0, 0, 1, 'RULES', 0, 0, 0, 0, 0, 0;
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

call dbo.spMODULES_BusinessRules()
/

call dbo.spSqlDropProcedure('spMODULES_BusinessRules')
/

-- #endif IBM_DB2 */

