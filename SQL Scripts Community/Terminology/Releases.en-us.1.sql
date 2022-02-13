

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Releases en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Releases', null, null, N'Create Release';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_RELEASE_NOT_FOUND'                         , N'en-US', N'Releases', null, null, N'Release Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Releases', null, null, N'Release List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LIST_ORDER'                           , N'en-US', N'Releases', null, null, N'List Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Releases', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ORDER'                                , N'en-US', N'Releases', null, null, N'List Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Releases', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Releases', null, null, N'Releases';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Releases', null, null, N'Rel';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Releases', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELEASE'                                   , N'en-US', N'Releases', null, null, N'Release:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Releases', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_RELEASE'                               , N'en-US', N'Releases', null, null, N'Create Release';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_LIST_ORDER'                                , N'en-US', N'Releases', null, null, N'Set the order within the list.';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_STATUS'                                    , N'en-US', N'Releases', null, null, N'Set to inactive to hide this item.';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Releases'                                      , N'en-US', null, N'moduleList'                        ,  27, N'Releases';

exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'release_status_dom'                ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Inactive'                                      , N'en-US', null, N'release_status_dom'                ,   2, N'Inactive';
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

call dbo.spTERMINOLOGY_Releases_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Releases_en_us')
/
-- #endif IBM_DB2 */
