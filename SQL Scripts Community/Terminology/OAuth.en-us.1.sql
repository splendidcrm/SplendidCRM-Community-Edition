

print 'TERMINOLOGY OAuth en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'OAuth';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_SUCCESSFUL'                           , N'en-US', N'OAuth', null, null, N'Connection successful.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_FAILED'                               , N'en-US', N'OAuth', null, null, N'Connection failed.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_BUTTON_LABEL'                         , N'en-US', N'OAuth', null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_BUTTON_LABEL'                       , N'en-US', N'OAuth', null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUTHORIZE_BUTTON_LABEL'                    , N'en-US', N'OAuth', null, null, N'Authorize';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REFRESH_TOKEN_LABEL'                       , N'en-US', N'OAuth', null, null, N'Refresh Token';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUTHORIZED'                                , N'en-US', N'OAuth', null, null, N'Authorized';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MISSING_AUTHORIZATION'                     , N'en-US', N'OAuth', null, null, N'An authorization token does not exist for service {0}';
-- 03/25/201 Paul.  React client displays an authorizing message.  
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUTHORIZING'                               , N'en-US', N'OAuth', null, null, N'Authorizing . . .';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TESTING'                                   , N'en-US', N'OAuth', null, null, N'Testing . . .';

GO

set nocount off;
GO

/* -- #if Oracle
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			StoO_selcnt := 0;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_OAuth_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_OAuth_en_us')
/
-- #endif IBM_DB2 */
