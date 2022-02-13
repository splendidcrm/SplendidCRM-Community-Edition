if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDOCUMENTS_List')
	Drop View dbo.vwDOCUMENTS_List;
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
-- 05/02/2006 Paul.  DB2 is particular about how * is used.  
-- 10/20/2010 Paul.  All modules should have a NAME field, so it was moved to the base view. 
-- 10/19/2016 Paul.  Include DOCUMENT_REVISIONS.CONTENT so that we can use Full-Text Search. 
-- 10/19/2016 Paul.  Instead of joining to actual table, just create placeholder for the layout manager. 
-- This is because the full-text query needs to be a sub-query or a schemabound indexed view. 
Create View dbo.vwDOCUMENTS_List
as
select vwDOCUMENTS.*
     , cast(null as varbinary(max)) as CONTENT
  from vwDOCUMENTS

GO

Grant Select on dbo.vwDOCUMENTS_List to public;
GO

 
