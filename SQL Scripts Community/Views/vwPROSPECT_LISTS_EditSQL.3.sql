if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECT_LISTS_EditSQL')
	Drop View dbo.vwPROSPECT_LISTS_EditSQL;
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
-- 01/14/2010 Paul.  Move DYNAMIC_SQL to a separate table so that it cannot be imported or exported. 
Create View dbo.vwPROSPECT_LISTS_EditSQL
as
select vwPROSPECT_LISTS_Edit.*
     , PROSPECT_LISTS_SQL.DYNAMIC_SQL
     , PROSPECT_LISTS_SQL.DYNAMIC_RDL
  from            vwPROSPECT_LISTS_Edit
  left outer join PROSPECT_LISTS_SQL 
               on PROSPECT_LISTS_SQL.ID = vwPROSPECT_LISTS_Edit.ID

GO

Grant Select on dbo.vwPROSPECT_LISTS_EditSQL to public;
GO


