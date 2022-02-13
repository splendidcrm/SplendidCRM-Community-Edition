if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ROLES_USERS')
	Drop View dbo.vwACL_ROLES_USERS;
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
-- 12/07/2006 Paul.  Only show active users. 
Create View dbo.vwACL_ROLES_USERS
as
select ACL_ROLES.ID   as ROLE_ID
     , ACL_ROLES.NAME as ROLE_NAME
     , USERS.ID   as USER_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.EMAIL1
     , USERS.PHONE_WORK
     , ACL_ROLES_USERS.DATE_ENTERED
  from           ACL_ROLES
      inner join ACL_ROLES_USERS
              on ACL_ROLES_USERS.ROLE_ID = ACL_ROLES.ID
             and ACL_ROLES_USERS.DELETED = 0
      inner join USERS
              on USERS.ID                = ACL_ROLES_USERS.USER_ID
             and USERS.DELETED           = 0
 where ACL_ROLES.DELETED = 0
  and (USERS.STATUS is null or USERS.STATUS = N'Active')

GO

Grant Select on dbo.vwACL_ROLES_USERS to public;
GO

