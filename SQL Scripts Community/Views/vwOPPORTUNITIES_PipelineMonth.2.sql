if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOPPORTUNITIES_PipelineMonth')
	Drop View dbo.vwOPPORTUNITIES_PipelineMonth;
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
-- 11/27/2006 Paul.  Add TEAM_ID. 
-- 08/30/2009 Paul.  Dynamic teams required an ID and TEAM_SET_ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwOPPORTUNITIES_PipelineMonth
as
select OPPORTUNITIES.ID
     , (case OPPORTUNITIES.SALES_STAGE
        when N'Closed Lost' then N'Closed Lost'
        when N'Closed Won'  then N'Closed Won'  
        else N'Other'
        end) as SALES_STAGE
     , OPPORTUNITIES.ASSIGNED_USER_ID
     , OPPORTUNITIES.AMOUNT_USDOLLAR
     , OPPORTUNITIES.DATE_CLOSED
     , OPPORTUNITIES.TEAM_ID
     , OPPORTUNITIES.TEAM_SET_ID
     , month(OPPORTUNITIES.DATE_CLOSED) as MONTH_CLOSED
     , ASSIGNED_SETS.ID                as ASSIGNED_SET_ID
     , ASSIGNED_SETS.ASSIGNED_SET_NAME as ASSIGNED_SET_NAME
     , ASSIGNED_SETS.ASSIGNED_SET_LIST as ASSIGNED_SET_LIST
  from            OPPORTUNITIES
       inner join USERS
               on USERS.ID              = OPPORTUNITIES.ASSIGNED_USER_ID
              and USERS.DELETED         = 0
  left outer join ASSIGNED_SETS
               on ASSIGNED_SETS.ID      = OPPORTUNITIES.ASSIGNED_SET_ID
              and ASSIGNED_SETS.DELETED = 0
 where OPPORTUNITIES.DELETED = 0

GO

Grant Select on dbo.vwOPPORTUNITIES_PipelineMonth to public;
GO

