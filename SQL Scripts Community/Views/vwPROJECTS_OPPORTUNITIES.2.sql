if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROJECTS_OPPORTUNITIES')
	Drop View dbo.vwPROJECTS_OPPORTUNITIES;
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
-- 12/05/2006 Paul.  Literals should be in unicode to reduce conversions at runtime. 
-- 09/08/2012 Paul.  Project Relations data for Opportunities moved to PROJECTS_OPPORTUNITIES. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwPROJECTS_OPPORTUNITIES
as
select PROJECT.ID               as PROJECT_ID
     , PROJECT.NAME             as PROJECT_NAME
     , PROJECT.ASSIGNED_USER_ID as PROJECT_ASSIGNED_USER_ID
     , PROJECT.ASSIGNED_SET_ID  as PROJECT_ASSIGNED_SET_ID
     , vwOPPORTUNITIES.ID       as OPPORTUNITY_ID
     , vwOPPORTUNITIES.NAME     as OPPORTUNITY_NAME
     , vwOPPORTUNITIES.*
  from            PROJECT
       inner join PROJECTS_OPPORTUNITIES
               on PROJECTS_OPPORTUNITIES.PROJECT_ID     = PROJECT.ID
              and PROJECTS_OPPORTUNITIES.DELETED        = 0
       inner join vwOPPORTUNITIES
               on vwOPPORTUNITIES.ID                    = PROJECTS_OPPORTUNITIES.OPPORTUNITY_ID
 where PROJECT.DELETED = 0

GO

Grant Select on dbo.vwPROJECTS_OPPORTUNITIES to public;
GO


