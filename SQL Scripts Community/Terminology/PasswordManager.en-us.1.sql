

print 'TERMINOLOGY PasswordManager en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'PasswordManager';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREFERRED_PASSWORD_LENGTH'                 , N'en-US', N'PasswordManager', null, null, N'Preferred Password Length:'   ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MINIMUM_LOWER_CASE_CHARACTERS'             , N'en-US', N'PasswordManager', null, null, N'Minimum LowerCase Characters:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MINIMUM_UPPER_CASE_CHARACTERS'             , N'en-US', N'PasswordManager', null, null, N'Minimum UpperCase Characters:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MINIMUM_NUMERIC_CHARACTERS'                , N'en-US', N'PasswordManager', null, null, N'Minimum Numeric Characters:'  ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MINIMUM_SYMBOL_CHARACTERS'                 , N'en-US', N'PasswordManager', null, null, N'Minimum Symbol Characters:'   ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYMBOL_CHARACTERS'                         , N'en-US', N'PasswordManager', null, null, N'Symbol Characters:'           ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COMPLEXITY_NUMBER'                         , N'en-US', N'PasswordManager', null, null, N'Complexity Number:'           ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HISTORY_MAXIMUM'                           , N'en-US', N'PasswordManager', null, null, N'History Maximum:'             ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_LOCKOUT_COUNT'                       , N'en-US', N'PasswordManager', null, null, N'Login Lockout Count:'         ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPIRATION_DAYS'                           , N'en-US', N'PasswordManager', null, null, N'Expiration Days:'             ;
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYMBOL_CHARACTERS_DEFAULT'                 , N'en-US', N'PasswordManager', null, null, N'Default symbols:'             ;
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'PasswordManager', null, null, N'Pwd';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Password Manager'                              , N'en-US', null, N'moduleList', 104, N'PasswordManager';
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

call dbo.spTERMINOLOGY_PasswordManager_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_PasswordManager_en_us')
/
-- #endif IBM_DB2 */
