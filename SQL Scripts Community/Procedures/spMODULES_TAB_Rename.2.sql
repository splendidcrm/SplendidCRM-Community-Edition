if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spMODULES_TAB_Rename' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spMODULES_TAB_Rename;
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
Create Procedure dbo.spMODULES_TAB_Rename
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @NAME              nvarchar(50)
	, @LANG              nvarchar(10)
	, @DISPLAY_NAME      nvarchar(2000)
	)
as
  begin
	set nocount on
	
	declare @LIST_NAME   nvarchar(50);
	set @LIST_NAME = N'moduleList';
	exec dbo.spTERMINOLOGY_LIST_Insert @ID out, @MODIFIED_USER_ID, @NAME, @LANG, null, @LIST_NAME, 1, @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.spMODULES_TAB_Rename to public;
GO

