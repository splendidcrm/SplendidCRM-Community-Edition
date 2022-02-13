if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnFormatPhone' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnFormatPhone;
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
Create Function dbo.fnFormatPhone(@PHONE nvarchar(25))
returns nvarchar(25)
as
  begin
	declare @FORMATTED nvarchar(25);
	set @FORMATTED = dbo.fnNormalizePhone(@PHONE);
	if @FORMATTED is not null begin -- then
		if substring(@FORMATTED, 1, 1) = '1' and len(@FORMATTED) = 11 begin -- then
			if @FORMATTED like '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' begin -- then
				set @FORMATTED = substring(@FORMATTED, 2, 10);
			end -- if;
		end -- if;
	
		-- 11/24/2017 Paul.  Any phone numbers without 10 characters are returned unmodified, except for trim. 
		if len(@FORMATTED) <> 10 begin -- then
			return ltrim(rtrim(@PHONE));
		end -- if;
	
		-- 11/24/2017 Paul.  Build US standard phone number. 
		set @FORMATTED = '(' + substring(@FORMATTED,1,3) + ') ' + substring(@FORMATTED, 4, 3) + '-' + substring(@FORMATTED, 7 ,4);
	end -- if;
	return @FORMATTED;
  end
GO

Grant Execute on dbo.fnFormatPhone to public
GO

