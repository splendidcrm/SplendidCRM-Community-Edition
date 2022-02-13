if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEMAIL_IMAGE_WriteOffset' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEMAIL_IMAGE_WriteOffset;
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
Create Procedure dbo.spEMAIL_IMAGE_WriteOffset
	( @ID                   uniqueidentifier
	, @FILE_POINTER         binary(16)
	, @MODIFIED_USER_ID     uniqueidentifier
	, @FILE_OFFSET          int
	, @BYTES                varbinary(max)
	)
as
  begin
	set nocount on
	
	-- 10/22/2005 Paul.  @ID is used in Oracle and MySQL. 
-- #if SQL_Server /*
	raiserror(N'updatetext, readtext and textptr() have been deprecated. ', 16, 1);
	-- updatetext EMAIL_IMAGES.CONTENT
	--            @FILE_POINTER
	--            @FILE_OFFSET
	--            null -- 0 deletes no data, null deletes all data from insertion point. 
	--            @BYTES;
-- #endif SQL_Server */



  end
GO
 
Grant Execute on dbo.spEMAIL_IMAGE_WriteOffset to public;
GO



