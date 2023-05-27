if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSqlColumns')
	Drop View dbo.vwSqlColumns;
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
-- 12/29/2007 Paul.  We should make sure to exclude the timestamp field as it would be used for replication. 
-- 09/07/2008 Paul.  Skip S for system and IT for information. 
-- 02/18/2009 Paul.  We need to know if the column is an identity so the workflow engine can avoid updating it.
-- 09/03/2009 Paul.  Add IsNullable for the ModuleBuilder. 
-- 09/14/2009 Paul.  Convert to use catalog views supported by Azure. 
-- http://msdn.microsoft.com/en-us/library/ee336238.aspx
-- 09/15/2009 Paul.  Use actual max of nvarchar(max) field. 
-- 09/15/2009 Paul.  Azure does not like the multi-part names in the output columns. 
-- Deprecated feature 'More than two-part column name' is not supported in this version of SQL Server.
-- 12/13/2009 Paul.  The numeric type (108) is functionally equivalent to the decimal. 
-- 10/26/2010 Peter.  Add support for smallint.
-- 01/10/2014 Paul.  Add smalldatetime to support a customer customization. 
-- 09/22/2016 Paul.  Manually specify default collation to ease migration to Azure
-- 01/22/2020 Paul.  A customer is using the "date" type. 
-- 02/11/2023 Paul.  Add support for DataTable using INFORMATION_SCHEMA. 
Create View dbo.vwSqlColumns
as
select objects.name  collate database_default          as ObjectName
     , objects.type  collate database_default          as ObjectType
     , columns.name  collate database_default          as ColumnName
     , columns.column_id      as colid
     , columns.system_type_id as xtype
     , columns.system_type_id as type
     , (case when columns.max_length     =  -1 then 1073741823
             when columns.system_type_id = 231 then columns.max_length/2
             when columns.system_type_id =  99 then 1073741823
             else columns.max_length
        end
       ) as length
     , columns.max_length
     , columns.precision      as prec
     , cast(0 as bit)             as cdefault
     , cast(0 as bit)             as isoutparam
     , (case when columns.system_type_id =  36 then N'uniqueidentifier'
             when columns.system_type_id =  48 then N'tinyint'
             when columns.system_type_id =  56 then N'int'
             when columns.system_type_id =  52 then N'smallint'
             when columns.system_type_id = 127 then N'bigint'
             when columns.system_type_id =  59 then N'real'
             when columns.system_type_id =  62 then N'float('    + cast(columns.precision    as varchar) + N')'
             when columns.system_type_id =  60 then N'money'
             when columns.system_type_id = 104 then N'bit'
             when columns.system_type_id = 175 then N'char('     + cast(columns.max_length   as varchar) + N')'
             when columns.system_type_id = 167 then N'varchar('  + (case max_length when -1 then 'max' else cast(columns.max_length   as varchar) end) + N')'
             when columns.system_type_id = 231 then N'nvarchar(' + (case max_length when -1 then 'max' else cast(columns.max_length/2 as varchar) end) + N')'
             when columns.system_type_id = 239 then N'nchar('    + cast(columns.max_length/2 as varchar) + N')'
             when columns.system_type_id =  35 then N'text'
             when columns.system_type_id =  99 then N'ntext'
             when columns.system_type_id =  40 then N'date'
             when columns.system_type_id =  61 then N'datetime'
             when columns.system_type_id =  58 then N'smalldatetime'
             when columns.system_type_id =  34 then N'image'
             when columns.system_type_id = 106 then N'decimal('  + cast(columns.precision  as varchar) + N', ' + cast(columns.scale as varchar) + N')'
             when columns.system_type_id = 108 then N'decimal('  + cast(columns.precision  as varchar) + N', ' + cast(columns.scale as varchar) + N')'
             when columns.system_type_id = 165 then N'varbinary('+ (case max_length when -1 then 'max' else cast(columns.max_length as varchar) end) + N')'
             when columns.system_type_id = 173 then N'binary('   + cast(columns.max_length as varchar) + N')'
        end
       ) as ColumnType
     , (case when columns.system_type_id =  36 then N'SqlDbType.UniqueIdentifier'
             when columns.system_type_id =  48 then N'SqlDbType.TinyInt'
             when columns.system_type_id =  56 then N'SqlDbType.Int'
             when columns.system_type_id =  52 then N'SqlDbType.SmallInt'
             when columns.system_type_id = 127 then N'SqlDbType.BigInt'
             when columns.system_type_id =  59 then N'SqlDbType.Real'
             when columns.system_type_id =  62 then N'SqlDbType.Real'
             when columns.system_type_id =  60 then N'SqlDbType.Money'
             when columns.system_type_id = 104 then N'SqlDbType.Bit'
             when columns.system_type_id = 175 then N'SqlDbType.Char'
             when columns.system_type_id = 167 then N'SqlDbType.VarChar'
             when columns.system_type_id = 231 then N'SqlDbType.NVarChar'
             when columns.system_type_id = 239 then N'SqlDbType.NChar'
             when columns.system_type_id =  35 then N'SqlDbType.Text'
             when columns.system_type_id =  99 then N'SqlDbType.NText'
             when columns.system_type_id =  40 then N'SqlDbType.DateTime'
             when columns.system_type_id =  61 then N'SqlDbType.DateTime'
             when columns.system_type_id =  58 then N'SqlDbType.DateTime'
             when columns.system_type_id =  34 then N'SqlDbType.VarBinary'
             when columns.system_type_id = 106 then N'SqlDbType.Real'
             when columns.system_type_id = 108 then N'SqlDbType.Real'
             when columns.system_type_id = 165 then N'SqlDbType.VarBinary'
             when columns.system_type_id = 173 then N'SqlDbType.Binary'
        end
       ) as SqlDbType
     -- 01/24/2006 Paul.  A severe error occurred on the current command. The results, if any, should be discarded. 
     -- MS03-031 security patch causes this error because of stricter datatype processing.  
     -- http://www.microsoft.com/technet/security/bulletin/MS03-031.mspx.
     -- http://support.microsoft.com/kb/827366/
     , (case when columns.system_type_id =  36 then N'Guid'
             when columns.system_type_id =  48 then N'short'
             when columns.system_type_id =  56 then N'Int32'
             when columns.system_type_id =  52 then N'Int16'
             when columns.system_type_id = 127 then N'Int64'
             when columns.system_type_id =  59 then N'float'
             when columns.system_type_id =  62 then N'float'
             when columns.system_type_id =  60 then N'decimal'
             when columns.system_type_id = 104 then N'bool'
             when columns.system_type_id = 175 then N'ansistring'
             when columns.system_type_id = 167 then N'ansistring'
             when columns.system_type_id = 231 then N'string'
             when columns.system_type_id = 239 then N'string'
             when columns.system_type_id =  35 then N'string'
             when columns.system_type_id =  99 then N'string'
             when columns.system_type_id =  40 then N'DateTime'
             when columns.system_type_id =  61 then N'DateTime'
             when columns.system_type_id =  58 then N'DateTime'
             when columns.system_type_id =  34 then N'byte[]'
             when columns.system_type_id = 106 then N'float'
             when columns.system_type_id = 108 then N'float'
             when columns.system_type_id = 165 then N'byte[]'
             when columns.system_type_id = 173 then N'byte[]'
        end
       ) as CsType
     , (case when columns.system_type_id =  36 then N'g'
             when columns.system_type_id =  48 then N'n'
             when columns.system_type_id =  56 then N'n'
             when columns.system_type_id =  52 then N'n'
             when columns.system_type_id = 127 then N'l'
             when columns.system_type_id =  59 then N'fl'
             when columns.system_type_id =  62 then N'fl'
             when columns.system_type_id =  60 then N'd'
             when columns.system_type_id = 104 then N'b'
             when columns.system_type_id = 175 then N's'
             when columns.system_type_id = 167 then N's'
             when columns.system_type_id = 231 then N's'
             when columns.system_type_id = 239 then N's'
             when columns.system_type_id =  35 then N's'
             when columns.system_type_id =  99 then N's'
             when columns.system_type_id =  40 then N'dt'
             when columns.system_type_id =  61 then N'dt'
             when columns.system_type_id =  58 then N'dt'
             when columns.system_type_id =  34 then N'by'
             when columns.system_type_id = 106 then N'fl'
             when columns.system_type_id = 108 then N'fl'
             when columns.system_type_id = 165 then N'bin'
             when columns.system_type_id = 173 then N'bin'
        end
       ) as CsPrefix
     , columns.is_identity as IsIdentity
     , columns.is_nullable as IsNullable
  from      sys.objects         objects
 inner join sys.columns         columns
         on columns.object_id = objects.object_id
 where objects.name <> 'dtproperties'
   and objects.type in ('U', 'V')
   and columns.system_type_id <> 189 -- timestamp
