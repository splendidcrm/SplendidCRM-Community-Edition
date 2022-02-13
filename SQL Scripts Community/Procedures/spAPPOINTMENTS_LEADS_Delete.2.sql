if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spAPPOINTMENTS_LEADS_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spAPPOINTMENTS_LEADS_Delete;
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
Create Procedure dbo.spAPPOINTMENTS_LEADS_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @ID               uniqueidentifier
	, @LEAD_ID       uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @APPOINTMENT_TYPE nvarchar(25);

	-- BEGIN Oracle Exception
		select @APPOINTMENT_TYPE = APPOINTMENT_TYPE
		  from vwAPPOINTMENTS
		 where ID = @ID;
	-- END Oracle Exception

	-- 03/29/2010 Paul.  A new Appointment will be created as a Meeting. 
	if @APPOINTMENT_TYPE = N'Meetings' or @APPOINTMENT_TYPE is null begin -- then
		exec dbo.spMEETINGS_LEADS_Delete @MODIFIED_USER_ID, @ID, @LEAD_ID;
	end else begin
		exec dbo.spCALLS_LEADS_Delete    @MODIFIED_USER_ID, @ID, @LEAD_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spAPPOINTMENTS_LEADS_Delete to public;
GO

