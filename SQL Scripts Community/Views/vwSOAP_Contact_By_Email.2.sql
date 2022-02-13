if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSOAP_Contact_By_Email')
	Drop View dbo.vwSOAP_Contact_By_Email;
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
-- 05/02/2006 Paul.  ASSIGNED_USER_ID is needed for ACL. 
Create View dbo.vwSOAP_Contact_By_Email
as
select ID                     as ID
     , FIRST_NAME             as NAME1
     , LAST_NAME              as NAME2
     , ACCOUNT_NAME           as ASSOCIATION
     , N'Lead'                as TYPE
     , EMAIL1                 as EMAIL_ADDRESS
     , EMAIL1                 as EMAIL1
     , EMAIL2                 as EMAIL2
     , vwLEADS.ASSIGNED_USER_ID       as ASSIGNED_USER_ID
  from vwLEADS
union all
select ID                     as ID
     , FIRST_NAME             as NAME1
     , LAST_NAME              as NAME2
     , ACCOUNT_NAME           as ASSOCIATION
     , N'Contact'             as TYPE
     , EMAIL1                 as EMAIL_ADDRESS
     , EMAIL1                 as EMAIL1
     , EMAIL2                 as EMAIL2
     , vwCONTACTS.ASSIGNED_USER_ID       as ASSIGNED_USER_ID
  from vwCONTACTS
union all
select vwACCOUNTS.ID          as ID
     , N''                    as NAME1
     , vwACCOUNTS.NAME        as NAME2
     , BILLING_ADDRESS_CITY   as ASSOCIATION
     , N'Account'             as TYPE
     , vwACCOUNTS.EMAIL1      as EMAIL_ADDRESS
     , CONTACTS.EMAIL1        as EMAIL1
     , CONTACTS.EMAIL2        as EMAIL2
     , vwACCOUNTS.ASSIGNED_USER_ID       as ASSIGNED_USER_ID
  from           vwACCOUNTS
      inner join ACCOUNTS_CONTACTS
              on ACCOUNTS_CONTACTS.ACCOUNT_ID = vwACCOUNTS.ID
             and ACCOUNTS_CONTACTS.DELETED    = 0
      inner join CONTACTS
              on CONTACTS.ID                  = ACCOUNTS_CONTACTS.CONTACT_ID
             and CONTACTS.DELETED             = 0
union all
select vwOPPORTUNITIES.ID     as ID
     , N''                    as NAME1
     , vwOPPORTUNITIES.NAME   as NAME2
     , ACCOUNT_NAME           as ASSOCIATION
     , N'Opportunity'         as TYPE
     , N''                    as EMAIL_ADDRESS
     , CONTACTS.EMAIL1        as EMAIL1
     , CONTACTS.EMAIL2        as EMAIL2
     , vwOPPORTUNITIES.ASSIGNED_USER_ID       as ASSIGNED_USER_ID
  from           vwOPPORTUNITIES
      inner join OPPORTUNITIES_CONTACTS
              on OPPORTUNITIES_CONTACTS.OPPORTUNITY_ID = vwOPPORTUNITIES.ID
             and OPPORTUNITIES_CONTACTS.DELETED        = 0
      inner join CONTACTS
              on CONTACTS.ID                           = OPPORTUNITIES_CONTACTS.CONTACT_ID
             and CONTACTS.DELETED                      = 0
union all
select vwCASES.ID             as ID
     , N''                    as NAME1
     , vwCASES.NAME           as NAME2
     , ACCOUNT_NAME           as ASSOCIATION
     , N'Case'                as TYPE
     , N''                    as EMAIL_ADDRESS
     , CONTACTS.EMAIL1        as EMAIL1
     , CONTACTS.EMAIL2        as EMAIL2
     , vwCASES.ASSIGNED_USER_ID       as ASSIGNED_USER_ID
  from           vwCASES
      inner join CONTACTS_CASES
              on CONTACTS_CASES.CASE_ID = vwCASES.ID
             and CONTACTS_CASES.DELETED = 0
      inner join CONTACTS
              on CONTACTS.ID            = CONTACTS_CASES.CONTACT_ID
             and CONTACTS.DELETED       = 0

GO

Grant Select on dbo.vwSOAP_Contact_By_Email to public;
GO


