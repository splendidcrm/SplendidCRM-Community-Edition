if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENTS_CONTENT_InitPointer' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENTS_CONTENT_InitPointer;
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
-- 09/15/2009 Paul.  updatetext, readtext and textptr() have been deprecated in SQL Server and are not supported in Azure. 
-- http://msdn.microsoft.com/en-us/library/ms143729.aspx
Create Procedure dbo.spDOCUMENTS_CONTENT_InitPointer
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @FILE_POINTER      binary(16) output
	)
as
  begin
	set nocount on
	
	-- 10/20/2005 Paul.  Truncate the content column so that future write operations can simply append data. 
-- #if SQL_Server /*
	raiserror(N'updatetext, readtext and textptr() have been deprecated. ', 16, 1);
	-- update DOCUMENT_REVISIONS
	--    set CONTENT          = ''               
	--      , MODIFIED_USER_ID = @MODIFIED_USER_ID
	--      , DATE_MODIFIED    =  getdate()        
	--      , DATE_MODIFIED_UTC=  getutcdate()     
	--  where ID               = @ID              ;
	
	-- 10/20/2005 Paul.  in_FILE_POINTER is not used in MySQL. 
	-- select @FILE_POINTER = textptr(CONTENT)
	--   from DOCUMENT_REVISIONS
	--  where ID               = @ID;
-- #endif SQL_Server */



  end
GO
 
Grant Execute on dbo.spDOCUMENTS_CONTENT_InitPointer to public;
GO



