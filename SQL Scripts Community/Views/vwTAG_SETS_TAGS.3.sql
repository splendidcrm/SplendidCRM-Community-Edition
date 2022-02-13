if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTAG_SETS_TAGS')
	Drop View dbo.vwTAG_SETS_TAGS;
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
Create View dbo.vwTAG_SETS_TAGS
as
select TAG_SETS.ID
     , TAGS.ID       as TAG_ID
     , TAGS.NAME     as TAG_NAME
  from      TAG_SETS
 inner join TAG_BEAN_REL
         on TAG_BEAN_REL.BEAN_ID = TAG_SETS.BEAN_ID
        and TAG_BEAN_REL.DELETED = 0
 inner join TAGS
         on TAGS.ID              = TAG_BEAN_REL.TAG_ID
        and TAGS.DELETED         = 0
 where TAG_SETS.DELETED = 0

GO

Grant Select on dbo.vwTAG_SETS_TAGS to public;
GO

 
