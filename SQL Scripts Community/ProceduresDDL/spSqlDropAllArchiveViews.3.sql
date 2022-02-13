if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlDropAllArchiveViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlDropAllArchiveViews;
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
Create Procedure dbo.spSqlDropAllArchiveViews
as
  begin
	set nocount on
	print 'spSqlDropAllArchiveViews';

	declare @COMMAND      nvarchar(max);
	declare @VIEW_NAME    nvarchar(90);
	declare ARCHIVE_VIEWS_CURSOR cursor for
	select TABLE_NAME
	  from INFORMATION_SCHEMA.VIEWS
	 where TABLE_NAME like 'vw%[_]ARCHIVE'
	order by TABLE_NAME;

	open ARCHIVE_VIEWS_CURSOR;
	fetch next from ARCHIVE_VIEWS_CURSOR into @VIEW_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = @VIEW_NAME) begin -- then
			set @COMMAND = 'Drop View dbo.' + @VIEW_NAME;
			print @COMMAND;
			exec(@COMMAND);
		end -- if;

		fetch next from ARCHIVE_VIEWS_CURSOR into @VIEW_NAME;
	end -- while;
	close ARCHIVE_VIEWS_CURSOR;
	deallocate ARCHIVE_VIEWS_CURSOR;
  end
GO


Grant Execute on dbo.spSqlDropAllArchiveViews to public;
GO

-- exec dbo.spSqlDropAllArchiveViews ;


