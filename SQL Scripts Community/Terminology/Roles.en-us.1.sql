

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Roles en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALLOWED_MODULES'                           , N'en-US', N'Roles', null, null, N'Allowed Modules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGN_MODULES'                            , N'en-US', N'Roles', null, null, N'Assign Modules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Roles', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISALLOWED_MODULES'                        , N'en-US', N'Roles', null, null, N'Disallowed Modules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Roles', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Roles', null, null, N'Role List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULES'                              , N'en-US', N'Roles', null, null, N'Modules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Roles', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Roles', null, null, N'Roles';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Roles', null, null, N'Rol';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULES'                                   , N'en-US', N'Roles', null, null, N'Modules:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Roles', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROLE'                                      , N'en-US', N'Roles', null, null, N'Role';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'Roles', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ROLE'                                  , N'en-US', N'Roles', null, null, N'Create Role';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ROLES'                                     , N'en-US', N'Roles', null, null, N'Roles';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Roles'                                         , N'en-US', null, N'moduleList'                        ,  23, N'Roles';
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

call dbo.spTERMINOLOGY_Roles_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Roles_en_us')
/
-- #endif IBM_DB2 */
