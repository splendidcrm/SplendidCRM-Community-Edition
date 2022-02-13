if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTWITTER_MESSAGES')
	Drop View dbo.vwTWITTER_MESSAGES;
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
-- 05/17/2017 Paul.  Add Tags module. 
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwTWITTER_MESSAGES
as
select TWITTER_MESSAGES.ID
     , TWITTER_MESSAGES.NAME
     , TWITTER_MESSAGES.DATE_START
     , TWITTER_MESSAGES.TIME_START
     , dbo.fnViewDateTime(TWITTER_MESSAGES.DATE_START, TWITTER_MESSAGES.TIME_START) as DATE_TIME
     , TWITTER_MESSAGES.PARENT_TYPE
     , TWITTER_MESSAGES.PARENT_ID
     , TWITTER_MESSAGES.TYPE
     , TWITTER_MESSAGES.STATUS
     , TWITTER_MESSAGES.TWITTER_ID
     , TWITTER_MESSAGES.TWITTER_USER_ID
     , TWITTER_MESSAGES.TWITTER_FULL_NAME
     , TWITTER_MESSAGES.TWITTER_SCREEN_NAME
     , TWITTER_MESSAGES.ORIGINAL_ID
     , TWITTER_MESSAGES.ORIGINAL_USER_ID
     , TWITTER_MESSAGES.ORIGINAL_FULL_NAME
     , TWITTER_MESSAGES.ORIGINAL_SCREEN_NAME
     , TWITTER_MESSAGES.DESCRIPTION
     , TWITTER_MESSAGES.ASSIGNED_USER_ID
     , TWITTER_MESSAGES.IS_PRIVATE
     , (case when TWITTER_MESSAGES.ORIGINAL_ID > 0 then 1 else 0 end) as IS_RETWEET
     , vwPARENTS.PARENT_NAME
     , vwPARENTS.PARENT_ASSIGNED_USER_ID
     , vwPARENTS.PARENT_ASSIGNED_SET_ID
     , TWITTER_MESSAGES.DATE_ENTERED
     , TWITTER_MESSAGES.DATE_MODIFIED
     , TWITTER_MESSAGES.DATE_MODIFIED_UTC
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , TWITTER_MESSAGES.CREATED_BY as CREATED_BY_ID
     , TWITTER_MESSAGES.MODIFIED_USER_ID
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
     , TWITTER_MESSAGES_CSTM.*
  from            TWITTER_MESSAGES
  left outer join vwPARENTS
               on vwPARENTS.PARENT_ID      = TWITTER_MESSAGES.PARENT_ID
  left outer join TEAMS
               on TEAMS.ID                 = TWITTER_MESSAGES.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = TWITTER_MESSAGES.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
  left outer join TAG_SETS
               on TAG_SETS.BEAN_ID         = TWITTER_MESSAGES.ID
              and TAG_SETS.DELETED         = 0
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = TWITTER_MESSAGES.ASSIGNED_USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = TWITTER_MESSAGES.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = TWITTER_MESSAGES.MODIFIED_USER_ID
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID         = TWITTER_MESSAGES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED    = 0
  left outer join TWITTER_MESSAGES_CSTM
               on TWITTER_MESSAGES_CSTM.ID_C = TWITTER_MESSAGES.ID
 where TWITTER_MESSAGES.DELETED = 0

GO

Grant Select on dbo.vwTWITTER_MESSAGES to public;
GO

 
