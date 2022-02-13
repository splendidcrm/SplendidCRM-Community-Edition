if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTEAMS')
	Drop View dbo.vwTEAMS;
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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 04/12/2016 Paul.  Add parent team and custom fields. 
Create View dbo.vwTEAMS
as
select TEAMS.ID
     , TEAMS.NAME
     , TEAMS.DESCRIPTION
     , TEAMS.PRIVATE
     , TEAMS.DATE_ENTERED
     , TEAMS.DATE_MODIFIED
     , TEAMS.DATE_MODIFIED_UTC
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , TEAMS.PARENT_ID
     , PARENT_TEAMS.NAME           as PARENT_NAME
     , TEAMS_CSTM.*
  from            TEAMS
  left outer join TEAMS                  PARENT_TEAMS
               on PARENT_TEAMS.ID      = TEAMS.PARENT_ID
              and PARENT_TEAMS.DELETED = 0
  left outer join TEAMS_CSTM
               on TEAMS_CSTM.ID_C      = TEAMS.ID
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = TEAMS.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = TEAMS.MODIFIED_USER_ID
 where TEAMS.DELETED = 0

GO

Grant Select on dbo.vwTEAMS to public;
GO

 
