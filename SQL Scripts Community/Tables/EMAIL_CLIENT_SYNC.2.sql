
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
-- 07/24/2010 Paul.  Instead of managing collation in code, it is better to change the collation on the field in the database. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS_SYNC' and COLUMN_NAME = 'REMOTE_KEY' and COLLATION_NAME = 'SQL_Latin1_General_CP1_CI_AS') begin -- then
	print 'alter table EMAILS_SYNC alter column REMOTE_KEY varchar(800) collate SQL_Latin1_General_CP1_CS_AS not null';

	if exists (select * from sys.indexes where name = 'IDX_EMAILS_SYNC_REMOTE_KEY') begin -- then
		drop index IDX_EMAILS_SYNC_REMOTE_KEY on EMAILS_SYNC;
	end -- if;

	alter table EMAILS_SYNC alter column REMOTE_KEY varchar(800) collate SQL_Latin1_General_CP1_CS_AS not null;

	create index IDX_EMAILS_SYNC_REMOTE_KEY on dbo.EMAILS_SYNC (ASSIGNED_USER_ID, DELETED, REMOTE_KEY, LOCAL_ID);
end -- if;
GO

-- 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAILS_SYNC' and COLUMN_NAME = 'REMOTE_KEY') begin -- then
	if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_CLIENT_SYNC') begin -- then
		if not exists(select * from EMAIL_CLIENT_SYNC) begin -- then
			drop table EMAIL_CLIENT_SYNC;
		end -- if;
	end -- if;
	-- 08/31/2010 Paul.  Delete the old procedures and views. 
	if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_SYNC_Delete' and ROUTINE_TYPE = 'PROCEDURE') begin -- then
		Drop Procedure dbo.spEMAILS_SYNC_Delete;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_SYNC_Update' and ROUTINE_TYPE = 'PROCEDURE') begin -- then
		Drop Procedure dbo.spEMAILS_SYNC_Update;
	end -- if;
	if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILS_SYNC') begin -- then
		Drop View dbo.vwEMAILS_SYNC;
	end -- if;

	-- 10/21/2010 Paul.  Drop and recreate the indexes so that the name will be consistent. 
	if exists (select * from sys.indexes where name = 'IDX_EMAILS_SYNC_DATE_MODIFIED') begin -- then
		drop index IDX_EMAILS_SYNC_DATE_MODIFIED on dbo.EMAILS_SYNC;
	end -- if;
	if exists (select * from sys.indexes where name = 'IDX_EMAILS_SYNC_REMOTE_KEY') begin -- then
		drop index IDX_EMAILS_SYNC_REMOTE_KEY    on dbo.EMAILS_SYNC;
	end -- if;
	alter table dbo.EMAILS_SYNC drop constraint PK_EMAILS_SYNC;

	print 'Rename EMAILS_SYNC to EMAIL_CLIENT_SYNC';
	exec sp_rename 'EMAILS_SYNC', 'EMAIL_CLIENT_SYNC';

	alter table EMAIL_CLIENT_SYNC add constraint PK_EMAIL_CLIENT_SYNC primary key ( ID );

	create index IDX_EMAIL_CLIENT_SYNC_DATE_MODIFIED on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, MODULE_NAME, PARENT_ID, REMOTE_DATE_MODIFIED_UTC);
	create index IDX_EMAIL_CLIENT_SYNC_REMOTE_KEY    on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, REMOTE_KEY, LOCAL_ID);
end -- if;
GO

-- 10/21/2010 Paul.  Drop and recreate the indexes so that the name will be consistent. 
if exists (select * 
             from      sys.indexes
            inner join sysobjects
                    on sysobjects.id = sys.indexes.object_id
            where sys.indexes.name = 'PK_EMAILS_SYNC'
              and sysobjects.name  = 'EMAIL_CLIENT_SYNC'
          ) begin -- then
	print 'rename primary key PK_EMAILS_SYNC';
	alter table dbo.EMAIL_CLIENT_SYNC drop constraint PK_EMAILS_SYNC;
	alter table EMAIL_CLIENT_SYNC add constraint PK_EMAIL_CLIENT_SYNC primary key ( ID );
end -- if;
GO

if exists (select * 
             from      sys.indexes
            inner join sysobjects
                    on sysobjects.id = sys.indexes.object_id
            where sys.indexes.name = 'IDX_EMAILS_SYNC_DATE_MODIFIED'
              and sysobjects.name  = 'EMAIL_CLIENT_SYNC'
          ) begin -- then
	print 'rename index IDX_EMAILS_SYNC_DATE_MODIFIED';
	drop index IDX_EMAILS_SYNC_DATE_MODIFIED on EMAIL_CLIENT_SYNC;
	create index IDX_EMAIL_CLIENT_SYNC_DATE_MODIFIED on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, MODULE_NAME, PARENT_ID, REMOTE_DATE_MODIFIED_UTC);
end -- if;
GO

if exists (select * 
             from      sys.indexes
            inner join sysobjects
                    on sysobjects.id = sys.indexes.object_id
            where sys.indexes.name = 'IDX_EMAILS_SYNC_REMOTE_KEY'
              and sysobjects.name  = 'EMAIL_CLIENT_SYNC'
          ) begin -- then
	print 'rename index IDX_EMAILS_SYNC_REMOTE_KEY';
	drop index IDX_EMAILS_SYNC_REMOTE_KEY on EMAIL_CLIENT_SYNC;
	create index IDX_EMAIL_CLIENT_SYNC_REMOTE_KEY    on dbo.EMAIL_CLIENT_SYNC (ASSIGNED_USER_ID, DELETED, REMOTE_KEY, LOCAL_ID);
end -- if;
GO

