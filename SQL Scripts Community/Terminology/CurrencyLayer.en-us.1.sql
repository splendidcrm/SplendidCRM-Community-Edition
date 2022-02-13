

print 'TERMINOLOGY CurrencyLayer en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'CurrencyLayer';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_CURRENCYLAYER_TITLE'                , N'en-US', N'CurrencyLayer', null, null, N'currencylayer';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_CURRENCYLAYER'                      , N'en-US', N'CurrencyLayer', null, null, N'Configure currencylayer Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENCYLAYER_SETTINGS'                    , N'en-US', N'CurrencyLayer', null, null, N'currencylayer Settings';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_KEY'                                , N'en-US', N'CurrencyLayer', null, null, N'Access Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLED'                                   , N'en-US', N'CurrencyLayer', null, null, N'Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOG_CONVERSIONS'                           , N'en-US', N'CurrencyLayer', null, null, N'Log Conversions:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RATE_LIFETIME'                             , N'en-US', N'CurrencyLayer', null, null, N'Rate Lifetime (minutes):';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_SUCCESSFUL'                           , N'en-US', N'CurrencyLayer', null, null, N'Connection successful.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYSTEM_CURRENCY_LOG'                       , N'en-US', N'CurrencyLayer', null, null, N'System Currency Log';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SOURCE_ISO4217'                       , N'en-US', N'CurrencyLayer', null, null, N'Source';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESTINATION_ISO4217'                  , N'en-US', N'CurrencyLayer', null, null, N'Destination';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CONVERSION_RATE'                      , N'en-US', N'CurrencyLayer', null, null, N'Rate';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSTRUCTIONS'                              , N'en-US', N'CurrencyLayer', null, null, N'';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_INSTRUCTIONS'                          , N'en-US', N'CurrencyLayer', null, null, N'<p>
In order to use CurrencyLayer, you need to get an access key from <a href="https://currencylayer.com/product">https://currencylayer.com/product</a>.
</p>';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'CurrencyLayer', null, null, N'CL';
GO

-- select * from vwTERMINOLOGY where LIST_NAME = 'moduleList' order by LIST_ORDER desc
exec dbo.spTERMINOLOGY_InsertOnly N'CurrencyLayer'                               , N'en-US', null, N'moduleList', 161, N'currencylayer';
GO

set nocount off;
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_CurrencyLayer_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_CurrencyLayer_en_us')
/
-- #endif IBM_DB2 */
