if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMEETINGS_New' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMEETINGS_New;
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
-- 06/20/2009 Paul.  We need to get and assign the default team otherwise the new record 
-- will not be displayed if the Team Required flag is set. 
-- 11/28/2009 Paul.  Add UTC date. 
-- 01/14/2010 Paul.  Add support for Team Sets. 
-- 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
-- 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
-- 09/06/2013 Paul.  Increase NAME size to 150 to support Asterisk. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spMEETINGS_New
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(150)
	, @DATE_TIME         datetime
	, @ASSIGNED_USER_ID  uniqueidentifier = null
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @TEAM_SET_ID         uniqueidentifier;
	declare @ASSIGNED_SET_ID     uniqueidentifier;
	declare @DURATION_HOURS      int;
	declare @DURATION_MINUTES    int;
	declare @STATUS              nvarchar(25);

	declare @DATE_START          datetime;
	declare @TIME_START          datetime;
	declare @DATE_END            datetime;

	-- 01/16/2012 Paul.  Normalize the team set by placing the primary ID first, then order list by ID and the name by team names. 
	-- 01/16/2012 Paul.  Use a team set so that team name changes can propagate. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spASSIGNED_SETS_NormalizeSet @ASSIGNED_SET_ID out, @MODIFIED_USER_ID, @ASSIGNED_USER_ID, @ASSIGNED_SET_LIST;

	-- 10/26/2006 Paul.  Default to a 1 hour duration, Outbound, Planned.
	set @DURATION_HOURS   = 1;
	set @DURATION_MINUTES = 0;
	set @STATUS           = N'Planned';

	-- 04/02/2006 Paul.  Use date functions so that the conversions will be simplified. 
	set @DATE_END   = dbo.fnDateAdd_Minutes(@DURATION_MINUTES, dbo.fnDateAdd_Hours(@DURATION_HOURS, @DATE_TIME));
	set @DATE_START = dbo.fnStoreDateOnly(@DATE_TIME);
	set @TIME_START = dbo.fnStoreTimeOnly(@DATE_TIME);

	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
	end -- if;
	insert into MEETINGS
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, DATE_MODIFIED_UTC
		, ASSIGNED_USER_ID 
		, NAME             
		, DURATION_HOURS   
		, DURATION_MINUTES 
		, DATE_START       
		, TIME_START       
		, DATE_END         
		, STATUS           
		, TEAM_ID          
		, TEAM_SET_ID      
		, ASSIGNED_SET_ID  
		)
	values
		( @ID               
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		,  getutcdate()     
		, @ASSIGNED_USER_ID 
		, @NAME             
		, @DURATION_HOURS   
		, @DURATION_MINUTES 
		, @DATE_START       
		, @TIME_START       
		, @DATE_END         
		, @STATUS           
		, @TEAM_ID          
		, @TEAM_SET_ID      
		, @ASSIGNED_SET_ID  
		);

	-- 03/04/2006 Paul.  Add record to custom table. 
	if not exists(select * from MEETINGS_CSTM where ID_C = @ID) begin -- then
		insert into MEETINGS_CSTM ( ID_C ) values ( @ID );
	end -- if;


	if @@ERROR = 0 begin -- then
		-- 06/09/2006 Paul.  New meetings are automatically assigned to the active user. 
		if dbo.fnIsEmptyGuid(@ASSIGNED_USER_ID) = 0 begin -- then
			exec dbo.spMEETINGS_USERS_Update      @MODIFIED_USER_ID, @ID, @ASSIGNED_USER_ID, 1, null;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spMEETINGS_New to public;
GO

