if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTAB_GROUPS')
	Drop View dbo.vwTAB_GROUPS;
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
-- 02/25/2010 Paul.  We need a flag to determine if the group is displayed on the menu. 
Create View dbo.vwTAB_GROUPS
as
select ID
     , NAME
     , TITLE
     , ENABLED
     , GROUP_ORDER
     , GROUP_MENU
  from TAB_GROUPS
 where DELETED = 0

GO

Grant Select on dbo.vwTAB_GROUPS to public;
GO

