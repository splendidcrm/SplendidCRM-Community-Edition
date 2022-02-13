if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGN_LOG_List')
	Drop View dbo.vwCAMPAIGN_LOG_List;
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
Create View dbo.vwCAMPAIGN_LOG_List
as
select vwUSERS.FULL_NAME      as RECIPIENT_NAME
     , vwUSERS.EMAIL1         as RECIPIENT_EMAIL
     , vwCAMPAIGN_LOG.*
  from      vwCAMPAIGN_LOG
 inner join vwUSERS
         on vwUSERS.ID = vwCAMPAIGN_LOG.TARGET_ID
 where vwCAMPAIGN_LOG.TARGET_TYPE = N'Users'
union all
select vwCONTACTS.NAME        as RECIPIENT_NAME
     , vwCONTACTS.EMAIL1      as RECIPIENT_EMAIL
     , vwCAMPAIGN_LOG.*
  from      vwCAMPAIGN_LOG
 inner join vwCONTACTS
         on vwCONTACTS.ID = vwCAMPAIGN_LOG.TARGET_ID
 where vwCAMPAIGN_LOG.TARGET_TYPE = N'Contacts'
union all
select vwLEADS.NAME           as RECIPIENT_NAME
     , vwLEADS.EMAIL1         as RECIPIENT_EMAIL
     , vwCAMPAIGN_LOG.*
  from      vwCAMPAIGN_LOG
 inner join vwLEADS
         on vwLEADS.ID = vwCAMPAIGN_LOG.TARGET_ID
 where vwCAMPAIGN_LOG.TARGET_TYPE = N'Leads'
union all
select vwPROSPECTS.NAME       as RECIPIENT_NAME
     , vwPROSPECTS.EMAIL1     as RECIPIENT_EMAIL
     , vwCAMPAIGN_LOG.*
  from      vwCAMPAIGN_LOG
 inner join vwPROSPECTS
         on vwPROSPECTS.ID = vwCAMPAIGN_LOG.TARGET_ID
 where vwCAMPAIGN_LOG.TARGET_TYPE = N'Prospects'

GO

Grant Select on dbo.vwCAMPAIGN_LOG_List to public;
GO

