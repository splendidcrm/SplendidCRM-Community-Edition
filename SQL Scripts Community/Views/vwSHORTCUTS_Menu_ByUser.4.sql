if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSHORTCUTS_Menu_ByUser')
	Drop View dbo.vwSHORTCUTS_Menu_ByUser;
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
-- 04/28/2006 Paul.  We need to look at both the access right and either the edit right or the list right. 
-- Although we could combine the union into a single query, it seems too complex. 
-- 09/09/2006 Paul.  Include import in types that can appear in shortcuts. 
-- 12/05/2006 Paul.  We need to filter on access rights for vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE, not the rights for the module being displayed. 
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 09/26/2017 Paul.  Add Archive access right. 
Create View dbo.vwSHORTCUTS_Menu_ByUser
as
select vwSHORTCUTS_USERS_Cross.USER_ID
     , vwSHORTCUTS_USERS_Cross.MODULE_NAME
     , vwSHORTCUTS_USERS_Cross.DISPLAY_NAME
     , vwSHORTCUTS_USERS_Cross.RELATIVE_PATH
     , vwSHORTCUTS_USERS_Cross.IMAGE_NAME
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ORDER
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE
  from            vwSHORTCUTS_USERS_Cross
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_AccessOnly
               on vwACL_ACTIONS_AccessOnly.CATEGORY = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_AccessOnly.NAME     = N'access'
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_EditOnly
               on vwACL_ACTIONS_EditOnly.CATEGORY   = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_EditOnly.NAME       = N'edit'
  left outer join vwACL_ACCESS_ByAccess
               on vwACL_ACCESS_ByAccess.USER_ID     = vwSHORTCUTS_USERS_Cross.USER_ID
              and vwACL_ACCESS_ByAccess.MODULE_NAME = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
 where vwSHORTCUTS_USERS_Cross.SHORTCUT_ENABLED = 1
   and vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE = N'edit'
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is not null and vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is not null and vwACL_ACTIONS_AccessOnly.ACLACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is null)
       )
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_EDIT   is not null and vwACL_ACCESS_ByAccess.ACLACCESS_EDIT >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_EDIT   is null     and vwACL_ACTIONS_EditOnly.ACLACCESS is not null   and vwACL_ACTIONS_EditOnly.ACLACCESS   >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_EDIT   is null     and vwACL_ACTIONS_EditOnly.ACLACCESS is null)
       )
union all
select vwSHORTCUTS_USERS_Cross.USER_ID
     , vwSHORTCUTS_USERS_Cross.MODULE_NAME
     , vwSHORTCUTS_USERS_Cross.DISPLAY_NAME
     , vwSHORTCUTS_USERS_Cross.RELATIVE_PATH
     , vwSHORTCUTS_USERS_Cross.IMAGE_NAME
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ORDER
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE
  from            vwSHORTCUTS_USERS_Cross
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_AccessOnly
               on vwACL_ACTIONS_AccessOnly.CATEGORY = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_AccessOnly.NAME     = N'access'
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_ListOnly
               on vwACL_ACTIONS_ListOnly.CATEGORY   = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_ListOnly.NAME       = N'list'
  left outer join vwACL_ACCESS_ByAccess
               on vwACL_ACCESS_ByAccess.USER_ID     = vwSHORTCUTS_USERS_Cross.USER_ID
              and vwACL_ACCESS_ByAccess.MODULE_NAME = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
 where vwSHORTCUTS_USERS_Cross.SHORTCUT_ENABLED = 1
   and vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE = N'list'
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is not null and vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is not null and vwACL_ACTIONS_AccessOnly.ACLACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is null)
       )
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_LIST   is not null and vwACL_ACCESS_ByAccess.ACLACCESS_LIST >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_LIST   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is not null   and vwACL_ACTIONS_ListOnly.ACLACCESS   >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_LIST   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is null)
       )
union all
select vwSHORTCUTS_USERS_Cross.USER_ID
     , vwSHORTCUTS_USERS_Cross.MODULE_NAME
     , vwSHORTCUTS_USERS_Cross.DISPLAY_NAME
     , vwSHORTCUTS_USERS_Cross.RELATIVE_PATH
     , vwSHORTCUTS_USERS_Cross.IMAGE_NAME
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ORDER
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE
  from            vwSHORTCUTS_USERS_Cross
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_AccessOnly
               on vwACL_ACTIONS_AccessOnly.CATEGORY = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_AccessOnly.NAME     = N'access'
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_ListOnly
               on vwACL_ACTIONS_ListOnly.CATEGORY   = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_ListOnly.NAME       = N'import'
  left outer join vwACL_ACCESS_ByAccess
               on vwACL_ACCESS_ByAccess.USER_ID     = vwSHORTCUTS_USERS_Cross.USER_ID
              and vwACL_ACCESS_ByAccess.MODULE_NAME = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
 where vwSHORTCUTS_USERS_Cross.SHORTCUT_ENABLED = 1
   and vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE = N'import'
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is not null and vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is not null and vwACL_ACTIONS_AccessOnly.ACLACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is null)
       )
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is not null and vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is not null   and vwACL_ACTIONS_ListOnly.ACLACCESS   >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is null)
       )
union all
select vwSHORTCUTS_USERS_Cross.USER_ID
     , vwSHORTCUTS_USERS_Cross.MODULE_NAME
     , vwSHORTCUTS_USERS_Cross.DISPLAY_NAME
     , vwSHORTCUTS_USERS_Cross.RELATIVE_PATH
     , vwSHORTCUTS_USERS_Cross.IMAGE_NAME
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ORDER
     , vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE
  from            vwSHORTCUTS_USERS_Cross
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_AccessOnly
               on vwACL_ACTIONS_AccessOnly.CATEGORY = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_AccessOnly.NAME     = N'access'
  left outer join vwACL_ACTIONS                       vwACL_ACTIONS_ListOnly
               on vwACL_ACTIONS_ListOnly.CATEGORY   = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
              and vwACL_ACTIONS_ListOnly.NAME       = N'archive'
  left outer join vwACL_ACCESS_ByAccess
               on vwACL_ACCESS_ByAccess.USER_ID     = vwSHORTCUTS_USERS_Cross.USER_ID
              and vwACL_ACCESS_ByAccess.MODULE_NAME = vwSHORTCUTS_USERS_Cross.SHORTCUT_MODULE
 where vwSHORTCUTS_USERS_Cross.SHORTCUT_ENABLED = 1
   and vwSHORTCUTS_USERS_Cross.SHORTCUT_ACLTYPE = N'archive'
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is not null and vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is not null and vwACL_ACTIONS_AccessOnly.ACLACCESS >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_ACCESS is null     and vwACL_ACTIONS_AccessOnly.ACLACCESS is null)
       )
   and (   (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is not null and vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is not null   and vwACL_ACTIONS_ListOnly.ACLACCESS   >= 0)
        or (vwACL_ACCESS_ByAccess.ACLACCESS_IMPORT   is null     and vwACL_ACTIONS_ListOnly.ACLACCESS is null)
       )

GO

Grant Select on dbo.vwSHORTCUTS_Menu_ByUser to public;
GO

