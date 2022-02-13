if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCURRENCIES_LISTBOX')
	Drop View dbo.vwCURRENCIES_LISTBOX;
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
-- 05/29/2008 Paul.  ISO4217 is needed to process PayPal transactions. 
-- 05/01/2016 Paul.  We are going to prepopulate the list and the ISO4217 is required and unique. 
Create View dbo.vwCURRENCIES_LISTBOX
as
select ID
     , NAME
     , SYMBOL
     , NAME + N': ' + SYMBOL as NAME_SYMBOL
     , CONVERSION_RATE
     , ISO4217
  from CURRENCIES
 where DELETED = 0
   and (STATUS is null or STATUS = N'Active')

GO

Grant Select on dbo.vwCURRENCIES_LISTBOX to public;
GO

 
