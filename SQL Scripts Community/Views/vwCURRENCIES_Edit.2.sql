if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCURRENCIES_Edit')
	Drop View dbo.vwCURRENCIES_Edit;
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
Create View dbo.vwCURRENCIES_Edit
as
select vwCURRENCIES.*
     , (case when cast(vwCURRENCIES.ID as char(36)) = dbo.fnCONFIG_String('base_currency'   ) or (vwCURRENCIES.ID = 'e340202e-6291-4071-b327-a34cb4df239b' and dbo.fnCONFIG_String('base_currency'   ) is null) then 1 else 0 end) as IS_BASE
     , (case when cast(vwCURRENCIES.ID as char(36)) = dbo.fnCONFIG_String('default_currency') or (vwCURRENCIES.ID = 'e340202e-6291-4071-b327-a34cb4df239b' and dbo.fnCONFIG_String('default_currency') is null) then 1 else 0 end) as IS_DEFAULT
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
  from            vwCURRENCIES
  left outer join USERS                      USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID     = vwCURRENCIES.MODIFIED_USER_ID

GO

Grant Select on dbo.vwCURRENCIES_Edit to public;
GO

 
