if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwINBOUND_EMAILS_Bounce')
	Drop View dbo.vwINBOUND_EMAILS_Bounce;
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
-- 01/12/2008 Paul.  Include all POP3 connection information. 
-- 01/13/2008 Paul.  ONLY_SINCE will not be stored in STORED_OPTIONS because we need high-performance access. 
-- 01/13/2008 Paul.  Correct spelling of DELETE_SEEN, which is the reverse of MARK_READ. 
-- 01/20/2008 Paul.  GROUP_ID is required. 
-- 04/19/2011 Paul.  Add IS_PERSONAL to exclude EmailClient inbound from being included in monitored list. 
-- 05/24/2014 Paul.  We need to track the Last Email UID in order to support Only Since flag. 
-- 01/26/2017 Paul.  Add support for Office 365 as an OutboundEmail. 
-- 01/28/2017 Paul.  EXCHANGE_WATERMARK for support of Exchange and Office365.
-- 01/28/2017 Paul.  GROUP_TEAM_ID for inbound emails. 
Create View dbo.vwINBOUND_EMAILS_Bounce
as
select ID
     , NAME
     , SERVER_URL
     , EMAIL_USER
     , EMAIL_PASSWORD
     , PORT
     , SERVICE
     , MAILBOX_SSL
     , MAILBOX
     , MARK_READ
     , ONLY_SINCE
     , MAILBOX_TYPE
     , FROM_NAME
     , FROM_ADDR
     , FILTER_DOMAIN
     , GROUP_ID
     , TEMPLATE_ID
     , LAST_EMAIL_UID
     , GROUP_TEAM_ID
     , EXCHANGE_WATERMARK
     , OFFICE365_OAUTH_ENABLED
     , GOOGLEAPPS_OAUTH_ENABLED
  from vwINBOUND_EMAILS
 where STATUS       = N'Active'
   and MAILBOX_TYPE = N'bounce'

GO

Grant Select on dbo.vwINBOUND_EMAILS_Bounce to public;
GO


