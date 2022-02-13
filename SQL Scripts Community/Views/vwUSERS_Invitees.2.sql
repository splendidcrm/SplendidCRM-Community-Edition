if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_Invitees')
	Drop View dbo.vwUSERS_Invitees;
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
-- 11/07/2005 Paul.  SQL Server needs the cast in order to compile vwACTIVITIES_Invitees.
-- 02/01/2006 Paul.  DB2 does not like comments in the middle of the Create View statement. 
-- 12/11/2009 Paul.  Only show active users and also exclude portal users. 
-- 12/12/2009 Paul.  We do not need to return the STATUS. 
-- If we include the status, then we would need a dummy STATUS field in the vwCONTACTS_Invitees view. 
Create View dbo.vwUSERS_Invitees
as
select ID          as ID
     , N'Users'    as INVITEE_TYPE
     , FULL_NAME   as NAME
     , FIRST_NAME  as FIRST_NAME
     , LAST_NAME   as LAST_NAME
     , EMAIL1      as EMAIL
     , PHONE_WORK  as PHONE
     , cast(null as uniqueidentifier) as ASSIGNED_USER_ID
  from vwUSERS
 where (STATUS      is null or STATUS      = N'Active')
   and (PORTAL_ONLY is null or PORTAL_ONLY = 0        )

GO

Grant Select on dbo.vwUSERS_Invitees to public;
GO


