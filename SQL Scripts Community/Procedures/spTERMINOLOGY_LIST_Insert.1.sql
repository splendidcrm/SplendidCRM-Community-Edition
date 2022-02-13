if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTERMINOLOGY_LIST_Insert' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTERMINOLOGY_LIST_Insert;
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
-- 05/26/2007 Paul.  Truncate NAME to 25 characters as all lists have this maximum.
-- 08/27/2008 Paul.  PostgreSQL does not allow modifying input parameters.  Use a local temp variable. 
-- 03/06/2012 Paul.  Increase size of the NAME field so that it can include a date formula. 
Create Procedure dbo.spTERMINOLOGY_LIST_Insert
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(150)
	, @LANG              nvarchar(10)
	, @MODULE_NAME       nvarchar(25)
	, @LIST_NAME         nvarchar(50)
	, @LIST_ORDER        int
	, @DISPLAY_NAME      nvarchar(max)
	)
as
  begin
	set nocount on
	
	declare @TEMP_LIST_ORDER int;
	set @TEMP_LIST_ORDER = @LIST_ORDER;
	-- First look for an existing key, if found, then overwrite. Duplicates are not allowed. 
	-- BEGIN Oracle Exception
		select @ID = ID
		  from TERMINOLOGY
		 where NAME        = @NAME
		   and LANG        = @LANG
		   and (MODULE_NAME = @MODULE_NAME or (MODULE_NAME is null and @MODULE_NAME is null))
		   and LIST_NAME   = @LIST_NAME
		   and DELETED     = 0;
	-- END Oracle Exception
	if dbo.fnIsEmptyGuid(@ID) = 0 begin -- then
		update TERMINOLOGY
		   set DISPLAY_NAME     = @DISPLAY_NAME
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ID               = @ID;
	end else begin
		-- LIST_ORDER -1 means add to end. 
		if @TEMP_LIST_ORDER = -1 begin -- then
			-- BEGIN Oracle Exception
				select @TEMP_LIST_ORDER = max(LIST_ORDER) + 1
				  from TERMINOLOGY
				 where LANG        = @LANG
				   and (MODULE_NAME = @MODULE_NAME or (MODULE_NAME is null and @MODULE_NAME is null))
				   and LIST_NAME   = @LIST_NAME
				   and DELETED     = 0;
			-- END Oracle Exception
		end -- if;
			-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
		-- BEGIN Oracle Exception
			update TERMINOLOGY
			   set LIST_ORDER       = LIST_ORDER + 1
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			 where LANG             = @LANG
			   and (MODULE_NAME = @MODULE_NAME or (MODULE_NAME is null and @MODULE_NAME is null))
			   and LIST_NAME        = @LIST_NAME
			   and LIST_ORDER      >= @TEMP_LIST_ORDER
			   and DELETED          = 0;
		-- END Oracle Exception

		set @ID = newid();
		insert into TERMINOLOGY
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, NAME             
			, LANG             
			, MODULE_NAME      
			, LIST_NAME        
			, LIST_ORDER       
			, DISPLAY_NAME     
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
			, @LIST_NAME        
			, @TEMP_LIST_ORDER       
			, @DISPLAY_NAME     
			);
	end -- if;
  end
GO

Grant Execute on dbo.spTERMINOLOGY_LIST_Insert to public;
GO

