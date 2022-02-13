if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDOCUMENTS_MassUpdate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDOCUMENTS_MassUpdate;
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
-- 09/11/2007 Paul.  Add TEAM_ID.
-- 05/13/2016 Paul.  Add Tags module. 
-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
Create Procedure dbo.spDOCUMENTS_MassUpdate
	( @ID_LIST               varchar(8000)
	, @MODIFIED_USER_ID      uniqueidentifier
	, @ACTIVE_DATE           datetime
	, @EXP_DATE              datetime
	, @CATEGORY_ID           nvarchar(25)
	, @SUBCATEGORY_ID        nvarchar(25)
	, @STATUS_ID             nvarchar(25)
	, @TEAM_ID               uniqueidentifier = null
	, @TEAM_SET_LIST         varchar(8000) = null
	, @TEAM_SET_ADD          bit = null
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
		-- 10/04/2006 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
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
				  from DOCUMENTS
				 where ID                = @ID
				   and DELETED           = 0;
			-- END Oracle Exception
			if @OLD_SET_ID is not null begin -- then
				exec dbo.spTEAM_SETS_AddSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @OLD_SET_ID, @TEAM_ID, @TEAM_SET_ID;
			end -- if;
		end -- if;

		-- 05/13/2016 Paul.  Add Tags module. 
		if @TAG_SET_NAME is not null and len(@TAG_SET_NAME) > 0 begin -- then
			if @TAG_SET_ADD = 1 begin -- then
				exec dbo.spTAG_SETS_AddSet       @MODIFIED_USER_ID, @ID, N'Documents', @TAG_SET_NAME;
			end else begin
				exec dbo.spTAG_SETS_NormalizeSet @MODIFIED_USER_ID, @ID, N'Documents', @TAG_SET_NAME;
			end -- if;
		end -- if;

		-- BEGIN Oracle Exception
			update DOCUMENTS
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , ACTIVE_DATE       = isnull(@ACTIVE_DATE     , ACTIVE_DATE     )
			     , EXP_DATE          = isnull(@EXP_DATE        , EXP_DATE        )
			     , CATEGORY_ID       = isnull(@CATEGORY_ID     , CATEGORY_ID     )
			     , SUBCATEGORY_ID    = isnull(@SUBCATEGORY_ID  , SUBCATEGORY_ID  )
			     , STATUS_ID         = isnull(@STATUS_ID       , STATUS_ID       )
			     , TEAM_ID           = isnull(@TEAM_ID         , TEAM_ID         )
			     , TEAM_SET_ID       = isnull(@TEAM_SET_ID     , TEAM_SET_ID     )
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception
		-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
		-- BEGIN Oracle Exception
			update DOCUMENTS_CSTM
			   set ID_C              = ID_C
			 where ID_C              = @ID;
		-- END Oracle Exception

		-- 08/30/2009 Paul.  Make sure to update the module-specific team relationships. 
		-- 08/31/2009 Paul.  Instead of managing a separate teams relationship, we will leverage TEAM_SETS_TEAMS. 
		-- if @TEAM_SET_ID is not null begin -- then
		-- 	exec dbo.spDOCUMENTS_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;
		-- end -- if;
	end -- while;
  end
GO
 
Grant Execute on dbo.spDOCUMENTS_MassUpdate to public;
GO
 
 
