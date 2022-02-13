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
-- 07/16/2013 Paul.  USER_ID should be nullable so that table can contain system email accounts. 
-- 04/20/2016 Paul.  Add team management to Outbound Emails. 
-- 01/17/2017 Paul.  Increase size of @MAIL_SENDTYPE to fit office365. 
-- drop table dbo.OUTBOUND_EMAILS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OUTBOUND_EMAILS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.OUTBOUND_EMAILS';
	Create Table dbo.OUTBOUND_EMAILS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_OUTBOUND_EMAILS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(50) null default('system')
		, TYPE                               nvarchar(15) null default('user')
		, USER_ID                            uniqueidentifier null
		, MAIL_SENDTYPE                      nvarchar(25) null default('smtp')
		, MAIL_SMTPTYPE                      nvarchar(20) null default('other')
		, MAIL_SMTPSERVER                    nvarchar(100) null
		, MAIL_SMTPPORT                      int null default(0)
		, MAIL_SMTPUSER                      nvarchar(100) null
		, MAIL_SMTPPASS                      nvarchar(100) null
		, MAIL_SMTPAUTH_REQ                  bit null default(0)
		, MAIL_SMTPSSL                       int null default(0)
		, FROM_NAME                          nvarchar(100) null
		, FROM_ADDR                          nvarchar(100) null
		, TEAM_ID                            uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		)

	create index IDX_OUTBOUND_EMAILS_USER_ID on dbo.OUTBOUND_EMAILS (USER_ID, TYPE, DELETED, ID)
  end
GO

