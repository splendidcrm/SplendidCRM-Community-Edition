
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
-- 10/26/2009 Paul.  We will be placing Knowledge Base Attachments in this table, so we need to remove the foreign key. 
-- 11/03/2009 Paul.  Azure does not like multi-part identifiers. 
-- 05/12/2017 Paul.  Need to optimize for Azure. ATTACHMENT is null filter is not indexable, so index length field. 
if exists(select *
            from      INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS   REFERENTIAL_CONSTRAINTS
           inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS         TABLE_CONSTRAINTS
                   on TABLE_CONSTRAINTS.CONSTRAINT_NAME          = REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME
                  and TABLE_CONSTRAINTS.CONSTRAINT_TYPE          = 'FOREIGN KEY'
           inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   CONSTRAINT_COLUMN_USAGE
                   on CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME    = REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME
                  and CONSTRAINT_COLUMN_USAGE.TABLE_NAME         = TABLE_CONSTRAINTS.TABLE_NAME
           where TABLE_CONSTRAINTS.TABLE_NAME        = 'NOTE_ATTACHMENTS'
             and CONSTRAINT_COLUMN_USAGE.COLUMN_NAME = 'NOTE_ID') begin -- then
	print 'alter table NOTE_ATTACHMENTS                 drop constraint FK_NOTE_ATTACHMENTS_NOTE_ID;';

	declare @DropFK_NOTE_ATTACHMENTS_NOTE_ID varchar(1000);
	select @DropFK_NOTE_ATTACHMENTS_NOTE_ID = 'alter table ' + upper(TABLE_CONSTRAINTS.TABLE_NAME) + space(32-len(TABLE_CONSTRAINTS.TABLE_NAME)) + ' drop constraint ' + upper(TABLE_CONSTRAINTS.CONSTRAINT_NAME) + ';'
	  from      INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS   REFERENTIAL_CONSTRAINTS
	 inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS         TABLE_CONSTRAINTS
	         on TABLE_CONSTRAINTS.CONSTRAINT_NAME          = REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME
	        and TABLE_CONSTRAINTS.CONSTRAINT_TYPE          = 'FOREIGN KEY'
	 inner join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE   CONSTRAINT_COLUMN_USAGE
	         on CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME    = REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME
	        and CONSTRAINT_COLUMN_USAGE.TABLE_NAME         = TABLE_CONSTRAINTS.TABLE_NAME
	 where TABLE_CONSTRAINTS.TABLE_NAME        = 'NOTE_ATTACHMENTS'
	   and CONSTRAINT_COLUMN_USAGE.COLUMN_NAME = 'NOTE_ID';

	exec(@DropFK_NOTE_ATTACHMENTS_NOTE_ID);
end -- if;
GO

-- 05/12/2017 Paul.  Need to optimize for Azure. ATTACHMENT is null filter is not indexable, so index length field. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTE_ATTACHMENTS' and COLUMN_NAME = 'ATTACHMENT_LENGTH') begin -- then
	print 'alter table NOTE_ATTACHMENTS add ATTACHMENT_LENGTH int null';
	alter table NOTE_ATTACHMENTS add ATTACHMENT_LENGTH int null;

	exec('update NOTE_ATTACHMENTS
	   set ATTACHMENT_LENGTH = datalength(ATTACHMENT);
	create index IDX_NOTE_ATTACHMENTS on dbo.NOTE_ATTACHMENTS (ID, DELETED, ATTACHMENT_LENGTH)');
end -- if;
GO

-- 05/12/2017 Paul.  Need to optimize for Azure. ATTACHMENT is null filter is not indexable, so index length field. 
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'NOTE_ATTACHMENTS_AUDIT') begin -- then
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'NOTE_ATTACHMENTS_AUDIT' and COLUMN_NAME = 'ATTACHMENT_LENGTH') begin -- then
		print 'alter table NOTE_ATTACHMENTS_AUDIT add ATTACHMENT_LENGTH int null';
		alter table NOTE_ATTACHMENTS_AUDIT add ATTACHMENT_LENGTH int null;
	end -- if;
end -- if;
GO

