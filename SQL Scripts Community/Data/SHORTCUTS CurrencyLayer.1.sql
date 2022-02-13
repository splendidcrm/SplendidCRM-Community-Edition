

print 'SHORTCUTS CurrencyLayer';
-- delete SHORTCUTS
GO

set nocount on;
GO

-- 05/03/2016 Paul.  Full editing of currencies requires shortcuts.  But, we don't need to allow creation as the list is prepopulated. 
-- delete from SHORTCUTS where MODULE_NAME = 'CurrencyLayer';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'CurrencyLayer' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'CurrencyLayer'         , 'Currencies.LNK_CURRENCY_LIST'            , '~/Administration/Currencies/default.aspx'                 , 'Currencies.gif'            , 1,  2, 'Currencies'   , 'list';
	exec dbo.spSHORTCUTS_InsertOnly null, 'CurrencyLayer'         , 'CurrencyLayer.LBL_CURRENCYLAYER_SETTINGS', '~/Administration/CurrencyLayer/default.aspx'              , 'CurrencyLayer.gif'         , 1,  3, 'CurrencyLayer', 'edit';
end -- if;
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

call dbo.spSHORTCUTS_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spSHORTCUTS_CurrencyLayer')
/

-- #endif IBM_DB2 */

