if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMEETINGS_InviteeMassUpdate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMEETINGS_InviteeMassUpdate;
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
-- 01/24/2009 Paul.  The current user is accepted by default. 
-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
Create Procedure dbo.spMEETINGS_InviteeMassUpdate
	( @MODIFIED_USER_ID  uniqueidentifier
	, @MEETING_ID           uniqueidentifier
	, @ID_LIST           varchar(8000)
	, @REQUIRED          bit
	)
as
  begin
	set nocount on
	
	declare @ID           uniqueidentifier;
	declare @CurrentPosR  int;
	declare @NextPosR     int;
	-- 02/02/2006 Paul.  Should be nvarchar. Caught when testing DB2.
	declare @INVITEE_TYPE nvarchar(25);

	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		-- 10/04/2006 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		set @CurrentPosR = @NextPosR+1;

		select @INVITEE_TYPE = INVITEE_TYPE
		  from vwINVITEES
		 where ID = @ID;
		if @INVITEE_TYPE = N'Users' begin -- then
			-- 01/24/2009 Paul.  The current user is accepted by default. 
			if @MODIFIED_USER_ID = @ID begin -- then
				exec dbo.spMEETINGS_USERS_Update    @MODIFIED_USER_ID, @MEETING_ID, @ID, @REQUIRED, N'accept';
			end else begin
				exec dbo.spMEETINGS_USERS_Update    @MODIFIED_USER_ID, @MEETING_ID, @ID, @REQUIRED, null;
			end -- if;
		end else if @INVITEE_TYPE = N'Contacts' begin -- then
			exec dbo.spMEETINGS_CONTACTS_Update @MODIFIED_USER_ID, @MEETING_ID, @ID, @REQUIRED, null;
		-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
		end else if @INVITEE_TYPE = N'Leads' begin -- then
			exec dbo.spMEETINGS_LEADS_Update @MODIFIED_USER_ID, @MEETING_ID, @ID, @REQUIRED, null;
		end -- if;
	end -- while;
  end
GO
 
Grant Execute on dbo.spMEETINGS_InviteeMassUpdate to public;
GO
 
 
