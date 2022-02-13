if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCamelCase' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCamelCase;
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
Create Function dbo.fnCamelCase(@NAME nvarchar(255))
returns nvarchar(255)
as
  begin
	declare @CAMEL_NAME  nvarchar(255);
	declare @CurrentPosR  int;
	declare @NextPosR     int;
	set @CAMEL_NAME = lower(@NAME);
	set @CAMEL_NAME = upper(left(@CAMEL_NAME, 1)) + substring(@CAMEL_NAME, 2, len(@NAME));

	set @CurrentPosR = 1;
	while charindex(' ', @CAMEL_NAME,  @CurrentPosR) > 0 begin -- do
		set @NextPosR = charindex(' ', @CAMEL_NAME,  @CurrentPosR);
		set @CAMEL_NAME = left(@CAMEL_NAME, @NextPosR-1) + ' ' + upper(substring(@CAMEL_NAME, @NextPosR+1, 1)) + substring(@CAMEL_NAME, @NextPosR+2, len(@NAME));
		set @CurrentPosR = @NextPosR+1;
	end -- while;
	return @CAMEL_NAME;
  end
GO

Grant Execute on dbo.fnCamelCase to public
GO

