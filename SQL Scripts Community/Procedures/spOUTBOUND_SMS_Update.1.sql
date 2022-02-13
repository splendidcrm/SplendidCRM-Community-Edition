if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spOUTBOUND_SMS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spOUTBOUND_SMS_Update;
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
Create Procedure dbo.spOUTBOUND_SMS_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(60)
	, @USER_ID            uniqueidentifier
	, @FROM_NUMBER        nvarchar(100)
	)
as
  begin
	set nocount on
	
	if not exists(select * from OUTBOUND_SMS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into OUTBOUND_SMS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, DATE_MODIFIED_UTC 
			, NAME              
			, USER_ID           
			, FROM_NUMBER       
			)
		values 	( @ID                
			, @MODIFIED_USER_ID        
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			,  getutcdate()      
			, @NAME              
			, @USER_ID           
			, @FROM_NUMBER       
			);
	end else begin
		update OUTBOUND_SMS
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , USER_ID            = @USER_ID           
		     , FROM_NUMBER        = @FROM_NUMBER       
		 where ID                 = @ID                ;
	end -- if;
  end
GO

Grant Execute on dbo.spOUTBOUND_SMS_Update to public;
GO

