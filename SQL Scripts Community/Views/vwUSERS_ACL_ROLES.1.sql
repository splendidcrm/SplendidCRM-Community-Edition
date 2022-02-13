if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_ACL_ROLES')
	Drop View dbo.vwUSERS_ACL_ROLES;
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
-- 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
Create View dbo.vwUSERS_ACL_ROLES
as
select USERS.ID              as USER_ID
     , ACL_ROLES.ID          as ROLE_ID
     , ACL_ROLES.NAME        as ROLE_NAME
     , ACL_ROLES.DESCRIPTION
     , ACL_ROLES_USERS.DATE_ENTERED
     , (case when USERS.PRIMARY_ROLE_ID = ACL_ROLES.ID then 1 else 0 end) as IS_PRIMARY_ROLE
  from           USERS
      inner join ACL_ROLES_USERS
              on ACL_ROLES_USERS.USER_ID = USERS.ID
             and ACL_ROLES_USERS.DELETED = 0
      inner join ACL_ROLES
              on ACL_ROLES.ID            = ACL_ROLES_USERS.ROLE_ID
             and ACL_ROLES.DELETED       = 0
 where USERS.DELETED = 0

GO

Grant Select on dbo.vwUSERS_ACL_ROLES to public;
GO

