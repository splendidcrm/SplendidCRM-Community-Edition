if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlForeignKeys')
	Drop View dbo.vwSqlForeignKeys;
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
Create View dbo.vwSqlForeignKeys
as
select TABLE_CONSTRAINTS.CONSTRAINT_NAME    as CONSTRAINT_NAME
     , TABLE_CONSTRAINTS.TABLE_SCHEMA       as TABLE_SCHEMA
     , TABLE_CONSTRAINTS.TABLE_NAME         as TABLE_NAME 
     , CONSTRAINT_COLUMN_USAGE.COLUMN_NAME  as COLUMN_NAME
     , PRIMARY_KEYS.TABLE_SCHEMA            as REFERENCED_TABLE_SCHEMA
     , PRIMARY_KEYS.TABLE_NAME              as REFERENCED_TABLE_NAME
     , PRIMARY_COLUMN_USAGE.COLUMN_NAME     as REFERENCED_COLUMN_NAME
  from      INFORMATION_SCHEMA.TABLE_CONSTRAINTS         TABLE_CONSTRAINTS
 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   CONSTRAINT_COLUMN_USAGE
         on CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
 inner join INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS   REFERENTIAL_CONSTRAINTS
         on REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME    = TABLE_CONSTRAINTS.CONSTRAINT_NAME
 inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS         PRIMARY_KEYS
         on PRIMARY_KEYS.CONSTRAINT_NAME               = REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_NAME
        and PRIMARY_KEYS.CONSTRAINT_TYPE               = 'PRIMARY KEY'
 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   PRIMARY_COLUMN_USAGE
         on PRIMARY_COLUMN_USAGE.CONSTRAINT_NAME       = PRIMARY_KEYS.CONSTRAINT_NAME
 where TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'



GO


Grant Select on dbo.vwSqlForeignKeys to public;
GO

