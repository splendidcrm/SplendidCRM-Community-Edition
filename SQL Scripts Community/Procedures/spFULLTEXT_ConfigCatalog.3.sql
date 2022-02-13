if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFULLTEXT_ConfigCatalog' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFULLTEXT_ConfigCatalog;
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
-- 02/06/2018 Paul.  Includes in [] so that names can be complex. 
Create Procedure dbo.spFULLTEXT_ConfigCatalog
	( @MODIFIED_USER_ID  uniqueidentifier
	, @OPERATION         nvarchar(25)
	)
as
  begin
	set nocount on

	declare @fulltext_catalog_id int;
	declare @Command             varchar(1000);
	declare @TABLE_NAME          varchar(50);
	declare @CATALOG_NAME        varchar(50);
	set @CATALOG_NAME = db_name() + 'Catalog';

	if @OPERATION = 'Enable' begin -- then
		if not exists(select * from sys.fulltext_document_types where document_type = '.pptx') or not exists(select * from sys.fulltext_document_types where document_type = '.pdf') begin -- then
			exec sp_fulltext_service 'load_os_resources', 1;
			exec sp_fulltext_service 'verify_signature' , 0;
		end -- if;
		if not exists(select fulltext_catalog_id from sys.fulltext_catalogs where name = @CATALOG_NAME) begin -- then
			set @Command = 'Create FullText Catalog [' + @CATALOG_NAME + ']';
			exec(@Command);
		end -- if;
		select @fulltext_catalog_id = fulltext_catalog_id
		  from sys.fulltext_catalogs
		 where name = @CATALOG_NAME;
		if not exists(select * from sys.fulltext_indexes where fulltext_catalog_id = @fulltext_catalog_id and object_name(object_id) = 'DOCUMENT_REVISIONS') begin -- then
			set @Command = 'Create FullText Index on dbo.DOCUMENT_REVISIONS(CONTENT type column FILE_EXT) key index PK_DOCUMENT_REVISIONS on [' + @CATALOG_NAME + ']';
			exec(@Command);
		end -- if;
		if not exists(select * from sys.fulltext_indexes where fulltext_catalog_id = @fulltext_catalog_id and object_name(object_id) = 'NOTE_ATTACHMENTS') begin -- then
			set @Command = 'Create FullText Index on dbo.NOTE_ATTACHMENTS(ATTACHMENT type column FILE_EXT) key index PK_NOTE_ATTACHMENTS on [' + @CATALOG_NAME + ']';
			exec(@Command);
		end -- if;
		-- 10/24/2016 Paul.  KBDocuments use the NOTE_ATTACHMENTS table for attachments and EMAIL_IMAGES table for images. 
		--if not exists(select * from sys.fulltext_indexes where fulltext_catalog_id = @fulltext_catalog_id and object_name(object_id) = 'EMAIL_IMAGES') begin -- then
		--	set @Command = 'Create FullText Index on dbo.EMAIL_IMAGES(CONTENT type column FILE_EXT) key index PK_EMAIL_IMAGES on ' + @CATALOG_NAME;
		--	exec(@Command);
		--end -- if;
	end else if @OPERATION = 'Disable' begin -- then
		if exists(select fulltext_catalog_id from sys.fulltext_catalogs where name = @CATALOG_NAME) begin -- then
			select @fulltext_catalog_id = fulltext_catalog_id
			  from sys.fulltext_catalogs
			 where name = @CATALOG_NAME;

			declare CATALOG_CURSOR cursor for
			select object_name(object_id) as TABLE_NAME
			  from sys.fulltext_indexes
			 where fulltext_catalog_id = @fulltext_catalog_id
			 order by TABLE_NAME;

			open CATALOG_CURSOR;
			fetch next from CATALOG_CURSOR into @TABLE_NAME;
			while @@FETCH_STATUS = 0 begin -- while
				set @Command = 'Drop FullText Index on ' + @TABLE_NAME;
				exec(@Command);
				fetch next from CATALOG_CURSOR into @TABLE_NAME;
			end -- while;
			close CATALOG_CURSOR;
			deallocate CATALOG_CURSOR;
			set @Command = 'Drop FullText Catalog [' + @CATALOG_NAME + ']';
			exec(@Command);
		end -- if;
	end else if @OPERATION = 'RebuildIndex' begin -- then
		set @Command = 'Alter FullText Catalog [' + @CATALOG_NAME + '] rebuild';
		exec(@Command);
	end -- if;
  end
GO

Grant Execute on dbo.spFULLTEXT_ConfigCatalog to public;
GO

-- exec spFULLTEXT_ConfigCatalog null, 'Enable';
-- exec spFULLTEXT_ConfigCatalog null, 'Disable';
-- exec spFULLTEXT_ConfigCatalog null, 'RebuildIndex';
-- exec spFULLTEXT_ConfigCatalog null, 1;
-- exec spFULLTEXT_ConfigCatalog null, 0;

