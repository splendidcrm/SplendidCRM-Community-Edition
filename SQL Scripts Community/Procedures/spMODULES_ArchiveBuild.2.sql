if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveBuild' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveBuild;
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
-- 02/08/2020 Paul.  Include Audit tables. 
-- 04/27/2020 Paul.  Detecting missing columns from activities table was incomplete.  Need to check for missing native columns. 
Create Procedure dbo.spMODULES_ArchiveBuild
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @MODULE_NAME         nvarchar(25);
	declare @TABLE_NAME          nvarchar(80);
	declare @CUSTOM_NAME         nvarchar(80);
	-- 02/08/2020 Paul.  Include Audit tables. 
	declare @AUDIT_TABLE_NAME    nvarchar(80);
	declare @AUDIT_CUSTOM_NAME   nvarchar(80);
	declare @RELATED_MODULE_NAME nvarchar(80);
	declare @ACTIVITY_TABLE_NAME nvarchar(80);
	declare @ARCHIVE_NAME        nvarchar(80);
	declare @MODULE_CHANGED      bit;
	declare @EXISTS              bit;
	declare @MISSING_ACTIVITIES  int;
	declare @ARCHIVE_DATABASE    nvarchar(50);

	set @MODULE_CHANGED = 0;
	set @ARCHIVE_DATABASE = dbo.fnCONFIG_String('Archive.Database');
	if @ARCHIVE_DATABASE is not null begin -- then
		print 'Archive Database = ' + isnull(@ARCHIVE_DATABASE, '');
	end -- if;

	-- 10/22/2017 Paul.  Only build if module is enabled. 
	select @MODULE_NAME = MODULE_NAME
	     , @TABLE_NAME  = TABLE_NAME
	  from MODULES
	 where ID             = @ID
	   and MODULE_ENABLED = 1
	   and DELETED        = 0;
	if @TABLE_NAME is not null begin -- then
		set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
		-- 02/08/2020 Paul.  Include Audit tables. 
		set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
		set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
		-- 10/22/2017 Paul.  Instead of always attempting to build the archive tables, just build when something is missing or changed. 
		exec dbo.spSqlTableColumnsChanged @MODULE_CHANGED out, @TABLE_NAME, @ARCHIVE_DATABASE;
		if @MODULE_CHANGED = 1 begin -- then
			print @MODULE_NAME + ' base table changed.';
		end -- if;
		if @MODULE_CHANGED = 0 begin -- then
			exec dbo.spSqlTableColumnsChanged @EXISTS out, @CUSTOM_NAME, @ARCHIVE_DATABASE;
			if @MODULE_CHANGED = 1 begin -- then
				print @MODULE_NAME + ' custom table changed.';
			end -- if;
		end -- if;

		-- 02/08/2020 Paul.  Include Audit tables. 
		if @MODULE_CHANGED = 0 begin -- then
			exec dbo.spSqlTableColumnsChanged @MODULE_CHANGED out, @AUDIT_TABLE_NAME, @ARCHIVE_DATABASE;
			if @MODULE_CHANGED = 1 begin -- then
				print @MODULE_NAME + ' base audit table changed.';
			end -- if;
		end -- if;
		if @MODULE_CHANGED = 0 begin -- then
			exec dbo.spSqlTableColumnsChanged @EXISTS out, @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
			if @MODULE_CHANGED = 1 begin -- then
				print @MODULE_NAME + ' custom audit table changed.';
			end -- if;
		end -- if;
		if @MODULE_CHANGED = 0 begin -- then
			if exists(select MODULES.MODULE_NAME
			               , max(FIELDS_META_DATA.DATE_MODIFIED   ) as DATE_MODIFIED
			               , max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) as DATE_ARCHIVED
			            from            MODULES
			            left outer join FIELDS_META_DATA
			                         on FIELDS_META_DATA.CUSTOM_MODULE     = MODULES.MODULE_NAME
			            left outer join MODULES_ARCHIVE_LOG
			                         on MODULES_ARCHIVE_LOG.MODULE_NAME    = MODULES.MODULE_NAME
			                        and MODULES_ARCHIVE_LOG.ARCHIVE_ACTION = 'Build'
			           where MODULES.MODULE_NAME in (select MODULE_NAME from dbo.fnArchiveRelatedModules(@MODULE_NAME))
				     and FIELDS_META_DATA.DATE_MODIFIED is not null
			           group by MODULES.MODULE_NAME
			           having max(FIELDS_META_DATA.DATE_MODIFIED) > max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) or max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) is null
			         ) begin -- then
				print @MODULE_NAME + ' related fields changed.';
				set @MODULE_CHANGED = 1;
			end -- if;
		end -- if;

		if @MODULE_CHANGED = 0 begin -- then
			print @MODULE_NAME + ' module has not changed.';
			-- 10/16/2018 Paul.  We may need to add the activities view for this module. 
			if exists(select * from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = @MODULE_NAME and RELATED_NAME = 'Activities') begin -- then
				if not exists(select * from vwSqlViews where VIEW_NAME = 'vw' + @TABLE_NAME + '_ACTIVITIES_ARCHIVE') begin -- then
					print @MODULE_NAME + ' module needs activities view.';
					exec dbo.spSqlBuildArchiveActivitiesView  @MODULE_NAME, @ARCHIVE_DATABASE;
				end -- if;
			end -- if;
		end else if @MODULE_CHANGED = 1 begin -- then
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
			if @TABLE_NAME = 'QUOTES' begin -- then
				set @TABLE_NAME  = 'QUOTES_LINE_ITEMS';
				set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
				exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
				exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

				-- 02/08/2020 Paul.  Include Audit tables. 
				set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
				set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
				exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			end else if @TABLE_NAME = 'ORDERS' begin -- then
				set @TABLE_NAME  = 'ORDERS_LINE_ITEMS';
				set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
				exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
				exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

				-- 02/08/2020 Paul.  Include Audit tables. 
				set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
				set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
				exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			end else if @TABLE_NAME = 'INVOICES' begin -- then
				set @TABLE_NAME  = 'INVOICES_LINE_ITEMS';
				set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
				exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

				-- 02/08/2020 Paul.  Include Audit tables. 
				set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
				set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
				exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			end else if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
				set @TABLE_NAME  = 'REVENUE_LINE_ITEMS';
				set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
				exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
				exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

				-- 02/08/2020 Paul.  Include Audit tables. 
				set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
				set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
				exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			end else if @TABLE_NAME = 'PROJECT' begin -- then
				set @TABLE_NAME  = 'PROJECT_TASK';
				set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
				exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
				exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
				exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
				exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

				-- 02/08/2020 Paul.  Include Audit tables. 
				set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
				set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
				exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
				exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
			end -- if;
			-- 10/16/2018 Paul.  We need to process activities for related modules. 
			if exists(select * from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = @MODULE_NAME and RELATED_NAME = 'Activities') begin -- then
				print @MODULE_NAME + ' module has activities.';
				-- 10/22/2017 Paul.  Instead of always attempting to build the archive tables, just build when something is missing or changed. 
				set @MISSING_ACTIVITIES = 0;
				if exists(select MODULES.MODULE_NAME
				               , max(FIELDS_META_DATA.DATE_MODIFIED   ) as DATE_MODIFIED
				               , max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) as DATE_ARCHIVED
				            from            MODULES
				            left outer join FIELDS_META_DATA
				                         on FIELDS_META_DATA.CUSTOM_MODULE     = MODULES.MODULE_NAME
				            left outer join MODULES_ARCHIVE_LOG
				                         on MODULES_ARCHIVE_LOG.MODULE_NAME    = MODULES.MODULE_NAME
				                        and MODULES_ARCHIVE_LOG.ARCHIVE_ACTION = 'Build'
				           where MODULES.MODULE_NAME in (select RELATED_NAME from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = 'Activities')
				           group by MODULES.MODULE_NAME
				           having max(FIELDS_META_DATA.DATE_MODIFIED) > max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) or max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) is null
				         ) begin -- then
					set @MISSING_ACTIVITIES = @MISSING_ACTIVITIES + 1;
				end -- if;
				if @MISSING_ACTIVITIES = 0 begin -- then
