if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFIELD_VALIDATORS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFIELD_VALIDATORS_Update;
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
Create Procedure dbo.spFIELD_VALIDATORS_Update
	( @ID                  uniqueidentifier output
	, @MODIFIED_USER_ID    uniqueidentifier
	, @NAME                nvarchar(50)
	, @VALIDATION_TYPE     nvarchar(50)
	, @REGULAR_EXPRESSION  nvarchar(2000)
	, @DATA_TYPE           nvarchar(25)
	, @MININUM_VALUE       nvarchar(255)
	, @MAXIMUM_VALUE       nvarchar(255)
	, @COMPARE_OPERATOR    nvarchar(25)
	)
as
  begin
	set nocount on
	
	if not exists(select * from FIELD_VALIDATORS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into FIELD_VALIDATORS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, NAME               
			, VALIDATION_TYPE    
			, REGULAR_EXPRESSION 
			, DATA_TYPE          
			, MININUM_VALUE      
			, MAXIMUM_VALUE      
			, COMPARE_OPERATOR   
			)
		values 	( @ID                 
			, @MODIFIED_USER_ID         
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @NAME               
			, @VALIDATION_TYPE    
			, @REGULAR_EXPRESSION 
			, @DATA_TYPE          
			, @MININUM_VALUE      
			, @MAXIMUM_VALUE      
			, @COMPARE_OPERATOR   
			);
	end else begin
		update FIELD_VALIDATORS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , NAME                = @NAME               
		     , VALIDATION_TYPE     = @VALIDATION_TYPE    
		     , REGULAR_EXPRESSION  = @REGULAR_EXPRESSION 
		     , DATA_TYPE           = @DATA_TYPE          
		     , MININUM_VALUE       = @MININUM_VALUE      
		     , MAXIMUM_VALUE       = @MAXIMUM_VALUE      
		     , COMPARE_OPERATOR    = @COMPARE_OPERATOR   
		 where ID                  = @ID                 ;
	end -- if;
  end
GO

Grant Execute on dbo.spFIELD_VALIDATORS_Update to public;
GO

