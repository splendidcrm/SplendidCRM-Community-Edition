if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOAUTH_TOKENS')
	Drop View dbo.vwOAUTH_TOKENS;
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
-- 09/05/2015 Paul.  Google now uses OAuth 2.0. 
Create View dbo.vwOAUTH_TOKENS
as
select NAME
     , ASSIGNED_USER_ID
     , TOKEN           
     , SECRET          
     , TOKEN_EXPIRES_AT
     , REFRESH_TOKEN   
  from OAUTH_TOKENS
 where DELETED = 0

GO

Grant Select on dbo.vwOAUTH_TOKENS to public;
GO

