if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_TASKS')
	Drop View dbo.vwEMAILS_TASKS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAILS_TASKS
as
select EMAILS.ID               as EMAIL_ID
     , EMAILS.NAME             as EMAIL_NAME
     , EMAILS.ASSIGNED_USER_ID as EMAIL_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID  as EMAIL_ASSIGNED_SET_ID
     , vwTASKS.ID              as TASK_ID
     , vwTASKS.NAME            as TASK_NAME
     , vwTASKS.*
  from            EMAILS
       inner join EMAILS_TASKS
               on EMAILS_TASKS.EMAIL_ID = EMAILS.ID
              and EMAILS_TASKS.DELETED  = 0
       inner join vwTASKS
               on vwTASKS.ID            = EMAILS_TASKS.TASK_ID
 where EMAILS.DELETED = 0
union all
select EMAILS.ID               as EMAIL_ID
     , EMAILS.NAME             as EMAIL_NAME
     , EMAILS.ASSIGNED_USER_ID as EMAIL_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID  as EMAIL_ASSIGNED_SET_ID
     , vwTASKS.ID              as TASK_ID
     , vwTASKS.NAME            as TASK_NAME
     , vwTASKS.*
  from            EMAILS
       inner join vwTASKS
               on vwTASKS.ID            = EMAILS.PARENT_ID
  left outer join EMAILS_TASKS
               on EMAILS_TASKS.EMAIL_ID = EMAILS.ID
              and EMAILS_TASKS.TASK_ID   = vwTASKS.ID
              and EMAILS_TASKS.DELETED  = 0
 where EMAILS.DELETED     = 0
   and EMAILS.PARENT_TYPE = N'Tasks'
   and EMAILS_TASKS.ID is null

GO

Grant Select on dbo.vwEMAILS_TASKS to public;
GO

