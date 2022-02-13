

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY Import en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_DUPLICATE_FIELDS'                          , N'en-US', N'Import', null, null, N'Duplicate Fields.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MISSING_REQUIRED_FIELDS'                   , N'en-US', N'Import', null, null, N'Missing Required Fields.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MULTIPLE'                                  , N'en-US', N'Import', null, null, N'Multiple columns defined.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNTS_NOTE_1'                           , N'en-US', N'Import', null, null, N'Account Name must be mapped.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNTS_NOTE_2'                           , N'en-US', N'Import', null, null, N'Street fields are combined into a single field.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACT'                                       , N'en-US', N'Import', null, null, N'Act!';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACT_2005'                                  , N'en-US', N'Import', null, null, N'Act! 2005';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AVAILABLE_COLUMNS'                         , N'en-US', N'Import', null, null, N'Available Columns';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTACTS_NOTE_1'                           , N'en-US', N'Import', null, null, N'Either Last Name or Full Name must be mapped.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTACTS_NOTE_2'                           , N'en-US', N'Import', null, null, N'First and Last are ignored if Full Name is mapped.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTACTS_NOTE_3'                           , N'en-US', N'Import', null, null, N'The Full Name will be split into First and Last.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONTACTS_NOTE_4'                           , N'en-US', N'Import', null, null, N'Street fields are combined into a single field.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM'                                    , N'en-US', N'Import', null, null, N'Custom';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_CSV'                                , N'en-US', N'Import', null, null, N'Comma Delimited File';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_DELIMETED'                          , N'en-US', N'Import', null, null, N'Custom Delimited File';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_DELIMETER'                          , N'en-US', N'Import', null, null, N'Custom Delimter:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_TAB'                                , N'en-US', N'Import', null, null, N'Tab Delimited File';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATABASE_FIELD'                            , N'en-US', N'Import', null, null, N'Database Field';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DBASE'                                     , N'en-US', N'Import', null, null, N'dBase';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DONT_MAP'                                  , N'en-US', N'Import', null, null, N'-- Do not map this field --';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DUPLICATE_FILTER'                          , N'en-US', N'Import', null, null, N'Duplicate Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DUPLICATES_IGNORED'                        , N'en-US', N'Import', null, null, N'Duplicates Ignored';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ERROR'                                     , N'en-US', N'Import', null, null, N'Error:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCEL'                                     , N'en-US', N'Import', null, null, N'Excel Workbook (2003 or later)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAIL'                                      , N'en-US', N'Import', null, null, N'Fail:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAILED_IMPORT'                             , N'en-US', N'Import', null, null, N'Failed Import';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FILTER_COLUMNS'                            , N'en-US', N'Import', null, null, N'Filter Columns';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HAS_HEADER'                                , N'en-US', N'Import', null, null, N'Has Header:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HEADER_ROW'                                , N'en-US', N'Import', null, null, N'Header Row';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_ACT_TITLE'                          , N'en-US', N'Import', null, null, N'An ACT! backup zip file can imported directly.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_CUSTOM_TITLE'                       , N'en-US', N'Import', null, null, N'Comma delimited files can be imported with, or without a header.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_DBASE'                              , N'en-US', N'Import', null, null, N'dBase files can be imported directly.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_DBASE_TITLE'                        , N'en-US', N'Import', null, null, N'dBase Import';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_EXCEL_TITLE'                        , N'en-US', N'Import', null, null, N'An Excel spreadsheet can only be import if it is on the first worksheet and must start at cell A1.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_SF_TITLE'                           , N'en-US', N'Import', null, null, N'To import Salesforce data, you will first need to export as comma-separated variable.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_DUPLICATE_FILTER'              , N'en-US', N'Import', null, null, N'Duplicate Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_MAP_FIELDS'                    , N'en-US', N'Import', null, null, N'Map Fields';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_RESULTS'                       , N'en-US', N'Import', null, null, N'Results';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_SELECT_SOURCE'                 , N'en-US', N'Import', null, null, N'Select Source';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_SPECIFY_DEFAULTS'              , N'en-US', N'Import', null, null, N'Specify Defaults';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_UPLOAD_FILE'                   , N'en-US', N'Import', null, null, N'Upload File';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_BUSINESS_RULES'                , N'en-US', N'Import', null, null, N'Business Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_TAB_TITLE'                          , N'en-US', N'Import', null, null, N'Tab delimited files can be imported with, or without a header.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_XML_SPREADSHEET_TITLE'              , N'en-US', N'Import', null, null, N'An Excel spreadsheet saved as an XML Spreadsheet can only be imported if it is the first worksheet and must start at cell A1.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_XML_TITLE'                          , N'en-US', N'Import', null, null, N'The format of the XML should have a node for the module and a node for the field.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORTED'                                  , N'en-US', N'Import', null, null, N'Imported';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_IMPORTED'                             , N'en-US', N'Import', null, null, N'Last Imported';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Import', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAX_ERRORS'                                , N'en-US', N'Import', null, null, N'Import stopped after too many errors';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE'                                    , N'en-US', N'Import', null, null, N'Module:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Import', null, null, N'Import';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Import', null, null, N'Imp';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_SAVED'                                  , N'en-US', N'Import', null, null, N'My Saved Sources:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Import', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTES'                                     , N'en-US', N'Import', null, null, N'Notes:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTHING'                                   , N'en-US', N'Import', null, null, N'Nothing to import.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPPORTUNITIES_NOTE_1'                      , N'en-US', N'Import', null, null, N'Opportunity Name, Account Name, Date Closed and Sales Stage are all required fields.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_BUTTON_LABEL'                      , N'en-US', N'Import', null, null, N'Preview';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_BUTTON_TITLE'                      , N'en-US', N'Import', null, null, N'Preview';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROW'                                       , N'en-US', N'Import', null, null, N'Row';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ROW_STATUS'                                , N'en-US', N'Import', null, null, N'Row Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RUN_BUTTON_LABEL'                          , N'en-US', N'Import', null, null, N'Import Now';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RUN_BUTTON_TITLE'                          , N'en-US', N'Import', null, null, N'Import Now';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_BUTTON_LABEL'                         , N'en-US', N'Import', null, null, N'Save';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_BUTTON_TITLE'                         , N'en-US', N'Import', null, null, N'Save';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_FIELDS_TO_MAP'                      , N'en-US', N'Import', null, null, N'Select Fields To Map:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_FILE'                               , N'en-US', N'Import', null, null, N'Select File:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUCCESS'                                   , N'en-US', N'Import', null, null, N'Success:';
-- 01/11/2016 Paul.  Fix spelling of Successfully. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUCCESSFULLY'                              , N'en-US', N'Import', null, null, N'Successfully Imported';
update TERMINOLOGY
   set DISPLAY_NAME      = 'Successfully Imported'
     , DATE_MODIFIED     = getdate()
     , DATE_MODIFIED_UTC = getutcdate()
 where NAME              = 'LBL_SUCCESSFULLY'
   and DISPLAY_NAME      = 'Succesfully Imported'
   and DELETED           = 0;

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TAB'                                       , N'en-US', N'Import', null, null, N'Tab Delimited File';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPLOAD_BUTTON_LABEL'                       , N'en-US', N'Import', null, null, N'Upload';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPLOAD_BUTTON_TITLE'                       , N'en-US', N'Import', null, null, N'Upload';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USE_TRANSACTION'                           , N'en-US', N'Import', null, null, N'Use transaction across all records:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WHAT_IS'                                   , N'en-US', N'Import', null, null, N'What is the source?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_XML'                                       , N'en-US', N'Import', null, null, N'Xml';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_XML_SPREADSHEET'                           , N'en-US', N'Import', null, null, N'Excel XML Spreadsheet';

