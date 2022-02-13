if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_CLIENT_SYNC')
	Drop View dbo.vwEMAIL_CLIENT_SYNC;
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
-- 04/01/2010 Paul.  Add the MODULE_NAME so that the LastModifiedTime can be filtered by module. 
-- 04/04/2010 Paul.  Add PARENT_ID so that the LastModifiedTime can be filtered by record. 
-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
Create View dbo.vwEMAIL_CLIENT_SYNC
as
select ID                        as SYNC_ID
     , ASSIGNED_USER_ID          as SYNC_ASSIGNED_USER_ID
     , LOCAL_ID                  as SYNC_LOCAL_ID
     , LOCAL_DATE_MODIFIED       as SYNC_LOCAL_DATE_MODIFIED
     , REMOTE_DATE_MODIFIED      as SYNC_REMOTE_DATE_MODIFIED
     , LOCAL_DATE_MODIFIED_UTC   as SYNC_LOCAL_DATE_MODIFIED_UTC
     , REMOTE_DATE_MODIFIED_UTC  as SYNC_REMOTE_DATE_MODIFIED_UTC
     , REMOTE_KEY                as SYNC_REMOTE_KEY
     , MODULE_NAME               as SYNC_MODULE_NAME
     , PARENT_ID                 as SYNC_PARENT_ID
  from EMAIL_CLIENT_SYNC
 where DELETED = 0

GO

Grant Select on dbo.vwEMAIL_CLIENT_SYNC to public;
GO


