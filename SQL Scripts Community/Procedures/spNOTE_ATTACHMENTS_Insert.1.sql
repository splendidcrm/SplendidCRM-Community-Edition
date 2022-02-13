if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNOTE_ATTACHMENTS_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNOTE_ATTACHMENTS_Insert;
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
Create Procedure dbo.spNOTE_ATTACHMENTS_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NOTE_ID           uniqueidentifier
	, @DESCRIPTION       nvarchar(255)
	, @FILENAME          nvarchar(255)
	, @FILE_EXT          nvarchar(25)
	, @FILE_MIME_TYPE    nvarchar(100)
	)
as
  begin
	set nocount on
	
	set @ID = newid();
	insert into NOTE_ATTACHMENTS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DESCRIPTION      
		, NOTE_ID          
		, FILENAME         
		, FILE_EXT         
		, FILE_MIME_TYPE   
		)
	values
		( @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @DESCRIPTION      
		, @NOTE_ID          
		, @FILENAME         
		, @FILE_EXT         
		, @FILE_MIME_TYPE   
		);
	
	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- 10/26/2009 Paul.  Now that we are using the NOTE_ATTACHMENTS table for Knowledge Base attachments, 
	-- we can no longer always update the NOTES record. 
	if exists(select * from NOTES where ID = @NOTE_ID) begin -- then
		-- BEGIN Oracle Exception
			update NOTES
			   set MODIFIED_USER_ID     = @MODIFIED_USER_ID 
			     , DATE_MODIFIED        =  getdate()        
			     , DATE_MODIFIED_UTC    =  getutcdate()     
			     , FILENAME             = @FILENAME         
			     , FILE_MIME_TYPE       = @FILE_MIME_TYPE   
			     , NOTE_ATTACHMENT_ID   = @ID               
			 where ID                   = @NOTE_ID          ;
		-- END Oracle Exception
	end -- if;
  end
GO

Grant Execute on dbo.spNOTE_ATTACHMENTS_Insert to public;
GO

