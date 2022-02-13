if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFEEDS_List')
	Drop View dbo.vwFEEDS_List;
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
-- 01/09/2008 Paul.  Fix name of USERS_FEED_ID.  It must be singular. 
Create View dbo.vwFEEDS_List
as
select vwFEEDS.*
     , USERS_FEEDS.ID              as USERS_FEED_ID
     , USERS_FEEDS.USER_ID         as USER_ID
     , USERS_FEEDS.RANK            as RANK
  from            vwFEEDS
  left outer join USERS_FEEDS
               on USERS_FEEDS.FEED_ID  = vwFEEDS.ID
              and USERS_FEEDS.DELETED  = 0

GO

Grant Select on dbo.vwFEEDS_List to public;
GO


