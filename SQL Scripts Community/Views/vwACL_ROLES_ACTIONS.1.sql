if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ROLES_ACTIONS')
	Drop View dbo.vwACL_ROLES_ACTIONS;
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
-- 01/15/2010 Paul.  Deleted ACL_ROLES was not being filtered. 
Create View dbo.vwACL_ROLES_ACTIONS
as
select ACL_ROLES.ID          as ROLE_ID
     , ACL_ACTIONS.NAME
     , ACL_ACTIONS.CATEGORY
     , (case when ACL_ROLES_ACTIONS.ACCESS_OVERRIDE is not null then ACL_ROLES_ACTIONS.ACCESS_OVERRIDE
             else ACL_ACTIONS.ACLACCESS
        end)                 as ACLACCESS
  from           ACL_ROLES
 left outer join ACL_ROLES_ACTIONS
              on ACL_ROLES_ACTIONS.ROLE_ID = ACL_ROLES.ID
             and ACL_ROLES_ACTIONS.DELETED = 0
 left outer join ACL_ACTIONS
              on ACL_ACTIONS.ID            = ACL_ROLES_ACTIONS.ACTION_ID
             and ACL_ACTIONS.DELETED       = 0
 where ACL_ROLES.DELETED = 0
GO

Grant Select on dbo.vwACL_ROLES_ACTIONS to public;
GO


