
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
-- 04/21/2008 Paul.  SugarCRM 5.0 migration. Allow nulls. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CURRENCIES' and COLUMN_NAME = 'CREATED_BY' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table CURRENCIES alter column CREATED_BY uniqueidentifier null';
	alter table CURRENCIES alter column CREATED_BY uniqueidentifier null;
end -- if;
GO

-- 04/30/2016 Paul.  Add reference to log entry that modified the record. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CURRENCIES' and COLUMN_NAME = 'SYSTEM_CURRENCY_LOG_ID') begin -- then
	print 'alter table CURRENCIES alter column SYSTEM_CURRENCY_LOG_ID uniqueidentifier null';
	alter table CURRENCIES add SYSTEM_CURRENCY_LOG_ID uniqueidentifier null;
end -- if;
GO

