if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTEAM_MEMBERSHIPS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTEAM_MEMBERSHIPS_Update;
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
-- 08/23/2008 Paul.  This procedure as been stubbed-out as it is usedin spEMAILS_Update. 
Create Procedure dbo.spTEAM_MEMBERSHIPS_Update
	( @MODIFIED_USER_ID  uniqueidentifier
	, @TEAM_ID           uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @EXPLICIT_ASSIGN   bit
	)
as
  begin
	set nocount on
	
  end
GO
 
Grant Execute on dbo.spTEAM_MEMBERSHIPS_Update to public;
GO
 
