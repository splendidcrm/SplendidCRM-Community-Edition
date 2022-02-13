if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEDITVIEWS_FIELDS_Searching')
	Drop View dbo.vwEDITVIEWS_FIELDS_Searching;
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
-- 04/17/2009 Paul.  Key off of the view name so that we don't have to change other areas of the code. 
Create View dbo.vwEDITVIEWS_FIELDS_Searching
as
select EDITVIEWS_FIELDS_Search.EDIT_NAME
     , EDITVIEWS_Search.VIEW_NAME
     , EDITVIEWS_Search.MODULE_NAME
     , EDITVIEWS_FIELDS_Module.DATA_FIELD
  from      EDITVIEWS_FIELDS                    EDITVIEWS_FIELDS_Search
 inner join EDITVIEWS                           EDITVIEWS_Search
         on EDITVIEWS_Search.NAME             = EDITVIEWS_FIELDS_Search.EDIT_NAME
        and EDITVIEWS_Search.DELETED          = 0
 inner join EDITVIEWS                           EDITVIEWS_Module
         on EDITVIEWS_Module.MODULE_NAME      = EDITVIEWS_Search.MODULE_NAME
        and EDITVIEWS_Module.DELETED          = 0
 inner join EDITVIEWS_FIELDS                    EDITVIEWS_FIELDS_Module
         on EDITVIEWS_FIELDS_Module.EDIT_NAME = EDITVIEWS_Module.NAME
        and EDITVIEWS_FIELDS_Module.DELETED   = 0
 where EDITVIEWS_FIELDS_Search.DELETED   = 0
   and (EDITVIEWS_FIELDS_Module.DEFAULT_VIEW = 0 or EDITVIEWS_FIELDS_Module.DEFAULT_VIEW is null)
   and EDITVIEWS_FIELDS_Module.DATA_FIELD is not null
union
select EDITVIEWS_FIELDS_Search.EDIT_NAME
     , EDITVIEWS_Search.VIEW_NAME
     , EDITVIEWS_Search.MODULE_NAME
     , EDITVIEWS_FIELDS_Module.DISPLAY_FIELD
  from      EDITVIEWS_FIELDS                    EDITVIEWS_FIELDS_Search
 inner join EDITVIEWS                           EDITVIEWS_Search
         on EDITVIEWS_Search.NAME             = EDITVIEWS_FIELDS_Search.EDIT_NAME
        and EDITVIEWS_Search.DELETED          = 0
 inner join EDITVIEWS                           EDITVIEWS_Module
         on EDITVIEWS_Module.MODULE_NAME      = EDITVIEWS_Search.MODULE_NAME
        and EDITVIEWS_Module.DELETED          = 0
 inner join EDITVIEWS_FIELDS                    EDITVIEWS_FIELDS_Module
         on EDITVIEWS_FIELDS_Module.EDIT_NAME = EDITVIEWS_Module.NAME
        and EDITVIEWS_FIELDS_Module.DELETED   = 0
 where EDITVIEWS_FIELDS_Search.DELETED   = 0
   and (EDITVIEWS_FIELDS_Module.DEFAULT_VIEW = 0 or EDITVIEWS_FIELDS_Module.DEFAULT_VIEW is null)
   and EDITVIEWS_FIELDS_Module.DISPLAY_FIELD is not null

GO

Grant Select on dbo.vwEDITVIEWS_FIELDS_Searching to public;
GO

