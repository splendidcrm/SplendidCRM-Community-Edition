

print 'CONFIG defaults';
GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 

-- 04/28/2006 Paul.  Provide a variable where the title of the application can be displayed. 
-- This is primarily used on the SplendidCRM Demo site.
-- <h1><font color=black>SQL Server 2005 Express</font></h1>
-- <h1><font color=black>Oracle 10g Express</font></h1>
-- <h1><font color=black>IBM DB2 Express-C</font></h1>
-- <h1><font color=black>MySQL 5.0</font></h1>
exec dbo.spCONFIG_InsertOnly null, 'system', 'platform_title'                         , '';

-- 07/16/2005 Paul. Defaults extracted from SugarSuite-Full-3.0b\include\utils.php function make_sugar_config
exec dbo.spCONFIG_InsertOnly null, 'system', 'admin_export_only'                      , 'false';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'cache_dir'                              , 'cache/';
exec dbo.spCONFIG_InsertOnly null, 'system', 'calculate_response_time'                , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'create_default_user'                    , 'false';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'default_action'                         , 'index';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_charset'                        , 'UTF-8';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_date_format'                    , 'MM/dd/yyyy';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_language'                       , 'en-US';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_module'                         , 'Home';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_password'                       , '';
-- 05/09/2010 Paul.  Make the default theme Six. 
-- 04/28/2012 Paul.  Make the default theme Atlantic. 
-- 03/12/2014 Paul.  Make the default theme Seven. 
-- 10/02/2016 Paul.  Make the default theme Arctic. 
-- 04/01/2022 Paul.  Make the default theme Pacific. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_theme'                          , 'Pacific';
-- 07/25/2015 Paul.  SugarClassic and Sugar2006 were moved long ago.  We need to change the default to prevent app crash. 
if exists(select * from CONFIG where NAME = 'default_theme' and VALUE = 'SugarClassic' and DELETED = 0) begin -- then
	update CONFIG
	   set VALUE             = 'Seven'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'default_theme'
	   and VALUE             in ('SugarClassic', 'Sugar2006')
	   and DELETED           = 0;
end -- if;

exec dbo.spCONFIG_InsertOnly null, 'system', 'default_time_format'                    , 'h:mm tt';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_user_is_admin'                  , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_user_name'                      , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'disable_export'                         , 'false';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'disable_persistent_connections'         , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'display_email_template_variable_chooser', 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'display_inbound_email_buttons'          , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'history_max_viewed'                     , '10';
exec dbo.spCONFIG_InsertOnly null, 'system', 'host_name'                              , 'localhost';
exec dbo.spCONFIG_InsertOnly null, 'system', 'languages'                              , 'en-US';
exec dbo.spCONFIG_InsertOnly null, 'system', 'list_max_entries_per_page'              , '20';
exec dbo.spCONFIG_InsertOnly null, 'system', 'lock_default_user_name'                 , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'log_memory_usage'                       , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'require_accounts'                       , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'rss_cache_time'                         , '10800';
exec dbo.spCONFIG_InsertOnly null, 'system', 'translation_string_prefix'              , 'false';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'unique_key'                             , md5(create_guid());
exec dbo.spCONFIG_InsertOnly null, 'system', 'upload_maxsize'                         , '3000000';

--exec dbo.spCONFIG_InsertOnly null, 'system', 'dbconfig'                               , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'dbconfigoption'                         , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'import_dir'                             , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'session_dir'                            , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'site_url'                               , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'tmp_dir'                                , ''; // this must be set!!
--exec dbo.spCONFIG_InsertOnly null, 'system', 'upload_dir'                             , ''; // this must be set!!


-- 07/16/2005 Paul. Defaults extracted from SugarSuite-Full-3.0b\include\utils.php function get_sugar_config_defaults
--exec dbo.spCONFIG_InsertOnly null, 'system', 'dump_slow_queries'                      , 'false';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'installer_locked'                       , 'true';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'large_scale_test'                       , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'login_nav'                              , 'true';
-- 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'save_query'                             , 'true';

