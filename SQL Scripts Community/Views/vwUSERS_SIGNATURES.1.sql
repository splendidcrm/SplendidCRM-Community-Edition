if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwUSERS_SIGNATURES')
	Drop View dbo.vwUSERS_SIGNATURES;
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
-- 09/13/2019 Paul.  USERS_SIGNATURE_ID is required by the REST API. 
Create View dbo.vwUSERS_SIGNATURES
as
select USERS_SIGNATURES.ID
     , USERS_SIGNATURES.ID         as USERS_SIGNATURE_ID
     , USERS_SIGNATURES.USER_ID
     , USERS_SIGNATURES.NAME
     , USERS_SIGNATURES.SIGNATURE
     , USERS_SIGNATURES.SIGNATURE_HTML
     , USERS_SIGNATURES.PRIMARY_SIGNATURE
     , USERS_SIGNATURES.DATE_ENTERED
     , USERS_SIGNATURES.DATE_MODIFIED
     , USERS_SIGNATURES.DATE_MODIFIED_UTC
     , USERS_CREATED_BY.USER_NAME  as CREATED_BY
     , USERS_MODIFIED_BY.USER_NAME as MODIFIED_BY
     , dbo.fnFullName(USERS_CREATED_BY.FIRST_NAME , USERS_CREATED_BY.LAST_NAME ) as CREATED_BY_NAME
     , dbo.fnFullName(USERS_MODIFIED_BY.FIRST_NAME, USERS_MODIFIED_BY.LAST_NAME) as MODIFIED_BY_NAME
  from            USERS_SIGNATURES
  left outer join USERS USERS_CREATED_BY
               on USERS_CREATED_BY.ID  = USERS_SIGNATURES.CREATED_BY
  left outer join USERS USERS_MODIFIED_BY
               on USERS_MODIFIED_BY.ID = USERS_SIGNATURES.MODIFIED_USER_ID
 where USERS_SIGNATURES.DELETED = 0

GO

Grant Select on dbo.vwUSERS_SIGNATURES to public;
GO

 
