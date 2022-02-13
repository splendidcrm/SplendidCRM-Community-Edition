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
-- 07/16/2005 Paul.  Version 3.0.1 added the OUTLOOK_ID field. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 09/04/2012 Paul.  Version 6.5.4 added REPEAT fields. 
-- 12/25/2012 Paul.  EMAIL_REMINDER_SENT was moved to relationship table so that it can be applied per recipient. 
-- 03/04/2013 Paul.  REPEAT_DOW is a character string of Days of Week. 0 = sunday, 1 = monday, 2 = tuesday, etc. 
-- 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
-- 09/06/2013 Paul.  Increase NAME size to 150 to support Asterisk. 
-- 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
-- 06/07/2017 Paul.  REMINDER_TIME, EMAIL_REMINDER_TIME, SMS_REMINDER_TIME should default to null, not -1.  
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MEETINGS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.MEETINGS';
	Create Table dbo.MEETINGS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_MEETINGS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, NAME                               nvarchar(150) null
		, LOCATION                           nvarchar(50) null
		, DURATION_HOURS                     int null
		, DURATION_MINUTES                   int null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, DATE_END                           datetime null
		, STATUS                             nvarchar(25) null
		, PARENT_TYPE                        nvarchar(25) null
		, PARENT_ID                          uniqueidentifier null
		, REMINDER_TIME                      int null
		, DESCRIPTION                        nvarchar(max) null
		, OUTLOOK_ID                         nvarchar(255) null
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		, EMAIL_REMINDER_TIME                int null
		, SMS_REMINDER_TIME                  int null
		, REPEAT_TYPE                        nvarchar(25) null
		, REPEAT_INTERVAL                    int null default(1)
		, REPEAT_DOW                         nvarchar(7) null
		, REPEAT_UNTIL                       datetime null
		, REPEAT_COUNT                       int null
		, REPEAT_PARENT_ID                   uniqueidentifier null
		, RECURRING_SOURCE                   nvarchar(25) null
		, ALL_DAY_EVENT                      bit null
		, IS_PRIVATE                         bit null
		)

	create index IDX_MEETINGS_NAME                  on dbo.MEETINGS (NAME, DELETED, ID)
	create index IDX_MEETINGS_PARENT_ID_PARENT_TYPE on dbo.MEETINGS (PARENT_ID, PARENT_TYPE, DELETED, ID)
	create index IDX_MEETINGS_ASSIGNED_USER_ID      on dbo.MEETINGS (ASSIGNED_USER_ID, DELETED, ID)
	create index IDX_MEETINGS_TEAM_ID               on dbo.MEETINGS (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_MEETINGS_TEAM_SET_ID           on dbo.MEETINGS (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_MEETINGS_ASSIGNED_SET_ID       on dbo.MEETINGS (ASSIGNED_SET_ID, DELETED, ID)
	-- 03/22/2013 Paul.  Index for updating recurring events. 
	create index IDX_MEETINGS_REPEAT_PARENT_ID      on dbo.MEETINGS (REPEAT_PARENT_ID, DELETED, DATE_START, DATE_MODIFIED_UTC, ID)
  end
GO


