if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spWORKFLOW_EVENTS_ProcessAll' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spWORKFLOW_EVENTS_ProcessAll;
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
-- 12/30/2007 Paul.  We are not ready to do any workflow processing, so just delete the records. 	
-- 01/18/2008 Paul.  Oracle requires from keyword. 
Create Procedure dbo.spWORKFLOW_EVENTS_ProcessAll
as
  begin
	set nocount on
	
	delete from WORKFLOW_EVENTS;
  end
GO

Grant Execute on dbo.spWORKFLOW_EVENTS_ProcessAll to public;
GO

