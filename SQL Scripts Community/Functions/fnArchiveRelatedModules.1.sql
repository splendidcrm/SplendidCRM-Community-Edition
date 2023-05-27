if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnArchiveRelatedModules' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnArchiveRelatedModules;
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
Create Function dbo.fnArchiveRelatedModules(@MODULE_NAME nvarchar(25))
returns @MODULES table (MODULE_NAME nvarchar(50))
as
  begin
	if @MODULE_NAME is not null begin -- then
		insert into @MODULES(MODULE_NAME) values (@MODULE_NAME);
	end -- if;
	if exists(select * from MODULES_ARCHIVE_RELATED where MODULE_NAME = @MODULE_NAME and RELATED_NAME = 'Activities' and DELETED = 0) begin -- then
		insert into @MODULES (MODULE_NAME)
		select RELATED_NAME
		  from vwMODULES_ARCHIVE_RELATED
		 where MODULE_NAME = 'Activities';
	end -- if;

	insert into @MODULES (MODULE_NAME)
	select RELATED_NAME
	  from MODULES_ARCHIVE_RELATED
	 where MODULE_NAME  = @MODULE_NAME
	   and RELATED_NAME <> 'Activities'
	   and DELETED      = 0;
	return;
  end
GO

Grant Select on dbo.fnArchiveRelatedModules to public;
GO

