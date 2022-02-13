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
-- drop table SYSTEM_TRANSACTIONS;
-- 10/07/2009 Paul.  This table will be slightly different than all the rest.  
-- We want it to have the same core fields, but in this case the ID field will be generated in the client app. 
-- The goal will be to use the SQL Server 2008 MERGE statement. 
-- http://weblogs.sqlteam.com/mladenp/archive/2007/08/03/60277.aspx
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_TRANSACTIONS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.SYSTEM_TRANSACTIONS';
	Create Table dbo.SYSTEM_TRANSACTIONS
		( ID                                 uniqueidentifier not null
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier not null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, SESSION_SPID                       int not null constraint PK_SYSTEM_TRANSACTIONS primary key
		)
	
	create index IDX_SYSTEM_TRANSACTIONS on dbo.SYSTEM_TRANSACTIONS(SESSION_SPID) include (ID, MODIFIED_USER_ID);
  end
GO


