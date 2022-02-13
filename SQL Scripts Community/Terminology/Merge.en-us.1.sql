

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:38 AM.
print 'TERMINOLOGY Merge en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_PARENT'                             , N'en-US', N'Merge', null, null, N'Set As Primary';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DIFF_COL_VALUES'                           , N'en-US', N'Merge', null, null, N'Diff Col Values:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MERGE_RECORDS_WITH'                        , N'en-US', N'Merge', null, null, N'Merge Records With';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_FROM_MERGE'                         , N'en-US', N'Merge', null, null, N'Remove From Merge';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAME_COL_VALUES'                           , N'en-US', N'Merge', null, null, N'Same Col Values:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_MERGED_RECORD_BUTTON_LABEL'           , N'en-US', N'Merge', null, null, N'Save Merged Record';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_MERGED_RECORD_BUTTON_TITLE'           , N'en-US', N'Merge', null, null, N'Save Merged Record';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_ERROR'                              , N'en-US', N'Merge', null, null, N'Select Error';
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

call dbo.spTERMINOLOGY_Merge_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Merge_en_us')
/
-- #endif IBM_DB2 */