-- #if SQL_Server /*
if exists(select * from CONFIG where NAME = 'save_query' and cast(VALUE as nvarchar(25)) = 'all' and DELETED = 0) begin -- then
	-- 08/12/2009 Paul.  The default in SugarCRM is 'all', but we treat save_query as a boolean flag. 
	update CONFIG
	   set VALUE            = 'true'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = NULL
	 where NAME             = 'save_query'
	   and DELETED          = 0;
end -- if;
-- #endif SQL_Server */

exec dbo.spCONFIG_InsertOnly null, 'system', 'slow_query_time_msec'                   , '100';
--exec dbo.spCONFIG_InsertOnly null, 'system', 'verify_client_ip'                       , 'true';

-- 08/28/2005 Paul.  Default timezone.
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_timezone'                       , 'BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A';
-- 11/07/2005 Paul.  Allow preferences to be stored in PHP format. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'XML_UserPreferences', 'on';
-- 11/10/2005 Paul.  Point to documentation on SourceForge.
exec dbo.spCONFIG_InsertOnly null, 'system', 'HelpUrl', 'http://sourceforge.net/project/showfiles.php?group_id=107819&package_id=124871';

-- 08/08/2006 Paul.  Default currency was not previously defined. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_currency'                       , 'E340202E-6291-4071-B327-A34CB4DF239B';
-- 04/30/2016 Paul.  Base currency has been USD, but we should make it easy to allow a different base. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'base_currency'                          , 'E340202E-6291-4071-B327-A34CB4DF239B';
-- 05/14/2008 Paul.  Some companies might want to show the cents.  This is more common when used as an ordering system. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'currency_format'                        , 'c0';

-- 08/08/2006 Paul.  Create a placeholder for a default role to be assigned to new users. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_role'                           , '';
-- 08/17/2006 Paul.  We only use SMTPServer, so don't populate smtpport, smtpuser or smtppassword. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtpserver'                             , '';
-- 12/21/2006 Paul.  We now support authentication to SMTP servers. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtpport'                               , '';
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtpauth_req'                           , '';
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtpuser'                               , '';
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtppass'                               , '';
-- 11/16/2009 Paul.  Allow SSL with client certificate. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'smtpcertificate'                        , '';
-- 12/22/2007 Paul.  Email campain config values. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'massemailer_campaign_emails_per_run'        , '500';
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'massemailer_tracking_entities_location_type', null;
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'massemailer_tracking_entities_location'     , null;
-- 01/13/2008 Paul.  Template subject for email regarding a case. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'inbound_email_case_subject_macro'       , '[CASE:%1]';
-- 01/20/2008 Paul.  Save the raw inbound email data by default. 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'email_inbound_save_raw'                 , 'true';
-- 01/20/2008 Paul.  Default filter for Cross-Site Scripting (XSS). 
exec dbo.spCONFIG_InsertOnly null, 'mail'  , 'email_xss', 'html|meta|body|base|form|style|applet|object|script|embed|xml|frameset|iframe|frame|blink|link|ilayer|layer|bgsound|import|xmp';

-- #if SQL_Server /*
-- 05/23/2010 Paul.  We want to keep the style tag. 
if exists(select * from CONFIG where NAME = 'email_xss' and VALUE like '%|style%' and DELETED = 0) begin -- then
	print 'CONFIG email_xss: We want to keep the style tag. ';
	update CONFIG
	   set VALUE             = replace(VALUE, '|style', '')
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = NULL
	 where NAME              = 'email_xss'
	   and VALUE             like '%|style%'
	   and DELETED           = 0;
end -- if;
-- #endif SQL_Server */

