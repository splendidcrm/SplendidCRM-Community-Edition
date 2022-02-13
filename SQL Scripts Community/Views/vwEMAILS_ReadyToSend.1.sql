if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_ReadyToSend')
	Drop View dbo.vwEMAILS_ReadyToSend;
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
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 12/19/2006 Paul.  The parent will be used when replacing template items. 
-- 05/15/2008 Paul.  Include DATE_MODIFIED so that emails could be sent FIFO style. 
-- 05/19/2008 Paul.  Email From information may already be split between FROM_ADDR and FROM_NAME. 
-- 07/19/2010 Paul.  When sending an email, the user account to use will be the last person who saved the email. 
-- 07/19/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
-- 07/19/2010 Paul.  Also include the Exchange Alias. 
-- 07/19/2013 Paul.  Transition to use of OUTBOUND_EMAILS for alternate outbound mailbox. 
Create View dbo.vwEMAILS_ReadyToSend
as
select EMAILS.ID
     , EMAILS.FROM_ADDR
     , EMAILS.FROM_NAME
     , EMAILS.TO_ADDRS
     , EMAILS.CC_ADDRS
     , EMAILS.BCC_ADDRS
     , EMAILS.NAME
     , EMAILS.DESCRIPTION
     , EMAILS.DESCRIPTION_HTML
     , EMAILS.TYPE
     , EMAILS.STATUS
     , EMAILS.PARENT_TYPE
     , EMAILS.PARENT_ID
     , EMAILS.DATE_MODIFIED
     , EMAILS.MODIFIED_USER_ID
     , EMAILS.MAILBOX_ID
     , EXCHANGE_USERS.EXCHANGE_ALIAS
     , EXCHANGE_USERS.EXCHANGE_EMAIL
     , isnull(OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPUSER, OUTBOUND_EMAILS_USER.MAIL_SMTPUSER) as MAIL_SMTPUSER
     , isnull(OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPPASS, OUTBOUND_EMAILS_USER.MAIL_SMTPPASS) as MAIL_SMTPPASS
     , OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPSERVER   
     , OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPPORT     
     , OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPAUTH_REQ 
     , OUTBOUND_EMAILS_MAILBOX.MAIL_SMTPSSL      
  from            EMAILS
  left outer join EXCHANGE_USERS
               on EXCHANGE_USERS.ASSIGNED_USER_ID = EMAILS.MODIFIED_USER_ID
              and EXCHANGE_USERS.DELETED          = 0
  left outer join OUTBOUND_EMAILS                   OUTBOUND_EMAILS_MAILBOX
               on OUTBOUND_EMAILS_MAILBOX.ID      = EMAILS.MAILBOX_ID
              and OUTBOUND_EMAILS_MAILBOX.DELETED = 0
  left outer join OUTBOUND_EMAILS                   OUTBOUND_EMAILS_USER
               on OUTBOUND_EMAILS_USER.USER_ID    = EMAILS.MODIFIED_USER_ID
              and OUTBOUND_EMAILS_USER.NAME       = N'system'
              and OUTBOUND_EMAILS_USER.TYPE       = N'system-override'
              and OUTBOUND_EMAILS_USER.DELETED    = 0
 where EMAILS.DELETED = 0
   and EMAILS.TYPE    = N'out'
   and (EMAILS.STATUS = N'draft' or EMAILS.STATUS is null)

GO

Grant Select on dbo.vwEMAILS_ReadyToSend to public;
GO

 
