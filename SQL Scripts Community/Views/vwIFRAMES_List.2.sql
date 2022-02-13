if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwIFRAMES_List')
	Drop View dbo.vwIFRAMES_List;
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
-- 01/01/2011 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
Create View dbo.vwIFRAMES_List
as
select ID
     , NAME
     , (case charindex(N'://', URL) when 0 then N'http://' + URL else URL end) as URL
     , TYPE
     , PLACEMENT
     , STATUS
     , CREATED_BY
     , CREATED_BY_NAME
     , MODIFIED_BY
     , MODIFIED_BY_NAME
  from vwIFRAMES

GO

Grant Select on dbo.vwIFRAMES_List to public;
GO


