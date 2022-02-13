

print 'TERMINOLOGY ChatDashboard en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'ChatDashboard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                                , N'en-US', N'ChatDashboard', null, null, N'Chat Dashboard';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                        , N'en-US', N'ChatDashboard', null, null, N'ChD';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                            , N'en-US', N'ChatDashboard', null, null, N'Chat Dashboard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MORE'                                       , N'en-US', N'ChatDashboard', null, null, N'[+]';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LESS'                                       , N'en-US', N'ChatDashboard', null, null, N'[-]';

exec dbo.spTERMINOLOGY_InsertOnly N'ChatDashboard'                                  , N'en-US', null, N'moduleList', 120, N'Chat Dashboard';
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

call dbo.spTERMINOLOGY_ChatDashboard_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ChatDashboard_en_us')
/
-- #endif IBM_DB2 */