-- 01/09/2008 Paul.  Use Rijndael instead of TripleDES because it allows 128 block and key sizes, so Guids can be used for both. 
-- 01/08/2008 Paul.  Generate the encryption key as it must remain with the database. 
-- 07/29/2010 Paul.  Now that we run the configurator, we can delay the creation of these keys until app startup. 
/*
if not exists(select * from CONFIG where NAME = 'InboundEmailKey' and DELETED = 0) begin -- then
	insert into CONFIG(ID, CATEGORY, NAME, VALUE)
	values(newid(), 'mail', 'InboundEmailKey', cast(newid() as nvarchar(36)));
end -- if;
-- 01/09/2008 Paul.  Generate the encryption IV as it must remain with the database. 
if not exists(select * from CONFIG where NAME = 'InboundEmailKey' and DELETED = 0) begin -- then
	insert into CONFIG(ID, CATEGORY, NAME, VALUE)
	values(newid(), 'mail', 'InboundEmailIV', cast(newid() as nvarchar(36)));
end -- if;
*/

-- 01/14/2008 Paul.  Generate a unique key for the system. 
if not exists(select * from CONFIG where NAME = 'unique_key' and DELETED = 0) begin -- then
	insert into CONFIG(ID, CATEGORY, NAME, VALUE)
	values(newid(), 'mail', 'unique_key', cast(newid() as nvarchar(36)));
end -- if;
-- 01/14/2008 Paul.  By default, we will check for updates and we will send usage info. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'send_usage_info'                        , 'true';

-- 10/25/2006 Paul.  Provide a way to disable help wiki. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_help_wiki'                       , 'true';
-- 11/01/2006 Paul.  Max import errors. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'import_max_errors'                      , '200';
-- 01/22/2007 Paul.  If ASSIGNED_USER_ID is null, then let everybody see it. 
-- This was added to work around a bug whereby the ASSIGNED_USER_ID was not automatically assigned to the creating user. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'show_unassigned'                        , 'false';
-- 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'require_user_assignment'                , 'false';


-- 06/02/2007 Paul.  Each user is allowed to set their own max_tabs in their general preferences. 
-- 05/09/2010 Paul.  The Six theme tabs are now larger, so reduce the max to 8. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_max_tabs'                       , '8';

-- 11/17/2007 Paul.  Allow the admin to select an alternate mobile theme. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_mobile_theme'                   , 'Mobile';

-- 03/30/2008 Paul.  Provide a way to disable silverlight graphs. Default to enable. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_silverlight'                     , 'true';
-- 03/30/2008 Paul.  Provide a way to disable flash graphs. Default to disable. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_flash'                           , 'false';

-- 12/09/2008 Paul.  Allow concurrency to be disabled. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_concurrency_check'               , 'true';
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_duplicate_check'                 , 'true';

-- 08/05/2009 Paul.  The Training Portal has changed, so we should take this opportunity to make it configurable.
-- exec dbo.spCONFIG_InsertOnly null, 'system', 'sugar_university', 'http://www.sugarcrm.com/crm/university-jump-page.php&tmpl=network&version={0}&edition=OS&language={1}';
exec dbo.spCONFIG_InsertOnly null, 'system', 'sugar_university', 'http://www.splendidcrm.com/Portals/0/Two-Minute%20Training.htm?version={0}&language={1}';

-- #if SQL_Server /*
--02/27/2010 Paul.  Point to new SplendidCRM training videos. 
if exists(select * from CONFIG where NAME = 'sugar_university' and VALUE like '%www.sugarcrm.com%' and DELETED = 0) begin -- then
	update CONFIG
	   set VALUE             = 'http://www.splendidcrm.com/Portals/0/Two-Minute%20Training.htm?version={0}&language={1}'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME    = 'sugar_university'
	   and VALUE   like '%www.sugarcrm.com%'
	   and DELETED = 0;
end -- if;
-- #endif SQL_Server */

