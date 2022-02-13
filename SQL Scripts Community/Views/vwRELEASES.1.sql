if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwRELEASES')
	Drop View dbo.vwRELEASES;
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
-- 08/01/2010 Paul.  Add CREATED_BY_NAME and MODIFIED_BY_NAME so that we can display the full name in lists like Sugar. 
-- 04/07/2019 Paul.  DATE_MODIFIED and DATE_ENTERED for detail view. 
Create View dbo.vwRELEASES
as
select RELEASES.ID
     , RELEASES.NAME
     , RELEASES.LIST_ORDER
     , RELEASES.STATUS
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , RELEASES.CREATED_BY         as CREATED_BY_ID
     , RELEASES.MODIFIED_USER_ID
     , RELEASES.DATE_ENTERED
     , RELEASES.DATE_MODIFIED
     , RELEASES.DATE_MODIFIED_UTC
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , RELEASES_CSTM.*
  from            RELEASES
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = RELEASES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = RELEASES.MODIFIED_USER_ID
  left outer join RELEASES_CSTM
               on RELEASES_CSTM.ID_C   = RELEASES.ID
 where RELEASES.DELETED = 0

GO

Grant Select on dbo.vwRELEASES to public;
GO


