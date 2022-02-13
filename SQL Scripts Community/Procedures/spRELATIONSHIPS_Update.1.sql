if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spRELATIONSHIPS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spRELATIONSHIPS_Update;
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
-- 04/29/2006 Paul.  @RELATIONSHIP_ROLE_COLUMN_VALUE is too long for Oracle, so reduce globally. 
Create Procedure dbo.spRELATIONSHIPS_Update
	( @ID                              uniqueidentifier output
	, @MODIFIED_USER_ID                uniqueidentifier
	, @RELATIONSHIP_NAME               nvarchar(150)
	, @LHS_MODULE                      nvarchar(100)
	, @LHS_TABLE                       nvarchar(64)
	, @LHS_KEY                         nvarchar(64)
	, @RHS_MODULE                      nvarchar(100)
	, @RHS_TABLE                       nvarchar(64)
	, @RHS_KEY                         nvarchar(64)
	, @JOIN_TABLE                      nvarchar(64)
	, @JOIN_KEY_LHS                    nvarchar(64)
	, @JOIN_KEY_RHS                    nvarchar(64)
	, @RELATIONSHIP_TYPE               nvarchar(64)
	, @RELATIONSHIP_ROLE_COLUMN        nvarchar(64)
	, @RELATIONSHIP_ROLE_COL_VALUE     nvarchar(50)
	, @REVERSE                         bit
	)
as
  begin
	set nocount on
	
	if not exists(select * from RELATIONSHIPS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into RELATIONSHIPS
			( ID                             
			, CREATED_BY                     
			, DATE_ENTERED                   
			, MODIFIED_USER_ID               
			, DATE_MODIFIED                  
			, RELATIONSHIP_NAME              
			, LHS_MODULE                     
			, LHS_TABLE                      
			, LHS_KEY                        
			, RHS_MODULE                     
			, RHS_TABLE                      
			, RHS_KEY                        
			, JOIN_TABLE                     
			, JOIN_KEY_LHS                   
			, JOIN_KEY_RHS                   
			, RELATIONSHIP_TYPE              
			, RELATIONSHIP_ROLE_COLUMN       
			, RELATIONSHIP_ROLE_COLUMN_VALUE 
			, REVERSE                        
			)
		values 	( @ID                             
			, @MODIFIED_USER_ID                     
			,  getdate()                      
			, @MODIFIED_USER_ID               
			,  getdate()                      
			, @RELATIONSHIP_NAME              
			, @LHS_MODULE                     
			, @LHS_TABLE                      
			, @LHS_KEY                        
			, @RHS_MODULE                     
			, @RHS_TABLE                      
			, @RHS_KEY                        
			, @JOIN_TABLE                     
			, @JOIN_KEY_LHS                   
			, @JOIN_KEY_RHS                   
			, @RELATIONSHIP_TYPE              
			, @RELATIONSHIP_ROLE_COLUMN       
			, @RELATIONSHIP_ROLE_COL_VALUE 
			, @REVERSE                        
			);
	end else begin
		update RELATIONSHIPS
		   set MODIFIED_USER_ID                = @MODIFIED_USER_ID               
		     , DATE_MODIFIED                   =  getdate()                      
		     , DATE_MODIFIED_UTC               =  getutcdate()                   
		     , RELATIONSHIP_NAME               = @RELATIONSHIP_NAME              
		     , LHS_MODULE                      = @LHS_MODULE                     
		     , LHS_TABLE                       = @LHS_TABLE                      
		     , LHS_KEY                         = @LHS_KEY                        
		     , RHS_MODULE                      = @RHS_MODULE                     
		     , RHS_TABLE                       = @RHS_TABLE                      
		     , RHS_KEY                         = @RHS_KEY                        
		     , JOIN_TABLE                      = @JOIN_TABLE                     
		     , JOIN_KEY_LHS                    = @JOIN_KEY_LHS                   
		     , JOIN_KEY_RHS                    = @JOIN_KEY_RHS                   
		     , RELATIONSHIP_TYPE               = @RELATIONSHIP_TYPE              
		     , RELATIONSHIP_ROLE_COLUMN        = @RELATIONSHIP_ROLE_COLUMN       
		     , RELATIONSHIP_ROLE_COLUMN_VALUE  = @RELATIONSHIP_ROLE_COL_VALUE 
		     , REVERSE                         = @REVERSE                        
		 where ID                              = @ID                             ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spRELATIONSHIPS_Update to public;
GO
 
