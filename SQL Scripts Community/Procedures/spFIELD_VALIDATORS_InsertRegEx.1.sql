if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFIELD_VALIDATORS_InsertRegEx' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFIELD_VALIDATORS_InsertRegEx;
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
Create Procedure dbo.spFIELD_VALIDATORS_InsertRegEx
	( @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(50)
	, @REGULAR_EXPRESSION nvarchar(2000)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	if not exists(select * from FIELD_VALIDATORS where NAME = @NAME) begin -- then
		set @ID = newid();
		insert into FIELD_VALIDATORS
			( ID                
			, CREATED_BY        
			, DATE_ENTERED      
			, MODIFIED_USER_ID  
			, DATE_MODIFIED     
			, NAME              
			, VALIDATION_TYPE   
			, REGULAR_EXPRESSION
			)
		values
			( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @NAME              
			, N'RegularExpressionValidator'
			, @REGULAR_EXPRESSION
			);
	end -- if;
  end
GO

Grant Execute on dbo.spFIELD_VALIDATORS_InsertRegEx to public;
GO

