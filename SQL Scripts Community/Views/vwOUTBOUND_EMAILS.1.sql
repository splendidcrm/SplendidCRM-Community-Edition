if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOUTBOUND_EMAILS')
	Drop View dbo.vwOUTBOUND_EMAILS;
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
-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
-- 01/17/2017 Paul.  Add support for Office 365 as an OutboundEmail. 
Create View dbo.vwOUTBOUND_EMAILS
as
select OUTBOUND_EMAILS.ID
     , OUTBOUND_EMAILS.NAME
     , OUTBOUND_EMAILS.TYPE
     , OUTBOUND_EMAILS.USER_ID
     , isnull(OUTBOUND_EMAILS.MAIL_SENDTYPE, N'smtp') as MAIL_SENDTYPE
     , OUTBOUND_EMAILS.MAIL_SMTPTYPE
     , OUTBOUND_EMAILS.MAIL_SMTPSERVER
     , OUTBOUND_EMAILS.MAIL_SMTPPORT
     , OUTBOUND_EMAILS.MAIL_SMTPUSER
     , OUTBOUND_EMAILS.MAIL_SMTPPASS
     , OUTBOUND_EMAILS.MAIL_SMTPAUTH_REQ
     , OUTBOUND_EMAILS.MAIL_SMTPSSL
     , (case when USERS_ASSIGNED.ID is not null then dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME) else OUTBOUND_EMAILS.FROM_NAME end) as FROM_NAME
     , (case when USERS_ASSIGNED.ID is not null then USERS_ASSIGNED.EMAIL1                                               else OUTBOUND_EMAILS.FROM_ADDR end) as FROM_ADDR
     , (case when USERS_ASSIGNED.ID is not null
             then dbo.fnEmailDisplayName(dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME), USERS_ASSIGNED.EMAIL1)
             else dbo.fnEmailDisplayName(OUTBOUND_EMAILS.FROM_NAME, OUTBOUND_EMAILS.FROM_ADDR)
        end) as DISPLAY_NAME
     , OUTBOUND_EMAILS.DATE_ENTERED
     , OUTBOUND_EMAILS.DATE_MODIFIED
     , OUTBOUND_EMAILS.USER_ID       as ASSIGNED_USER_ID
     , USERS_ASSIGNED.USER_NAME      as ASSIGNED_TO_NAME
     , USERS_CREATED_BY.USER_NAME    as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME   as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , TEAMS.ID                    as TEAM_ID
     , TEAMS.NAME                  as TEAM_NAME
     , TEAM_SETS.ID                as TEAM_SET_ID
     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME
     , TEAM_SETS.TEAM_SET_LIST     as TEAM_SET_LIST
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.ID and OAUTH_TOKENS.NAME = N'Office365'  and OAUTH_TOKENS.DELETED = 0) as OFFICE365_OAUTH_ENABLED
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = OUTBOUND_EMAILS.ID and OAUTH_TOKENS.NAME = N'GoogleApps' and OAUTH_TOKENS.DELETED = 0) as GOOGLEAPPS_OAUTH_ENABLED
  from            OUTBOUND_EMAILS
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = OUTBOUND_EMAILS.USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = OUTBOUND_EMAILS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = OUTBOUND_EMAILS.MODIFIED_USER_ID
  left outer join TEAMS
               on TEAMS.ID                 = OUTBOUND_EMAILS.TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join TEAM_SETS
               on TEAM_SETS.ID             = OUTBOUND_EMAILS.TEAM_SET_ID
              and TEAM_SETS.DELETED        = 0
 where OUTBOUND_EMAILS.DELETED = 0

GO

Grant Select on dbo.vwOUTBOUND_EMAILS to public;
GO


