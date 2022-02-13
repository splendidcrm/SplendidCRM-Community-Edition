if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_LEADS_Soap')
	Drop View dbo.vwMEETINGS_LEADS_Soap;
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
Create View dbo.vwMEETINGS_LEADS_Soap
as
select MEETINGS_LEADS.MEETING_ID as PRIMARY_ID
     , MEETINGS_LEADS.LEAD_ID    as RELATED_ID
     , MEETINGS_LEADS.DELETED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
  from      MEETINGS_LEADS
 inner join MEETINGS
         on MEETINGS.ID      = MEETINGS_LEADS.MEETING_ID
        and MEETINGS.DELETED = MEETINGS_LEADS.DELETED
 inner join LEADS
         on LEADS.ID      = MEETINGS_LEADS.LEAD_ID
        and LEADS.DELETED = MEETINGS_LEADS.DELETED
 union
select MEETINGS.ID                  as PRIMARY_ID
     , LEADS.ID                     as RELATED_ID
     , MEETINGS.DELETED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
  from      MEETINGS
 inner join LEADS
         on LEADS.ID      = MEETINGS.PARENT_ID
        and LEADS.DELETED = MEETINGS.DELETED
 where MEETINGS.PARENT_TYPE = N'Leads'

GO

Grant Select on dbo.vwMEETINGS_LEADS_Soap to public;
GO

