if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSYSTEM_CURRENCY_LOG')
	Drop View dbo.vwSYSTEM_CURRENCY_LOG;
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
-- 03/18/2021 Paul.  Join to currencies table so that the React client can include subpanel data automatically. 
Create View dbo.vwSYSTEM_CURRENCY_LOG
as
select SYSTEM_CURRENCY_LOG.ID
     , SYSTEM_CURRENCY_LOG.SERVICE_NAME
     , SYSTEM_CURRENCY_LOG.SOURCE_ISO4217
     , SYSTEM_CURRENCY_LOG.DESTINATION_ISO4217
     , SYSTEM_CURRENCY_LOG.CONVERSION_RATE
     , SYSTEM_CURRENCY_LOG.DATE_ENTERED
     , SYSTEM_CURRENCY_LOG.DATE_MODIFIED
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
     , CURRENCIES.ID         as CURRENCY_ID
  from            SYSTEM_CURRENCY_LOG
  left outer join CURRENCIES
               on CURRENCIES.ISO4217 = SYSTEM_CURRENCY_LOG.DESTINATION_ISO4217
              and CURRENCIES.DELETED = 0
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = SYSTEM_CURRENCY_LOG.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = SYSTEM_CURRENCY_LOG.MODIFIED_USER_ID
 where SYSTEM_CURRENCY_LOG.DELETED = 0

GO

Grant Select on dbo.vwSYSTEM_CURRENCY_LOG to public;
GO


