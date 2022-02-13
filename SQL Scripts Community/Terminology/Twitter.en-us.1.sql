

print 'TERMINOLOGY Twitter en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Twitter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_TWITTER_TITLE'                     , N'en-US', N'Twitter', null, null, N'Twitter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_TWITTER'                           , N'en-US', N'Twitter', null, null, N'Manage Twitter Application';
-- 02/26/2015 Paul.  Provide a way to disable twitter without clearing values. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLE_TRACKING'                          , N'en-US', N'Twitter', null, null, N'Enable Tracking:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_CONSUMER_KEY'                     , N'en-US', N'Twitter', null, null, N'Twitter Consumer Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_SECRET_KEY'                       , N'en-US', N'Twitter', null, null, N'Twitter Consumer Secret:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_TOKEN'                             , N'en-US', N'Twitter', null, null, N'Twitter Access Token:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_TOKEN_SECRET'                      , N'en-US', N'Twitter', null, null, N'Twitter Access Token Secret:';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_TWITTER_SETUP'                            , N'en-US', N'Twitter', null, null, N'The Twitter Consumer Key and Secret must be specified in the Admin area.';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                      , N'en-US', N'Twitter', null, null, N'Twi';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_INSTRUCTIONS'                         , N'en-US', N'Twitter', null, null, N'<p>
In order to allow the import of Twitter followers, 
you will need to create a Twitter applicaton.  Once a Twitter application has been created, 
you can provide the Consumer Key and the Secret Key below.</p>
<p>
You can create the Twitter application at <a href="https://dev.twitter.com/apps/new" target="_default">https://dev.twitter.com/apps/new</a>.
</p>
<p>
Make sure to specify the WebSite as the URL of your CRM site (~/).
</p>';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_START_BUTTON'                             , N'en-US', N'Twitter', null, null, N'Start';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STOP_BUTTON'                              , N'en-US', N'Twitter', null, null, N'Stop';


exec dbo.spTERMINOLOGY_InsertOnly N'Twitter'                                      , N'en-US', null, N'moduleList', 102, N'Twitter';
-- 11/12/2019 Paul.  Settings for React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER_SETTINGS'                      , N'en-US', N'Twitter', null, null, N'Configure Twitter Settings';
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

call dbo.spTERMINOLOGY_Twitter_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Twitter_en_us')
/
-- #endif IBM_DB2 */
