

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:34 AM.
print 'TERMINOLOGY Global en-us';
GO

set nocount on;
GO

-- 09/14/2012 Paul.  Fix spelling for ERR_CONCURRENCY_EXCEPTION. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_CONCURRENCY_EXCEPTION'                     , N'en-US', null, null, null, N'This record was last edited on {0}.  Please reload and reapply your changes.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_CONCURRENCY_OVERRIDE'                      , N'en-US', null, null, null, N'This record was last edited on {0}.  Do you want to override the changes?';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_DATE'                              , N'en-US', null, null, null, N'Invalid Date.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_DECIMAL'                           , N'en-US', null, null, null, N'Invalid Decimal Value.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_EMAIL_ADDRESS'                     , N'en-US', null, null, null, N'Invalid Email Address.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_INTEGER'                           , N'en-US', null, null, null, N'Invalid Integer Value.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_PHONE_NUMBER'                      , N'en-US', null, null, null, N'Invalid Phone Number.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_TIME'                              , N'en-US', null, null, null, N'Invalid Time.';
-- 07/06/2017 Paul.  Missing field validator messages. 
-- select * from vwFIELD_VALIDATORS order by NAME
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_POSITIVE_DECIMAL'                  , N'en-US', null, null, null, N'Invalid Positive Decimal.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_POSITIVE_DECIMAL_COMMAS'           , N'en-US', null, null, null, N'Invalid Positive Decimal with Comma.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_INTEGER'                           , N'en-US', null, null, null, N'Invalid Integer.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_TWITTER_TRACK'                             , N'en-US', null, null, null, N'Invalid Twitter Track.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_TWITTER_MESSAGE'                           , N'en-US', null, null, null, N'Invalid Twitter Message.';

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MISSING_REQUIRED_FIELDS'                   , N'en-US', null, null, null, N'Missing Required Fields.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REQUIRED_FIELD'                            , N'en-US', null, null, null, N'Required Field.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT'                                   , N'en-US', null, null, null, N'Account';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTIONS'                                   , N'en-US', null, null, null, N'Actions';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_BUTTON'                                , N'en-US', null, null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_BUTTON_LABEL'                          , N'en-US', null, null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_BUTTON_TITLE'                          , N'en-US', null, null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN'                                     , N'en-US', null, null, null, N'Admin';
-- 04/16/2021 Paul.  Provide quick access to old admin system. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN_CLASSIC'                             , N'en-US', null, null, null, N'Admin (Classic)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALT_HOT_KEY'                               , N'en-US', null, null, null, N'Alt Hot Key';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_TO'                               , N'en-US', null, null, null, N'Assigned To:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_TO_NAME'                          , N'en-US', null, null, null, N'Assigned To Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_TO_USER'                          , N'en-US', null, null, null, N'Assigned To User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_USER_ID'                          , N'en-US', null, null, null, N'Assigned User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_ACTION'                              , N'en-US', null, null, null, N'Audit Action:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_COLUMNS'                             , N'en-US', null, null, null, N'Audit Columns:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_DATE'                                , N'en-US', null, null, null, N'Audit Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_ID'                                  , N'en-US', null, null, null, N'Audit ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_TOKEN'                               , N'en-US', null, null, null, N'Audit Token:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACK'                                      , N'en-US', null, null, null, N'Back';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACK_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Back';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACK_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Back';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BROWSER_TITLE'                             , N'en-US', null, null, null, N'SplendidCRM';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BY'                                        , N'en-US', null, null, null, N'By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CAMPAIGNS_SEND_QUEUED'                     , N'en-US', null, null, null, N'Campaigns Send Queued';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CANCEL_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Cancel';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CANCEL_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Cancel';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Change';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Change';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHECKALL'                                  , N'en-US', null, null, null, N'Check All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLEAR_BUTTON_LABEL'                        , N'en-US', null, null, null, N'Clear';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLEAR_BUTTON_TITLE'                        , N'en-US', null, null, null, N'Clear';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLEARALL'                                  , N'en-US', null, null, null, N'Clear All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COMPOSE_EMAIL_BUTTON_LABEL'                , N'en-US', null, null, null, N'Compose Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COMPOSE_EMAIL_BUTTON_TITLE'                , N'en-US', null, null, null, N'Compose Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Create';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATE_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Create';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED_BY'                                , N'en-US', null, null, null, N'Created By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED_BY_ID'                             , N'en-US', null, null, null, N'Created By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED_BY_NAME'                           , N'en-US', null, null, null, N'Created By Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED_BY_USER'                           , N'en-US', null, null, null, N'Created By User';
-- 03/31/2012 Paul.  Change current user to My Items. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENT_USER_FILTER'                       , N'en-US', null, null, null, N'My Items:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_ENTERED'                              , N'en-US', null, null, null, N'Date Entered:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_MODIFIED'                             , N'en-US', null, null, null, N'Date Modified:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_MODIFIED_UTC'                         , N'en-US', null, null, null, N'Date Modified UTC';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT'                                   , N'en-US', null, null, null, N'Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULTS_BUTTON_LABEL'                     , N'en-US', null, null, null, N'Restore Defaults';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULTS_BUTTON_TITLE'                     , N'en-US', null, null, null, N'Restore Defaults';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE'                                    , N'en-US', null, null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETE_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETED'                                   , N'en-US', null, null, null, N'Deleted:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESELECT_ALL'                              , N'en-US', null, null, null, N'Deselect All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DONE_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Done';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DONE_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Done';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DUPLICATE_BUTTON_LABEL'                    , N'en-US', null, null, null, N'Duplicate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DUPLICATE_BUTTON_TITLE'                    , N'en-US', null, null, null, N'Duplicate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_SEARCH_NO_RESULTS'                   , N'en-US', null, null, null, N'No results were found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMPLOYEES'                                 , N'en-US', null, null, null, N'Employees';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENTER_DATE'                                , N'en-US', null, null, null, N'Enter Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_FOLDER'                           , N'en-US', null, null, null, N'Create Exchange Folder:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_SYNC'                             , N'en-US', null, null, null, N'Sync Exchange';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_UNSYNC'                           , N'en-US', null, null, null, N'Unsync Exchange';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT'                                    , N'en-US', null, null, null, N'Export';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Export';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Export';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT_DATABASE'                           , N'en-US', null, null, null, N'Export Database';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT_DATABASE_TITLE'                     , N'en-US', null, null, null, N'Export all database tables';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXPORT_VCARD'                              , N'en-US', null, null, null, N'Export vCard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULL_FORM_BUTTON_LABEL'                    , N'en-US', null, null, null, N'Full Form';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULL_FORM_BUTTON_TITLE'                    , N'en-US', null, null, null, N'Full Form';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GO_BUTTON_LABEL'                           , N'en-US', null, null, null, N'Go';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ID'                                        , N'en-US', null, null, null, N'ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ID_C'                                      , N'en-US', null, null, null, N'ID_C:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT'                                    , N'en-US', null, null, null, N'Import';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPORT_VCARD'                              , N'en-US', null, null, null, N'Import vCard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_VIEWED'                               , N'en-US', null, null, null, N'Last Viewed';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINK_NONE'                                 , N'en-US', null, null, null, N'None';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASSIGNED_TO'                          , N'en-US', null, null, null, N'Assigned To';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASSIGNED_TO_NAME'                     , N'en-US', null, null, null, N'Assigned To Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASSIGNED_USER'                        , N'en-US', null, null, null, N'Assigned User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASSIGNED_USER_ID'                     , N'en-US', null, null, null, N'Assigned User ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_ACTION'                         , N'en-US', null, null, null, N'Audit Action';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_COLUMNS'                        , N'en-US', null, null, null, N'Audit Columns';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_DATE'                           , N'en-US', null, null, null, N'Audit Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_ID'                             , N'en-US', null, null, null, N'Audit ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_TOKEN'                          , N'en-US', null, null, null, N'Audit Token';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CONTACT_NAME'                         , N'en-US', null, null, null, N'Contact Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CREATED'                              , N'en-US', null, null, null, N'Created';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CREATED_BY'                           , N'en-US', null, null, null, N'Created By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CREATED_BY_ID'                        , N'en-US', null, null, null, N'Created By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CREATED_BY_NAME'                      , N'en-US', null, null, null, N'Created By Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CREATED_BY_USER'                      , N'en-US', null, null, null, N'Created By ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_ENTERED'                         , N'en-US', null, null, null, N'Date Entered';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_MODIFIED'                        , N'en-US', null, null, null, N'Date Modified';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_MODIFIED_UTC'                    , N'en-US', null, null, null, N'Date Modified UTC';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEFAULT'                              , N'en-US', null, null, null, N'Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DELETED'                              , N'en-US', null, null, null, N'Deleted';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ID'                                   , N'en-US', null, null, null, N'ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ID_C'                                 , N'en-US', null, null, null, N'ID_C';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODIFIED_BY'                          , N'en-US', null, null, null, N'Modified By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODIFIED_BY_ID'                       , N'en-US', null, null, null, N'Modified By';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODIFIED_BY_NAME'                     , N'en-US', null, null, null, N'Modified By Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODIFIED_USER_ID'                     , N'en-US', null, null, null, N'Modified User ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_OF'                                   , N'en-US', null, null, null, N'Of';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE'                                , N'en-US', null, null, null, N'Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEAM_ID'                              , N'en-US', null, null, null, N'Team ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEAM_NAME'                            , N'en-US', null, null, null, N'Team Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TEAM_SET_NAME'                        , N'en-US', null, null, null, N'Team Set Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LISTVIEW_NO_SELECTED'                      , N'en-US', null, null, null, N'No Selected';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LISTVIEW_OPTION_CURRENT'                   , N'en-US', null, null, null, N'Current Page';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LISTVIEW_OPTION_ENTIRE'                    , N'en-US', null, null, null, N'Entire List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LISTVIEW_OPTION_SELECTED'                  , N'en-US', null, null, null, N'Selected Records';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LISTVIEW_TWO_REQUIRED'                     , N'en-US', null, null, null, N'Two Required';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGOUT'                                    , N'en-US', null, null, null, N'Logout';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAILMERGE'                                 , N'en-US', null, null, null, N'Mail Merge';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MASS_UPDATE_TITLE'                         , N'en-US', null, null, null, N'Mass Update';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MERGE'                                     , N'en-US', null, null, null, N'Merge';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_BY'                               , N'en-US', null, null, null, N'Modified By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_BY_ID'                            , N'en-US', null, null, null, N'Modified By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_BY_NAME'                          , N'en-US', null, null, null, N'Modified By Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_BY_USER'                          , N'en-US', null, null, null, N'Modified By User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODIFIED_USER_ID'                          , N'en-US', null, null, null, N'Modified User ID:';
-- 08/07/2013 Paul.  Change My Account to Profile. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_ACCOUNT'                                , N'en-US', null, null, null, N'Profile';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_BUTTON_LABEL'                          , N'en-US', null, null, null, N'Create';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_BUTTON_TITLE'                          , N'en-US', null, null, null, N'Create';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Next';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Next';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NO'                                        , N'en-US', null, null, null, N'No';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NONE'                                      , N'en-US', null, null, null, N'--None--';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NONE_VALUE'                                , N'en-US', null, null, null, N'None';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OR'                                        , N'en-US', null, null, null, N'Or';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_ID'                                 , N'en-US', null, null, null, N'Parent ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_BUTTON_LABEL'                     , N'en-US', null, null, null, N'Previous';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_BUTTON_TITLE'                     , N'en-US', null, null, null, N'Previous';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELATED_RECORDS'                           , N'en-US', null, null, null, N'Related Records';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE'                                    , N'en-US', null, null, null, N'Remove';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REQUIRED_SYMBOL'                           , N'en-US', null, null, null, N'*';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Save';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Save';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_NEW_BUTTON_LABEL'                     , N'en-US', null, null, null, N'Save & Create New';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_NEW_BUTTON_TITLE'                     , N'en-US', null, null, null, N'Save & Create New';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVED_SEARCH_SHORTCUT'                     , N'en-US', null, null, null, N'Saved Searches';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH'                                    , N'en-US', null, null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_ALL'                                , N'en-US', null, null, null, N'Select All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Select';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Select';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_CHECKED_BUTTON_LABEL'               , N'en-US', null, null, null, N'Select Checked';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_CHECKED_BUTTON_TITLE'               , N'en-US', null, null, null, N'Select Checked';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_PAGE'                               , N'en-US', null, null, null, N'Select Page';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECTED'                                  , N'en-US', null, null, null, N'Selected: {0}';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHORTCUTS'                                 , N'en-US', null, null, null, N'Shortcuts';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBMIT_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Submit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBMIT_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Submit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC'                                      , N'en-US', null, null, null, N'Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_ACTIVITIES'                       , N'en-US', null, null, null, N'Activities';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_ALL'                              , N'en-US', null, null, null, N'All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_COLLABORATION'                    , N'en-US', null, null, null, N'Collaboration';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_HOME'                             , N'en-US', null, null, null, N'Home';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_MARKETING'                        , N'en-US', null, null, null, N'Marketing';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_OTHER'                            , N'en-US', null, null, null, N'Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_REPORTS'                          , N'en-US', null, null, null, N'Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_SALES'                            , N'en-US', null, null, null, N'Sales';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_SUPPORT'                          , N'en-US', null, null, null, N'Support';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TABGROUP_TOOLS'                            , N'en-US', null, null, null, N'Tools';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_ID'                                   , N'en-US', null, null, null, N'Team ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_NAME'                                 , N'en-US', null, null, null, N'Team Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_SET_ID'                               , N'en-US', null, null, null, N'Team Set ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_SET_LIST'                             , N'en-US', null, null, null, N'Teams:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEAM_SET_NAME'                             , N'en-US', null, null, null, N'Teams:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TOO_MANY_RECORDS'                          , N'en-US', null, null, null, N'A maximum of 200 records can be modified at one time.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TRAINING'                                  , N'en-US', null, null, null, N'Training';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TYPE_TO_SEARCH'                            , N'en-US', null, null, null, N'Type To Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNAUTH_ADMIN'                              , N'en-US', null, null, null, N'Unauthorized access';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNSYNC'                                    , N'en-US', null, null, null, N'Unsync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATE'                                    , N'en-US', null, null, null, N'Update';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATE_BUTTON_LABEL'                       , N'en-US', null, null, null, N'Update';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATE_BUTTON_TITLE'                       , N'en-US', null, null, null, N'Update';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VCARD'                                     , N'en-US', null, null, null, N'vCard';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_YES'                                       , N'en-US', null, null, null, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ABOUT'                                     , N'en-US', null, null, null, N'About';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ADVANCED_SEARCH'                           , N'en-US', null, null, null, N'Advanced Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_BASIC_SEARCH'                              , N'en-US', null, null, null, N'Basic Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CLEAR_DEFAULT'                             , N'en-US', null, null, null, N'Clear Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DELETE'                                    , N'en-US', null, null, null, N'del';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_DUPLICATE_SEARCH'                          , N'en-US', null, null, null, N'Duplicate Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_EDIT'                                      , N'en-US', null, null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_GET_LATEST'                                , N'en-US', null, null, null, N'Get Latest';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_HELP'                                      , N'en-US', null, null, null, N'Help';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_HELP_WIKI'                                 , N'en-US', null, null, null, N'Help Wiki';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_IMPORT_VCARD'                              , N'en-US', null, null, null, N'Import vCard';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_END'                                  , N'en-US', null, null, null, N'End';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_NEXT'                                 , N'en-US', null, null, null, N'Next';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_PREVIOUS'                             , N'en-US', null, null, null, N'Previous';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_RETURN'                               , N'en-US', null, null, null, N'Return to List';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_START'                                , N'en-US', null, null, null, N'Start';
-- 12/31/2017 Paul.  First and Last are used on HTML5 client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_FIRST'                                , N'en-US', null, null, null, N'First';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_LAST'                                 , N'en-US', null, null, null, N'Last';

