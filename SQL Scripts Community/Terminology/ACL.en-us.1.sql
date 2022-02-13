

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:34 AM.
print 'TERMINOLOGY ACL en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSUFFICIENT_ACCESS'                       , N'en-US', N'ACL', null, null, N'Insufficient Access';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NO_ACCESS'                                 , N'en-US', N'ACL', null, null, N'Access denied.';
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

call dbo.spTERMINOLOGY_ACL_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ACL_en_us')
/
-- #endif IBM_DB2 */
