if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableIndexExists' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableIndexExists;
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
Create Procedure dbo.spSqlTableIndexExists
	( @EXISTS           bit output
	, @TABLE_NAME       nvarchar(80)
	, @INDEX_NAME       nvarchar(120)
	, @ARCHIVE_DATABASE nvarchar(50)
	)
as
  begin
	set nocount on

	declare @COMMAND              nvarchar(max);
	declare @PARAM_DEFINTION      nvarchar(100);
	declare @ARCHIVE_DATABASE_DOT nvarchar(50);
	set @PARAM_DEFINTION = N'@COUNT_VALUE int output';
	set @EXISTS   = 0;
	
	if len(@ARCHIVE_DATABASE) > 0 begin -- then
		set @ARCHIVE_DATABASE_DOT = '[' + @ARCHIVE_DATABASE + '].';
	end else begin
		set @ARCHIVE_DATABASE_DOT = '';
	end -- if;

	set @COMMAND = N'select @COUNT_VALUE = count(*) from ' + @ARCHIVE_DATABASE_DOT + 'sys.indexes where name = ''' + @INDEX_NAME + '''';
	exec sp_executesql @COMMAND, @PARAM_DEFINTION, @COUNT_VALUE = @EXISTS output;
  end
GO


Grant Execute on dbo.spSqlTableIndexExists to public;
GO

/*
declare @EXISTS bit;
exec spSqlTableIndexExists @EXISTS out, 'OPPORTUNITIES', 'IDXR_OPPORTUNITIES_ASSIGNED_SET_ID', 'SplendidCRM_Archive';
print @EXISTS;
*/

