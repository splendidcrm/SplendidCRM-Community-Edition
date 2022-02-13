if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spLANGUAGES_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spLANGUAGES_InsertOnly;
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
Create Procedure dbo.spLANGUAGES_InsertOnly
	( @NAME              nvarchar(10)
	, @LCID              int
	, @ACTIVE            bit
	, @NATIVE_NAME       nvarchar(80)
	, @DISPLAY_NAME      nvarchar(80)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	declare @MODIFIED_USER_ID  uniqueidentifier;
	if not exists(select * from LANGUAGES where NAME = @NAME and DELETED = 0) begin -- then
		set @ID = newid();
		insert into LANGUAGES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, LCID             
			, ACTIVE           
			, NATIVE_NAME      
			, DISPLAY_NAME     
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, @LCID             
			, @ACTIVE           
			, @NATIVE_NAME      
			, @DISPLAY_NAME     
			);
	end -- if;
	-- 01/13/2006 Paul.  InsertOnly is used when importing a Language Pack. Enable the language if necessary. 
	-- 05/21/2008 Paul.  Language is no longer automatically enabled. Now that we add all supported languages, only support the minimum. 
  end
GO
 
Grant Execute on dbo.spLANGUAGES_InsertOnly to public;
GO
 
