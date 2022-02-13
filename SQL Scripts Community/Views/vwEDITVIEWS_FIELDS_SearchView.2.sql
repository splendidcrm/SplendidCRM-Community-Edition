if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEDITVIEWS_FIELDS_SearchView')
	Drop View dbo.vwEDITVIEWS_FIELDS_SearchView;
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
Create View dbo.vwEDITVIEWS_FIELDS_SearchView
as
select vwEDITVIEWS_FIELDS.*
     , dbo.fnEDITVIEWS_FIELDS_MultiSelect(MODULE_NAME, DATA_FIELD, FIELD_TYPE) as IS_MULTI_SELECT
  from vwEDITVIEWS_FIELDS

GO


Grant Select on dbo.vwEDITVIEWS_FIELDS_SearchView to public;
GO

