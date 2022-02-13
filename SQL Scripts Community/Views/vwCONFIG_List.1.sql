if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONFIG_List')
	Drop View dbo.vwCONFIG_List;
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
-- 09/28/2008 Paul.  max_users is a protected config value that cannot be edited by an admin. 
-- 01/19/2013 Paul.  This view is not using on Surface RT. 
Create View dbo.vwCONFIG_List
as
select ID
     , NAME
     , VALUE
     , CATEGORY
     , DATE_MODIFIED
     , isnull(CATEGORY, N'') + N'_' + NAME as CATEGORY_NAME
  from CONFIG
 where DELETED = 0
   and NAME not in (N'max_users')

GO

Grant Select on dbo.vwCONFIG_List to public;
GO

