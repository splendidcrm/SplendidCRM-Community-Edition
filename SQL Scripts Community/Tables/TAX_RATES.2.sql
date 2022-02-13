
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
-- 06/02/2012 Paul.  Tax Vendor is required to create a QuickBooks tax rate. 
-- 04/07/2016 Paul.  Tax rates per team. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TAX_RATES' and COLUMN_NAME = 'QUICKBOOKS_TAX_VENDOR') begin -- then
	print 'alter table TAX_RATES add QUICKBOOKS_TAX_VENDOR nvarchar(50) null';
	alter table TAX_RATES add QUICKBOOKS_TAX_VENDOR nvarchar(50) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TAX_RATES' and COLUMN_NAME = 'DESCRIPTION') begin -- then
	print 'alter table TAX_RATES add DESCRIPTION nvarchar(max) null';
	alter table TAX_RATES add DESCRIPTION nvarchar(max) null;
end -- if;
GO

-- 02/24/2015 Paul.  Add state for lookup. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TAX_RATES' and COLUMN_NAME = 'ADDRESS_STATE') begin -- then
	print 'alter table TAX_RATES add ADDRESS_STATE nvarchar(100) null';
	alter table TAX_RATES add ADDRESS_STATE nvarchar(100) null;
end -- if;
GO

-- 04/07/2016 Paul.  Tax rates per team. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TAX_RATES' and COLUMN_NAME = 'TEAM_ID') begin -- then
	print 'alter table TAX_RATES add TEAM_ID uniqueidentifier null';
	alter table TAX_RATES add TEAM_ID uniqueidentifier null;

	create index IDX_TAX_RATES_TEAM_ID on dbo.TAX_RATES (TEAM_ID, DELETED, ID)
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TAX_RATES' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table TAX_RATES add TEAM_SET_ID uniqueidentifier null';
	alter table TAX_RATES add TEAM_SET_ID uniqueidentifier null;

	create index IDX_TAX_RATES_TEAM_SET_ID on dbo.TAX_RATES (TEAM_SET_ID, DELETED, ID);
end -- if;
GO

