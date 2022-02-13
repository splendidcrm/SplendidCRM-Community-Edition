if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGN_TRKRS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGN_TRKRS_Update;
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
-- 05/05/2006 Paul.  TRACKER_KEY is an identity and cannot be updated. 
-- 07/08/2007 Paul.  The CAMPAIGN_ID cannot be changed. 
-- 07/25/2009 Paul.  TRACKER_KEY is no longer an identity and must be formatted. 
Create Procedure dbo.spCAMPAIGN_TRKRS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @TRACKER_NAME      nvarchar(30)
	, @TRACKER_URL       nvarchar(255)
	, @CAMPAIGN_ID       uniqueidentifier
	, @IS_OPTOUT         bit
	, @TRACKER_KEY       nvarchar(30) = null
	)
as
  begin
	set nocount on
	
	declare @TEMP_TRACKER_KEY nvarchar(30);
	set @TEMP_TRACKER_KEY = @TRACKER_KEY;
	if not exists(select * from CAMPAIGN_TRKRS where ID = @ID) begin -- then
		if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
			set @ID = newid();
		end -- if;
		-- 07/25/2009 Paul.  Allow the TRACKER_KEY to be imported. 
		if @TEMP_TRACKER_KEY is null begin -- then
			exec dbo.spNUMBER_SEQUENCES_Formatted 'CAMPAIGN_TRKRS.TRACKER_KEY', 1, @TEMP_TRACKER_KEY out;
		end -- if;
		insert into CAMPAIGN_TRKRS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, TRACKER_NAME     
			, TRACKER_URL      
			, TRACKER_KEY      
			, CAMPAIGN_ID      
			, IS_OPTOUT        
			)
		values 	( @ID               
			, @MODIFIED_USER_ID       
			,  getdate()        
			, @MODIFIED_USER_ID 
			,  getdate()        
			, @TRACKER_NAME     
			, @TRACKER_URL      
			, @TEMP_TRACKER_KEY 
			, @CAMPAIGN_ID      
			, @IS_OPTOUT        
			);
	end else begin
		update CAMPAIGN_TRKRS
		   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
		     , DATE_MODIFIED     =  getdate()        
		     , DATE_MODIFIED_UTC =  getutcdate()     
		     , TRACKER_NAME      = @TRACKER_NAME     
		     , TRACKER_URL       = @TRACKER_URL      
		     , TRACKER_KEY       = isnull(@TEMP_TRACKER_KEY, TRACKER_KEY)
		     , IS_OPTOUT         = @IS_OPTOUT        
		 where ID                = @ID               ;
	end -- if;

	if not exists(select * from CAMPAIGN_TRKRS_CSTM where ID_C = @ID) begin -- then
		insert into CAMPAIGN_TRKRS_CSTM ( ID_C ) values ( @ID );
	end -- if;

  end
GO
 
Grant Execute on dbo.spCAMPAIGN_TRKRS_Update to public;
GO
 
