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
-- 09/15/2009 Paul.  Convert data type to varbinary(max) to support Azure. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 02/09/2017 Paul.  Add index on PARENT_ID.  
-- 05/17/2017 Paul.  Need to optimize for Azure. CONTENT is null filter is not indexable, so index length field. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_IMAGES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.EMAIL_IMAGES';
	Create Table dbo.EMAIL_IMAGES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_EMAIL_IMAGES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PARENT_ID                          uniqueidentifier null
		, FILENAME                           nvarchar(255) null
		, FILE_EXT                           nvarchar(25) null
		, FILE_MIME_TYPE                     nvarchar(100) null
		, CONTENT                            varbinary(max) null
		, CONTENT_LENGTH                     int null
		)

	create index IDX_EMAIL_IMAGES_PARENT_ID on dbo.EMAIL_IMAGES (PARENT_ID, DELETED, ID)
  end
GO


