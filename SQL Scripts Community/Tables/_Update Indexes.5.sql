
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 *********************************************************************************************************************/
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_BUGS_ACCOUNT_ID'                          , 'ACCOUNTS_BUGS'                  , 'ACCOUNT_ID'         , 'DELETED'      , 'BUG_ID'              ;
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_BUGS_BUG_ID'                              , 'ACCOUNTS_BUGS'                  , 'BUG_ID'             , 'DELETED'      , 'ACCOUNT_ID'          ;
-- 04/24/2018 Paul.  ACCOUNTS_CASES use was ended back in 2005. The table needs to be removed as it causes problems with archiving. 
--exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_CASES_ACCOUNT_ID'                         , 'ACCOUNTS_CASES'                 , 'ACCOUNT_ID'         , 'DELETED'      , 'CASE_ID'             ;
--exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_CASES_CASE_ID'                            , 'ACCOUNTS_CASES'                 , 'CASE_ID'            , 'DELETED'      , 'ACCOUNT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_CONTACTS_ACCOUNT_ID'                      , 'ACCOUNTS_CONTACTS'              , 'ACCOUNT_ID'         , 'DELETED'      , 'CONTACT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_CONTACTS_CONTACT_ID'                      , 'ACCOUNTS_CONTACTS'              , 'CONTACT_ID'         , 'DELETED'      , 'ACCOUNT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_OPPORTUNITIES_ACCOUNT_ID'                 , 'ACCOUNTS_OPPORTUNITIES'         , 'ACCOUNT_ID'         , 'DELETED'      , 'OPPORTUNITY_ID'      ;
exec dbo.spSqlUpdateIndex 'IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID'             , 'ACCOUNTS_OPPORTUNITIES'         , 'OPPORTUNITY_ID'     , 'DELETED'      , 'ACCOUNT_ID'          ;
-- 05/02/2013 Paul.  Add new index fields. 
exec dbo.spSqlUpdateIndex 'IDX_CALLS_CONTACTS_CALL_ID'                            , 'CALLS_CONTACTS'                 , 'CALL_ID'            , 'DELETED'      , 'CONTACT_ID'          , 'ACCEPT_STATUS'       , 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_CALLS_CONTACTS_CONTACT_ID'                         , 'CALLS_CONTACTS'                 , 'CONTACT_ID'         , 'DELETED'      , 'CALL_ID'             , 'ACCEPT_STATUS'       , 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_CALLS_USERS_CALL_ID'                               , 'CALLS_USERS'                    , 'CALL_ID'            , 'DELETED'      , 'USER_ID'             , 'ACCEPT_STATUS'       , 'REMINDER_DISMISSED', 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_CALLS_USERS_USER_ID'                               , 'CALLS_USERS'                    , 'USER_ID'            , 'DELETED'      , 'CALL_ID'             , 'ACCEPT_STATUS'       , 'REMINDER_DISMISSED', 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_CASES_BUGS_CASE_ID'                                , 'CASES_BUGS'                     , 'CASE_ID'            , 'DELETED'      , 'BUG_ID'              ;
exec dbo.spSqlUpdateIndex 'IDX_CASES_BUGS_BUG_ID'                                 , 'CASES_BUGS'                     , 'BUG_ID'             , 'DELETED'      , 'CASE_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_BUGS_CONTACT_ID'                          , 'CONTACTS_BUGS'                  , 'CONTACT_ID'         , 'DELETED'      , 'BUG_ID'              ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_BUGS_BUG_ID'                              , 'CONTACTS_BUGS'                  , 'BUG_ID'             , 'DELETED'      , 'CONTACT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_CASES_CONTACT_ID'                         , 'CONTACTS_CASES'                 , 'CONTACT_ID'         , 'DELETED'      , 'CASE_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_CASES_CASE_ID'                            , 'CONTACTS_CASES'                 , 'CASE_ID'            , 'DELETED'      , 'CONTACT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_USERS_CONTACT_ID'                         , 'CONTACTS_USERS'                 , 'CONTACT_ID'         , 'DELETED'      , 'USER_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_CONTACTS_USERS_USER_ID'                            , 'CONTACTS_USERS'                 , 'USER_ID'            , 'DELETED'      , 'CONTACT_ID'          ;
-- 12/31/2010 Irantha.  Add index to improve caching. 
exec dbo.spSqlUpdateIndex 'IDX_EDITVIEWS_FIELDS_CACHE_NAME'                       , 'EDITVIEWS_FIELDS'               , 'DATA_FIELD'         , 'DELETED'      , 'FIELD_TYPE'          , 'DEFAULT_VIEW'        , 'CACHE_NAME';
exec dbo.spSqlUpdateIndex 'IDX_EMAIL_MARKETING_PROSPECT_LISTS_EMAIL_MARKETING_ID' , 'EMAIL_MARKETING_PROSPECT_LISTS' , 'EMAIL_MARKETING_ID' , 'DELETED'      , 'PROSPECT_LIST_ID'    ;
exec dbo.spSqlUpdateIndex 'IDX_EMAIL_MARKETING_PROSPECT_LISTS_PROSPECT_LIST_ID'   , 'EMAIL_MARKETING_PROSPECT_LISTS' , 'PROSPECT_LIST_ID'   , 'DELETED'      , 'EMAIL_MARKETING_ID'  ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_ACCOUNTS_EMAIL_ID'                          , 'EMAILS_ACCOUNTS'                , 'EMAIL_ID'           , 'DELETED'      , 'ACCOUNT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_ACCOUNTS_ACCOUNT_ID'                        , 'EMAILS_ACCOUNTS'                , 'ACCOUNT_ID'         , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_BUGS_EMAIL_ID'                              , 'EMAILS_BUGS'                    , 'EMAIL_ID'           , 'DELETED'      , 'BUG_ID'              ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_BUGS_BUG_ID'                                , 'EMAILS_BUGS'                    , 'BUG_ID'             , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_CASES_EMAIL_ID'                             , 'EMAILS_CASES'                   , 'EMAIL_ID'           , 'DELETED'      , 'CASE_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_CASES_CASE_ID'                              , 'EMAILS_CASES'                   , 'CASE_ID'            , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_CONTACTS_EMAIL_ID'                          , 'EMAILS_CONTACTS'                , 'EMAIL_ID'           , 'DELETED'      , 'CONTACT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_CONTACTS_CONTACT_ID'                        , 'EMAILS_CONTACTS'                , 'CONTACT_ID'         , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_LEADS_EMAIL_ID'                             , 'EMAILS_LEADS'                   , 'EMAIL_ID'           , 'DELETED'      , 'LEAD_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_LEADS_LEAD_ID'                              , 'EMAILS_LEADS'                   , 'LEAD_ID'            , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_OPPORTUNITIES_EMAIL_ID'                     , 'EMAILS_OPPORTUNITIES'           , 'EMAIL_ID'           , 'DELETED'      , 'OPPORTUNITY_ID'      ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_OPPORTUNITIES_OPPORTUNITY_ID'               , 'EMAILS_OPPORTUNITIES'           , 'OPPORTUNITY_ID'     , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROJECT_TASKS_EMAIL_ID'                     , 'EMAILS_PROJECT_TASKS'           , 'EMAIL_ID'           , 'DELETED'      , 'PROJECT_TASK_ID'     ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROJECT_TASKS_PROJECT_TASK_ID'              , 'EMAILS_PROJECT_TASKS'           , 'PROJECT_TASK_ID'    , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROJECTS_EMAIL_ID'                          , 'EMAILS_PROJECTS'                , 'EMAIL_ID'           , 'DELETED'      , 'PROJECT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROJECTS_PROJECT_ID'                        , 'EMAILS_PROJECTS'                , 'PROJECT_ID'         , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROSPECTS_EMAIL_ID'                         , 'EMAILS_PROSPECTS'               , 'EMAIL_ID'           , 'DELETED'      , 'PROSPECT_ID'         ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_PROSPECTS_PROSPECT_ID'                      , 'EMAILS_PROSPECTS'               , 'PROSPECT_ID'        , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_TASKS_EMAIL_ID'                             , 'EMAILS_TASKS'                   , 'EMAIL_ID'           , 'DELETED'      , 'TASK_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_TASKS_TASK_ID'                              , 'EMAILS_TASKS'                   , 'TASK_ID'            , 'DELETED'      , 'EMAIL_ID'            ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_USERS_EMAIL_ID'                             , 'EMAILS_USERS'                   , 'EMAIL_ID'           , 'DELETED'      , 'USER_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_EMAILS_USERS_USER_ID'                              , 'EMAILS_USERS'                   , 'USER_ID'            , 'DELETED'      , 'EMAIL_ID'            ;
-- 05/02/2013 Paul.  Add new index fields. 
exec dbo.spSqlUpdateIndex 'IDX_MEETINGS_CONTACTS_MEETING_ID'                      , 'MEETINGS_CONTACTS'              , 'MEETING_ID'         , 'DELETED'      , 'CONTACT_ID'          , 'ACCEPT_STATUS'       , 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_MEETINGS_CONTACTS_CONTACT_ID'                      , 'MEETINGS_CONTACTS'              , 'CONTACT_ID'         , 'DELETED'      , 'MEETING_ID'          , 'ACCEPT_STATUS'       , 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_MEETINGS_USERS_MEETING_ID'                         , 'MEETINGS_USERS'                 , 'MEETING_ID'         , 'DELETED'      , 'USER_ID'             , 'ACCEPT_STATUS'       , 'REMINDER_DISMISSED' , 'EMAIL_REMINDER_SENT';
exec dbo.spSqlUpdateIndex 'IDX_MEETINGS_USERS_USER_ID'                            , 'MEETINGS_USERS'                 , 'USER_ID'            , 'DELETED'      , 'MEETING_ID'          , 'ACCEPT_STATUS'       , 'REMINDER_DISMISSED' , 'EMAIL_REMINDER_SENT';
-- 12/30/2010 Irantha.  Add index for caching. 
exec dbo.spSqlUpdateIndex 'IX_MODULES_MODULE_NAME'                                , 'MODULES'                        , 'MODULE_NAME'        , 'DELETED'      , 'MODULE_ENABLED'      , 'IS_ADMIN'            , 'TAB_ORDER';
exec dbo.spSqlUpdateIndex 'IDX_OPPORTUNITIES_CONTACTS_CONTACT_ID'                 , 'OPPORTUNITIES_CONTACTS'         , 'CONTACT_ID'         , 'DELETED'      , 'OPPORTUNITY_ID'      ;
exec dbo.spSqlUpdateIndex 'IDX_OPPORTUNITIES_CONTACTS_OPPORTUNITY_ID'             , 'OPPORTUNITIES_CONTACTS'         , 'OPPORTUNITY_ID'     , 'DELETED'      , 'CONTACT_ID'          , 'CONTACT_ROLE'        ;
exec dbo.spSqlUpdateIndex 'IDX_PROJECT_RELATION_PROJECT_ID'                       , 'PROJECT_RELATION'               , 'PROJECT_ID'         , 'RELATION_TYPE', 'DELETED'             , 'RELATION_ID'         ;
exec dbo.spSqlUpdateIndex 'IDX_PROJECT_RELATION_RELATION_ID'                      , 'PROJECT_RELATION'               , 'RELATION_ID'        , 'RELATION_TYPE', 'DELETED'             , 'PROJECT_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_PROSPECT_LIST_CAMPAIGNS_PROSPECT_LIST_ID'          , 'PROSPECT_LIST_CAMPAIGNS'        , 'PROSPECT_LIST_ID'   , 'DELETED'      , 'CAMPAIGN_ID'         ;
exec dbo.spSqlUpdateIndex 'IDX_PROSPECT_LIST_CAMPAIGNS_CAMPAIGN_ID'               , 'PROSPECT_LIST_CAMPAIGNS'        , 'CAMPAIGN_ID'        , 'DELETED'      , 'PROSPECT_LIST_ID'    ;
exec dbo.spSqlUpdateIndex 'IDX_PROSPECT_LISTS_PROSPECTS_PROSPECT_LIST_ID'         , 'PROSPECT_LISTS_PROSPECTS'       , 'PROSPECT_LIST_ID'   , 'RELATED_TYPE' , 'DELETED'             , 'RELATED_ID'          ;
exec dbo.spSqlUpdateIndex 'IDX_PROSPECT_LISTS_PROSPECTS_RELATED_ID'               , 'PROSPECT_LISTS_PROSPECTS'       , 'RELATED_ID'         , 'RELATED_TYPE' , 'DELETED'             , 'PROSPECT_LIST_ID'    ;
exec dbo.spSqlUpdateIndex 'IDX_ROLES_MODULES_ROLE_ID'                             , 'ROLES_MODULES'                  , 'ROLE_ID'            , 'DELETED'      , 'MODULE_ID'           ;
exec dbo.spSqlUpdateIndex 'IDX_ROLES_MODULES_MODULE_ID'                           , 'ROLES_MODULES'                  , 'MODULE_ID'          , 'DELETED'      , 'ROLE_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_ROLES_USERS_ROLE_ID'                               , 'ROLES_USERS'                    , 'ROLE_ID'            , 'DELETED'      , 'USER_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_ROLES_USERS_USER_ID'                               , 'ROLES_USERS'                    , 'USER_ID'            , 'DELETED'      , 'ROLE_ID'             ;
-- 12/30/2010 Irantha.  Add index for caching. 
exec dbo.spSqlUpdateIndex 'IX_SHORTCUTS_SHORTCUT_ORDER'                           , 'SHORTCUTS'                      , 'DELETED'            , 'SHORTCUT_ORDER', 'SHORTCUT_MODULE'    ;
-- 12/30/2010 Irantha.  Add index for list caching. 
exec dbo.spSqlUpdateIndex 'IX_TERMINOLOGY_LIST_NAME'                              , 'TERMINOLOGY'                    , 'DELETED'            , 'LANG'         , 'LIST_NAME'           ;
exec dbo.spSqlUpdateIndex 'IDX_USERS_ID'                                          , 'USERS'                          , 'ID'                 , 'DELETED'      , 'STATUS'              , 'PORTAL_ONLY'         , 'USER_NAME'    ;
exec dbo.spSqlUpdateIndex 'IDX_USERS_USER_NAME'                                   , 'USERS'                          , 'USER_NAME'          , 'USER_HASH'    , 'DELETED'             , 'STATUS'              , 'PORTAL_ONLY'  , 'DEFAULT_TEAM';
exec dbo.spSqlUpdateIndex 'IDX_USERS_FEEDS_USER_ID'                               , 'USERS_FEEDS'                    , 'USER_ID'            , 'DELETED'      , 'FEED_ID'             ;
exec dbo.spSqlUpdateIndex 'IDX_USERS_FEEDS_FEED_ID'                               , 'USERS_FEEDS'                    , 'FEED_ID'            , 'DELETED'      , 'USER_ID'             ;
GO

