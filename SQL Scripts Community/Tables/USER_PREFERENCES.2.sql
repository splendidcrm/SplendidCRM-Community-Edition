
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
-- 04/21/2008 Paul.  SugarCRM uses the field name CONTENTS and we use CONTENT. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USER_PREFERENCES' and COLUMN_NAME = 'CONTENT') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USER_PREFERENCES' and COLUMN_NAME = 'CONTENTS') begin -- then
		print 'alter table USER_PREFERENCES rename CONTENTS to CONTENT';
		exec sp_rename 'USER_PREFERENCES.CONTENTS', 'CONTENT', 'COLUMN';
	end -- if;
end -- if;
GO

-- 11/17/2009 Paul.  We have added DATE_MODIFIED_UTC to tables that are sync'd. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'USER_PREFERENCES' and COLUMN_NAME = 'DATE_MODIFIED_UTC') begin -- then
	print 'alter table USER_PREFERENCES add DATE_MODIFIED_UTC datetime null default(getutcdate())';
	alter table USER_PREFERENCES add DATE_MODIFIED_UTC datetime null default(getutcdate());
end -- if;
GO

