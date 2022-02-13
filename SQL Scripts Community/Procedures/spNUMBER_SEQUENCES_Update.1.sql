if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNUMBER_SEQUENCES_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNUMBER_SEQUENCES_Update;
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
Create Procedure dbo.spNUMBER_SEQUENCES_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(60)
	, @ALPHA_PREFIX      nvarchar(10)
	, @ALPHA_SUFFIX      nvarchar(10)
	, @SEQUENCE_STEP     int
	, @NUMERIC_PADDING   int
	, @CURRENT_VALUE     int
	)
as
  begin
	set nocount on
	
	if not exists(select * from NUMBER_SEQUENCES where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into NUMBER_SEQUENCES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, ALPHA_PREFIX     
			, ALPHA_SUFFIX     
			, SEQUENCE_STEP    
			, NUMERIC_PADDING  
			, CURRENT_VALUE    
			)
		values 	( @ID               
			, @MODIFIED_USER_ID       
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, @ALPHA_PREFIX     
			, @ALPHA_SUFFIX     
			, @SEQUENCE_STEP    
			, @NUMERIC_PADDING  
			, @CURRENT_VALUE    
			);
	end else begin
		update NUMBER_SEQUENCES
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , NAME              = @NAME             
		     , ALPHA_PREFIX      = @ALPHA_PREFIX     
		     , ALPHA_SUFFIX      = @ALPHA_SUFFIX     
		     , SEQUENCE_STEP     = @SEQUENCE_STEP    
		     , NUMERIC_PADDING   = @NUMERIC_PADDING  
		     , CURRENT_VALUE     = @CURRENT_VALUE    
		 where ID                = @ID               ;
	end -- if;
  end
GO

Grant Execute on dbo.spNUMBER_SEQUENCES_Update to public;
GO


