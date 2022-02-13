if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAIL_MARKETING_Duplicate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAIL_MARKETING_Duplicate;
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
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
Create Procedure dbo.spEMAIL_MARKETING_Duplicate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DUPLICATE_ID      uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	set @ID = null;
	if not exists(select * from vwEMAIL_MARKETING where ID = @DUPLICATE_ID) begin -- then
		raiserror(N'Cannot duplicate non-existent email marketing.', 16, 1);
		return;
	end -- if;

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	insert into EMAIL_MARKETING
		( ID                
		, CREATED_BY        
		, DATE_ENTERED      
		, MODIFIED_USER_ID  
		, DATE_MODIFIED     
		, NAME              
		, FROM_ADDR         
		, FROM_NAME         
		, DATE_START        
		, TIME_START        
		, TEMPLATE_ID       
		, CAMPAIGN_ID       
		, INBOUND_EMAIL_ID  
		, STATUS            
		, ALL_PROSPECT_LISTS
		, REPLY_TO_NAME     
		, REPLY_TO_ADDR     
		)
	select	  @ID                
		, @MODIFIED_USER_ID  
		,  getdate()         
		, @MODIFIED_USER_ID  
		,  getdate()         
		,  NAME              
		,  FROM_ADDR         
		,  FROM_NAME         
		,  DATE_START        
		,  TIME_START        
		,  TEMPLATE_ID       
		, @CAMPAIGN_ID       
		,  INBOUND_EMAIL_ID  
		,  STATUS            
		,  ALL_PROSPECT_LISTS
		,  REPLY_TO_NAME     
		,  REPLY_TO_ADDR     
	  from EMAIL_MARKETING
	 where ID = @DUPLICATE_ID;

	insert into EMAIL_MARKETING_CSTM ( ID_C ) values ( @ID );
  end
GO
 
Grant Execute on dbo.spEMAIL_MARKETING_Duplicate to public;
GO

