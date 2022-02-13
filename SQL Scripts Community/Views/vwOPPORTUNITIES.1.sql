if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOPPORTUNITIES')
	Drop View dbo.vwOPPORTUNITIES;
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
-- 12/25/2007 Paul.  CAMPAIGN_ID was added in SugarCRM 4.5.1
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 12/16/2009 Paul.  We should allow the display of the CAMPAIGN_NAME. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 11/22/2012 Paul.  Join to LAST_ACTIVITY table. 
-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
-- 02/24/2016 Paul.  Add EMAIL1 to make it easy for the Office Addin to search. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwOPPORTUNITIES
as
select OPPORTUNITIES.ID
     , OPPORTUNITIES.OPPORTUNITY_NUMBER
     , OPPORTUNITIES.NAME
     , OPPORTUNITIES.OPPORTUNITY_TYPE
     , OPPORTUNITIES.LEAD_SOURCE
     , OPPORTUNITIES.AMOUNT
     , OPPORTUNITIES.AMOUNT_BACKUP
     , OPPORTUNITIES.AMOUNT_USDOLLAR
     , OPPORTUNITIES.CURRENCY_ID
     , OPPORTUNITIES.DATE_CLOSED
     , OPPORTUNITIES.NEXT_STEP
     , OPPORTUNITIES.SALES_STAGE
     , OPPORTUNITIES.PROBABILITY
     , OPPORTUNITIES.ASSIGNED_USER_ID
     , OPPORTUNITIES.DATE_ENTERED
     , OPPORTUNITIES.DATE_MODIFIED
     , OPPORTUNITIES.DATE_MODIFIED_UTC
     , OPPORTUNITIES.CAMPAIGN_ID
     , CAMPAIGNS.NAME              as CAMPAIGN_NAME
     , CAMPAIGNS.ASSIGNED_USER_ID  as CAMPAIGN_ASSIGNED_USER_ID
     , CAMPAIGNS.ASSIGNED_SET_ID   as CAMPAIGN_ASSIGNED_SET_ID
     , OPPORTUNITIES.DESCRIPTION
     , ACCOUNTS.ID                 as ACCOUNT_ID
     , ACCOUNTS.NAME               as ACCOUNT_NAME
     , ACCOUNTS.ASSIGNED_USER_ID   as ACCOUNT_ASSIGNED_USER_ID
     , ACCOUNTS.ASSIGNED_SET_ID    as ACCOUNT_ASSIGNED_SET_ID
     , ACCOUNTS.EMAIL1             as ACCOUNT_EMAIL1
     , LEADS.ID                    as LEAD_ID
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as LEAD_NAME
     , LEADS.ASSIGNED_USER_ID      as LEAD_ASSIGNED_USER_ID
     , LEADS.ASSIGNED_SET_ID       as LEAD_ASSIGNED_SET_ID
     , LEADS.EMAIL1                as LEAD_EMAIL1
     , CONTACTS.ID                 as B2C_CONTACT_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as B2C_CONTACT_NAME
     , CONTACTS.ASSIGNED_USER_ID   as B2C_CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID    as B2C_CONTACT_ASSIGNED_SET_ID
     , CONTACTS.EMAIL1             as B2C_CONTACT_EMAIL1
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , OPPORTUNITIES.CREATED_BY    as CREATED_BY_ID
     , OPPORTUNITIES.MODIFIED_USER_ID
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
     , OPPORTUNITIES_CSTM.*
  from            OPPORTUNITIES
  left outer join ACCOUNTS_OPPORTUNITIES
               on ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID = OPPORTUNITIES.ID
              and ACCOUNTS_OPPORTUNITIES.DELETED        = 0
  left outer join ACCOUNTS
               on ACCOUNTS.ID                           = ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID
              and ACCOUNTS.DELETED                      = 0
  left outer join LEADS_OPPORTUNITIES
               on LEADS_OPPORTUNITIES.OPPORTUNITY_ID    = OPPORTUNITIES.ID
              and LEADS_OPPORTUNITIES.DELETED           = 0
  left outer join LEADS
               on LEADS.ID                              = LEADS_OPPORTUNITIES.LEAD_ID
              and LEADS.DELETED                         = 0
  left outer join CONTACTS
               on CONTACTS.ID                           = OPPORTUNITIES.B2C_CONTACT_ID
              and CONTACTS.DELETED                      = 0
  left outer join CAMPAIGNS
               on CAMPAIGNS.ID                          = OPPORTUNITIES.CAMPAIGN_ID
              and CAMPAIGNS.DELETED                     = 0
  left outer join TEAMS
               on TEAMS.ID                              = OPPORTUNITIES.TEAM_ID
              and TEAMS.DELETED                         = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                          = OPPORTUNITIES.TEAM_SET_ID
              and TEAM_SETS.DELETED                     = 0
  left outer join LAST_ACTIVITY
               on LAST_ACTIVITY.ACTIVITY_ID             = OPPORTUNITIES.ID
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID                      = OPPORTUNITIES.ID
              and TAG_SETS.DELETED                      = 0
  left outer join USERS                                   USERS_ASSIGNED
               on USERS_ASSIGNED.ID                     = OPPORTUNITIES.ASSIGNED_USER_ID
  left outer join USERS                                   USERS_CREATED_BY
               on USERS_CREATED_BY.ID                   = OPPORTUNITIES.CREATED_BY
  left outer join USERS                                   USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID                  = OPPORTUNITIES.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID                      = OPPORTUNITIES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED                 = 0
  left outer join OPPORTUNITIES_CSTM
               on OPPORTUNITIES_CSTM.ID_C               = OPPORTUNITIES.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID         = OPPORTUNITIES.ID
 where OPPORTUNITIES.DELETED = 0

GO

Grant Select on dbo.vwOPPORTUNITIES to public;
GO


