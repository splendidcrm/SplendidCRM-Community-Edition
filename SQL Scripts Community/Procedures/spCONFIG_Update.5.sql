if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONFIG_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONFIG_Update;
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
-- 09/28/2008 Paul.  max_users is a protected config value that cannot be edited by an admin. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spCONFIG_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @CATEGORY          nvarchar(32)
	, @NAME              nvarchar(60)
	, @VALUE             nvarchar(max)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from CONFIG
		 where NAME = @NAME 
		   and DELETED = 0;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into CONFIG
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, CATEGORY         
			, NAME             
			, VALUE            
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @CATEGORY         
			, @NAME             
			, @VALUE            
			);
	end else begin
		-- 09/28/2008 Paul.  max_users can be inserted, but it cannot be updated. 
		if lower(@NAME) <> N'max_users' begin -- then
			update CONFIG
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , CATEGORY          = @CATEGORY         
			     , NAME              = @NAME             
			     , VALUE             = @VALUE            
			 where ID                = @ID               ;
		end -- if;
	end -- if;

	-- 09/20/2007 Paul.  Create private teams when enabling team management. 
	if @NAME = N'enable_team_management' begin -- then
		if dbo.fnCONFIG_Boolean(@NAME) = 1 begin -- then
			-- 09/14/2008 Paul.  A single space after the procedure simplifies the migration to DB2. 
			exec dbo.spTEAMS_InitPrivate ;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spCONFIG_Update to public;
GO

