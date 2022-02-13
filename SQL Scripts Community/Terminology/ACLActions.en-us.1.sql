

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY ACLActions en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_ALL'                                , N'en-US', N'ACLActions', null, null, N'All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_DISABLED'                           , N'en-US', N'ACLActions', null, null, N'Disabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_ENABLED'                            , N'en-US', N'ACLActions', null, null, N'Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_NONE'                               , N'en-US', N'ACLActions', null, null, N'None';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_NOT_SET'                            , N'en-US', N'ACLActions', null, null, N'Not Set';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_OWNER'                              , N'en-US', N'ACLActions', null, null, N'Owner';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_ACCESS'                             , N'en-US', N'ACLActions', null, null, N'Access';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_DELETE'                             , N'en-US', N'ACLActions', null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_EDIT'                               , N'en-US', N'ACLActions', null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_EXPORT'                             , N'en-US', N'ACLActions', null, null, N'Export';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_IMPORT'                             , N'en-US', N'ACLActions', null, null, N'Import';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_LIST'                               , N'en-US', N'ACLActions', null, null, N'List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_VIEW'                               , N'en-US', N'ACLActions', null, null, N'View';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTION_ARCHIVE'                            , N'en-US', N'ACLActions', null, null, N'Archive';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_ARCHIVE'                            , N'en-US', N'ACLActions', null, null, N'Archive';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_VIEW'                               , N'en-US', N'ACLActions', null, null, N'View';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_NONE'                         , N'en-US', N'ACLActions', null, null, N'None';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_NOT_SET'                      , N'en-US', N'ACLActions', null, null, N'Not Set';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_OWNER_READ_ONLY'              , N'en-US', N'ACLActions', null, null, N'Owner Read Only';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_OWNER_READ_OWNER_WRITE'       , N'en-US', N'ACLActions', null, null, N'Owner Read/Owner Write';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_READ_ONLY'                    , N'en-US', N'ACLActions', null, null, N'Read Only';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_READ_OWNER_WRITE'             , N'en-US', N'ACLActions', null, null, N'Read/Owner Write';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_ACCESS_READ_WRITE'                   , N'en-US', N'ACLActions', null, null, N'Read/Write';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_PERMISSION'                          , N'en-US', N'ACLActions', null, null, N'Field Permission';
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

call dbo.spTERMINOLOGY_ACLActions_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ACLActions_en_us')
/
-- #endif IBM_DB2 */
