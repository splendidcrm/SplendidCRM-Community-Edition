
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
-- 04/12/2016 Paul.  Add parent team and custom fields. 
-- 04/28/2016 Paul.  Rename parent to PARENT_ID. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TEAMS' and COLUMN_NAME = 'PARENT_TEAM_ID') begin -- then
	print 'alter table TEAMS add PARENT_TEAM_ID uniqueidentifier null';
	print 'rename TEAMS.PARENT_TEAM_ID to TEAMS.PARENT_ID';
	exec sp_rename 'TEAMS.PARENT_TEAM_ID', 'PARENT_ID', 'COLUMN';
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'TEAMS' and COLUMN_NAME = 'PARENT_ID') begin -- then
	print 'alter table TEAMS add PARENT_ID uniqueidentifier null';
	alter table TEAMS add PARENT_ID uniqueidentifier null;
end -- if;
GO

