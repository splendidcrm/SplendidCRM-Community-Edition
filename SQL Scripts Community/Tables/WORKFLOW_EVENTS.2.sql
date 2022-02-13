
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
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'WORKFLOW_EVENTS' and COLUMN_NAME = 'DATE_MODIFIED') begin -- then
	print 'Drop Table WORKFLOW_EVENTS';
	Drop Table dbo.WORKFLOW_EVENTS;

	print 'Create Table dbo.WORKFLOW_EVENTS';
	Create Table dbo.WORKFLOW_EVENTS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_WORKFLOW_EVENTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())

		, AUDIT_VERSION                      rowversion not null
		, AUDIT_ID                           uniqueidentifier not null
		, AUDIT_TABLE                        nvarchar(50) not null
		, AUDIT_TOKEN                        varchar(255) null
		, AUDIT_ACTION                       int null
		)
end -- if;
GO

-- 07/26/2008 Paul.  Add AUDIT_ACTION to speed workflow processing. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'WORKFLOW_EVENTS' and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
	print 'alter table WORKFLOW_EVENTS add AUDIT_ACTION int null';
	alter table WORKFLOW_EVENTS add AUDIT_ACTION int null;
end -- if;
GO

-- 12/03/2008 Paul.  AUDIT_PARENT_ID is needed to roll-up events within a transaction. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'WORKFLOW_EVENTS' and COLUMN_NAME = 'AUDIT_PARENT_ID') begin -- then
	print 'alter table WORKFLOW_EVENTS add AUDIT_PARENT_ID uniqueidentifier null';
	alter table WORKFLOW_EVENTS add AUDIT_PARENT_ID uniqueidentifier null;
end -- if;
GO
