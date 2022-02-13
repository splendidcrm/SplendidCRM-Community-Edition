if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwMODULES_ARCHIVE_RELATED')
	Drop View dbo.vwMODULES_ARCHIVE_RELATED;
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
-- 01/08/2018 Paul.  ACTIVITIES should never be returned as a related table. 
-- Protect against bad TABLE_NAME in MODULES table. 
-- 01/30/2019 Paul.  Ease conversion to Oracle. 
Create View dbo.vwMODULES_ARCHIVE_RELATED
as
select MODULES_ARCHIVE_RELATED.MODULE_NAME
     , MODULES_ARCHIVE_RELATED.RELATED_NAME
     , MODULES_ARCHIVE_RELATED.RELATED_ORDER
     , MODULES.TABLE_NAME
     , nullif(RELATED.TABLE_NAME, N'ACTIVITIES')   as RELATED_TABLE
  from      MODULES_ARCHIVE_RELATED
 inner join MODULES
         on MODULES.MODULE_NAME    = MODULES_ARCHIVE_RELATED.MODULE_NAME
        and MODULES.DELETED        = 0
 inner join MODULES                  RELATED
         on RELATED.MODULE_NAME    = MODULES_ARCHIVE_RELATED.RELATED_NAME
        and RELATED.MODULE_ENABLED = 1
        and RELATED.DELETED        = 0
 where MODULES_ARCHIVE_RELATED.DELETED = 0

GO

Grant Select on dbo.vwMODULES_ARCHIVE_RELATED to public;
GO

