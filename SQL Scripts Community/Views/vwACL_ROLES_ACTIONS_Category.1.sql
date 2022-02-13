if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ROLES_ACTIONS_Category')
	Drop View dbo.vwACL_ROLES_ACTIONS_Category;
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
Create View dbo.vwACL_ROLES_ACTIONS_Category
as
select ACL_ROLES_ACTIONS.ID
     , ACL_ROLES_ACTIONS.DELETED
     , ACL_ROLES_ACTIONS.CREATED_BY
     , ACL_ROLES_ACTIONS.DATE_ENTERED
     , ACL_ROLES_ACTIONS.MODIFIED_USER_ID
     , ACL_ROLES_ACTIONS.DATE_MODIFIED
     , ACL_ROLES_ACTIONS.DATE_MODIFIED_UTC
     , ACL_ROLES_ACTIONS.ROLE_ID
     , ACL_ROLES_ACTIONS.ACTION_ID
     , ACL_ROLES_ACTIONS.ACCESS_OVERRIDE
     , ACL_ACTIONS.CATEGORY
  from      ACL_ROLES_ACTIONS
 inner join ACL_ACTIONS
         on ACL_ACTIONS.ID = ACL_ROLES_ACTIONS.ACTION_ID

GO

Grant Select on dbo.vwACL_ROLES_ACTIONS_Category to public;
GO


