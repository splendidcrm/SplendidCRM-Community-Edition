if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENT_REVISIONS_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENT_REVISIONS_Insert;
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
Create Procedure dbo.spDOCUMENT_REVISIONS_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DOCUMENT_ID       uniqueidentifier
	, @REVISION          nvarchar(25)
	, @CHANGE_LOG        nvarchar(255)
	, @FILENAME          nvarchar(255)
	, @FILE_EXT          nvarchar(25)
	, @FILE_MIME_TYPE    nvarchar(100)
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
		)
	values
		( @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @CHANGE_LOG       
		, @DOCUMENT_ID      
		, @FILENAME         
		, @FILE_EXT         
		, @FILE_MIME_TYPE   
		, @REVISION         
		);
	
	-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
	-- BEGIN Oracle Exception
		update DOCUMENTS
		   set MODIFIED_USER_ID     = @MODIFIED_USER_ID 
		     , DATE_MODIFIED        =  getdate()        
		     , DATE_MODIFIED_UTC    =  getutcdate()     
		     , DOCUMENT_REVISION_ID = @ID               
		 where ID                   = @DOCUMENT_ID      ;
	-- END Oracle Exception
	
	if not exists(select * from DOCUMENT_REVISIONS_CSTM where ID_C = @ID) begin -- then
		insert into DOCUMENT_REVISIONS_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO

Grant Execute on dbo.spDOCUMENT_REVISIONS_Insert to public;
GO

