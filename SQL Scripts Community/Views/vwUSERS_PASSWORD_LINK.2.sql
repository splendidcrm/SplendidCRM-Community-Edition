if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_PASSWORD_LINK')
	Drop View dbo.vwUSERS_PASSWORD_LINK;
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
Create View dbo.vwUSERS_PASSWORD_LINK
as
select USERS_PASSWORD_LINK.ID  as ID
     , vwUSERS_Login.ID        as USER_ID
     , vwUSERS_Login.USER_NAME as USER_NAME
  from      USERS_PASSWORD_LINK
 inner join vwUSERS_Login
         on vwUSERS_Login.USER_NAME = USERS_PASSWORD_LINK.USER_NAME
 where USERS_PASSWORD_LINK.DELETED = 0

GO

Grant Select on dbo.vwUSERS_PASSWORD_LINK to public;
GO

