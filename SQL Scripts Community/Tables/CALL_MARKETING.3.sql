
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
-- 11/29/2017 Paul.  Add TEAM_SET_ID. 
-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 

-- 11/29/2017 Paul.  Add TEAM_SET_ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALL_MARKETING' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
	print 'alter table CALL_MARKETING add TEAM_SET_ID uniqueidentifier null';
	alter table CALL_MARKETING add TEAM_SET_ID uniqueidentifier null;

	-- 08/31/2009 Paul.  Add index for TEAM_SET_ID as we will soon filter on it.
	create index IDX_CALL_MARKETING_TEAM_SET_ID on dbo.CALL_MARKETING (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALL_MARKETING_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALL_MARKETING_AUDIT' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then
		print 'alter table CALL_MARKETING_AUDIT add TEAM_SET_ID uniqueidentifier null';
		alter table CALL_MARKETING_AUDIT add TEAM_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

-- 11/29/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALL_MARKETING' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
	print 'alter table CALL_MARKETING add ASSIGNED_SET_ID uniqueidentifier null';
	alter table CALL_MARKETING add ASSIGNED_SET_ID uniqueidentifier null;

	create index IDX_CALL_MARKETING_ASSIGNED_SET_ID on dbo.CALL_MARKETING (ASSIGNED_SET_ID, DELETED, ID)
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'CALL_MARKETING_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CALL_MARKETING_AUDIT' and COLUMN_NAME = 'ASSIGNED_SET_ID') begin -- then
		print 'alter table CALL_MARKETING_AUDIT add ASSIGNED_SET_ID uniqueidentifier null';
		alter table CALL_MARKETING_AUDIT add ASSIGNED_SET_ID uniqueidentifier null;
	end -- if;
end -- if;
GO

