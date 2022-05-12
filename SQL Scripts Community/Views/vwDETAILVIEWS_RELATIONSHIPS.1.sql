if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDETAILVIEWS_RELATIONSHIPS')
	Drop View dbo.vwDETAILVIEWS_RELATIONSHIPS;
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
-- 04/27/2006 Paul.  ACL will use the MODULE_NAME.
-- 07/11/2006 Paul.  Disable the relationship if the module is disabled. 
-- 09/08/2007 Paul.  Relationships can now be disabled.
-- 09/08/2007 Paul.  We need a title when we migrate to WebParts. 
-- 01/24/2010 Paul.  We need the ID for report dashlet management. 
-- 01/27/2010 Paul.  Remove the join to DETAILVIEWS so that we can use this table for EditView Relationships. 
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- 03/30/2022 Paul.  Add Insight fields. 
Create View dbo.vwDETAILVIEWS_RELATIONSHIPS
as
select DETAILVIEWS_RELATIONSHIPS.ID
     , DETAILVIEWS_RELATIONSHIPS.DETAIL_NAME
     , DETAILVIEWS_RELATIONSHIPS.MODULE_NAME
     , DETAILVIEWS_RELATIONSHIPS.TITLE
     , DETAILVIEWS_RELATIONSHIPS.CONTROL_NAME
     , DETAILVIEWS_RELATIONSHIPS.RELATIONSHIP_ORDER
     , DETAILVIEWS_RELATIONSHIPS.TABLE_NAME
     , DETAILVIEWS_RELATIONSHIPS.PRIMARY_FIELD
     , DETAILVIEWS_RELATIONSHIPS.SORT_FIELD
     , DETAILVIEWS_RELATIONSHIPS.SORT_DIRECTION
     , DETAILVIEWS_RELATIONSHIPS.INSIGHT_LABEL
     , DETAILVIEWS_RELATIONSHIPS.INSIGHT_VIEW
     , DETAILVIEWS_RELATIONSHIPS.INSIGHT_OPERATOR
  from      DETAILVIEWS_RELATIONSHIPS
 inner join MODULES
         on MODULES.MODULE_NAME    = DETAILVIEWS_RELATIONSHIPS.MODULE_NAME
        and MODULES.DELETED        = 0
        and MODULES.MODULE_ENABLED = 1
 where DETAILVIEWS_RELATIONSHIPS.DELETED = 0
   and DETAILVIEWS_RELATIONSHIPS.RELATIONSHIP_ENABLED = 1

GO

Grant Select on dbo.vwDETAILVIEWS_RELATIONSHIPS to public;
GO

