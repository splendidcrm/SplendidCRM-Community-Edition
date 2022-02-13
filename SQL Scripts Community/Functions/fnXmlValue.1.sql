if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnXmlValue' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnXmlValue;
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
Create Function dbo.fnXmlValue(@SEARCH nvarchar(max), @FIND nvarchar(60))
returns nvarchar(255)
as
  begin
	declare @BEGIN_TAG int;
	declare @END_TAG   int;
	declare @VALUE     nvarchar(255);
	set @BEGIN_TAG = charindex('<'  + @FIND + '>', @SEARCH);
	if @BEGIN_TAG > 0 begin -- then
		set @BEGIN_TAG = @BEGIN_TAG + len(@FIND) + 2;
		set @END_TAG   = charindex('</' + @FIND + '>', @SEARCH, @BEGIN_TAG);
		if @END_TAG > 0 and @END_TAG > @BEGIN_TAG begin -- then
			set @VALUE = substring(@SEARCH, @BEGIN_TAG, @END_TAG - @BEGIN_TAG);
		end -- if;
	end -- if;
	return @VALUE;
  end
GO

Grant Execute on dbo.fnXmlValue to public
GO

