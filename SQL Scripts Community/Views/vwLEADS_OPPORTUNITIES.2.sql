if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwvwOPPORTUNITIES_LEADS')
	Drop View dbo.vwvwOPPORTUNITIES_LEADS;
GO

if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_OPPORTUNITIES')
	Drop View dbo.vwLEADS_OPPORTUNITIES;
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
-- 11/02/2017 Paul.  Correct the view name. 
Create View dbo.vwLEADS_OPPORTUNITIES
as
select vwOPPORTUNITIES.ID     as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME   as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from vwOPPORTUNITIES

GO

Grant Select on dbo.vwLEADS_OPPORTUNITIES to public;
GO


