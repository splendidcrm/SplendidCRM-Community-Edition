if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTERMINOLOGY_HELP_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTERMINOLOGY_HELP_InsertOnly;
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
-- 07/24/2006 Paul.  Increase the MODULE_NAME to 25 to match the size in the MODULES table.
-- 09/15/2009 Paul.  Convert data type to nvarchar(max) to support Azure. 
Create Procedure dbo.spTERMINOLOGY_HELP_InsertOnly
	( @NAME              nvarchar(50)
	, @LANG              nvarchar(10)
	, @MODULE_NAME       nvarchar(25)
	, @DISPLAY_TEXT      nvarchar(max)
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from TERMINOLOGY_HELP
		 where NAME              = @NAME
		   and LANG              = @LANG
		   and MODULE_NAME       = @MODULE_NAME
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into TERMINOLOGY_HELP
			( ID               
			, DATE_ENTERED     
			, DATE_MODIFIED    
			, NAME             
			, LANG             
			, MODULE_NAME      
			, DISPLAY_TEXT     
			)
		values
			( @ID               
			,  getdate()        
			,  getdate()        
			, @NAME             
			, @LANG             
			, @MODULE_NAME      
			, @DISPLAY_TEXT     
			);
	end -- if;
  end
GO

Grant Execute on dbo.spTERMINOLOGY_HELP_InsertOnly to public;
GO

