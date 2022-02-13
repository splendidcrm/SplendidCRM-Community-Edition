if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFULLTEXT_UpdateLayouts' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFULLTEXT_UpdateLayouts;
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
Create Procedure dbo.spFULLTEXT_UpdateLayouts
	( @MODIFIED_USER_ID  uniqueidentifier
	, @OPERATION         nvarchar(25)
	)
as
  begin
	set nocount on

	if @OPERATION = 'Enable' begin -- then
		-- 10/24/2016 Paul.  KBDocuments use the NOTE_ATTACHMENTS table for attachments and EMAIL_IMAGES table for images. 
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchAdvanced' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchAdvanced' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'ATTACHMENT'
				     , DATA_LABEL        = 'KBDocuments.LBL_ATTACHMENT'
				     , DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchAdvanced' and DATA_FIELD = 'DESCRIPTION' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
				   and DATA_FIELD        = 'DESCRIPTION'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchAdvanced', 1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchAdvanced', -1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchBasic' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchBasic' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'ATTACHMENT'
				     , DATA_LABEL        = 'KBDocuments.LBL_ATTACHMENT'
				     , DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchBasic'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchBasic' and DATA_FIELD = 'DESCRIPTION' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchBasic'
				   and DATA_FIELD        = 'DESCRIPTION'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchBasic'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchBasic', 1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchBasic'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchBasic', -1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchBasic'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchPopup' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchPopup' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'ATTACHMENT'
				     , DATA_LABEL        = 'KBDocuments.LBL_ATTACHMENT'
				     , DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchPopup'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchPopup' and DATA_FIELD = 'DOCUMENT_NAME' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchPopup'
				   and DATA_FIELD        = 'DOCUMENT_NAME'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchPopup'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchPopup', 1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchPopup'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'KBDocuments.SearchPopup', -1, 'KBDocuments.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext KBDocuments'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'KBDocuments.SearchPopup'
				   and DATA_FIELD        = 'ATTACHMENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;

		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'CONTENT'
				     , DATA_LABEL        = 'Documents.LBL_CONTENT'
				     , DATA_FORMAT       = 'fulltext Documents'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchAdvanced'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and DATA_FIELD = 'DOCUMENT_NAME' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchAdvanced'
				   and DATA_FIELD        = 'DOCUMENT_NAME'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchAdvanced'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchAdvanced', 1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchAdvanced'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchAdvanced', -1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchAdvanced'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'CONTENT'
				     , DATA_LABEL        = 'Documents.LBL_CONTENT'
				     , DATA_FORMAT       = 'fulltext Documents'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchBasic'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and DATA_FIELD = 'DOCUMENT_NAME' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchBasic'
				   and DATA_FIELD        = 'DOCUMENT_NAME'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchBasic'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchBasic', 1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchBasic'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchBasic', -1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchBasic'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchPopup' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchPopup' and FIELD_TYPE = 'Blank' and FIELD_INDEX = 1 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set FIELD_TYPE        = 'TextBox'
				     , DATA_FIELD        = 'CONTENT'
				     , DATA_LABEL        = 'Documents.LBL_CONTENT'
				     , DATA_FORMAT       = 'fulltext Documents'
				     , DATA_REQUIRED     = 0
				     , UI_REQUIRED       = 0
				     , FORMAT_SIZE       = 35
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchPopup'
				   and FIELD_TYPE        = 'Blank' 
				   and FIELD_INDEX       = 1
				   and DEFAULT_VIEW      = 0
				   and DELETED           = 0;
			end else if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchPopup' and DATA_FIELD = 'DOCUMENT_NAME' and FIELD_INDEX = 0 and COLSPAN = 3 and DELETED = 0) begin -- then
				update EDITVIEWS_FIELDS
				   set COLSPAN           = 2
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchPopup'
				   and DATA_FIELD        = 'DOCUMENT_NAME'
				   and FIELD_INDEX       = 0
				   and COLSPAN           = 3
				   and DELETED           = 0;
				update EDITVIEWS_FIELDS
				   set FIELD_INDEX       = FIELD_INDEX + 1
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchPopup'
				   and FIELD_INDEX      >= 1
				   and DELETED           = 0;
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchPopup', 1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchPopup'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end else begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsBound 'Documents.SearchPopup', -1, 'Documents.LBL_CONTENT', 'CONTENT', 0, null, null, 35, null;
				update EDITVIEWS_FIELDS
				   set DATA_FORMAT       = 'fulltext Documents'
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where EDIT_NAME         = 'Documents.SearchPopup'
				   and DATA_FIELD        = 'CONTENT'
				   and DELETED           = 0;
			end -- if;
		end -- if;

		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchAdvanced' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			exec dbo.spEDITVIEWS_FIELDS_InsBound 'Notes.SearchAdvanced', -1, 'Notes.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
			update EDITVIEWS_FIELDS
			   set DATA_FORMAT       = 'fulltext Notes'
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Notes.SearchAdvanced'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DELETED           = 0;
		end -- if;
		if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchBasic' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			exec dbo.spEDITVIEWS_FIELDS_InsBound 'Notes.SearchBasic'   , -1, 'Notes.LBL_ATTACHMENT', 'ATTACHMENT', 0, null, null, 35, null;
			update EDITVIEWS_FIELDS
			   set DATA_FORMAT       = 'fulltext Notes'
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Notes.SearchBasic'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DELETED           = 0;
		end -- if;
	end else if @OPERATION = 'Disable' begin -- then
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchAdvanced' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'KBDocuments.SearchAdvanced'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchBasic' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'KBDocuments.SearchBasic'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'KBDocuments.SearchPopup' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'KBDocuments.SearchPopup'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;

		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchAdvanced' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Documents.SearchAdvanced'
			   and DATA_FIELD        = 'CONTENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchBasic' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Documents.SearchBasic'
			   and DATA_FIELD        = 'CONTENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchPopup' and DATA_FIELD = 'CONTENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set FIELD_TYPE        = 'Blank'
			     , DATA_FIELD        = null
			     , DATA_LABEL        = null
			     , DATA_REQUIRED     = null
			     , UI_REQUIRED       = null
			     , FORMAT_SIZE       = null
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Documents.SearchPopup'
			   and DATA_FIELD        = 'CONTENT'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;

		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchAdvanced' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Notes.SearchAdvanced'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DELETED           = 0;
		end -- if;
		if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchBasic' and DATA_FIELD = 'ATTACHMENT' and DELETED = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = null
			 where EDIT_NAME         = 'Notes.SearchBasic'
			   and DATA_FIELD        = 'ATTACHMENT'
			   and DELETED           = 0;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spFULLTEXT_UpdateLayouts to public;
GO

-- exec spFULLTEXT_UpdateLayouts null, 1;
-- exec spFULLTEXT_UpdateLayouts null, 0;

