if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDETAILVIEWS_RELATIONSHIPS_Enable' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_Enable;
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
Create Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_Enable
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @SWAP_ID            uniqueidentifier;
	declare @DETAIL_NAME        nvarchar(50);
	declare @RELATIONSHIP_ORDER int;
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where ID = @ID and DELETED = 0) begin -- then
		-- BEGIN Oracle Exception
			select @DETAIL_NAME        = DETAIL_NAME
			     , @RELATIONSHIP_ORDER = RELATIONSHIP_ORDER
			  from DETAILVIEWS_RELATIONSHIPS
			 where ID          = @ID
			   and DELETED     = 0;
		-- END Oracle Exception

		-- BEGIN Oracle Exception
			select @SWAP_ID           = ID
			  from DETAILVIEWS_RELATIONSHIPS
			 where DETAIL_NAME        = @DETAIL_NAME
			   and RELATIONSHIP_ORDER = 0
			   and DELETED            = 0;
		-- END Oracle Exception
		-- 01/04/2005 Paul.  If there is a module at 0, shift all DETAILVIEWS_RELATIONSHIPS so that this one can be 1. 
		if dbo.fnIsEmptyGuid(@SWAP_ID) = 0 begin -- then
			-- 04/02/2006 Paul.  Catch the Oracle NO_DATA_FOUND exception. 
			-- BEGIN Oracle Exception
				update DETAILVIEWS_RELATIONSHIPS
				   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
				 where DETAIL_NAME        = @DETAIL_NAME
				   and RELATIONSHIP_ORDER >= 0
				   and DELETED = 0;
			-- END Oracle Exception
		end -- if;
		
		-- 01/04/2006 Paul.  DETAILVIEWS_RELATIONSHIPS made visible start at tab 0. 
		-- BEGIN Oracle Exception
			update DETAILVIEWS_RELATIONSHIPS
			   set MODIFIED_USER_ID     = @MODIFIED_USER_ID 
			     , DATE_MODIFIED        =  getdate()        
			     , DATE_MODIFIED_UTC    =  getutcdate()     
			     , RELATIONSHIP_ORDER   = 0
			     , RELATIONSHIP_ENABLED = 1
			 where ID                   = @ID
			   and DELETED              = 0;
		-- END Oracle Exception
	end -- if;
  end
GO

Grant Execute on dbo.spDETAILVIEWS_RELATIONSHIPS_Enable to public;
GO