exec dbo.spTERMINOLOGY_InsertOnly N'LNK_MAKE_DEFAULT'                              , N'en-US', null, null, null, N'Make Default';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_PRINT'                                     , N'en-US', null, null, null, N'Print';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REMOVE'                                    , N'en-US', null, null, null, N'rem';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SAVED_VIEWS'                               , N'en-US', null, null, null, N'Saved Views';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SORT'                                      , N'en-US', null, null, null, N'Sort';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_VIEW'                                      , N'en-US', null, null, null, N'View';
-- 06/30/2018 Paul.  Rename to Audit Log. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_VIEW_CHANGE_LOG'                           , N'en-US', null, null, null, N'View Audit Log';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_DELETE_CONFIRMATION'                       , N'en-US', null, null, null, N'Are you sure?';
-- 09/16/2012 Paul.  Global remove flag. 
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_REMOVE_CONFIRMATION'                       , N'en-US', null, null, null, N'Are you sure?';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_LOGIN_MESSAGE'                             , N'en-US', null, null, null, N'Please login.';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_NO_ITEMS_DISPLAY'                          , N'en-US', null, null, null, N'none';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_REQUIRED'                                  , N'en-US', null, null, null, N'Required.';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_WELCOME'                                   , N'en-US', null, null, null, N'Welcome.';
-- 10/02/2011 Paul.  HTML5 will support offline access. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ENABLE_OFFLINE'                            , N'en-US', null, null, null, N'Enable Offline Access';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ONLINE'                                    , N'en-US', null, null, null, N'Online';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFFLINE'                                   , N'en-US', null, null, null, N'Offline';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CACHE_SELECTED'                            , N'en-US', null, null, null, N'Cache Selected';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_HTML5_OFFLINE_CLIENT'                      , N'en-US', null, null, null, N'HTML5 Offline Client';
-- 10/16/2016 Paul.  Remove offline ability. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_MOBILE_CLIENT'                             , N'en-US', null, null, null, N'Mobile Client';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CACHE_ALL'                                 , N'en-US', null, null, null, N'Cache All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STOP_CACHING'                              , N'en-US', null, null, null, N'Stop Caching';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYSTEM_LOG'                                , N'en-US', null, null, null, N'System Log';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SPLENDID_STORAGE'                          , N'en-US', null, null, null, N'Splendid Storage';
-- 12/30/2011 Paul.  Was previously displaying delete confirmation message. 
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_CACHE_CONFIRMATION'                        , N'en-US', null, null, null, N'Are you sure you want to cache all records?';
-- 03/29/2012 Paul.  New menu has more text. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MORE'                                      , N'en-US', null, null, null, N'More';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELOAD'                                    , N'en-US', null, null, null, N'( Reload )';
-- 03/31/2012 Paul.  Add support for favorites. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAVORITES'                                 , N'en-US', null, null, null, N'Favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAVORITES_FILTER'                          , N'en-US', null, null, null, N'My Favorites:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_FROM_FAVORITES'                     , N'en-US', null, null, null, N'Remove from Favorites';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_TO_FAVORITES'                          , N'en-US', null, null, null, N'Add to Favorites';

