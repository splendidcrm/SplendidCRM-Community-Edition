if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACTIVITIES_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACTIVITIES_Delete;
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
Create Procedure dbo.spACTIVITIES_Delete
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on
	
	declare @ACTIVITY_TYPE nvarchar(25);
	select @ACTIVITY_TYPE = ACTIVITY_TYPE
	  from vwACTIVITIES
	 where ID = @ID;

	if @ACTIVITY_TYPE = N'Tasks' begin -- then
		exec dbo.spTASKS_Delete @ID, @MODIFIED_USER_ID;
	end else if @ACTIVITY_TYPE = N'Meetings' begin -- then
		exec dbo.spMEETINGS_Delete @ID, @MODIFIED_USER_ID;
	end else if @ACTIVITY_TYPE = N'Calls' begin -- then
		exec dbo.spCALLS_Delete @ID, @MODIFIED_USER_ID;
	end else if @ACTIVITY_TYPE = N'Emails' begin -- then
		exec dbo.spEMAILS_Delete @ID, @MODIFIED_USER_ID;
	end else if @ACTIVITY_TYPE = N'Notes' begin -- then
		exec dbo.spNOTES_Delete @ID, @MODIFIED_USER_ID;
	end else begin
		-- 03/29/2006 Paul.  SQL Server 2005 Express error.
		-- Cannot specify uniqueidentifier data type (parameter 4) as a substitution parameter.
		raiserror(N'Could not find activity', 16, 1);
	end -- if;
  end
GO

Grant Execute on dbo.spACTIVITIES_Delete to public;
GO

