if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPROSPECT_LISTS_Import' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPROSPECT_LISTS_Import;
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
-- 01/10/2010 Paul.  We are not going to allow the importing of Dynamic SQL.
-- 02/04/2010 Paul.  The Dynamic SQL fields were removed.
-- 01/10/2011 Paul.  Prevent duplicate lists by searching for an existing list. 
-- 01/11/2011 Paul.  If @TEAM_SET_LIST is null, then ignore the existing value for this field. 
-- 05/12/2016 Paul.  Add Tags module. 
-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Create Procedure dbo.spPROSPECT_LISTS_Import
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @ASSIGNED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @DESCRIPTION       nvarchar(max)
	, @PARENT_TYPE       nvarchar(25)
	, @PARENT_ID         uniqueidentifier
	, @LIST_TYPE         nvarchar(255)
	, @DOMAIN_NAME       nvarchar(255)
	, @TEAM_ID           uniqueidentifier = null
	, @TEAM_SET_LIST     varchar(8000) = null
	, @TAG_SET_NAME      nvarchar(4000) = null
	, @ASSIGNED_SET_LIST varchar(8000) = null
	)
as
  begin
	set nocount on
	
	declare @DYNAMIC_LIST      bit;
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		select top 1 @ID     = ID
		  from vwPROSPECT_LISTS
		 where NAME    = @NAME
		   and (ASSIGNED_USER_ID = @ASSIGNED_USER_ID or (ASSIGNED_USER_ID is null and @ASSIGNED_USER_ID is null))
		   and (TEAM_ID          = @TEAM_ID          or (TEAM_ID          is null and @TEAM_ID          is null))
		   and (TEAM_SET_LIST    = @TEAM_SET_LIST    or (@TEAM_SET_LIST   is null));
	end -- if;
	-- 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	exec dbo.spPROSPECT_LISTS_Update @ID out
		, @MODIFIED_USER_ID
		, @ASSIGNED_USER_ID
		, @NAME
		, @DESCRIPTION
		, @PARENT_TYPE
		, @PARENT_ID
		, @LIST_TYPE
		, @DOMAIN_NAME
		, @TEAM_ID
		, @TEAM_SET_LIST
		, @DYNAMIC_LIST
		, @TAG_SET_NAME
		, @ASSIGNED_SET_LIST
		;
  end
GO

Grant Execute on dbo.spPROSPECT_LISTS_Import to public;
GO

