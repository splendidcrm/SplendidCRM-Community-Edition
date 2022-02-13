if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropDefaultConstraint' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropDefaultConstraint;
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
Create Procedure dbo.spSqlDropDefaultConstraint(@TABLE_NAME nvarchar(50) out, @COLUMN_NAME nvarchar(50))
as
  begin
	set nocount on

	declare @COMMAND varchar(1000);
	select @COMMAND = 'alter table ' + sys.tables.name + ' drop constraint ' + sys.default_constraints.name
	  from      sys.all_columns
	 inner join sys.tables
	         on sys.tables.object_id              = sys.all_columns.object_id
	 inner join sys.default_constraints
	         on sys.default_constraints.object_id = sys.all_columns.default_object_id
	 where sys.tables.name      = @TABLE_NAME
	   and sys.all_columns.name = @COLUMN_NAME;

	if @COMMAND is not null begin -- then
		print @COMMAND;
		exec(@COMMAND);
	end -- if;
  end
GO


Grant Execute on dbo.spSqlDropDefaultConstraint to public;
GO

