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
-- 07/25/2009 Paul.  We need the number sequences table to be high-performance, 
-- so make sure that nothing is nullable so that we never have to check. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 01/12/2010 Paul.  Oracle does not like allowing an empty string in a not null field. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NUMBER_SEQUENCES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.NUMBER_SEQUENCES';
	Create Table dbo.NUMBER_SEQUENCES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_NUMBER_SEQUENCES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, NAME                               nvarchar(60) not null
		, ALPHA_PREFIX                       nvarchar(10) null default('')
		, ALPHA_SUFFIX                       nvarchar(10) null default('')
		, SEQUENCE_STEP                      int not null default(1)
		, NUMERIC_PADDING                    int not null default(0)
		, CURRENT_VALUE                      int not null default(0)
		)

	create index IDX_NUMBER_SEQUENCES_NAME on dbo.NUMBER_SEQUENCES (NAME, DELETED)
  end
GO

