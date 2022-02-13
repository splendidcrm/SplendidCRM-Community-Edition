if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSER_PREFERENCES_ReadOffset' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSER_PREFERENCES_ReadOffset;
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
-- 09/15/2009 Paul.  Convert data type to varbinary(max) to support Azure. 
-- 09/15/2009 Paul.  updatetext, readtext and textptr() have been deprecated in SQL Server and are not supported in Azure. 
-- http://msdn.microsoft.com/en-us/library/ms143729.aspx
Create Procedure dbo.spUSER_PREFERENCES_ReadOffset
	( @ID                   uniqueidentifier
	, @FILE_OFFSET          int
	, @READ_SIZE            int
	, @BYTES                varbinary(max) output
	)
as
  begin
	set nocount on
	
	-- 08/12/2005 Paul.  Oracle returns its data in the @BYTES field. 
	-- 10/22/2005 Paul.  MySQL can also return data in @BYTES, but using a recordset has fewer limitations. 
	-- 01/25/2007 Paul.  Protect against a read error by ensuring that the file size is zero if no content. 
-- #if SQL_Server /*
	raiserror(N'updatetext, readtext and textptr() have been deprecated. ', 16, 1);
	-- declare @FILE_SIZE    bigint;
	-- declare @FILE_POINTER binary(16);
	-- select @FILE_SIZE    = isnull(datalength(CONTENT), 0)
	--      , @FILE_POINTER = textptr(CONTENT)
	--   from USER_PREFERENCES
	--  where ID            = @ID;
	-- if @FILE_OFFSET + @READ_SIZE > @FILE_SIZE begin -- then
	-- 	set @READ_SIZE = @FILE_SIZE - @FILE_OFFSET;
	-- end -- if;
	-- if @READ_SIZE > 0 begin -- then
	-- 	readtext USER_PREFERENCES.CONTENT @FILE_POINTER @FILE_OFFSET @READ_SIZE;
	-- end -- if;
-- #endif SQL_Server */



  end
GO
 
Grant Execute on dbo.spUSER_PREFERENCES_ReadOffset to public;
GO


