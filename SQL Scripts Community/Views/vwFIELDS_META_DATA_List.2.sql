if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFIELDS_META_DATA_List')
	Drop View dbo.vwFIELDS_META_DATA_List;
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
-- 01/10/2007 Paul.  Add EXT1 for dropdown lists. 
Create View dbo.vwFIELDS_META_DATA_List
as
select ID
     , NAME
     , LABEL
     , CUSTOM_MODULE
     , DATA_TYPE
     , MAX_SIZE
     , REQUIRED_OPTION
     , DEFAULT_VALUE
     , DATE_ENTERED
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
     , EXT1
  from vwFIELDS_META_DATA

GO

Grant Select on dbo.vwFIELDS_META_DATA_List to public;
GO

 
