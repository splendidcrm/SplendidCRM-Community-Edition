if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_Roi')
	Drop View dbo.vwCAMPAIGNS_Roi;
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
Create View dbo.vwCAMPAIGNS_Roi
as
select vwCAMPAIGNS.*
     , (select count(*)
          from OPPORTUNITIES
         where CAMPAIGN_ID = vwCAMPAIGNS.ID
           and SALES_STAGE = N'Closed Won'
           and DELETED     = 0
       )                                    as OPPORTUNITIES_WON
     , ACTUAL_COST_USDOLLAR / nullif(IMPRESSIONS, 0) as COST_PER_IMPRESSION
     , (select vwCAMPAIGNS.ACTUAL_COST_USDOLLAR / nullif(count(*), 0)
         from CAMPAIGN_LOG
        where CAMPAIGN_ID = vwCAMPAIGNS.ID
          and ACTIVITY_TYPE = N'link'
       )                                    as COST_PER_CLICK_THROUGH
     , (select sum(AMOUNT_USDOLLAR)
          from OPPORTUNITIES
         where CAMPAIGN_ID = vwCAMPAIGNS.ID
           and SALES_STAGE = N'Closed Won'
           and DELETED     = 0
       )                   as REVENUE
  from vwCAMPAIGNS

GO

Grant Select on dbo.vwCAMPAIGNS_Roi to public;
GO

