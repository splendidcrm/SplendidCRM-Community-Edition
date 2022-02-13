if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_FEEDS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_FEEDS_Update;
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
Create Procedure dbo.spUSERS_FEEDS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @FEED_ID           uniqueidentifier
	, @RANK              int
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from USERS_FEEDS
		 where USER_ID           = @USER_ID
		   and FEED_ID           = @FEED_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into USERS_FEEDS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, USER_ID          
			, FEED_ID          
			, RANK             
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @USER_ID          
			, @FEED_ID          
			, @RANK             
			);
	end else begin
		update USERS_FEEDS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , RANK              = @RANK             
		 where ID                = @ID               ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spUSERS_FEEDS_Update to public;
GO
 
