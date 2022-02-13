if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCHAT_CHANNELS_ATTACHMENTS')
	Drop View dbo.vwCHAT_CHANNELS_ATTACHMENTS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCHAT_CHANNELS_ATTACHMENTS
as
select CHAT_CHANNELS.ID               as CHAT_CHANNEL_ID
     , CHAT_CHANNELS.NAME             as CHAT_CHANNEL_NAME
     , CHAT_CHANNELS.ASSIGNED_USER_ID
     , TEAMS.ID                       as TEAM_ID
     , TEAMS.NAME                     as TEAM_NAME
     , TEAM_SETS.ID                   as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME        as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST        as TEAM_SET_LIST
     , NOTE_ATTACHMENTS.FILENAME      as NAME
     , NOTE_ATTACHMENTS.ID
     , NOTE_ATTACHMENTS.DESCRIPTION
     , NOTE_ATTACHMENTS.NOTE_ID
     , NOTE_ATTACHMENTS.FILENAME
     , NOTE_ATTACHMENTS.FILE_MIME_TYPE
     , NOTE_ATTACHMENTS.DATE_ENTERED 
     , NOTE_ATTACHMENTS.CREATED_BY    as CREATED_USER_ID
     , USERS_CREATED_BY.USER_NAME     as CREATED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            CHAT_CHANNELS
       inner join CHAT_MESSAGES
               on CHAT_MESSAGES.CHAT_CHANNEL_ID = CHAT_CHANNELS.ID
              and CHAT_MESSAGES.DELETED         = 0
       inner join NOTE_ATTACHMENTS
               on NOTE_ATTACHMENTS.ID           = CHAT_MESSAGES.NOTE_ATTACHMENT_ID
              and NOTE_ATTACHMENTS.DELETED      = 0
  left outer join TEAMS
               on TEAMS.ID                      = CHAT_CHANNELS.TEAM_ID
              and TEAMS.DELETED                 = 0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID              = CHAT_CHANNELS.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED         = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID                  = CHAT_CHANNELS.TEAM_SET_ID
              and TEAM_SETS.DELETED             = 0
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID           = NOTE_ATTACHMENTS.CREATED_BY
 where NOTE_ATTACHMENTS.DELETED = 0

GO

Grant Select on dbo.vwCHAT_CHANNELS_ATTACHMENTS to public;
GO

