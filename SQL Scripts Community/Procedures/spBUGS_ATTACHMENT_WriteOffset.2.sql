if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spBUGS_ATTACHMENT_WriteOffset' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spBUGS_ATTACHMENT_WriteOffset;
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
Create Procedure dbo.spBUGS_ATTACHMENT_WriteOffset
	( @ID                   uniqueidentifier
	, @FILE_POINTER         binary(16)
	, @MODIFIED_USER_ID     uniqueidentifier
	, @FILE_OFFSET          int
	, @BYTES                varbinary(max)
	)
as
  begin
	set nocount on
	
	exec dbo.spNOTES_ATTACHMENT_WriteOffset @ID, @FILE_POINTER, @MODIFIED_USER_ID, @FILE_OFFSET, @BYTES;
  end
GO
 
Grant Execute on dbo.spBUGS_ATTACHMENT_WriteOffset to public;
GO



