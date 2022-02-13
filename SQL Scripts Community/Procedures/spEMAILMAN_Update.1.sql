if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILMAN_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILMAN_Update;
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
-- 04/21/2006 Paul.  RELATED_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  EMAILMAN_NUMBER was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  TEMPLATE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_EMAIL was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  FROM_NAME was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  MODULE was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  INVALID_EMAIL was dropped in SugarCRM 4.0.
-- 05/05/2006 Paul.  EMAILMAN_NUMBER cannot be updated because it is an identity. 
-- 07/25/2009 Paul.  EMAILMAN_NUMBER is no longer an identity and must be formatted. 
Create Procedure dbo.spEMAILMAN_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	, @MARKETING_ID      uniqueidentifier
	, @LIST_ID           uniqueidentifier
	, @SEND_DATE_TIME    datetime
	, @IN_QUEUE          bit
	, @IN_QUEUE_DATE     datetime
	, @SEND_ATTEMPTS     int
	, @RELATED_ID        uniqueidentifier
	, @RELATED_TYPE      nvarchar(100)
	, @EMAILMAN_NUMBER   nvarchar(30) = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_EMAILMAN_NUMBER nvarchar(30);
	set @TEMP_EMAILMAN_NUMBER = @EMAILMAN_NUMBER;
	if not exists(select * from EMAILMAN where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 07/25/2009 Paul.  Allow the EMAILMAN_NUMBER to be imported. 
		if @TEMP_EMAILMAN_NUMBER is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'EMAILMAN.EMAILMAN_NUMBER', 1, @TEMP_EMAILMAN_NUMBER out;
		end -- if;
		insert into EMAILMAN
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, EMAILMAN_NUMBER  
			, USER_ID          
			, CAMPAIGN_ID      
			, MARKETING_ID     
			, LIST_ID          
			, SEND_DATE_TIME   
			, IN_QUEUE         
			, IN_QUEUE_DATE    
			, SEND_ATTEMPTS    
			, RELATED_ID       
			, RELATED_TYPE     
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @TEMP_EMAILMAN_NUMBER
			, @USER_ID          
			, @CAMPAIGN_ID      
			, @MARKETING_ID     
			, @LIST_ID          
			, @SEND_DATE_TIME   
			, @IN_QUEUE         
			, @IN_QUEUE_DATE    
			, @SEND_ATTEMPTS    
			, @RELATED_ID       
			, @RELATED_TYPE     
			);
	end else begin
		update EMAILMAN
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , EMAILMAN_NUMBER   = isnull(@TEMP_EMAILMAN_NUMBER, EMAILMAN_NUMBER)
		     , USER_ID           = @USER_ID          
		     , CAMPAIGN_ID       = @CAMPAIGN_ID      
		     , MARKETING_ID      = @MARKETING_ID     
		     , LIST_ID           = @LIST_ID          
		     , SEND_DATE_TIME    = @SEND_DATE_TIME   
		     , IN_QUEUE          = @IN_QUEUE         
		     , IN_QUEUE_DATE     = @IN_QUEUE_DATE    
		     , SEND_ATTEMPTS     = @SEND_ATTEMPTS    
		     , RELATED_ID        = @RELATED_ID       
		     , RELATED_TYPE      = @RELATED_TYPE     
		 where ID                = @ID               ;
	end -- if;

	if not exists(select * from EMAILMAN_CSTM where ID_C = @ID) begin -- then
		insert into EMAILMAN_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO

Grant Execute on dbo.spEMAILMAN_Update to public;
GO

