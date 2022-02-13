if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwTRACKER_LastViewed')
	Drop View dbo.vwTRACKER_LastViewed;
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
-- 04/06/2006 Paul.  The module name needs to be corrected as it will be used in the URL and the folder names are plural. 
-- 04/06/2006 Paul.  Add the IMAGE_NAME column as the filenames will not be changed. 
-- 07/26/2006 Paul.  Join to the modules table and return the relative path.  This will allow for nested modules. 
-- 07/26/2006 Paul.  Using the RELATIVE_PATH will also mean that the module name need not be corrected. 
-- 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
-- 03/31/2012 Paul.  Increase name length to 25. 
Create View dbo.vwTRACKER_LastViewed
as
select vwTRACKER.USER_ID
     , vwTRACKER.MODULE_NAME
     , vwMODULES.RELATIVE_PATH
     , vwTRACKER.ITEM_ID
     , (case when len(vwTRACKER.ITEM_SUMMARY) > 25 then left(vwTRACKER.ITEM_SUMMARY, 25) + N'...'
        else ITEM_SUMMARY
        end) as ITEM_SUMMARY
     , vwTRACKER.DATE_ENTERED
     , vwTRACKER.MODULE_NAME as IMAGE_NAME
  from      vwTRACKER
 inner join vwMODULES
         on vwMODULES.MODULE_NAME = vwTRACKER.MODULE_NAME
 where vwTRACKER.ACTION = N'detailview'

GO

Grant Select on dbo.vwTRACKER_LastViewed to public;
GO

