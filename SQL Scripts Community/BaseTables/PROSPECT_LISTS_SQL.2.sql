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
-- 01/14/2010 Paul.  This table will not have a default primary key. 
-- We will use the same ID as the matching PROSPECT_LISTS record. 
-- drop table dbo.PROSPECT_LISTS_SQL;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECT_LISTS_SQL' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PROSPECT_LISTS_SQL';
	Create Table dbo.PROSPECT_LISTS_SQL
		( ID                                 uniqueidentifier not null constraint PK_PROSPECT_LISTS_SQL primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime not null default(getutcdate())

		, DYNAMIC_SQL                        nvarchar(max) null
		, DYNAMIC_RDL                        nvarchar(max) null
		)

  end
GO


