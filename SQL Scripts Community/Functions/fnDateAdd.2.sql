if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnDateAdd' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnDateAdd;
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
Create Function dbo.fnDateAdd(@DATE_PART varchar(20), @INTERVAL int, @VALUE datetime)
returns datetime
as
  begin
	if @DATE_PART = 'year' begin -- then
		return dateadd(year, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'quarter' begin -- then
		return dateadd(quarter, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'month' begin -- then
		return dateadd(month, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'week' begin -- then
		return dateadd(week, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'day' begin -- then
		return dateadd(day, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'hour' begin -- then
		return dateadd(hour, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'minute' begin -- then
		return dateadd(minute, @INTERVAL, @VALUE);
	end else if @DATE_PART = 'second' begin -- then
		return dateadd(second, @INTERVAL, @VALUE);
	end -- if;
	return null;
  end
GO

Grant Execute on dbo.fnDateAdd to public;
GO

