if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableDropColumn' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableDropColumn;
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
Create Procedure dbo.spSqlTableDropColumn
	( @TABLE_NAME        varchar(255)
	, @COLUMN_NAME       varchar(255)
	)
as
  begin
	set nocount on

	declare @Command   varchar(2000);
	declare @OldColumn varchar(100);
	declare @NewColumn varchar(100);

	exec dbo.spSqlTableDropColumnConstraint @TABLE_NAME, @COLUMN_NAME;

	set @Command = 'alter table ' + @TABLE_NAME + ' drop column ' + @COLUMN_NAME;
	exec (@Command);

	-- 07/15/2009 Jamie.  When dropping a column, we also need to drop it from the audit table. 
	-- However, since we want to retain the audit, just rename the filed and include the drop date. 
	if exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TABLE_NAME + '_AUDIT' and COLUMN_NAME = @COLUMN_NAME) begin -- then
-- #if SQL_Server /*
		set @OldColumn = @TABLE_NAME + '_AUDIT' + '.' + @COLUMN_NAME;
		set @NewColumn = upper(@COLUMN_NAME) + '_' + convert(varchar(8), getdate(), 112) + '_' + replace(convert(varchar(8), getdate(), 108), ':', '');
		exec sp_rename @OldColumn, @NewColumn, 'COLUMN';
-- #endif SQL_Server */
	end -- if;
  end
GO

Grant Execute on dbo.spSqlTableDropColumn to public;
GO


