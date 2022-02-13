if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnDatePart' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnDatePart;
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
Create Function dbo.fnDatePart(@DATE_PART varchar(20), @VALUE datetime)
returns int
as
  begin
	if          @DATE_PART = 'year'        or @DATE_PART = 'yy' or @DATE_PART = 'yyyy' begin -- then
		return datepart(  year       ,    @VALUE);
	end else if @DATE_PART = 'quarter'     or @DATE_PART = 'qq' or @DATE_PART = 'q' begin -- then
		return datepart(  quarter    ,    @VALUE);
	end else if @DATE_PART = 'month'       or @DATE_PART = 'mm' or @DATE_PART = 'm' begin -- then
		return datepart(  month      ,    @VALUE);
	end else if @DATE_PART = 'dayofyear'   or @DATE_PART = 'dy' or @DATE_PART = 'y' begin -- then
		return datepart(  dayofyear  ,    @VALUE);
	end else if @DATE_PART = 'day'         or @DATE_PART = 'dd' or @DATE_PART = 'd' begin -- then
		return datepart(  day        ,    @VALUE);
	end else if @DATE_PART = 'week'        or @DATE_PART = 'ww' or @DATE_PART = 'wk' begin -- then
		return datepart(  week       ,    @VALUE);
	end else if @DATE_PART = 'weekday'     or @DATE_PART = 'dw' begin -- then
		return datepart(  weekday    ,    @VALUE);
	end else if @DATE_PART = 'hour'        or @DATE_PART = 'hh' begin -- then
		return datepart(  hour       ,    @VALUE);
	end else if @DATE_PART = 'minute'      or @DATE_PART = 'mi' or @DATE_PART = 'n' begin -- then
		return datepart(  minute     ,    @VALUE);
	end else if @DATE_PART = 'second'      or @DATE_PART = 'ss' or @DATE_PART = 's' begin -- then
		return datepart(  second     ,    @VALUE);
	end else if @DATE_PART = 'millisecond' or @DATE_PART = 'ms' begin -- then
		return datepart(  millisecond,    @VALUE);
	end -- if;
	return null;
  end
GO

Grant Execute on dbo.fnDatePart to public;
GO


