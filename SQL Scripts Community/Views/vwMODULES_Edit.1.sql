if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_Edit')
	Drop View dbo.vwMODULES_Edit;
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
-- 09/08/2010 Paul.  We need a separate view for the list as the default view filters by MODULE_ENABLED 
-- and we don't want to filter by that flag in the ListView, DetailView or EditView. 
-- 06/18/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
-- 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
-- 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
-- 07/31/2019 Paul.  DEFAULT_SORT is a new field for the React Client. 
Create View dbo.vwMODULES_Edit
as
select ID
     , MODULE_NAME
     , DISPLAY_NAME
     , RELATIVE_PATH
     , MODULE_ENABLED
     , TAB_ENABLED
     , TAB_ORDER
     , PORTAL_ENABLED
     , CUSTOM_ENABLED
     , IS_ADMIN
     , TABLE_NAME
     , REPORT_ENABLED
     , IMPORT_ENABLED
     , SYNC_ENABLED
     , MOBILE_ENABLED
     , CUSTOM_PAGING
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
     , MASS_UPDATE_ENABLED
     , DEFAULT_SEARCH_ENABLED
     , EXCHANGE_SYNC
     , EXCHANGE_FOLDERS
     , EXCHANGE_CREATE_PARENT
     , REST_ENABLED
     , DUPLICATE_CHECHING_ENABLED
     , RECORD_LEVEL_SECURITY_ENABLED
     , DEFAULT_SORT
  from MODULES
 where DELETED        = 0

GO

Grant Select on dbo.vwMODULES_Edit to public;
GO


