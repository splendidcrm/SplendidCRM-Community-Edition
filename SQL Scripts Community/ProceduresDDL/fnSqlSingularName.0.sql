if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnSqlSingularName' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnSqlSingularName;
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
Create Function dbo.fnSqlSingularName(@NAME varchar(80))
returns varchar(80)
as
  begin
	declare @SINGULAR_NAME varchar(80);
	if right(@NAME, 3) = 'IES' begin -- then
		set @SINGULAR_NAME = substring(@NAME, 1, len(@NAME) - 3) + 'Y';
	end else if right(@NAME, 1) = 'S' begin -- then
		set @SINGULAR_NAME = substring(@NAME, 1, len(@NAME) - 1);
	end else begin
		set @SINGULAR_NAME = @NAME;
	end -- if;
	return @SINGULAR_NAME;
  end
GO

Grant Execute on dbo.fnSqlSingularName to public
GO



