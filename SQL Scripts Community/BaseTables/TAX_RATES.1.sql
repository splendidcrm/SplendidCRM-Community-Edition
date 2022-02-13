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
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 06/02/2012 Paul.  Tax Vendor is required to create a QuickBooks tax rate. 
-- 02/24/2015 Paul.  Add state for lookup. 
-- 04/07/2016 Paul.  Tax rates per team. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TAX_RATES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.TAX_RATES';
	Create Table dbo.TAX_RATES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_TAX_RATES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, TEAM_ID                            uniqueidentifier null
		, NAME                               nvarchar(50) not null
		, STATUS                             nvarchar(25) null
		, ADDRESS_STATE                      nvarchar(100) null
		, VALUE                              money null
		, LIST_ORDER                         int null
		, QUICKBOOKS_TAX_VENDOR              nvarchar(50) null
		, DESCRIPTION                        nvarchar(max) null
		, TEAM_SET_ID                        uniqueidentifier null
		)
  end
GO

