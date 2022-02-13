if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTEAMS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTEAMS_InsertOnly;
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
-- 11/18/2006 Paul.  This procedure will be used to create the Global team which will have a hard-coded ID. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 04/28/2016 Paul.  Make sure that the custom field table exists. 
-- 04/28/2016 Paul.  PRIVATE flag should not be null. 
-- 07/24/2019 Paul.  Prevent duplicates. 
Create Procedure dbo.spTEAMS_InsertOnly
	( @ID                uniqueidentifier
	, @NAME              nvarchar(128)
	, @DESCRIPTION       nvarchar(max)
	)
as
  begin
	set nocount on
	
	if dbo.fnTEAMS_IsValidName(@ID, @NAME) = 0 begin -- then
		raiserror(N'spTEAMS_InsertOnly: The name %s already exists.  Duplicate names are not allowed. ', 16, 1, @NAME);
	end else begin
		if not exists(select * from TEAMS where ID = @ID) begin -- then
			if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
				set @ID = newid();
			end -- if;
			insert into TEAMS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, NAME             
				, DESCRIPTION      
				, PRIVATE          
				)
			values 	( @ID               
				, null       
				,  getdate()        
				, null 
				,  getdate()        
				, @NAME             
				, @DESCRIPTION      
				, 0                 
				);
			-- 04/28/2016 Paul.  Make sure that the custom field table exists. 
			if @@ERROR = 0 begin -- then
				if not exists(select * from TEAMS_CSTM where ID_C = @ID) begin -- then
					insert into TEAMS_CSTM ( ID_C ) values ( @ID );
				end -- if;
			end -- if;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spTEAMS_InsertOnly to public;
GO

