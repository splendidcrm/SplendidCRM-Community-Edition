

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Configurator en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACK_BUTTON'                               , N'en-US', N'Configurator', null, null, N'< Back';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLEAR_BUTTON_TITLE'                        , N'en-US', N'Configurator', null, null, N'Clear';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COMPANY_NAME'                              , N'en-US', N'Configurator', null, null, N'Company Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTINUE_BUTTON'                           , N'en-US', N'Configurator', null, null, N'Continue';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_TEST_OUTBOUND_SETTINGS'              , N'en-US', N'Configurator', null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FINISH_BUTTON'                             , N'en-US', N'Configurator', null, null, N'Finish';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADER_LOGO_HEIGHT'                        , N'en-US', N'Configurator', null, null, N'Header Image Height:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADER_LOGO_IMAGE'                         , N'en-US', N'Configurator', null, null, N'Header Image';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADER_LOGO_STYLE'                         , N'en-US', N'Configurator', null, null, N'Header Image Style:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADER_LOGO_WIDTH'                         , N'en-US', N'Configurator', null, null, N'Header Image Width:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTP_SETTINGS'                        , N'en-US', N'Configurator', null, null, N'Mail Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_BUTTON'                               , N'en-US', N'Configurator', null, null, N'Next >';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SKIP_BUTTON'                               , N'en-US', N'Configurator', null, null, N'Skip';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SMTPTYPE_GMAIL'                            , N'en-US', N'Configurator', null, null, N'Gmail';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SMTPTYPE_OTHER'                            , N'en-US', N'Configurator', null, null, N'Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SMTPTYPE_YAHOO'                            , N'en-US', N'Configurator', null, null, N'Yahoo!';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPLOAD_BUTTON'                             , N'en-US', N'Configurator', null, null, N'Upload';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_LOCALE_DESC'                        , N'en-US', N'Configurator', null, null, N'Please specify the default language, date format and currency format.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_LOCALE_TITLE'                       , N'en-US', N'Configurator', null, null, N'System Locale';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_SMTP_DESC'                          , N'en-US', N'Configurator', null, null, N'Please specify the SMTP settings used to send emails.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_SYSTEM_DESC'                        , N'en-US', N'Configurator', null, null, N'Please specify the title and upload a logo (optional).';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_SYSTEM_TITLE'                       , N'en-US', N'Configurator', null, null, N'System Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_LOCALE_DESC'                   , N'en-US', N'Configurator', null, null, N'Please specify your language, date format and currency format.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_LOCALE_TITLE'                  , N'en-US', N'Configurator', null, null, N'Your Locale';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_MAIL_DESC'                     , N'en-US', N'Configurator', null, null, N'Please specify your email account information.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_MAIL_TITLE'                    , N'en-US', N'Configurator', null, null, N'Your Email Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_SETTINGS_DESC'                 , N'en-US', N'Configurator', null, null, N'Please specify your profile information.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WIZARD_USER_SETTINGS_TITLE'                , N'en-US', N'Configurator', null, null, N'Your Profile';
-- 01/26/2014 Paul.  Atlantic theme header logo. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ATLANTIC_HOME_IMAGE'                       , N'en-US', N'Configurator', null, null, N'Atlantic Header Image:';
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

call dbo.spTERMINOLOGY_Configurator_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Configurator_en_us')
/
-- #endif IBM_DB2 */
