if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_USERS_Soap')
	Drop View dbo.vwCONTACTS_USERS_Soap;
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
-- 02/21/2006 Paul.  A valid relationship is one where all three records are valid. 
-- A deleted record is one where the user is valid but the contact and the relationship are deleted. 
-- 06/13/2007 Paul.  The date to return is that of the related object. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 09/18/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
Create View dbo.vwCONTACTS_USERS_Soap
as
select CONTACTS_USERS.CONTACT_ID as PRIMARY_ID
     , CONTACTS_USERS.USER_ID    as RELATED_ID
     , CONTACTS_USERS.DELETED
     , CONTACTS.DATE_MODIFIED
     , CONTACTS.DATE_MODIFIED_UTC
     , CONTACTS_USERS.SERVICE_NAME
  from      CONTACTS_USERS
 inner join CONTACTS
         on CONTACTS.ID      = CONTACTS_USERS.CONTACT_ID
        and CONTACTS.DELETED = CONTACTS_USERS.DELETED
 inner join USERS
         on USERS.ID         = CONTACTS_USERS.USER_ID
        and USERS.DELETED    = 0
 where CONTACTS_USERS.SERVICE_NAME is null

GO

Grant Select on dbo.vwCONTACTS_USERS_Soap to public;
GO

