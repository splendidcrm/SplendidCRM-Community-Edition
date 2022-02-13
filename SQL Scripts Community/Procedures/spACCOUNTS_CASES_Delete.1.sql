if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spACCOUNTS_CASES_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spACCOUNTS_CASES_Delete;
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
-- 12/19/2017 Paul.  ACCOUNTS_CASES use was ended back in 2005. The table needs to be removed as it causes problems with archiving. 
Create Procedure dbo.spACCOUNTS_CASES_Delete
	( @MODIFIED_USER_ID uniqueidentifier
	, @ACCOUNT_ID       uniqueidentifier
	, @CASE_ID          uniqueidentifier
	)
as
  begin
	set nocount on
	
	-- 12/19/2017 Paul.  Deleting the relationship means that the field is set to null. 
	if exists(select * from CASES where ACCOUNT_ID = @ACCOUNT_ID and ID = @CASE_ID and DELETED = 0) begin -- then
		update CASES
		   set ACCOUNT_ID       = null
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = @MODIFIED_USER_ID
		 where ACCOUNT_ID       = @ACCOUNT_ID
		   and ID               = @CASE_ID
		   and DELETED          = 0;
		update CASES_CSTM
		   set ID_C             = ID_C
		 where ID_C             = @CASE_ID;
	end -- if;
  end
GO

Grant Execute on dbo.spACCOUNTS_CASES_Delete to public;
GO

