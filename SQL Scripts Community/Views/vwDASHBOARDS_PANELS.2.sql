if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDASHBOARDS_PANELS')
	Drop View dbo.vwDASHBOARDS_PANELS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
-- 05/26/2019 Paul.  Dashboard Name is needed by the React client. 
Create View dbo.vwDASHBOARDS_PANELS
as
select DASHBOARDS_PANELS.ID
     , DASHBOARDS_PANELS.DATE_ENTERED
     , DASHBOARDS_PANELS.DATE_MODIFIED
     , DASHBOARDS_PANELS.DATE_MODIFIED_UTC
     , DASHBOARDS_PANELS.PANEL_ORDER
     , DASHBOARDS_PANELS.ROW_INDEX
     , DASHBOARDS_PANELS.COLUMN_WIDTH
     , DASHBOARDS.ID                     as DASHBOARD_ID
     , DASHBOARDS.NAME                   as DASHBOARD_NAME
     , DASHBOARDS.ASSIGNED_USER_ID       as PARENT_ASSIGNED_USER_ID
     , DASHBOARDS.ASSIGNED_SET_ID        as PARENT_ASSIGNED_SET_ID
     , DASHBOARDS.TEAM_ID
     , DASHBOARDS.TEAM_SET_ID
     , DASHBOARD_APPS.ID                 as DASHBOARD_APP_ID
     , DASHBOARD_APPS.NAME
     , DASHBOARD_APPS.CATEGORY
     , DASHBOARD_APPS.MODULE_NAME
     , DASHBOARD_APPS.TITLE
     , DASHBOARD_APPS.SETTINGS_EDITVIEW
     , DASHBOARD_APPS.IS_ADMIN
     , DASHBOARD_APPS.APP_ENABLED
     , DASHBOARD_APPS.SCRIPT_URL
     , DASHBOARD_APPS.DEFAULT_SETTINGS
  from            DASHBOARDS_PANELS
       inner join DASHBOARDS
               on DASHBOARDS.ID            = DASHBOARDS_PANELS.DASHBOARD_ID
              and DASHBOARDS.DELETED       = 0
       inner join DASHBOARD_APPS
               on DASHBOARD_APPS.ID        = DASHBOARDS_PANELS.DASHBOARD_APP_ID
              and DASHBOARD_APPS.DELETED   = 0
 where DASHBOARDS_PANELS.DELETED = 0

GO

Grant Select on dbo.vwDASHBOARDS_PANELS to public;
GO

