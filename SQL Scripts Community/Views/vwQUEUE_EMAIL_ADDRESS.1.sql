if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwQUEUE_EMAIL_ADDRESS')
	Drop View dbo.vwQUEUE_EMAIL_ADDRESS;
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
-- 06/03/2008 Paul.  Only use the Account email if the Contact email does not exist. 
-- 08/23/2008 Paul.  Payments, Quotes, Orders, Invoices are not supported in the Community Edition. 
-- 10/13/2011 Paul.  We need to return the recipient ID and not the parent ID. 
Create View dbo.vwQUEUE_EMAIL_ADDRESS
as
select PARENT_ID
     , PARENT_NAME
     , PARENT_TYPE
     , MODULE
     , EMAIL1
     , cast(null as uniqueidentifier) as RECIPIENT_ID
     , cast(null as nvarchar(200))    as RECIPIENT_NAME
  from vwPARENTS_EMAIL_ADDRESS
union all
select CASES.ID                          as PARENT_ID
     , ACCOUNTS.NAME                     as PARENT_NAME
     , N'Cases'                          as PARENT_TYPE
     , N'Accounts'                       as MODULE
     , ACCOUNTS.EMAIL1                   as EMAIL1
     , ACCOUNTS.ID                       as RECIPIENT_ID
     , ACCOUNTS.NAME                     as RECIPIENT_NAME
  from            CASES
       inner join ACCOUNTS
               on ACCOUNTS.ID      = CASES.ACCOUNT_ID
              and ACCOUNTS.DELETED = 0
 where CASES.DELETED = 0
   and ACCOUNTS.EMAIL1 is not null
union all
select OPPORTUNITIES.ID                  as PARENT_ID
     , ACCOUNTS.NAME                     as PARENT_NAME
     , N'Opportunities'                  as PARENT_TYPE
     , N'Accounts'                       as MODULE
     , ACCOUNTS.EMAIL1                   as EMAIL1
     , ACCOUNTS.ID                       as RECIPIENT_ID
     , ACCOUNTS.NAME                     as RECIPIENT_NAME
  from            OPPORTUNITIES
       inner join ACCOUNTS_OPPORTUNITIES
               on ACCOUNTS_OPPORTUNITIES.OPPORTUNITY_ID = OPPORTUNITIES.ID
              and ACCOUNTS_OPPORTUNITIES.DELETED        = 0
       inner join ACCOUNTS
               on ACCOUNTS.ID                           = ACCOUNTS_OPPORTUNITIES.ACCOUNT_ID
              and ACCOUNTS.DELETED                      = 0
 where OPPORTUNITIES.DELETED = 0
   and ACCOUNTS.EMAIL1 is not null

GO

Grant Select on dbo.vwQUEUE_EMAIL_ADDRESS to public;
GO

