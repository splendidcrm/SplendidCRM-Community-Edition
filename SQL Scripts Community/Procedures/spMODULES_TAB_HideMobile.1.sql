if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_TAB_HideMobile' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_TAB_HideMobile;
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
-- 04/21/2009 Paul.  Correct any ordering problems. 
-- 09/13/2010 Paul.  If the data is bad, then the there may be more than one record with the tab order 
-- so make sure to only return one record. 
Create Procedure dbo.spMODULES_TAB_HideMobile
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID    uniqueidentifier;
	declare @TAB_ORDER  int;
	if exists(select * from MODULES where ID = @ID and DELETED = 0) begin -- then
		-- 11/17/2007 Paul.  First disable, then only reset the tab order if not visible on mobile. 
		-- BEGIN Oracle Exception
			update MODULES
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , MOBILE_ENABLED    = 0
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception

		if exists(select * from MODULES where ID = @ID and TAB_ENABLED = 0 and MOBILE_ENABLED = 0 and DELETED = 0) begin -- then
			-- BEGIN Oracle Exception
				select @TAB_ORDER = TAB_ORDER
				  from MODULES
				 where ID          = @ID
				   and DELETED     = 0;
			-- END Oracle Exception
			
			-- 01/04/2006 Paul.  Hidden modules get an order of 0. 
			-- BEGIN Oracle Exception
				update MODULES
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , TAB_ORDER         = 0
				 where ID                = @ID
				   and DELETED           = 0;
			-- END Oracle Exception
			
			-- BEGIN Oracle Exception
				-- 09/13/2010 Paul.  If the data is bad, then the there may be more than one record with the tab order 
				-- so make sure to only return one record. 
				select top 1 @SWAP_ID   = ID
				  from MODULES
				 where TAB_ORDER  = @TAB_ORDER
				   and DELETED    = 0
				 order by TAB_ORDER;
			-- END Oracle Exception
	
			-- 01/04/2006 Paul.  Shift all modules down, but only if there is no duplicate order value. 
			if dbo.fnIsEmptyGuid(@SWAP_ID) = 1 begin -- then
				-- BEGIN Oracle Exception
					update MODULES
					   set TAB_ORDER = TAB_ORDER - 1
					 where TAB_ORDER > @TAB_ORDER
					   and DELETED = 0;
				-- END Oracle Exception
			end -- if;
		end -- if;

		-- 04/21/2009 Paul.  Correct any ordering problems. 
		exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_TAB_HideMobile to public;
GO

