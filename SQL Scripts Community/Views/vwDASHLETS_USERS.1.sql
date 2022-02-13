-- 09/07/2010 Paul.  Not sure why we are dropping this view after creating it, but it does not appear to be used anywhere. 
-- 09/10/2010 Paul.  This was just an old version of the view.  Move to the top. 
if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDETAILVIEWS_USERS')
	Drop View dbo.vwDETAILVIEWS_USERS;
GO


if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDASHLETS_USERS')
	Drop View dbo.vwDASHLETS_USERS;
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
-- 07/10/2009 Paul.  Defer the enabled check to the code so that we can see if data exists at all. 
-- 07/12/2009 Paul.  Include RELATIONSHIP_ORDER column to be compatible with DETAILVIEWS_RELATIONSHIPS view. 
-- 03/09/2014 Paul.  User dashlets do notrequire a DetailView record.  The filter was causing problems with Module dashlets. 
Create View dbo.vwDASHLETS_USERS
as
select DASHLETS_USERS.ID
     , DASHLETS_USERS.ASSIGNED_USER_ID
     , DASHLETS_USERS.DETAIL_NAME
     , DASHLETS_USERS.MODULE_NAME
     , DASHLETS_USERS.TITLE
     , DASHLETS_USERS.CONTROL_NAME
     , DASHLETS_USERS.DASHLET_ORDER
     , DASHLETS_USERS.DASHLET_ENABLED
     , DASHLETS_USERS.DASHLET_ORDER     as RELATIONSHIP_ORDER
  from      DASHLETS_USERS
-- inner join DETAILVIEWS
--         on DETAILVIEWS.NAME       = DASHLETS_USERS.DETAIL_NAME
--        and DETAILVIEWS.DELETED    = 0
 inner join MODULES
         on MODULES.MODULE_NAME    = DASHLETS_USERS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1
 where DASHLETS_USERS.DELETED = 0

GO

Grant Select on dbo.vwDASHLETS_USERS to public;
GO

