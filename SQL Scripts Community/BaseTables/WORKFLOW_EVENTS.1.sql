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
-- 03/06/2008 Paul.  All tables should have MODIFIED_USER_ID and DATE_MODIFIED.
-- 07/26/2008 Paul.  Add AUDIT_ACTION to speed workflow processing. 
-- drop table WORKFLOW_EVENTS;
-- 12/03/2008 Paul.  AUDIT_PARENT_ID is needed to roll-up events within a transaction. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'WORKFLOW_EVENTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.WORKFLOW_EVENTS';
	Create Table dbo.WORKFLOW_EVENTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_WORKFLOW_EVENTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, AUDIT_VERSION                      rowversion not null
		, AUDIT_ID                           uniqueidentifier not null
		, AUDIT_TABLE                        nvarchar(50) not null
		, AUDIT_TOKEN                        varchar(255) null
		, AUDIT_ACTION                       int null
		, AUDIT_PARENT_ID                    uniqueidentifier null
		)
  end
GO


