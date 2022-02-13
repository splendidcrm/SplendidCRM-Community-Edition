if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_CASES')
	Drop View dbo.vwCONTACTS_CASES;
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
-- 11/11/2013 Paul.  Use a union so that his view can also be used when in B2C mode. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCONTACTS_CASES
as
select CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , vwCASES.ID                as CASE_ID
     , vwCASES.NAME              as CASE_NAME
     , vwCASES.*
  from           CONTACTS
      inner join CONTACTS_CASES
              on CONTACTS_CASES.CONTACT_ID = CONTACTS.ID
             and CONTACTS_CASES.DELETED    = 0
      inner join vwCASES
              on vwCASES.ID                = CONTACTS_CASES.CASE_ID
 where CONTACTS.DELETED = 0
union
select CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , vwCASES.ID                as CASE_ID
     , vwCASES.NAME              as CASE_NAME
     , vwCASES.*
  from           CONTACTS
      inner join vwCASES
              on vwCASES.B2C_CONTACT_ID = CONTACTS.ID
 where CONTACTS.DELETED = 0

GO

Grant Select on dbo.vwCONTACTS_CASES to public;
GO


