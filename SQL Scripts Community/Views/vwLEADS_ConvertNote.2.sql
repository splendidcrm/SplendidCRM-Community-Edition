if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_ConvertNote')
	Drop View dbo.vwLEADS_ConvertNote;
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
Create View dbo.vwLEADS_ConvertNote
as
select cast(null as nvarchar(255))    as NAME
     , cast(null as nvarchar(25))     as PARENT_TYPE
     , cast(null as uniqueidentifier) as CONTACT_ID
     , cast(null as bit)              as PORTAL_FLAG
     , cast(null as uniqueidentifier) as PARENT_ID
     , cast(null as uniqueidentifier) as NOTE_ATTACHMENT_ID
     , cast(null as nvarchar(255))    as FILENAME
     , cast(null as nvarchar(100))    as FILE_MIME_TYPE
     , cast(null as bit)              as ATTACHMENT_READY
     , cast(null as nvarchar(150))    as PARENT_NAME
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_USER_ID
     , cast(null as uniqueidentifier) as PARENT_ASSIGNED_SET_ID
     , dbo.fnFullName(vwLEADS_Convert.FIRST_NAME, vwLEADS_Convert.LAST_NAME) as CONTACT_NAME
     , PHONE_WORK                     as CONTACT_PHONE
     , EMAIL1                         as CONTACT_EMAIL
     , ASSIGNED_USER_ID               as CONTACT_ASSIGNED_USER_ID
     , ASSIGNED_SET_ID                as CONTACT_ASSIGNED_SET_ID
     , vwLEADS_Convert.*
  from vwLEADS_Convert

GO

Grant Select on dbo.vwLEADS_ConvertNote to public;
GO

 
