if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwINVITEES')
	Drop View dbo.vwINVITEES;
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
Create View dbo.vwINVITEES
as
select USERS.ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as FULL_NAME
     , N'Users'    as INVITEE_TYPE
  from USERS
 where DELETED = 0
union all
select CONTACTS.ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as FULL_NAME
     , N'Contacts' as INVITEE_TYPE
  from CONTACTS
 where DELETED = 0
union all
select LEADS.ID
     , rtrim(isnull(FIRST_NAME, N'') + N' ' + isnull(LAST_NAME, N'')) as FULL_NAME
     , N'Leads' as INVITEE_TYPE
  from LEADS
 where DELETED = 0

GO

Grant Select on dbo.vwINVITEES to public;
GO

