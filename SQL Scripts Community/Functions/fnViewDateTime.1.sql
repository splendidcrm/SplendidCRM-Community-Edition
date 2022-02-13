if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnViewDateTime' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnViewDateTime;
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
Create Function dbo.fnViewDateTime(@DATE_VALUE datetime, @TIME_VALUE datetime)
returns datetime
as
  begin
	-- 10/23/2005 Paul.  On SQL Server, we store the full datetime.
	return @DATE_VALUE;
  end
GO

Grant Execute on dbo.fnViewDateTime to public;
GO

