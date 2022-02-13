if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_OPPORTUNITIES')
	Drop View dbo.vwCONTACTS_OPPORTUNITIES;
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
-- 09/18/2018 Paul.  Include the opportunities in B2C mode. 
Create View dbo.vwCONTACTS_OPPORTUNITIES
as
select CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , vwOPPORTUNITIES.ID        as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME      as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from           CONTACTS
      inner join OPPORTUNITIES_CONTACTS
              on OPPORTUNITIES_CONTACTS.CONTACT_ID = CONTACTS.ID
             and OPPORTUNITIES_CONTACTS.DELETED    = 0
      inner join vwOPPORTUNITIES
              on vwOPPORTUNITIES.ID                = OPPORTUNITIES_CONTACTS.OPPORTUNITY_ID
 where CONTACTS.DELETED = 0
union
select CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , vwOPPORTUNITIES.ID        as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME      as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from           CONTACTS
      inner join vwOPPORTUNITIES
              on vwOPPORTUNITIES.B2C_CONTACT_ID = CONTACTS.ID
 where CONTACTS.DELETED = 0


GO

Grant Select on dbo.vwCONTACTS_OPPORTUNITIES to public;
GO


