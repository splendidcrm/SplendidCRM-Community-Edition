if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spKBDOCUMENT_ATTACHMENTS_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spKBDOCUMENT_ATTACHMENTS_Insert;
GO

if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spKBDOCUMENTS_ATTACHMENTS_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spKBDOCUMENTS_ATTACHMENTS_Insert;
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
-- 10/26/2009 Paul.  Knowledge Base attachments will be stored in the Note Attachments table. 
Create Procedure dbo.spKBDOCUMENTS_ATTACHMENTS_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @KBDOCUMENT_ID     uniqueidentifier
	, @FILENAME          nvarchar(255)
	, @FILE_EXT          nvarchar(25)
	, @FILE_MIME_TYPE    nvarchar(100)
	)
as
  begin
	set nocount on
	
  end
GO

Grant Execute on dbo.spKBDOCUMENTS_ATTACHMENTS_Insert to public;
GO

