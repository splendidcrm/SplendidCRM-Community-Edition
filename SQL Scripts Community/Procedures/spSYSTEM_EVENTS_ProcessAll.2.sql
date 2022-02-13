if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSYSTEM_EVENTS_ProcessAll' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSYSTEM_EVENTS_ProcessAll;
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
Create Procedure dbo.spSYSTEM_EVENTS_ProcessAll
as
  begin
	set nocount on

	-- 10/13/2008 Paul.  Delete all events older than 24 hours. 
	-- The system events are primarily used to keep servers in sync, 
	-- so we do not need to worry about old events. 
	delete from SYSTEM_EVENTS
	 where DATE_ENTERED < dbo.fnDateAdd_Hours(-24, getdate());
  end
GO

Grant Execute on dbo.spSYSTEM_EVENTS_ProcessAll to public;
GO

