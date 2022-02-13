

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Shortcuts en-us';
GO

set nocount on;
GO

-- 03/28/2019 Paul.  Every module should have a LBL_NEW_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Shortcuts', null, null, N'Shortcuts';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISPLAY_NAME'                              , N'en-US', N'Shortcuts', null, null, N'Display Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMAGE_NAME'                                , N'en-US', N'Shortcuts', null, null, N'Image Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DISPLAY_NAME'                         , N'en-US', N'Shortcuts', null, null, N'Display Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Shortcuts', null, null, N'Shortcut List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IMAGE_NAME'                           , N'en-US', N'Shortcuts', null, null, N'Image Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Shortcuts', null, null, N'Module Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RELATIVE_PATH'                        , N'en-US', N'Shortcuts', null, null, N'Relative Path';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SHORTCUT_ACLTYPE'                     , N'en-US', N'Shortcuts', null, null, N'ACL Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SHORTCUT_ENABLED'                     , N'en-US', N'Shortcuts', null, null, N'Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SHORTCUT_MODULE'                      , N'en-US', N'Shortcuts', null, null, N'ACL Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SHORTCUT_ORDER'                       , N'en-US', N'Shortcuts', null, null, N'Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Shortcuts', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Shortcuts', null, null, N'Sho';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELATIVE_PATH'                             , N'en-US', N'Shortcuts', null, null, N'Relative Path:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHORTCUT_ACLTYPE'                          , N'en-US', N'Shortcuts', null, null, N'ACL Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHORTCUT_ENABLED'                          , N'en-US', N'Shortcuts', null, null, N'Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHORTCUT_MODULE'                           , N'en-US', N'Shortcuts', null, null, N'ACL Module:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHORTCUT_ORDER'                            , N'en-US', N'Shortcuts', null, null, N'Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DOWN'                                      , N'en-US', N'Shortcuts', null, null, N'Down';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_SHORTCUT'                              , N'en-US', N'Shortcuts', null, null, N'Create Shortcut';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SHORTCUT_LIST'                             , N'en-US', N'Shortcuts', null, null, N'Shortcuts';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_UP'                                        , N'en-US', N'Shortcuts', null, null, N'Up';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Shortcuts'                                     , N'en-US', null, N'moduleList'                        ,  66, N'Shortcuts';

-- 04/01/2019 Paul.  List needed for Admin API. 
exec dbo.spTERMINOLOGY_InsertOnly N'edit'                                          , N'en-US', null, N'shortcuts_acltype_dom'             ,   0, N'edit';
exec dbo.spTERMINOLOGY_InsertOnly N'list'                                          , N'en-US', null, N'shortcuts_acltype_dom'             ,   1, N'list';
exec dbo.spTERMINOLOGY_InsertOnly N'import'                                        , N'en-US', null, N'shortcuts_acltype_dom'             ,   2, N'import';
exec dbo.spTERMINOLOGY_InsertOnly N'view'                                          , N'en-US', null, N'shortcuts_acltype_dom'             ,   3, N'view';
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

call dbo.spTERMINOLOGY_Shortcuts_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Shortcuts_en_us')
/
-- #endif IBM_DB2 */