-- 09/07/2009 Paul.  Custom Paging can be enabled and disabled, but default to false as few customers will have millions of records. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'allow_custom_paging'                    , 'false';
-- 12/03/2009 Paul.  The AjaxControlToolkit has support for Tabs. 
-- 02/26/2010 Paul.  Change name from configure_group_tabs to default_subpanel_tabs. 
-- 02/27/2010 Paul.  Turn on SubPanel Tabs and Group Tabs by default. 
-- 05/06/2010 Paul.  Now that we have the Six theme, we can disable the subpanel tabs. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_subpanel_tabs'                  , 'false';
-- 02/26/2010 Paul.  Added support for Group Menu, and make it the default to match SugarCRM. 
-- 05/06/2010 Paul.  Now that we have the Six theme, we can disable the group tabs. 
-- 07/28/2010 Paul.  Sugar 6 defaults to group tabs off. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_group_tabs'                     , 'false';

-- 02/27/2010 Paul.  Include Show SQL so that it is easy to enable. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'show_sql'                               , 'false';

-- 04/08/2010 Paul.  Admin Delegation flag. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'allow_admin_roles'                      , 'false';

-- 08/02/2010 Paul.  Add support for LinkedIn icon in DetailView. 
-- 11/11/2010 Paul.  We are getting a javascript error in the LinkedIn code on IE8. "Error: Invalid argument."
-- this._window.style.left = windowOffset.left + "px";
-- Lets remove LinkedIn as this error will make us look bad. 
--exec dbo.spCONFIG_InsertOnly null, 'system', 'external_scripts'                       , '<script type="text/javascript" src="http://www.linkedin.com/companyInsider?script&useBorder=yes"></script><script type="text/javascript" src="http://www.linkedin.com/js/public-profile/widget-os.js"></script>';
exec dbo.spCONFIG_InsertOnly null, 'system', 'external_scripts'                       , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'external_scripts_mobile'                , '';

-- 10/09/2010 Paul.  Provide a way to hide the Six toolbar. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'hide_theme_toolbar'                     , 'false';

-- 03/05/2011 Paul.  Default to 6 characters, 1 alpha, 1 numeric, no history, no expiration. 
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.PreferredPasswordLength'   , '6';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.MinimumLowerCaseCharacters', '1';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.MinimumUpperCaseCharacters', '0';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.MinimumNumericCharacters'  , '1';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.MinimumSymbolCharacters'   , '0';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.PrefixText'                , null;
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.TextStrengthDescriptions'  , null;
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.SymbolCharacters'          , null;
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.ComplexityNumber'          , '2';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.HistoryMaximum'            , '0';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.LoginLockoutCount'         , '5';
exec dbo.spCONFIG_InsertOnly null, 'security', 'Password.ExpirationDays'            , '0';

-- 03/19/2011 Paul.  Allow facebook integration to be configurable. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'facebook.AppID'                       , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'facebook.AppSecret'                   , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'facebook.EnableLogin'                 , 'false';
exec dbo.spCONFIG_InsertOnly null, 'system', 'facebook.Portal.EnableLogin'          , 'false';

-- 04/08/2012 Paul.  Allow import of LinkedIn contacts. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'LinkedIn.APIKey'                      , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'LinkedIn.SecretKey'                   , '';

-- 04/08/2012 Paul.  Allow import of Twitter contacts. 
-- 02/26/2015 Paul.  Provide a way to disable twitter without clearing values. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'Twitter.EnableTracking'               , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'Twitter.ConsumerKey'                  , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'Twitter.ConsumerSecret'               , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'Twitter.VerboseStatus'                , 'false';

-- 04/22/2012 Paul.  Allow import of Salesforce contacts. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'Salesforce.ConsumerKey'               , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'Salesforce.ConsumerSecret'            , '';
-- 04/22/2012 Paul.  Hardcode the version as this is what the code was developed against. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'Salesforce.Version'                   , '24.0';

-- 08/22/2012 Paul.  Apple and Android devices should support speech and handwriting. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_speech'                        , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_handwriting'                   , 'true';

