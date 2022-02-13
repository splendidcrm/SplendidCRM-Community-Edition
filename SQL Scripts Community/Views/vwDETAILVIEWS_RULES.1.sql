if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDETAILVIEWS_RULES')
	Drop View dbo.vwDETAILVIEWS_RULES;
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
-- 11/11/2010 Paul.  Change to Pre Load and Post Load. 
Create View dbo.vwDETAILVIEWS_RULES
as
select DETAILVIEWS.ID
     , DETAILVIEWS.NAME
     , DETAILVIEWS.MODULE_NAME
     , DETAILVIEWS.VIEW_NAME
     , PRE_LOAD_EVENT_RULES.ID      as PRE_LOAD_EVENT_ID
     , PRE_LOAD_EVENT_RULES.NAME    as PRE_LOAD_EVENT_NAME
     , PRE_LOAD_EVENT_RULES.XOML    as PRE_LOAD_EVENT_XOML
     , POST_LOAD_EVENT_RULES.ID     as POST_LOAD_EVENT_ID
     , POST_LOAD_EVENT_RULES.NAME   as POST_LOAD_EVENT_NAME
     , POST_LOAD_EVENT_RULES.XOML   as POST_LOAD_EVENT_XOML
  from            DETAILVIEWS
  left outer join RULES                            PRE_LOAD_EVENT_RULES
               on PRE_LOAD_EVENT_RULES.ID        = DETAILVIEWS.PRE_LOAD_EVENT_ID
              and PRE_LOAD_EVENT_RULES.DELETED   = 0
  left outer join RULES                            POST_LOAD_EVENT_RULES
               on POST_LOAD_EVENT_RULES.ID       = DETAILVIEWS.POST_LOAD_EVENT_ID
              and POST_LOAD_EVENT_RULES.DELETED  = 0
 where DETAILVIEWS.DELETED = 0

GO

Grant Select on dbo.vwDETAILVIEWS_RULES to public;
GO

