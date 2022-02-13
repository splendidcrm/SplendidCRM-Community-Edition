if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnLocation' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnLocation;
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
-- 08/17/2010 Paul.  Now that we are using this function in the list views, we need to be more efficient. 
Create Function dbo.fnLocation(@CITY nvarchar(100), @STATE nvarchar(100))
returns nvarchar(200)
as
  begin
	declare @DISPLAY_NAME nvarchar(200);
	if @CITY is null begin -- then
		set @DISPLAY_NAME = @STATE;
	end else if @STATE is null begin -- then
		set @DISPLAY_NAME = @CITY;
	end else begin
		set @DISPLAY_NAME = rtrim(isnull(@CITY, N'') + N', ' + isnull(@STATE, N''));
	end -- if;
	return @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.fnLocation to public
GO

