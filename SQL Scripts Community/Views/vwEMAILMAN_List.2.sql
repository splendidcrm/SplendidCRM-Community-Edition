if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAILMAN_List')
	Drop View dbo.vwEMAILMAN_List;
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
-- 01/13/2008 Paul.  Use the email manager to generate AutoReplies. 
-- 08/23/2011 Paul.  Campaign emails are being sent to invalid email addresses even after being marked as invalid. 
-- Filter invalid emails at runtime. 
-- 10/27/2017 Paul.  Add Accounts as email source. 
Create View dbo.vwEMAILMAN_List
as
select vwUSERS.FULL_NAME      as RECIPIENT_NAME
     , vwUSERS.EMAIL1         as RECIPIENT_EMAIL
     , cast(0 as bit)         as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwUSERS
         on vwUSERS.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'Users'
union all
select vwCONTACTS.NAME        as RECIPIENT_NAME
     , vwCONTACTS.EMAIL1      as RECIPIENT_EMAIL
     , isnull(vwCONTACTS.INVALID_EMAIL, 0) as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwCONTACTS
         on vwCONTACTS.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'Contacts'
union all
select vwLEADS.NAME           as RECIPIENT_NAME
     , vwLEADS.EMAIL1         as RECIPIENT_EMAIL
     , isnull(vwLEADS.INVALID_EMAIL, 0) as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwLEADS
         on vwLEADS.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'Leads'
union all
select vwPROSPECTS.NAME       as RECIPIENT_NAME
     , vwPROSPECTS.EMAIL1     as RECIPIENT_EMAIL
     , isnull(vwPROSPECTS.INVALID_EMAIL, 0) as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwPROSPECTS
         on vwPROSPECTS.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'Prospects'
union all
select vwINBOUND_EMAIL_AUTOREPLY.AUTOREPLIED_NAME as RECIPIENT_NAME
     , vwINBOUND_EMAIL_AUTOREPLY.AUTOREPLIED_TO   as RECIPIENT_EMAIL
     , cast(0 as bit)                             as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwINBOUND_EMAIL_AUTOREPLY
         on vwINBOUND_EMAIL_AUTOREPLY.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'AutoReply'
union all
select vwACCOUNTS.NAME        as RECIPIENT_NAME
     , vwACCOUNTS.EMAIL1      as RECIPIENT_EMAIL
     , isnull(vwACCOUNTS.INVALID_EMAIL, 0) as INVALID_EMAIL
     , vwEMAILMAN.*
  from      vwEMAILMAN
 inner join vwACCOUNTS
         on vwACCOUNTS.ID = vwEMAILMAN.RELATED_ID
 where vwEMAILMAN.RELATED_TYPE = N'Accounts'

GO

Grant Select on dbo.vwEMAILMAN_List to public;
GO

