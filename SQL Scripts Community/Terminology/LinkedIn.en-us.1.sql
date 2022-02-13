

print 'TERMINOLOGY LinkedIn en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'LinkedIn';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_LINKEDIN_TITLE'                     , N'en-US', N'LinkedIn', null, null, N'LinkedIn';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_LINKEDIN'                           , N'en-US', N'LinkedIn', null, null, N'Manage LinkedIn Application';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINKEDIN_API_KEY'                          , N'en-US', N'LinkedIn', null, null, N'LinkedIn API Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINKEDIN_SECRET_KEY'                       , N'en-US', N'LinkedIn', null, null, N'LinkedIn Secret Key:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'LinkedIn', null, null, N'in';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_INSTRUCTIONS'                          , N'en-US', N'LinkedIn', null, null, N'<p>
In order to allow the import of LinkedIn connections, 
you will need to create a LinkedIn applicaton.  Once a LinkedIn application has been created, 
you can provide the API Key and the Secret Key below.</p>
<p>
For instructions on how to create a LinkedIn application, please follow Step 1 of the 
<a href="http://developer.linkedin.com/apply-getting-started" target="_default">Getting Started</a> document on the LinkedIn site. 
You will be directed to <a href="https://www.linkedin.com/secure/developer" target="_default">https://www.linkedin.com/secure/developer</a> 
to create an API key.  You can skip the remaining steps as SplendidCRM only requires the API keys. 
</p>
<p>
Make sure to specify the Application Type as Web application and to set the Live Status to Live.
</p>
<p>
Make sure to specify the WebSite as the URL of your CRM site (~/).
</p>';
-- 05/17/2017 Paul.  Include the CRM URL. 
if not exists(select * from TERMINOLOGY where NAME = 'LBL_APP_INSTRUCTIONS' and MODULE_NAME = 'LinkedIn' and DISPLAY_NAME like '%~/%' and DELETED = 0) begin -- then
	update TERMINOLOGY
	   set DISPLAY_NAME      = DISPLAY_NAME + '<p>Make sure to specify the WebSite as the URL of your CRM site (~/).</p>'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'LBL_APP_INSTRUCTIONS'
	   and MODULE_NAME       = 'LinkedIn'
	   and DISPLAY_NAME      not like '%~/%'
	   and DELETED           = 0;
end -- if;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LinkedIn'                                      , N'en-US', null, N'moduleList', 101, N'LinkedIn';
-- 11/12/2019 Paul.  Settings for React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINKEDIN_SETTINGS'                         , N'en-US', N'LinkedIn', null, null, N'Configure LinkedIn Settings';
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

call dbo.spTERMINOLOGY_LinkedIn_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_LinkedIn_en_us')
/
-- #endif IBM_DB2 */
