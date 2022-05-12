if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_Edit')
	Drop View dbo.vwUSERS_Edit;
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
-- 11/08/2008 Paul.  Move description to base view. 
-- 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
-- 06/02/2016 Paul.  We need SMTP server values. 
-- 01/17/2017 Paul.  Add support for Office 365 OAuth credentials. 
-- 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
-- 01/30/2019 Paul.  Ease conversion to Oracle. 
-- 07/14/2020 Paul.  Create dummy ICLOUD_SECURITY_CODE field just in case it is required. 
-- 02/12/2022 Paul.  Apple now uses OAuth. 
Create View dbo.vwUSERS_Edit
as
select vwUSERS.*
     , dbo.fnFullAddressHtml(vwUSERS.ADDRESS_STREET, vwUSERS.ADDRESS_CITY, vwUSERS.ADDRESS_STATE, vwUSERS.ADDRESS_POSTALCODE, vwUSERS.ADDRESS_COUNTRY) as ADDRESS_HTML
     , OUTBOUND_EMAILS.MAIL_SMTPUSER
     , OUTBOUND_EMAILS.MAIL_SMTPPASS
     , OUTBOUND_EMAILS.MAIL_SMTPSERVER
     , OUTBOUND_EMAILS.MAIL_SMTPPORT
     , OUTBOUND_EMAILS.MAIL_SMTPAUTH_REQ
     , OUTBOUND_EMAILS.MAIL_SMTPSSL
     , (case when OUTBOUND_EMAILS.MAIL_SENDTYPE is null and OUTBOUND_EMAILS.MAIL_SMTPPORT in (25, 465, 587) then N'smtp' else OUTBOUND_EMAILS.MAIL_SENDTYPE end) as MAIL_SENDTYPE
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = vwUSERS.ID and OAUTH_TOKENS.NAME = N'Office365'  and OAUTH_TOKENS.DELETED = 0) as OFFICE365_OAUTH_ENABLED
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = vwUSERS.ID and OAUTH_TOKENS.NAME = N'GoogleApps' and OAUTH_TOKENS.DELETED = 0) as GOOGLEAPPS_OAUTH_ENABLED
     , (select count(*) from OAUTH_TOKENS where OAUTH_TOKENS.ASSIGNED_USER_ID = vwUSERS.ID and OAUTH_TOKENS.NAME = N'iCloud'     and OAUTH_TOKENS.DELETED = 0) as ICLOUD_OAUTH_ENABLED
     , cast(null as nvarchar(25)) as ICLOUD_SECURITY_CODE
  from            vwUSERS
  left outer join USERS
               on USERS.ID = vwUSERS.ID
  left outer join OUTBOUND_EMAILS
               on OUTBOUND_EMAILS.USER_ID         = USERS.ID
              and OUTBOUND_EMAILS.TYPE            = N'system-override'
              and (OUTBOUND_EMAILS.MAIL_SMTPUSER   is not null or OUTBOUND_EMAILS.MAIL_SENDTYPE is not null)
              and OUTBOUND_EMAILS.DELETED         = 0

GO

Grant Select on dbo.vwUSERS_Edit to public;
GO

