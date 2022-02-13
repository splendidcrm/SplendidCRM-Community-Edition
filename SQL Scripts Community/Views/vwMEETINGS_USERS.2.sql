if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_USERS')
	Drop View dbo.vwMEETINGS_USERS;
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
-- 09/08/2015 Paul.  The primary ID is needed to enable Preview in the Seven theme. 
-- 06/14/2017 Paul.  DATE_MODIFIED_UTC is needed by HTML5 Client. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 05/05/2018 Paul.  ASSIGNED_SET_LIST can be used. 
Create View dbo.vwMEETINGS_USERS
as
select MEETINGS.ID               as MEETING_ID
     , MEETINGS.NAME             as MEETING_NAME
     , MEETINGS.ASSIGNED_USER_ID as MEETING_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID  as MEETING_ASSIGNED_SET_ID
     , USERS.ID                  as ID
     , USERS.ID                  as USER_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.EMAIL1
     , USERS.PHONE_WORK
     , MEETINGS_USERS.DATE_ENTERED
     , MEETINGS_USERS.DATE_MODIFIED_UTC
     , MEETINGS.ASSIGNED_USER_ID
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from           MEETINGS
      inner join MEETINGS_USERS
              on MEETINGS_USERS.MEETING_ID = MEETINGS.ID
             and MEETINGS_USERS.DELETED    = 0
      inner join USERS
              on USERS.ID                  = MEETINGS_USERS.USER_ID
             and USERS.DELETED             = 0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = MEETINGS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
 where MEETINGS.DELETED = 0

GO

Grant Select on dbo.vwMEETINGS_USERS to public;
GO

