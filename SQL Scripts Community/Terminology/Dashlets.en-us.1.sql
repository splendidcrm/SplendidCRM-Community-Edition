

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY Dashlets en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTROL_NAME'                              , N'en-US', N'Dashlets', null, null, N'Control Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHLET_ENABLED'                           , N'en-US', N'Dashlets', null, null, N'Dashlet Enabled:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHLET_ORDER'                             , N'en-US', N'Dashlets', null, null, N'Dashlet Order:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CONTROL_NAME'                         , N'en-US', N'Dashlets', null, null, N'Control Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DASHLET_ENABLED'                      , N'en-US', N'Dashlets', null, null, N'Dashlet Enabled';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DASHLET_ORDER'                        , N'en-US', N'Dashlets', null, null, N'Dashlet Order';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Dashlets', null, null, N'Module Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TITLE'                                , N'en-US', N'Dashlets', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Dashlets', null, null, N'Module Name:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Dashlets', null, null, N'Dsl';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TITLE'                                     , N'en-US', N'Dashlets', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DISABLE'                                   , N'en-US', N'Dashlets', null, null, N'Disable';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DOWN'                                      , N'en-US', N'Dashlets', null, null, N'Down';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ENABLE'                                    , N'en-US', N'Dashlets', null, null, N'Enable';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_UP'                                        , N'en-US', N'Dashlets', null, null, N'Up';
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

call dbo.spTERMINOLOGY_Dashlets_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Dashlets_en_us')
/
-- #endif IBM_DB2 */
