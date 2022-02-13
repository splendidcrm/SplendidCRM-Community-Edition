if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_USERS')
	Drop View dbo.vwEMAILS_USERS;
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
-- 10/07/2015 Paul.  All views should have an ID. This is new because of the Preview button added 06/07/2015. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwEMAILS_USERS
as
select EMAILS.ID               as EMAIL_ID
     , EMAILS.NAME             as EMAIL_NAME
     , EMAILS.ASSIGNED_USER_ID as EMAIL_ASSIGNED_USER_ID
     , EMAILS.ASSIGNED_SET_ID  as EMAIL_ASSIGNED_SET_ID
     , USERS.ID
     , USERS.ID      as USER_ID
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as FULL_NAME
     , USERS.USER_NAME
     , USERS.EMAIL1
     , USERS.PHONE_WORK
     , EMAILS_USERS.DATE_ENTERED
  from           EMAILS
      inner join EMAILS_USERS
              on EMAILS_USERS.EMAIL_ID = EMAILS.ID
             and EMAILS_USERS.DELETED  = 0
      inner join USERS
              on USERS.ID              = EMAILS_USERS.USER_ID
             and USERS.DELETED         = 0
 where EMAILS.DELETED = 0

GO

Grant Select on dbo.vwEMAILS_USERS to public;
GO

