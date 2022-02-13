if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_ASSIGNED_TO_List')
	Drop View dbo.vwUSERS_ASSIGNED_TO_List;
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
-- 12/04/2006 Paul.  Only include active users. 
-- 12/05/2006 Paul.  New users created via NTLM will have a status of NULL. 
-- 04/15/2008 Paul.  Use vwUSERS_ASSIGNED_TO as the base to be similar to vwTEAMS_ASSIGNED_TO_List. 
Create View dbo.vwUSERS_ASSIGNED_TO_List
as
select vwUSERS_List.*
  from      vwUSERS_ASSIGNED_TO
 inner join vwUSERS_List
         on vwUSERS_List.ID = vwUSERS_ASSIGNED_TO.ID

GO

Grant Select on dbo.vwUSERS_ASSIGNED_TO_List to public;
GO


