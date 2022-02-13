

print 'CONFIG Company';
GO

set nocount on;
GO

-- 04/23/2008 Paul.  Company information is used in Quotes, Orders and Invoices.
exec dbo.spCONFIG_InsertOnly null, 'company', 'company_name'   , 'Company Name';
exec dbo.spCONFIG_InsertOnly null, 'company', 'company_address', 'Company Address';
exec dbo.spCONFIG_InsertOnly null, 'company', 'company_logo'   , '';
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

call dbo.spCONFIG_Company()
/

call dbo.spSqlDropProcedure('spCONFIG_Company')
/

-- #endif IBM_DB2 */

