if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlGetTransactionToken' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlGetTransactionToken;
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
-- 04/10/2008 Paul.  sp_getbindtoken may not be accessible in a hosted environment. 
-- Wrap sp_getbindtoken in a procedure that can be bypassed.
-- The EXECUTE permission was denied on the object 'sp_getbindtoken', database 'mssqlsystemresource', 
-- 04/23/2008 Paul.  The token must be a varchar. 
-- Implicit conversion from data type nvarchar to varchar is not allowed. Use the CONVERT function to run this query.
-- 09/27/2009 Paul.  Allow the Azure commands to be enabled by the SplendidCRM Configuration Wizard.
-- 05/11/2013 Paul.  Dynamically create the procedure so that the same code would work on SQL Server and SQL Azure. 
-- 01/30/2016 Paul.  sp_getbindtoken was added back to SQL Azure, though I'm not sure if we should re-enable. 
declare @Command varchar(max);
if charindex('Microsoft SQL Azure', @@VERSION) > 0 begin -- then
	print 'Microsoft SQL Azure';
	set @Command = 'Create Procedure dbo.spSqlGetTransactionToken(@TRANSACTION_TOKEN varchar(255) out)
as
  begin
	set nocount on

	if @@TRANCOUNT > 0 begin -- then
		-- 09/15/2009 Paul.  If sp_getbindtoken is not available, use date and time until we can find a better solution. 
		-- set @TRANSACTION_TOKEN = convert(varchar(19), getutcdate(), 120);

		-- 10/07/2009 Paul.  MODIFIED_USER_ID will never be NULL, though it may be 00000000-0000-0000-0000-000000000000. 
		select @TRANSACTION_TOKEN = cast(ID as char(36)) + '','' + cast(MODIFIED_USER_ID as char(36))
		  from SYSTEM_TRANSACTIONS
		 where SESSION_SPID = @@SPID;
		-- 10/07/2009 Paul.  The SPID should always exists, but just in case, lets create it if it does not exist. 
		-- One possible reason for it not existing is if the database is modified internally. 
		if @TRANSACTION_TOKEN is null begin -- then
			declare @ID uniqueidentifier;
			exec dbo.spSYSTEM_TRANSACTIONS_Create @ID out, null;

			select @TRANSACTION_TOKEN = cast(ID as char(36)) + '','' + cast(MODIFIED_USER_ID as char(36))
			  from SYSTEM_TRANSACTIONS
			 where SESSION_SPID = @@SPID;
		end -- if;
	end -- if;
  end
';
	exec(@Command);
end else begin
	print 'Microsoft SQL Server';
	set @Command = 'Create Procedure dbo.spSqlGetTransactionToken(@TRANSACTION_TOKEN varchar(255) out)
as
  begin
	set nocount on

	if @@TRANCOUNT > 0 begin -- then
		exec sp_getbindtoken @TRANSACTION_TOKEN out;
	end -- if;
  end
';
	exec(@Command);
end -- if;
GO


Grant Execute on dbo.spSqlGetTransactionToken to public;
GO

