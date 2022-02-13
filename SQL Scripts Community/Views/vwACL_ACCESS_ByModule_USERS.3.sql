if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ACCESS_ByModule_USERS')
	Drop View dbo.vwACL_ACCESS_ByModule_USERS;
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
-- 03/09/2010 Paul.  Allow IS_ADMIN and Team Management so that they can be managed separately. 
-- 09/26/2017 Paul.  Add Archive access right. 
Create View dbo.vwACL_ACCESS_ByModule_USERS
as
select vwACL_ACCESS_ByModule.MODULE_NAME
     , vwACL_ACCESS_ByModule.DISPLAY_NAME
     , vwACL_ACCESS_ByModule.ACLACCESS_ADMIN 
     , vwACL_ACCESS_ByModule.ACLACCESS_ACCESS
     , vwACL_ACCESS_ByModule.ACLACCESS_VIEW  
     , vwACL_ACCESS_ByModule.ACLACCESS_LIST  
     , vwACL_ACCESS_ByModule.ACLACCESS_EDIT  
     , vwACL_ACCESS_ByModule.ACLACCESS_DELETE
     , vwACL_ACCESS_ByModule.ACLACCESS_IMPORT
     , vwACL_ACCESS_ByModule.ACLACCESS_EXPORT
     , vwACL_ACCESS_ByModule.ACLACCESS_ARCHIVE
     , USERS.ID           as USER_ID
     , vwACL_ACCESS_ByModule.IS_ADMIN
  from      vwACL_ACCESS_ByModule
 cross join USERS
 where USERS.DELETED   = 0

GO

Grant Select on dbo.vwACL_ACCESS_ByModule_USERS to public;
GO

