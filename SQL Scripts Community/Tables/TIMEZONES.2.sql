
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
-- 01/02/2012 Paul.  Add iCal TZID. 
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TIMEZONES' and COLUMN_NAME = 'TZID') begin -- then
	print 'alter table TIMEZONES add TZID nvarchar(50) null';
	alter table TIMEZONES add TZID nvarchar(50) null;
end -- if;
GO

-- 03/26/2013 Paul.  iCloud uses linked_timezone values from http://tzinfo.rubyforge.org/doc/. 
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TIMEZONES' and COLUMN_NAME = 'LINKED_TIMEZONE') begin -- then
	print 'alter table TIMEZONES add LINKED_TIMEZONE nvarchar(50) null';
	alter table TIMEZONES add LINKED_TIMEZONE nvarchar(50) null;
end -- if;
GO


