if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMEETINGS_List')
	Drop View dbo.vwMEETINGS_List;
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
-- 09/11/2009 Paul.  Move the Primary Contact filter out of the where clause as it will prevent us from stubbing the primary function. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwMEETINGS_List
as
select vwMEETINGS.*
     , CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
  from            vwMEETINGS
  left outer join MEETINGS_CONTACTS
               on MEETINGS_CONTACTS.MEETING_ID = vwMEETINGS.ID
              and MEETINGS_CONTACTS.DELETED    = 0
              and MEETINGS_CONTACTS.CONTACT_ID = dbo.fnMEETINGS_CONTACTS_Primary(vwMEETINGS.ID)
  left outer join CONTACTS
               on CONTACTS.ID                  = MEETINGS_CONTACTS.CONTACT_ID
              and CONTACTS.DELETED             = 0

GO

Grant Select on dbo.vwMEETINGS_List to public;
GO


