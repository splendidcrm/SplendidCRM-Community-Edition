if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPHONE_NUMBERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPHONE_NUMBERS_Update;
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
Create Procedure dbo.spPHONE_NUMBERS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @PARENT_ID         uniqueidentifier
	, @PARENT_TYPE       nvarchar(25)
	, @PHONE_TYPE        nvarchar(25)
	, @PHONE_NUMBER      nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID                uniqueidentifier;
	declare @NORMALIZED_NUMBER nvarchar(25);

	if @PHONE_NUMBER is not null begin -- then
		set @NORMALIZED_NUMBER = dbo.fnNormalizePhone(@PHONE_NUMBER);
	end -- if;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from PHONE_NUMBERS
		 where PARENT_ID   = @PARENT_ID
		   and PHONE_TYPE  = @PHONE_TYPE
		   and DELETED     = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		if @NORMALIZED_NUMBER is not null begin -- then
			set @ID = newid();
			insert into PHONE_NUMBERS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, PARENT_ID        
				, PARENT_TYPE      
				, PHONE_TYPE       
				, NORMALIZED_NUMBER
				)
			values
				( @ID               
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @MODIFIED_USER_ID 
				,  getdate()        
				, @PARENT_ID        
				, @PARENT_TYPE      
				, @PHONE_TYPE       
				, @NORMALIZED_NUMBER
				);
		end -- if;
	end else begin
		if @NORMALIZED_NUMBER is not null begin -- then
			update PHONE_NUMBERS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , NORMALIZED_NUMBER = @NORMALIZED_NUMBER
			 where ID                = @ID               ;
		end else begin
			update PHONE_NUMBERS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , DELETED           = 1
			 where ID                = @ID               ;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spPHONE_NUMBERS_Update to public;
GO
 
