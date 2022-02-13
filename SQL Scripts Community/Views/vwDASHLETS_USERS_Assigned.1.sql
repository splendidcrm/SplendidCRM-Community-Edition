if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDASHLETS_USERS_Assigned')
	Drop View dbo.vwDASHLETS_USERS_Assigned;
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
-- 09/20/2009 Paul.  This view is used to determine if any dashlets have been assigned. 
-- The primary goal is to allow a user to delete all dashlets and not have them automatically re-assigned. 
-- 03/09/2014 Paul.  User dashlets do notrequire a DetailView record.  The filter was causing problems with Module dashlets. 
Create View dbo.vwDASHLETS_USERS_Assigned
as
select DASHLETS_USERS.ID
     , DASHLETS_USERS.ASSIGNED_USER_ID
     , DASHLETS_USERS.DETAIL_NAME
     , DASHLETS_USERS.DELETED
  from      DASHLETS_USERS
-- inner join DETAILVIEWS
--         on DETAILVIEWS.NAME       = DASHLETS_USERS.DETAIL_NAME
--        and DETAILVIEWS.DELETED    = 0
 inner join MODULES
         on MODULES.MODULE_NAME    = DASHLETS_USERS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1

GO

Grant Select on dbo.vwDASHLETS_USERS_Assigned to public;
GO

