if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableColumnsChanged' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableColumnsChanged;
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
Create Procedure dbo.spSqlTableColumnsChanged
	( @EXISTS           bit output
	, @TABLE_NAME       nvarchar(80)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on

	declare @COLUMNS_CHANGED      int;
	declare @COMMAND              nvarchar(max);
	declare @PARAM_DEFINTION      nvarchar(100);
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	set @PARAM_DEFINTION = N'@CONFIG_VALUE nvarchar(50) OUTPUT';
	set @EXISTS   = 0;
	
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	set @COMMAND = N'select @CONFIG_VALUE = count(*)
	  from            INFORMATION_SCHEMA.COLUMNS   vwSqlColumns
	  left outer join ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.COLUMNS   vwSqlColumnsArchive
	               on vwSqlColumnsArchive.TABLE_NAME  = vwSqlColumns.TABLE_NAME + ''_ARCHIVE''
	              and vwSqlColumnsArchive.COLUMN_NAME = vwSqlColumns.COLUMN_NAME
	 where vwSqlColumnsArchive.TABLE_NAME is null
	   and vwSqlColumns.TABLE_NAME = ''' + @TABLE_NAME + '''';

	exec sp_executesql @COMMAND, @PARAM_DEFINTION, @CONFIG_VALUE = @COLUMNS_CHANGED output;
	if @COLUMNS_CHANGED > 0 begin -- then
		set @EXISTS = 1;
	end -- if;
  end
GO


Grant Execute on dbo.spSqlTableColumnsChanged to public;
GO

/*
declare @EXISTS bit;
exec spSqlTableColumnsChanged @EXISTS out, 'OPPORTUNITIES', null;
print @EXISTS
exec spSqlTableColumnsChanged @EXISTS out, 'OPPORTUNITIES', '';
print @EXISTS
exec spSqlTableColumnsChanged @EXISTS out, 'OPPORTUNITIES', 'SplendidCRM_Archive';
print @EXISTS
*/

