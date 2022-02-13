if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_CONTACTS_Soap')
	Drop View dbo.vwMEETINGS_CONTACTS_Soap;
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
-- 06/13/2007 Paul.  The date to return is that of the related object. 
-- 10/25/2009 Paul.  The view needs to include the meeting if the contact is a parent. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
Create View dbo.vwMEETINGS_CONTACTS_Soap
as
select MEETINGS_CONTACTS.MEETING_ID as PRIMARY_ID
     , MEETINGS_CONTACTS.CONTACT_ID as RELATED_ID
     , MEETINGS_CONTACTS.DELETED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
  from      MEETINGS_CONTACTS
 inner join MEETINGS
         on MEETINGS.ID      = MEETINGS_CONTACTS.MEETING_ID
        and MEETINGS.DELETED = MEETINGS_CONTACTS.DELETED
 inner join CONTACTS
         on CONTACTS.ID      = MEETINGS_CONTACTS.CONTACT_ID
        and CONTACTS.DELETED = MEETINGS_CONTACTS.DELETED
 union
select MEETINGS.ID                  as PRIMARY_ID
     , CONTACTS.ID                  as RELATED_ID
     , MEETINGS.DELETED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
  from      MEETINGS
 inner join CONTACTS
         on CONTACTS.ID      = MEETINGS.PARENT_ID
        and CONTACTS.DELETED = MEETINGS.DELETED
 where MEETINGS.PARENT_TYPE = N'Contacts'

GO

Grant Select on dbo.vwMEETINGS_CONTACTS_Soap to public;
GO

