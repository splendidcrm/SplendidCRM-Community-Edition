if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamIndex' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamIndex;
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
-- 01/15/2018 Paul.  Include the AUDIT_ID so that the columns can be updated. 
Create Procedure dbo.spSqlBuildStreamIndex(@TABLE_NAME varchar(80))
as
  begin
	set nocount on

	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @STREAM_INDEX      varchar(90);
	declare @CRLF              char(2);
	declare @TEST              bit;
	
	set @TEST = 0;
	set @CRLF = char(13) + char(10);
	set @STREAM_TABLE = @TABLE_NAME + '_STREAM';
	if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @STREAM_TABLE and TABLE_TYPE = 'BASE TABLE') begin -- then
		/*
		set @STREAM_INDEX = 'IDX_' + @STREAM_TABLE + '_SET';
		if exists (select * from sys.indexes where name = @STREAM_INDEX) begin -- then
			set @Command = 'drop   index ' + @STREAM_INDEX + ' on dbo.' + @STREAM_TABLE;
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;
		*/

		-- 06/03/2016 Paul.  Index when Dynamic Teams disabled. 
		set @STREAM_INDEX = 'IDX_' + @STREAM_TABLE + '_SET';
		if not exists (select * from sys.indexes where name = @STREAM_INDEX) begin -- then
			set @Command = 'create index ' + @STREAM_INDEX + ' on dbo.' + @STREAM_TABLE + '(TEAM_SET_ID, CREATED_BY, ASSIGNED_USER_ID, ID, AUDIT_ID, TEAM_ID)';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;

		-- 06/03/2016 Paul.  Index when Teams enabled, Dynamic Teams disabled. 
		set @STREAM_INDEX = 'IDX_' + @STREAM_TABLE + '_TID';
		if not exists (select * from sys.indexes where name = @STREAM_INDEX) begin -- then
			set @Command = 'create index ' + @STREAM_INDEX + ' on dbo.' + @STREAM_TABLE + '(TEAM_ID, CREATED_BY, ASSIGNED_USER_ID, ID, AUDIT_ID)';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;

		-- 06/03/2016 Paul.  Index when Teams disabled. 
		set @STREAM_INDEX = 'IDX_' + @STREAM_TABLE + '_CBY';
		if not exists (select * from sys.indexes where name = @STREAM_INDEX) begin -- then
			set @Command = 'create index ' + @STREAM_INDEX + ' on dbo.' + @STREAM_TABLE + '(CREATED_BY, ASSIGNED_USER_ID, ID, AUDIT_ID, TEAM_ID)';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;

		-- 01/15/2018 Paul.  Include the AUDIT_ID so that the columns can be updated. 
		set @STREAM_INDEX = 'IDX_' + @STREAM_TABLE + '_AID';
		if not exists (select * from sys.indexes where name = @STREAM_INDEX) begin -- then
			set @Command = 'create index ' + @STREAM_INDEX + ' on dbo.' + @STREAM_TABLE + '(AUDIT_ID)';
			if @TEST = 1 begin -- then
				print @Command;
			end else begin
				print @Command;
				exec(@Command);
			end -- if;
		end -- if;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBuildStreamIndex to public;
GO

-- exec dbo.spSqlBuildStreamIndex 'ACCOUNTS';

