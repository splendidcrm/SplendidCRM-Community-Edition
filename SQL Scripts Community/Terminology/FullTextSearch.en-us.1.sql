

print 'TERMINOLOGY FullTextSearch en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'FullTextSearch';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_FULLTEXT_SEARCH_TITLE'                    , N'en-US', N'FullTextSearch', null, null, N'Full-Text Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_FULLTEXT_SEARCH'                          , N'en-US', N'FullTextSearch', null, null, N'Manage Full-Text Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULLTEXTSEARCH_SETTINGS'                         , N'en-US', N'FullTextSearch', null, null, N'Full-Text Search Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                                 , N'en-US', N'FullTextSearch', null, null, N'Full-Text Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                               , N'en-US', N'FullTextSearch', null, null, N'Search';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                       , N'en-US', N'FullTextSearch', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABLE_NAME'                                      , N'en-US', N'FullTextSearch', null, null, N'Table Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_TEXT'                                     , N'en-US', N'FullTextSearch', null, null, N'Search Text:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULLTEXT_SUPPORTED'                              , N'en-US', N'FullTextSearch', null, null, N'Is Full-Text Search Supported?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUPPORTED_INSTRUCTIONS'                          , N'en-US', N'FullTextSearch', null, null, N'Full-Text Search is only supported with SQL Server.  You may need to upgrade to SQL Server Express with Advanced Services, Standard, Enterprise, Business or Web Editions.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULLTEXT_INSTALLED'                              , N'en-US', N'FullTextSearch', null, null, N'Is Full-Text Service Installed?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSTALLED_INSTRUCTIONS'                          , N'en-US', N'FullTextSearch', null, null, N'The Full-Text Service is not typically installed with SQL Server Express, so you may need to upgrade the SQL Server edition to include it.';
-- 10/19/2016 Paul.  sp_fulltext_database is only needed for SQL Server 2005. 
--exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULLTEXT_ENABLED'                                , N'en-US', N'FullTextSearch', null, null, N'Is Database Enable?';
--exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLED_INSTRUCTIONS'                            , N'en-US', N'FullTextSearch', null, null, N'The database will need to be enabled in order to support Full-Text Search.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULLTEXT_CATALOG_EXISTS'                         , N'en-US', N'FullTextSearch', null, null, N'Does the Catalog Exist?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATALOG_INSTRUCTIONS'                            , N'en-US', N'FullTextSearch', null, null, N'The catalog is where the Full-Text Search data is stored.  It will be created when the feature is enabled.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFFICE_SUPPORTED'                                , N'en-US', N'FullTextSearch', null, null, N'Is Office 2010 Filter Pack Installed?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFFICE_INSTRUCTIONS'                             , N'en-US', N'FullTextSearch', null, null, N'The Office 2010 Filter Pack can be downloaded from <a href="https://www.microsoft.com/en-us/download/details.aspx?id=17062">https://www.microsoft.com/en-us/download/details.aspx?id=17062</a>.  It must be installed on the SQL Server computer.
After installation, you may need to click the Enable button again and restart the SQL Server service.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PDF_SUPPORTED'                                   , N'en-US', N'FullTextSearch', null, null, N'Is Adobe PDF iFilter Installed?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PDF_INSTRUCTIONS'                                , N'en-US', N'FullTextSearch', null, null, N'PDF support is included in the SQL Server 2016 OS.  For older versions of Windows, 
the Adobe PDF iFilter can be downloaded from <a href="http://www.adobe.com/support/downloads/thankyou.jsp?ftpID=5542&fileID=5550">http://www.adobe.com/support/downloads/thankyou.jsp?ftpID=5542&fileID=5550</a>.  It must be installed on the SQL Server computer.
After installation, you may need to click the Enable button again above and restart the SQL Server service.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUPPORTED_DOCUMENT_TYPES'                        , N'en-US', N'FullTextSearch', null, null, N'Supported Document Types:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INDEXED_TABLES'                                  , N'en-US', N'FullTextSearch', null, null, N'Indexed Tables:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POPULATION_STATUS'                               , N'en-US', N'FullTextSearch', null, null, N'Population Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POPULATION_COUNT'                                , N'en-US', N'FullTextSearch', null, null, N'Population Item Count:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_POPULATION_DATE'                            , N'en-US', N'FullTextSearch', null, null, N'Population Date:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLE_BUTTON'                                   , N'en-US', N'FullTextSearch', null, null, N'Enable';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISABLE_BUTTON'                                  , N'en-US', N'FullTextSearch', null, null, N'Disable';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_BUTTON'                                     , N'en-US', N'FullTextSearch', null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REBUILD_INDEX_BUTTON'                            , N'en-US', N'FullTextSearch', null, null, N'Rebuild Index';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                             , N'en-US', N'FullTextSearch', null, null, N'FTS';
exec dbo.spTERMINOLOGY_InsertOnly N'FullTextSearch'                                      , N'en-US', null, N'moduleList',  166, N'FullTextSearch';
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

call dbo.spTERMINOLOGY_FullTextSearch_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_FullTextSearch_en_us')
/
-- #endif IBM_DB2 */
