

print 'TERMINOLOGY ZipCodes en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'ZipCodes';
-- 03/28/2019 Paul.  Every module should have a LBL_NEW_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'ZipCodes', null, null, N'Zip Codes';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ZipCodes', null, null, N'Zip Code:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CITY'                                      , N'en-US', N'ZipCodes', null, null, N'City:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATE'                                     , N'en-US', N'ZipCodes', null, null, N'State:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COUNTRY'                                   , N'en-US', N'ZipCodes', null, null, N'Country:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LONGITUDE'                                 , N'en-US', N'ZipCodes', null, null, N'Longitude:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LATITUDE'                                  , N'en-US', N'ZipCodes', null, null, N'Latitude:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIMEZONE_ID'                               , N'en-US', N'ZipCodes', null, null, N'Time Zone:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'ZipCodes', null, null, N'Zip Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CITY'                                 , N'en-US', N'ZipCodes', null, null, N'City';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATE'                                , N'en-US', N'ZipCodes', null, null, N'State';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_COUNTRY'                              , N'en-US', N'ZipCodes', null, null, N'Country';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LONGITUDE'                            , N'en-US', N'ZipCodes', null, null, N'Longitude';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LATITUDE'                             , N'en-US', N'ZipCodes', null, null, N'Latitude';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TIMEZONE_ID'                          , N'en-US', N'ZipCodes', null, null, N'Time Zone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ZIPCODE'                              , N'en-US', N'ZipCodes', null, null, N'Zip Code';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'ZipCodes', null, null, N'Zip Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ZIPCODE_LIST'                              , N'en-US', N'ZipCodes', null, null, N'Zip Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'ZipCodes', null, null, N'Zip Codes List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'ZipCodes', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_ZIPCODES'                             , N'en-US', N'ZipCodes', null, null, N'List Zip Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ZIPCODE'                               , N'en-US', N'ZipCodes', null, null, N'Create Zip Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_BY_ZIPCODE'                         , N'en-US', N'ZipCodes', null, null, N'Search by Zip Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOOKUP_BUTTON_LABEL'                       , N'en-US', N'ZipCodes', null, null, N'Lookup';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NOT_FOUND'                                 , N'en-US', N'ZipCodes', null, null, N'Zip Code not found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ZipCodes', null, null, N'Zip';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ZIPCODES_TITLE'                            , N'en-US', N'Administration', null, null, N'Manage Zip Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ZIPCODES'                                  , N'en-US', N'Administration', null, null, N'Edit or Import Zip Codes and Postal Codes.';

exec dbo.spTERMINOLOGY_InsertOnly N'ZipCodes'                                      , N'en-US', null, N'moduleList', 160, N'Zip Codes';
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

call dbo.spTERMINOLOGY_ZipCodes_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ZipCodes_en_us')
/
-- #endif IBM_DB2 */
