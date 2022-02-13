if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_PASSWORD_HISTORY_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_PASSWORD_HISTORY_InsertOnly;
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
Create Procedure dbo.spUSERS_PASSWORD_HISTORY_InsertOnly
	( @MODIFIED_USER_ID  uniqueidentifier
	, @USER_ID           uniqueidentifier
	, @USER_HASH         nvarchar(32)
	)
as
  begin
	set nocount on
	
	declare @HistoryMax   int;
	declare @HistoryCount int;
	declare @OLDEST_ID    uniqueidentifier;

	insert into USERS_PASSWORD_HISTORY
		( ID               
		, CREATED_BY       
		, DATE_ENTERED     
		, MODIFIED_USER_ID 
		, DATE_MODIFIED    
		, USER_ID          
		, USER_HASH        
		)
	values
		(  newid()          
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @MODIFIED_USER_ID 
		,  getdate()        
		, @USER_ID          
		, @USER_HASH        
		);

	set @HistoryMax = dbo.fnCONFIG_Int(N'Password.HistoryMaximum');
	if @HistoryMax is null or @HistoryMax < 0 begin -- then
		set @HistoryMax = 0;
	end -- if;

-- #if SQL_Server /*
	select @HistoryCount = count(*)
	  from USERS_PASSWORD_HISTORY
	 where USER_ID     = @USER_ID;

	while @HistoryCount > @HistoryMax begin -- do
		select top 1 @OLDEST_ID = ID
		  from USERS_PASSWORD_HISTORY
		 where USER_ID     = @USER_ID
		 order by DATE_ENTERED;
		
		delete from USERS_PASSWORD_HISTORY
		  where ID = @OLDEST_ID;
		
		select @HistoryCount = count(*)
		  from USERS_PASSWORD_HISTORY
		 where USER_ID     = @USER_ID;
	end -- while;
-- #endif SQL_Server */




  end
GO
 
Grant Execute on dbo.spUSERS_PASSWORD_HISTORY_InsertOnly to public;
GO
 
 
