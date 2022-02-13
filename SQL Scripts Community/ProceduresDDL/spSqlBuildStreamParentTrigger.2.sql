if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBuildStreamParentTrigger' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBuildStreamParentTrigger;
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
-- 04/29/2016 Paul.  The deallocate PARENTS_CURSOR needs to be outside the IF condition. 
Create Procedure dbo.spSqlBuildStreamParentTrigger(@TABLE_NAME varchar(80))
as
  begin
	set nocount on
	
	declare @Command           varchar(max);
	declare @STREAM_TABLE      varchar(90);
	declare @AUDIT_TABLE       varchar(90);
	declare @TRIGGER_NAME      varchar(90);
	declare @TEST              bit;
	declare @CRLF              char(2);
	declare @AUDIT_FIELDS      int;
	declare @STREAM_FIELDS     int;
	declare @PARENT_TABLE_NAME varchar(90);
	declare @MODULE_NAME       varchar(30);

	declare PARENTS_CURSOR cursor for
	select vwSqlTablesStreamed.TABLE_NAME
	  from      vwSqlTablesStreamed
	 inner join vwSqlTables
	         on vwSqlTables.TABLE_NAME = vwSqlTablesStreamed.TABLE_NAME + '_STREAM'
	order by vwSqlTablesStreamed.TABLE_NAME;

	-- 07/31/2017 Paul.  We need to use Try/Catch to fully capture the error. 
	begin try
		set @TEST            = 0;
		set @CRLF            = char(13) + char(10);
		set @AUDIT_FIELDS    = 0;
		set @AUDIT_TABLE     = @TABLE_NAME + '_AUDIT';
		set @MODULE_NAME     = substring(@TABLE_NAME , 1, 1) + replace(lower(substring(@TABLE_NAME , 2, len(@TABLE_NAME ))), '_', '');
		if @TABLE_NAME = 'CHAT_CHANNELS' begin -- then
			set @MODULE_NAME = 'ChatChannels';
		end -- if;
		if @TABLE_NAME = 'SMS_MESSAGES' begin -- then
			set @MODULE_NAME = 'SmsMessages';
		end -- if;
		if @TABLE_NAME = 'TWITTER_MESSAGES' begin -- then
			set @MODULE_NAME = 'TwitterMessages';
		end -- if;
	
		-- 09/23/2015 Paul.  We need to prevent from adding streaming to non-SplendidCRM tables, so check for the base fields. 
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ID') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_ACTION') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_DATE') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_VERSION') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_COLUMNS') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @AUDIT_TABLE and COLUMN_NAME = 'AUDIT_TOKEN') begin -- then
			set @AUDIT_FIELDS = @AUDIT_FIELDS + 1;
		end -- if;
		if @AUDIT_FIELDS = 6 begin -- then
			set @TRIGGER_NAME = 'tr' + @TABLE_NAME + '_Parent_Ins_STREAM';
			if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '' + @AUDIT_TABLE) begin -- then
				if exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
					set @Command = 'Drop   Trigger dbo.' + @TRIGGER_NAME;
					if @TEST = 0 begin -- then
						print @Command;
						exec(@Command);
					end -- if;
				end -- if;
				
				if not exists (select * from sys.objects where name = @TRIGGER_NAME and type = 'TR') begin -- then
					set @Command = '';
					set @Command = @Command + 'Create Trigger dbo.' + @TRIGGER_NAME + ' on dbo.' + @AUDIT_TABLE + @CRLF;
					set @Command = @Command + 'for insert' + @CRLF;
					set @Command = @Command + 'as' + @CRLF;
					set @Command = @Command + '  begin' + @CRLF;
					open PARENTS_CURSOR;
					fetch next from PARENTS_CURSOR into @PARENT_TABLE_NAME;
					while @@FETCH_STATUS = 0 begin -- do
						set @STREAM_TABLE    = @PARENT_TABLE_NAME + '_STREAM';
						set @STREAM_FIELDS   = 0;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_ID') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_DATE') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_VERSION') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_ACTION') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'STREAM_COLUMNS') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'AUDIT_ID') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @STREAM_TABLE and COLUMN_NAME = 'ID') begin -- then
							set @STREAM_FIELDS = @STREAM_FIELDS + 1;
						end -- if;
						
						if @STREAM_FIELDS = 7 and (@TABLE_NAME <> 'ACCOUNTS' or @PARENT_TABLE_NAME = 'ACCOUNTS') begin -- then
							set @Command = @Command + '	insert into dbo.' + @PARENT_TABLE_NAME + '_STREAM' + @CRLF;
							set @Command = @Command + '		( STREAM_ID'             + @CRLF;
							set @Command = @Command + '		, STREAM_DATE'           + @CRLF;
							set @Command = @Command + '		, LINK_AUDIT_ID'         + @CRLF;
							set @Command = @Command + '		, STREAM_ACTION'         + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_ID'     + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_MODULE' + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_NAME'   + @CRLF;
							set @Command = @Command + '		, ID'                    + @CRLF;
							set @Command = @Command + '		, CREATED_BY'            + @CRLF;
							set @Command = @Command + '		, ASSIGNED_USER_ID'      + @CRLF;
							set @Command = @Command + '		, TEAM_ID'               + @CRLF;
							set @Command = @Command + '		, TEAM_SET_ID'           + @CRLF;
							set @Command = @Command + '		, NAME'                  + @CRLF;
							set @Command = @Command + '		)'                       + @CRLF;
							set @Command = @Command + '	select	  newid()'               + @CRLF;
							set @Command = @Command + '		, inserted.AUDIT_DATE'   + @CRLF;
							set @Command = @Command + '		, inserted.AUDIT_ID'     + @CRLF;
							set @Command = @Command + '		, ''Linked'''            + @CRLF;
							set @Command = @Command + '		, inserted.ID'           + @CRLF;
							set @Command = @Command + '		, ''' + @MODULE_NAME + '''' + @CRLF;
							set @Command = @Command + '		, inserted.NAME'             + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.ID'               + @CRLF;
							-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.MODIFIED_USER_ID' + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.ASSIGNED_USER_ID' + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.TEAM_ID'          + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.TEAM_SET_ID'      + @CRLF;
							if @PARENT_TABLE_NAME = 'CONTACTS' or @PARENT_TABLE_NAME = 'LEADS' or @PARENT_TABLE_NAME = 'PROSPECTS' or @PARENT_TABLE_NAME = 'USERS' begin -- then
								set @Command = @Command + '		, dbo.fnFullName(' + @PARENT_TABLE_NAME + '.FIRST_NAME, ' + @PARENT_TABLE_NAME + '.LAST_NAME) as NAME' + @CRLF;
							end else if @PARENT_TABLE_NAME = 'DOCUMENTS' begin -- then
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.DOCUMENT_NAME' + @CRLF;
							end else if @PARENT_TABLE_NAME = 'PAYMENTS' begin -- then
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.PAYMENT_NUM'   + @CRLF;
							end else begin
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.NAME'          + @CRLF;
							end -- if;
							set @Command = @Command + '	  from            inserted'              + @CRLF;
							set @Command = @Command + '	       inner join ' + @PARENT_TABLE_NAME + @CRLF;
							set @Command = @Command + '	               on ' + @PARENT_TABLE_NAME + '.ID = inserted.PARENT_ID'        + @CRLF;
							set @Command = @Command + '	  left outer join ' + @AUDIT_TABLE + ' ' + @AUDIT_TABLE + '_OLD'             + @CRLF;
							set @Command = @Command + '	               on ' + @AUDIT_TABLE + '_OLD.ID = inserted.ID'                 + @CRLF;
							set @Command = @Command + '	              and ' + @AUDIT_TABLE + '_OLD.AUDIT_VERSION = '                 + @CRLF;
							set @Command = @Command + '		(select max(' + @AUDIT_TABLE + '.AUDIT_VERSION)'                     + @CRLF;
							set @Command = @Command + '		   from ' + @AUDIT_TABLE                                             + @CRLF;
							set @Command = @Command + '		  where ' + @AUDIT_TABLE + '.ID            = inserted.ID'            + @CRLF;
							set @Command = @Command + '		    and ' + @AUDIT_TABLE + '.AUDIT_VERSION < inserted.AUDIT_VERSION' + @CRLF;
							set @Command = @Command + '		)' + @CRLF;
							set @Command = @Command + '	 where ' + @AUDIT_TABLE + '_OLD.AUDIT_ID  is null' + @CRLF;
							set @Command = @Command + '	    or ' + @AUDIT_TABLE + '_OLD.PARENT_ID is null' + @CRLF;
							set @Command = @Command + '	    or inserted.PARENT_ID <> ' + @AUDIT_TABLE + '_OLD.PARENT_ID' + @CRLF;
							set @Command = @Command + '	;' + @CRLF;
	
							set @Command = @Command + '	insert into dbo.' + @PARENT_TABLE_NAME + '_STREAM' + @CRLF;
							set @Command = @Command + '		( STREAM_ID'             + @CRLF;
							set @Command = @Command + '		, STREAM_DATE'           + @CRLF;
							set @Command = @Command + '		, LINK_AUDIT_ID'         + @CRLF;
							set @Command = @Command + '		, STREAM_ACTION'         + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_ID'     + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_MODULE' + @CRLF;
							set @Command = @Command + '		, STREAM_RELATED_NAME'   + @CRLF;
							set @Command = @Command + '		, ID'                    + @CRLF;
							set @Command = @Command + '		, CREATED_BY'            + @CRLF;
							set @Command = @Command + '		, ASSIGNED_USER_ID'      + @CRLF;
							set @Command = @Command + '		, TEAM_ID'               + @CRLF;
							set @Command = @Command + '		, TEAM_SET_ID'           + @CRLF;
							set @Command = @Command + '		, NAME'                  + @CRLF;
							set @Command = @Command + '		)'                       + @CRLF;
							set @Command = @Command + '	select	  newid()'               + @CRLF;
							set @Command = @Command + '		, inserted.AUDIT_DATE'   + @CRLF;
							set @Command = @Command + '		, inserted.AUDIT_ID'     + @CRLF;
							set @Command = @Command + '		, ''Unlinked'''          + @CRLF;
							set @Command = @Command + '		, inserted.ID'           + @CRLF;
							set @Command = @Command + '		, ''' + @MODULE_NAME + '''' + @CRLF;
							set @Command = @Command + '		, inserted.NAME'             + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.ID'               + @CRLF;
							-- 06/03/2016 Paul.  We should be using the MODIFIED_USER_ID as the person who made the change. 
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.MODIFIED_USER_ID' + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.ASSIGNED_USER_ID' + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.TEAM_ID'          + @CRLF;
							set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.TEAM_SET_ID'      + @CRLF;
							if @PARENT_TABLE_NAME = 'CONTACTS' or @PARENT_TABLE_NAME = 'LEADS' or @PARENT_TABLE_NAME = 'PROSPECTS' or @PARENT_TABLE_NAME = 'USERS' begin -- then
								set @Command = @Command + '		, dbo.fnFullName(' + @PARENT_TABLE_NAME + '.FIRST_NAME, ' + @PARENT_TABLE_NAME + '.LAST_NAME) as NAME' + @CRLF;
							end else if @PARENT_TABLE_NAME = 'DOCUMENTS' begin -- then
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.DOCUMENT_NAME' + @CRLF;
							end else if @PARENT_TABLE_NAME = 'PAYMENTS' begin -- then
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.PAYMENT_NUM'   + @CRLF;
							end else begin
								set @Command = @Command + '		, ' + @PARENT_TABLE_NAME + '.NAME'          + @CRLF;
							end -- if;
							set @Command = @Command + '	  from      inserted'                                                        + @CRLF;
							set @Command = @Command + '	 inner join ' + @AUDIT_TABLE + ' ' + @AUDIT_TABLE + '_OLD'                   + @CRLF;
							set @Command = @Command + '	         on ' + @AUDIT_TABLE + '_OLD.ID = inserted.ID'                       + @CRLF;
							set @Command = @Command + '	        and ' + @AUDIT_TABLE + '_OLD.AUDIT_VERSION = '                       + @CRLF;
							set @Command = @Command + '		(select max(' + @AUDIT_TABLE + '.AUDIT_VERSION)'                     + @CRLF;
							set @Command = @Command + '		   from ' + @AUDIT_TABLE                                             + @CRLF;
							set @Command = @Command + '		  where ' + @AUDIT_TABLE + '.ID            = inserted.ID'            + @CRLF;
							set @Command = @Command + '		    and ' + @AUDIT_TABLE + '.AUDIT_VERSION < inserted.AUDIT_VERSION' + @CRLF;
							set @Command = @Command + '		)' + @CRLF;
							set @Command = @Command + '	 inner join ' + @PARENT_TABLE_NAME + @CRLF;
							set @Command = @Command + '	         on ' + @PARENT_TABLE_NAME + '.ID = ' + @AUDIT_TABLE + '_OLD.PARENT_ID' + @CRLF;
							set @Command = @Command + '	 where inserted.PARENT_ID is null' + @CRLF;
							set @Command = @Command + '	    or inserted.PARENT_ID <> ' + @AUDIT_TABLE + '_OLD.PARENT_ID' + @CRLF;
							set @Command = @Command + '	;' + @CRLF;
						end -- if;
						fetch next from PARENTS_CURSOR into @PARENT_TABLE_NAME;
					end -- while;
					close PARENTS_CURSOR;
					set @Command = @Command + '  end' + @CRLF;
					if @TEST = 1 begin -- then
						print @Command + @CRLF;
					end else begin
						print substring(@Command, 1, charindex(@CRLF, @Command));
						exec(@Command);
					end -- if;
				end -- if;
			end -- if;
		end -- if;
	end try
	begin catch
		print 'Server: Msg 207, Level 16, State 1, Procedure spSqlBuildStreamParentTrigger, Line 221: ' + @TABLE_NAME;
		print ERROR_MESSAGE();
	end catch
	-- 04/29/2016 Paul.  The deallocate PARENTS_CURSOR needs to be outside the IF condition. 
	deallocate PARENTS_CURSOR;
  end
GO


Grant Execute on dbo.spSqlBuildStreamParentTrigger to public;
GO

-- exec spSqlBuildStreamParentTrigger 'ACCOUNTS';

