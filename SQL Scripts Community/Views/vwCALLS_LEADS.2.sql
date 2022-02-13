if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALLS_LEADS')
	Drop View dbo.vwCALLS_LEADS;
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
Create View dbo.vwCALLS_LEADS
as
select CALLS.ID               as CALL_ID
     , CALLS.NAME             as CALL_NAME
     , CALLS.ASSIGNED_USER_ID as CALL_ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID  as CALL_ASSIGNED_SET_ID
     , CALLS_LEADS.ACCEPT_STATUS
     , vwLEADS.ID             as LEAD_ID
     , vwLEADS.NAME           as LEAD_NAME
     , vwLEADS.*
  from            CALLS
       inner join CALLS_LEADS
               on CALLS_LEADS.CALL_ID = CALLS.ID
              and CALLS_LEADS.DELETED = 0
       inner join vwLEADS
               on vwLEADS.ID          = CALLS_LEADS.LEAD_ID
 where CALLS.DELETED = 0
 union all
select CALLS.ID               as CALL_ID
     , CALLS.NAME             as CALL_NAME
     , CALLS.ASSIGNED_USER_ID as CALL_ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID  as CALL_ASSIGNED_SET_ID
     , CALLS_LEADS.ACCEPT_STATUS
     , vwLEADS.ID             as LEAD_ID
     , vwLEADS.NAME           as LEAD_NAME
     , vwLEADS.*
  from            CALLS
       inner join vwLEADS
               on vwLEADS.ID             = CALLS.PARENT_ID
  left outer join CALLS_LEADS
               on CALLS_LEADS.CALL_ID    = CALLS.ID
              and CALLS_LEADS.LEAD_ID    = vwLEADS.ID
              and CALLS_LEADS.DELETED    = 0
 where CALLS.DELETED     = 0
   and CALLS.PARENT_TYPE = N'Leads'
   and CALLS_LEADS.ID is null

GO

Grant Select on dbo.vwCALLS_LEADS to public;
GO

