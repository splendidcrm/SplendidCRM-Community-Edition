if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_RenameTabs')
	Drop View dbo.vwMODULES_RenameTabs;
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
Create View dbo.vwMODULES_RenameTabs
as
select TERMINOLOGY.ID
     , TERMINOLOGY.NAME
     , TERMINOLOGY.LANG
     , TERMINOLOGY.LIST_NAME
     , TERMINOLOGY.LIST_ORDER
     , TERMINOLOGY.DISPLAY_NAME
     , vwMODULES.TAB_ORDER
  from      TERMINOLOGY
 inner join vwMODULES
         on vwMODULES.MODULE_NAME = TERMINOLOGY.NAME
 where TERMINOLOGY.DELETED = 0
   and TERMINOLOGY.LIST_NAME = N'moduleList'
   and vwMODULES.TAB_ENABLED = 1
GO

Grant Select on dbo.vwMODULES_RenameTabs to public;
GO


