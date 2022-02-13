if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSCHEDULERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSCHEDULERS_Update;
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
-- 12/31/2007 Paul.  Don't need to insert LAST_RUN. 
Create Procedure dbo.spSCHEDULERS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(255)
	, @JOB               nvarchar(255)
	, @DATE_TIME_START   datetime
	, @DATE_TIME_END     datetime
	, @JOB_INTERVAL      nvarchar(100)
	, @TIME_FROM         datetime
	, @TIME_TO           datetime
	, @STATUS            nvarchar(25)
	, @CATCH_UP          bit
	)
as
  begin
	set nocount on

	declare @VALIDATE_CRON bit;
	-- 12/31/2007 Paul.  Only update the scheduler if the CRON can be validated. 
	set @VALIDATE_CRON = dbo.fnCronRun(@JOB_INTERVAL, getdate(), 5);
	if @@ERROR = 0 begin -- then
		if not exists(select * from SCHEDULERS where ID = @ID) begin -- then
			if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
				set @ID = newid();
			end -- if;
			insert into SCHEDULERS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, NAME             
				, JOB              
				, DATE_TIME_START  
				, DATE_TIME_END    
				, JOB_INTERVAL     
				, TIME_FROM        
				, TIME_TO          
				, STATUS           
				, CATCH_UP         
				)
			values 	( @ID               
				, @MODIFIED_USER_ID       
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @NAME             
				, @JOB              
				, @DATE_TIME_START  
				, @DATE_TIME_END    
				, @JOB_INTERVAL     
				, @TIME_FROM        
				, @TIME_TO          
				, @STATUS           
				, @CATCH_UP         
				);
		end else begin
			update SCHEDULERS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , NAME              = @NAME             
			     , JOB               = @JOB              
			     , DATE_TIME_START   = @DATE_TIME_START  
			     , DATE_TIME_END     = @DATE_TIME_END    
			     , JOB_INTERVAL      = @JOB_INTERVAL     
			     , TIME_FROM         = @TIME_FROM        
			     , TIME_TO           = @TIME_TO          
			     , STATUS            = @STATUS           
			     , CATCH_UP          = @CATCH_UP         
			 where ID                = @ID               ;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spSCHEDULERS_Update to public;
GO

