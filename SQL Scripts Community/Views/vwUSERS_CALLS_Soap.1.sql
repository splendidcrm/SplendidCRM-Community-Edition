if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_CALLS_Soap')
	Drop View dbo.vwUSERS_CALLS_Soap;
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
-- 02/21/2006 Paul.  A valid relationship is one where all three records are valid. 
-- A deleted record is one where the user is valid but the contact and the relationship are deleted. 
-- 06/13/2007 Paul.  The date to return is that of the related object. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
Create View dbo.vwUSERS_CALLS_Soap
as
select CALLS_USERS.USER_ID    as PRIMARY_ID
     , CALLS_USERS.CALL_ID    as RELATED_ID
     , CALLS_USERS.DELETED
     , CALLS.DATE_MODIFIED
     , CALLS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(CALLS.DATE_START, CALLS.TIME_START) as DATE_START
  from      CALLS_USERS
 inner join CALLS
         on CALLS.ID      = CALLS_USERS.CALL_ID
        and CALLS.DELETED = CALLS_USERS.DELETED
 inner join USERS
         on USERS.ID      = CALLS_USERS.USER_ID
        and USERS.DELETED = 0

GO

Grant Select on dbo.vwUSERS_CALLS_Soap to public;
GO

