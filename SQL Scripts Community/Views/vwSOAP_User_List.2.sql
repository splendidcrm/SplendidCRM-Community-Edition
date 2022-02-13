if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSOAP_User_List')
	Drop View dbo.vwSOAP_User_List;
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
-- 03/06/2006 Paul.  Oracle does not like <> ''.  Use len() > 0 instead. 
Create View dbo.vwSOAP_User_List
as
select ID
     , FIRST_NAME
     , LAST_NAME
     , USER_NAME
     , DEPARTMENT
     , EMAIL1      as EMAIL_ADDRESS
     , TITLE
  from vwUSERS
 where USER_NAME is not null
   and len(USER_NAME) > 0

GO

Grant Select on dbo.vwSOAP_User_List to public;
GO


