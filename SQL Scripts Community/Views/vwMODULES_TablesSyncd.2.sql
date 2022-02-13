if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_TablesSyncd')
	Drop View dbo.vwMODULES_TablesSyncd;
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
-- 10/27/2009 Paul.  We also need the module name. 
Create View dbo.vwMODULES_TablesSyncd
as
select vwMODULES.MODULE_NAME
     , vwSqlTables.TABLE_NAME
     , cast(0 as bit)         as RELATIONSHIP
  from            vwMODULES
       inner join vwSqlTables
               on vwSqlTables.TABLE_NAME = vwMODULES.TABLE_NAME
 where vwMODULES.SYNC_ENABLED = 1
union
select vwMODULES.MODULE_NAME
     , vwSqlTables.TABLE_NAME
     , cast(1 as bit)         as RELATIONSHIP
  from            vwMODULES
       inner join vwSqlTables
               on vwSqlTables.TABLE_NAME           like vwMODULES.TABLE_NAME + N'_%'
  left outer join vwMODULES                             vwMODULES_NotSyncd
               on vwSqlTables.TABLE_NAME           like N'%_' + vwMODULES_NotSyncd.TABLE_NAME
              and (vwMODULES_NotSyncd.SYNC_ENABLED is null or vwMODULES_NotSyncd.SYNC_ENABLED = 0)
 where vwMODULES.SYNC_ENABLED = 1
   and vwMODULES_NotSyncd.ID is null
   and vwSqlTables.TABLE_NAME not in ('USERS_LAST_IMPORT', 'USERS_LOGINS', 'USERS_SIGNATURES')
   and vwSqlTables.TABLE_NAME not like N'%_AUDIT'
   and vwSqlTables.TABLE_NAME not like N'%_REMOTE'
   and vwSqlTables.TABLE_NAME not like N'%_CSTM'
   and vwSqlTables.TABLE_NAME not like N'%_SYNC'

GO

-- select * from vwMODULES_TablesSyncd order by TABLE_NAME

Grant Select on dbo.vwMODULES_TablesSyncd to public;
GO

