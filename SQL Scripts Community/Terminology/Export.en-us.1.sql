

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Export en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Export', null, null, N'Export List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RECORDS'                                   , N'en-US', N'Export', null, null, N'{0} records';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Export', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABLE_NAME'                                , N'en-US', N'Export', null, null, N'Table Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABLE_STATUS'                              , N'en-US', N'Export', null, null, N'Table Status';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Export', null, null, N'Exp';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Export'                                        , N'en-US', null, N'moduleList'                        ,  68, N'Export';
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

call dbo.spTERMINOLOGY_Export_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Export_en_us')
/
-- #endif IBM_DB2 */
