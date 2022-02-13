if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwGRIDVIEWS')
	Drop View dbo.vwGRIDVIEWS;
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
-- 11/22/2010 Paul.  Add support for Business Rules Framework. 
-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
Create View dbo.vwGRIDVIEWS
as
select GRIDVIEWS.ID
     , GRIDVIEWS.NAME
     , GRIDVIEWS.MODULE_NAME
     , GRIDVIEWS.VIEW_NAME
     , GRIDVIEWS.SCRIPT
     , GRIDVIEWS.SORT_FIELD       
     , GRIDVIEWS.SORT_DIRECTION   
     , PRE_LOAD_EVENT_RULES.ID      as PRE_LOAD_EVENT_ID
     , PRE_LOAD_EVENT_RULES.NAME    as PRE_LOAD_EVENT_NAME
     , POST_LOAD_EVENT_RULES.ID     as POST_LOAD_EVENT_ID
     , POST_LOAD_EVENT_RULES.NAME   as POST_LOAD_EVENT_NAME
  from            GRIDVIEWS
  left outer join RULES                            PRE_LOAD_EVENT_RULES
               on PRE_LOAD_EVENT_RULES.ID        = GRIDVIEWS.PRE_LOAD_EVENT_ID
              and PRE_LOAD_EVENT_RULES.DELETED   = 0
  left outer join RULES                            POST_LOAD_EVENT_RULES
               on POST_LOAD_EVENT_RULES.ID       = GRIDVIEWS.POST_LOAD_EVENT_ID
              and POST_LOAD_EVENT_RULES.DELETED  = 0
 where GRIDVIEWS.DELETED = 0

GO

Grant Select on dbo.vwGRIDVIEWS to public;
GO

