if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnCronRun' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnCronRun;
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
-- http://www.adminschoice.com/docs/crontab.htm
-- http://www.hccfl.edu/pollock/Unix/Crontab.htm
/*
Field Descriptions: 
	minute  hour  dayOfMonth  month  dayOfWeek
where:
	minute      values range from 0 to 59
	hour        values range from 0 to 23
	dayOfMonth  values range from 1 to 31
	month       values range from 1 to 12
	dayOfWeek   values range from 0 to 6, with 0 meaning Sunday 

Field Values: 
	NUM             A single value 
	NUM-NUM         A range of values 
	NUM,NUM-NUM,... A comma separated list of values or ranges (remember no spaces after commas!) 
	*               wildcard, meaning match all possible values 
*/
-- 12/31/2007 Paul.  Round the minutes down to the nearest divisor. 
-- We must round down the minutes because the current time will be round down. 
-- 01/01/2008 Paul.  Added lots of extra protection against entering an endless loop. 
-- 01/01/2008 Paul.  Incorporate failsafe counter.  
-- 08/26/2008 Paul.  Parameters are read-only in PostgreSQL, so @CRON and @MINUTE_DIVISOR need to be a local variable. 
Create Function dbo.fnCronRun(@CRON_INPUT nvarchar(100), @CURRENT_TIME datetime, @MINUTE_DIVISOR_INPUT int)
returns bit
as
  begin
	declare @CRON                     nvarchar(100);
	declare @MINUTE_DIVISOR           int;
	declare @CurrentPosR              int;
	declare @NextPosR                 int;
	declare @CRON_TEMP                nvarchar(100);
	declare @CRON_MONTH               nvarchar(100);
	declare @CRON_DAYOFMONTH          nvarchar(100);
	declare @CRON_DAYOFWEEK           nvarchar(100);
	declare @CRON_HOUR                nvarchar(100);
	declare @CRON_MINUTE              nvarchar(100);
	declare @CRON_VALUE               nvarchar(100);
	declare @CRON_VALUE_START         nvarchar(100);
	declare @CRON_VALUE_END           nvarchar(100);
	declare @CRON_VALUE_INT           int;
	declare @CRON_VALUE_START_INT     int;
	declare @CRON_VALUE_END_INT       int;
	-- 01/01/2008 Paul.  We need a failsafe int that will help ensure that a loop never exceed its limit.
	-- For example, the months loop should not exceed 12 iterations, a day loop should not exceed 31,
	-- an hour loop should not exceed 24 and a minute loop should not exceed 60. 
	declare @FAIL_SAFE_INT            int;

	declare @CURRENT_MONTH            int;
	declare @CURRENT_DAYOFMONTH       int;
	declare @CURRENT_LASTDAYOFMONTH   int;
	declare @CURRENT_WEEK             int;
	declare @CURRENT_DAYOFWEEK        int;
	declare @CURRENT_HOUR             int;
	declare @CURRENT_MINUTE           int;

	declare @MATCH_CURRENT_MONTH      bit;
	declare @MATCH_CURRENT_DAYOFMONTH bit;
	declare @MATCH_CURRENT_DAYOFWEEK  bit;
	declare @MATCH_CURRENT_HOUR       bit;
	declare @MATCH_CURRENT_MINUTE     bit;

	-- 08/26/2008 Paul.  Parameters are read-only in PostgreSQL, so @CRON and @MINUTE_DIVISOR need to be a local variable. 
	set @CRON           = @CRON_INPUT;
	set @MINUTE_DIVISOR = @MINUTE_DIVISOR_INPUT;
	-- 12/30/2007 Paul.  Exit early if everything is possible. 
	if charindex(' ', @CRON) > 0 begin -- then
		set @CRON = replace(@CRON, ' ', '');
		----print 'Remove spaces';
	end -- if;
	if @CURRENT_TIME is null begin -- then
		----print 'Current date/time not specified';
		return 0;
	end else if @CRON is null or @CRON = '' or @CRON = '*::*::*::*::*' begin -- then
		----print 'Current pattern matches everything';
		return 1;
	end -- if;
	if @MINUTE_DIVISOR is null or @MINUTE_DIVISOR < 1 begin -- then
		set @MINUTE_DIVISOR = 5;
	end -- if;
	--print 'CRON ' + @CRON;
	--print 'Current Time ' + convert(varchar(30), @CURRENT_TIME, 101) + ' ' + convert(varchar(30), @CURRENT_TIME, 114);

	-- 12/31/2007 Paul.  If the values are not specified, then assume everything. 
	set @CRON_MONTH      = '*';
	set @CRON_DAYOFMONTH = '*';
	set @CRON_DAYOFWEEK  = '*';
	set @CRON_HOUR       = '*';
	set @CRON_MINUTE     = '*';

	set @CurrentPosR = 1;
	-- Minute
	if @CurrentPosR <= len(@CRON) begin -- then
		set @NextPosR = charindex('::', @CRON,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@CRON) + 1;
		end -- if;
		set @CRON_MINUTE = substring(@CRON, @CurrentPosR, @NextPosR - @CurrentPosR);
		set @CurrentPosR = @NextPosR + 2;
	end -- if;
	-- Hour
	if @CurrentPosR <= len(@CRON) begin -- then
		set @NextPosR = charindex('::', @CRON,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@CRON) + 1;
		end -- if;
		set @CRON_HOUR = substring(@CRON, @CurrentPosR, @NextPosR - @CurrentPosR);
		set @CurrentPosR = @NextPosR + 2;
	end -- if;
	-- Day of Month
	if @CurrentPosR <= len(@CRON) begin -- then
		set @NextPosR = charindex('::', @CRON,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@CRON) + 1;
		end -- if;
		set @CRON_DAYOFMONTH = substring(@CRON, @CurrentPosR, @NextPosR - @CurrentPosR);
		set @CurrentPosR = @NextPosR + 2;
	end -- if;
	-- Month
	if @CurrentPosR <= len(@CRON) begin -- then
		set @NextPosR = charindex('::', @CRON,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@CRON) + 1;
		end -- if;
		set @CRON_MONTH = substring(@CRON, @CurrentPosR, @NextPosR - @CurrentPosR);
		set @CurrentPosR = @NextPosR + 2;
	end -- if;
	-- Day of Week
	if @CurrentPosR <= len(@CRON) begin -- then
		set @NextPosR = charindex('::', @CRON,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@CRON) + 1;
		end -- if;
		set @CRON_DAYOFWEEK = substring(@CRON, @CurrentPosR, @NextPosR - @CurrentPosR);
		set @CurrentPosR = @NextPosR + 2;
	end -- if;


	set @MATCH_CURRENT_MONTH = 1;
	set @CURRENT_MONTH = datepart(month, @CURRENT_TIME);
	--print 'Current Month      ' + cast(@CURRENT_MONTH as varchar(10));
	if @CRON_MONTH is not null and @CRON_MONTH <> '*' begin -- then
		set @CurrentPosR = 1;
		set @CRON_TEMP = @CRON_MONTH;
		set @MATCH_CURRENT_MONTH = 0;
		while @CurrentPosR <= len(@CRON_TEMP) and @MATCH_CURRENT_MONTH = 0 begin -- do
			set @NextPosR = charindex(',', @CRON_TEMP,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@CRON_TEMP) + 1;
			end -- if;
			set @CRON_VALUE = substring(@CRON_TEMP, @CurrentPosR, @NextPosR - @CurrentPosR);
			set @CurrentPosR = @NextPosR + 1;

			set @NextPosR = charindex('-', @CRON_VALUE);
			if @NextPosR is not null and @NextPosR > 0 begin -- then
				set @CRON_VALUE_START = substring(@CRON_VALUE, 1, @NextPosR - 1);
				set @CRON_VALUE_END   = substring(@CRON_VALUE, @NextPosR + 1, len(@CRON_VALUE) - @NextPosR);
				if @CRON_VALUE_START is not null and isnumeric(@CRON_VALUE_START) = 1 and @CRON_VALUE_END is not null and isnumeric(@CRON_VALUE_END) = 1 begin -- then
					set @CRON_VALUE_START_INT = cast(@CRON_VALUE_START as int);
					set @CRON_VALUE_END_INT   = cast(@CRON_VALUE_END   as int);
					----print '@CRON_VALUE_START = ' + cast(@CRON_VALUE_START_INT as varchar(10));
					----print '@CRON_VALUE_END   = ' + cast(@CRON_VALUE_END_INT   as varchar(10));
					if @CRON_VALUE_START_INT is not null and @CRON_VALUE_END_INT is not null begin -- then
						set @FAIL_SAFE_INT  = 0;
						set @CRON_VALUE_INT = @CRON_VALUE_START_INT;
						while @FAIL_SAFE_INT < 12 and @CRON_VALUE_INT <= @CRON_VALUE_END_INT and @MATCH_CURRENT_MONTH = 0 begin -- do
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_MONTH begin -- then
								--print '@CURRENT_MONTH between @CRON_VALUE_START_INT and @CRON_VALUE_END_INT';
								set @MATCH_CURRENT_MONTH = 1;
							end -- if;
							set @FAIL_SAFE_INT  = @FAIL_SAFE_INT  + 1;
							set @CRON_VALUE_INT = @CRON_VALUE_INT + 1;
						end -- while;
					end -- if;
				end -- if;
			end else begin
				if @CRON_VALUE is not null and isnumeric(@CRON_VALUE) = 1 begin -- then
					set @CRON_VALUE_INT = cast(@CRON_VALUE as int);
					----print '@CRON_VALUE_INT = ' + cast(@CRON_VALUE_INT as varchar(10));
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_MONTH begin -- then
						--print '@CRON_VALUE_INT = @CURRENT_MONTH';
						set @MATCH_CURRENT_MONTH = 1;
					end -- if;
				end -- if;
			end -- if;
		end -- while;
		-- 12/31/2007 Paul.  Exit early if we can confirm that there is no match.  This will save CPU cycles. 
		if @MATCH_CURRENT_MONTH = 0 begin -- then
			--print '@MATCH_CURRENT_MONTH failed';
			return 0;
		end -- if;
	end -- if;

	set @MATCH_CURRENT_DAYOFMONTH = 1;
	set @CURRENT_DAYOFMONTH = datepart(day, @CURRENT_TIME);
	--print 'Current DayOfMonth ' + cast(@CURRENT_DAYOFMONTH as varchar(10));
	-- 12/31/2007 Paul.  Last Day of Month seems expensive, so only compute if necessary, when value specified = 31. 
	--set @CURRENT_LASTDAYOFMONTH = datepart(day, dateadd(day, -1, dateadd(month, 1, dateadd(day, 1 - @CURRENT_DAYOFMONTH, @CURRENT_TIME))));
	----print 'Current LastDayOfMonth ' + cast(@CURRENT_LASTDAYOFMONTH as varchar(10));
	if @CRON_DAYOFMONTH is not null and @CRON_DAYOFMONTH <> '*' begin -- then
		set @CurrentPosR = 1;
		set @CRON_TEMP = @CRON_DAYOFMONTH;
		set @MATCH_CURRENT_DAYOFMONTH = 0;
		while @CurrentPosR <= len(@CRON_TEMP) and @MATCH_CURRENT_DAYOFMONTH = 0 begin -- do
			set @NextPosR = charindex(',', @CRON_TEMP,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@CRON_TEMP) + 1;
			end -- if;
			set @CRON_VALUE = substring(@CRON_TEMP, @CurrentPosR, @NextPosR - @CurrentPosR);
			set @CurrentPosR = @NextPosR + 1;

			set @NextPosR = charindex('-', @CRON_VALUE);
			if @NextPosR is not null and @NextPosR > 0 begin -- then
				set @CRON_VALUE_START = substring(@CRON_VALUE, 1, @NextPosR - 1);
				set @CRON_VALUE_END   = substring(@CRON_VALUE, @NextPosR + 1, len(@CRON_VALUE) - @NextPosR);
				if @CRON_VALUE_START is not null and isnumeric(@CRON_VALUE_START) = 1 and @CRON_VALUE_END is not null and isnumeric(@CRON_VALUE_END) = 1 begin -- then
					set @CRON_VALUE_START_INT = cast(@CRON_VALUE_START as int);
					set @CRON_VALUE_END_INT   = cast(@CRON_VALUE_END   as int);
					----print '@CRON_VALUE_START = ' + cast(@CRON_VALUE_START_INT as varchar(10));
					----print '@CRON_VALUE_END   = ' + cast(@CRON_VALUE_END_INT   as varchar(10));
					if @CRON_VALUE_START_INT is not null and @CRON_VALUE_END_INT is not null begin -- then
						set @FAIL_SAFE_INT  = 0;
						set @CRON_VALUE_INT = @CRON_VALUE_START_INT;
						while @FAIL_SAFE_INT < 31 and @CRON_VALUE_INT <= @CRON_VALUE_END_INT and @MATCH_CURRENT_DAYOFMONTH = 0 begin -- do
							-- 12/31/2007 Paul.  The value 31 has a special meaning, it means the last day of the month
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = 31 begin -- then
								if @CURRENT_LASTDAYOFMONTH is null begin -- then
									set @CURRENT_LASTDAYOFMONTH = datepart(day, dateadd(day, -1, dateadd(month, 1, dateadd(day, 1 - @CURRENT_DAYOFMONTH, @CURRENT_TIME))));
									--print 'Current LastDayOfMonth ' + cast(@CURRENT_LASTDAYOFMONTH as varchar(10));
								end -- if;
								if @CRON_VALUE_INT > @CURRENT_LASTDAYOFMONTH begin -- then
									set @CRON_VALUE_INT = @CURRENT_LASTDAYOFMONTH;
								end -- if;
							end -- if;
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_DAYOFMONTH begin -- then
								--print '@CURRENT_DAYOFMONTH between @CRON_VALUE_START_INT and @CRON_VALUE_END_INT';
								set @MATCH_CURRENT_DAYOFMONTH = 1;
							end -- if;
							set @FAIL_SAFE_INT  = @FAIL_SAFE_INT  + 1;
							set @CRON_VALUE_INT = @CRON_VALUE_INT + 1;
						end -- while;
					end -- if;
				end -- if;
			end else begin
				if @CRON_VALUE is not null and isnumeric(@CRON_VALUE) = 1 begin -- then
					set @CRON_VALUE_INT = cast(@CRON_VALUE as int);
					----print '@CRON_VALUE_INT = ' + cast(@CRON_VALUE_INT as varchar(10));
					-- 12/31/2007 Paul.  The value 31 has a special meaning, it means the last day of the month
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = 31 begin -- then
						if @CURRENT_LASTDAYOFMONTH is null begin -- then
							set @CURRENT_LASTDAYOFMONTH = datepart(day, dateadd(day, -1, dateadd(month, 1, dateadd(day, 1 - @CURRENT_DAYOFMONTH, @CURRENT_TIME))));
							--print 'Current LastDayOfMonth ' + cast(@CURRENT_LASTDAYOFMONTH as varchar(10));
						end -- if;
						if @CRON_VALUE_INT > @CURRENT_LASTDAYOFMONTH begin -- then
							set @CRON_VALUE_INT = @CURRENT_LASTDAYOFMONTH;
						end -- if;
					end -- if;
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_DAYOFMONTH begin -- then
						--print '@CRON_VALUE_INT = @CURRENT_DAYOFMONTH';
						set @MATCH_CURRENT_DAYOFMONTH = 1;
					end -- if;
				end -- if;
			end -- if;
		end -- while;
		-- 12/31/2007 Paul.  Exit early if we can confirm that there is no match.  This will save CPU cycles. 
		if @MATCH_CURRENT_DAYOFMONTH = 0 begin -- then
			--print '@MATCH_CURRENT_DAYOFMONTH failed';
			return 0;
		end -- if;
	end -- if;

	set @MATCH_CURRENT_DAYOFWEEK = 1;
	set @CURRENT_WEEK = datepart(week, @CURRENT_TIME);
	--print 'Current Week       ' + cast(@CURRENT_WEEK as varchar(10));
	set @CURRENT_DAYOFWEEK = datepart(weekday, @CURRENT_TIME) - 1;
	--print 'Current DayOfWeek  ' + cast(@CURRENT_DAYOFWEEK as varchar(10));
	if @CRON_DAYOFWEEK is not null and @CRON_DAYOFWEEK <> '*' begin -- then
		set @CurrentPosR = 1;
		set @CRON_TEMP = @CRON_DAYOFWEEK;
		set @MATCH_CURRENT_DAYOFWEEK = 0;
		while @CurrentPosR <= len(@CRON_TEMP) and @MATCH_CURRENT_DAYOFWEEK = 0 begin -- do
			set @NextPosR = charindex(',', @CRON_TEMP,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@CRON_TEMP) + 1;
			end -- if;
			set @CRON_VALUE = substring(@CRON_TEMP, @CurrentPosR, @NextPosR - @CurrentPosR);
			set @CurrentPosR = @NextPosR + 1;

			set @NextPosR = charindex('-', @CRON_VALUE);
			if @NextPosR is not null and @NextPosR > 0 begin -- then
				set @CRON_VALUE_START = substring(@CRON_VALUE, 1, @NextPosR - 1);
				set @CRON_VALUE_END   = substring(@CRON_VALUE, @NextPosR + 1, len(@CRON_VALUE) - @NextPosR);
				if @CRON_VALUE_START is not null and isnumeric(@CRON_VALUE_START) = 1 and @CRON_VALUE_END is not null and isnumeric(@CRON_VALUE_END) = 1 begin -- then
					set @CRON_VALUE_START_INT = cast(@CRON_VALUE_START as int);
					set @CRON_VALUE_END_INT   = cast(@CRON_VALUE_END   as int);
					----print '@CRON_VALUE_START = ' + cast(@CRON_VALUE_START_INT as varchar(10));
					----print '@CRON_VALUE_END   = ' + cast(@CRON_VALUE_END_INT   as varchar(10));
					if @CRON_VALUE_START_INT is not null and @CRON_VALUE_END_INT is not null begin -- then
						set @FAIL_SAFE_INT  = 0;
						set @CRON_VALUE_INT = @CRON_VALUE_START_INT;
						while @FAIL_SAFE_INT < 7 and @CRON_VALUE_INT <= @CRON_VALUE_END_INT and @MATCH_CURRENT_DAYOFWEEK = 0 begin -- do
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_DAYOFWEEK begin -- then
								--print '@CURRENT_DAYOFWEEK between @CRON_VALUE_START_INT and @CRON_VALUE_END_INT';
								set @MATCH_CURRENT_DAYOFWEEK = 1;
							end -- if;
							set @FAIL_SAFE_INT  = @FAIL_SAFE_INT  + 1;
							set @CRON_VALUE_INT = @CRON_VALUE_INT + 1;
						end -- while;
					end -- if;
				end -- if;
			end else begin
				if @CRON_VALUE is not null and isnumeric(@CRON_VALUE) = 1 begin -- then
					set @CRON_VALUE_INT = cast(@CRON_VALUE as int);
					----print '@CRON_VALUE_INT = ' + cast(@CRON_VALUE_INT as varchar(10));
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_DAYOFWEEK begin -- then
						--print '@CRON_VALUE_INT = @CURRENT_DAYOFWEEK';
						set @MATCH_CURRENT_DAYOFWEEK = 1;
					end -- if;
				end -- if;
			end -- if;
		end -- while;
		-- 12/31/2007 Paul.  Exit early if we can confirm that there is no match.  This will save CPU cycles. 
		if @MATCH_CURRENT_DAYOFWEEK = 0 begin -- then
			--print '@MATCH_CURRENT_DAYOFWEEK failed';
			return 0;
		end -- if;
	end -- if;

	set @MATCH_CURRENT_HOUR = 1;
	set @CURRENT_HOUR = datepart(hour, @CURRENT_TIME);
	--print 'Current Hour       ' + cast(@CURRENT_HOUR as varchar(10));
	if @CRON_HOUR is not null and @CRON_HOUR <> '*' begin -- then
		set @CurrentPosR = 1;
		set @CRON_TEMP = @CRON_HOUR;
		set @MATCH_CURRENT_HOUR = 0;
		while @CurrentPosR <= len(@CRON_TEMP) and @MATCH_CURRENT_HOUR = 0 begin -- do
			set @NextPosR = charindex(',', @CRON_TEMP,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@CRON_TEMP) + 1;
			end -- if;
			set @CRON_VALUE = substring(@CRON_TEMP, @CurrentPosR, @NextPosR - @CurrentPosR);
			set @CurrentPosR = @NextPosR + 1;

			set @NextPosR = charindex('-', @CRON_VALUE);
			if @NextPosR is not null and @NextPosR > 0 begin -- then
				set @CRON_VALUE_START = substring(@CRON_VALUE, 1, @NextPosR - 1);
				set @CRON_VALUE_END   = substring(@CRON_VALUE, @NextPosR + 1, len(@CRON_VALUE) - @NextPosR);
				if @CRON_VALUE_START is not null and isnumeric(@CRON_VALUE_START) = 1 and @CRON_VALUE_END is not null and isnumeric(@CRON_VALUE_END) = 1 begin -- then
					set @CRON_VALUE_START_INT = cast(@CRON_VALUE_START as int);
					set @CRON_VALUE_END_INT   = cast(@CRON_VALUE_END   as int);
					----print '@CRON_VALUE_START = ' + cast(@CRON_VALUE_START_INT as varchar(10));
					----print '@CRON_VALUE_END   = ' + cast(@CRON_VALUE_END_INT   as varchar(10));
					if @CRON_VALUE_START_INT is not null and @CRON_VALUE_END_INT is not null begin -- then
						set @FAIL_SAFE_INT  = 0;
						set @CRON_VALUE_INT = @CRON_VALUE_START_INT;
						while @FAIL_SAFE_INT < 24 and @CRON_VALUE_INT <= @CRON_VALUE_END_INT and @MATCH_CURRENT_HOUR = 0 begin -- do
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_HOUR begin -- then
								--print '@CURRENT_HOUR between @CRON_VALUE_START_INT and @CRON_VALUE_END_INT';
								set @MATCH_CURRENT_HOUR = 1;
							end -- if;
							set @FAIL_SAFE_INT  = @FAIL_SAFE_INT  + 1;
							set @CRON_VALUE_INT = @CRON_VALUE_INT + 1;
						end -- while;
					end -- if;
				end -- if;
			end else begin
				if @CRON_VALUE is not null and isnumeric(@CRON_VALUE) = 1 begin -- then
					set @CRON_VALUE_INT = cast(@CRON_VALUE as int);
					----print '@CRON_VALUE_INT = ' + cast(@CRON_VALUE_INT as varchar(10));
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_HOUR begin -- then
						--print '@CRON_VALUE_INT = @CURRENT_HOUR';
						set @MATCH_CURRENT_HOUR = 1;
					end -- if;
				end -- if;
			end -- if;
		end -- while;
		-- 12/31/2007 Paul.  Exit early if we can confirm that there is no match.  This will save CPU cycles. 
		if @MATCH_CURRENT_HOUR = 0 begin -- then
			--print '@MATCH_CURRENT_HOUR failed';
			return 0;
		end -- if;
	end -- if;

	set @MATCH_CURRENT_MINUTE = 1;
	set @CURRENT_MINUTE = datepart(minute, @CURRENT_TIME);
	--print 'Current Minute     ' + cast(@CURRENT_MINUTE as varchar(10));
	if @CRON_MINUTE is not null and @CRON_MINUTE <> '*' begin -- then
		set @CurrentPosR = 1;
		set @CRON_TEMP = @CRON_MINUTE;
		set @MATCH_CURRENT_MINUTE = 0;
		while @CurrentPosR <= len(@CRON_TEMP) and @MATCH_CURRENT_MINUTE = 0 begin -- do
			set @NextPosR = charindex(',', @CRON_TEMP,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@CRON_TEMP) + 1;
			end -- if;
			set @CRON_VALUE = substring(@CRON_TEMP, @CurrentPosR, @NextPosR - @CurrentPosR);
			set @CurrentPosR = @NextPosR + 1;

			set @NextPosR = charindex('-', @CRON_VALUE);
			if @NextPosR is not null and @NextPosR > 0 begin -- then
				set @CRON_VALUE_START = substring(@CRON_VALUE, 1, @NextPosR - 1);
				set @CRON_VALUE_END   = substring(@CRON_VALUE, @NextPosR + 1, len(@CRON_VALUE) - @NextPosR);
				if @CRON_VALUE_START is not null and isnumeric(@CRON_VALUE_START) = 1 and @CRON_VALUE_END is not null and isnumeric(@CRON_VALUE_END) = 1 begin -- then
					set @CRON_VALUE_START_INT = cast(@CRON_VALUE_START as int);
					set @CRON_VALUE_END_INT   = cast(@CRON_VALUE_END   as int);
					----print '@CRON_VALUE_START = ' + cast(@CRON_VALUE_START_INT as varchar(10));
					----print '@CRON_VALUE_END   = ' + cast(@CRON_VALUE_END_INT   as varchar(10));
					if @CRON_VALUE_START_INT is not null and @CRON_VALUE_END_INT is not null begin -- then
						set @FAIL_SAFE_INT  = 0;
						set @CRON_VALUE_INT = @CRON_VALUE_START_INT;
						while @FAIL_SAFE_INT < 60 and @CRON_VALUE_INT <= @CRON_VALUE_END_INT and @MATCH_CURRENT_MINUTE = 0 begin -- do
							-- 12/31/2007 Paul.  Round the minutes down to the nearest divisor. 
							set @CRON_VALUE_INT = @CRON_VALUE_INT - (@CRON_VALUE_INT % @MINUTE_DIVISOR);
							if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_MINUTE begin -- then
								--print '@CURRENT_MINUTE between @CRON_VALUE_START_INT and @CRON_VALUE_END_INT';
								set @MATCH_CURRENT_MINUTE = 1;
							end -- if;
							-- 01/01/2008 Paul.  It is extremely important that we increment by the amount of the minute divisor. 
							-- Otherwise we would enter an endless loop where we increment, but then round down. 
							set @FAIL_SAFE_INT  = @FAIL_SAFE_INT  + 1;
							set @CRON_VALUE_INT = @CRON_VALUE_INT + @MINUTE_DIVISOR;
						end -- while;
					end -- if;
				end -- if;
			end else begin
				if @CRON_VALUE is not null and isnumeric(@CRON_VALUE) = 1 begin -- then
					set @CRON_VALUE_INT = cast(@CRON_VALUE as int);
					-- 12/31/2007 Paul.  Round the minutes down to the nearest divisor. 
					set @CRON_VALUE_INT = @CRON_VALUE_INT - (@CRON_VALUE_INT % @MINUTE_DIVISOR);
					----print '@CRON_VALUE_INT = ' + cast(@CRON_VALUE_INT as varchar(10));
					if @CRON_VALUE_INT is not null and @CRON_VALUE_INT = @CURRENT_MINUTE begin -- then
						--print '@CRON_VALUE_INT = @CURRENT_MINUTE';
						set @MATCH_CURRENT_MINUTE = 1;
					end -- if;
				end -- if;
			end -- if;
		end -- while;
		-- 12/31/2007 Paul.  Exit early if we can confirm that there is no match.  This will save CPU cycles. 
		if @MATCH_CURRENT_MINUTE = 0 begin -- then
			--print '@MATCH_CURRENT_MINUTE failed';
			return 0;
		end -- if;
	end -- if;

	-- 12/31/2007 Paul.  We should have already exited if we do not match the current day/time.  The goal is to save CPU cycles. 
	----print 'Match Current Month      ' + cast(@MATCH_CURRENT_MONTH      as varchar(10));
	----print 'Match Current DayOfMonth ' + cast(@MATCH_CURRENT_DAYOFMONTH as varchar(10));
	----print 'Match Current DayOfWeek  ' + cast(@MATCH_CURRENT_DAYOFWEEK  as varchar(10));
	----print 'Match Current Hour       ' + cast(@MATCH_CURRENT_HOUR       as varchar(10));
	----print 'Match Current Minute     ' + cast(@MATCH_CURRENT_MINUTE     as varchar(10));
	--if @MATCH_CURRENT_MONTH = 0 or @MATCH_CURRENT_DAYOFMONTH = 0 or @MATCH_CURRENT_DAYOFWEEK = 0 or @MATCH_CURRENT_HOUR = 0 or @MATCH_CURRENT_MINUTE = 0 begin -- then
	--	----print 'At least one item did not match';
	--	return 0;
	--end -- if;

	--print 'CRON matched!';
	return 1;
  end
GO

-- minute  hour  dayOfMonth  month  dayOfWeek
--declare @NOW datetime;
--set @NOW = '12/31/2007 13:45';
--select dbo.fnTimeRoundMinutes(@NOW, 5)
--     , dbo.fnCronRun('40::*::*::11-12::*', dbo.fnTimeRoundMinutes(@NOW, 5), 5);

Grant Execute on dbo.fnCronRun to public;
GO

