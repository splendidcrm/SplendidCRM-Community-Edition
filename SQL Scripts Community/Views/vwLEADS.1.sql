if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS')
	Drop View dbo.vwLEADS;
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
-- 04/21/2006 Paul.  CAMPAIGN_ID was added in SugarCRM 4.0.
-- 04/24/2006 Paul.  Bug fix, change CAMPAIGNS_NAME to CAMPAIGN_NAME. 
-- 07/27/2006 Paul.  LEAD_SOURCE_DESCRIPTION was moved to the base view because it is used in several SubPanels. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 07/21/2010 Paul.  Include ASSISTANT and ASSISTANT_PHONE so that vCard export will not complain. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 04/03/2013 Paul.  Convert EMAIL_OPT_OUT is null to 0 to simplify Campaign Dynamic Lists. 
-- 09/27/2013 Paul.  SMS messages need to be opt-in. 
-- 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
-- 05/24/2015 Paul.  Add picture. 
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
Create View dbo.vwLEADS
as
select LEADS.ID
     , LEADS.LEAD_NUMBER
     , LEADS.SALUTATION
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as NAME
     , LEADS.FIRST_NAME
     , LEADS.LAST_NAME
     , LEADS.TITLE
     , LEADS.REFERED_BY
     , LEADS.LEAD_SOURCE
     , LEADS.STATUS
     , LEADS.DEPARTMENT
     , LEADS.REPORTS_TO_ID
     , LEADS.DO_NOT_CALL
     , LEADS.PHONE_HOME
     , LEADS.PHONE_MOBILE
     , LEADS.PHONE_WORK
     , LEADS.PHONE_OTHER
     , LEADS.PHONE_FAX
     , LEADS.EMAIL1
     , LEADS.EMAIL2
     , LEADS.ASSISTANT
     , LEADS.ASSISTANT_PHONE
     , isnull(LEADS.EMAIL_OPT_OUT, 0) as EMAIL_OPT_OUT
     , LEADS.INVALID_EMAIL
     , LEADS.SMS_OPT_IN
     , LEADS.TWITTER_SCREEN_NAME
     , LEADS.PRIMARY_ADDRESS_STREET
     , LEADS.PRIMARY_ADDRESS_CITY
     , LEADS.PRIMARY_ADDRESS_STATE
     , LEADS.PRIMARY_ADDRESS_POSTALCODE
     , LEADS.PRIMARY_ADDRESS_COUNTRY
     , LEADS.ALT_ADDRESS_STREET
     , LEADS.ALT_ADDRESS_CITY
     , LEADS.ALT_ADDRESS_STATE
     , LEADS.ALT_ADDRESS_POSTALCODE
     , LEADS.ALT_ADDRESS_COUNTRY
     , LEADS.ACCOUNT_NAME
     , LEADS.CONTACT_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONVERTED_CONTACT_NAME
     , CONTACTS.ASSIGNED_USER_ID      as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID       as CONTACT_ASSIGNED_SET_ID
     , LEADS.ACCOUNT_ID
     , ACCOUNTS.NAME                  as CONVERTED_ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID      as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID       as ACCOUNT_ASSIGNED_SET_ID
     , LEADS.OPPORTUNITY_ID           as CONVERTED_OPPORTUNITY_ID
     , LEADS.OPPORTUNITY_NAME         as CONVERTED_OPPORTUNITY_NAME
     , LEADS.OPPORTUNITY_AMOUNT       as CONVERTED_OPPORTUNITY_AMOUNT
     , OPPORTUNITIES.ASSIGNED_USER_ID as CONVERTED_OPPORTUNITY_ASSIGNED_USER_ID
     , OPPORTUNITIES.ASSIGNED_SET_ID  as CONVERTED_OPPORTUNITY_ASSIGNED_SET_ID
     , LEADS.CAMPAIGN_ID
     , CAMPAIGNS.NAME                 as CAMPAIGN_NAME
     , CAMPAIGNS.ASSIGNED_USER_ID     as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID      as CAMPAIGN_ASSIGNED_SET_ID
     , LEADS.ASSIGNED_USER_ID
     , LEADS.DATE_ENTERED
     , LEADS.DATE_MODIFIED
     , LEADS.DATE_MODIFIED_UTC
     , LEADS.STATUS_DESCRIPTION
     , LEADS.DESCRIPTION
     , LEADS.PICTURE
     , LEADS.ACCOUNT_DESCRIPTION
     , LEADS.DP_BUSINESS_PURPOSE
     , LEADS.DP_CONSENT_LAST_UPDATED
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME       as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME     as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME    as MODIFIED_BY
     , LEADS.CREATED_BY               as CREATED_BY_ID
     , LEADS.MODIFIED_USER_ID
     , LEADS.LEAD_SOURCE_DESCRIPTION
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , LEADS.BIRTHDATE
     , LEADS.WEBSITE
     , LAST_ACTIVITY.LAST_ACTIVITY_DATE
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , LEADS_CSTM.*
  from            LEADS
  left outer join CONTACTS
               on CONTACTS.ID           = LEADS.CONTACT_ID
              and CONTACTS.DELETED      = 0
  left outer join ACCOUNTS
               on ACCOUNTS.ID           = LEADS.ACCOUNT_ID
              and ACCOUNTS.DELETED      = 0
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID          = LEADS.CAMPAIGN_ID
              and CAMPAIGNS.DELETED     = 0
  left outer join OPPORTUNITIES
               on OPPORTUNITIES.ID      = LEADS.OPPORTUNITY_ID
              and OPPORTUNITIES.DELETED = 0
  left outer join TEAMS
               on TEAMS.ID              = LEADS.TEAM_ID
              and TEAMS.DELETED         = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID          = LEADS.TEAM_SET_ID
              and TEAM_SETS.DELETED     = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID = LEADS.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID      = LEADS.ID
              and TAG_SETS.DELETED      = 0
  left outer join USERS                   USERS_ASSIGNED
               on USERS_ASSIGNED.ID     = LEADS.ASSIGNED_USER_ID
  left outer join USERS                   USERS_CREATED_BY
               on USERS_CREATED_BY.ID   = LEADS.CREATED_BY
  left outer join USERS                   USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID  = LEADS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID      = LEADS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED = 0
  left outer join LEADS_CSTM
               on LEADS_CSTM.ID_C       = LEADS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = LEADS.ID
 where LEADS.DELETED = 0

GO

Grant Select on dbo.vwLEADS to public;
GO


