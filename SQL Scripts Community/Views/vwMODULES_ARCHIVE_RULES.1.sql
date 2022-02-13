if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_ARCHIVE_RULES')
	Drop View dbo.vwMODULES_ARCHIVE_RULES;
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
Create View dbo.vwMODULES_ARCHIVE_RULES
as
select MODULES_ARCHIVE_RULES.ID
     , MODULES_ARCHIVE_RULES.NAME
     , MODULES_ARCHIVE_RULES.MODULE_NAME
     , MODULES_ARCHIVE_RULES.STATUS
     , MODULES_ARCHIVE_RULES.LIST_ORDER_Y
     , MODULES_ARCHIVE_RULES.DESCRIPTION
     , MODULES_ARCHIVE_RULES.DATE_ENTERED
     , MODULES_ARCHIVE_RULES.DATE_MODIFIED
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , MODULES_ARCHIVE_RULES.FILTER_SQL
     , MODULES_ARCHIVE_RULES.FILTER_XML
  from            MODULES_ARCHIVE_RULES
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = MODULES_ARCHIVE_RULES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = MODULES_ARCHIVE_RULES.MODIFIED_USER_ID
 where MODULES_ARCHIVE_RULES.DELETED = 0

GO

Grant Select on dbo.vwMODULES_ARCHIVE_RULES to public;
GO

