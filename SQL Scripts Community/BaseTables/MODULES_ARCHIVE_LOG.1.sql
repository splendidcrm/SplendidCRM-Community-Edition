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
-- 02/17/2018 Paul.  Add ARCHIVE_RULE_ID. 
-- drop table MODULES_ARCHIVE_LOG;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'MODULES_ARCHIVE_LOG' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.MODULES_ARCHIVE_LOG';
	Create Table dbo.MODULES_ARCHIVE_LOG
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_MODULES_ARCHIVE_LOG primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, MODULE_NAME                        nvarchar(25) null
		, TABLE_NAME                         nvarchar(50) null
		, ARCHIVE_RULE_ID                    uniqueidentifier null
		, ARCHIVE_ACTION                     nvarchar(25) null
		, ARCHIVE_TOKEN                      varchar(255) null
		, ARCHIVE_RECORD_ID                  uniqueidentifier null
		)

	create index IDX_MODULES_ARCHIVE_LOG on dbo.MODULES_ARCHIVE_LOG (MODULE_NAME, ARCHIVE_ACTION)
	create index IDX_MODULES_ARCHIVE_LOG_ACTION on dbo.MODULES_ARCHIVE_LOG (ARCHIVE_ACTION, MODULE_NAME)
  end
GO

