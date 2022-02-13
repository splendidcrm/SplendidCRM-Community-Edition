if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwSUGARFAVORITES_MyFavorites')
	Drop View dbo.vwSUGARFAVORITES_MyFavorites;
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
-- 12/15/2012 Paul.  vwMODULES now includes a name field, so we must qualify the NAME field. 
Create View dbo.vwSUGARFAVORITES_MyFavorites
as
select ASSIGNED_USER_ID         as USER_ID
     , vwMODULES.MODULE_NAME    as MODULE_NAME
     , vwMODULES.RELATIVE_PATH  as RELATIVE_PATH
     , RECORD_ID                as ITEM_ID
     , (case when len(SUGARFAVORITES.NAME) > 25 then left(SUGARFAVORITES.NAME, 25) + N'...'
        else SUGARFAVORITES.NAME
        end) as ITEM_SUMMARY
  from      SUGARFAVORITES
 inner join vwMODULES
         on vwMODULES.MODULE_NAME = SUGARFAVORITES.MODULE
 where DELETED = 0

GO

Grant Select on dbo.vwSUGARFAVORITES_MyFavorites to public;
GO

