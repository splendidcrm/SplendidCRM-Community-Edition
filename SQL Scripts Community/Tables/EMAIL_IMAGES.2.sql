
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
-- 05/17/2017 Paul.  Need to optimize for Azure. CONTENT is null filter is not indexable, so index length field. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_IMAGES' and COLUMN_NAME = 'CONTENT_LENGTH') begin -- then
	print 'alter table EMAIL_IMAGES add CONTENT_LENGTH int null';
	alter table EMAIL_IMAGES add CONTENT_LENGTH int null;

	exec('update EMAIL_IMAGES
	   set CONTENT_LENGTH = datalength(CONTENT);
	create index IDX_EMAIL_IMAGES on dbo.EMAIL_IMAGES (ID, DELETED, CONTENT_LENGTH)');
end -- if;
GO

-- 05/12/2017 Paul.  Need to optimize for Azure. CONTENT is null filter is not indexable, so index length field. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'EMAIL_IMAGES_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'EMAIL_IMAGES_AUDIT' and COLUMN_NAME = 'CONTENT_LENGTH') begin -- then
		print 'alter table EMAIL_IMAGES_AUDIT add CONTENT_LENGTH int null';
		alter table EMAIL_IMAGES_AUDIT add CONTENT_LENGTH int null;
	end -- if;
end -- if;
GO

