if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEDITVIEWS_RELATIONSHIPS_Layout')
	Drop View dbo.vwEDITVIEWS_RELATIONSHIPS_Layout;
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
-- 10/29/2015 Paul.  CONTROL_NAME is need to allow copying of the layout. 
Create View dbo.vwEDITVIEWS_RELATIONSHIPS_Layout
as
select EDITVIEWS_RELATIONSHIPS.ID
     , EDITVIEWS_RELATIONSHIPS.EDIT_NAME
     , EDITVIEWS_RELATIONSHIPS.MODULE_NAME
     , EDITVIEWS_RELATIONSHIPS.TITLE
     , EDITVIEWS_RELATIONSHIPS.CONTROL_NAME
     , EDITVIEWS_RELATIONSHIPS.RELATIONSHIP_ORDER
     , EDITVIEWS_RELATIONSHIPS.RELATIONSHIP_ENABLED
     , EDITVIEWS_RELATIONSHIPS.NEW_RECORD_ENABLED
     , EDITVIEWS_RELATIONSHIPS.EXISTING_RECORD_ENABLED
     , EDITVIEWS_RELATIONSHIPS.ALTERNATE_VIEW
  from      EDITVIEWS_RELATIONSHIPS
 inner join MODULES
         on MODULES.MODULE_NAME    = EDITVIEWS_RELATIONSHIPS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1
 where EDITVIEWS_RELATIONSHIPS.DELETED = 0

GO

Grant Select on dbo.vwEDITVIEWS_RELATIONSHIPS_Layout to public;
GO

