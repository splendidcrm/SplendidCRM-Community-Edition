if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwINBOUND_EMAILS')
	Drop View dbo.vwINBOUND_EMAILS;
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
-- 01/08/2008 Paul.  Separate out MAILBOX_SSL for ease of coding. Sugar combines it an TLS into the SERVICE field. 
-- 01/13/2008 Paul.  ONLY_SINCE will not be stored in STORED_OPTIONS because we need high-performance access. 
-- 01/13/2008 Paul.  Correct spelling of DELETE_SEEN, which is the reverse of MARK_READ. 
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 04/19/2011 Paul.  Add IS_PERSONAL to exclude EmailClient inbound from being included in monitored list. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
-- 05/24/2014 Paul.  We need to track the Last Email UID in order to support Only Since flag. 
-- 01/26/2017 Paul.  Add support for Office 365 as an OutboundEmail. 
-- 01/28/2017 Paul.  EXCHANGE_WATERMARK for support of Exchange and Office365.
-- 01/28/2017 Paul.  GROUP_TEAM_ID for inbound emails. 
Create View dbo.vwINBOUND_EMAILS
as
select INBOUND_EMAILS.ID
     , INBOUND_EMAILS.NAME
     , INBOUND_EMAILS.STATUS
     , INBOUND_EMAILS.SERVER_URL
     , INBOUND_EMAILS.EMAIL_USER
     , INBOUND_EMAILS.EMAIL_PASSWORD
     , INBOUND_EMAILS.PORT
     , INBOUND_EMAILS.SERVICE
     , INBOUND_EMAILS.MAILBOX_SSL
     , INBOUND_EMAILS.MAILBOX
     , (case INBOUND_EMAILS.DELETE_SEEN
        when 1 then 0
        else 1
        end)                         as MARK_READ
     , INBOUND_EMAILS.ONLY_SINCE
     , INBOUND_EMAILS.MAILBOX_TYPE
     , INBOUND_EMAILS.STORED_OPTIONS
     , INBOUND_EMAILS.FROM_NAME
     , INBOUND_EMAILS.FROM_ADDR
     , INBOUND_EMAILS.REPLY_TO_NAME
     , INBOUND_EMAILS.REPLY_TO_ADDR
     , INBOUND_EMAILS.FILTER_DOMAIN
     , INBOUND_EMAILS.IS_PERSONAL
     , INBOUND_EMAILS.DATE_ENTERED
     , INBOUND_EMAILS.DATE_MODIFIED
     , USERS_CREATED_BY.USER_NAME    as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME   as MODIFIED_BY
     , USER_GROUPS.ID                as GROUP_ID
     , USER_GROUPS.LAST_NAME         as GROUP_NAME
     , EMAIL_TEMPLATES.ID            as TEMPLATE_ID
     , EMAIL_TEMPLATES.NAME          as TEMPLATE_NAME
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , INBOUND_EMAILS.LAST_EMAIL_UID
     , INBOUND_EMAILS.GROUP_TEAM_ID
     , TEAMS.NAME                    as GROUP_TEAM_NAME
     , INBOUND_EMAILS.EXCHANGE_WATERMARK
     , INBOUND_EMAILS_CSTM.*
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = INBOUND_EMAILS.ID and OAUTH_TOKENS.NAME = N'Office365'  and OAUTH_TOKENS.DELETED = 0) as OFFICE365_OAUTH_ENABLED
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = INBOUND_EMAILS.ID and OAUTH_TOKENS.NAME = N'GoogleApps' and OAUTH_TOKENS.DELETED = 0) as GOOGLEAPPS_OAUTH_ENABLED
  from            INBOUND_EMAILS
  left outer join EMAIL_TEMPLATES
               on EMAIL_TEMPLATES.ID       = INBOUND_EMAILS.TEMPLATE_ID
              and EMAIL_TEMPLATES.DELETED  = 0
  left outer join USERS                      USER_GROUPS
               on USER_GROUPS.ID           = INBOUND_EMAILS.GROUP_ID
              and USER_GROUPS.DELETED      = 0
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = INBOUND_EMAILS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = INBOUND_EMAILS.MODIFIED_USER_ID
  left outer join TEAMS
               on TEAMS.ID                 = INBOUND_EMAILS.GROUP_TEAM_ID
              and TEAMS.DELETED            = 0
  left outer join INBOUND_EMAILS_CSTM
               on INBOUND_EMAILS_CSTM.ID_C = INBOUND_EMAILS.ID
 where INBOUND_EMAILS.DELETED = 0

GO

Grant Select on dbo.vwINBOUND_EMAILS to public;
GO


