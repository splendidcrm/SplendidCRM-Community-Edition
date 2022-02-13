if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_ASSIGNED_TO')
	Drop View dbo.vwUSERS_ASSIGNED_TO;
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
-- 03/06/2006 Paul.  Oracle does not like <> ''.  Use len() > 0 instead. 
-- 12/04/2006 Paul.  Only include active users. 
-- 12/05/2006 Paul.  New users created via NTLM will have a status of NULL. 
-- 03/05/2009 Paul.  A Portal user should not be assignable. 
-- 08/02/2016 Paul.  This view will be used to get round-robin users to assign to a process. 
Create View dbo.vwUSERS_ASSIGNED_TO
as
select ID
     , USER_NAME
     , DATE_ENTERED
  from USERS
 where USER_NAME is not null
   and len(USER_NAME) > 0
   and (STATUS is null or STATUS = N'Active')
   and (PORTAL_ONLY is null or PORTAL_ONLY = 0)
   and DELETED = 0

GO

Grant Select on dbo.vwUSERS_ASSIGNED_TO to public;
GO




