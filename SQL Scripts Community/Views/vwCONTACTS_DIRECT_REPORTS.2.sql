if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_DIRECT_REPORTS')
	Drop View dbo.vwCONTACTS_DIRECT_REPORTS;
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
-- 11/27/2006 Paul.  Add TEAM_ID. 
-- 11/27/2006 Paul.  Return TEAM.ID so that a deleted team will return NULL even if a value remains in the related record. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 10/25/2010 Paul.  TEAM_SET_LIST is needed by the RulesWizard. 
-- 12/04/2012 Paul.  Change the view to return all vwCONTACTS fields. 
-- 12/04/2012 Paul.  It may seem odd to use CONTACT_ID as the name of the parent ID, but that is the convention for relationship views. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCONTACTS_DIRECT_REPORTS
as
select vwCONTACTS.REPORTS_TO_ID    as CONTACT_ID
     , vwCONTACTS.NAME             as CONTACT_NAME
     , vwCONTACTS.ASSIGNED_USER_ID as CONTACT_ASSIGNED_USER_ID
     , vwCONTACTS.ASSIGNED_SET_ID  as CONTACT_ASSIGNED_SET_ID
     , vwCONTACTS.ID               as DIRECT_REPORT_ID
     , vwCONTACTS.NAME             as DIRECT_REPORT_NAME
     , vwCONTACTS.ASSIGNED_USER_ID as DIRECT_REPORT_ASSIGNED_USER_ID
     , vwCONTACTS.ASSIGNED_SET_ID  as DIRECT_REPORT_ASSIGNED_SET_ID
     , vwCONTACTS.*
  from vwCONTACTS
GO

Grant Select on dbo.vwCONTACTS_DIRECT_REPORTS to public;
GO

