if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spASSIGNED_SETS_NormalizeSet' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spASSIGNED_SETS_NormalizeSet;
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
-- 12/27/2021 Paul.  Correct to match Enterprise version.  
Create Procedure dbo.spASSIGNED_SETS_NormalizeSet
	( @ID                   uniqueidentifier output
	, @MODIFIED_USER_ID     uniqueidentifier
	, @PRIMARY_USER_ID      uniqueidentifier
	, @ASSIGNED_SET_LIST    varchar(8000)
	)
as
  begin
	set nocount on

		
  end
GO
 
Grant Execute on dbo.spASSIGNED_SETS_NormalizeSet to public;
GO
 
 