-- 05/23/2012 Paul.  Test and Sync are very common. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TEST_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Test';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_BUTTON_LABEL'                         , N'en-US', null, null, null, N'Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_BUTTON_TITLE'                         , N'en-US', null, null, null, N'Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_ALL_BUTTON_LABEL'                     , N'en-US', null, null, null, N'Sync All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_ALL_BUTTON_TITLE'                     , N'en-US', null, null, null, N'Sync All';

-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_ACTIVITY_DATE'                        , N'en-US', null, null, null, N'Last Activity Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_ACTIVITY_DATE'                   , N'en-US', null, null, null, N'Last Activity';

-- 11/30/2012 Paul.  Provide a way to go from Mobile theme to Full Site. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULL_SITE'                                 , N'en-US', null, null, null, N'Full Site';

-- 12/24/2012 Paul.  Add popup reminder to top of master page. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISMISS_BUTTON_LABEL'                      , N'en-US', null, null, null, N'Dismiss';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DISMISS_BUTTON_TITLE'                      , N'en-US', null, null, null, N'Dismiss';

-- 10/10/2013 Paul.  LNK_INS is used in the Admin layout views. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_INS'                                       , N'en-US', null, null, null, N'Ins';
-- 03/01/2014 Paul.  Add Preview button. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW'                                   , N'en-US', null, null, null, N'Preview';
-- 03/06/2014 Paul.  Add Dashboard panel. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DASHBOARD'                                 , N'en-US', null, null, null, N'Dashboard';
-- 03/14/2014 Paul.  Add Save Duplicate button to most module save operations. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_DUPLICATE_EXCEPTION'                       , N'en-US', null, null, null, N'A record with that name already exists.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_DUPLICATE_LABEL'                      , N'en-US', null, null, null, N'Save Duplicate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_DUPLICATE_TITLE'                      , N'en-US', null, null, null, N'Save Duplicate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_CONCURRENCY_LABEL'                    , N'en-US', null, null, null, N'Overwrite Changes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_CONCURRENCY_TITLE'                    , N'en-US', null, null, null, N'Overwrite Changes';

