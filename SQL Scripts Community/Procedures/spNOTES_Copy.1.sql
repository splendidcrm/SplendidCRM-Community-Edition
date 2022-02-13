if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNOTES_Copy' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNOTES_Copy;
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
-- 12/21/2007 Paul.  The NOTES table is used as a relationship table between emails and attachments. 
-- When applying an Email Template to an Email, we copy the NOTES records. 
-- 10/25/2009 Paul.  Add TEAM_SET_ID. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spNOTES_Copy
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @COPY_ID           uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	)
as
  begin
	set nocount on
	
	set @ID = newid();
	insert into NOTES
		( ID                
		, CREATED_BY        
		, DATE_ENTERED      
		, MODIFIED_USER_ID  
		, DATE_MODIFIED     
		, TEAM_ID           
		, TEAM_SET_ID       
		, NAME              
		, FILENAME          
		, FILE_MIME_TYPE    
		, PARENT_TYPE       
		, PARENT_ID         
		, CONTACT_ID        
		, PORTAL_FLAG       
		, DESCRIPTION       
		, NOTE_ATTACHMENT_ID
		, ASSIGNED_SET_ID   
		)
	select
		  @ID                
		, @MODIFIED_USER_ID  
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  TEAM_ID           
		,  TEAM_SET_ID       
		,  NAME              
		,  FILENAME          
		,  FILE_MIME_TYPE    
		, @PARENT_TYPE       
		, @PARENT_ID         
		,  CONTACT_ID        
		,  PORTAL_FLAG       
		,  DESCRIPTION       
		,  NOTE_ATTACHMENT_ID
		, ASSIGNED_SET_ID    
	  from NOTES
	 where ID = @COPY_ID;

	if not exists(select * from NOTES_CSTM where ID_C = @ID) begin -- then
		insert into NOTES_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO

Grant Execute on dbo.spNOTES_Copy to public;
GO

