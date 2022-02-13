if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDASHLETS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDASHLETS_Update;
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
-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
-- 01/24/2010 Paul.  Allow multiple. 
Create Procedure dbo.spDASHLETS_Update
	( @ID                  uniqueidentifier output
	, @MODIFIED_USER_ID    uniqueidentifier
	, @CATEGORY            nvarchar(25)
	, @MODULE_NAME         nvarchar(50)
	, @CONTROL_NAME        nvarchar(100)
	, @TITLE               nvarchar(100)
	, @DASHLET_ENABLED     bit
	, @ALLOW_MULTIPLE      bit = null
	)
as
  begin
	if not exists(select * from DASHLETS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		insert into DASHLETS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, CATEGORY           
			, MODULE_NAME        
			, CONTROL_NAME       
			, TITLE              
			, DASHLET_ENABLED    
			, ALLOW_MULTIPLE     
			)
		values 
			( @ID                 
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @MODIFIED_USER_ID   
			,  getdate()          
			, @CATEGORY           
			, @MODULE_NAME        
			, @CONTROL_NAME       
			, @TITLE              
			, @DASHLET_ENABLED    
			, @ALLOW_MULTIPLE     
			);
	end else begin
		update DASHLETS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , CATEGORY            = @CATEGORY           
		     , MODULE_NAME         = @MODULE_NAME        
		     , CONTROL_NAME        = @CONTROL_NAME       
		     , TITLE               = @TITLE              
		     , DASHLET_ENABLED     = @DASHLET_ENABLED    
		     , ALLOW_MULTIPLE      = @ALLOW_MULTIPLE     
		 where ID                  = @ID                 ;
	end -- if;
  end
GO
 
Grant Execute on dbo.spDASHLETS_Update to public;
GO
 
