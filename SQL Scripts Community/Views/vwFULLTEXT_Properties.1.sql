if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFULLTEXT_Properties')
	Drop View dbo.vwFULLTEXT_Properties;
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
Create View dbo.vwFULLTEXT_Properties
as
select substring(@@version, 1, charindex(char(10), @@version)) as SQL_SERVER_VERSION
     , ServerProperty('Edition')             as SQL_SERVER_EDITION
     , db_name()                             as DATABASE_NAME
     , ServerProperty('IsFullTextInstalled') as FULLTEXT_INSTALLED
     , (select fulltext_catalog_id from sys.fulltext_catalogs where name = db_name() + 'Catalog') as FULLTEXT_CATALOG_ID
     , (select 1 from sys.fulltext_document_types where document_type = '.pptx') as OFFICE_DOCUMENT_TYPE
     , (select 1 from sys.fulltext_document_types where document_type = '.pdf' ) as PDF_DOCUMENT_TYPE
GO

Grant Select on dbo.vwFULLTEXT_Properties to public;
GO

-- select * from vwFULLTEXT_Properties

