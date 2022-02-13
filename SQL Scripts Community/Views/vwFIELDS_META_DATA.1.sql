if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFIELDS_META_DATA')
	Drop View dbo.vwFIELDS_META_DATA;
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
-- 04/21/2006 Paul.  MASS_UPDATE was added in SugarCRM 4.0.
Create View dbo.vwFIELDS_META_DATA
as
select ID
     , NAME
     , LABEL
     , CUSTOM_MODULE
     , DATA_TYPE
     , MAX_SIZE
     , REQUIRED_OPTION
     , AUDITED
     , DEFAULT_VALUE
     , EXT1
     , EXT2
     , EXT3
     , MASS_UPDATE
     , DATE_ENTERED
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
  from FIELDS_META_DATA
 where DELETED = 0

GO

Grant Select on dbo.vwFIELDS_META_DATA to public;
GO

