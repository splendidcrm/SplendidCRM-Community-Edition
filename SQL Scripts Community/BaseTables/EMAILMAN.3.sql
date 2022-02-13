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
-- 04/21/2006 Paul.  RELATED_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  EMAILMAN_NUMBER was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  TEMPLATE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_EMAIL was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_NAME was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  INVALID_EMAIL was dropped in SugarCRM 4.0.
-- 04/02/2006 Paul.  MySQL requires an index on an identity column. 
-- 01/13/2008 Paul.  Add INBOUND_EMAIL_ID so that the email manager can be used to send out AutoReplies. 
-- INBOUND_EMAIL_ID Should only be set by the AutoReply system. 
-- 07/25/2009 Paul.  EMAILMAN_NUMBER is now a string. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAILMAN' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAILMAN';
	Create Table dbo.EMAILMAN
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAILMAN primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, EMAILMAN_NUMBER                    nvarchar( 30) null
		, USER_ID                            uniqueidentifier null
		, CAMPAIGN_ID                        uniqueidentifier null
		, MARKETING_ID                       uniqueidentifier null
		, LIST_ID                            uniqueidentifier null
		, SEND_DATE_TIME                     datetime null
		, IN_QUEUE                           bit null default(0)
		, IN_QUEUE_DATE                      datetime null
		, SEND_ATTEMPTS                      int null default(0)
		, RELATED_ID                         uniqueidentifier null
		, RELATED_TYPE                       nvarchar(100) null
		, INBOUND_EMAIL_ID                   uniqueidentifier null
		, COMPUTED_EMAIL1                    nvarchar(100) null
		)

	create index IDX_EMAILMAN_LIST_ID_USER_ID on dbo.EMAILMAN (LIST_ID, USER_ID, DELETED)
	create index IDX_EMAILMAN_CAMPAIGN_ID     on dbo.EMAILMAN (CAMPAIGN_ID)
	create index IDX_EMAILMAN_NUMBER          on dbo.EMAILMAN (EMAILMAN_NUMBER)
	create index IDX_EMAILMAN_COMPUTED_EMAIL1 on dbo.EMAILMAN (COMPUTED_EMAIL1)
	-- 02/11/2017 Paul.  New index based on missing indexes query. 
	create index IDX_EMAILMAN_DELETED_CAMPAIGN on dbo.EMAILMAN (DELETED, CAMPAIGN_ID, RELATED_TYPE)
	create index IDX_EMAILMAN_DELETED_RELATED  on dbo.EMAILMAN (DELETED, RELATED_TYPE, CAMPAIGN_ID)

	alter table dbo.EMAILMAN add constraint FK_EMAILMAN_USER_ID      foreign key ( USER_ID      ) references dbo.USERS           ( ID )
	alter table dbo.EMAILMAN add constraint FK_EMAILMAN_CAMPAIGN_ID  foreign key ( CAMPAIGN_ID  ) references dbo.CAMPAIGNS       ( ID )
	alter table dbo.EMAILMAN add constraint FK_EMAILMAN_MARKETING_ID foreign key ( MARKETING_ID ) references dbo.EMAIL_MARKETING ( ID )
  end
GO

