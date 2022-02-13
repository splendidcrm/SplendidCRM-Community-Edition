if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDYNAMIC_BUTTONS_InsSaveNew' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDYNAMIC_BUTTONS_InsSaveNew;
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
Create Procedure dbo.spDYNAMIC_BUTTONS_InsSaveNew
	( @VIEW_NAME           nvarchar(50)
	, @CONTROL_INDEX       int
	, @MODULE_NAME         nvarchar(25)
	)
as
  begin
	set nocount on
	
	exec dbo.spDYNAMIC_BUTTONS_InsButton @VIEW_NAME, @CONTROL_INDEX, @MODULE_NAME, 'edit'  , null, null, 'SaveNew'  , null, '.LBL_SAVE_NEW_BUTTON_LABEL' , '.LBL_SAVE_NEW_BUTTON_TITLE' , '.LBL_SAVE_NEW_BUTTON_KEY' , null, null;
  end
GO

Grant Execute on dbo.spDYNAMIC_BUTTONS_InsSaveNew to public;
GO

