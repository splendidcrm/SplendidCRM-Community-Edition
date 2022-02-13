if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_TASKS_Soap')
	Drop View dbo.vwUSERS_TASKS_Soap;
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
Create View dbo.vwUSERS_TASKS_Soap
as
select USERS.ID    as PRIMARY_ID
     , TASKS.ID    as RELATED_ID
     , TASKS.DELETED
     , TASKS.DATE_MODIFIED
     , TASKS.DATE_MODIFIED_UTC
  from      TASKS
 inner join USERS
         on USERS.ID         = TASKS.ASSIGNED_USER_ID
        and USERS.DELETED    = 0

GO

Grant Select on dbo.vwUSERS_TASKS_Soap to public;
GO

