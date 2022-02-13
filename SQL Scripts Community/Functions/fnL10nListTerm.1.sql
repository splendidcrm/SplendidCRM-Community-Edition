if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnL10nListTerm' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnL10nListTerm;
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
Create Function dbo.fnL10nListTerm(@LANG nvarchar(10), @MODULE_NAME nvarchar(20), @NAME nvarchar(50),  @LIST_NAME nvarchar(30))
returns nvarchar(2000)
as
  begin
	declare @DISPLAY_NAME nvarchar(2000);
	if @MODULE_NAME is null begin -- then
		select @DISPLAY_NAME = DISPLAY_NAME
		  from dbo.TERMINOLOGY
		 where LANG        = @LANG
		   and NAME        = @NAME
		   and MODULE_NAME is null
		   and LIST_NAME   = @LIST_NAME;
	end else if @MODULE_NAME is not null begin -- then
		select @DISPLAY_NAME = DISPLAY_NAME
		  from dbo.TERMINOLOGY
		 where LANG        = @LANG
		   and NAME        = @NAME
		   and MODULE_NAME = @MODULE_NAME
		   and LIST_NAME   = @LIST_NAME;
	end -- if;
	
	return @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.fnL10nListTerm to public
GO

