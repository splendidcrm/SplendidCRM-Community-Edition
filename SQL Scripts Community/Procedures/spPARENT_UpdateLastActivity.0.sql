if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPARENT_UpdateLastActivity' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPARENT_UpdateLastActivity;
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
-- 11/22/2012 Paul.  Activity moved to a separate table to prevent auditing. 
Create Procedure dbo.spPARENT_UpdateLastActivity
	( @MODIFIED_USER_ID  uniqueidentifier
	, @PARENT_ID         uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	declare @TEMP_PARENT_TYPE nvarchar(25);
	if not exists(select * from LAST_ACTIVITY where ACTIVITY_ID = @PARENT_ID) begin -- then
		-- 12/15/2013 Paul.  PARENT_TYPE is a required field, so do a lookup if not provided. 
		set @TEMP_PARENT_TYPE = @PARENT_TYPE;
		if @TEMP_PARENT_TYPE is null begin -- then
			-- BEGIN Oracle Exception
				select top 1 @TEMP_PARENT_TYPE = PARENT_TYPE
				  from vwPARENTS
				 where PARENT_ID = @PARENT_ID
				 order by PARENT_TYPE;
			-- END Oracle Exception
		end -- if;

		set @ID = newid();
		insert into LAST_ACTIVITY
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, ACTIVITY_ID       
			, ACTIVITY_TYPE     
			, LAST_ACTIVITY_DATE
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @PARENT_ID        
			, @TEMP_PARENT_TYPE 
			,  getdate()        
			);
	end else begin
		update LAST_ACTIVITY
		   set LAST_ACTIVITY_DATE = getdate()
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = @MODIFIED_USER_ID
		 where ACTIVITY_ID        = @PARENT_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spPARENT_UpdateLastActivity to public;
GO

