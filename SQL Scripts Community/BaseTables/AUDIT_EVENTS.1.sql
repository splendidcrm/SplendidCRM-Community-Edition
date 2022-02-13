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
-- 01/20/2010 Paul.  We don't need any default values as this table will be populated by values from WORKFLOW_EVENTS. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AUDIT_EVENTS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.AUDIT_EVENTS';
	Create Table dbo.AUDIT_EVENTS
		( ID                                 uniqueidentifier not null constraint PK_AUDIT_EVENTS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, AUDIT_ID                           uniqueidentifier not null
		, AUDIT_TABLE                        nvarchar(50) not null
		, AUDIT_TOKEN                        varchar(255) null
		, AUDIT_ACTION                       int null
		, AUDIT_PARENT_ID                    uniqueidentifier null
		)
  end
GO


