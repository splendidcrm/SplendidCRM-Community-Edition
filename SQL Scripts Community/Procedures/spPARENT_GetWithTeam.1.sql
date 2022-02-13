if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPARENT_GetWithTeam' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPARENT_GetWithTeam;
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
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spPARENT_GetWithTeam
	( @ID                uniqueidentifier output
	, @MODULE            nvarchar( 25) output
	, @PARENT_TYPE       nvarchar( 25) output
	, @PARENT_NAME       nvarchar(150) output
	, @ASSIGNED_USER_ID  uniqueidentifier output
	, @ASSIGNED_TO       nvarchar(60) output
	, @ASSIGNED_TO_NAME  nvarchar(100) output
	, @TEAM_ID           uniqueidentifier output
	, @TEAM_NAME         nvarchar(128) output
	, @TEAM_SET_ID       uniqueidentifier output
	, @ASSIGNED_SET_ID   uniqueidentifier output
	)
as
  begin
	set nocount on
	
	declare @PARENT_ID uniqueidentifier;
	select top 1 @PARENT_ID         = PARENT_ID
	     , @MODULE            = MODULE
	     , @PARENT_TYPE       = PARENT_TYPE
	     , @PARENT_NAME       = PARENT_NAME
	     , @ASSIGNED_USER_ID  = PARENT_ASSIGNED_USER_ID
	     , @ASSIGNED_TO       = PARENT_ASSIGNED_TO
	     , @ASSIGNED_TO_NAME  = PARENT_ASSIGNED_TO_NAME
	     , @TEAM_ID           = PARENT_TEAM_ID
	     , @TEAM_NAME         = PARENT_TEAM_NAME
	     , @TEAM_SET_ID       = PARENT_TEAM_SET_ID
	     , @ASSIGNED_SET_ID   = PARENT_ASSIGNED_SET_ID
	  from vwPARENTS_WithTeam
	 where PARENT_ID    = @ID
	 order by PARENT_TYPE;

	-- Return NULL if not found. 
	set @ID = @PARENT_ID;
  end
GO

Grant Execute on dbo.spPARENT_GetWithTeam to public;
GO

