if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ROLES')
	Drop View dbo.vwACL_ROLES;
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
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 07/07/2020 Paul.  DATE_MODIFIED_UTC is required by the React Client. 
Create View dbo.vwACL_ROLES
as
select ACL_ROLES.ID
     , ACL_ROLES.NAME
     , ACL_ROLES.DESCRIPTION
     , ACL_ROLES.DATE_ENTERED
     , ACL_ROLES.DATE_MODIFIED
     , ACL_ROLES.DATE_MODIFIED_UTC
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , ACL_ROLES_CSTM.*
  from            ACL_ROLES
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = ACL_ROLES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = ACL_ROLES.MODIFIED_USER_ID
  left outer join ACL_ROLES_CSTM
               on ACL_ROLES_CSTM.ID_C      = ACL_ROLES.ID
 where ACL_ROLES.DELETED = 0

GO

Grant Select on dbo.vwACL_ROLES to public;
GO


