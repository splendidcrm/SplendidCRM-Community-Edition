if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwNOTE_ATTACHMENTS')
	Drop View dbo.vwNOTE_ATTACHMENTS;
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
Create View dbo.vwNOTE_ATTACHMENTS
as
select NOTE_ATTACHMENTS.ID
     , NOTE_ATTACHMENTS.DESCRIPTION
     , NOTE_ATTACHMENTS.NOTE_ID
     , NOTE_ATTACHMENTS.FILENAME
     , NOTE_ATTACHMENTS.FILE_MIME_TYPE
     , NOTE_ATTACHMENTS.DATE_ENTERED 
     , USERS_CREATED_BY.USER_NAME       as CREATED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
  from            NOTE_ATTACHMENTS
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID = NOTE_ATTACHMENTS.CREATED_BY
 where NOTE_ATTACHMENTS.DELETED = 0

GO

Grant Select on dbo.vwNOTE_ATTACHMENTS to public;
GO

