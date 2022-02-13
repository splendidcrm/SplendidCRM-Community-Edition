if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCALLS_NOTES')
	Drop View dbo.vwCALLS_NOTES;
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
-- 02/01/2006 Paul.  DB2 does not like to return NULL.  So cast NULL to the correct data type. 
-- 04/21/2006 Paul.  Email does have a status, make sure to return it.
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create View dbo.vwCALLS_NOTES
as
select CALLS.ID                  as CALL_ID
     , CALLS.NAME                as CALL_NAME
     , CALLS.ASSIGNED_USER_ID    as CALL_ASSIGNED_USER_ID
     , CALLS.ASSIGNED_SET_ID     as CALL_ASSIGNED_SET_ID
     , vwNOTES.ID                as NOTE_ID
     , vwNOTES.NAME              as NOTE_NAME
     , vwNOTES.*
  from           CALLS
      inner join vwNOTES
              on vwNOTES.PARENT_ID   = CALLS.ID
             and vwNOTES.PARENT_TYPE = N'Calls'
 where CALLS.DELETED = 0

GO

Grant Select on dbo.vwCALLS_NOTES to public;
GO

