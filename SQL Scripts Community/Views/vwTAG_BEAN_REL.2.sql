if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTAG_BEAN_REL')
	Drop View dbo.vwTAG_BEAN_REL;
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
Create View dbo.vwTAG_BEAN_REL
as
select TAG_BEAN_REL.BEAN_ID as BEAN_ID
     , TAG_BEAN_REL.TAG_ID  as TAG_ID
     , TAGS.NAME            as TAG_NAME
  from      TAG_BEAN_REL
 inner join TAGS
         on TAGS.ID      = TAG_BEAN_REL.TAG_ID
        and TAGS.DELETED = 0
 where TAG_BEAN_REL.DELETED = 0

GO

Grant Select on dbo.vwTAG_BEAN_REL to public;
GO

 
