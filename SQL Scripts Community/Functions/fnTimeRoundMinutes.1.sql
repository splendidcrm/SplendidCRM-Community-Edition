if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTimeRoundMinutes' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTimeRoundMinutes;
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
Create Function dbo.fnTimeRoundMinutes(@VALUE datetime, @MINUTE_DIVISOR int)
returns datetime
as
  begin
	declare @MINUTES      int;
	declare @SECONDS      int;
	declare @MILLISECONDS int;
	if @VALUE is null or @MINUTE_DIVISOR is null or @MINUTE_DIVISOR <= 0 begin -- then
		return null;
	end -- if;
	set @MINUTES      = datepart(minute     , @VALUE);
	set @SECONDS      = datepart(second     , @VALUE);
	set @MILLISECONDS = datepart(millisecond, @VALUE);
	return dateadd(minute, -(@MINUTES % @MINUTE_DIVISOR), dateadd(second, -@SECONDS, dateadd(millisecond, -@MILLISECONDS, @VALUE)));
  end
GO

Grant Execute on dbo.fnTimeRoundMinutes to public;
GO

