if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTEAM_MEMBERSHIPS')
	Drop View dbo.vwTEAM_MEMBERSHIPS;
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
-- 11/24/2006 Paul.  We need to make sure that the columns do not match that of any view that will be joined to this one. 
Create View dbo.vwTEAM_MEMBERSHIPS
as
select ID      as MEMBERSHIP_ID
     , TEAM_ID as MEMBERSHIP_TEAM_ID
     , USER_ID as MEMBERSHIP_USER_ID
  from TEAM_MEMBERSHIPS
 where DELETED = 0

GO

Grant Select on dbo.vwTEAM_MEMBERSHIPS to public;
GO

