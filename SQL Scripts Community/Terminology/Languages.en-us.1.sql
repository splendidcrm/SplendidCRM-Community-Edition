

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:38 AM.
print 'TERMINOLOGY Languages en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTIVE'                                    , N'en-US', N'Languages', null, null, N'Active:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISPLAY_NAME'                              , N'en-US', N'Languages', null, null, N'Display Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LCID'                                      , N'en-US', N'Languages', null, null, N'LCID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ACTIVE'                               , N'en-US', N'Languages', null, null, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DISPLAY_NAME'                         , N'en-US', N'Languages', null, null, N'Display Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LCID'                                 , N'en-US', N'Languages', null, null, N'LCID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Languages', null, null, N'Language';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NATIVE_NAME'                          , N'en-US', N'Languages', null, null, N'Native Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Languages', null, null, N'Language:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NATIVE_NAME'                               , N'en-US', N'Languages', null, null, N'Native Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Languages', null, null, N'Lan';

-- 02/03/2021 Paul.  The React client requires the title. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Languages', null, null, N'Languages';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Languages'                                     , N'en-US', null, N'moduleList'         , 104, N'Languages';
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

call dbo.spTERMINOLOGY_Languages_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Languages_en_us')
/
-- #endif IBM_DB2 */
