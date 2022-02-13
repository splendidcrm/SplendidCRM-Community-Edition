if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnNormalizePhone' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnNormalizePhone;
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
-- 11/24/2017 Paul.  Convert empty string to null. 
-- 08/15/2018 Paul.  Use like clause for more flexible phone number lookup. 
Create Function dbo.fnNormalizePhone(@PHONE nvarchar(25))
returns nvarchar(25)
as
  begin
	declare @NORMALIZED nvarchar(25);
	set @NORMALIZED = @PHONE;
	if @NORMALIZED is not null begin -- then
		set @NORMALIZED = replace(@NORMALIZED, N' ', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'+', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'(', N'');
		set @NORMALIZED = replace(@NORMALIZED, N')', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'-', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'.', N'');
		-- 08/15/2018 Paul.  Use like clause for more flexible phone number lookup. 
		set @NORMALIZED = replace(@NORMALIZED, N'[', N'');
		set @NORMALIZED = replace(@NORMALIZED, N']', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'#', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'*', N'');
		set @NORMALIZED = replace(@NORMALIZED, N'%', N'');
		if len(@NORMALIZED) = 0 begin -- then
			set @NORMALIZED = null;
		end -- if;
	end -- if;
	return @NORMALIZED;
  end
GO

Grant Execute on dbo.fnNormalizePhone to public
GO

