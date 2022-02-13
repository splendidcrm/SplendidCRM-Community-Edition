

print 'DETAILVIEWS_RELATIONSHIPS CurrencyLayer';
--delete from DETAILVIEWS_RELATIONSHIPS
--GO

set nocount on;
GO

-- 04/30/2016 Paul.  Add CurrencyLayer. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'CurrencyLayer.DetailView';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'CurrencyLayer.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS CurrencyLayer.DetailView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'CurrencyLayer.DetailView' , 'CurrencyLayer'    , 'SystemCurrencyLog',  0, 'CurrencyLayer.LBL_SYSTEM_CURRENCY_LOG', 'vwSYSTEM_CURRENCY_LOG', null, 'DATE_ENTERED', 'desc';
end -- if;
GO

-- 03/09/2021 Paul.  The React client uses ConfigView. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'CurrencyLayer.ConfigView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS CurrencyLayer.ConfigView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'CurrencyLayer.ConfigView' , 'CurrencyLayer'    , 'SystemCurrencyLog',  0, 'CurrencyLayer.LBL_SYSTEM_CURRENCY_LOG', 'vwSYSTEM_CURRENCY_LOG', null, 'DATE_ENTERED', 'desc';
end -- if;
GO

-- 03/18/2021 Paul.  The React client uses ConfigView. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Currencies.DetailView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Currencies.ConfigView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Currencies.DetailView' , 'Currencies'    , 'SystemCurrencyLog',  0, 'CurrencyLayer.LBL_SYSTEM_CURRENCY_LOG', 'vwSYSTEM_CURRENCY_LOG', 'CURRENCY_ID', 'DATE_ENTERED', 'desc';
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_CurrencyLayer')
/

-- #endif IBM_DB2 */

