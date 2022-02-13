if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_CONFIGURE_TABS')
	Drop View dbo.vwMODULES_CONFIGURE_TABS;
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
-- 08/27/2007 Paul.  We need to have access to disabled modules. 
-- 11/17/2007 Paul.  Add MOBILE_ENABLED flag to determine if module should be shown on mobile browser.
Create View dbo.vwMODULES_CONFIGURE_TABS
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
     , MOBILE_ENABLED
  from MODULES
 where DELETED  = 0
   and IS_ADMIN = 0

GO

Grant Select on dbo.vwMODULES_CONFIGURE_TABS to public;
GO