-- #if SQL_Server /*
					declare MODULES_MISSING_ACTIVITIES_CURSOR cursor for
					select RELATED_TABLE
					  from vwMODULES_ARCHIVE_RELATED
					 where MODULE_NAME = 'Activities'
					 order by RELATED_ORDER;
-- #endif SQL_Server */
					
					open MODULES_MISSING_ACTIVITIES_CURSOR;
					fetch next from MODULES_MISSING_ACTIVITIES_CURSOR into @ACTIVITY_TABLE_NAME;
					while @@FETCH_STATUS = 0 begin -- do
						set @ARCHIVE_NAME = @ACTIVITY_TABLE_NAME + '_ARCHIVE';
						exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_NAME, @ARCHIVE_DATABASE;
						if @EXISTS = 0 begin -- then
							set @MISSING_ACTIVITIES = @MISSING_ACTIVITIES + 1;
						end -- if;
						fetch next from MODULES_MISSING_ACTIVITIES_CURSOR into @ACTIVITY_TABLE_NAME;
					end -- while;
					close MODULES_MISSING_ACTIVITIES_CURSOR;
					deallocate MODULES_MISSING_ACTIVITIES_CURSOR;
				end -- if;
				-- 04/27/2020 Paul.  Detecting missing columns from activities table was incomplete.  Need to check for missing native columns. 
				if @MISSING_ACTIVITIES = 0 begin -- then
					if exists(select MODULES.TABLE_NAME, COLUMNS.COLUMN_NAME, ARCHIVE_COLUMNS.COLUMN_NAME
						  from            vwMODULES_ARCHIVE_RELATED
						       inner join MODULES
						               on MODULES.MODULE_NAME         = vwMODULES_ARCHIVE_RELATED.RELATED_NAME
						       inner join INFORMATION_SCHEMA.COLUMNS    COLUMNS
						               on COLUMNS.TABLE_NAME          = MODULES.TABLE_NAME
						  left outer join INFORMATION_SCHEMA.COLUMNS    ARCHIVE_COLUMNS
						               on ARCHIVE_COLUMNS.TABLE_NAME  = COLUMNS.TABLE_NAME + '_ARCHIVE'
						              and ARCHIVE_COLUMNS.COLUMN_NAME = COLUMNS.COLUMN_NAME
						 where vwMODULES_ARCHIVE_RELATED.MODULE_NAME = 'Activities'
						   and ARCHIVE_COLUMNS.COLUMN_NAME is null
					         ) begin -- then
						set @MISSING_ACTIVITIES = @MISSING_ACTIVITIES + 1;
					end -- if;
				end -- if;
				if @MISSING_ACTIVITIES > 0 begin -- then
					exec dbo.spMODULES_ArchiveBuildActivities @MODIFIED_USER_ID;
				end -- if;
				exec dbo.spSqlBuildArchiveActivitiesView  @MODULE_NAME, @ARCHIVE_DATABASE;
			end else begin
				print @MODULE_NAME + ' module does not have activities.';
			end -- if;

			-- 10/16/2018 Paul.  Display related modules. 
			/*
			print @MODULE_NAME + ' related modules:';
			select RELATED_NAME
			     , RELATED_TABLE
			  from vwMODULES_ARCHIVE_RELATED
			 where MODULE_NAME = @MODULE_NAME
			 order by RELATED_ORDER;
			*/

