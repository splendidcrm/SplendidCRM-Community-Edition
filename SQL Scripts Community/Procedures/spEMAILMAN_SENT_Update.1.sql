if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILMAN_SENT_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILMAN_SENT_Update;
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
Create Procedure dbo.spEMAILMAN_SENT_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @TEMPLATE_ID       uniqueidentifier
	, @FROM_EMAIL        nvarchar(255)
	, @FROM_NAME         nvarchar(255)
	, @MODULE_ID         uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	, @MARKETING_ID      uniqueidentifier
	, @LIST_ID           uniqueidentifier
	, @MODULE            nvarchar(100)
	, @SEND_DATE_TIME    datetime
	, @INVALID_EMAIL     bit
	, @IN_QUEUE          bit
	, @IN_QUEUE_DATE     datetime
	, @SEND_ATTEMPTS     int
	)
as
  begin
	set nocount on
	
	if not exists(select * from EMAILMAN_SENT where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into EMAILMAN_SENT
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, USER_ID          
			, TEMPLATE_ID      
			, FROM_EMAIL       
			, FROM_NAME        
			, MODULE_ID        
			, CAMPAIGN_ID      
			, MARKETING_ID     
			, LIST_ID          
			, MODULE           
			, SEND_DATE_TIME   
			, INVALID_EMAIL    
			, IN_QUEUE         
			, IN_QUEUE_DATE    
			, SEND_ATTEMPTS    
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @USER_ID          
			, @TEMPLATE_ID      
			, @FROM_EMAIL       
			, @FROM_NAME        
			, @MODULE_ID        
			, @CAMPAIGN_ID      
			, @MARKETING_ID     
			, @LIST_ID          
			, @MODULE           
			, @SEND_DATE_TIME   
			, @INVALID_EMAIL    
			, @IN_QUEUE         
			, @IN_QUEUE_DATE    
			, @SEND_ATTEMPTS    
			);
	end else begin
		update EMAILMAN_SENT
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , USER_ID           = @USER_ID          
		     , TEMPLATE_ID       = @TEMPLATE_ID      
		     , FROM_EMAIL        = @FROM_EMAIL       
		     , FROM_NAME         = @FROM_NAME        
		     , MODULE_ID         = @MODULE_ID        
		     , CAMPAIGN_ID       = @CAMPAIGN_ID      
		     , MARKETING_ID      = @MARKETING_ID     
		     , LIST_ID           = @LIST_ID          
		     , MODULE            = @MODULE           
		     , SEND_DATE_TIME    = @SEND_DATE_TIME   
		     , INVALID_EMAIL     = @INVALID_EMAIL    
		     , IN_QUEUE          = @IN_QUEUE         
		     , IN_QUEUE_DATE     = @IN_QUEUE_DATE    
		     , SEND_ATTEMPTS     = @SEND_ATTEMPTS    
		 where ID                = @ID               ;
	end -- if;
  end
GO

Grant Execute on dbo.spEMAILMAN_SENT_Update to public;
GO

