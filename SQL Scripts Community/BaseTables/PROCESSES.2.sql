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
-- Drop Table PROCESSES;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROCESSES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PROCESSES';
	Create Table dbo.PROCESSES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_PROCESSES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PROCESS_NUMBER                     int null
		, BUSINESS_PROCESS_INSTANCE_ID       uniqueidentifier not null
		, ACTIVITY_INSTANCE                  nvarchar(100) not null
		, ACTIVITY_NAME                      nvarchar(200) null
		, BUSINESS_PROCESS_ID                uniqueidentifier null
		, PROCESS_USER_ID                    uniqueidentifier null
		, BOOKMARK_NAME                      nvarchar(100) null
		, PARENT_TYPE                        nvarchar(50) null
		, PARENT_ID                          uniqueidentifier null
		, USER_TASK_TYPE                     nvarchar(50) null
		, CHANGE_ASSIGNED_USER               bit null
		, CHANGE_ASSIGNED_TEAM_ID            uniqueidentifier null
		, CHANGE_PROCESS_USER                bit null
		, CHANGE_PROCESS_TEAM_ID             uniqueidentifier null
		, USER_ASSIGNMENT_METHOD             nvarchar(50) null
		, STATIC_ASSIGNED_USER_ID            uniqueidentifier null
		, DYNAMIC_PROCESS_TEAM_ID            uniqueidentifier null
		, DYNAMIC_PROCESS_ROLE_ID            uniqueidentifier null
		, READ_ONLY_FIELDS                   nvarchar(max) null
		, REQUIRED_FIELDS                    nvarchar(max) null
		, DURATION_UNITS                     nvarchar(50) null
		, DURATION_VALUE                     int null
		, STATUS                             nvarchar(50) null
		, APPROVAL_USER_ID                   uniqueidentifier null
		, APPROVAL_DATE                      datetime null
		, APPROVAL_RESPONSE                  nvarchar(100) null
		)

	-- drop index IDX_BPM_APPROVALS_PARENT_ID on PROCESSES
	create index IDX_BPM_APPROVALS_DATE        on PROCESSES (DATE_MODIFIED, PARENT_ID, PROCESS_USER_ID, DELETED)
	create index IDX_BPM_APPROVALS_PARENT_ID   on PROCESSES (PARENT_ID, DELETED, APPROVAL_USER_ID, STATUS)
	create index IDX_BPM_APPROVALS_INSTANCE_ID on PROCESSES (BUSINESS_PROCESS_INSTANCE_ID, ACTIVITY_INSTANCE)
	create index IDX_BPM_APPROVALS_MY_LIST     on PROCESSES (PROCESS_USER_ID, DELETED, STATUS, APPROVAL_USER_ID, USER_ASSIGNMENT_METHOD)
  end
GO

