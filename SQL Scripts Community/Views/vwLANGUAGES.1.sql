if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLANGUAGES')
	Drop View dbo.vwLANGUAGES;
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
-- 05/20/2008 Paul.  NAME should no longer be made lower case. 
-- 05/20/2008 Paul.  Include ACTIVE flag to reduce memory foot print. 
-- 04/02/2019 Paul.  DATE_MODIFIED and DATE_ENTERED for detail view. 
Create View dbo.vwLANGUAGES
as
select ID
     , NAME
     , LCID
     , ACTIVE
     , NATIVE_NAME
     , DISPLAY_NAME
     , DATE_ENTERED
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
  from LANGUAGES
 where DELETED = 0

GO

Grant Select on dbo.vwLANGUAGES to public;
GO


