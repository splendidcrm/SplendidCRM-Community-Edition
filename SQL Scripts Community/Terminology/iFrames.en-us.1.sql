

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY iFrames en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_SITE'                                  , N'en-US', N'iFrames', null, null, N'Add Site';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'iFrames', null, null, N'Portal List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'iFrames', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PLACEMENT'                            , N'en-US', N'iFrames', null, null, N'Placement';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SITES'                                , N'en-US', N'iFrames', null, null, N'Sites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'iFrames', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TYPE'                                 , N'en-US', N'iFrames', null, null, N'Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_URL'                                  , N'en-US', N'iFrames', null, null, N'URL';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'iFrames', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PLACEMENT'                                 , N'en-US', N'iFrames', null, null, N'Placement:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'iFrames', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TYPE'                                      , N'en-US', N'iFrames', null, null, N'Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_URL'                                       , N'en-US', N'iFrames', null, null, N'URL:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'iFrames', null, null, N'iFr';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'iFrames'                                       , N'en-US', null, N'moduleList'                        ,  17, N'My Portal';
exec dbo.spTERMINOLOGY_InsertOnly N'iFrames'                                       , N'en-US', null, N'moduleListSingular'                ,  17, N'My Portal';

exec dbo.spTERMINOLOGY_InsertOnly N'all'                                           , N'en-US', null, N'DROPDOWN_PLACEMENT'                ,   1, N'All';
exec dbo.spTERMINOLOGY_InsertOnly N'tab'                                           , N'en-US', null, N'DROPDOWN_PLACEMENT'                ,   2, N'Tab';
exec dbo.spTERMINOLOGY_InsertOnly N'shortcut'                                      , N'en-US', null, N'DROPDOWN_PLACEMENT'                ,   3, N'Shortcut';

exec dbo.spTERMINOLOGY_InsertOnly N'personal'                                      , N'en-US', null, N'DROPDOWN_TYPE'                     ,   1, N'Personal';
exec dbo.spTERMINOLOGY_InsertOnly N'global'                                        , N'en-US', null, N'DROPDOWN_TYPE'                     ,   2, N'Global';
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

call dbo.spTERMINOLOGY_iFrames_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_iFrames_en_us')
/
-- #endif IBM_DB2 */
