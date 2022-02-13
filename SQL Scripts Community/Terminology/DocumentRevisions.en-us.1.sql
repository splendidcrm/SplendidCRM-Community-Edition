

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY DocumentRevisions en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DOCUMENT_LIST'                             , N'en-US', N'DocumentRevisions', null, null, N'Documents';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_DOCUMENT'                              , N'en-US', N'DocumentRevisions', null, null, N'Create Document';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'DocumentRevisions', null, null, N'Document Revisions';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'DocumentRevisions', null, null, N'DoR';
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

call dbo.spTERMINOLOGY_DocumentRevisions_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_DocumentRevisions_en_us')
/
-- #endif IBM_DB2 */
