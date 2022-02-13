if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNUMBER_SEQUENCES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNUMBER_SEQUENCES_InsertOnly;
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
Create Procedure dbo.spNUMBER_SEQUENCES_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
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
	
	declare @ID uniqueidentifier;
	if not exists(select * from NUMBER_SEQUENCES where NAME = @NAME) begin -- then
		set @ID = newid();
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
		values
			( @ID               
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
	end -- if;
  end
GO

Grant Execute on dbo.spNUMBER_SEQUENCES_InsertOnly to public;
GO

