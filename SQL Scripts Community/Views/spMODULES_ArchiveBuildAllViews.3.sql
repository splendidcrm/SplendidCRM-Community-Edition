if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveBuildAllViews' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveBuildAllViews;
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
Create Procedure dbo.spMODULES_ArchiveBuildAllViews
as
  begin
	set nocount on

	declare @MODULE_ID   uniqueidentifier;
	declare @MODULE_NAME nvarchar(25);

	declare MODULES_ARCHIVE_BUILD_ALL_CURSOR cursor for
	select distinct MODULES.ID
	     , MODULES.MODULE_NAME
	  from      MODULES_ARCHIVE_RELATED
	 inner join MODULES
	         on MODULES.MODULE_NAME    = MODULES_ARCHIVE_RELATED.MODULE_NAME
	        and MODULES.MODULE_ENABLED = 1
	        and MODULES.DELETED        = 0
	 where MODULES_ARCHIVE_RELATED.DELETED = 0
	 order by MODULES.MODULE_NAME;
	
	open MODULES_ARCHIVE_BUILD_ALL_CURSOR;
	fetch next from MODULES_ARCHIVE_BUILD_ALL_CURSOR into @MODULE_ID, @MODULE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		print 'Build Archive View: ' + @MODULE_NAME;
		exec dbo.spMODULES_ArchiveBuildView @MODULE_ID, null;
		fetch next from MODULES_ARCHIVE_BUILD_ALL_CURSOR into @MODULE_ID, @MODULE_NAME;
	end -- while;
	close MODULES_ARCHIVE_BUILD_ALL_CURSOR;
	deallocate MODULES_ARCHIVE_BUILD_ALL_CURSOR;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveBuildAllViews to public;
GO

/*
-- 10/16/2018 Paul.  1 minute. 
begin try
	begin tran;
	-- exec dbo.spSqlDropAllArchiveViews ;
	exec dbo.spMODULES_ArchiveBuildAllViews ;
	commit tran;
end try
begin catch
	rollback tran;
	print ERROR_MESSAGE();
end catch
*/

