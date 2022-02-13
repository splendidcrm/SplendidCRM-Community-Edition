if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_LayoutViews')
	Drop View dbo.vwMODULES_LayoutViews;
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
-- 02/17/2011 Paul.  Need to allow ProductCategories and Discounts. 
Create View dbo.vwMODULES_LayoutViews
as
select MODULE_NAME
     , TABLE_NAME
     , RELATIVE_PATH
  from vwMODULES
 where (REPORT_ENABLED = 1 or MODULE_NAME in (N'Teams', N'ProductCategories', N'Discounts', N'Releases'))
   and MODULE_NAME not in (N'Payments')
GO

Grant Select on dbo.vwMODULES_LayoutViews to public;
GO


