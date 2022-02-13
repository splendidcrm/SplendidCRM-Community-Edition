if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTEAM_SETS_AddSet' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTEAM_SETS_AddSet;
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
-- 08/29/2009 Paul.  Teams are not supported in the Community Edition, but the procedure is still called from MassUpdate procedures. 
Create Procedure dbo.spTEAM_SETS_AddSet
	( @ID                   uniqueidentifier output
	, @MODIFIED_USER_ID     uniqueidentifier
	, @OLD_SET_ID           uniqueidentifier
	, @PRIMARY_TEAM_ID      uniqueidentifier
	, @NEW_SET_ID           uniqueidentifier
	)
as
  begin
	set nocount on

		
  end
GO
 
Grant Execute on dbo.spTEAM_SETS_AddSet to public;
GO
 
 
