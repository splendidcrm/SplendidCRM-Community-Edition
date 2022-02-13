if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAIL_MARKETING_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAIL_MARKETING_Update;
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
-- 04/21/2006 Paul.  INBOUND_EMAIL_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  STATUS was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  ALL_PROSPECT_LISTS was added in SugarCRM 4.0.
-- 07/08/2007 Paul.  The CAMPAIGN_ID cannot be changed. 
-- 12/15/2007 Paul.  If we are enabling ALL, then delete any existing prospect lists. 
-- 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
Create Procedure dbo.spEMAIL_MARKETING_Update
	( @ID                 uniqueidentifier output
	, @MODIFIED_USER_ID   uniqueidentifier
	, @NAME               nvarchar(255)
	, @FROM_ADDR          nvarchar(100)
	, @FROM_NAME          nvarchar(100)
	, @DATE_TIME          datetime
	, @TEMPLATE_ID        uniqueidentifier
	, @CAMPAIGN_ID        uniqueidentifier
	, @INBOUND_EMAIL_ID   uniqueidentifier
	, @STATUS             nvarchar(25)
	, @ALL_PROSPECT_LISTS bit
	, @REPLY_TO_NAME      nvarchar(100) = null
	, @REPLY_TO_ADDR      nvarchar(100) = null
	)
as
  begin
	set nocount on

	declare @DATE_START datetime;
	declare @TIME_START datetime;
	-- 07/08/2007 Paul.  Use date functions so that the conversions will be simplified. 
	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);
	
	if not exists(select * from EMAIL_MARKETING where ID = @ID) begin -- then
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
		values
			( @ID                
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @MODIFIED_USER_ID  
			,  getdate()         
			, @NAME              
			, @FROM_ADDR         
			, @FROM_NAME         
			, @DATE_START        
			, @TIME_START        
			, @TEMPLATE_ID       
			, @CAMPAIGN_ID       
			, @INBOUND_EMAIL_ID  
			, @STATUS            
			, @ALL_PROSPECT_LISTS
			, @REPLY_TO_NAME     
			, @REPLY_TO_ADDR     
			);
	end else begin
		update EMAIL_MARKETING
		   set MODIFIED_USER_ID   = @MODIFIED_USER_ID  
		     , DATE_MODIFIED      =  getdate()         
		     , DATE_MODIFIED_UTC  =  getutcdate()      
		     , NAME               = @NAME              
		     , FROM_ADDR          = @FROM_ADDR         
		     , FROM_NAME          = @FROM_NAME         
		     , DATE_START         = @DATE_START        
		     , TIME_START         = @TIME_START        
		     , TEMPLATE_ID        = @TEMPLATE_ID       
		     , INBOUND_EMAIL_ID   = @INBOUND_EMAIL_ID  
		     , STATUS             = @STATUS            
		     , ALL_PROSPECT_LISTS = @ALL_PROSPECT_LISTS
		     , REPLY_TO_ADDR      = @REPLY_TO_ADDR     
		     , REPLY_TO_NAME      = @REPLY_TO_NAME     
		 where ID                 = @ID                ;
		if @ALL_PROSPECT_LISTS = 1 begin -- then
			-- 12/15/2007 Paul.  Delete the existing prospect lists. 
			if exists(select * from EMAIL_MARKETING_PROSPECT_LISTS where EMAIL_MARKETING_ID = @ID and DELETED = 0) begin -- then
				update EMAIL_MARKETING_PROSPECT_LISTS
				   set DELETED            = 1
				     , MODIFIED_USER_ID   = @MODIFIED_USER_ID 
				     , DATE_MODIFIED      =  getdate()        
				     , DATE_MODIFIED_UTC  =  getutcdate()     
				 where EMAIL_MARKETING_ID = @ID
				   and DELETED            = 0;
			end -- if;
		end -- if;
	end -- if;

	if not exists(select * from EMAIL_MARKETING_CSTM where ID_C = @ID) begin -- then
		insert into EMAIL_MARKETING_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO

Grant Execute on dbo.spEMAIL_MARKETING_Update to public;
GO

