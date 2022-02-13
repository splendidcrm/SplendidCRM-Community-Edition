if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACCOUNTS_Edit')
	Drop View dbo.vwACCOUNTS_Edit;
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
-- 11/08/2008 Paul.  Move description to base view. 
Create View dbo.vwACCOUNTS_Edit
as
select vwACCOUNTS.*
     , dbo.fnFullAddressHtml(vwACCOUNTS.BILLING_ADDRESS_STREET , vwACCOUNTS.BILLING_ADDRESS_CITY , vwACCOUNTS.BILLING_ADDRESS_STATE , vwACCOUNTS.BILLING_ADDRESS_POSTALCODE , vwACCOUNTS.BILLING_ADDRESS_COUNTRY ) as BILLING_ADDRESS_HTML
     , dbo.fnFullAddressHtml(vwACCOUNTS.SHIPPING_ADDRESS_STREET, vwACCOUNTS.SHIPPING_ADDRESS_CITY, vwACCOUNTS.SHIPPING_ADDRESS_STATE, vwACCOUNTS.SHIPPING_ADDRESS_POSTALCODE, vwACCOUNTS.SHIPPING_ADDRESS_COUNTRY) as SHIPPING_ADDRESS_HTML
  from            vwACCOUNTS
  left outer join ACCOUNTS
               on ACCOUNTS.ID = vwACCOUNTS.ID

GO

Grant Select on dbo.vwACCOUNTS_Edit to public;
GO


