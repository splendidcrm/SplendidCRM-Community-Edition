if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSCHEDULERS_Run')
	Drop View dbo.vwSCHEDULERS_Run;
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
-- 12/31/2007 Paul.  When comparing against the CRON pattern, round the time down to the nearest 5 minute interval. 
-- 01/18/2008 Paul.  Lets make sure that the CheckVersion occurs shortly after application install. 
-- The trick is to skip the CRON filter if the CheckVersion job has never run. 
-- 01/18/2008 Paul.  Simplify code to handle LAST_RUN to match the Oracle implementation. 
Create View dbo.vwSCHEDULERS_Run
as
select vwSCHEDULERS.*
     , dbo.fnTimeRoundMinutes(getdate(), 5) as NEXT_RUN
  from vwSCHEDULERS
 where STATUS = N'Active'
   and (DATE_TIME_START is null or getdate() > DATE_TIME_START)
   and (DATE_TIME_END   is null or getdate() < DATE_TIME_END  )
   and (TIME_FROM       is null or getdate() > (dbo.fnDateAdd_Time(TIME_FROM, dbo.fnDateOnly(getdate()))))
   and (TIME_TO         is null or getdate() < (dbo.fnDateAdd_Time(TIME_TO  , dbo.fnDateOnly(getdate()))))
   and (   (JOB = N'function::CheckVersion' and LAST_RUN is null)
        or dbo.fnCronRun(JOB_INTERVAL, dbo.fnTimeRoundMinutes(getdate(), 5), 5) = 1
       )
   and (LAST_RUN is null or dbo.fnTimeRoundMinutes(getdate(), 5) > dbo.fnTimeRoundMinutes(LAST_RUN, 5))
GO

Grant Select on dbo.vwSCHEDULERS_Run to public;
GO

