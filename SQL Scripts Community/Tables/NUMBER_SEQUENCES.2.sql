
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
-- 01/12/2010 Paul.  Oracle does not like allowing an empty string in a not null field. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NUMBER_SEQUENCES' and COLUMN_NAME = 'ALPHA_PREFIX' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table NUMBER_SEQUENCES alter column ALPHA_PREFIX nvarchar(10) null';
	alter table NUMBER_SEQUENCES alter column ALPHA_PREFIX nvarchar(10) null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NUMBER_SEQUENCES' and COLUMN_NAME = 'ALPHA_SUFFIX' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table NUMBER_SEQUENCES alter column ALPHA_SUFFIX nvarchar(10) null';
	alter table NUMBER_SEQUENCES alter column ALPHA_SUFFIX nvarchar(10) null;
end -- if;
GO

