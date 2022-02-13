if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMEETINGS_LEADS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMEETINGS_LEADS_Update;
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
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
Create Procedure dbo.spMEETINGS_LEADS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MEETING_ID        uniqueidentifier
	, @LEAD_ID           uniqueidentifier
	, @REQUIRED          bit
	, @ACCEPT_STATUS     nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from MEETINGS_LEADS
		 where MEETING_ID        = @MEETING_ID
		   and LEAD_ID           = @LEAD_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into MEETINGS_LEADS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, MEETING_ID       
			, LEAD_ID       
			, REQUIRED         
			, ACCEPT_STATUS    
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MEETING_ID       
			, @LEAD_ID       
			, @REQUIRED         
			, @ACCEPT_STATUS    
			);
		
		update MEETINGS
		   set DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @MEETING_ID
		   and DELETED          = 0;
	end else begin
		update MEETINGS_LEADS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , REQUIRED          = @REQUIRED         
		     , ACCEPT_STATUS     = @ACCEPT_STATUS    
		 where ID                = @ID               ;
	end -- if;
	
	if @@ERROR = 0 begin -- then
		-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
		exec dbo.spPARENT_UpdateLastActivity @MODIFIED_USER_ID, @LEAD_ID, N'Leads';
	end -- if;
  end
GO
 
Grant Execute on dbo.spMEETINGS_LEADS_Update to public;
GO
 