union all
select procedures.name           as ObjectName
     , procedures.type           as ObjectType
     , parameters.name           as ColumnName
     , parameters.parameter_id   as colid
     , parameters.system_type_id as xtype
     , parameters.system_type_id as type
     , (case when parameters.max_length     =  -1 then 100*1024*1024
             when parameters.system_type_id = 231 then parameters.max_length/2
             when parameters.system_type_id =  99 then 100*1024*1024  -- Set maximum file upload size to 100M
             else parameters.max_length
        end
       ) as length
     , parameters.max_length
     , parameters.precision      as prec
     , has_default_value             as cdefault
     , is_output                     as isoutparam
     , (case when parameters.system_type_id =  36 then N'uniqueidentifier'
             when parameters.system_type_id =  48 then N'tinyint'
             when parameters.system_type_id =  56 then N'int'
             when parameters.system_type_id =  52 then N'smallint'
             when parameters.system_type_id = 127 then N'bigint'
             when parameters.system_type_id =  59 then N'real'
             when parameters.system_type_id =  62 then N'float('    + cast(parameters.precision    as varchar) + N')'
             when parameters.system_type_id =  60 then N'money'
             when parameters.system_type_id = 104 then N'bit'
             when parameters.system_type_id = 175 then N'char('     + cast(parameters.max_length   as varchar) + N')'
             when parameters.system_type_id = 167 then N'varchar('  + (case max_length when -1 then 'max' else cast(parameters.max_length   as varchar) end) + N')'
             when parameters.system_type_id = 231 then N'nvarchar(' + (case max_length when -1 then 'max' else cast(parameters.max_length/2 as varchar) end) + N')'
             when parameters.system_type_id = 239 then N'nchar('    + cast(parameters.max_length/2 as varchar) + N')'
             when parameters.system_type_id =  35 then N'text'
             when parameters.system_type_id =  99 then N'ntext'
             when parameters.system_type_id =  40 then N'date'
             when parameters.system_type_id =  61 then N'datetime'
             when parameters.system_type_id =  58 then N'datetime'
             when parameters.system_type_id =  34 then N'image'
             when parameters.system_type_id = 106 then N'decimal('  + cast(parameters.precision  as varchar) + N', ' + cast(parameters.scale as varchar) + N')'
             when parameters.system_type_id = 108 then N'decimal('  + cast(parameters.precision  as varchar) + N', ' + cast(parameters.scale as varchar) + N')'
             when parameters.system_type_id = 165 then N'varbinary('+ (case max_length when -1 then 'max' else cast(parameters.max_length as varchar) end) + N')'
             when parameters.system_type_id = 173 then N'binary('   + cast(parameters.max_length as varchar) + N')'
        end
       ) as ColumnType
     , (case when parameters.system_type_id =  36 then N'SqlDbType.UniqueIdentifier'
             when parameters.system_type_id =  48 then N'SqlDbType.TinyInt'
             when parameters.system_type_id =  56 then N'SqlDbType.Int'
             when parameters.system_type_id =  52 then N'SqlDbType.SmallInt'
             when parameters.system_type_id = 127 then N'SqlDbType.BigInt'
             when parameters.system_type_id =  59 then N'SqlDbType.Real'
             when parameters.system_type_id =  62 then N'SqlDbType.Real'
             when parameters.system_type_id =  60 then N'SqlDbType.Money'
             when parameters.system_type_id = 104 then N'SqlDbType.Bit'
             when parameters.system_type_id = 175 then N'SqlDbType.Char'
             when parameters.system_type_id = 167 then N'SqlDbType.VarChar'
             when parameters.system_type_id = 231 then N'SqlDbType.NVarChar'
             when parameters.system_type_id = 239 then N'SqlDbType.NChar'
             when parameters.system_type_id =  35 then N'SqlDbType.Text'
             when parameters.system_type_id =  99 then N'SqlDbType.NText'
             when parameters.system_type_id =  40 then N'SqlDbType.DateTime'
             when parameters.system_type_id =  61 then N'SqlDbType.DateTime'
             when parameters.system_type_id =  58 then N'SqlDbType.DateTime'
             when parameters.system_type_id =  34 then N'SqlDbType.VarBinary'
             when parameters.system_type_id = 106 then N'SqlDbType.Real'
             when parameters.system_type_id = 108 then N'SqlDbType.Real'
             when parameters.system_type_id = 165 then N'SqlDbType.VarBinary'
             when parameters.system_type_id = 173 then N'SqlDbType.Binary'
        end
       ) as SqlDbType
     -- 01/24/2006 Paul.  A severe error occurred on the current command. The results, if any, should be discarded. 
     -- MS03-031 security patch causes this error because of stricter datatype processing.  
     -- http://www.microsoft.com/technet/security/bulletin/MS03-031.mspx.
     -- http://support.microsoft.com/kb/827366/
     , (case when parameters.system_type_id =  36 then N'Guid'
             when parameters.system_type_id =  48 then N'short'
             when parameters.system_type_id =  56 then N'Int32'
             when parameters.system_type_id =  52 then N'Int16'
             when parameters.system_type_id = 127 then N'Int64'
             when parameters.system_type_id =  59 then N'float'
             when parameters.system_type_id =  62 then N'float'
             when parameters.system_type_id =  60 then N'decimal'
             when parameters.system_type_id = 104 then N'bool'
             when parameters.system_type_id = 175 then N'ansistring'
             when parameters.system_type_id = 167 then N'ansistring'
             when parameters.system_type_id = 231 then N'string'
             when parameters.system_type_id = 239 then N'string'
             when parameters.system_type_id =  35 then N'string'
             when parameters.system_type_id =  99 then N'string'
             when parameters.system_type_id =  40 then N'DateTime'
             when parameters.system_type_id =  61 then N'DateTime'
             when parameters.system_type_id =  58 then N'DateTime'
             when parameters.system_type_id =  34 then N'byte[]'
             when parameters.system_type_id = 106 then N'float'
             when parameters.system_type_id = 108 then N'float'
             when parameters.system_type_id = 165 then N'byte[]'
             when parameters.system_type_id = 173 then N'byte[]'
             when SCHEMA_PARAMETERS.DATA_TYPE = 'table type' then 'DataTable'
        end
       ) as CsType
     , (case when parameters.system_type_id =  36 then N'g'
             when parameters.system_type_id =  48 then N'n'
             when parameters.system_type_id =  56 then N'n'
             when parameters.system_type_id =  52 then N'n'
             when parameters.system_type_id = 127 then N'l'
             when parameters.system_type_id =  59 then N'fl'
             when parameters.system_type_id =  62 then N'fl'
             when parameters.system_type_id =  60 then N'd'
             when parameters.system_type_id = 104 then N'b'
             when parameters.system_type_id = 175 then N's'
             when parameters.system_type_id = 167 then N's'
             when parameters.system_type_id = 231 then N's'
             when parameters.system_type_id = 239 then N's'
             when parameters.system_type_id =  35 then N's'
             when parameters.system_type_id =  99 then N's'
             when parameters.system_type_id =  40 then N'dt'
             when parameters.system_type_id =  61 then N'dt'
             when parameters.system_type_id =  58 then N'dt'
             when parameters.system_type_id =  34 then N'by'
             when parameters.system_type_id = 106 then N'fl'
             when parameters.system_type_id = 108 then N'fl'
             when parameters.system_type_id = 165 then N'bin'
             when parameters.system_type_id = 173 then N'bin'
             when SCHEMA_PARAMETERS.DATA_TYPE = 'table type' then 'tbl'
        end
       ) as CsPrefix
     , cast(null as bit) as IsIdentity
     , cast(1    as bit) as IsNullable
  from      sys.procedures         procedures
 inner join sys.parameters         parameters
         on parameters.object_id = procedures.object_id
 inner join INFORMATION_SCHEMA.PARAMETERS SCHEMA_PARAMETERS
         on SCHEMA_PARAMETERS.SPECIFIC_NAME = procedures.name
        and SCHEMA_PARAMETERS.PARAMETER_NAME = parameters.name
 where procedures.type = 'P'
   and parameters.system_type_id <> 189 -- timestamp

GO

Grant Select on dbo.vwSqlColumns to public;
GO