-- #if SQL_Server /*
			declare MODULES_ARCHIVE_RELATED_CURSOR cursor for
			select RELATED_NAME
			     , RELATED_TABLE
			  from vwMODULES_ARCHIVE_RELATED
			 where MODULE_NAME = @MODULE_NAME
			 order by RELATED_ORDER;
-- #endif SQL_Server */
			
			open MODULES_ARCHIVE_RELATED_CURSOR;
			fetch next from MODULES_ARCHIVE_RELATED_CURSOR into @RELATED_MODULE_NAME, @TABLE_NAME;
			while @@FETCH_STATUS = 0 begin -- do
				if @TABLE_NAME is not null and @RELATED_MODULE_NAME <> @MODULE_NAME begin -- then
					print @MODULE_NAME + ' module has related archive ' + @RELATED_MODULE_NAME + ' with table ' + isnull(@TABLE_NAME, '');
					set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
					exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
					exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
					exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
					exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
					exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
					exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;

					-- 02/08/2020 Paul.  Include Audit tables. 
					set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
					set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
					exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					if @TABLE_NAME = 'QUOTES' begin -- then
						set @TABLE_NAME  = 'QUOTES_LINE_ITEMS';
						set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
						exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
						exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
						exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;
	
						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
						set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					end else if @TABLE_NAME = 'ORDERS' begin -- then
						set @TABLE_NAME  = 'ORDERS_LINE_ITEMS';
						set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
						exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
						exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
						exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;
	
						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
						set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					end else if @TABLE_NAME = 'INVOICES' begin -- then
						set @TABLE_NAME  = 'INVOICES_LINE_ITEMS';
						set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
						exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
						exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
						exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;
	
						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
						set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					end else if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
						set @TABLE_NAME  = 'REVENUE_LINE_ITEMS';
						set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
						exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
						exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
						exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;
	
						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
						set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					end else if @TABLE_NAME = 'PROJECT' begin -- then
						set @TABLE_NAME  = 'PROJECT_TASK';
						set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @TABLE_NAME, N'Build';
						exec dbo.spSqlBuildArchiveTable   @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @TABLE_NAME ;
						exec dbo.spSqlBuildArchiveTable   @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlDropForeignKeys     @CUSTOM_NAME;
						exec dbo.spSqlBuildArchiveIndexes @TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @TABLE_NAME , @ARCHIVE_DATABASE;
	
						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
						set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlBuildArchiveTable   @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveTable   @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveIndexes @AUDIT_CUSTOM_NAME, @ARCHIVE_DATABASE;
						exec dbo.spSqlBuildArchiveView    @AUDIT_TABLE_NAME , @ARCHIVE_DATABASE;
					end -- if;
					-- 10/16/2018 Paul.  We need to process activities for related modules. 
					if exists(select * from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = @RELATED_MODULE_NAME and RELATED_NAME = 'Activities') begin -- then
						print @RELATED_MODULE_NAME + ' module has activities.';
						-- 10/22/2017 Paul.  Instead of always attempting to build the archive tables, just build when something is missing or changed. 
						set @MISSING_ACTIVITIES = 0;
						if exists(select MODULES.MODULE_NAME
						               , max(FIELDS_META_DATA.DATE_MODIFIED   ) as DATE_MODIFIED
						               , max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) as DATE_ARCHIVED
						            from            MODULES
						            left outer join FIELDS_META_DATA
						                         on FIELDS_META_DATA.CUSTOM_MODULE     = MODULES.MODULE_NAME
						            left outer join MODULES_ARCHIVE_LOG
						                         on MODULES_ARCHIVE_LOG.MODULE_NAME    = MODULES.MODULE_NAME
						                        and MODULES_ARCHIVE_LOG.ARCHIVE_ACTION = 'Build'
						           where MODULES.MODULE_NAME in (select RELATED_NAME from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = 'Activities')
						           group by MODULES.MODULE_NAME
						           having max(FIELDS_META_DATA.DATE_MODIFIED) > max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) or max(MODULES_ARCHIVE_LOG.DATE_MODIFIED) is null
						         ) begin -- then
							set @MISSING_ACTIVITIES = @MISSING_ACTIVITIES + 1;
						end -- if;
						if @MISSING_ACTIVITIES = 0 begin -- then
