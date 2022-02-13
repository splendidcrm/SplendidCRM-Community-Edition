if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_ArchiveBuildByName' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_ArchiveBuildByName;
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
Create Procedure dbo.spMODULES_ArchiveBuildByName
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MODULE_NAME       nvarchar(25)
	)
as
  begin
	set nocount on

	declare @ID uniqueidentifier;
	select @ID = ID
	  from MODULES
	 where MODULE_NAME = @MODULE_NAME
	   and DELETED     = 0;
	if @ID is not null begin -- then
		exec dbo.spMODULES_ArchiveBuild @ID, @MODIFIED_USER_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_ArchiveBuildByName to public;
GO

/*
-- 12/14/2017 Paul.  Took 4 minutes. 
begin try
	begin tran;
	--exec dbo.spSqlDropAllArchiveTables;
	exec dbo.spMODULES_ArchiveBuildByName null, 'Accounts';
	commit tran;
end try
begin catch
	rollback tran;
	print ERROR_MESSAGE();
end catch
*/

