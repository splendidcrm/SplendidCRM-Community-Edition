if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnWeekOnly' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnWeekOnly;
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
Create Function dbo.fnWeekOnly(@VALUE datetime)
returns nvarchar(10)
as
  begin
	if datepart(week, @VALUE) >= 10 begin -- then
		return cast(year(@VALUE) as char(4)) + ' W'  + cast(datepart(week, @VALUE) as char(2));
	end -- if;
	return cast(year(@VALUE) as char(4)) + ' W0' + cast(datepart(week, @VALUE) as char(1));
  end
GO

Grant Execute on dbo.fnWeekOnly to public;
GO