-- 12/19/2014 Paul.  This message needs to be globally available. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLEAR_ERROR'                               , N'en-US', null, null, null, N'Clear Error';
-- 06/09/2015 Paul.  Define the unspecified abbreviation.
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', null, null, null, N'';
-- 10/09/2015 Paul.  Add support for subscriptions. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FOLLOW'                                    , N'en-US', null, null, null, N'Follow';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FOLLOWING'                                 , N'en-US', null, null, null, N'Following';
-- 01/05/2016 Paul.  Provide a way to run a report from mass update. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTHING_SELECTED'                          , N'en-US', null, null, null, N'Nothing was selected.';
-- 04/04/2016 Paul.  Add link to core modules for related activities. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VIEW_RELATED_ACTIVITIES'                   , N'en-US', null, null, null, N'View Related Activities';
-- 08/29/2016 Paul.  New Process term. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PENDING_PROCESS_ID'                        , N'en-US', null, null, null, N'Pending Process ID';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVE_DATA'                              , N'en-US', null, null, null, N'Archive Data';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RECOVER_DATA'                              , N'en-US', null, null, null, N'Recover Data';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BACKGROUND_OPERATION'                      , N'en-US', null, null, null, N'Operation will be performed in the background.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVE_VIEW'                              , N'en-US', null, null, null, N'Archive View';
-- 10/19/2017 Paul.  Archive fields. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVE_DATE_UTC'                          , N'en-US', null, null, null, N'Archive Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ARCHIVE_DATE_UTC'                     , N'en-US', null, null, null, N'Archive Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVE_USER_ID'                           , N'en-US', null, null, null, N'Archive User:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVE_BY'                                , N'en-US', null, null, null, N'Archive User:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ARCHIVE_BY'                           , N'en-US', null, null, null, N'Archive User';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ARCHIVE_OFFLINE_CLIENT'                    , N'en-US', null, null, null, N'Cannot archive on Offline Client.';
-- 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ARCHIVED_RECORD'                           , N'en-US', null, null, null, N'This record has been archived.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VIEW_ARCHIVED_DATA'                        , N'en-US', null, null, null, N'View Archived Data';
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASSIGNED_SET_NAME'                    , N'en-US', null, null, null, N'Assigned Set Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_SET_ID'                           , N'en-US', null, null, null, N'Assigned Set ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_SET_LIST'                         , N'en-US', null, null, null, N'Assigned Users:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNED_SET_NAME'                         , N'en-US', null, null, null, N'Assigned Users:';
-- 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALL_SELECTED'                              , N'en-US', null, null, null, N'All selected';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COUNT_SELECTED'                            , N'en-US', null, null, null, N'# of % selected';
-- 06/28/2018 Paul.  Show data privacy fields. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_PERSONAL_INFO'                             , N'en-US', null, null, null, N'View Personal Information';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PERSONAL_INFO_FOR'                         , N'en-US', null, null, null, N'Personal Information for {0}';
-- 07/16/2019 Paul.  React Client has some unsupported features. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FEATURE_NOT_SUPPORTED'                     , N'en-US', null, null, null, N'This feature is not supported at this time.';
-- 08/19/2019 Paul.  React Client uses Close in popups. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLOSE_BUTTON_LABEL'                        , N'en-US', null, null, null, N'Close';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CLOSE_BUTTON_TITLE'                        , N'en-US', null, null, null, N'Close';
-- 03/25/2022 Paul.  Allow Available columns to be added to SplendidGrid at runtime. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AVAILABLE_COLUMNS'                         , N'en-US', null, null, null, N'Columns';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AVAILABLE_CHOOSE_COLUMNS'                  , N'en-US', null, null, null, N'Choose Columns';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AVAILABLE_DISPLAYED'                       , N'en-US', null, null, null, N'Displayed';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AVAILABLE_HIDDEN'                          , N'en-US', null, null, null, N'Hidden';
-- 03/30/2022 Paul.  Add Insight fields. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_SUBPANELS'                          , N'en-US', null, null, null, N'Select which subpanels to view';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_TOTAL'                             , N'en-US', null, null, null, N'Total';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_TOTAL_VALUE'                       , N'en-US', null, null, null, N'Total Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_NEXT_EXPIRATION_DATE'              , N'en-US', null, null, null, N'Next Expiration Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_NEXT_ACTIVITY_DATE'                , N'en-US', null, null, null, N'Next Activity Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_LAST_TOUCHPOINT'                   , N'en-US', null, null, null, N'Last Touchpoint';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_LAST_PARTICIPATED'                 , N'en-US', null, null, null, N'Last Participated';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_OPEN_CASES_TOTAL'                  , N'en-US', null, null, null, N'Open Cases | Total';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_RENEWAL_DATE'                      , N'en-US', null, null, null, N'Renewal Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_TOTAL_OVERDUE_TOTAL'               , N'en-US', null, null, null, N'Total Overdue | Total';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSIGHT_LAST_ACTIVITY_DATE'                , N'en-US', null, null, null, N'Last Activity Date';
-- 04/06/2022 Paul.  Quick Search dropdown. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICK_SEARCH_NEW_BUTTON'                   , N'en-US', null, null, null, N'New';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICK_SEARCH_PLACEHOLDER'                  , N'en-US', null, null, null, N'Search...';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BULK_ACTION'                               , N'en-US', null, null, null, N'Bulk Action';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SEARCH_FILTER'                             , N'en-US', null, null, null, N'Filter';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */

