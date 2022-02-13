

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Upgrade en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Upgrade', null, null, N'Upgrade';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Upgrade', null, null, N'Upg';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Upgrade'                                       , N'en-US', null, N'moduleList'                        ,  97, N'Upgrade';
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

call dbo.spTERMINOLOGY_Upgrade_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Upgrade_en_us')
/
-- #endif IBM_DB2 */
