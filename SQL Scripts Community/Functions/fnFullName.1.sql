if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnFullName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnFullName;
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
-- 04/07/2010 Paul.  We want to trim the middle space. 
-- 08/01/2010 Paul.  Now that we are using this function in the list views, we need to be more efficient. 
Create Function dbo.fnFullName(@FIRST_NAME nvarchar(100), @LAST_NAME nvarchar(100))
returns nvarchar(200)
as
  begin
	declare @FULL_NAME nvarchar(200);
	if @FIRST_NAME is null begin -- then
		set @FULL_NAME = @LAST_NAME;
	end else if @LAST_NAME is null begin -- then
		set @FULL_NAME = @FIRST_NAME;
	end else begin
		set @FULL_NAME = @FIRST_NAME + N' ' + @LAST_NAME;
	end -- if;
	return @FULL_NAME;
  end
GO

Grant Execute on dbo.fnFullName to public
GO