-- 04/08/2012 Paul.  Allow import of LinkedIn data. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_STEP_CONNECT'                       , N'en-US', N'Import', null, null, N'Connect';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNIN_BUTTON_LABEL'                       , N'en-US', N'Import', null, null, N'Sign In';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNIN_BUTTON_TITLE'                       , N'en-US', N'Import', null, null, N'Sign In';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNOUT_BUTTON_LABEL'                      , N'en-US', N'Import', null, null, N'Sign Out';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNOUT_BUTTON_TITLE'                      , N'en-US', N'Import', null, null, N'Sign Out';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONNECT_BUTTON_LABEL'                      , N'en-US', N'Import', null, null, N'Connect';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONNECT_BUTTON_TITLE'                      , N'en-US', N'Import', null, null, N'Connect';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINKEDIN'                                  , N'en-US', N'Import', null, null, N'LinkedIn &reg;';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_LINKEDIN_TITLE'                     , N'en-US', N'Import', null, null, N'You will first need to sign-in to LinkedIn &reg; in order to connect and retrieve the connections.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TWITTER'                                   , N'en-US', N'Import', null, null, N'Twitter &reg;';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_TWITTER_TITLE'                      , N'en-US', N'Import', null, null, N'You will first need to sign-in to Twitter &reg; in order to connect and retrieve the connections.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK'                                  , N'en-US', N'Import', null, null, N'facebook &reg;';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_FACEBOOK_TITLE'                     , N'en-US', N'Import', null, null, N'You will first need to sign-in to facebook &reg; in order to connect and retrieve the connections.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SALESFORCE'                                , N'en-US', N'Import', null, null, N'Salesforce.com &reg;';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_SALESFORCE_TITLE'                   , N'en-US', N'Import', null, null, N'You will first need to sign-in to Salesforce.com &reg; in order to connect and retrieve the connections.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICKBOOKS'                                , N'en-US', N'Import', null, null, N'QuickBooks &reg;';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_QUICKBOOKS_TITLE'                   , N'en-US', N'Import', null, null, N'In order to sync with QuickBooks, you install RSSBus ADO.NET Data Provider for QuickBooks on the computer running QuickBooks.';
-- 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICKBOOKS_ONLINE'                         , N'en-US', N'Import', null, null, N'QuickBooks &reg; Online';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_QUICKBOOKS_ONLINE'                  , N'en-US', N'Import', null, null, N'You will first need to sign-in to QuickBooks &reg; in order to connect and retreive data.';

-- 09/06/2012 Paul.  Allow direct import into prospect list. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_INTO'                               , N'en-US', N'Import', null, null, N'Import into {0}';
-- 08/15/2017 Paul.  Provide a way to export errors. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_EXPORT_ERRORS'                             , N'en-US', N'Import', null, null, N'Export Errors';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NO_ERRORS'                                 , N'en-US', N'Import', null, null, N'No errors were found.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NO_PROCESSED_TABLE'                        , N'en-US', N'Import', null, null, N'No processed table found in temp file.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_NO_PROCESSED_FILE'                         , N'en-US', N'Import', null, null, N'No process file was found.';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Import'                                        , N'en-US', null, N'moduleList'                        ,  64, N'Import';
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

call dbo.spTERMINOLOGY_Import_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Import_en_us')
/
-- #endif IBM_DB2 */
