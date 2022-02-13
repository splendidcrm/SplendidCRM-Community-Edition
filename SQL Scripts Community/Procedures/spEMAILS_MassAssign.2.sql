if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAILS_MassAssign' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAILS_MassAssign;
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
-- 04/17/2013 Paul.  If the TEAM_ID is updated, then we also need to update TEAM_SET_ID. 
-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
Create Procedure dbo.spEMAILS_MassAssign
	( @ID_LIST           varchar(8000)
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @TEAM_ID           uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ID            uniqueidentifier;
	declare @TEAM_SET_ID   uniqueidentifier;
	declare @TEAM_SET_LIST varchar(8000);
	declare @CurrentPosR   int;
	declare @NextPosR      int;
	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		-- 10/04/2006 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		set @CurrentPosR = @NextPosR+1;

		-- 04/17/2013 Paul.  If the TEAM_ID is updated, then we also need to update TEAM_SET_ID. 
		if @TEAM_ID is not null begin -- then
			select @TEAM_SET_LIST = TEAM_SET_LIST
			  from            EMAILS
			  left outer join TEAM_SETS
			               on TEAM_SETS.ID      = EMAILS.TEAM_SET_ID
			              and TEAM_SETS.DELETED = 0
			 where EMAILS.ID = @ID;
			exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;
		end -- if;
		-- BEGIN Oracle Exception
			update EMAILS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , ASSIGNED_USER_ID  = @ASSIGNED_USER_ID
			     , TEAM_ID           = isnull(@TEAM_ID, TEAM_ID)
			     , TEAM_SET_ID       = isnull(@TEAM_SET_ID, TEAM_SET_ID)
			 where ID                = @ID
			   and DELETED           = 0;

			-- 01/30/2019 Paul.  We should be creating the matching custom audit record. 
			update EMAILS_CSTM
			   set ID_C              = ID_C
			 where ID_C              = @ID;
		-- END Oracle Exception
	end -- while;
  end
GO
 
Grant Execute on dbo.spEMAILS_MassAssign to public;
GO
 
 
