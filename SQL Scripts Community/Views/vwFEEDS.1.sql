if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFEEDS')
	Drop View dbo.vwFEEDS;
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
-- 12/29/2006 Paul.  Add TEAM_ID for team management. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwFEEDS
as
select FEEDS.ID
     , FEEDS.TITLE
     , FEEDS.URL
     , FEEDS.ASSIGNED_USER_ID
     , FEEDS.DATE_ENTERED
     , FEEDS.DATE_MODIFIED
     , FEEDS.DATE_MODIFIED_UTC
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
     , FEEDS_CSTM.*
  from            FEEDS
  left outer join TEAMS
               on TEAMS.ID             = FEEDS.TEAM_ID
              and TEAMS.DELETED        = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID         = FEEDS.TEAM_SET_ID
              and TEAM_SETS.DELETED    = 0
  left outer join USERS                  USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = FEEDS.ASSIGNED_USER_ID
  left outer join USERS                  USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = FEEDS.CREATED_BY
  left outer join USERS                  USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = FEEDS.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID     = FEEDS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED= 0
  left outer join FEEDS_CSTM
               on FEEDS_CSTM.ID_C      = FEEDS.ID
 where FEEDS.DELETED = 0

GO

Grant Select on dbo.vwFEEDS to public;
GO

 
