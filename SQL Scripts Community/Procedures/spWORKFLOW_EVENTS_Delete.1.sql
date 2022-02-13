if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spWORKFLOW_EVENTS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spWORKFLOW_EVENTS_Delete;
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
-- 08/27/2008 Paul.  PostgreSQL requires delete from clause. 
Create Procedure dbo.spWORKFLOW_EVENTS_Delete
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on
	
	delete from WORKFLOW_EVENTS
	 where ID = @ID;
  end
GO

Grant Execute on dbo.spWORKFLOW_EVENTS_Delete to public;
GO