exec dbo.spTERMINOLOGY_InsertOnly N'AL'                                            , N'en-US', null, N'states_dom'                        ,   1, N'Alabama';
exec dbo.spTERMINOLOGY_InsertOnly N'AK'                                            , N'en-US', null, N'states_dom'                        ,   2, N'Alaska';
exec dbo.spTERMINOLOGY_InsertOnly N'AZ'                                            , N'en-US', null, N'states_dom'                        ,   3, N'Arizona';
exec dbo.spTERMINOLOGY_InsertOnly N'AR'                                            , N'en-US', null, N'states_dom'                        ,   4, N'Arkansas';
exec dbo.spTERMINOLOGY_InsertOnly N'CA'                                            , N'en-US', null, N'states_dom'                        ,   5, N'California';
exec dbo.spTERMINOLOGY_InsertOnly N'CO'                                            , N'en-US', null, N'states_dom'                        ,   6, N'Colorado';
exec dbo.spTERMINOLOGY_InsertOnly N'CT'                                            , N'en-US', null, N'states_dom'                        ,   7, N'Connecticut';
exec dbo.spTERMINOLOGY_InsertOnly N'DE'                                            , N'en-US', null, N'states_dom'                        ,   8, N'Delaware';
exec dbo.spTERMINOLOGY_InsertOnly N'FL'                                            , N'en-US', null, N'states_dom'                        ,   9, N'Florida';
exec dbo.spTERMINOLOGY_InsertOnly N'GA'                                            , N'en-US', null, N'states_dom'                        ,  10, N'Georgia';
exec dbo.spTERMINOLOGY_InsertOnly N'HI'                                            , N'en-US', null, N'states_dom'                        ,  11, N'Hawaii';
exec dbo.spTERMINOLOGY_InsertOnly N'ID'                                            , N'en-US', null, N'states_dom'                        ,  12, N'Idaho';
exec dbo.spTERMINOLOGY_InsertOnly N'IL'                                            , N'en-US', null, N'states_dom'                        ,  13, N'Illinois';
exec dbo.spTERMINOLOGY_InsertOnly N'IN'                                            , N'en-US', null, N'states_dom'                        ,  14, N'Indiana';
exec dbo.spTERMINOLOGY_InsertOnly N'IA'                                            , N'en-US', null, N'states_dom'                        ,  15, N'Iowa';
exec dbo.spTERMINOLOGY_InsertOnly N'KS'                                            , N'en-US', null, N'states_dom'                        ,  16, N'Kansas';
exec dbo.spTERMINOLOGY_InsertOnly N'KY'                                            , N'en-US', null, N'states_dom'                        ,  17, N'Kentucky';
exec dbo.spTERMINOLOGY_InsertOnly N'LA'                                            , N'en-US', null, N'states_dom'                        ,  18, N'Louisiana';
exec dbo.spTERMINOLOGY_InsertOnly N'ME'                                            , N'en-US', null, N'states_dom'                        ,  19, N'Maine';
exec dbo.spTERMINOLOGY_InsertOnly N'MD'                                            , N'en-US', null, N'states_dom'                        ,  20, N'Maryland';
exec dbo.spTERMINOLOGY_InsertOnly N'MA'                                            , N'en-US', null, N'states_dom'                        ,  21, N'Massachusetts';
exec dbo.spTERMINOLOGY_InsertOnly N'MI'                                            , N'en-US', null, N'states_dom'                        ,  22, N'Michigan';
exec dbo.spTERMINOLOGY_InsertOnly N'MN'                                            , N'en-US', null, N'states_dom'                        ,  23, N'Minnesota';
exec dbo.spTERMINOLOGY_InsertOnly N'MS'                                            , N'en-US', null, N'states_dom'                        ,  24, N'Mississippi';
exec dbo.spTERMINOLOGY_InsertOnly N'MO'                                            , N'en-US', null, N'states_dom'                        ,  25, N'Missouri';
exec dbo.spTERMINOLOGY_InsertOnly N'MT'                                            , N'en-US', null, N'states_dom'                        ,  26, N'Montana';
exec dbo.spTERMINOLOGY_InsertOnly N'NE'                                            , N'en-US', null, N'states_dom'                        ,  27, N'Nebraska';
exec dbo.spTERMINOLOGY_InsertOnly N'NV'                                            , N'en-US', null, N'states_dom'                        ,  28, N'Nevada';
exec dbo.spTERMINOLOGY_InsertOnly N'NH'                                            , N'en-US', null, N'states_dom'                        ,  29, N'New Hampshire';
exec dbo.spTERMINOLOGY_InsertOnly N'NJ'                                            , N'en-US', null, N'states_dom'                        ,  30, N'New Jersey';
exec dbo.spTERMINOLOGY_InsertOnly N'NM'                                            , N'en-US', null, N'states_dom'                        ,  31, N'New Mexico';
exec dbo.spTERMINOLOGY_InsertOnly N'NY'                                            , N'en-US', null, N'states_dom'                        ,  32, N'New York';
exec dbo.spTERMINOLOGY_InsertOnly N'NC'                                            , N'en-US', null, N'states_dom'                        ,  33, N'North Carolina';
exec dbo.spTERMINOLOGY_InsertOnly N'ND'                                            , N'en-US', null, N'states_dom'                        ,  34, N'North Dakota';
exec dbo.spTERMINOLOGY_InsertOnly N'OH'                                            , N'en-US', null, N'states_dom'                        ,  35, N'Ohio';
exec dbo.spTERMINOLOGY_InsertOnly N'OK'                                            , N'en-US', null, N'states_dom'                        ,  36, N'Oklahoma';
exec dbo.spTERMINOLOGY_InsertOnly N'OR'                                            , N'en-US', null, N'states_dom'                        ,  37, N'Oregon';
exec dbo.spTERMINOLOGY_InsertOnly N'PA'                                            , N'en-US', null, N'states_dom'                        ,  38, N'Pennsylvania';
exec dbo.spTERMINOLOGY_InsertOnly N'RI'                                            , N'en-US', null, N'states_dom'                        ,  39, N'Rhode Island';
exec dbo.spTERMINOLOGY_InsertOnly N'SC'                                            , N'en-US', null, N'states_dom'                        ,  40, N'South Carolina';
exec dbo.spTERMINOLOGY_InsertOnly N'SD'                                            , N'en-US', null, N'states_dom'                        ,  41, N'South Dakota';
exec dbo.spTERMINOLOGY_InsertOnly N'TN'                                            , N'en-US', null, N'states_dom'                        ,  42, N'Tennessee';
exec dbo.spTERMINOLOGY_InsertOnly N'TX'                                            , N'en-US', null, N'states_dom'                        ,  43, N'Texas';
exec dbo.spTERMINOLOGY_InsertOnly N'UT'                                            , N'en-US', null, N'states_dom'                        ,  44, N'Utah';
exec dbo.spTERMINOLOGY_InsertOnly N'VT'                                            , N'en-US', null, N'states_dom'                        ,  45, N'Vermont';
exec dbo.spTERMINOLOGY_InsertOnly N'VA'                                            , N'en-US', null, N'states_dom'                        ,  46, N'Virginia';
exec dbo.spTERMINOLOGY_InsertOnly N'WA'                                            , N'en-US', null, N'states_dom'                        ,  47, N'Washington';
exec dbo.spTERMINOLOGY_InsertOnly N'WV'                                            , N'en-US', null, N'states_dom'                        ,  48, N'West Virginia';
exec dbo.spTERMINOLOGY_InsertOnly N'WI'                                            , N'en-US', null, N'states_dom'                        ,  49, N'Wisconsin';
exec dbo.spTERMINOLOGY_InsertOnly N'WY'                                            , N'en-US', null, N'states_dom'                        ,  50, N'Wyoming';
exec dbo.spTERMINOLOGY_InsertOnly N'AS'                                            , N'en-US', null, N'states_dom'                        ,  51, N'American Samoa';
exec dbo.spTERMINOLOGY_InsertOnly N'DC'                                            , N'en-US', null, N'states_dom'                        ,  52, N'District of Columbia';
exec dbo.spTERMINOLOGY_InsertOnly N'FM'                                            , N'en-US', null, N'states_dom'                        ,  53, N'Federated States of Micronesia';
exec dbo.spTERMINOLOGY_InsertOnly N'GU'                                            , N'en-US', null, N'states_dom'                        ,  54, N'Guam';
exec dbo.spTERMINOLOGY_InsertOnly N'MH'                                            , N'en-US', null, N'states_dom'                        ,  55, N'Marshall Islands';
exec dbo.spTERMINOLOGY_InsertOnly N'MP'                                            , N'en-US', null, N'states_dom'                        ,  56, N'Northern Mariana Islands';
exec dbo.spTERMINOLOGY_InsertOnly N'PW'                                            , N'en-US', null, N'states_dom'                        ,  57, N'Palau';
exec dbo.spTERMINOLOGY_InsertOnly N'PR'                                            , N'en-US', null, N'states_dom'                        ,  58, N'Puerto Rico';
exec dbo.spTERMINOLOGY_InsertOnly N'VI'                                            , N'en-US', null, N'states_dom'                        ,  59, N'Virgin Islands';
GO

