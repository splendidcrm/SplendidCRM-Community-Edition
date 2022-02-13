if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_USERS_Cross')
	Drop View dbo.vwMODULES_USERS_Cross;
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
-- 04/29/2006 Paul.  DB2 has a problem with cross joins, so place in a view so that it can easily be converted. 
-- 05/20/2006 Paul.  Add REPORT_ENABLED flag as we need to restrict the list to enabled and accessible modules. 
-- 10/06/2006 Paul.  Add IMPORT_ENABLED if the module can allow importing. 
-- 11/17/2007 Paul.  Add MOBILE_ENABLED. 
-- 10/26/2009 Paul.  Add PORTAL_ENABLED. 
-- 12/06/2009 Paul.  We need the ID and TABLE_NAME when generating the SemanticModel for the ReportBuilder. 
Create View dbo.vwMODULES_USERS_Cross
as
select MODULES.MODULE_NAME
     , MODULES.DISPLAY_NAME
     , MODULES.RELATIVE_PATH
     , MODULES.MODULE_ENABLED
     , MODULES.TAB_ENABLED
     , MODULES.TAB_ORDER
     , MODULES.REPORT_ENABLED
     , MODULES.IMPORT_ENABLED
     , MODULES.IS_ADMIN
     , USERS.ID           as USER_ID
     , MODULES.MOBILE_ENABLED
     , MODULES.PORTAL_ENABLED
     , MODULES.ID
     , MODULES.TABLE_NAME
  from      MODULES
 cross join USERS
 where MODULES.DELETED = 0
   and USERS.DELETED   = 0

GO

Grant Select on dbo.vwMODULES_USERS_Cross to public;
GO

