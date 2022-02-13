if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spIMPORT_MAPS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spIMPORT_MAPS_Update;
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
-- 10/08/2006 Paul.  NAME, SOURCE and MODULE are now nvarchar fields. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
-- 09/17/2013 Paul.  Add Business Rules to import. 
Create Procedure dbo.spIMPORT_MAPS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(150)
	, @SOURCE            nvarchar(25)
	, @MODULE            nvarchar(25)
	, @HAS_HEADER        bit
	, @IS_PUBLISHED      bit
	, @CONTENT           nvarchar(max)
	, @RULES_XML         nvarchar(max) = null
	)
as
  begin
	set nocount on
	
	if not exists(select * from IMPORT_MAPS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into IMPORT_MAPS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, ASSIGNED_USER_ID 
			, NAME             
			, SOURCE           
			, MODULE           
			, HAS_HEADER       
			, IS_PUBLISHED     
			, CONTENT          
			, RULES_XML        
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @ASSIGNED_USER_ID 
			, @NAME             
			, @SOURCE           
			, @MODULE           
			, @HAS_HEADER       
			, @IS_PUBLISHED     
			, @CONTENT          
			, @RULES_XML        
			);
	end else begin
		update IMPORT_MAPS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID 
		     , NAME              = @NAME             
		     , SOURCE            = @SOURCE           
		     , MODULE            = @MODULE           
		     , HAS_HEADER        = @HAS_HEADER       
		     , IS_PUBLISHED      = @IS_PUBLISHED     
		     , CONTENT           = @CONTENT          
		     , RULES_XML         = @RULES_XML        
		 where ID                = @ID               ;
	end -- if;
  end
GO

Grant Execute on dbo.spIMPORT_MAPS_Update to public;
GO

