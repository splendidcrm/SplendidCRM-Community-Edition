if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ACCESS_ByAccess')
	Drop View dbo.vwACL_ACCESS_ByAccess;
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
-- 03/09/2010 Paul.  Allow IS_ADMIN and Team Management so that they can be managed separately. 
-- 09/26/2017 Paul.  Add Archive access right. 
Create View dbo.vwACL_ACCESS_ByAccess
as
select USERS.ID as USER_ID
     , vwACL_ACCESS_ByRole.MODULE_NAME
     , vwACL_ACCESS_ByRole.DISPLAY_NAME
     , min(ACLACCESS_ADMIN ) as ACLACCESS_ADMIN 
     , min(ACLACCESS_ACCESS) as ACLACCESS_ACCESS
     , min(ACLACCESS_VIEW  ) as ACLACCESS_VIEW  
     , min(ACLACCESS_LIST  ) as ACLACCESS_LIST  
     , min(ACLACCESS_EDIT  ) as ACLACCESS_EDIT  
     , min(ACLACCESS_DELETE) as ACLACCESS_DELETE
     , min(ACLACCESS_IMPORT) as ACLACCESS_IMPORT
     , min(ACLACCESS_EXPORT) as ACLACCESS_EXPORT
     , min(ACLACCESS_ARCHIVE) as ACLACCESS_ARCHIVE
     , vwACL_ACCESS_ByRole.IS_ADMIN
  from       vwACL_ACCESS_ByRole
  inner join ACL_ROLES_USERS
          on ACL_ROLES_USERS.ROLE_ID = vwACL_ACCESS_ByRole.ROLE_ID
         and ACL_ROLES_USERS.DELETED = 0
  inner join USERS
          on USERS.ID                = ACL_ROLES_USERS.USER_ID
         and USERS.DELETED           = 0
 group by USERS.ID, vwACL_ACCESS_ByRole.MODULE_NAME, vwACL_ACCESS_ByRole.DISPLAY_NAME, vwACL_ACCESS_ByRole.IS_ADMIN
GO

Grant Select on dbo.vwACL_ACCESS_ByAccess to public;
GO


