if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCombineAddress' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCombineAddress;
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
Create Function dbo.fnCombineAddress
	( @ADDRESS_STREET1    nvarchar(150)
	, @ADDRESS_STREET2    nvarchar(150)
	, @ADDRESS_STREET3    nvarchar(150)
	, @ADDRESS_STREET4    nvarchar(150)
	)
returns nvarchar(600)
as
  begin
	declare @FULL_ADDRESS nvarchar(600);
	set @FULL_ADDRESS = @ADDRESS_STREET1;
	if @ADDRESS_STREET2 is not null and len(@ADDRESS_STREET2) > 0 begin -- then
		if @FULL_ADDRESS is not null begin -- then
			set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + nchar(13) + nchar(10);
		end -- if;
		set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + @ADDRESS_STREET2;
	end -- if;
	if @ADDRESS_STREET3 is not null and len(@ADDRESS_STREET3) > 0 begin -- then
		if @FULL_ADDRESS is not null begin -- then
			set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + nchar(13) + nchar(10);
		end -- if;
		set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + @ADDRESS_STREET3;
	end -- if;
	if @ADDRESS_STREET4 is not null and len(@ADDRESS_STREET4) > 0 begin -- then
		if @FULL_ADDRESS is not null begin -- then
			set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + nchar(13) + nchar(10);
		end -- if;
		set @FULL_ADDRESS = isnull(@FULL_ADDRESS, N'') + @ADDRESS_STREET4;
	end -- if;
	return @FULL_ADDRESS;
  end
GO

Grant Execute on dbo.fnCombineAddress to public
GO

