

print 'TERMINOLOGY NAICS Codes en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'NAICSCodes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'NAICSCodes', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'NAICSCodes', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'NAICSCodes', null, null, N'NAICS Code List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'NAICSCodes', null, null, N'NAICS Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'NAICSCodes', null, null, N'NAICS Code:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAICS_CODES'                               , N'en-US', N'NAICSCodes', null, null, N'NAICS Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_NAICS_CODE'                            , N'en-US', N'NAICSCodes', null, null, N'Create NAICS Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NAICS_CODE_LIST'                           , N'en-US', N'NAICSCodes', null, null, N'NAICS Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'NAICSCodes', null, null, N'Create NAICS Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_NAICS_SET'                             , N'en-US', N'NAICSCodes', null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPLACE_NAICS_SET'                         , N'en-US', N'NAICSCodes', null, null, N'Replace';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIMARY_NAICS_CODE'                   , N'en-US', N'NAICSCodes', null, null, N'Primary';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_NAICS_CODE'                        , N'en-US', N'NAICSCodes', null, null, N'Invalid NAICS Code';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NAICS_CODE_NOT_FOUND'                      , N'en-US', N'NAICSCodes', null, null, N'NAICS Code not found';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAICS_SET_NAME'                            , N'en-US', N'NAICSCodes', null, null, N'NAICS Codes:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAICS_SET_NAME'                       , N'en-US', N'NAICSCodes', null, null, N'NAICS';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'NAICSCodes', null, null, N'NAICSCodes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'NAICSCodes', null, null, N'NC';
-- select * from vwTERMINOLOGY where LIST_NAME = 'moduleList' order by LIST_ORDER desc;
exec dbo.spTERMINOLOGY_InsertOnly N'NAICSCodes'                                    , N'en-US', null, N'moduleList',  168, N'NAICSCodes';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_NAICS_CODES_TITLE'                  , N'en-US', N'Administration', null, null, N'NAICS Codes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_NAICS_CODES'                        , N'en-US', N'Administration', null, null, N'NAICS Codes';
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

call dbo.spTERMINOLOGY_NAICSCodes_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_NAICSCodes_en_us')
/
-- #endif IBM_DB2 */

