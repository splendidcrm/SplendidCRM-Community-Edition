if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOPPORTUNITIES_LEADS')
	Drop View dbo.vwOPPORTUNITIES_LEADS;
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
-- 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwOPPORTUNITIES_LEADS
as
select OPPORTUNITIES.ID               as OPPORTUNITY_ID
     , OPPORTUNITIES.NAME             as OPPORTUNITY_NAME
     , OPPORTUNITIES.ASSIGNED_USER_ID as OPPORTUNITY_ASSIGNED_USER_ID
     , OPPORTUNITIES.ASSIGNED_SET_ID  as OPPORTUNITY_ASSIGNED_SET_ID
     , vwLEADS.ID                     as LEAD_ID
     , vwLEADS.NAME                   as LEAD_NAME
     , vwLEADS.*
  from      OPPORTUNITIES
 inner join LEADS_OPPORTUNITIES
         on LEADS_OPPORTUNITIES.OPPORTUNITY_ID = OPPORTUNITIES.ID
        and LEADS_OPPORTUNITIES.DELETED        = 0
 inner join vwLEADS
         on vwLEADS.ID                         = LEADS_OPPORTUNITIES.LEAD_ID
 where OPPORTUNITIES.DELETED = 0

GO

Grant Select on dbo.vwOPPORTUNITIES_LEADS to public;
GO


