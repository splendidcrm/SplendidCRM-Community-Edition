if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSAVED_SEARCH')
	Drop View dbo.vwSAVED_SEARCH;
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
-- 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
Create View dbo.vwSAVED_SEARCH
as
select ID
     , NAME
     , ASSIGNED_USER_ID
     , SEARCH_MODULE
     , DEFAULT_SEARCH_ID
     , DATE_MODIFIED
     , CONTENTS
  from SAVED_SEARCH
 where DELETED = 0

GO

Grant Select on dbo.vwSAVED_SEARCH to public;
GO

