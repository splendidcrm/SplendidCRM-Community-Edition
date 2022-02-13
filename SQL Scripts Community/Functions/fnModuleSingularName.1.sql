if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnModuleSingularName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnModuleSingularName;
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
Create Function dbo.fnModuleSingularName(@COLUMN_NAME nvarchar(80))
returns nvarchar(80)
as
  begin
	declare @SINGULAR_NAME nvarchar(80);
	if @COLUMN_NAME is not null and len(@COLUMN_NAME) > 0 begin -- then
		if substring(@COLUMN_NAME, len(@COLUMN_NAME) - 2, 3) = 'IES' begin -- then
			set @SINGULAR_NAME = substring(@COLUMN_NAME, 1, len(@COLUMN_NAME) - 3) + 'Y';
		end else if substring(@COLUMN_NAME, len(@COLUMN_NAME), 1) = 'S' begin -- then
			set @SINGULAR_NAME = substring(@COLUMN_NAME, 1, len(@COLUMN_NAME) - 1);
		end else begin
			set @SINGULAR_NAME = @COLUMN_NAME;
		end -- if;
	end -- if;
	return @SINGULAR_NAME;
  end
GO

Grant Execute on dbo.fnModuleSingularName to public
GO

