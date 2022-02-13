if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENT_REVISIONS_Duplicate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENT_REVISIONS_Duplicate;
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
Create Procedure dbo.spDOCUMENT_REVISIONS_Duplicate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DOCUMENT_ID       uniqueidentifier
	, @DUPLICATE_ID      uniqueidentifier
	, @REVISION          nvarchar(25)
	, @CHANGE_LOG        nvarchar(255)
	)
as
  begin
	set nocount on
	
	set @ID = newid();
	insert into DOCUMENT_REVISIONS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, CHANGE_LOG       
		, DOCUMENT_ID      
		, FILENAME         
		, FILE_EXT         
		, FILE_MIME_TYPE   
		, REVISION         
		, CONTENT          
		)
	select	  @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @CHANGE_LOG       
		, @DOCUMENT_ID      
		, FILENAME         
		, FILE_EXT         
		, FILE_MIME_TYPE   
		, @REVISION         
		, CONTENT           
	  from      DOCUMENT_REVISIONS
	 inner join DOCUMENTS
	         on DOCUMENTS.DOCUMENT_REVISION_ID = DOCUMENT_REVISIONS.ID
	        and DOCUMENTS.DELETED              = 0
	 where DOCUMENTS.ID = @DUPLICATE_ID;
	
	-- BEGIN Oracle Exception
		select @ID = ID
		  from DOCUMENT_REVISIONS
		 where ID      = @ID
		   and DELETED = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		update DOCUMENTS
		   set MODIFIED_USER_ID     = @MODIFIED_USER_ID 
		     , DATE_MODIFIED        =  getdate()        
		     , DATE_MODIFIED_UTC    =  getutcdate()     
		     , DOCUMENT_REVISION_ID = @ID               
		 where ID                   = @DOCUMENT_ID      ;
	end -- if;
	
	if not exists(select * from DOCUMENT_REVISIONS_CSTM where ID_C = @ID) begin -- then
		insert into DOCUMENT_REVISIONS_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO

Grant Execute on dbo.spDOCUMENT_REVISIONS_Duplicate to public;
GO

