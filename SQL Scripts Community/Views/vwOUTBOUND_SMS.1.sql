if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOUTBOUND_SMS')
	Drop View dbo.vwOUTBOUND_SMS;
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
Create View dbo.vwOUTBOUND_SMS
as
select OUTBOUND_SMS.ID
     , OUTBOUND_SMS.NAME
     , OUTBOUND_SMS.USER_ID
     , OUTBOUND_SMS.FROM_NUMBER
     , (case when USERS_ASSIGNED.ID is not null
             then dbo.fnEmailDisplayName(dbo.fnFullName(USERS_ASSIGNED.FIRST_NAME, USERS_ASSIGNED.LAST_NAME), OUTBOUND_SMS.FROM_NUMBER)
             else dbo.fnEmailDisplayName(OUTBOUND_SMS.NAME, OUTBOUND_SMS.FROM_NUMBER)
        end) as DISPLAY_NAME
     , OUTBOUND_SMS.DATE_ENTERED
     , OUTBOUND_SMS.DATE_MODIFIED
     , OUTBOUND_SMS.USER_ID          as ASSIGNED_USER_ID
     , USERS_ASSIGNED.USER_NAME      as ASSIGNED_TO_NAME
     , USERS_CREATED_BY.USER_NAME    as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME   as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
  from            OUTBOUND_SMS
  left outer join USERS                      USERS_ASSIGNED
               on USERS_ASSIGNED.ID        = OUTBOUND_SMS.USER_ID
  left outer join USERS                      USERS_CREATED_BY
               on USERS_CREATED_BY.ID      = OUTBOUND_SMS.CREATED_BY
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = OUTBOUND_SMS.MODIFIED_USER_ID
 where OUTBOUND_SMS.DELETED = 0

GO

Grant Select on dbo.vwOUTBOUND_SMS to public;
GO

