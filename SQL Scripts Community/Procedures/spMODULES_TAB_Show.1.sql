if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_TAB_Show' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_TAB_Show;
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
-- 08/27/2007 Paul.  Update auditing records for primary module being modified only.
-- No sense in updating the auditing records for all modules as it would confuse the issue. 
-- 04/21/2009 Paul.  Correct any ordering problems. 
-- 09/13/2010 Paul.  If the data is bad, then the there may be more than one record with the tab order 
-- so make sure to only return one record. 
Create Procedure dbo.spMODULES_TAB_Show
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID    uniqueidentifier;
	declare @TAB_ORDER  int;
	if exists(select * from MODULES where ID = @ID and DELETED = 0) begin -- then
		-- 11/17/2007 Paul.  First enable the module, then adjust the tab order if necessary. 
		-- This is so that a hidden tab can still be ordered properly when displayed on a mobile browser. 
		-- BEGIN Oracle Exception
			update MODULES
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , TAB_ENABLED       = 1
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception

		if exists(select * from MODULES where ID = @ID and TAB_ORDER = 0 and DELETED = 0) begin -- then
			-- 09/13/2010 Paul.  If the data is bad, then the there may be more than one record with the tab order 
			-- so make sure to only return one record. 
			-- BEGIN Oracle Exception
				select top 1 @SWAP_ID   = ID
				  from MODULES
				 where TAB_ORDER  = 1
				   and DELETED    = 0
				 order by TAB_ORDER;
			-- END Oracle Exception
			-- 01/04/2005 Paul.  If there is a module at 1, shift all modules so that this one can be 1. 
			if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
				-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
				-- BEGIN Oracle Exception
					update MODULES
					   set TAB_ORDER = TAB_ORDER + 1
					 where TAB_ORDER > 0
					   and DELETED = 0;
				-- END Oracle Exception
			end -- if;
			
			-- 01/04/2006 Paul.  Modules made visible start at tab 1. 
			-- BEGIN Oracle Exception
				update MODULES
				   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
				     , DATE_MODIFIED     =  getdate()        
				     , DATE_MODIFIED_UTC =  getutcdate()     
				     , TAB_ORDER         = 1
				 where ID                = @ID
				   and DELETED           = 0;
			-- END Oracle Exception
		end -- if;

		-- 04/21/2009 Paul.  Correct any ordering problems. 
		exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spMODULES_TAB_Show to public;
GO

