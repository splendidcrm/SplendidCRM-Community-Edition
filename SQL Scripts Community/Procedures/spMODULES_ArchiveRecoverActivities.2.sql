if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveRecoverActivities' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveRecoverActivities;
GO


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
-- 05/02/2018 Paul.  List is not paginated. 
-- 02/08/2020 Paul.  Include Audit tables. 
Create Procedure dbo.spMODULES_ArchiveRecoverActivities
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MODULE_NAME       nvarchar(25)
	, @ID_LIST           varchar(max)
	)
as
  begin
	set nocount on

	declare @TABLE_NAME           nvarchar(80);
	declare @RELATED_TABLE_NAME   nvarchar(80);
	declare @RELATED_CUSTOM_NAME  nvarchar(80);
	declare @RELATED_FIELD_NAME   nvarchar(80);
	-- 02/08/2020 Paul.  Include Audit tables. 
	declare @AUDIT_RELATED_TABLE_NAME    nvarchar(80);
	declare @AUDIT_RELATED_CUSTOM_NAME   nvarchar(80);
	declare @BIND_TOKEN           nvarchar(255);
	declare @ARCHIVE_DATABASE     nvarchar(50);
	declare @EXISTS               bit;
	declare @RELATED_ARCHIVE      nvarchar(90);
	set @ARCHIVE_DATABASE = dbo.fnCONFIG_String('Archive.Database');

	select @TABLE_NAME = TABLE_NAME
	  from MODULES
	 where MODULE_NAME    = @MODULE_NAME
	   and MODULE_ENABLED = 1
	   and DELETED        = 0;

	if len(@ID_LIST) = 0 begin -- then
		raiserror(N'List of IDs is empty.', 16, 1);
	end else if @TABLE_NAME is not null begin -- then
		exec dbo.spSqlGetTransactionToken @BIND_TOKEN out;
-- #if SQL_Server /*
		declare MODULES_ARCHIVE_ACTIVITIES_CURSOR cursor for
		select RELATED_TABLE
		  from vwMODULES_ARCHIVE_RELATED
		 where MODULE_NAME = 'Activities'
		 order by RELATED_ORDER;
-- #endif SQL_Server */
		
		open MODULES_ARCHIVE_ACTIVITIES_CURSOR;
		fetch next from MODULES_ARCHIVE_ACTIVITIES_CURSOR into @RELATED_TABLE_NAME;
		while @@FETCH_STATUS = 0 begin -- do
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'PARENT_ID';
			-- 11/18/2017 Paul.  Activities module may be disabled, so check if archive table exists first. 
			set @RELATED_ARCHIVE     = @RELATED_TABLE_NAME + '_ARCHIVE';
			exec dbo.spSqlTableExists @EXISTS out, @RELATED_ARCHIVE, @ARCHIVE_DATABASE;
			if @EXISTS = 1 begin -- then
				-- 09/26/2017 Paul.  Must move custom data first before the parent record is deleted. 
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
				exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, @TABLE_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, @TABLE_NAME, @ARCHIVE_DATABASE;
			end -- if;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			set @RELATED_ARCHIVE           = @RELATED_TABLE_NAME + '_AUDIT_ARCHIVE';
			exec dbo.spSqlTableExists @EXISTS out, @RELATED_ARCHIVE, @ARCHIVE_DATABASE;
			if @EXISTS = 1 begin -- then
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
				exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, @TABLE_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, @TABLE_NAME, @ARCHIVE_DATABASE;
			end -- if;
			fetch next from MODULES_ARCHIVE_ACTIVITIES_CURSOR into @RELATED_TABLE_NAME;
		end -- while;
		close MODULES_ARCHIVE_ACTIVITIES_CURSOR;
		deallocate MODULES_ARCHIVE_ACTIVITIES_CURSOR;

		-- 09/27/2017 Paul.  We want to prevent recovered records from generating workflow events, so delete the events after they are created. 
		delete from WORKFLOW_EVENTS
		 where AUDIT_TOKEN = @BIND_TOKEN;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveRecoverActivities to public;
GO

