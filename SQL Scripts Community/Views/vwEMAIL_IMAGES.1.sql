if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwEMAIL_IMAGES')
	Drop View dbo.vwEMAIL_IMAGES;
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
-- 06/19/2010 Paul.  View was pointing to IMAGES table and not EMAIL_IMAGES table. 
-- 05/17/2017 Paul.  Need to optimize for Azure. CONTENT is null filter is not indexable, so index length field. 
Create View dbo.vwEMAIL_IMAGES
as
select ID
     , PARENT_ID
     , FILENAME
     , FILE_MIME_TYPE
     , DATE_ENTERED 
     , CONTENT_LENGTH  as FILE_SIZE
  from EMAIL_IMAGES
 where DELETED = 0

GO

Grant Select on dbo.vwEMAIL_IMAGES to public;
GO

