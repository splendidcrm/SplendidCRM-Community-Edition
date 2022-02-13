if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCAMPAIGNS_CALL_MARKETING')
	Drop View dbo.vwCAMPAIGNS_CALL_MARKETING;
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
-- 08/02/2019 Paul.  The React Client needs relationship primary keys. 
Create View dbo.vwCAMPAIGNS_CALL_MARKETING
as
select vwCALL_MARKETING.ID   as CALL_MARKETING_ID
     , vwCALL_MARKETING.NAME as CALL_MARKETING_NAME
     , vwCALL_MARKETING.*
  from      CAMPAIGNS
 inner join vwCALL_MARKETING
         on vwCALL_MARKETING.CAMPAIGN_ID = CAMPAIGNS.ID
 where CAMPAIGNS.DELETED = 0

GO

Grant Select on dbo.vwCAMPAIGNS_CALL_MARKETING to public;
GO

