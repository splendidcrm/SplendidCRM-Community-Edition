if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFULLTEXT_INDEXES')
	Drop View dbo.vwFULLTEXT_INDEXES;
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
-- https://msdn.microsoft.com/en-us/library/ms190370(v=sql.90).aspx
Create View dbo.vwFULLTEXT_INDEXES
as
select object_name(fulltext_indexes.object_id) as TABLE_NAME
  from      sys.fulltext_indexes                    fulltext_indexes
 inner join sys.fulltext_catalogs                   fulltext_catalogs
         on fulltext_catalogs.fulltext_catalog_id = fulltext_indexes.fulltext_catalog_id
 where fulltext_catalogs.name = db_name() + 'Catalog'
GO

Grant Select on dbo.vwFULLTEXT_INDEXES to public;
GO

-- select * from vwFULLTEXT_INDEXES

