if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_MEETINGS_Soap')
	Drop View dbo.vwUSERS_MEETINGS_Soap;
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
Create View dbo.vwUSERS_MEETINGS_Soap
as
select MEETINGS_USERS.USER_ID    as PRIMARY_ID
     , MEETINGS_USERS.MEETING_ID as RELATED_ID
     , MEETINGS_USERS.DELETED
     , MEETINGS.DATE_MODIFIED
     , MEETINGS.DATE_MODIFIED_UTC
     , dbo.fnViewDateTime(MEETINGS.DATE_START, MEETINGS.TIME_START) as DATE_START
  from      MEETINGS_USERS
 inner join MEETINGS
         on MEETINGS.ID      = MEETINGS_USERS.MEETING_ID
        and MEETINGS.DELETED = MEETINGS_USERS.DELETED
 inner join USERS
         on USERS.ID         = MEETINGS_USERS.USER_ID
        and USERS.DELETED    = 0

GO

Grant Select on dbo.vwUSERS_MEETINGS_Soap to public;
GO

