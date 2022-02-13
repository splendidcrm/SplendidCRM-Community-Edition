if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spRELEASES_MassUpdate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spRELEASES_MassUpdate;
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
-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
Create Procedure dbo.spRELEASES_MassUpdate
	( @ID_LIST           varchar(8000)
	, @MODIFIED_USER_ID  uniqueidentifier
	, @STATUS            nvarchar(25)
	)
as
  begin
	set nocount on
	
	declare @ID           uniqueidentifier;
	declare @CurrentPosR  int;
	declare @NextPosR     int;
	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@ID_LIST) begin -- do
		-- 10/04/2006 Paul.  charindex should not use unicode parameters as it will limit all inputs to 4000 characters. 
		set @NextPosR = charindex(',', @ID_LIST,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@ID_LIST) + 1;
		end -- if;
		set @ID = cast(rtrim(ltrim(substring(@ID_LIST, @CurrentPosR, @NextPosR - @CurrentPosR))) as uniqueidentifier);
		set @CurrentPosR = @NextPosR+1;

		-- BEGIN Oracle Exception
			update RELEASES
			   set MODIFIED_USER_ID  = @MODIFIED_USER_ID 
			     , DATE_MODIFIED     =  getdate()        
			     , DATE_MODIFIED_UTC =  getutcdate()     
			     , STATUS            = isnull(@STATUS, STATUS)
			 where ID                = @ID
			   and DELETED           = 0;
		-- END Oracle Exception
		-- 03/22/2017 Paul.  Update the custom field table so that the audit view will have matching custom field values. 
		-- BEGIN Oracle Exception
			update RELEASES_CSTM
			   set ID_C              = ID_C
			 where ID_C              = @ID;
		-- END Oracle Exception
	end -- while;
  end
GO
 
Grant Execute on dbo.spRELEASES_MassUpdate to public;
GO
 
 
