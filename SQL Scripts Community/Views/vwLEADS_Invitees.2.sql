if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_Invitees')
	Drop View dbo.vwLEADS_Invitees;
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
Create View dbo.vwLEADS_Invitees
as
select ID               as ID
     , N'Leads'         as INVITEE_TYPE
     , NAME             as NAME
     , FIRST_NAME       as FIRST_NAME
     , LAST_NAME        as LAST_NAME
     , EMAIL1           as EMAIL
     , PHONE_WORK       as PHONE
     , ASSIGNED_USER_ID as ASSIGNED_USER_ID
  from vwLEADS
 where EMAIL1 is not null
--   and len(EMAIL1) > 0

GO

Grant Select on dbo.vwLEADS_Invitees to public;
GO


