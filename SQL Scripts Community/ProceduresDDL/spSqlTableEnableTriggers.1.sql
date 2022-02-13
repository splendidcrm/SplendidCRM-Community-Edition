if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlTableEnableTriggers' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlTableEnableTriggers;
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
Create Procedure dbo.spSqlTableEnableTriggers
	( @TABLE_NAME        varchar(255)
	)
as
  begin
	set nocount on

	declare @COMMAND       varchar(2000);
	declare @COLUMN_NAME   varchar(255);

	-- 04/27/2014 Paul.  Use simplified call to manage triggers. Both are valid. 
	set @COMMAND = 'alter table ' + upper(@TABLE_NAME) + ' enable trigger all';
	--set @COMMAND = 'enable trigger all on ' + upper(@TABLE_NAME);
	exec(@COMMAND);
	--declare TRIGGER_CURSOR cursor for
	--select TRIGGERS.name
	--  from      sys.objects        TRIGGERS
	-- inner join sys.objects        TABLES
	--         on TABLES.object_id = TRIGGERS.parent_object_id
	-- where TRIGGERS.type = 'TR'
	--   and TABLES.name = @TABLE_NAME;
	--open TRIGGER_CURSOR;
	--fetch next from TRIGGER_CURSOR into @COLUMN_NAME;
	--while @@FETCH_STATUS = 0 begin -- do
	--	set @COMMAND = 'alter table ' + upper(@TABLE_NAME) + ' enable trigger ' +  @COLUMN_NAME + ';';
	--	exec(@COMMAND);
	--	fetch next from TRIGGER_CURSOR into @COLUMN_NAME;
	--end -- while;
	--close TRIGGER_CURSOR;
	--deallocate TRIGGER_CURSOR;
  end
GO

Grant Execute on dbo.spSqlTableEnableTriggers to public;
GO


