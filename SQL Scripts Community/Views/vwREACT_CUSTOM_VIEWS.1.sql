if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwREACT_CUSTOM_VIEWS')
	Drop View dbo.vwREACT_CUSTOM_VIEWS;
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
Create View dbo.vwREACT_CUSTOM_VIEWS
as
select REACT_CUSTOM_VIEWS.ID
     , REACT_CUSTOM_VIEWS.NAME
     , REACT_CUSTOM_VIEWS.MODULE_NAME
     , REACT_CUSTOM_VIEWS.CATEGORY
     , MODULES.IS_ADMIN
     , REACT_CUSTOM_VIEWS.CONTENT
  from      REACT_CUSTOM_VIEWS
 inner join MODULES
         on MODULES.MODULE_NAME    = REACT_CUSTOM_VIEWS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1
 where REACT_CUSTOM_VIEWS.DELETED = 0

GO

Grant Select on dbo.vwREACT_CUSTOM_VIEWS to public;
GO

