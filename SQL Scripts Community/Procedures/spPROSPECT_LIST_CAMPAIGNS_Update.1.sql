if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECT_LIST_CAMPAIGNS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECT_LIST_CAMPAIGNS_Update;
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
-- 11/13/2009 Paul.  Remove the unnecessary update as it will reduce offline client conflicts. 
Create Procedure dbo.spPROSPECT_LIST_CAMPAIGNS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @PROSPECT_LIST_ID  uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID uniqueidentifier;
	-- BEGIN Oracle Exception
		select @ID = ID
		  from PROSPECT_LIST_CAMPAIGNS
		 where PROSPECT_LIST_ID  = @PROSPECT_LIST_ID
		   and CAMPAIGN_ID       = @CAMPAIGN_ID
		   and DELETED           = 0;
	-- END Oracle Exception
	
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into PROSPECT_LIST_CAMPAIGNS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, PROSPECT_LIST_ID 
			, CAMPAIGN_ID      
			)
		values
			( @ID               
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @PROSPECT_LIST_ID 
			, @CAMPAIGN_ID      
			);
	end -- if;
  end
GO
 
Grant Execute on dbo.spPROSPECT_LIST_CAMPAIGNS_Update to public;
GO
 
