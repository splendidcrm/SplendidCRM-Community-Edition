
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
-- 04/21/2006 Paul.  RELATED_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  EMAILMAN_NUMBER was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  TEMPLATE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_EMAIL was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_NAME was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  INVALID_EMAIL was dropped in SugarCRM 4.0.
-- 01/13/2008 Paul.  Add INBOUND_EMAIL_ID so that the email manager can be used to send out AutoReplies. 
-- INBOUND_EMAIL_ID Should only be set by the AutoReply system. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'RELATED_ID') begin -- then
	print 'alter table EMAILMAN add RELATED_ID uniqueidentifier null';
	alter table EMAILMAN add RELATED_ID uniqueidentifier null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'RELATED_TYPE') begin -- then
	print 'alter table EMAILMAN add RELATED_TYPE nvarchar(100) null';
	alter table EMAILMAN add RELATED_TYPE nvarchar(100) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'EMAILMAN_NUMBER') begin -- then
	print 'alter table EMAILMAN add EMAILMAN_NUMBER int not null identity(1, 1)';
	alter table EMAILMAN add EMAILMAN_NUMBER int not null identity(1, 1);
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'TEMPLATE_ID') begin -- then
	print 'alter table EMAILMAN drop constraint FK_EMAILMAN_TEMPLATE_ID';
	alter table EMAILMAN drop constraint FK_EMAILMAN_TEMPLATE_ID;
	print 'alter table EMAILMAN drop column TEMPLATE_ID';
	alter table EMAILMAN drop column TEMPLATE_ID;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'FROM_EMAIL') begin -- then
	print 'alter table EMAILMAN drop column FROM_EMAIL';
	alter table EMAILMAN drop column FROM_EMAIL;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'FROM_NAME') begin -- then
	print 'alter table EMAILMAN drop column FROM_NAME';
	alter table EMAILMAN drop column FROM_NAME;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'MODULE_ID') begin -- then
	print 'alter table EMAILMAN drop column MODULE_ID';
	alter table EMAILMAN drop column MODULE_ID;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'MODULE') begin -- then
	print 'alter table EMAILMAN drop column MODULE';
	alter table EMAILMAN drop column MODULE;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'INVALID_EMAIL') begin -- then
	print 'alter table EMAILMAN drop column INVALID_EMAIL';
	--alter table EMAILMAN drop column INVALID_EMAIL;
	-- 04/22/2006 Paul.  Use procedure because this field has a default constraint. 
	exec dbo.spSqlTableDropColumn 'EMAILMAN', 'INVALID_EMAIL';
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'INBOUND_EMAIL_ID') begin -- then
	print 'alter table EMAILMAN add INBOUND_EMAIL_ID uniqueidentifier null';
	alter table EMAILMAN add INBOUND_EMAIL_ID uniqueidentifier null;
end -- if;
GO


-- 07/25/2009 Paul.  EMAILMAN_NUMBER is now a string. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'EMAILMAN_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
	print 'Change EMAILMAN.EMAILMAN_NUMBER to nvarchar.';
	if exists (select * from sys.indexes where name = 'IDX_EMAILMAN_NUMBER') begin -- then
		drop index IDX_EMAILMAN_NUMBER on EMAILMAN;
	end -- if;

	declare @CURRENT_VALUE int;
	select @CURRENT_VALUE = max(EMAILMAN_NUMBER)
	  from EMAILMAN;
	-- 08/06/2009 Paul.  @CURRENT_VALUE cannot be null, so only insert if it has a value. 
	if @CURRENT_VALUE is not null begin -- then
		if exists (select * from NUMBER_SEQUENCES where NAME = 'EMAILMAN.EMAILMAN_NUMBER') begin -- then
			update NUMBER_SEQUENCES
			   set CURRENT_VALUE = @CURRENT_VALUE
			 where NAME = 'EMAILMAN.EMAILMAN_NUMBER';
		end else begin
			insert into NUMBER_SEQUENCES (ID, NAME, CURRENT_VALUE)
			values (newid(), 'EMAILMAN.EMAILMAN_NUMBER', @CURRENT_VALUE);
		end -- if;
	end -- if;

	exec sp_rename 'EMAILMAN.EMAILMAN_NUMBER', 'EMAILMAN_NUMBER_INT', 'COLUMN';
	exec ('alter table EMAILMAN add EMAILMAN_NUMBER nvarchar(30) null');
	exec ('update EMAILMAN set EMAILMAN_NUMBER = cast(EMAILMAN_NUMBER_INT as nvarchar(30))');
	exec ('alter table EMAILMAN drop column EMAILMAN_NUMBER_INT');
	
	exec ('create index IDX_EMAILMAN_NUMBER          on dbo.EMAILMAN (EMAILMAN_NUMBER)');
end -- if;
GO

-- 08/08/2009 Paul.  We also need to change the field in the audit table. 
-- 11/01/2015 Paul.  There is no EMAILMAN_AUDIT table. 
-- if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN_AUDIT' and COLUMN_NAME = 'EMAILMAN_NUMBER' and DATA_TYPE <> 'nvarchar') begin -- then
-- 	print 'Change EMAILMAN_AUDIT.EMAILMAN_NUMBER to nvarchar.';
-- 	exec sp_rename 'EMAILMAN_AUDIT.EMAILMAN_NUMBER', 'EMAILMAN_NUMBER_INT', 'COLUMN';
-- 	exec ('alter table EMAILMAN_AUDIT add EMAILMAN_NUMBER nvarchar(30) null');
-- 	exec ('update EMAILMAN_AUDIT set EMAILMAN_NUMBER = cast(EMAILMAN_NUMBER_INT as nvarchar(30))');
-- 	exec ('alter table EMAILMAN_AUDIT drop column EMAILMAN_NUMBER_INT');
-- end -- if;

-- 11/01/2015 Paul.  Include COMPUTED_EMAIL1 in table to increase performance of dup removal. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILMAN' and COLUMN_NAME = 'COMPUTED_EMAIL1') begin -- then
	print 'alter table EMAILMAN add COMPUTED_EMAIL1 nvarchar(100) null';
	alter table EMAILMAN add COMPUTED_EMAIL1 nvarchar(100) null;
	exec ('create index IDX_EMAILMAN_COMPUTED_EMAIL1 on dbo.EMAILMAN (COMPUTED_EMAIL1)');
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_EMAILMAN_DELETED_CAMPAIGN') begin -- then
	print 'create index IDX_EMAILMAN_DELETED_CAMPAIGN';
	create index IDX_EMAILMAN_DELETED_CAMPAIGN on dbo.EMAILMAN (DELETED, CAMPAIGN_ID, RELATED_TYPE)
end -- if;
GO

-- 02/11/2017 Paul.  New index based on missing indexes query. 
if not exists (select * from sys.indexes where name = 'IDX_EMAILMAN_DELETED_RELATED') begin -- then
	print 'create index IDX_EMAILMAN_DELETED_RELATED';
	create index IDX_EMAILMAN_DELETED_RELATED  on dbo.EMAILMAN (DELETED, RELATED_TYPE, CAMPAIGN_ID)
end -- if;
GO

