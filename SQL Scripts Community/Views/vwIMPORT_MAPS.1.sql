if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwIMPORT_MAPS')
	Drop View dbo.vwIMPORT_MAPS;
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
-- 08/01/2010 Paul.  Add ASSIGNED_TO_NAME so that we can display the full name in lists like Sugar. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 09/17/2013 Paul.  Add Business Rules to import. 
Create View dbo.vwIMPORT_MAPS
as
select IMPORT_MAPS.ID
     , IMPORT_MAPS.NAME
     , IMPORT_MAPS.SOURCE
     , IMPORT_MAPS.MODULE
     , IMPORT_MAPS.HAS_HEADER
     , IMPORT_MAPS.IS_PUBLISHED
     , IMPORT_MAPS.ASSIGNED_USER_ID
     , IMPORT_MAPS.DATE_ENTERED
     , IMPORT_MAPS.DATE_MODIFIED
     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME   , USERS_ASSIGNED.LAST_NAME   ) as ASSIGNED_TO_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , IMPORT_MAPS.RULES_XML
  from            IMPORT_MAPS
  left outer join USERS USERS_ASSIGNED
               on USERS_ASSIGNED.ID    = IMPORT_MAPS.ASSIGNED_USER_ID
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = IMPORT_MAPS.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = IMPORT_MAPS.MODIFIED_USER_ID
 where IMPORT_MAPS.DELETED = 0

GO

Grant Select on dbo.vwIMPORT_MAPS to public;
GO


