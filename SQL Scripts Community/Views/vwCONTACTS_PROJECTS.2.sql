if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_PROJECTS')
	Drop View dbo.vwCONTACTS_PROJECTS;
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
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 10/27/2012 Paul.  Project Relations data for Contacts moved to PROJECTS_CONTACTS. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCONTACTS_PROJECTS
as
select CONTACTS.ID               as CONTACT_ID
     , CONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , CONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , dbo.fnFullName(CONTACTS.FIRST_NAME, CONTACTS.LAST_NAME) as CONTACT_NAME
     , vwPROJECTS.ID             as PROJECT_ID
     , vwPROJECTS.NAME           as PROJECT_NAME
     , vwPROJECTS.*
  from            CONTACTS
       inner join PROJECTS_CONTACTS
               on PROJECTS_CONTACTS.CONTACT_ID   = CONTACTS.ID
              and PROJECTS_CONTACTS.DELETED      = 0
       inner join vwPROJECTS
               on vwPROJECTS.ID                  = PROJECTS_CONTACTS.PROJECT_ID
 where CONTACTS.DELETED = 0

GO

Grant Select on dbo.vwCONTACTS_PROJECTS to public;
GO


