if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_Invitees')
	Drop View dbo.vwMEETINGS_Invitees;
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
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
Create View dbo.vwMEETINGS_Invitees
as
select MEETING_ID
     , CONTACT_ID  as INVITEE_ID
     , N'Contacts' as INVITEE_TYPE
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as INVITEE_NAME
  from      MEETINGS_CONTACTS
 inner join CONTACTS
         on CONTACTS.ID       = MEETINGS_CONTACTS.CONTACT_ID
        and CONTACTS.DELETED  = 0
 where MEETINGS_CONTACTS.DELETED = 0
union all
select MEETING_ID
     , USER_ID     as INVITEE_ID
     , N'Users'    as INVITEE_TYPE
     , dbo.fnFullName(USERS.FIRST_NAME, USERS.LAST_NAME) as INVITEE_NAME
  from      MEETINGS_USERS
 inner join USERS
         on USERS.ID          = MEETINGS_USERS.USER_ID
        and USERS.DELETED     = 0
 where MEETINGS_USERS.DELETED    = 0
union all
select MEETING_ID
     , LEAD_ID  as INVITEE_ID
     , N'Leads' as INVITEE_TYPE
     , dbo.fnFullName(LEADS.FIRST_NAME, LEADS.LAST_NAME) as INVITEE_NAME
  from      MEETINGS_LEADS
 inner join LEADS
         on LEADS.ID       = MEETINGS_LEADS.LEAD_ID
        and LEADS.DELETED  = 0
 where MEETINGS_LEADS.DELETED = 0

GO

Grant Select on dbo.vwMEETINGS_Invitees to public;
GO

