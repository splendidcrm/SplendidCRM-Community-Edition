if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsEdit' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsEdit;
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
-- 09/12/2010 Paul.  Add default parameter ONCLICK_SCRIPT to ease migration to EffiProz. 
Create Procedure dbo.spDYNAMIC_BUTTONS_InsEdit
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	)
as
  begin
	set nocount on
	
	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink
		  @VIEW_NAME
		, @CONTROL_INDEX
		, @MODULE_NAME
		, N'edit'
		, null
		, null
		, N'Edit'
		, N'edit.aspx?ID={0}'
		, N'ID'
		, N'.LBL_EDIT_BUTTON_LABEL'
		, N'.LBL_EDIT_BUTTON_TITLE'
		, N'.LBL_EDIT_BUTTON_KEY'
		, null
		, null
		, null          -- ONCLICK_SCRIPT
		;

  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsEdit to public;
GO

