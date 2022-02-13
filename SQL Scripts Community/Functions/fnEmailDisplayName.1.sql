if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnEmailDisplayName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnEmailDisplayName;
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
Create Function dbo.fnEmailDisplayName(@FROM_NAME nvarchar(100), @FROM_ADDR nvarchar(100))
returns nvarchar(200)
as
  begin
	declare @DISPLAY_NAME nvarchar(200);
	if @FROM_NAME is null begin -- then
		set @DISPLAY_NAME = N' <' + @FROM_ADDR + N'>';
	end else if @FROM_ADDR is null begin -- then
		set @DISPLAY_NAME = @FROM_NAME;
	end else begin
		set @DISPLAY_NAME = @FROM_NAME + N' <' + @FROM_ADDR + N'>';
	end -- if;
	return @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.fnEmailDisplayName to public
GO

