if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlBackupDatabase' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlBackupDatabase;
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
-- 02/09/2008 Paul.  Remove the SplendidCRM folder in the backup path.  
-- It is not automatically created and we don't want to create it manually at this time. 
-- 02/25/2008 Paul.  Increase size of DBNAME. 
-- 02/21/2017 Paul.  Allow both parameters to be optional. 
Create Procedure dbo.spSqlBackupDatabase
	( @FILENAME nvarchar(255) = null out
	, @TYPE nvarchar(20) = null
	)
as
  begin
	set nocount on

	-- 12/31/2007 Paul.  The backup is place relative to the default backup directory. 
	declare @TIMESTAMP varchar(30);
	-- 02/25/2008 Paul.  The database name can be large.
	declare @DBNAME    varchar(200);
	declare @NOW       datetime;
	set @NOW    = getdate();
	set @DBNAME = db_name();
	set @TYPE   = upper(@TYPE);
	set @TIMESTAMP = convert(varchar(30), @NOW, 112) + convert(varchar(30), @NOW, 108);
	set @TIMESTAMP = substring(replace(@TIMESTAMP, ':', ''), 1, 12);
	-- 02/21/2017 Paul.  Allow both parameters to be optional. 
	if @TYPE = 'FULL' or @TYPE is null begin -- then
		if @FILENAME is null or @FILENAME = '' begin -- then
			set @FILENAME = @DBNAME + '_db_' + @TIMESTAMP + '.bak';
		end -- if;
		backup database @DBNAME to disk = @FILENAME;
	end else if @TYPE = 'LOG' begin -- then
		if @FILENAME is null or @FILENAME = '' begin -- then
			set @FILENAME = @DBNAME + '_tlog_' + @TIMESTAMP + '.trn';
		end -- if;
		backup log @DBNAME to disk = @FILENAME;
	end else begin
		raiserror(N'Unknown backup type', 16, 1);
	end -- if;
  end
GO


Grant Execute on dbo.spSqlBackupDatabase to public;
GO

-- exec spSqlBackupDatabase null, 'FULL';
-- exec spSqlBackupDatabase null, 'LOG';

