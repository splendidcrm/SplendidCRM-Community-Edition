

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY SavedSearch en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASCENDING'                                 , N'en-US', N'SavedSearch', null, null, N'Ascending';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCENDING'                                , N'en-US', N'SavedSearch', null, null, N'Descending';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DIRECTION'                                 , N'en-US', N'SavedSearch', null, null, N'Direction:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFY_CURRENT_SEARCH'                     , N'en-US', N'SavedSearch', null, null, N'Modify current search:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ORDER_BY_COLUMNS'                          , N'en-US', N'SavedSearch', null, null, N'Order By Column:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_SEARCH_AS'                            , N'en-US', N'SavedSearch', null, null, N'Save this search as:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_AFTER'                              , N'en-US', N'SavedSearch', null, null, N'On or After:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_BEFORE'                             , N'en-US', N'SavedSearch', null, null, N'Before:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'SavedSearch', null, null, N'Sav';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'SavedSearch'                                   , N'en-US', null, N'moduleList'                        ,  32, N'Saved Searches';
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

call dbo.spTERMINOLOGY_SavedSearch_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_SavedSearch_en_us')
/
-- #endif IBM_DB2 */
