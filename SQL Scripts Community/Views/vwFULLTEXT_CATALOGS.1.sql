if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFULLTEXT_CATALOGS')
	Drop View dbo.vwFULLTEXT_CATALOGS;
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
Create View dbo.vwFULLTEXT_CATALOGS
as
select FullTextCatalogProperty(name,'ItemCount'            ) as ITEM_COUNT
     , FullTextCatalogProperty(name,'MergeStatus'          ) as MERGE_STATUS
     , FullTextCatalogProperty(name,'PopulateCompletionAge') as POPULATE_COMPLETION_AGE
     , (case FullTextCatalogProperty(name,'PopulateStatus')
        when 0 then 'Idle'
        when 1 then 'Full population in progress'
        when 2 then 'Paused'
        when 3 then 'Throttled'
        when 4 then 'Recovering'
        when 5 then 'Shutdown'
        when 6 then 'Incremental population in progress'
        when 7 then 'Building index'
        when 8 then 'Disk is full. Paused.'
        when 9 then 'Change tracking'
        else cast(FullTextCatalogProperty(name,'PopulateStatus') as varchar(4))
        end) as POPULATE_STATUS
     , FullTextCatalogProperty(name,'ImportStatus'         ) as IMPORT_STATUS
     , FullTextCatalogProperty(name,'IndexSize'            ) as INDEX_SIZE
     , FullTextCatalogProperty(name,'UniqueKeyCount'       ) as UNIQUE_KEY_COUNT
     , dateadd(ss, FullTextCatalogProperty(name, 'PopulateCompletionAge'), '1/1/1990') as LAST_POPULATION_DATE
  from sys.fulltext_catalogs
 where name = db_name() + 'Catalog'
GO

Grant Select on dbo.vwFULLTEXT_CATALOGS to public;
GO

-- select * from vwFULLTEXT_CATALOGS

