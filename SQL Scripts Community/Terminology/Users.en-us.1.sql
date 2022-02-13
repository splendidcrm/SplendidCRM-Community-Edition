

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 2:12:43 AM.
print 'TERMINOLOGY Users en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ENTER_CONFIRMATION_PASSWORD'               , N'en-US', N'Users', null, null, N'Are you sure?';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ENTER_NEW_PASSWORD'                        , N'en-US', N'Users', null, null, N'Enter New Password.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ENTER_OLD_PASSWORD'                        , N'en-US', N'Users', null, null, N'Enter Old Password.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_FORGOT_PASSWORD'                   , N'en-US', N'Users', null, null, N'Invalid User Name and Email Address.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_PASSWORD'                          , N'en-US', N'Users', null, null, N'Invalid User Name and Password.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_MAX_USERS'                                 , N'en-US', N'Users', null, null, N'Max Users.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_PASSWORD_INCORRECT_OLD'                    , N'en-US', N'Users', null, null, N'Old password does not match.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REASS_DIFF_USERS'                          , N'en-US', N'Users', null, null, N'You must select a different user.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REASS_SELECT_MODULE'                       , N'en-US', N'Users', null, null, N'You must select at least one module.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REENTER_PASSWORDS'                         , N'en-US', N'Users', null, null, N'Reenter Passwords.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_USER_NAME_EXISTS_1'                        , N'en-US', N'Users', null, null, N'The User Name ';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_USER_NAME_EXISTS_2'                        , N'en-US', N'Users', null, null, N' alredy exists.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_USER_NOT_FOUND'                            , N'en-US', N'Users', null, null, N'User Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_CANNOT_REUSE_PASSWORD'                     , N'en-US', N'Users', null, null, N'Cannot reuse password.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_USER_LOCKED_OUT'                           , N'en-US', N'Users', null, null, N'This user has been locked out.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FACEBOOK_LOGIN'                            , N'en-US', N'Users', null, null, N'Invalid facebook user.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_USER'                              , N'en-US', N'Users', null, null, N'Invalid user.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FACEBOOK_SIGNATURE'                        , N'en-US', N'Users', null, null, N'facebook arguments failed signature validation.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FACEBOOK_COOKIE'                           , N'en-US', N'Users', null, null, N'facebook cookie is missing.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_GET_ID'                           , N'en-US', N'Users', null, null, N'Get facebook ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FACEBOOK_ID'                               , N'en-US', N'Users', null, null, N'facebook ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEND_SUCCESSFUL'                           , N'en-US', N'Users', null, null, N'Send was successful.';
-- 08/09/2018 Paul.  Allow translation of connection success. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONNECTION_SUCCESSFUL'                     , N'en-US', N'Users', null, null, N'Connection successful. {0} items in {1}';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS'                                   , N'en-US', N'Users', null, null, N'Address';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_CITY'                              , N'en-US', N'Users', null, null, N'City:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_COUNTRY'                           , N'en-US', N'Users', null, null, N'Country:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_INFORMATION'                       , N'en-US', N'Users', null, null, N'Address Information';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_POSTALCODE'                        , N'en-US', N'Users', null, null, N'Postal Code:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_STATE'                             , N'en-US', N'Users', null, null, N'State:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADDRESS_STREET'                            , N'en-US', N'Users', null, null, N'Street:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN'                                     , N'en-US', N'Users', null, null, N'Admin';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN_DELEGATE'                            , N'en-US', N'Users', null, null, N'Admin Delegate:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN_DELEGATE_TEXT'                       , N'en-US', N'Users', null, null, N'Allows user to perform some admin functions.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADMIN_TEXT'                                , N'en-US', N'Users', null, null, N'Grant admin rights to this user.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ANY_EMAIL'                                 , N'en-US', N'Users', null, null, N'Any Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ANY_PHONE'                                 , N'en-US', N'Users', null, null, N'Any Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASPNET_SESSIONID'                          , N'en-US', N'Users', null, null, N'ASP.NET Session ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CALENDAR_OPTIONS'                          , N'en-US', N'Users', null, null, N'Calendar Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_PASSWORD'                           , N'en-US', N'Users', null, null, N'Change Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_PASSWORD_BUTTON_LABEL'              , N'en-US', N'Users', null, null, N'Change Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGE_PASSWORD_BUTTON_TITLE'              , N'en-US', N'Users', null, null, N'Change Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHOOSE_A_KEY'                              , N'en-US', N'Users', null, null, N'Choose A Key';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CITY'                                      , N'en-US', N'Users', null, null, N'City';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CONFIRM_PASSWORD'                          , N'en-US', N'Users', null, null, N'Confirm Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COUNTRY'                                   , N'en-US', N'Users', null, null, N'Country';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENCY'                                  , N'en-US', N'Users', null, null, N'Currency';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENCY_ID'                               , N'en-US', N'Users', null, null, N'Currency ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENCY_TEXT'                             , N'en-US', N'Users', null, null, N'Set default currency.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_FORMAT'                               , N'en-US', N'Users', null, null, N'Date Format';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_FORMAT_TEXT'                          , N'en-US', N'Users', null, null, N'Set date format.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DECIMAL_SEP'                               , N'en-US', N'Users', null, null, N'Decimal symbol';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DECIMAL_SEP_TEXT'                          , N'en-US', N'Users', null, null, N'Set decimal separator.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_TEAM'                              , N'en-US', N'Users', null, null, N'Default Team:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEFAULT_TEAM_NAME'                         , N'en-US', N'Users', null, null, N'Default Team Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DEPARTMENT'                                , N'en-US', N'Users', null, null, N'Department:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Users', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL'                                     , N'en-US', N'Users', null, null, N'Email address';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL1'                                    , N'en-US', N'Users', null, null, N'Email:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL2'                                    , N'en-US', N'Users', null, null, N'Other Email:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMPLOYEE_STATUS'                           , N'en-US', N'Users', null, null, N'Employee Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ERROR'                                     , N'en-US', N'Users', null, null, N'Error';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FAX'                                       , N'en-US', N'Users', null, null, N'Fax';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIRST_NAME'                                , N'en-US', N'Users', null, null, N'First Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FORGOT_PASSWORD'                           , N'en-US', N'Users', null, null, N'Forgot Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FULL_NAME'                                 , N'en-US', N'Users', null, null, N'Full Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GRIDLINE'                                  , N'en-US', N'Users', null, null, N'Gridline';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GRIDLINE_TEXT'                             , N'en-US', N'Users', null, null, N'Show gridlines.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP'                                     , N'en-US', N'Users', null, null, N'Group:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_TABS'                                , N'en-US', N'Users', null, null, N'Show Group Tabs:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GROUP_TABS_TEXT'                           , N'en-US', N'Users', null, null, N'Display the tab menu in groups.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HOME_PHONE'                                , N'en-US', N'Users', null, null, N'Home Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INVALID_DECIMAL'                           , N'en-US', N'Users', null, null, N'Invalid Decimal';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_ADMIN'                                  , N'en-US', N'Users', null, null, N'Is Admin:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_ADMIN_DELEGATE'                         , N'en-US', N'Users', null, null, N'Is Admin Delegate:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_GROUP'                                  , N'en-US', N'Users', null, null, N'Is Group:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LANGUAGE'                                  , N'en-US', N'Users', null, null, N'Language';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LANGUAGE_TEXT'                             , N'en-US', N'Users', null, null, N'Select language.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_NAME'                                 , N'en-US', N'Users', null, null, N'Last Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADDRESS_CITY'                         , N'en-US', N'Users', null, null, N'City';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADDRESS_COUNTRY'                      , N'en-US', N'Users', null, null, N'Country';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADDRESS_POSTALCODE'                   , N'en-US', N'Users', null, null, N'Postal Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADDRESS_STATE'                        , N'en-US', N'Users', null, null, N'State';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADDRESS_STREET'                       , N'en-US', N'Users', null, null, N'Street';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ADMIN'                                , N'en-US', N'Users', null, null, N'Admin';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ASPNET_SESSIONID'                     , N'en-US', N'Users', null, null, N'ASP.NET Session ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEFAULT_TEAM'                         , N'en-US', N'Users', null, null, N'Default Team';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEFAULT_TEAM_NAME'                    , N'en-US', N'Users', null, null, N'Default Team Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DEPARTMENT'                           , N'en-US', N'Users', null, null, N'Department';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Users', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMAIL'                                , N'en-US', N'Users', null, null, N'Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMAIL1'                               , N'en-US', N'Users', null, null, N'Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMAIL2'                               , N'en-US', N'Users', null, null, N'Other Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EMPLOYEE_STATUS'                      , N'en-US', N'Users', null, null, N'Employee Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FIRST_NAME'                           , N'en-US', N'Users', null, null, N'First Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Users', null, null, N'User List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_GROUP'                                , N'en-US', N'Users', null, null, N'Group';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_ADMIN'                             , N'en-US', N'Users', null, null, N'Is Admin';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_ADMIN_DELEGATE'                    , N'en-US', N'Users', null, null, N'Is Admin Delegate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_GROUP'                             , N'en-US', N'Users', null, null, N'Is Group';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_NAME'                            , N'en-US', N'Users', null, null, N'Last Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LOGIN_DATE'                           , N'en-US', N'Users', null, null, N'Login Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LOGIN_STATUS'                         , N'en-US', N'Users', null, null, N'Login Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LOGIN_TYPE'                           , N'en-US', N'Users', null, null, N'Login Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LOGOUT_DATE'                          , N'en-US', N'Users', null, null, N'Logout Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAIL_SMTPPASS'                        , N'en-US', N'Users', null, null, N'Mail Smtppass';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAIL_SMTPUSER'                        , N'en-US', N'Users', null, null, N'Mail Smtpuser';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSENGER_ID'                         , N'en-US', N'Users', null, null, N'Messenger ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MESSENGER_TYPE'                       , N'en-US', N'Users', null, null, N'Messenger Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Users', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE_FAX'                            , N'en-US', N'Users', null, null, N'Phone Fax';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE_HOME'                           , N'en-US', N'Users', null, null, N'Phone Home';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE_MOBILE'                         , N'en-US', N'Users', null, null, N'Phone Mobile';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE_OTHER'                          , N'en-US', N'Users', null, null, N'Phone Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PHONE_WORK'                           , N'en-US', N'Users', null, null, N'Phone Work';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PORTAL_ONLY'                          , N'en-US', N'Users', null, null, N'Portal Only';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIMARY_PHONE'                        , N'en-US', N'Users', null, null, N'Primary Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PWD_LAST_CHANGED'                     , N'en-US', N'Users', null, null, N'Pwd Last Changed';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RECEIVE_NOTIFICATIONS'                , N'en-US', N'Users', null, null, N'Receive Notifications';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REMOTE_HOST'                          , N'en-US', N'Users', null, null, N'Remote Host';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REPORTS_TO_ID'                        , N'en-US', N'Users', null, null, N'Reports To ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REPORTS_TO_NAME'                      , N'en-US', N'Users', null, null, N'Reports To Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Users', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SYSTEM_GENERATED_PASSWORD'            , N'en-US', N'Users', null, null, N'System Generated Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TARGET'                               , N'en-US', N'Users', null, null, N'Target';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TITLE'                                , N'en-US', N'Users', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_HASH'                            , N'en-US', N'Users', null, null, N'User Hash';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_NAME'                            , N'en-US', N'Users', null, null, N'User Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_PASSWORD'                        , N'en-US', N'Users', null, null, N'User Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_PREFERENCES'                     , N'en-US', N'Users', null, null, N'User Preferences';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN'                                     , N'en-US', N'Users', null, null, N'User Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_BUTTON_LABEL'                        , N'en-US', N'Users', null, null, N'Login';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_BUTTON_TITLE'                        , N'en-US', N'Users', null, null, N'Login';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_DATE'                                , N'en-US', N'Users', null, null, N'Login Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_OPTIONS'                             , N'en-US', N'Users', null, null, N'Login Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGIN_STATUS'                              , N'en-US', N'Users', null, null, N'Login Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGINS'                                    , N'en-US', N'Users', null, null, N'Logins';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LOGOUT_DATE'                               , N'en-US', N'Users', null, null, N'Logout Date:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_FROMADDRESS'                          , N'en-US', N'Users', null, null, N'Mail Fromaddress';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_FROMNAME'                             , N'en-US', N'Users', null, null, N'Mail Fromname';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_OPTIONS_TITLE'                        , N'en-US', N'Users', null, null, N'Mail Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPPASS'                             , N'en-US', N'Users', null, null, N'SMTP Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPUSER'                             , N'en-US', N'Users', null, null, N'SMTP Username:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSENGER_ID'                              , N'en-US', N'Users', null, null, N'Messenger ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MESSENGER_TYPE'                            , N'en-US', N'Users', null, null, N'Messenger Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MOBILE_PHONE'                              , N'en-US', N'Users', null, null, N'Mobile Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Users', null, null, N'Users';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Users', null, null, N'Usr';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_TEAMS'                                  , N'en-US', N'Users', null, null, N'My Teams';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Users', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_PASSWORD'                              , N'en-US', N'Users', null, null, N'New Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTES'                                     , N'en-US', N'Users', null, null, N'Notes';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NUMBER_GROUPING_SEP'                       , N'en-US', N'Users', null, null, N'1000s separator';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NUMBER_GROUPING_SEP_TEXT'                  , N'en-US', N'Users', null, null, N'Group separator.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFFICE_PHONE'                              , N'en-US', N'Users', null, null, N'Office Phone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OLD_PASSWORD'                              , N'en-US', N'Users', null, null, N'Old Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OPTIONAL'                                  , N'en-US', N'Users', null, null, N'Optional';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OTHER'                                     , N'en-US', N'Users', null, null, N'Other';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OTHER_EMAIL'                               , N'en-US', N'Users', null, null, N'Other Email';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_ID'                                 , N'en-US', N'Users', null, null, N'Parent ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_NAME'                               , N'en-US', N'Users', null, null, N'Parent Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_TYPE'                               , N'en-US', N'Users', null, null, N'Parent Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD'                                  , N'en-US', N'Users', null, null, N'Password';
-- 02/19/2011 Paul.  Messages are now external. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_CHARACTERS'             , N'en-US', N'Users', null, null, N'{0} more character(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_NUMBERS'                , N'en-US', N'Users', null, null, N'{0} more number(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_LOWERCASE'              , N'en-US', N'Users', null, null, N'{0} more lower case character(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_UPPERCASE'              , N'en-US', N'Users', null, null, N'{0} more upper case character(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_SYMBOLS'                , N'en-US', N'Users', null, null, N'{0} symbol character(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_REMAINING_MIXEDCASE'              , N'en-US', N'Users', null, null, N'{0} more mixed case character(s)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_SATISFIED'                        , N'en-US', N'Users', null, null, N'Nothing more required';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PASSWORD_EXPIRED'                          , N'en-US', N'Users', null, null, N'Password expired.  You must change it.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PHONE_FAX'                                 , N'en-US', N'Users', null, null, N'Phone Fax:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PHONE_HOME'                                , N'en-US', N'Users', null, null, N'Phone Home:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PHONE_MOBILE'                              , N'en-US', N'Users', null, null, N'Phone Mobile:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PHONE_OTHER'                               , N'en-US', N'Users', null, null, N'Phone Other:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PHONE_WORK'                                , N'en-US', N'Users', null, null, N'Phone Work:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PICK_TZ_DESCRIPTION'                       , N'en-US', N'Users', null, null, N'Please select your time zone.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PICK_TZ_WELCOME'                           , N'en-US', N'Users', null, null, N'Welcome to SplendidCRM.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PORT'                                      , N'en-US', N'Users', null, null, N'Port';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PORTAL_ONLY'                               , N'en-US', N'Users', null, null, N'Portal Only:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PORTAL_ONLY_TEXT'                          , N'en-US', N'Users', null, null, N'Show on portal only.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POSTAL_CODE'                               , N'en-US', N'Users', null, null, N'Postal Code';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIMARY_ADDRESS'                           , N'en-US', N'Users', null, null, N'Primary Address';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PUBLISH_KEY'                               , N'en-US', N'Users', null, null, N'Publish Key';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PWD_LAST_CHANGED'                          , N'en-US', N'Users', null, null, N'Pwd Last Changed:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_ASSESSING'                           , N'en-US', N'Users', null, null, N'Assessing {0}';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_CLEAR'                        , N'en-US', N'Users', null, null, N'Clear';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_CONTINUE'                     , N'en-US', N'Users', null, null, N'Continue';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_GO_BACK'                      , N'en-US', N'Users', null, null, N'Go Back';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_RESTART'                      , N'en-US', N'Users', null, null, N'Restart';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_RETURN'                       , N'en-US', N'Users', null, null, N'Return';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_BUTTON_SUBMIT'                       , N'en-US', N'Users', null, null, N'Submit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_DESC_PART1'                          , N'en-US', N'Users', null, null, N'Reassign records from one user to another.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_FILTERS'                             , N'en-US', N'Users', null, null, N'{0} Filters';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_MOD_REASSIGN'                        , N'en-US', N'Users', null, null, N'Modules:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_NO_CHANGE'                           , N'en-US', N'Users', null, null, N'-- No Change --';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_NOTES_TITLE'                         , N'en-US', N'Users', null, null, N'Note: Workflows will fire as usual.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_SCRIPT_TITLE'                        , N'en-US', N'Users', null, null, N'Record Reassignment';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_SELECT_USER'                         , N'en-US', N'Users', null, null, N'Select User.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_SUCCESSFUL'                          , N'en-US', N'Users', null, null, N'Update complete: {0} affected';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_USER_FROM'                           , N'en-US', N'Users', null, null, N'From:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_USER_TEAM'                           , N'en-US', N'Users', null, null, N'Set Team:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_USER_TO'                             , N'en-US', N'Users', null, null, N'To:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_WILL_BE_UPDATED'                     , N'en-US', N'Users', null, null, N'{0} records from {1} will be updated.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASS_WORK_NOTIF_AUDIT'                    , N'en-US', N'Users', null, null, N'Reassign workflows';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REASSIGN_TITLE'                            , N'en-US', N'Users', null, null, N'Reassignment';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RECEIVE_NOTIFICATIONS'                     , N'en-US', N'Users', null, null, N'Receive Notifications:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RECEIVE_NOTIFICATIONS_TEXT'                , N'en-US', N'Users', null, null, N'Show notifications.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMINDER'                                  , N'en-US', N'Users', null, null, N'Reminder';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMINDER_TEXT'                             , N'en-US', N'Users', null, null, N'Show reminders.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOTE_HOST'                               , N'en-US', N'Users', null, null, N'Remote Host:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPORTS_TO_ID'                             , N'en-US', N'Users', null, null, N'Reports To ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPORTS_TO_NAME'                           , N'en-US', N'Users', null, null, N'Reports To Name:';
-- 10/12/2020 Paul.  Employees module may be disabled, so make sure to define LBL_REPORTS_TO for use on Users.EditView. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPORTS_TO'                                , N'en-US', N'Users', null, null, N'Reports To:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REQUIRE'                                   , N'en-US', N'Users', null, null, N'Require';
-- 02/16/2011 Paul.  Fix URL for ChangePassword.  It had a single " and not enclosing double quotes. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RESET_PASSWORD_BODY'                       , N'en-US', N'Users', null, null, N'<p>A password reset was requested.</p><p>Please click the following link to reset your password:</p><p><a href="{0}">{0}</a></p>';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RESET_PASSWORD_STATUS'                     , N'en-US', N'Users', null, null, N'A Reset Password request has been emailed to the user.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RESET_PASSWORD_SUBJECT'                    , N'en-US', N'Users', null, null, N'Reset your password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_QUERY'                                , N'en-US', N'Users', null, null, N'Save Query';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SAVE_QUERY_TEXT'                           , N'en-US', N'Users', null, null, N'Save search panel filters.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_URL'                                , N'en-US', N'Users', null, null, N'Search Url';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATE'                                     , N'en-US', N'Users', null, null, N'State';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Users', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBPANEL_TABS'                             , N'en-US', N'Users', null, null, N'Show SubPanel Tabs:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBPANEL_TABS_TEXT'                        , N'en-US', N'Users', null, null, N'Display the SubPanels in groups.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYSTEM_GENERATED_PASSWORD'                 , N'en-US', N'Users', null, null, N'System Generated Password:';
-- 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYSTEM_GENERATED_PASSWORD_TEXT'            , N'en-US', N'Users', null, null, N'User must change password at next login.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TARGET'                                    , N'en-US', N'Users', null, null, N'Target:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_THEME'                                     , N'en-US', N'Users', null, null, N'Theme';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_THEME_TEXT'                                , N'en-US', N'Users', null, null, N'Select theme.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIME_FORMAT'                               , N'en-US', N'Users', null, null, N'Time Format';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIME_FORMAT_TEXT'                          , N'en-US', N'Users', null, null, N'Set time format.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIMEZONE'                                  , N'en-US', N'Users', null, null, N'Timezone';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIMEZONE_ID'                               , N'en-US', N'Users', null, null, N'Timezone ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIMEZONE_TEXT'                             , N'en-US', N'Users', null, null, N'Set time zone.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TITLE'                                     , N'en-US', N'Users', null, null, N'Title:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER'                                      , N'en-US', N'Users', null, null, N'User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_ASSIGNMENT_OPTIONAL'                  , N'en-US', N'Users', null, null, N'User Assignment Optional';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_ASSIGNMENT_REQUIRED'                  , N'en-US', N'Users', null, null, N'User Assignment Required';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_HASH'                                 , N'en-US', N'Users', null, null, N'User Hash:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_INFORMATION'                          , N'en-US', N'Users', null, null, N'User Information';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_NAME'                                 , N'en-US', N'Users', null, null, N'User Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_PASSWORD'                             , N'en-US', N'Users', null, null, N'User Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_PREFERENCES'                          , N'en-US', N'Users', null, null, N'User Preferences:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_SETTINGS'                             , N'en-US', N'Users', null, null, N'User Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_YOUR_PUBLISH_URL'                          , N'en-US', N'Users', null, null, N'Your Publish Url';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_USER'                                  , N'en-US', N'Users', null, null, N'Create User';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REASSIGN_RECORDS'                          , N'en-US', N'Users', null, null, N'Reassign Records';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_USER_LIST'                                 , N'en-US', N'Users', null, null, N'Users';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPERSONATE'                               , N'en-US', N'Users', null, null, N'Impersonate';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IMPERSONATING'                             , N'en-US', N'Users', null, null, N'Impersonating';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_SYNC_CONTACTS'                  , N'en-US', N'Users', null, null, N'Sync Google Contacts:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_SYNC_CALENDAR'                  , N'en-US', N'Users', null, null, N'Sync Google Calendar:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_USERNAME'                       , N'en-US', N'Users', null, null, N'Google Apps Username:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_PASSWORD'                       , N'en-US', N'Users', null, null, N'Google Apps Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_USERNAME_TIP'                   , N'en-US', N'Users', null, null, N'Only when different from SMTP Username';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_PASSWORD_TIP'                   , N'en-US', N'Users', null, null, N'Only when different from SMTP Password';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_OPTIONS_TITLE'                  , N'en-US', N'Users', null, null, N'Google Apps Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_TEST_SUCCESSFUL'                , N'en-US', N'Users', null, null, N'Google Apps authentication was successful.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_SYNC'                           , N'en-US', N'Users', null, null, N'Google Apps Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_GOOGLEAPPS_SYNC_ALL'                       , N'en-US', N'Users', null, null, N'Google Apps Sync All';
GO

-- 12/13/2011 Paul.  Add support for Apple iCloud. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_SYNC_CONTACTS'                      , N'en-US', N'Users', null, null, N'Sync iCloud Contacts:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_SYNC_CALENDAR'                      , N'en-US', N'Users', null, null, N'Sync iCloud Calendar:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_USERNAME'                           , N'en-US', N'Users', null, null, N'iCloud Username:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_PASSWORD'                           , N'en-US', N'Users', null, null, N'iCloud Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_OPTIONS_TITLE'                      , N'en-US', N'Users', null, null, N'iCloud Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_TEST_SUCCESSFUL'                    , N'en-US', N'Users', null, null, N'iCloud authentication was successful.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_SYNC'                               , N'en-US', N'Users', null, null, N'iCloud Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_SYNC_ALL'                           , N'en-US', N'Users', null, null, N'iCloud Sync All';
-- 07/11/2020 Paul.  iCloud now uses 2 factor authentication, so we need to prompt for the security code. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_SECURITY_CODE'                      , N'en-US', N'Users', null, null, N'Security Code:';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_ICLOUD_SECURITY_CODE_REQUIRED'             , N'en-US', N'Users', null, null, N'Security Code is required.';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_SYNC'                             , N'en-US', N'Users', null, null, N'Exchange Sync';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXCHANGE_SYNC_ALL'                         , N'en-US', N'Users', null, null, N'Exchange Sync All';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SYNC_BACKGROUND'                           , N'en-US', N'Users', null, null, N'Sync will be performed in a background thread.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Users', null, null, N'Create User';

-- 04/16/2013 Paul.  Allow system to be restricted by IP Address. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_INVALID_IP_ADDRESS'                        , N'en-US', N'Users', null, null, N'Invalid IP Address.';

-- 04/17/2013 Paul.  New page to distribute records. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REDISTRIBUTE_RECORDS'                      , N'en-US', N'Users', null, null, N'Redistribute Records';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REDISTRIBUTE_TITLE'                        , N'en-US', N'Users', null, null, N'Redistribute Records';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REDISTRIBUTE_DESCRIPTION'                  , N'en-US', N'Users', null, null, N'Redistribute records from one user to many users, with dependent records following the parent.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REDISTRIBUTE_SELECT_USERS'                 , N'en-US', N'Users', null, null, N'Select one or more users.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REDISTRIBUTE_WILL_BE_UPDATED'              , N'en-US', N'Users', null, null, N'{0} records from {1} will be distributed to the following users: {2}';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REDISTRIBUTE_SELECT_USERS'                 , N'en-US', N'Users', null, null, N'You must select at least one user.';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_REDISTRIBUTE_DIFF_USERS'                   , N'en-US', N'Users', null, null, N'Records cannot be redistributed to the same user.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REDISTRIBUTE_SUCCESSFUL'                   , N'en-US', N'Users', null, null, N'Update complete: {0} affected';

-- 09/20/2013 Paul.  Move EXTENSION to the main table. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EXTENSION'                                 , N'en-US', N'Users', null, null, N'Extension:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_EXTENSION'                            , N'en-US', N'Users', null, null, N'Extension';
-- 09/22/2013 Paul.  Add SmsMessages module. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SMS_OPT_IN'                                , N'en-US', N'Users', null, null, N'SMS Opt In:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SMS_OPT_IN'                           , N'en-US', N'Users', null, null, N'SMS Opt In';
-- 11/21/2014 Paul.  Add User Picture. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PICTURE'                                   , N'en-US', N'Users', null, null, N'Picture:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PICTURE'                              , N'en-US', N'Users', null, null, N'Picture';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCESS_RIGHTS'                             , N'en-US', N'Users', null, null, N'Access Rights';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFFICE365_OPTIONS_TITLE'                   , N'en-US', N'Users', null, null, N'Office 365 Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ICLOUD_NOT_ENABLED'                        , N'en-US', N'Users', null, null, N'iCloud has not been enabled.';

-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DYNAMIC'                                   , N'en-US', N'Users', null, null, N'Dynamic';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SINGULAR'                                  , N'en-US', N'Users', null, null, N'Singular';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNMENT_DYNAMIC'                        , N'en-US', N'Users', null, null, N' and Dynamic';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ASSIGNMENT_NOT_DYNAMIC'                    , N'en-US', N'Users', null, null, N' and Not Dynamic';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATING_MODULES_DYNAMIC_ASSIGNMENT'       , N'en-US', N'Users', null, null, N'Updating all modules to Dynamic Assignment in the background.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATING_MODULES_DYNAMIC_TEAMS'            , N'en-US', N'Users', null, null, N'Updating all modules to Dynamic Teams in the background.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIMARY_USER'                         , N'en-US', N'Users', null, null, N'Primary';
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Users'                                         , N'en-US', null, N'moduleList'                        ,  25, N'Users';
exec dbo.spTERMINOLOGY_InsertOnly N'Users'                                         , N'en-US', null, N'moduleListSingular'                ,  24, N'User';

exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'employee_status_dom'               ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Terminated'                                    , N'en-US', null, N'employee_status_dom'               ,   2, N'Terminated';
exec dbo.spTERMINOLOGY_InsertOnly N'Leave of Absence'                              , N'en-US', null, N'employee_status_dom'               ,   3, N'Leave of absence';

exec dbo.spTERMINOLOGY_InsertOnly N'MSN'                                           , N'en-US', null, N'messenger_type_dom'                ,   1, N'Msn';
exec dbo.spTERMINOLOGY_InsertOnly N'Yahoo!'                                        , N'en-US', null, N'messenger_type_dom'                ,   2, N'Yahoo!';
exec dbo.spTERMINOLOGY_InsertOnly N'AOL'                                           , N'en-US', null, N'messenger_type_dom'                ,   3, N'Aol';

exec dbo.spTERMINOLOGY_InsertOnly N'sendmail'                                      , N'en-US', null, N'notifymail_sendtype'               ,   1, N'Sendmail';
exec dbo.spTERMINOLOGY_InsertOnly N'SMTP'                                          , N'en-US', null, N'notifymail_sendtype'               ,   2, N'Smtp';

exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'user_status_dom'                   ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Inactive'                                      , N'en-US', null, N'user_status_dom'                   ,   2, N'Inactive';

-- 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
-- delete from TERMINOLOGY where LIST_NAME = 'user_mail_send_type';
exec dbo.spTERMINOLOGY_InsertOnly N'smtp'                                          , N'en-US', null, N'user_mail_send_type', 1, N'SMTP';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SENDTYPE'                             , N'en-US', N'Users', null, null, N'Send Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SMTP_TITLE'                                , N'en-US', N'Users', null, null, N'SMTP Settings';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPSERVER'                           , N'en-US', N'Users', null, null, N'SMTP Server:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPPORT'                             , N'en-US', N'Users', null, null, N'Port:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPUSER'                             , N'en-US', N'Users', null, null, N'Login:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPPASS'                             , N'en-US', N'Users', null, null, N'Password:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPAUTH_REQ'                         , N'en-US', N'Users', null, null, N'Use SMTP Authentication?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAIL_SMTPSSL'                              , N'en-US', N'Users', null, null, N'Enable SMTP over SSL:';
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_EMAIL_REQUIRED_TO_TEST'                    , N'en-US', N'Users', null, null, N'Email is required to test.';
-- 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_USER_SET'                              , N'en-US', N'Users', null, null, N'Add';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPLACE_USER_SET'                          , N'en-US', N'Users', null, null, N'Replace';
-- 02/18/2020 Paul. Allow React Client to forget password. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADFS_AUTHENTICATION_REQUIRED'              , N'en-US', N'Users', null, null, N'ADFS Authentication Required.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AZURE_AUTHENTICATION_REQUIRED'             , N'en-US', N'Users', null, null, N'Azure Authentication Required.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WINDOWS_AUTHENTICATION_REQUIRED'           , N'en-US', N'Users', null, null, N'Windows Authentication Required.';
-- 07/04/2020 Paul.  Configurator.LBL_EMAIL_TEST_OUTBOUND_SETTINGS may not be available to the React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EMAIL_TEST'                                , N'en-US', N'Users', null, null, N'Test';
-- 08/11/2020 Paul.  Employees module may be disabled, so create a Users version of LBL_RESET_PREFERENCES. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RESET_PREFERENCES'                         , N'en-US', N'Users', null, null, N'Reset Preferences';

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

call dbo.spTERMINOLOGY_Users_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Users_en_us')
/
-- #endif IBM_DB2 */
