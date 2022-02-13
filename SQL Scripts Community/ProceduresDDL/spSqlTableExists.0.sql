if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableExists' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableExists;
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
-- 06/28/2018 Paul.  Output should be int. 
Create Procedure dbo.spSqlTableExists
	( @EXISTS           bit output
	, @TABLE_NAME       nvarchar(80)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on

	declare @COMMAND              nvarchar(max);
	declare @PARAM_DEFINTION      nvarchar(100);
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	set @PARAM_DEFINTION = N'@COUNT_VALUE int OUTPUT';
	set @EXISTS = 0;
	
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	set @COMMAND = N'select @COUNT_VALUE = count(*) from ' + @ARCHIVE_DATABASE_DOT + 'INFORMATION_SCHEMA.TABLES where TABLE_NAME = ''' + @TABLE_NAME + ''' and TABLE_TYPE = ''BASE TABLE''';
	exec sp_executesql @COMMAND, @PARAM_DEFINTION, @COUNT_VALUE = @EXISTS output;
  end
GO


Grant Execute on dbo.spSqlTableExists to public;
GO

/*
declare @EXISTS bit;
exec spSqlTableExists @EXISTS out, 'ACCOUNTS', null;
print @EXISTS
exec spSqlTableExists @EXISTS out, 'ACCOUNTS', '';
print @EXISTS
exec spSqlTableExists @EXISTS out, 'ACCOUNTS_XXX';
print @EXISTS
*/

