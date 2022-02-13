if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_TabMenu_ByUser')
	Drop View dbo.vwMODULES_TabMenu_ByUser;
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
-- 04/28/2006 Paul.  We could not use vwACL_ACCESS_ByModule because it does not include all available modules. 
-- 06/03/2006 Paul.  Only include modules that are enabled.  
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 10/26/2009 Paul.  Add PORTAL_ENABLED. 
Create View dbo.vwMODULES_TabMenu_ByUser
as
select vwMODULES_USERS_Cross.USER_ID
     , vwMODULES_USERS_Cross.MODULE_NAME
     , vwMODULES_USERS_Cross.DISPLAY_NAME
     , vwMODULES_USERS_Cross.RELATIVE_PATH
     , vwMODULES_USERS_Cross.TAB_ORDER
     , vwMODULES_USERS_Cross.PORTAL_ENABLED
  from            vwMODULES_USERS_Cross
  left outer join vwACL_ACTIONS
               on vwACL_ACTIONS.CATEGORY            = vwMODULES_USERS_Cross.MODULE_NAME
              and vwACL_ACTIONS.NAME                = N'access'
  left outer join vwACL_ACCESS_ByAccess
               on vwACL_ACCESS_ByAccess.USER_ID     = vwMODULES_USERS_Cross.USER_ID
              and vwACL_ACCESS_ByAccess.MODULE_NAME = vwMODULES_USERS_Cross.MODULE_NAME
 where vwMODULES_USERS_Cross.MODULE_ENABLED = 1
   and vwMODULES_USERS_Cross.TAB_ENABLED    = 1
   and vwMODULES_USERS_Cross.IS_ADMIN       = 0
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is not null and vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null and vwACL_ACTIONS.ACLACCESS is not null and vwACL_ACTIONS.ACLACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null and vwACL_ACTIONS.ACLACCESS is null)
       )
GO

Grant Select on dbo.vwMODULES_TabMenu_ByUser to public;
GO

