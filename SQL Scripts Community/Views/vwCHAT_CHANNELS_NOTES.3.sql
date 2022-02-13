if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCHAT_CHANNELS_NOTES')
	Drop View dbo.vwCHAT_CHANNELS_NOTES;
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
Create View dbo.vwCHAT_CHANNELS_NOTES
as
select CHAT_CHANNELS.NAME             as CHAT_CHANNEL_NAME
     , vwCHAT_MESSAGES_NOTES.*
  from           CHAT_CHANNELS
      inner join vwCHAT_MESSAGES_NOTES
              on vwCHAT_MESSAGES_NOTES.CHAT_CHANNEL_ID = CHAT_CHANNELS.ID
 where CHAT_CHANNELS.DELETED = 0

GO

Grant Select on dbo.vwCHAT_CHANNELS_NOTES to public;
GO


