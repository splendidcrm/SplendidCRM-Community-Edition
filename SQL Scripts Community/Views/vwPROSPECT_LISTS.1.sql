if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS')
	Drop View dbo.vwPROSPECT_LISTS;
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
-- 04/21/2006 Paul.  LIST_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  DOMAIN_NAME was added in SugarCRM 4.0.1.
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/09/2010 Paul.  A Dynamic List is one that uses SQL to build the prospect list. 
-- 01/14/2010 Paul.  Move DYNAMIC_SQL to a separate table so that it cannot be imported or exported. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 08/19/2016 Paul.  Add support for Business Processes. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPROSPECT_LISTS
as
select PROSPECT_LISTS.ID
     , PROSPECT_LISTS.NAME
     , PROSPECT_LISTS.DESCRIPTION
     , PROSPECT_LISTS.ASSIGNED_USER_ID
     , PROSPECT_LISTS.DATE_ENTERED
     , PROSPECT_LISTS.DATE_MODIFIED
     , PROSPECT_LISTS.DATE_MODIFIED_UTC
     , PROSPECT_LISTS.LIST_TYPE
     , PROSPECT_LISTS.DOMAIN_NAME
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , PROSPECT_LISTS.CREATED_BY   as CREATED_BY_ID
     , PROSPECT_LISTS.MODIFIED_USER_ID
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , PROSPECT_LISTS.DYNAMIC_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , TAG_SETS.TAG_SET_NAME
     , vwPROCESSES_Pending.ID      as PENDING_PROCESS_ID
     , PROSPECT_LISTS_CSTM.*
  from            PROSPECT_LISTS
  left outer join TEAMS
               on TEAMS.ID                 = PROSPECT_LISTS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = PROSPECT_LISTS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = PROSPECT_LISTS.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = PROSPECT_LISTS.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = PROSPECT_LISTS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = PROSPECT_LISTS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = PROSPECT_LISTS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join PROSPECT_LISTS_CSTM
               on PROSPECT_LISTS_CSTM.ID_C = PROSPECT_LISTS.ID
  left outer join vwPROCESSES_Pending
               on vwPROCESSES_Pending.PARENT_ID = PROSPECT_LISTS.ID
 where PROSPECT_LISTS.DELETED = 0

GO

Grant Select on dbo.vwPROSPECT_LISTS to public;
GO

 
