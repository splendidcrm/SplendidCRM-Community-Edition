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
-- 04/21/2006 Paul.  Added in SugarCRM 4.2.
-- 07/25/2009 Paul.  TRACKER_KEY is now a string. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CAMPAIGN_TRKRS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.CAMPAIGN_TRKRS';
	Create Table dbo.CAMPAIGN_TRKRS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_CAMPAIGN_TRKRS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TRACKER_NAME                       nvarchar( 30) null
		, TRACKER_URL                        nvarchar(255) null default('http://')
		, TRACKER_KEY                        nvarchar( 30) null
		, CAMPAIGN_ID                        uniqueidentifier null
		, IS_OPTOUT                          bit null default(0)
		)

	create index IDX_CAMPAIGN_TRKRS_TRACKER_KEY on dbo.CAMPAIGN_TRKRS (TRACKER_KEY, ID, DELETED)

	alter table dbo.CAMPAIGN_TRKRS add constraint FK_CAMPAIGN_TRKRS_CAMPAIGN_ID foreign key ( CAMPAIGN_ID) references dbo.CAMPAIGNS ( ID )
  end
GO