-- 01/03/2016 Paul.  Add Yes/No and True/False. 
-- delete from TERMINOLOGY where LIST_NAME in ('yesno_dom', 'truefalse_dom');
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'yesno_dom'                         ,   1, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'yesno_dom'                         ,   2, N'No';
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'truefalse_dom'                     ,   1, N'True';
exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'truefalse_dom'                     ,   2, N'False';
-- 09/15/2019 Paul.  The React Client sees True/False and the ASP.NET client sees 1/0.  Need a list that supports both, simultaneously. 
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'yesno_list'                        ,   1, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'yesno_list'                        ,   2, N'No';
exec dbo.spTERMINOLOGY_InsertOnly N'True'                                          , N'en-US', null, N'yesno_list'                        ,   1, N'Yes';
exec dbo.spTERMINOLOGY_InsertOnly N'False'                                         , N'en-US', null, N'yesno_list'                        ,   2, N'No';

-- 03/02/2019 Paul.  Missing term. DetailViewsRelationships should be treated as a module so that the merge modules can be retrieved by the Word Plug-in. 
exec dbo.spTERMINOLOGY_InsertOnly N'DetailViewsRelationships'                      , N'en-US', null, N'moduleList'                        , 100, N'Detail Views Relationships';

-- 10/27/2019 Paul.  React Client needs to have a list for business mode. 
exec dbo.spTERMINOLOGY_InsertOnly N'B2B'                                           , N'en-US', null, N'business_mode_dom'                 ,   1, N'Business-to-Business';
exec dbo.spTERMINOLOGY_InsertOnly N'B2C'                                           , N'en-US', null, N'business_mode_dom'                 ,   2, N'Business-to-Consumer';
exec dbo.spTERMINOLOGY_InsertOnly N'Opportunities'                                 , N'en-US', null, N'opportunities_mode_dom'            ,   1, N'Opportunities';
exec dbo.spTERMINOLOGY_InsertOnly N'Revenue'                                       , N'en-US', null, N'opportunities_mode_dom'            ,   2, N'Opportunities with Revenue Line Items';
-- 05/25/2020 Paul.  React Client link on old login page. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REACT_CLIENT'                              , N'en-US', null, null, null, N'React Client';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INSUFFICIENT_ACCESS'                       , N'en-US', null, null, null, N'Insufficient Access';
-- 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAYOUT_TAB_OVERVIEW'                       , N'en-US', null, null, null, N'Overview';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAYOUT_TAB_MORE_INFORMATION'               , N'en-US', null, null, null, N'More Information';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAYOUT_TAB_OTHER'                          , N'en-US', null, null, null, N'Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAYOUT_TAB_BASIC'                          , N'en-US', null, null, null, N'Basic';
-- 04/23/2022 Paul.  Empy grid should indicate no data. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NO_DATA'                                   , N'en-US', null, null, null, N'No Data';
-- 04/06/2022 Paul.  Quick Search dropdown. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICK_SEARCH_NEW_BUTTON'                   , N'en-US', null, null, null, N'New';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_QUICK_SEARCH_PLACEHOLDER'                  , N'en-US', null, null, null, N'Search...';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BULK_ACTION'                               , N'en-US', null, null, null, N'Bulk Action';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SEARCH_FILTER'                             , N'en-US', null, null, null, N'Filter';
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

call dbo.spTERMINOLOGY_Global_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Global_en_us')
/
-- #endif IBM_DB2 */
