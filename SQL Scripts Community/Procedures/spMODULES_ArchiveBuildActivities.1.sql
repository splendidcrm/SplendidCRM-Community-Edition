if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveBuildActivities' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveBuildActivities;
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
-- 01/31/2019 Paul.  Ease conversion to Oracle. 
-- 02/08/2020 Paul.  Include Audit tables. 
Create Procedure dbo.spMODULES_ArchiveBuildActivities
	( @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @TABLE_NAME          nvarchar(80);
	declare @CUSTOM_NAME         nvarchar(80);
	-- 02/08/2020 Paul.  Include Audit tables. 
	declare @AUDIT_TABLE_NAME    nvarchar(80);
	declare @AUDIT_CUSTOM_NAME   nvarchar(80);
	declare @ARCHIVE_DATABASE    nvarchar(50);
	set @ARCHIVE_DATABASE   = dbo.fnCONFIG_String('Archive.Database');

-- #if SQL_Server /*
	declare MODULES_ARCHIVE_ACTIVITIES_CURSOR cursor for
	select RELATED_TABLE
	  from vwMODULES_ARCHIVE_RELATED
	 where MODULE_NAME = 'Activities'
	 order by RELATED_ORDER;
-- #endif SQL_Server */
	
	open MODULES_ARCHIVE_ACTIVITIES_CURSOR;
	fetch next from MODULES_ARCHIVE_ACTIVITIES_CURSOR into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
		-- 02/08/2020 Paul.  Include Audit tables. 
		set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
		set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';

		-- 10/22/2017 Paul.  Only build if module is enabled. 
		if exists(select * from MODULES where TABLE_NAME = @TABLE_NAME and MODULE_ENABLED = 1 and DELETED = 0) begin -- then
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
			exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
			exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
			exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
			exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
			exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
			exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
		end -- if;
		fetch next from MODULES_ARCHIVE_ACTIVITIES_CURSOR into @TABLE_NAME;
	end -- while;
	close MODULES_ARCHIVE_ACTIVITIES_CURSOR;
	deallocate MODULES_ARCHIVE_ACTIVITIES_CURSOR;

	exec dbo.spSqlBuildArchiveActivityView @ARCHIVE_DATABASE;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveBuildActivities to public;
GO

