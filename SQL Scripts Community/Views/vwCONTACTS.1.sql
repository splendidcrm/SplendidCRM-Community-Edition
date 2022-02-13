if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS')
	Drop View dbo.vwCONTACTS;
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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 04/03/2013 Paul.  Convert EMAIL_OPT_OUT is null to 0 to simplify Campaign Dynamic Lists. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
-- 05/24/2015 Paul.  Add picture. 
-- 09/11/2015 Paul.  Join to LEADS now that we have the relationship. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_DP_CONSENT_LAST_UPDATED for data privacy. 
Create View dbo.vwCONTACTS
as
select CONTACTS.ID
     , CONTACTS.CONTACT_NUMBER
     , CONTACTS.SALUTATION
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as NAME
     , CONTACTS.FIRST_NAME
     , CONTACTS.LAST_NAME
     , CONTACTS.LEAD_SOURCE
     , CONTACTS.TITLE
     , CONTACTS.DEPARTMENT
     , CONTACTS.REPORTS_TO_ID
     , dbo.fnFullName(REPORTS_TO_CONTACTS.FIRST_NAME, REPORTS_TO_CONTACTS.LAST_NAME) as REPORTS_TO_NAME
     , CONTACTS.BIRTHDATE
     , CONTACTS.DO_NOT_CALL
     , CONTACTS.PHONE_HOME
     , CONTACTS.PHONE_MOBILE
     , CONTACTS.PHONE_WORK
     , CONTACTS.PHONE_OTHER
     , CONTACTS.PHONE_FAX
     , CONTACTS.EMAIL1
     , CONTACTS.EMAIL2
     , CONTACTS.ASSISTANT
     , CONTACTS.ASSISTANT_PHONE
     , isnull(CONTACTS.EMAIL_OPT_OUT, 0) as EMAIL_OPT_OUT
     , CONTACTS.INVALID_EMAIL
     , CONTACTS.SMS_OPT_IN
     , CONTACTS.TWITTER_SCREEN_NAME
     , CONTACTS.PRIMARY_ADDRESS_STREET
     , CONTACTS.PRIMARY_ADDRESS_CITY
     , CONTACTS.PRIMARY_ADDRESS_STATE
     , CONTACTS.PRIMARY_ADDRESS_POSTALCODE
     , CONTACTS.PRIMARY_ADDRESS_COUNTRY
     , CONTACTS.ALT_ADDRESS_STREET
     , CONTACTS.ALT_ADDRESS_CITY
     , CONTACTS.ALT_ADDRESS_STATE
     , CONTACTS.ALT_ADDRESS_POSTALCODE
     , CONTACTS.ALT_ADDRESS_COUNTRY
     , CONTACTS.PORTAL_NAME
     , CONTACTS.PORTAL_ACTIVE
     , CONTACTS.PORTAL_APP
     , CONTACTS.ASSIGNED_USER_ID
     , CONTACTS.DATE_ENTERED
     , CONTACTS.DATE_MODIFIED
     , CONTACTS.DATE_MODIFIED_UTC
     , CONTACTS.DESCRIPTION
     , CONTACTS.PICTURE
     , CONTACTS.DP_BUSINESS_PURPOSE
     , CONTACTS.DP_CONSENT_LAST_UPDATED
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , CONTACTS.CREATED_BY         as CREATED_BY_ID
     , CONTACTS.MODIFIED_USER_ID
     , ACCOUNTS.ID                 as ACCOUNT_ID
     , ACCOUNTS.NAME               as ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID    as ACCOUNT_ASSIGNED_SET_ID
     , LEADS.ID                                          as LEAD_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , LEADS.ASSIGNED_USER_ID                            as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID                             as LEAD_ASSIGNED_SET_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , LAST_ACTIVITY.LAST_ACTIVITY_DATE
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , CONTACTS_CSTM.*
  from            CONTACTS
  left outer join CONTACTS                       REPORTS_TO_CONTACTS
               on REPORTS_TO_CONTACTS.ID       = CONTACTS.REPORTS_TO_ID
              and REPORTS_TO_CONTACTS.DELETED  = 0
  left outer join ACCOUNTS_CONTACTS
               on ACCOUNTS_CONTACTS.CONTACT_ID = CONTACTS.ID
              and ACCOUNTS_CONTACTS.DELETED    = 0
  left outer join ACCOUNTS
               on ACCOUNTS.ID                  = ACCOUNTS_CONTACTS.ACCOUNT_ID
  left outer join LEADS_CONTACTS
               on LEADS_CONTACTS.CONTACT_ID    = CONTACTS.ID
              and LEADS_CONTACTS.DELETED       = 0
  left outer join LEADS
               on LEADS.ID                     = LEADS_CONTACTS.LEAD_ID
  left outer join TEAMS
               on TEAMS.ID                     = CONTACTS.TEAM_ID
              and TEAMS.DELETED                = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                 = CONTACTS.TEAM_SET_ID
              and TEAM_SETS.DELETED            = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID    = CONTACTS.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID             = CONTACTS.ID
              and TAG_SETS.DELETED             = 0
  left outer join USERS                          USERS_ASSIGNED
               on USERS_ASSIGNED.ID            = CONTACTS.ASSIGNED_USER_ID
  left outer join USERS                          USERS_CREATED_BY
               on USERS_CREATED_BY.ID          = CONTACTS.CREATED_BY
  left outer join USERS                          USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID         = CONTACTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID             = CONTACTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED        = 0
  left outer join CONTACTS_CSTM
               on CONTACTS_CSTM.ID_C           = CONTACTS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = CONTACTS.ID
 where CONTACTS.DELETED = 0

GO

Grant Select on dbo.vwCONTACTS to public;
GO

 
