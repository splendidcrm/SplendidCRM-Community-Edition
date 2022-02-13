if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCURRENCIES_InsertOnlyByISO' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCURRENCIES_InsertOnlyByISO;
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
Create Procedure dbo.spCURRENCIES_InsertOnlyByISO
	( @NAME              nvarchar(36)
	, @SYMBOL            nvarchar(36)
	, @ISO4217           nvarchar(3)
	, @CONVERSION_RATE   float(53)
	, @STATUS            nvarchar(25)
	)
as
  begin
	set nocount on
	
	-- 05/01/2016 Paul.  We are going to prepopulate the list and the ISO4217 is required and unique. 
	declare @ID               uniqueidentifier;
	declare @MODIFIED_USER_ID uniqueidentifier;
	declare @TEMP_SYMBOL      nvarchar(36);
	if @ISO4217 is null or @ISO4217 = N'' begin -- then
		raiserror(N'ISO4217 is required', 16, 1);
		return;
	end -- if;
	set @TEMP_SYMBOL = @SYMBOL;
	if @TEMP_SYMBOL is null or @TEMP_SYMBOL = N'' begin -- then
		set @TEMP_SYMBOL = @ISO4217;
	end -- if;
	if not exists(select * from CURRENCIES where ISO4217 = @ISO4217) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into CURRENCIES
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, SYMBOL           
			, ISO4217          
			, CONVERSION_RATE  
			, STATUS           
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @NAME             
			, @TEMP_SYMBOL      
			, @ISO4217          
			, @CONVERSION_RATE  
			, @STATUS           
			);

		if not exists(select * from CURRENCIES_CSTM where ID_C = @ID) begin -- then
			insert into CURRENCIES_CSTM ( ID_C ) values ( @ID );
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spCURRENCIES_InsertOnlyByISO to public;
GO

