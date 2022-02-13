if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROCESSES_Pending')
	Drop View dbo.vwPROCESSES_Pending;
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
-- 08/26/2016 Paul.  A completed process will need to set thte status. 
Create View dbo.vwPROCESSES_Pending
as
select ID
     , PROCESS_NUMBER
     , BUSINESS_PROCESS_INSTANCE_ID
     , ACTIVITY_INSTANCE
     , ACTIVITY_NAME
     , BUSINESS_PROCESS_ID
     , PROCESS_USER_ID
     , BOOKMARK_NAME
     , PARENT_TYPE
     , PARENT_ID
     , USER_TASK_TYPE
     , CHANGE_ASSIGNED_USER
     , CHANGE_ASSIGNED_TEAM_ID
     , CHANGE_PROCESS_USER
     , CHANGE_PROCESS_TEAM_ID
     , USER_ASSIGNMENT_METHOD
     , STATIC_ASSIGNED_USER_ID
     , DYNAMIC_PROCESS_TEAM_ID
     , DYNAMIC_PROCESS_ROLE_ID
     , READ_ONLY_FIELDS
     , REQUIRED_FIELDS
     , DURATION_UNITS
     , DURATION_VALUE
     , STATUS
     , APPROVAL_USER_ID
     , APPROVAL_DATE
     , APPROVAL_RESPONSE
     , DATE_ENTERED
     , DATE_MODIFIED
  from PROCESSES
 where DELETED = 0
   and APPROVAL_USER_ID is null
   and STATUS in (N'In Progress', N'Unclaimed', N'Claimed')

GO

Grant Select on dbo.vwPROCESSES_Pending to public;
GO