-- 12/21/2012 Paul.  Prepare to show reminders. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_reminder_popdowns'             , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'reminder_max_time'                    , '90000';
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_email_reminders'               , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'notify_send_from_assigning_user'      , 'false';
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_sms_reminders'                 , 'true';
-- 01/16/2014 Paul.  Allow reminders to contacts and leads to be disabled. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_email_reminders_contacts'      , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_email_reminders_leads'         , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_sms_reminders_contacts'        , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_sms_reminders_leads'           , 'true';

-- 02/20/2013 Paul.  New HTML5 calendar supports Google Calendars. 
-- 11/19/2014 Paul.  Calendar code is failing.  Stop enabling as default. 
-- http://www.google.com/calendar/feeds/usa__en@holiday.calendar.google.com/public/basic
exec dbo.spCONFIG_InsertOnly null, 'system', 'GoogleCalendar.HolidayCalendars'      , '';
-- 06/15/2020 Paul.  Correct if calendar is bad. 
if exists(select * from CONFIG where NAME = 'GoogleCalendar.HolidayCalendars' and VALUE = 'http://www.google.com/calendar/feeds/usa__en@holiday.calendar.google.com/public/basic' and DELETED = 0) begin -- then
	update CONFIG
	   set VALUE             = null
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'GoogleCalendar.HolidayCalendars'
	   and VALUE             = 'http://www.google.com/calendar/feeds/usa__en@holiday.calendar.google.com/public/basic'
	   and DELETED           = 0;
end -- if;
GO

exec dbo.spCONFIG_InsertOnly null, 'system', 'calendar.hour_start'                  , '8';
exec dbo.spCONFIG_InsertOnly null, 'system', 'calendar.hour_end'                    , '18';

-- 03/04/2013 Paul.  Data for recurring calls or meetings. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'calendar.max_repeat_count'            , '1000';
-- 04/16/2013 Paul.  Allow system to be restricted by IP Address. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'Authentication.IPAddresses'           , '';
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'BusinessMode'                         , 'B2B';
-- 08/07/2015 Paul.  Revenue line items. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'OpportunitiesMode'                    , 'Opportunities';
-- 10/10/2015 Paul.  Allow activity streams to be disabled for performance reasons. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_activity_streams'              , 'true';
-- 04/07/2016 Paul.  Provide a way to hide the access view. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'hide_user_access_view'                , 'false';
-- 04/14/2016 Paul.  Provide a way to inherit Assigned User from parent.  
exec dbo.spCONFIG_InsertOnly null, 'system', 'inherit_assigned_user'                , 'false';
-- 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_separate_smtp_server'          , 'false';
-- 04/03/2018 Paul.  Enable Dynamic Mass Update. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_dynamic_mass_update'           , 'true';
GO

-- 07/07/2013 Paul.  Convert translation engine to use Microsoft Translator. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'MicrosoftTranslator.ClientID'         , '';
exec dbo.spCONFIG_InsertOnly null, 'system', 'MicrosoftTranslator.ClientSecret'     , '';
GO

-- 04/20/2018 Paul.  Alternate language mapping to convert en-CA to en_US. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'alternate_language.en-CA'             , 'en-US';
exec dbo.spCONFIG_InsertOnly null, 'system', 'alternate_language.en-AU'             , 'en-US';
exec dbo.spCONFIG_InsertOnly null, 'system', 'alternate_language.en-GB'             , 'en-US';
GO

-- 07/02/2018 Paul.  Allow defaults to display as checked for Opt Out and Do Not Call. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_email_opt_out'                , 'true';
exec dbo.spCONFIG_InsertOnly null, 'system', 'default_do_not_call'                  , 'true';
-- 07/28/2019 Paul.  Specify default so that React client will not complain. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_dynamic_assignment'            , 'false';
-- 03/30/2022 Paul.  Add Insight fields. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'enable_insights'                      , 'true';
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

call dbo.spCONFIG_Defaults()
/

call dbo.spSqlDropProcedure('spCONFIG_Defaults')
/

-- #endif IBM_DB2 */

