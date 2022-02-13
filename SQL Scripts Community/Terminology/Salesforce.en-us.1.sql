

print 'TERMINOLOGY Salesforce en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'Salesforce';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_SALESFORCE_TITLE'                     , N'en-US', N'Salesforce', null, null, N'Salesforce';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_SALESFORCE'                           , N'en-US', N'Salesforce', null, null, N'Manage Salesforce Application';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALESFORCE_CONSUMER_KEY'                     , N'en-US', N'Salesforce', null, null, N'Salesforce Consumer Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALESFORCE_SECRET_KEY'                       , N'en-US', N'Salesforce', null, null, N'Salesforce Consumer Secret:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                         , N'en-US', N'Salesforce', null, null, N'sf';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_APP_INSTRUCTIONS'                            , N'en-US', N'Salesforce', null, null, N'<p>
In order to allow the import of Salesforce data, 
you will need to create a Salesforce Remote Access Applicaton.  Once a Salesforce application has been created, 
you can provide the Consumer Key and the Secret Key below.</p>
<p>
To create a Remote Access Application, login to Salesforce and navigate to App Setup / Develop / Remote Access. 
Create a new application making sure to specify the correct Callback URL.
The Callback URL must match the CRM landing page, which is expected to be: ~/Import/OAuthLanding.aspx.
</p>';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'Salesforce'                                      , N'en-US', null, N'moduleList', 103, N'Salesforce';
-- 11/12/2019 Paul.  Settings for React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALESFORCE_SETTINGS'                         , N'en-US', N'Salesforce', null, null, N'Configure Salesforce Settings';
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

call dbo.spTERMINOLOGY_Salesforce_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Salesforce_en_us')
/
-- #endif IBM_DB2 */