-- #if SQL_Server /*
							declare MODULES_MISSING_ACTIVITIES_CURSOR cursor for
							select RELATED_TABLE
							  from vwMODULES_ARCHIVE_RELATED
							 where MODULE_NAME = 'Activities'
							 order by RELATED_ORDER;
-- #endif SQL_Server */
							
							open MODULES_MISSING_ACTIVITIES_CURSOR;
							fetch next from MODULES_MISSING_ACTIVITIES_CURSOR into @ACTIVITY_TABLE_NAME;
							while @@FETCH_STATUS = 0 begin -- do
								set @ARCHIVE_NAME = @ACTIVITY_TABLE_NAME + '_ARCHIVE';
								exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_NAME, @ARCHIVE_DATABASE;
								if @EXISTS = 0 begin -- then
									set @MISSING_ACTIVITIES = @MISSING_ACTIVITIES + 1;
								end -- if;
								fetch next from MODULES_MISSING_ACTIVITIES_CURSOR into @ACTIVITY_TABLE_NAME;
							end -- while;
							close MODULES_MISSING_ACTIVITIES_CURSOR;
							deallocate MODULES_MISSING_ACTIVITIES_CURSOR;
						end -- if;
						if @MISSING_ACTIVITIES > 0 begin -- then
							exec dbo.spMODULES_ArchiveBuildActivities @MODIFIED_USER_ID;
						end -- if;
						exec dbo.spSqlBuildArchiveActivitiesView  @RELATED_MODULE_NAME, @ARCHIVE_DATABASE;
					end else begin
						print @RELATED_MODULE_NAME + ' module does not have activities.';
					end -- if;
				end else if @TABLE_NAME = 'Activities' begin -- then
					exec dbo.spSqlBuildArchiveActivitiesView @RELATED_MODULE_NAME, @ARCHIVE_DATABASE;
				end -- if;
				-- 10/16/2018 Paul.  Fix to populate @RELATED_MODULE_NAME. 
				fetch next from MODULES_ARCHIVE_RELATED_CURSOR into @RELATED_MODULE_NAME, @TABLE_NAME;
			end -- while;
			close MODULES_ARCHIVE_RELATED_CURSOR;
			deallocate MODULES_ARCHIVE_RELATED_CURSOR;
			-- 12/20/2017 Paul.  Related views need to be created after related archive table have been created. 
			exec dbo.spSqlBuildArchiveRelatedView     @MODULE_NAME, @ARCHIVE_DATABASE;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveBuild to public;
GO

