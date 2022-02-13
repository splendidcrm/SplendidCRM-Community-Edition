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
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 08/21/2009 Paul.  Add support for dynamic teams. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/19/2010 Paul.  Some customers have requested that we allow for fractional efforts. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROJECT_TASK' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PROJECT_TASK';
	Create Table dbo.PROJECT_TASK
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_PROJECT_TASK primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, NAME                               nvarchar(50) not null
		, STATUS                             nvarchar(25) null
		, DATE_DUE                           datetime null
		, TIME_DUE                           datetime null
		, DATE_START                         datetime null
		, TIME_START                         datetime null
		, PARENT_ID                          uniqueidentifier null
		, PRIORITY                           nvarchar(25) null
		, DESCRIPTION                        nvarchar(max) null
		, ORDER_NUMBER                       int null
		, TASK_NUMBER                        int null
		, DEPENDS_ON_ID                      uniqueidentifier null
		, MILESTONE_FLAG                     bit null
		, ESTIMATED_EFFORT                   float null
		, ACTUAL_EFFORT                      float null
		, UTILIZATION                        int null default(100)
		, PERCENT_COMPLETE                   int null default(0)
		, TEAM_SET_ID                        uniqueidentifier null
		, ASSIGNED_SET_ID                    uniqueidentifier null
		)

	create index IDX_PROJECT_TASK_PARENT_ID        on dbo.PROJECT_TASK (PARENT_ID, DELETED, ID)
	create index IDX_PROJECT_TASK_ASSIGNED_USER_ID on dbo.PROJECT_TASK (ASSIGNED_USER_ID, DELETED, ID)
	create index IDX_PROJECT_TASK_TEAM_ID          on dbo.PROJECT_TASK (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_PROJECT_TASK_TEAM_SET_ID      on dbo.PROJECT_TASK (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
	-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	create index IDX_PROJECT_TASK_ASSIGNED_SET_ID  on dbo.PROJECT_TASK (ASSIGNED_SET_ID, DELETED, ID)
  end
GO


