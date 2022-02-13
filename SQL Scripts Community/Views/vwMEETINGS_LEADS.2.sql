if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_LEADS')
	Drop View dbo.vwMEETINGS_LEADS;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwMEETINGS_LEADS
as
select MEETINGS.ID               as MEETING_ID
     , MEETINGS.NAME             as MEETING_NAME
     , MEETINGS.ASSIGNED_USER_ID as MEETING_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID  as MEETING_ASSIGNED_SET_ID
     , MEETINGS_LEADS.ACCEPT_STATUS
     , vwLEADS.ID                as LEAD_ID
     , vwLEADS.NAME              as LEAD_NAME
     , vwLEADS.*
  from            MEETINGS
       inner join MEETINGS_LEADS
               on MEETINGS_LEADS.MEETING_ID = MEETINGS.ID
              and MEETINGS_LEADS.DELETED    = 0
       inner join vwLEADS
               on vwLEADS.ID                = MEETINGS_LEADS.LEAD_ID
 where MEETINGS.DELETED = 0
 union all
select MEETINGS.ID               as MEETING_ID
     , MEETINGS.NAME             as MEETING_NAME
     , MEETINGS.ASSIGNED_USER_ID as MEETING_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID  as MEETING_ASSIGNED_SET_ID
     , MEETINGS_LEADS.ACCEPT_STATUS
     , vwLEADS.ID                as LEAD_ID
     , vwLEADS.NAME              as LEAD_NAME
     , vwLEADS.*
  from            MEETINGS
       inner join vwLEADS
               on vwLEADS.ID                = MEETINGS.PARENT_ID
  left outer join MEETINGS_LEADS
               on MEETINGS_LEADS.MEETING_ID = MEETINGS.ID
              and MEETINGS_LEADS.LEAD_ID = vwLEADS.ID
              and MEETINGS_LEADS.DELETED    = 0
 where MEETINGS.DELETED     = 0
   and MEETINGS.PARENT_TYPE = N'Leads'
   and MEETINGS_LEADS.ID is null

GO

Grant Select on dbo.vwMEETINGS_LEADS to public;
GO

