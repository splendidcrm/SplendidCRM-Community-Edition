

print 'SCHEDULERS CurrencyLayer';
GO

set nocount on;
GO

-- 05/02/2016 Paul.  Check for currency updates. 
-- delete from SCHEDULERS where job = 'function::pollCurrency'
exec dbo.spSCHEDULERS_InsertOnly null, N'Check Currency updates during business hours', N'function::pollCurrency', null, null, N'0::7-19::*::*::1-5', null, null, N'Inactive', 0;


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

call dbo.spSCHEDULERS_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spSCHEDULERS_CurrencyLayer')
/

-- #endif IBM_DB2 */

