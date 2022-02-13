if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_Audited')
	Drop View dbo.vwMODULES_Audited;
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
-- 08/10/2013 Paul.  Contacts, Leads, Prospects and Documents don't have a NAME column. 
Create View dbo.vwMODULES_Audited
as
select MODULE_NAME   
     , DISPLAY_NAME  
  from vwMODULES     
 where TABLE_NAME in (select TABLE_NAME from vwSqlTablesAudited)
   and TABLE_NAME in (select ObjectName from vwSqlColumns
                       where ColumnName = 'NAME'
                          or ObjectName in('Contacts', 'Leads', 'Prospects', 'Documents')
                     )

GO

Grant Select on dbo.vwMODULES_Audited to public;
GO


