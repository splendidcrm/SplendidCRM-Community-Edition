if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveRecoverData' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveRecoverData;
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
-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
Create Procedure dbo.spMODULES_ArchiveRecoverData
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MODULE_NAME       nvarchar(25)
	, @ID_LIST           varchar(max)
	)
as
  begin
	set nocount on

	declare @BIND_TOKEN          nvarchar(255);
	declare @Command             nvarchar(max);
	declare @CRLF                nchar(2);
	declare @TABLE_NAME          nvarchar(80);
	declare @CUSTOM_NAME         nvarchar(80);
	-- 02/08/2020 Paul.  Include Audit tables. 
	declare @AUDIT_TABLE_NAME    nvarchar(80);
	declare @AUDIT_CUSTOM_NAME   nvarchar(80);
	declare @RELATED_TABLE_NAME  nvarchar(80);
	declare @RELATED_CUSTOM_NAME nvarchar(80);
	declare @RELATED_FIELD_NAME  nvarchar(80);
	-- 02/08/2020 Paul.  Include Audit tables. 
	declare @AUDIT_RELATED_TABLE_NAME    nvarchar(80);
	declare @AUDIT_RELATED_CUSTOM_NAME   nvarchar(80);
	declare @ID_VALUES           nvarchar(max);
	declare @ID                  uniqueidentifier;
	declare @CurrentPosR         int;
	declare @NextPosR            int;
	declare @RELATED_MODULE_NAME nvarchar(80);
	declare @LEFT_TABLE          nvarchar(90);
	declare @RIGHT_TABLE         nvarchar(90);
	declare @SINGULAR_LEFT_KEY   nvarchar(80);
	declare @SINGULAR_RIGHT_KEY  nvarchar(80);
	declare @RELATIONSHIP_TABLE  nvarchar(80);
	declare @RELATED_ID_LIST     nvarchar(max);
	declare @ARCHIVE_DATABASE    nvarchar(50);
	declare @EXISTS              bit;
	declare @RELATED_ARCHIVE     nvarchar(80);

	set @ARCHIVE_DATABASE   = dbo.fnCONFIG_String ('Archive.Database');
	print 'spMODULES_ArchiveRecoverData: ' + @MODULE_NAME;
	if @ARCHIVE_DATABASE is not null begin -- then
		print 'Archive Database = ' + @ARCHIVE_DATABASE;
	end -- if;

	declare @ID_LIST_TABLE TABLE
		( ID uniqueidentifier not null
		);

	select @TABLE_NAME = TABLE_NAME
	  from MODULES
	 where MODULE_NAME = @MODULE_NAME
	   and DELETED     = 0;

	set @CRLF = char(13) + char(10);
	set @ID_VALUES = '';
	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		if len(@ID_VALUES) > 0 begin -- then
			set @ID_VALUES = @ID_VALUES + ', ';
		end -- if;
		set @ID_VALUES = @ID_VALUES + '''' + cast(@ID as char(36)) + '''';
		set @CurrentPosR = @NextPosR+1;
	end -- while;

	if len(@ID_LIST) = 0 begin -- then
		raiserror(N'List of IDs is empty.', 16, 1);
	end else if @TABLE_NAME is not null begin -- then
		exec dbo.spSqlGetTransactionToken @BIND_TOKEN out;

		set @CUSTOM_NAME = @TABLE_NAME + '_CSTM';
		exec dbo.spMODULES_ARCHIVE_LOG_InsertList @MODIFIED_USER_ID, @TABLE_NAME, N'Recover', @ID_LIST, null;
		exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @CUSTOM_NAME, @ID_LIST, null, null, null, @ARCHIVE_DATABASE;
		exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @TABLE_NAME , @ID_LIST, null, null, null, @ARCHIVE_DATABASE;

		-- 02/08/2020 Paul.  Include Audit tables. 
		set @AUDIT_TABLE_NAME  = @TABLE_NAME + '_AUDIT';
		set @AUDIT_CUSTOM_NAME = @TABLE_NAME + '_CSTM_AUDIT';
		exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_CUSTOM_NAME, @ID_LIST, null, null, null, @ARCHIVE_DATABASE;
		exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_TABLE_NAME , @ID_LIST, null, null, null, @ARCHIVE_DATABASE;
		if @TABLE_NAME = 'QUOTES' begin -- then
			set @RELATED_TABLE_NAME  = 'QUOTES_LINE_ITEMS';
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'QUOTE_ID';
			-- 09/26/2017 Paul.  Must move custom data first before the parent record is deleted. 
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
		end else if @TABLE_NAME = 'ORDERS' begin -- then
			set @RELATED_TABLE_NAME  = 'ORDERS_LINE_ITEMS';
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'ORDER_ID';
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
		end else if @TABLE_NAME = 'INVOICES' begin -- then
			set @RELATED_TABLE_NAME  = 'INVOICES_LINE_ITEMS';
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'INVOICE_ID';
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
		end else if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
			set @RELATED_TABLE_NAME  = 'REVENUE_LINE_ITEMS';
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'OPPORTUNITY_ID';
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
		end else if @TABLE_NAME = 'PROJECT' begin -- then
			set @RELATED_TABLE_NAME  = 'PROJECT_TASK';
			set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
			set @RELATED_FIELD_NAME  = 'PROJECT_ID';
			exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

			-- 02/08/2020 Paul.  Include Audit tables. 
			set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
			set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
			-- 05/07/2020 Paul.  Correct @RELATED_FIELD_NAME. 
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
			exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
		end -- if;
		if exists(select * from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = @MODULE_NAME and RELATED_NAME = 'Activities') begin -- then
			exec dbo.spMODULES_ArchiveRecoverActivities @MODIFIED_USER_ID, @MODULE_NAME, @ID_LIST;
		end -- if;

		declare MODULES_ARCHIVE_RELATED_CURSOR cursor for
		select RELATED_NAME
		     , RELATED_TABLE
		  from vwMODULES_ARCHIVE_RELATED
		 where MODULE_NAME = @MODULE_NAME
		   and RELATED_NAME <> MODULE_NAME
		   and RELATED_TABLE is not null
		 order by RELATED_ORDER;
		
		open MODULES_ARCHIVE_RELATED_CURSOR;
		fetch next from MODULES_ARCHIVE_RELATED_CURSOR into @RELATED_MODULE_NAME, @RELATED_TABLE_NAME;
		while @@FETCH_STATUS = 0 begin -- do
			print 'spMODULES_ArchiveRecoverData: ' + @MODULE_NAME + '.' + @RELATED_MODULE_NAME;
			set @RELATED_ARCHIVE = @RELATED_TABLE_NAME + '_ARCHIVE';
			exec dbo.spSqlTableExists @EXISTS out, @RELATED_ARCHIVE, @ARCHIVE_DATABASE;
			if @EXISTS = 0 begin -- then
				print 'spMODULES_ArchiveRecoverData: ' + @RELATED_ARCHIVE + ' does not exist';
			end -- if;
			if @EXISTS = 1 begin -- then
				set @LEFT_TABLE  = @TABLE_NAME;
				set @RIGHT_TABLE = @RELATED_TABLE_NAME;
				set @SINGULAR_LEFT_KEY  = dbo.fnSqlSingularName(@LEFT_TABLE ) + '_ID';
				set @SINGULAR_RIGHT_KEY = dbo.fnSqlSingularName(@RIGHT_TABLE) + '_ID';

				set @RELATIONSHIP_TABLE = @TABLE_NAME + '_' + @RELATED_TABLE_NAME;
				if not exists (select * from vwSqlTables where TABLE_NAME = @RELATIONSHIP_TABLE) begin -- then
					set @RELATIONSHIP_TABLE = @RELATED_TABLE_NAME + '_' + @TABLE_NAME;
					if not exists (select * from vwSqlTables where TABLE_NAME = @RELATIONSHIP_TABLE) begin -- then
						if exists (select * from vwSqlColumns where ObjectName = @RELATED_TABLE_NAME and ColumnName = @SINGULAR_LEFT_KEY) begin -- then
							set @RELATIONSHIP_TABLE = @RELATED_TABLE_NAME;
							set @SINGULAR_RIGHT_KEY = 'ID';
						end -- if;
					end -- if;
				end -- if;
				--print 'spMODULES_ArchiveRecoverData: ' + @RELATIONSHIP_TABLE + '.' + @SINGULAR_RIGHT_KEY;
				if exists (select * from vwSqlTables where TABLE_NAME = @RELATIONSHIP_TABLE) begin -- then
					set @Command = 'select ' + @SINGULAR_RIGHT_KEY + @CRLF
					             + '  from ' + @RELATIONSHIP_TABLE + @CRLF
					             + ' where ' + @SINGULAR_LEFT_KEY + ' in (' + @ID_VALUES + ')';
					print @Command;
					delete from @ID_LIST_TABLE;
					insert into @ID_LIST_TABLE
					exec sp_executesql @Command;

					set @RELATED_ID_LIST = '';
					select @RELATED_ID_LIST = @RELATED_ID_LIST + (case when len(@RELATED_ID_LIST) > 0 then ',' else '' end) + cast(ID as char(36)) from @ID_LIST_TABLE;
					--print @RELATED_ID_LIST;
					if len(@RELATED_ID_LIST) > 0 begin -- then
						set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
						exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
						exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, null, null, null, @ARCHIVE_DATABASE;
						exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, null, null, null, @ARCHIVE_DATABASE;

						-- 02/08/2020 Paul.  Include Audit tables. 
						set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
						set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
						exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, null, null, null, @ARCHIVE_DATABASE;
						exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, null, null, null, @ARCHIVE_DATABASE;
						if @TABLE_NAME = 'QUOTES' begin -- then
							set @RELATED_TABLE_NAME  = 'QUOTES_LINE_ITEMS';
							set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
							set @RELATED_FIELD_NAME  = 'QUOTE_ID';
							exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

							-- 02/08/2020 Paul.  Include Audit tables. 
							set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
							set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
						end else if @TABLE_NAME = 'ORDERS' begin -- then
							set @RELATED_TABLE_NAME  = 'ORDERS_LINE_ITEMS';
							set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
							set @RELATED_FIELD_NAME  = 'ORDER_ID';
							exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

							-- 02/08/2020 Paul.  Include Audit tables. 
							set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
							set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
						end else if @TABLE_NAME = 'INVOICES' begin -- then
							set @RELATED_TABLE_NAME  = 'INVOICES_LINE_ITEMS';
							set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
							set @RELATED_FIELD_NAME  = 'INVOICE_ID';
							exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

							-- 02/08/2020 Paul.  Include Audit tables. 
							set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
							set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
						end else if @TABLE_NAME = 'OPPORTUNITIES' begin -- then
							set @RELATED_TABLE_NAME  = 'REVENUE_LINE_ITEMS';
							set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
							set @RELATED_FIELD_NAME  = 'OPPORTUNITY_ID';
							exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

							-- 02/08/2020 Paul.  Include Audit tables. 
							set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
							set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
						end else if @TABLE_NAME = 'PROJECT' begin -- then
							set @RELATED_TABLE_NAME  = 'PROJECT_TASK';
							set @RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM';
							set @RELATED_FIELD_NAME  = 'PROJECT_ID';
							exec dbo.spMODULES_ARCHIVE_LOG_InsertOnly @MODIFIED_USER_ID, @RELATED_TABLE_NAME, N'Recover';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @RELATED_TABLE_NAME , @RELATED_ID_LIST, @RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;

							-- 02/08/2020 Paul.  Include Audit tables. 
							set @AUDIT_RELATED_TABLE_NAME  = @RELATED_TABLE_NAME + '_AUDIT';
							set @AUDIT_RELATED_CUSTOM_NAME = @RELATED_TABLE_NAME + '_CSTM_AUDIT';
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_CUSTOM_NAME, @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
							exec dbo.spSqlRecoverArchiveData @MODIFIED_USER_ID, @AUDIT_RELATED_TABLE_NAME , @RELATED_ID_LIST, @AUDIT_RELATED_TABLE_NAME, @RELATED_FIELD_NAME, null, @ARCHIVE_DATABASE;
						end -- if;
						if exists(select * from vwMODULES_ARCHIVE_RELATED where MODULE_NAME = @RELATED_MODULE_NAME and RELATED_NAME = 'Activities') begin -- then
							exec dbo.spMODULES_ArchiveRecoverActivities @MODIFIED_USER_ID, @RELATED_MODULE_NAME, @RELATED_ID_LIST;
						end -- if;
					end -- if;
				end -- if;
			end -- if;
			fetch next from MODULES_ARCHIVE_RELATED_CURSOR into @RELATED_MODULE_NAME, @RELATED_TABLE_NAME;
		end -- while;
		close MODULES_ARCHIVE_RELATED_CURSOR;
		deallocate MODULES_ARCHIVE_RELATED_CURSOR;

		-- 09/27/2017 Paul.  We want to prevent recovered records from generating workflow events, so delete the events after they are created. 
		delete from WORKFLOW_EVENTS
		 where AUDIT_TOKEN = @BIND_TOKEN;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveRecoverData to public;
GO

/*
declare @ID_LIST varchar(8000);
set @ID_LIST = '27667C9D-5B60-403C-B95E-42DF8758E38F, 27667C9D-5B60-403C-B95E-42DF8758E38E';
exec dbo.spMODULES_ArchiveRecoverData null, 'CONTACTS', @ID_LIST;
*/

