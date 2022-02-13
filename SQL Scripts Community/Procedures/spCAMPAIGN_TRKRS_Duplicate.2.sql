if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCAMPAIGN_TRKRS_Duplicate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCAMPAIGN_TRKRS_Duplicate;
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
Create Procedure dbo.spCAMPAIGN_TRKRS_Duplicate
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DUPLICATE_ID      uniqueidentifier
	, @CAMPAIGN_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @TEMP_TRACKER_KEY nvarchar(30);
	set @ID = null;
	if not exists(select * from vwCAMPAIGN_TRKRS where ID = @DUPLICATE_ID) begin -- then
		raiserror(N'Cannot duplicate non-existent campaign tracker.', 16, 1);
		return;
	end -- if;

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	exec dbo.spNUMBER_SEQUENCES_Formatted 'CAMPAIGN_TRKRS.TRACKER_KEY', 1, @TEMP_TRACKER_KEY out;
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
	select	  @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		,  TRACKER_NAME     
		,  TRACKER_URL      
		, @TEMP_TRACKER_KEY 
		, @CAMPAIGN_ID      
		,  IS_OPTOUT        
	  from CAMPAIGN_TRKRS
	 where ID = @DUPLICATE_ID;

	insert into CAMPAIGN_TRKRS_CSTM ( ID_C ) values ( @ID );
  end
GO
 
Grant Execute on dbo.spCAMPAIGN_TRKRS_Duplicate to public;
GO

