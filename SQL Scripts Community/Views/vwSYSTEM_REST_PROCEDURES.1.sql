if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSYSTEM_REST_PROCEDURES')
	Drop View dbo.vwSYSTEM_REST_PROCEDURES;
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
-- 11/25/2020 Paul.  We need a way to call a generic procedure.  Security is still managed through SYSTEM_REST_TABLES. 
Create View dbo.vwSYSTEM_REST_PROCEDURES
as
select SYSTEM_REST_TABLES.TABLE_NAME
     , SYSTEM_REST_TABLES.IS_SYSTEM
     , SYSTEM_REST_TABLES.IS_RELATIONSHIP
     , SYSTEM_REST_TABLES.DEPENDENT_LEVEL
     , SYSTEM_REST_TABLES.VIEW_NAME
     , SYSTEM_REST_TABLES.MODULE_NAME
     , SYSTEM_REST_TABLES.MODULE_NAME_RELATED
     , SYSTEM_REST_TABLES.MODULE_SPECIFIC
     , SYSTEM_REST_TABLES.MODULE_FIELD_NAME
     , SYSTEM_REST_TABLES.IS_ASSIGNED
     , SYSTEM_REST_TABLES.ASSIGNED_FIELD_NAME
     , SYSTEM_REST_TABLES.HAS_CUSTOM
     , SYSTEM_REST_TABLES.REQUIRED_FIELDS
     , null as LIST_VIEW
     , null as EDIT_VIEW
  from            SYSTEM_REST_TABLES
       inner join vwSqlProcedures
               on vwSqlProcedures.NAME        = SYSTEM_REST_TABLES.VIEW_NAME
  left outer join MODULES
               on MODULES.MODULE_NAME         = SYSTEM_REST_TABLES.MODULE_NAME
              and MODULES.DELETED             = 0
 where  SYSTEM_REST_TABLES.DELETED = 0
   and (SYSTEM_REST_TABLES.MODULE_NAME         is null or (MODULES.MODULE_ENABLED         = 1))

GO

Grant Select on dbo.vwSYSTEM_REST_PROCEDURES to public;
GO

