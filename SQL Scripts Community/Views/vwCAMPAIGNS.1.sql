if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS')
	Drop View dbo.vwCAMPAIGNS;
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
-- 04/21/2006 Paul.  CURRENCY_ID was added in SugarCRM 4.2.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 05/17/2017 Paul.  Add Tags module. 
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCAMPAIGNS
as
select CAMPAIGNS.ID
     , CAMPAIGNS.CAMPAIGN_NUMBER
     , CAMPAIGNS.NAME
     , CAMPAIGNS.TRACKER_KEY
     , CAMPAIGNS.TRACKER_COUNT
     , CAMPAIGNS.IMPRESSIONS
     , CAMPAIGNS.REFER_URL
     , CAMPAIGNS.TRACKER_TEXT
     , CAMPAIGNS.START_DATE
     , CAMPAIGNS.END_DATE
     , CAMPAIGNS.STATUS
     , CAMPAIGNS.BUDGET
     , CAMPAIGNS.BUDGET_USDOLLAR
     , CAMPAIGNS.EXPECTED_COST
     , CAMPAIGNS.EXPECTED_COST_USDOLLAR
     , CAMPAIGNS.ACTUAL_COST
     , CAMPAIGNS.ACTUAL_COST_USDOLLAR
     , CAMPAIGNS.EXPECTED_REVENUE
     , CAMPAIGNS.EXPECTED_REVENUE_USDOLLAR
     , CAMPAIGNS.CAMPAIGN_TYPE
     , CAMPAIGNS.CURRENCY_ID
     , CURRENCIES.NAME             as CURRENCY_NAME
     , CURRENCIES.SYMBOL           as CURRENCY_SYMBOL
     , CURRENCIES.CONVERSION_RATE  as CURRENCY_CONVERSION_RATE
     , CAMPAIGNS.ASSIGNED_USER_ID
     , CAMPAIGNS.DATE_ENTERED
     , CAMPAIGNS.DATE_MODIFIED
     , CAMPAIGNS.DATE_MODIFIED_UTC
     , CAMPAIGNS.OBJECTIVE
     , CAMPAIGNS.CONTENT
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , CAMPAIGNS.CREATED_BY        as CREATED_BY_ID
     , CAMPAIGNS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , CAMPAIGNS_CSTM.*
  from            CAMPAIGNS
  left outer join TEAMS
               on TEAMS.ID             = CAMPAIGNS.TEAM_ID
              and TEAMS.DELETED        = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID         = CAMPAIGNS.TEAM_SET_ID
              and TEAM_SETS.DELETED    = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID     = CAMPAIGNS.ID
              and TAG_SETS.DELETED     = 0
  left outer join USERS                  USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = CAMPAIGNS.ASSIGNED_USER_ID
  left outer join USERS                  USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = CAMPAIGNS.CREATED_BY
  left outer join USERS                  USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = CAMPAIGNS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID     = CAMPAIGNS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED= 0
  left outer join CURRENCIES
               on CURRENCIES.ID        = CAMPAIGNS.CURRENCY_ID
              and CURRENCIES.DELETED   = 0
  left outer join CAMPAIGNS_CSTM
               on CAMPAIGNS_CSTM.ID_C  = CAMPAIGNS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = CAMPAIGNS.ID
 where CAMPAIGNS.DELETED = 0

GO

Grant Select on dbo.vwCAMPAIGNS to public;
GO

