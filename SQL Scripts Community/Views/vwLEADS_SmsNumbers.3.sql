if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_SmsNumbers')
	Drop View dbo.vwLEADS_SmsNumbers;
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
Create View dbo.vwLEADS_SmsNumbers
as
select ID
     , NAME
     , FIRST_NAME
     , LAST_NAME
     , TITLE
     , ACCOUNT_NAME
     , ACCOUNT_ID
     , PHONE_HOME
     , PHONE_MOBILE
     , PHONE_WORK
     , PHONE_OTHER
     , PHONE_FAX
     , EMAIL1
     , EMAIL2
     , SMS_OPT_IN
     , cast(null as nvarchar(75)) as ASSISTANT
     , cast(null as nvarchar(25)) as ASSISTANT_PHONE
     , ASSIGNED_TO
     , ASSIGNED_USER_ID
     , TEAM_ID
     , TEAM_NAME
     , TEAM_SET_ID
     , TEAM_SET_NAME
     , N'Leads' as MODULE_TYPE
     , ASSIGNED_SET_ID
     , ASSIGNED_SET_NAME
     , ASSIGNED_SET_LIST
  from vwLEADS_List
 where PHONE_MOBILE is not null
   and len(PHONE_MOBILE) > 0

GO

Grant Select on dbo.vwLEADS_SmsNumbers to public;
GO


