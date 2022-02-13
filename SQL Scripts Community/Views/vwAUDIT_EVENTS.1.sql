if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwAUDIT_EVENTS')
	Drop View dbo.vwAUDIT_EVENTS;
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
-- 01/20/2010 Paul.  Correct for the singular module names. 
-- 03/27/2019 Paul.  Every searchable view should have a NAME field. 
-- 11/13/2020 Paul.  Add DATE_ENTERED to support default view of React Client. 
Create View dbo.vwAUDIT_EVENTS
as
select dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.USER_NAME            as NAME
     , USERS.ID                   as USER_ID
     , AUDIT_EVENTS.DATE_ENTERED
     , AUDIT_EVENTS.DATE_MODIFIED
     , AUDIT_EVENTS.AUDIT_ID
     , AUDIT_EVENTS.AUDIT_TABLE
     , AUDIT_EVENTS.AUDIT_ACTION
     , AUDIT_EVENTS.AUDIT_PARENT_ID
     , MODULES.MODULE_NAME
     , (case MODULES.MODULE_NAME
        when N'Project'     then N'Projects'
        when N'ProjectTask' then N'ProjectTasks'
        else MODULES.MODULE_NAME
        end) as MODULE_FOLDER
  from      AUDIT_EVENTS
 inner join USERS
         on USERS.ID           = AUDIT_EVENTS.MODIFIED_USER_ID
 inner join MODULES
         on MODULES.TABLE_NAME + N'_AUDIT' = AUDIT_EVENTS.AUDIT_TABLE

GO

Grant Select on dbo.vwAUDIT_EVENTS to public;
GO


