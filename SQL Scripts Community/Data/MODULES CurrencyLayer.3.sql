

print 'MODULES CurrencyLayer';
GO

set nocount on;
GO

-- 04/30/2016 Paul.  Add CurrencyLayer. 
exec dbo.spMODULES_InsertOnly null, 'CurrencyLayer'         , '.moduleList.CurrencyLayer'            , '~/Administration/CurrencyLayer/'    , 1, 0,  0, 0, 0, 0, 0, 1, null                 , 0, 0, 0, 0, 0, 0;


-- 08/24/2008 Paul.  Reorder the modules. 
exec dbo.spMODULES_Reorder null;
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

call dbo.spMODULES_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spMODULES_CurrencyLayer')
/

-- #endif IBM_DB2 */

