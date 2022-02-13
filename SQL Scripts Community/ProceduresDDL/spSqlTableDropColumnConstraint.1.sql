if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableDropColumnConstraint' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableDropColumnConstraint;
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
-- 09/15/2009 Paul.  Use alias to get working on Azure. 
-- Deprecated feature 'More than two-part column name' is not supported in this version of SQL Server.
-- 09/12/2010 Paul.  Add Oracle code to lookup the constraint name. 
Create Procedure dbo.spSqlTableDropColumnConstraint
	( @TABLE_NAME        varchar(255)
	, @COLUMN_NAME       varchar(255)
	)
as
  begin
	set nocount on
	
	declare @Command varchar(2000);
-- #if SQL_Server /*
	select @Command = 'alter table ' + objects.name + ' drop constraint ' + default_constraints.name + ';'
	  from      sys.default_constraints  default_constraints
	 inner join sys.objects              objects
	         on objects.object_id      = default_constraints.parent_object_id
	 inner join sys.columns              columns
	         on columns.object_id      = objects.object_id
	        and columns.column_id      = default_constraints.parent_column_id
	 where objects.type = 'U'
	   and default_constraints.type = 'D'
	   and objects.name = @TABLE_NAME
	   and columns.name = @COLUMN_NAME;
-- #endif SQL_Server */



	if @Command is not null begin -- then
		exec (@Command);
	end -- if;
  end
GO

Grant Execute on dbo.spSqlTableDropColumnConstraint to public;
GO

