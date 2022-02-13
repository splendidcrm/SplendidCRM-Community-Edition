if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONFIG')
	Drop View dbo.vwCONFIG;
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
-- 12/05/2012 Paul.  We need the ID for Surface RT. 
-- 01/19/2013 Paul.  We need the CATEGORY for Surface RT, as vwCONFIG_List is not used. 
Create View dbo.vwCONFIG
as
select ID
     , NAME
     , VALUE
     , CATEGORY
     , DATE_MODIFIED
     , isnull(CATEGORY, N'') + N'_' + NAME as CATEGORY_NAME
  from CONFIG
 where DELETED = 0

GO

Grant Select on dbo.vwCONFIG to public;
GO

