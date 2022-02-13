if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALLS_CONTACTS_Soap')
	Drop View dbo.vwCALLS_CONTACTS_Soap;
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
-- 10/25/2009 Paul.  The view needs to include the call if the contact is a parent. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
Create View dbo.vwCALLS_CONTACTS_Soap
as
select CALLS_CONTACTS.CALL_ID    as PRIMARY_ID
     , CALLS_CONTACTS.CONTACT_ID as RELATED_ID
     , CALLS_CONTACTS.DELETED
     , CALLS.DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(CALLS.DATE_START, CALLS.TIME_START) as DATE_START
  from      CALLS_CONTACTS
 inner join CALLS
         on CALLS.ID         = CALLS_CONTACTS.CALL_ID
        and CALLS.DELETED    = CALLS_CONTACTS.DELETED
 inner join CONTACTS
         on CONTACTS.ID      = CALLS_CONTACTS.CONTACT_ID
        and CONTACTS.DELETED = CALLS_CONTACTS.DELETED
 union
select CALLS.ID                  as PRIMARY_ID
     , CONTACTS.ID               as RELATED_ID
     , CALLS.DELETED
     , CALLS.DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(CALLS.DATE_START, CALLS.TIME_START) as DATE_START
  from      CALLS
 inner join CONTACTS
         on CONTACTS.ID      = CALLS.PARENT_ID
        and CONTACTS.DELETED = CALLS.DELETED
 where CALLS.PARENT_TYPE = N'Contacts'

GO

Grant Select on dbo.vwCALLS_CONTACTS_Soap to public;
GO

