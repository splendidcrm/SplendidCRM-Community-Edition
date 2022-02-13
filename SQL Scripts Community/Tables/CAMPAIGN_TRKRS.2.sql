
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
-- 07/25/2009 Paul.  TRACKER_KEY is now a string. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGN_TRKRS' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CAMPAIGN_TRKRS.TRACKER_KEY to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_CAMPAIGN_TRKRS_TRACKER_KEY') begin -- then
		drop index IDX_CAMPAIGN_TRKRS_TRACKER_KEY on CAMPAIGN_TRKRS;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(TRACKER_KEY)
	  from CAMPAIGN_TRKRS;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'CAMPAIGN_TRKRS.TRACKER_KEY') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'CAMPAIGN_TRKRS.TRACKER_KEY';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'CAMPAIGN_TRKRS.TRACKER_KEY', @CURRENT_VALUE);
		end -- if;
	end -- if;

	exec sp_rename 'CAMPAIGN_TRKRS.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table CAMPAIGN_TRKRS add TRACKER_KEY nvarchar(30) null');
	exec ('update CAMPAIGN_TRKRS set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec ('alter table CAMPAIGN_TRKRS drop column TRACKER_KEY_INT');
	
	exec ('create index IDX_CAMPAIGN_TRKRS_TRACKER_KEY on dbo.CAMPAIGN_TRKRS (TRACKER_KEY, ID, DELETED)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CAMPAIGN_TRKRS_AUDIT' and COLUMN_NAME = 'TRACKER_KEY' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change CAMPAIGN_TRKRS_AUDIT.TRACKER_KEY to nvarchar.';
	exec sp_rename 'CAMPAIGN_TRKRS_AUDIT.TRACKER_KEY', 'TRACKER_KEY_INT', 'COLUMN';
	exec ('alter table CAMPAIGN_TRKRS_AUDIT add TRACKER_KEY nvarchar(30) null');
	exec ('update CAMPAIGN_TRKRS_AUDIT set TRACKER_KEY = cast(TRACKER_KEY_INT as nvarchar(30))');
	exec ('alter table CAMPAIGN_TRKRS_AUDIT drop column TRACKER_KEY_INT');
end -- if;
GO

