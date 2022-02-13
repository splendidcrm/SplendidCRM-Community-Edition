if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECTS')
	Drop View dbo.vwPROSPECTS;
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
-- 04/21/2006 Paul.  LEAD_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ACCOUNT_NAME was added in SugarCRM 4.0.
-- 04/24/2006 Paul.  Change LEAD_NAME to CONVERTED_LEAD_NAME to be consistent with lead conversion to contact. 
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
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 06/23/2018 Paul.  Add LEAD_SOURCE, DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
Create View dbo.vwPROSPECTS
as
select PROSPECTS.ID
     , PROSPECTS.PROSPECT_NUMBER
     , PROSPECTS.SALUTATION
     , dbo.fnFullName(PROSPECTS.FIRST_NAME, PROSPECTS.LAST_NAME) as NAME
     , PROSPECTS.FIRST_NAME
     , PROSPECTS.LAST_NAME
     , PROSPECTS.TITLE
     , PROSPECTS.DEPARTMENT
     , PROSPECTS.BIRTHDATE
     , PROSPECTS.DO_NOT_CALL
     , PROSPECTS.PHONE_HOME
     , PROSPECTS.PHONE_MOBILE
     , PROSPECTS.PHONE_WORK
     , PROSPECTS.PHONE_OTHER
     , PROSPECTS.PHONE_FAX
     , PROSPECTS.EMAIL1
     , PROSPECTS.EMAIL2
     , PROSPECTS.ASSISTANT
     , PROSPECTS.ASSISTANT_PHONE
     , isnull(PROSPECTS.EMAIL_OPT_OUT, 0) as EMAIL_OPT_OUT
     , PROSPECTS.INVALID_EMAIL
     , PROSPECTS.SMS_OPT_IN
     , PROSPECTS.TWITTER_SCREEN_NAME
     , PROSPECTS.PRIMARY_ADDRESS_STREET
     , PROSPECTS.PRIMARY_ADDRESS_CITY
     , PROSPECTS.PRIMARY_ADDRESS_STATE
     , PROSPECTS.PRIMARY_ADDRESS_POSTALCODE
     , PROSPECTS.PRIMARY_ADDRESS_COUNTRY
     , PROSPECTS.ALT_ADDRESS_STREET
     , PROSPECTS.ALT_ADDRESS_CITY
     , PROSPECTS.ALT_ADDRESS_STATE
     , PROSPECTS.ALT_ADDRESS_POSTALCODE
     , PROSPECTS.ALT_ADDRESS_COUNTRY
     , PROSPECTS.LEAD_ID
     , LEADS.ASSIGNED_USER_ID  as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID   as LEAD_ASSIGNED_SET_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as CONVERTED_LEAD_NAME
     , PROSPECTS.ACCOUNT_NAME
     , PROSPECTS.ASSIGNED_USER_ID
     , PROSPECTS.DATE_ENTERED
     , PROSPECTS.DATE_MODIFIED
     , PROSPECTS.DATE_MODIFIED_UTC
     , PROSPECTS.DESCRIPTION
     , PROSPECTS.PICTURE
     , PROSPECTS.LEAD_SOURCE
     , PROSPECTS.DP_BUSINESS_PURPOSE
     , PROSPECTS.DP_CONSENT_LAST_UPDATED
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , PROSPECTS.CREATED_BY        as CREATED_BY_ID
     , PROSPECTS.MODIFIED_USER_ID
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
     , PROSPECTS_CSTM.*
  from            PROSPECTS
  left outer join LEADS
               on LEADS.ID                 = PROSPECTS.LEAD_ID
              and LEADS.DELETED            = 0
  left outer join TEAMS
               on TEAMS.ID                 = PROSPECTS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = PROSPECTS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID= PROSPECTS.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = PROSPECTS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = PROSPECTS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = PROSPECTS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = PROSPECTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = PROSPECTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join PROSPECTS_CSTM
               on PROSPECTS_CSTM.ID_C      = PROSPECTS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = PROSPECTS.ID
 where PROSPECTS.DELETED = 0

GO

Grant Select on dbo.vwPROSPECTS to public;
GO

 
