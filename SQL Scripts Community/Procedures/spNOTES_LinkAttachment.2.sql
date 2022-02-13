if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNOTES_LinkAttachment' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNOTES_LinkAttachment;
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
-- 03/30/2013 Paul.  Link attachments to campaign emails. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spNOTES_LinkAttachment
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(255)
	, @PARENT_TYPE        nvarchar(25)
	, @PARENT_ID          uniqueidentifier
	, @DESCRIPTION        nvarchar(max)
	, @ASSIGNED_USER_ID   uniqueidentifier
	, @TEAM_ID            uniqueidentifier
	, @TEAM_SET_ID        uniqueidentifier
	, @NOTE_ATTACHMENT_ID uniqueidentifier
	, @ASSIGNED_SET_ID    uniqueidentifier
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	insert into NOTES
		( ID                
		, CREATED_BY        
		, DATE_ENTERED      
		, MODIFIED_USER_ID  
		, DATE_MODIFIED     
		, DATE_MODIFIED_UTC 
		, NAME              
		, PARENT_TYPE       
		, PARENT_ID         
		, DESCRIPTION       
		, TEAM_ID           
		, TEAM_SET_ID       
		, ASSIGNED_USER_ID  
		, NOTE_ATTACHMENT_ID
		, ASSIGNED_SET_ID   
		)
	values
		( @ID                
		, @MODIFIED_USER_ID  
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  getutcdate()      
		, @NAME              
		, @PARENT_TYPE       
		, @PARENT_ID         
		, @DESCRIPTION       
		, @TEAM_ID           
		, @TEAM_SET_ID       
		, @ASSIGNED_USER_ID  
		, @NOTE_ATTACHMENT_ID
		, @ASSIGNED_SET_ID   
		);
	if @@ERROR = 0 begin -- then
		if not exists(select * from NOTES_CSTM where ID_C = @ID) begin -- then
			insert into NOTES_CSTM ( ID_C ) values ( @ID );
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spNOTES_LinkAttachment to public;
GO

