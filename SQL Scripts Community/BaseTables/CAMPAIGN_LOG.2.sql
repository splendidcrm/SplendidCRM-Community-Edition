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
-- 04/21/2006 Paul.  Added in SugarCRM 4.0.
-- 04/21/2006 Paul.  MORE_INFORMATION was added in SugarCRM 4.2.
-- 09/10/2007 Paul.  MARKETING_ID was added in SugarCRM 4.5.1.
-- 12/20/2007 Paul.  ACTIVITY_DATE should default to now. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CAMPAIGN_LOG' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CAMPAIGN_LOG';
	Create Table dbo.CAMPAIGN_LOG
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CAMPAIGN_LOG primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, CAMPAIGN_ID                        uniqueidentifier null
		, TARGET_TRACKER_KEY                 uniqueidentifier null
		, TARGET_ID                          uniqueidentifier null
		, TARGET_TYPE                        nvarchar(25) null
		, ACTIVITY_TYPE                      nvarchar(25) null
		, ACTIVITY_DATE                      datetime null default(getdate())
		, RELATED_ID                         uniqueidentifier null
		, RELATED_TYPE                       nvarchar(25) null
		, ARCHIVED                           bit null default(0)
		, HITS                               int null default(0)
		, LIST_ID                            uniqueidentifier null
		, MORE_INFORMATION                   nvarchar(100) null
		, MARKETING_ID                       uniqueidentifier null
		)

	create index IDX_CAMPAIGN_LOG_TARGET_TRACKER_KEY on dbo.CAMPAIGN_LOG (TARGET_TRACKER_KEY)
	create index IDX_CAMPAIGN_LOG_CAMPAIGN_ID        on dbo.CAMPAIGN_LOG (CAMPAIGN_ID       )
	create index IDX_CAMPAIGN_LOG_MORE_INFORMATION   on dbo.CAMPAIGN_LOG (RELATED_ID, MORE_INFORMATION, ID)
  end
GO


