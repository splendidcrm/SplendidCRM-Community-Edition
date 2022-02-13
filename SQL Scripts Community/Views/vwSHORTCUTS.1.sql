if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSHORTCUTS')
	Drop View dbo.vwSHORTCUTS;
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
-- 04/28/2006 Paul.  Added SHORTCUT_MODULE to help with ACL. 
-- 04/28/2006 Paul.  Added SHORTCUT_ACLTYPE to help with ACL. 
-- 03/29/2019 Paul.  All modules must have a name field. 
-- 04/01/2019 Paul.  DATE_MODIFIED and DATE_ENTERED for detail view. 
Create View dbo.vwSHORTCUTS
as
select ID
     , DISPLAY_NAME  as NAME
     , MODULE_NAME
     , DISPLAY_NAME
     , RELATIVE_PATH
     , IMAGE_NAME
     , SHORTCUT_ENABLED
     , SHORTCUT_ORDER
     , SHORTCUT_MODULE
     , SHORTCUT_ACLTYPE
     , DATE_ENTERED
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
  from SHORTCUTS
 where DELETED = 0

GO

Grant Select on dbo.vwSHORTCUTS to public;
GO


