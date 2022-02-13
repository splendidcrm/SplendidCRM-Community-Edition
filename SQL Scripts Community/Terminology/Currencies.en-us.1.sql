

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Currencies en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Currencies';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONVERSION_RATE'                           , N'en-US', N'Currencies', null, null, N'Conversion Rate:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENCY'                                  , N'en-US', N'Currencies', null, null, N'Currency';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ISO4217'                                   , N'en-US', N'Currencies', null, null, N'ISO 4217 Code:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CONVERSION_RATE'                      , N'en-US', N'Currencies', null, null, N'Conversion Rate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Currencies', null, null, N'Create Currency';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Currencies', null, null, N'Currencies';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ISO4217'                              , N'en-US', N'Currencies', null, null, N'ISO 4217 Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Currencies', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RATE'                                 , N'en-US', N'Currencies', null, null, N'Rate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Currencies', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SYMBOL'                               , N'en-US', N'Currencies', null, null, N'Symbol';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Currencies', null, null, N'Currencies';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CURRENCY_LIST'                             , N'en-US', N'Currencies', null, null, N'Currencies';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CURRENCY'                              , N'en-US', N'Currencies', null, null, N'Create Currency';

-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Currencies', null, null, N'Cur';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Currencies', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Currencies', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYMBOL'                                    , N'en-US', N'Currencies', null, null, N'Symbol:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_US_DOLLAR'                                 , N'en-US', N'Currencies', null, null, N'US Dollar:';
-- 03/19/2019 Paul.  Missing RATE term. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RATE'                                      , N'en-US', N'Currencies', null, null, N'Rate:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEFAULT_CURRENCY'                     , N'en-US', N'Currencies', null, null, N'Default Currency';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_BASE_CURRENCY'                        , N'en-US', N'Currencies', null, null, N'Base Currency';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_CURRENCY'                          , N'en-US', N'Currencies', null, null, N'Default Currency:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BASE_CURRENCY'                             , N'en-US', N'Currencies', null, null, N'Base Currency:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAKE_DEFAULT'                              , N'en-US', N'Currencies', null, null, N'Make Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAKE_BASE'                                 , N'en-US', N'Currencies', null, null, N'Make Base';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATE_RATE'                               , N'en-US', N'Currencies', null, null, N'Update Rate';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_CONFIRM_CHANGE'                            , N'en-US', N'Currencies', null, null, N'Are you sure?';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Currencies'                                    , N'en-US', null, N'moduleList'                        ,  62, N'Currencies';

-- 10/17/2013 Paul.  currency_status_dom was inadvertantly deleted a while ago. 
exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'currency_status_dom'               ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Inactive'                                      , N'en-US', null, N'currency_status_dom'               ,   2, N'Inactive';
-- 05/01/2016 Paul.  List names should not include the module name. 
update TERMINOLOGY
   set DELETED           = 1
     , DATE_MODIFIED     = getdate()
     , DATE_MODIFIED_UTC = getutcdate()
 where LIST_NAME         = 'currency_status_dom'
   and MODULE_NAME       = 'Currencies'
   and DELETED           = 0;

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

call dbo.spTERMINOLOGY_Currencies_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Currencies_en_us')
/
-- #endif IBM_DB2 */
