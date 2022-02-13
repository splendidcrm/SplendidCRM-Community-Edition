if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTermName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTermName;
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
-- 04/23/2017 Paul.  Module name can be 25 chars. 
Create Function dbo.fnTermName(@MODULE_NAME nvarchar(25), @LIST_NAME nvarchar(50), @NAME nvarchar(50))
returns nvarchar(150)
as
  begin
	declare @TERM_NAME nvarchar(200);
	if @LIST_NAME is null or @LIST_NAME = '' begin -- then
		set @TERM_NAME = isnull(@MODULE_NAME, N'') + N'.' + isnull(@NAME, N'');
	end else begin
		set @TERM_NAME = isnull(@MODULE_NAME, N'') + N'.' + isnull(@LIST_NAME, N'') + N'.' + isnull(@NAME, N'');
	end -- if;
	return @TERM_NAME;
  end
GO

Grant Execute on dbo.fnTermName to public
GO

