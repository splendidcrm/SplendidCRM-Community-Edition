if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwIFRAMES')
	Drop View dbo.vwIFRAMES;
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
-- 11/28/2007 Paul.  Include TEAM_ID to allow standard ACL code to work.
-- 09/01/2009 Paul.  Add TEAM_SET_ID so that the team filter will not fail. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 02/21/2021 Paul.  DATE_MODIFIED_UTC is needed by the React client. 
Create View dbo.vwIFRAMES
as
select IFRAMES.ID
     , IFRAMES.NAME
     , IFRAMES.URL
     , IFRAMES.TYPE
     , IFRAMES.PLACEMENT
     , IFRAMES.STATUS
     , IFRAMES.DATE_ENTERED
     , IFRAMES.DATE_MODIFIED
     , IFRAMES.DATE_MODIFIED_UTC
     , USERS_CREATED_BY.USER_NAME     as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME    as MODIFIED_BY
     , cast(null as uniqueidentifier) as ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as TEAM_ID
     , cast(null as uniqueidentifier) as TEAM_SET_ID
     , cast(null as nvarchar(200))    as TEAM_SET_NAME
     , cast(null as uniqueidentifier) as ASSIGNED_SET_ID
     , cast(null as nvarchar(200))    as ASSIGNED_SET_NAME
     , cast(null as varchar(851))     as ASSIGNED_SET_LIST
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
  from            IFRAMES
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = IFRAMES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = IFRAMES.MODIFIED_USER_ID
 where IFRAMES.DELETED = 0

GO

Grant Select on dbo.vwIFRAMES to public;
GO

 
