if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlTablesAudited')
	Drop View dbo.vwSqlTablesAudited;
GO


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
-- 01/16/2008 Paul.  Simplify conversion to Oracle. 
-- 02/11/2008 Paul.  PAYMENTS_TRANSACTIONS is not audited. 
-- 03/02/2008 Paul.  USERS_LOGINS is not audited. 
-- 03/06/2008 Paul.  SYSTEM_LOG is not audited.
-- 04/02/2008 Paul.  VALIDATION_EXPRESSIONS is not audited.
-- 04/08/2008 Paul.  FIELD_VALIDATORS is not audited.
-- 04/08/2008 Paul.  DYNAMIC_BUTTONS is not audited.
-- 04/22/2008 Paul.  EMAIL_CACHE is new to SugarCRM 5.0 and is not audited. 
-- 07/16/2008 Paul.  Workflow tables are not audited. 
-- 07/19/2008 Paul.  Exclude all workflow tables. 
-- 08/16/2008 Paul.  Allow triggers on CAMPAIGN_LOG so that we can run a workflow on the event. 
-- 08/20/2008 Paul.  Move system tables to a separate view. 
-- 08/20/2008 Paul.  Use separate views for the cached data. 
-- 09/07/2008 Paul.  Exclude temp tables (usedi n Oracle). 
-- 10/07/2008 Paul.  PROSPECT_LISTS should be audited so that assignment notifications can be generated. 
-- 10/08/2008 Paul.  INETLOG should not be audited.  This table is used on our demo site. 
-- 10/08/2008 Paul.  Workflow tables start with WWF_.
-- 04/03/2009 Paul.  Exclude QuickBooks tables from audit. 
-- 04/06/2009 Paul.  Exclude QuickBooks Sync tables from audit. 
-- 05/01/2009 Paul.  Exclude temp tables during SugarCRM migration. 
-- 05/01/2009 Paul.  We need to isolate tables that are non CRM tables. 
-- 07/21/2009 Paul.  Sync tables will not be audited. 
-- 07/25/2009 Paul.  NUMBER_SEQUENCES is not audited. 
-- 10/07/2009 Paul.  All tables beginning with SYSTEM_ should be treated as a system table. 
-- 01/25/2010 Paul.  AUDIT_EVENTS should not be audited, as it is already an audit table. 
-- 02/18/2010 Paul.  SEMANTIC_MODEL tables should not be audited. 
-- 02/18/2010 Paul.  TAB_GROUPS and MODULES_GROUPS should not be audited. 
-- 05/12/2010 Paul.  USERS_PASSWORD_LINK should not be audited.
-- 07/12/2010 Paul.  REPORTS should be audited so that the Workflow editor will work with Report workflows. 
-- 07/12/2010 Paul.  EMAIL_TEMPLATES should be audited as this is user-edited data. 
-- 07/12/2010 Paul.  PRODUCT_TEMPLATES should be audited as this is user-edited data. 
-- 12/05/2010 Paul.  Add OUTBOUND_EMAILS, REGIONS and TEAM_SETS.
-- 09/14/2011 Paul.  EXCHANGE_USERS does not need to be audited. It is getting very large with all the watermarks. 
-- 04/03/2012 Paul.  SUGARFAVORITES is not audited. 
-- 04/08/2012 Paul.  OAUTHKEYS and OAUTH_TOKENS are not audited. 
-- 07/05/2012 Paul.  PHONE_NUMBERS is not audited for now since it only contains the normalized number. 
-- 11/19/2012 Paul.  USERS_SIGNATURES should be audited as it is user data. 
-- 11/22/2012 Paul.  LAST_ACTIVITY is not audited. 
-- 01/23/2013 Paul.  CALL_MARKETING does not need to be audited. 
-- 04/17/2013 Paul.  SUGARFEED does not need to be audited. 
-- 06/15/2013 Paul.  Allow triggers on SURVEY_RESULTS and SURVEY_QUESTIONS_RESULTS so that we can run a workflow on the event. 
-- 08/08/2013 Paul.  Allow triggers on PROSPECT_LIST_CAMPAIGNS and PROSPECT_LISTS_PROSPECTS for undelete. 
-- 08/08/2013 Paul.  Exclude CALL_MARKETING_PROSPECT_LISTS. 
-- 08/08/2013 Paul.  Allow auditing of NOTE_ATTACHMENTS to allow undelete. 
-- 10/30/2013 Paul.  Allow auditing of CONTRACT_TYPES_DOCUMENTS.
-- 09/14/2015 Paul.  Do not audit OAUTH_SYNC_TOKENS. 
-- 09/24/2015 Paul.  Exclude Activity Stream tables. 
-- 10/01/2015 Paul.  Exclude Azure System Log table. 
-- 10/01/2015 Paul.  Correct wildcard with []. 
-- 10/09/2015 Paul.  Exclude SUGARFAVORITES and SUBSCRIPTIONS
-- 04/12/2016 Paul.  Exclude ZIPCODES. 
-- 05/12/2016 Paul.  Add TAG_SETS
-- 06/23/2016 Paul.  Business Process tables (WF4) are not audited. 
-- 09/22/2016 Paul.  Manually specify default collation to ease migration to Azure
-- 05/18/2017 Paul.  DASHBOARDS is not audited. 
-- 06/07/2017 Paul.  NAICS_CODES is not audited. 
-- 09/25/2017 Paul.  Archive tables are not audited. 
-- 10/22/2017 Paul.  MODULES_ARCHIVE_LOG is not audited. 
-- 12/02/2017 Paul.  We want to start audting TEAMS. 
-- 11/30/2017 Paul.  ASSIGNED_SETS_USERS and ASSIGNED_SETS will not be audit. 
-- 01/22/2020 Paul.  A customer is using custom tables that start with "USR_". 
-- 09/08/2020 Paul.  USERS_CSTM should be audited. 
-- 08/08/2021 Paul.  Machine Learning tables/ prection tables are not audited. 
Create View dbo.vwSqlTablesAudited
as
select TABLE_NAME  collate database_default  as TABLE_NAME
  from vwSqlTables
 where TABLE_NAME not like N'%[_]AUDIT'
   and TABLE_NAME not like N'%[_]ARCHIVE'
   and TABLE_NAME not like N'%[_]STREAM'
   and TABLE_NAME not like N'%[_]PREDICTIONS'
   and TABLE_NAME not like N'%[_]AUDIT[_]SUGARCRM'
   and TABLE_NAME not like N'%[_]REMOTE'
   and TABLE_NAME not like N'%[_]CSTM[_]REMOTE'
   and TABLE_NAME not like N'%[_]SYNC'
   and TABLE_NAME not like N'SYSTEM[_]%'
   and TABLE_NAME not like N'%[_]SYSTEM[_]LOG'
   and TABLE_NAME not like N'SEMANTIC[_]MODEL[_]%'
   and TABLE_NAME not like N'WWF[_]%'
   and TABLE_NAME not like N'WF4[_]%'
   and TABLE_NAME not like N'TEMP[_]%'
   and TABLE_NAME not like N'WORKFLOW%'
   and TABLE_NAME not like N'BUSINESS_PROCESS%'
   and TABLE_NAME not like N'PROCESS%'
   and TABLE_NAME not like N'QUICKBOOKS[_]%'
   and TABLE_NAME not like N'QBSYNC[_]%'
   and TABLE_NAME not like N'USR[_]%'
   and TABLE_NAME not in (select TABLE_NAME from vwSqlTablesCachedSystem)
   and TABLE_NAME not in (select TABLE_NAME from vwSqlTablesCachedData where TABLE_NAME not in (N'TEAMS', N'USERS'))
   and TABLE_NAME in     (select TABLE_NAME from vwSqlTablesBase)
   and TABLE_NAME not in
