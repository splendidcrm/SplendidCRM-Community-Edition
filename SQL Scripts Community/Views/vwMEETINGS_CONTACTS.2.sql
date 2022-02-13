if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_CONTACTS')
	Drop View dbo.vwMEETINGS_CONTACTS;
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
-- 10/25/2009 Paul.  The view needs to include the meeting if the contact is a parent. 
-- 07/27/2010 Paul.  Add ACCEPT_STATUS so that it can be references in the layout view. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwMEETINGS_CONTACTS
as
select MEETINGS.ID               as MEETING_ID
     , MEETINGS.NAME             as MEETING_NAME
     , MEETINGS.ASSIGNED_USER_ID as MEETING_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID  as MEETING_ASSIGNED_SET_ID
     , MEETINGS_CONTACTS.ACCEPT_STATUS
     , vwCONTACTS.ID             as CONTACT_ID
     , vwCONTACTS.NAME           as CONTACT_NAME
     , vwCONTACTS.*
  from            MEETINGS
       inner join MEETINGS_CONTACTS
               on MEETINGS_CONTACTS.MEETING_ID = MEETINGS.ID
              and MEETINGS_CONTACTS.DELETED    = 0
       inner join vwCONTACTS
               on vwCONTACTS.ID                = MEETINGS_CONTACTS.CONTACT_ID
 where MEETINGS.DELETED = 0
 union all
select MEETINGS.ID               as MEETING_ID
     , MEETINGS.NAME             as MEETING_NAME
     , MEETINGS.ASSIGNED_USER_ID as MEETING_ASSIGNED_USER_ID
     , MEETINGS.ASSIGNED_SET_ID  as MEETING_ASSIGNED_SET_ID
     , MEETINGS_CONTACTS.ACCEPT_STATUS
     , vwCONTACTS.ID             as CONTACT_ID
     , vwCONTACTS.NAME           as CONTACT_NAME
     , vwCONTACTS.*
  from            MEETINGS
       inner join vwCONTACTS
               on vwCONTACTS.ID                = MEETINGS.PARENT_ID
  left outer join MEETINGS_CONTACTS
               on MEETINGS_CONTACTS.MEETING_ID = MEETINGS.ID
              and MEETINGS_CONTACTS.CONTACT_ID = vwCONTACTS.ID
              and MEETINGS_CONTACTS.DELETED    = 0
 where MEETINGS.DELETED     = 0
   and MEETINGS.PARENT_TYPE = N'Contacts'
   and MEETINGS_CONTACTS.ID is null

GO

Grant Select on dbo.vwMEETINGS_CONTACTS to public;
GO

