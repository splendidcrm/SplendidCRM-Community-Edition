
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
-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

-- 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SMS_MESSAGES' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
	print 'alter table SMS_MESSAGES add IS_PRIVATE bit null';
	alter table SMS_MESSAGES add IS_PRIVATE bit null;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SMS_MESSAGES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SMS_MESSAGES_AUDIT' and COLUMN_NAME = 'IS_PRIVATE') begin -- then
		print 'alter table SMS_MESSAGES_AUDIT add IS_PRIVATE bit null';
		alter table SMS_MESSAGES_AUDIT add IS_PRIVATE bit null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SMS_MESSAGES' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table SMS_MESSAGES add ASSIGNED_SET_ID uniqueidentifier null';
	alter table SMS_MESSAGES add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_SMS_MESSAGES_ASSIGNED_SET_ID on dbo.SMS_MESSAGES (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SMS_MESSAGES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SMS_MESSAGES_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table SMS_MESSAGES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table SMS_MESSAGES_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

