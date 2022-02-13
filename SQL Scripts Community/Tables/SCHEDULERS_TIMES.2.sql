
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
-- 04/21/2008 Paul.  SugarCRM uses the field name SCHEDULER_ID and we use SCHEDULE_ID. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SCHEDULERS_TIMES' and COLUMN_NAME = 'SCHEDULE_ID') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SCHEDULERS_TIMES' and COLUMN_NAME = 'SCHEDULER_ID') begin -- then
		print 'alter table SCHEDULERS_TIMES rename SCHEDULER_ID to SCHEDULE_ID';
		exec sp_rename 'SCHEDULERS_TIMES.SCHEDULER_ID', 'SCHEDULE_ID', 'COLUMN';
	end -- if;
end -- if;
GO

