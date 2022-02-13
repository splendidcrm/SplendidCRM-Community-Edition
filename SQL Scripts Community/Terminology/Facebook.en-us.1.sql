

print 'TERMINOLOGY Facebook en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Facebook';
-- 01/18/2021 Paul.  LBL_FACEBOOK_SETTINGS is used by React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_SETTINGS'                         , N'en-US', N'Facebook', null, null, N'facebook &reg; Authentication';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_FACEBOOK_TITLE'                     , N'en-US', N'Facebook', null, null, N'facebook &reg; Authentication';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_FACEBOOK'                           , N'en-US', N'Facebook', null, null, N'Manage facebook Authentication';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_APPID'                            , N'en-US', N'Facebook', null, null, N'facebook AppID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_SECRET_KEY'                       , N'en-US', N'Facebook', null, null, N'facebook Secret Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_ENABLE_LOGIN'                     , N'en-US', N'Facebook', null, null, N'Enable CRM Login:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_PORTAL_LOGIN'                     , N'en-US', N'Facebook', null, null, N'Enable Portal Login:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_INSTRUCTIONS'                          , N'en-US', N'Facebook', null, null, N'<p>
In order to use facebook authentication or to allow the import of facebook friends, 
you will need to create a facebook applicaton.  Once a facebook application has been created, 
you can provide the AppID and the Secret key below.</p>
<p>
For instructions on how to create a facebook application, please follow the 
<a href="https://developers.facebook.com/docs/opengraph/tutorial/" target="_default">Tutorial</a> on the facebook site. 
You can create the facebook application at <a href="https://developers.facebook.com/apps" target="_default">https://developers.facebook.com/apps</a>.
</p>
<p>
Make sure to specify the App Domain as the domain of your CRM site and the Website Site URL as the URL of your CRM site (~/).
</p>';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Facebook', null, null, N'fac';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Facebook'                                      , N'en-US', null, N'moduleList',  98, N'Facebook';
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

call dbo.spTERMINOLOGY_Facebook_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Facebook_en_us')
/
-- #endif IBM_DB2 */
