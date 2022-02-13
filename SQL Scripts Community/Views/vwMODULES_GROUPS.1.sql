if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_GROUPS')
	Drop View dbo.vwMODULES_GROUPS;
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
-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
Create View dbo.vwMODULES_GROUPS
as
select MODULES_GROUPS.ID
     , MODULES_GROUPS.GROUP_NAME
     , MODULES_GROUPS.MODULE_NAME
     , MODULES_GROUPS.MODULE_ORDER
     , MODULES_GROUPS.MODULE_MENU
     , TAB_GROUPS.TITLE
     , TAB_GROUPS.ENABLED
     , TAB_GROUPS.GROUP_ORDER
     , TAB_GROUPS.GROUP_MENU
  from      MODULES_GROUPS
 inner join TAB_GROUPS
         on TAB_GROUPS.NAME    = MODULES_GROUPS.GROUP_NAME
        and TAB_GROUPS.DELETED = 0
 where MODULES_GROUPS.DELETED = 0

GO

Grant Select on dbo.vwMODULES_GROUPS to public;
GO

