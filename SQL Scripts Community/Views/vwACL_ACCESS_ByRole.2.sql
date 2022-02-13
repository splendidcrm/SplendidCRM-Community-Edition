if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ACCESS_ByRole')
	Drop View dbo.vwACL_ACCESS_ByRole;
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
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 12/05/2006 Paul.  iFrames should not be excluded because the My Portal tab can be disabled and edited. 
-- 02/03/2009 Paul.  Exclude Teams from role management. 
-- 03/09/2010 Paul.  Allow IS_ADMIN and Team Management so that they can be managed separately. 
-- 04/17/2016 Paul.  Allow Calendar to be disabled. 
-- 09/26/2017 Paul.  Add Archive access right. 
Create View dbo.vwACL_ACCESS_ByRole
as
select vwMODULES_ACL_ROLES_Cross.MODULE_NAME
     , vwMODULES_ACL_ROLES_Cross.DISPLAY_NAME
     , vwMODULES_ACL_ROLES_Cross.ROLE_ID
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'admin' ),  1) as ACLACCESS_ADMIN 
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'access'), 89) as ACLACCESS_ACCESS
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'view'  ), 90) as ACLACCESS_VIEW  
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'list'  ), 90) as ACLACCESS_LIST  
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'edit'  ), 90) as ACLACCESS_EDIT  
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'delete'), 90) as ACLACCESS_DELETE
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'import'), 90) as ACLACCESS_IMPORT
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'export'), 90) as ACLACCESS_EXPORT
     , isnull((select min(ACLACCESS) from vwACL_ROLES_ACTIONS where ROLE_ID = vwMODULES_ACL_ROLES_Cross.ROLE_ID and CATEGORY = vwMODULES_ACL_ROLES_Cross.MODULE_NAME and NAME = N'archive'), 90) as ACLACCESS_ARCHIVE
     , vwMODULES_ACL_ROLES_Cross.IS_ADMIN
  from vwMODULES_ACL_ROLES_Cross
 where vwMODULES_ACL_ROLES_Cross.MODULE_ENABLED = 1
   and vwMODULES_ACL_ROLES_Cross.MODULE_NAME not in (N'Activities', N'Home')
GO

Grant Select on dbo.vwACL_ACCESS_ByRole to public;
GO


