if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllStreamTriggers' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllStreamTriggers;
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
Create Procedure dbo.spSqlDropAllStreamTriggers
as
  begin
	set nocount on

	declare @Command      varchar(max);
	declare @AUDIT_TABLE  varchar(90);
	declare @TABLE_NAME   varchar(80);
	declare @TRIGGER_NAME varchar(90);

	declare TRIGGERS_CURSOR cursor for
	select name
	  from sys.triggers
	 where name like 'tr%_Ins_STREAM'
	 order by name;
	open TRIGGERS_CURSOR;
	fetch next from TRIGGERS_CURSOR into @TRIGGER_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		set @Command = 'Drop Trigger dbo.' + @TRIGGER_NAME;
		print @Command;
		exec(@Command);
		fetch next from TRIGGERS_CURSOR into @TRIGGER_NAME;
	end -- while;
	close TRIGGERS_CURSOR;
	deallocate TRIGGERS_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllStreamTriggers to public;
GO

-- exec dbo.spSqlDropAllStreamTriggers;


