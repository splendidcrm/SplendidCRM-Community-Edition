if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSHORTCUTS_USERS_Cross')
	Drop View dbo.vwSHORTCUTS_USERS_Cross;
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
-- 04/29/2006 Paul.  DB2 has a problem with cross joins, so place in a view so that it can easily be converted. 
-- 11/22/2007 Paul.  Only show the shortcut if the module of the shortcut is enabled. 
-- 03/04/2008 Paul.  Admin modules are not ment to be disabled, so show the short cuts even if they are disabled. 
-- 03/11/2008 Paul.  Must always check the deleted flag. 
Create View dbo.vwSHORTCUTS_USERS_Cross
as
select SHORTCUTS.MODULE_NAME
     , SHORTCUTS.DISPLAY_NAME
     , SHORTCUTS.RELATIVE_PATH
     , SHORTCUTS.IMAGE_NAME
     , SHORTCUTS.SHORTCUT_ENABLED
     , SHORTCUTS.SHORTCUT_ORDER
     , SHORTCUTS.SHORTCUT_MODULE
     , SHORTCUTS.SHORTCUT_ACLTYPE
     , USERS.ID                   as USER_ID
  from      SHORTCUTS
 inner join MODULES
         on MODULES.MODULE_NAME    = SHORTCUTS.SHORTCUT_MODULE
        and MODULES.DELETED        = 0
        and (MODULES.MODULE_ENABLED = 1 or MODULES.IS_ADMIN = 1)
 cross join USERS
 where SHORTCUTS.DELETED = 0

GO

Grant Select on dbo.vwSHORTCUTS_USERS_Cross to public;
GO

