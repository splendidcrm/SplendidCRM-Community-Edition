if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_ACL_ROLES_Cross')
	Drop View dbo.vwMODULES_ACL_ROLES_Cross;
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
-- 01/16/2010 Paul.  We need the table name so that we can get the ACL Fields for a module. 
Create View dbo.vwMODULES_ACL_ROLES_Cross
as
select MODULES.MODULE_NAME
     , MODULES.TABLE_NAME
     , MODULES.DISPLAY_NAME
     , MODULES.MODULE_ENABLED
     , MODULES.TAB_ENABLED
     , MODULES.TAB_ORDER
     , MODULES.IS_ADMIN
     , ACL_ROLES.ID           as ROLE_ID
  from      MODULES
 cross join ACL_ROLES
 where MODULES.DELETED = 0
   and ACL_ROLES.DELETED = 0

GO

Grant Select on dbo.vwMODULES_ACL_ROLES_Cross to public;
GO

