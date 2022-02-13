if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwFIELDS_META_DATA_Validated')
	Drop View dbo.vwFIELDS_META_DATA_Validated;
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
-- 07/07/2007 Paul.  Join to the Modules table to get the table name. 
-- Custom Fields was failing fror PRODUCT_TEMPLATES and PROJECT_TASK.
-- 07/07/2007 Paul.  The code searches for the custom module by table name, not by module name. 
-- 07/07/2207 Paul.  Use vwMODULES so that deleted flag and module flag are applied. 
-- 02/18/2009 Paul.  Include the module name to simplify code to generate valid workflow update columns. 
-- 02/18/2009 Paul.  We need to know if the column is an identity so the workflow engine can avoid updating it.
Create View dbo.vwFIELDS_META_DATA_Validated
as
select vwFIELDS_META_DATA.ID
     , vwFIELDS_META_DATA.NAME
     , vwFIELDS_META_DATA.LABEL
     , vwMODULES.MODULE_NAME
     , vwMODULES.TABLE_NAME
     , vwMODULES.TABLE_NAME               as CUSTOM_MODULE
     , vwFIELDS_META_DATA.DATA_TYPE
     , vwFIELDS_META_DATA.MAX_SIZE
     , vwFIELDS_META_DATA.REQUIRED_OPTION
     , vwFIELDS_META_DATA.DEFAULT_VALUE
     , vwSqlColumns.CsType
     , vwSqlColumns.colid
     , vwSqlColumns.IsIdentity
  from      vwFIELDS_META_DATA
 inner join vwMODULES
         on vwMODULES.MODULE_NAME   = vwFIELDS_META_DATA.CUSTOM_MODULE
 inner join vwSqlColumns
         on vwSqlColumns.ObjectName = vwMODULES.TABLE_NAME + '_CSTM'
        and vwSqlColumns.ColumnName = vwFIELDS_META_DATA.NAME

GO

Grant Select on dbo.vwFIELDS_META_DATA_Validated to public;
GO

 
