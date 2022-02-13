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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILMAN_SENT' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAILMAN_SENT';
	Create Table dbo.EMAILMAN_SENT
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAILMAN_SENT primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, USER_ID                            uniqueidentifier null
		, TEMPLATE_ID                        uniqueidentifier null
		, FROM_EMAIL                         nvarchar(255) null
		, FROM_NAME                          nvarchar(255) null
		, MODULE_ID                          uniqueidentifier null
		, CAMPAIGN_ID                        uniqueidentifier null
		, MARKETING_ID                       uniqueidentifier null
		, LIST_ID                            uniqueidentifier null
		, MODULE                             nvarchar(100) null
		, SEND_DATE_TIME                     datetime null
		, INVALID_EMAIL                      bit null default(0)
		, IN_QUEUE                           bit null default(0)
		, IN_QUEUE_DATE                      datetime null
		, SEND_ATTEMPTS                      int null default(0)
		)

	create index IDX_EMAILMAN_SENT_LIST_ID_USER_ID on dbo.EMAILMAN_SENT (LIST_ID, USER_ID, DELETED)

	alter table dbo.EMAILMAN_SENT add constraint FK_EMAILMAN_SENT_USER_ID      foreign key ( USER_ID      ) references dbo.USERS           ( ID )
	alter table dbo.EMAILMAN_SENT add constraint FK_EMAILMAN_SENT_TEMPLATE_ID  foreign key ( TEMPLATE_ID  ) references dbo.EMAIL_TEMPLATES ( ID )
	alter table dbo.EMAILMAN_SENT add constraint FK_EMAILMAN_SENT_CAMPAIGN_ID  foreign key ( CAMPAIGN_ID  ) references dbo.CAMPAIGNS       ( ID )
	alter table dbo.EMAILMAN_SENT add constraint FK_EMAILMAN_SENT_MARKETING_ID foreign key ( MARKETING_ID ) references dbo.EMAIL_MARKETING ( ID )
  end
GO