( N'ACL_ROLES_CSTM'
, N'ASSIGNED_SETS'
, N'ASSIGNED_SETS_USERS'
, N'AUDIT_EVENTS'
, N'CAMPAIGN_TRKRS'
, N'CAMPAIGN_TRKRS_CSTM'
, N'CURRENCIES_CSTM'
, N'DASHBOARDS'
, N'DASHBOARD_APPS'
, N'DOCUMENT_REVISIONS'
, N'DOCUMENT_REVISIONS_CSTM'
, N'CALL_MARKETING'
, N'CALL_MARKETING_CSTM'
, N'CALL_MARKETING_PROSPECT_LISTS'
, N'EMAIL_MARKETING'
, N'EMAIL_MARKETING_CSTM'
, N'EMAIL_MARKETING_PROSPECT_LISTS'
, N'EMAILMAN'
, N'EMAILMAN_CSTM'
, N'EMAILMAN_SENT'
, N'EXCHANGE_USERS'
, N'FEEDS'
, N'FEEDS_CSTM'
, N'FIELD_VALIDATORS'
, N'FILES'
, N'FORECASTS'
, N'FORECASTS_OPPORTUNITIES'
, N'IFRAMES'
, N'IMAGES'
, N'IMPORT_MAPS'
, N'INBOUND_EMAIL_AUTOREPLY'
, N'INBOUND_EMAILS_CSTM'
, N'INETLOG'
, N'LAST_ACTIVITY'
, N'LINKED_DOCUMENTS'
, N'MACHINE_LEARNING_MODELS'
, N'MODULES_ARCHIVE_LOG'
, N'MODULES_GROUPS'
, N'NAICS_CODE_SETS'
, N'NAICS_CODES_RELATED'
, N'NAICS_CODES'
, N'NUMBER_SEQUENCES'
, N'OAUTHKEYS'
, N'OAUTH_TOKENS'
, N'OAUTH_SYNC_TOKENS'
, N'OUTBOUND_EMAILS'
, N'PAYMENTS_TRANSACTIONS'
, N'PHONE_NUMBERS'
, N'PRODUCT_BUNDLE_NOTES'
, N'PRODUCT_BUNDLE_QUOTE'
, N'PRODUCT_BUNDLES'
, N'PRODUCT_CATEGORIES_CSTM'
, N'PRODUCT_PRODUCT'
, N'PRODUCT_TYPES_CSTM'
, N'PRODUCTS'
, N'PRODUCTS_CSTM'
, N'REGIONS'
, N'REGIONS_COUNTRIES'
, N'REGIONS_CSTM'
, N'RELEASES_CSTM'
, N'ROLES'
, N'ROLES_CSTM'
, N'ROLES_MODULES'
, N'ROLES_USERS'
, N'SAVED_SEARCH'
, N'SCHEDULERS'
, N'SCHEDULERS_TIMES'
, N'SUGARFAVORITES'
, N'SUBSCRIPTIONS'
, N'SUGARFEED'
, N'TAB_GROUPS'
, N'TAG_SETS'
, N'TEAM_MEMBERSHIPS'
, N'TEAM_NOTICES'
, N'TEAM_SETS'
, N'TEAM_SETS_TEAMS'
, N'TERMINOLOGY_HELP'
, N'TIME_PERIODS'
, N'TRACKER'
, N'UPGRADE_HISTORY'
, N'USER_PREFERENCES'
, N'USERS_FEEDS'
, N'USERS_LAST_IMPORT'
, N'USERS_LOGINS'
, N'USERS_PASSWORD_LINK'
, N'VALIDATION_EXPRESSIONS'
, N'VCALS'
, N'VERSIONS'
, N'WORKFLOW_EVENTS'
, N'ZIPCODES'
)
GO


-- select ', N''' + TABLE_NAME + '''' from vwSqlTables
-- select * from vwSqlTablesAudited

Grant Select on dbo.vwSqlTablesAudited to public;
GO

