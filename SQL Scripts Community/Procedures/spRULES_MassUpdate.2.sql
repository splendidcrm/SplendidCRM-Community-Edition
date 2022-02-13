if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spRULES_MassUpdate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spRULES_MassUpdate;
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
-- 05/25/2021 Paul.  Add Tags module. 
Create Procedure dbo.spRULES_MassUpdate
	( @ID_LIST           varchar(8000)
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @TEAM_ID           uniqueidentifier
	, @TEAM_SET_LIST     varchar(8000)
	, @TEAM_SET_ADD      bit
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @TAG_SET_ADD       bit = null
	)
as
  begin
	set nocount on
	
	declare @ID           uniqueidentifier;
	declare @CurrentPosR  int;
	declare @NextPosR     int;
	declare @TEAM_SET_ID  uniqueidentifier;
	declare @OLD_SET_ID   uniqueidentifier;

	-- 08/29/2009 Paul.  Allow sets to be mass assigned. 
	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;

	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		set @CurrentPosR = @NextPosR+1;

		-- 08/29/2009 Paul.  When adding a set, we need to start with the existing set of the current record. 
		if @TEAM_SET_ADD = 1 and @TEAM_SET_ID is not null begin -- then
			-- BEGIN Oracle Exception
				-- 08/29/2009 Paul.  If a primary team was not provided, then load the old primary team. 
				select @OLD_SET_ID = TEAM_SET_ID
				     , @TEAM_ID    = isnull(@TEAM_ID, TEAM_ID)
				  from RULES
				 where ID                = @ID
				   and DELETED           = 0;
			-- END Oracle Exception
			if @OLD_SET_ID is not null begin -- then
				exec dbo.spTEAM_SETS_AddSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @OLD_SET_ID, @TEAM_ID, @TEAM_SET_ID;
			end -- if;
		end -- if;

		-- 05/25/2021 Paul.  Add Tags module. 
		if @TAG_SET_NAME is not null and len(@TAG_SET_NAME) > 0 begin -- then
			if @TAG_SET_ADD = 1 begin -- then
				exec dbo.spTAG_SETS_AddSet       @MODIFIED_USER_ID, @ID, N'RulesWizard', @TAG_SET_NAME;
			end else begin
				exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'RulesWizard', @TAG_SET_NAME;
			end -- if;
		end -- if;

		-- BEGIN Oracle Exception
			update RULES
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , ASSIGNED_USER_ID  = isnull(@ASSIGNED_USER_ID, ASSIGNED_USER_ID)
			     , TEAM_ID           = isnull(@TEAM_ID         , TEAM_ID         )
			     , TEAM_SET_ID       = isnull(@TEAM_SET_ID     , TEAM_SET_ID     )
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception
	end -- while;
  end
GO
 
Grant Execute on dbo.spRULES_MassUpdate to public;
GO
 
