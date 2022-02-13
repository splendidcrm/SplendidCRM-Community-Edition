if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spBUG_ATTACHMENTS_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spBUG_ATTACHMENTS_Insert;
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
-- 09/13/2008 Paul.  DB2 does not support optional parameters. 
-- 08/23/2009 Paul.  Since we create a note, we need to pass the team information to the new note. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spBUG_ATTACHMENTS_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @BUG_ID            uniqueidentifier
	, @DESCRIPTION       nvarchar(255)
	, @FILENAME          nvarchar(255)
	, @FILE_EXT          nvarchar(25)
	, @FILE_MIME_TYPE    nvarchar(100)
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	declare @NOTE_ID uniqueidentifier;
	
	-- 08/21/2005 Paul.  Don't use a separate table for bug attachments as SugarCRM already has a relationship with Notes.
	-- 08/23/2009 Paul.  Since we create a note, we need to pass the team information to the new note. 
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spNOTES_Update @NOTE_ID out
		, @MODIFIED_USER_ID
		, @DESCRIPTION, N'Bugs'
		, @BUG_ID
		, null
		, null
		, @TEAM_ID
		, @TEAM_SET_LIST
		, @ASSIGNED_SET_LIST
		;

	exec dbo.spNOTE_ATTACHMENTS_Insert @ID out, @MODIFIED_USER_ID, @NOTE_ID, @DESCRIPTION, @FILENAME, @FILE_EXT, @FILE_MIME_TYPE;
  end
GO

Grant Execute on dbo.spBUG_ATTACHMENTS_Insert to public;
GO

