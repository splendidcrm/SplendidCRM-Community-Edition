if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDASHBOARD_APPS')
	Drop View dbo.vwDASHBOARD_APPS;
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
-- 06/16/2017 Paul.  Add DEFAULT_SETTINGS. 
Create View dbo.vwDASHBOARD_APPS
as
select DASHBOARD_APPS.ID
     , DASHBOARD_APPS.NAME
     , DASHBOARD_APPS.CATEGORY
     , DASHBOARD_APPS.MODULE_NAME
     , DASHBOARD_APPS.TITLE
     , DASHBOARD_APPS.SETTINGS_EDITVIEW
     , DASHBOARD_APPS.IS_ADMIN
     , DASHBOARD_APPS.APP_ENABLED
     , DASHBOARD_APPS.SCRIPT_URL
     , DASHBOARD_APPS.DEFAULT_SETTINGS
  from      DASHBOARD_APPS
 inner join MODULES
         on MODULES.MODULE_NAME    = DASHBOARD_APPS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1
 where DASHBOARD_APPS.DELETED = 0

GO

Grant Select on dbo.vwDASHBOARD_APPS to public;
GO

