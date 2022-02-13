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
-- 04/21/2006 Paul.  INBOUND_EMAIL_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  STATUS was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ALL_PROSPECT_LISTS was added in SugarCRM 4.0.
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_MARKETING' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAIL_MARKETING';
	Create Table dbo.EMAIL_MARKETING
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAIL_MARKETING primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(255) null
		, FROM_ADDR                          nvarchar(100) null
		, FROM_NAME                          nvarchar(100) null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, TEMPLATE_ID                        uniqueidentifier null
		, CAMPAIGN_ID                        uniqueidentifier null
		, INBOUND_EMAIL_ID                   uniqueidentifier null
		, STATUS                             nvarchar(25) null
		, ALL_PROSPECT_LISTS                 bit null default(0)
		, REPLY_TO_NAME                      nvarchar(100) null
		, REPLY_TO_ADDR                      nvarchar(100) null
		)

	create index IDX_EMAIL_MARKETING_NAME  on dbo.EMAIL_MARKETING (NAME   )
	create index IDX_EMAIL_MARKETING       on dbo.EMAIL_MARKETING (DELETED)

	alter table dbo.EMAIL_MARKETING add constraint FK_EMAIL_MARKETING_TEMPLATE_ID foreign key ( TEMPLATE_ID ) references dbo.EMAIL_TEMPLATES ( ID )
	alter table dbo.EMAIL_MARKETING add constraint FK_EMAIL_MARKETING_CAMPAIGN_ID foreign key ( CAMPAIGN_ID ) references dbo.CAMPAIGNS       ( ID )
  end
GO

