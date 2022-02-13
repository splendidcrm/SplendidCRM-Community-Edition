

print 'GRIDVIEWS_COLUMNS SubPanel default';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME not like '%.ListView'
--GO

set nocount on;
GO


if exists(select * from GRIDVIEWS where VIEW_NAME = 'wSYSTEM_CURRENCY_LOG') begin -- then
	update GRIDVIEWS
	   set VIEW_NAME         = 'vwSYSTEM_CURRENCY_LOG'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where VIEW_NAME         = 'wSYSTEM_CURRENCY_LOG';
end -- if;
GO

-- 03/09/2021 Paul.  SystemCurrencyLog for the React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'CurrencyLayer.SystemCurrencyLog';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'CurrencyLayer.SystemCurrencyLog' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS CurrencyLayer.SystemCurrencyLog';
	exec dbo.spGRIDVIEWS_InsertOnly           'CurrencyLayer.SystemCurrencyLog', 'CurrencyLayer', 'vwSYSTEM_CURRENCY_LOG';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CurrencyLayer.SystemCurrencyLog', 1, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'       , 'DATE_ENTERED'          , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CurrencyLayer.SystemCurrencyLog', 2, '.LBL_LIST_CREATED_BY'                      , 'CREATED_BY'         , 'CREATED_BY'            , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CurrencyLayer.SystemCurrencyLog', 3, 'CurrencyLayer.LBL_LIST_SOURCE_ISO4217'     , 'SOURCE_ISO4217'     , 'SOURCE_ISO4217'        , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CurrencyLayer.SystemCurrencyLog', 4, 'CurrencyLayer.LBL_LIST_DESTINATION_ISO4217', 'DESTINATION_ISO4217', 'DESTINATION_ISO4217'   , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'CurrencyLayer.SystemCurrencyLog', 5, 'CurrencyLayer.LBL_LIST_CONVERSION_RATE'    , 'CONVERSION_RATE'    , 'CONVERSION_RATE'       , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'CurrencyLayer.SystemCurrenLog',  'CONVERSION_RATE', '{0:N3}';
end -- if;
GO

-- 03/18/2021 Paul.  SystemCurrencyLog for the React client. 
-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Currencies.SystemCurrencyLog';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Currencies.SystemCurrencyLog' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Currencies.SystemCurrencyLog';
	exec dbo.spGRIDVIEWS_InsertOnly           'Currencies.SystemCurrencyLog', 'CurrencyLayer', 'vwSYSTEM_CURRENCY_LOG';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Currencies.SystemCurrencyLog', 1, '.LBL_LIST_DATE_ENTERED'                    , 'DATE_ENTERED'       , 'DATE_ENTERED'          , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Currencies.SystemCurrencyLog', 2, '.LBL_LIST_CREATED_BY'                      , 'CREATED_BY'         , 'CREATED_BY'            , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Currencies.SystemCurrencyLog', 3, 'CurrencyLayer.LBL_LIST_SOURCE_ISO4217'     , 'SOURCE_ISO4217'     , 'SOURCE_ISO4217'        , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Currencies.SystemCurrencyLog', 4, 'CurrencyLayer.LBL_LIST_DESTINATION_ISO4217', 'DESTINATION_ISO4217', 'DESTINATION_ISO4217'   , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Currencies.SystemCurrencyLog', 5, 'CurrencyLayer.LBL_LIST_CONVERSION_RATE'    , 'CONVERSION_RATE'    , 'CONVERSION_RATE'       , '19%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateFormat null, 'Currencies.SystemCurrenLog',  'CONVERSION_RATE', '{0:N3}';
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

call dbo.spGRIDVIEWS_COLUMNS_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_CurrencyLayer')
/

-- #endif IBM_DB2 */

