if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSER_PREFERENCES')
	Drop View dbo.vwUSER_PREFERENCES;
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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
Create View dbo.vwUSER_PREFERENCES
as
select USER_PREFERENCES.ID
     , USER_PREFERENCES.CATEGORY
     , USER_PREFERENCES.ASSIGNED_USER_ID
     , USER_PREFERENCES.DATE_MODIFIED
     , USER_PREFERENCES.DATE_MODIFIED_UTC
     , lower(USERS.USER_NAME)             as ASSIGNED_USER_NAME
  from            USER_PREFERENCES
  left outer join USERS
               on USERS.ID = USER_PREFERENCES.ASSIGNED_USER_ID
 where USER_PREFERENCES.DELETED = 0

GO

Grant Select on dbo.vwUSER_PREFERENCES to public;
GO

