if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSYSTEM_TRANSACTIONS_Create' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSYSTEM_TRANSACTIONS_Create;
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
-- 10/07/2009 Paul.  The goal will be to use the SQL Server 2008 MERGE statement. 
-- http://weblogs.sqlteam.com/mladenp/archive/2007/08/03/60277.aspx
-- 10/07/2009 Paul.  On SQL Server 2005 and 2008, this function should do nothing. 
-- 05/11/2013 Paul.  Dynamically create the procedure so that the same code would work on SQL Server and SQL Azure. 
declare @Command varchar(max);
if charindex('Microsoft SQL Azure', @@VERSION) > 0 begin -- then
	set @Command = 'Create Procedure dbo.spSYSTEM_TRANSACTIONS_Create
	( @ID               uniqueidentifier output
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

	declare @TEMP_SESSION_SPID     int;
	declare @TEMP_MODIFIED_USER_ID uniqueidentifier;

	set @TEMP_SESSION_SPID     = @@SPID;
	set @TEMP_MODIFIED_USER_ID = @MODIFIED_USER_ID;
	if @ID is null begin -- then
		set @ID = newid();
	end -- if;
	if @TEMP_MODIFIED_USER_ID is null begin -- then
		set @TEMP_MODIFIED_USER_ID = ''00000000-0000-0000-0000-000000000000'';
	end -- if;

	merge dbo.SYSTEM_TRANSACTIONS as TARGET
	using (select @ID
	            , @TEMP_MODIFIED_USER_ID
	            , getdate()
	            , @TEMP_SESSION_SPID
	            )
	   as SOURCE( ID
	            , MODIFIED_USER_ID
	            , DATE_MODIFIED
	            , SESSION_SPID
	            )
	   on (TARGET.SESSION_SPID = SOURCE.SESSION_SPID)
	 when matched then
		update set TARGET.ID               = SOURCE.ID              
		         , TARGET.MODIFIED_USER_ID = SOURCE.MODIFIED_USER_ID
		         , TARGET.DATE_MODIFIED    = SOURCE.DATE_MODIFIED   
	 when not matched then
		insert
			( ID              
			, MODIFIED_USER_ID
			, DATE_MODIFIED   
			, SESSION_SPID    
			)
		values
			( SOURCE.ID              
			, SOURCE.MODIFIED_USER_ID
			, SOURCE.DATE_MODIFIED   
			, SOURCE.SESSION_SPID    
			);
  end
';
	exec(@Command);
end else begin
	set @Command = 'Create Procedure dbo.spSYSTEM_TRANSACTIONS_Create
	( @ID               uniqueidentifier output
	, @MODIFIED_USER_ID uniqueidentifier
	)
as
  begin
	set nocount on

  end
';
	exec(@Command);
end -- if;
GO

Grant Execute on dbo.spSYSTEM_TRANSACTIONS_Create to public;
GO

