if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTERMINOLOGY_HELP_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTERMINOLOGY_HELP_Update;
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
-- 10/25/2006 Paul.  The NAME, LANG or MODULE_NAME cannot be changed. 
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spTERMINOLOGY_HELP_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @LANG              nvarchar(10)
	, @MODULE_NAME       nvarchar(25)
	, @DISPLAY_TEXT      nvarchar(max)
	)
as
  begin
	set nocount on
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into TERMINOLOGY_HELP
			( ID               
			, CREATED_BY                  
			, DATE_ENTERED                
			, MODIFIED_USER_ID            
			, DATE_MODIFIED               
			, NAME             
			, LANG             
			, MODULE_NAME      
			, DISPLAY_TEXT     
			)
		values
			( @ID               
			, @MODIFIED_USER_ID            
			,  getdate()                   
			, @MODIFIED_USER_ID            
			,  getdate()                   
			, @NAME             
			, @LANG             
			, @MODULE_NAME      
			, @DISPLAY_TEXT     
			);
	end else begin
		update TERMINOLOGY_HELP
		   set MODIFIED_USER_ID = @MODIFIED_USER_ID
		     , DATE_MODIFIED    =  getdate()        
		     , DATE_MODIFIED_UTC=  getutcdate()     
		     , DISPLAY_TEXT     = @DISPLAY_TEXT     
		 where ID               = @ID              ;
	end -- if;
  end
GO

Grant Execute on dbo.spTERMINOLOGY_HELP_Update to public;
GO

