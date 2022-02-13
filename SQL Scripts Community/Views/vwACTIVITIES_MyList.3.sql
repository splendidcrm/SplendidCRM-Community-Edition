if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACTIVITIES_MyList')
	Drop View dbo.vwACTIVITIES_MyList;
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
-- 08/16/2005 Paul.  Only return the date. 
-- 10/23/2005 Paul.  Always return full date as it will need to be converted to the correct timezone.
-- 08/02/2005 Paul.  Although the SugarCRM 3.0 code suggests that declined would not be shown, it actually is shown. 
--        and MEETINGS_USERS.ACCEPT_STATUS <> N'Decline'
--        and CALLS_USERS.ACCEPT_STATUS <> N'Decline'
-- 02/01/2006 Paul.  DB2 does not like comments in the middle of the Create View statement. 
-- 11/22/2006 Paul.  Add TEAM_ID for team management. 
-- 08/30/2009 Paul.  All module views must have a TEAM_SET_ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwACTIVITIES_MyList
as
select N'Meetings'            as ACTIVITY_TYPE
     , vwMEETINGS_List.ID
     , vwMEETINGS_List.NAME
     , vwMEETINGS_List.DATE_START
     , isnull(MEETINGS_USERS.ACCEPT_STATUS, N'none') as ACCEPT_STATUS
     , MEETINGS_USERS.USER_ID as ASSIGNED_USER_ID
     , vwMEETINGS_List.TEAM_ID
     , vwMEETINGS_List.TEAM_NAME
     , vwMEETINGS_List.TEAM_SET_ID
     , vwMEETINGS_List.TEAM_SET_NAME
     , vwMEETINGS_List.ASSIGNED_SET_ID
     , vwMEETINGS_List.ASSIGNED_SET_NAME
     , vwMEETINGS_List.ASSIGNED_SET_LIST
  from            vwMEETINGS_List
       inner join MEETINGS_USERS
               on MEETINGS_USERS.MEETING_ID =  vwMEETINGS_List.ID
              and MEETINGS_USERS.DELETED    =  0
 where STATUS in (N'Planned')
union all
select N'Calls'               as ACTIVITY_TYPE
     , vwCALLS_List.ID
     , vwCALLS_List.NAME
     , vwCALLS_List.DATE_START
     , isnull(CALLS_USERS.ACCEPT_STATUS, N'none') as ACCEPT_STATUS
     , CALLS_USERS.USER_ID    as ASSIGNED_USER_ID
     , vwCALLS_List.TEAM_ID
     , vwCALLS_List.TEAM_NAME
     , vwCALLS_List.TEAM_SET_ID
     , vwCALLS_List.TEAM_SET_NAME
     , vwCALLS_List.ASSIGNED_SET_ID
     , vwCALLS_List.ASSIGNED_SET_NAME
     , vwCALLS_List.ASSIGNED_SET_LIST
  from            vwCALLS_List
       inner join CALLS_USERS
               on CALLS_USERS.CALL_ID       = vwCALLS_List.ID
              and CALLS_USERS.DELETED       = 0
 where STATUS in (N'Planned')

GO

Grant Select on dbo.vwACTIVITIES_MyList to public;
GO

