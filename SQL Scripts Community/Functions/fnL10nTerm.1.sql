if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnL10nTerm' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnL10nTerm;
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
-- 09/03/2009 Paul.  Convert terms to a base term. 
-- 11/22/2021 Paul.  Include Assigned Set. 
Create Function dbo.fnL10nTerm(@LANG nvarchar(10), @MODULE_NAME nvarchar(20), @NAME nvarchar(50))
returns nvarchar(2000)
as
  begin
	declare @DISPLAY_NAME nvarchar(2000);
	if    @NAME = 'LBL_ID'              
	   or @NAME = 'LBL_DELETED'         
	   or @NAME = 'LBL_CREATED_BY'      
	   or @NAME = 'LBL_CREATED_BY_ID'   
	   or @NAME = 'LBL_DATE_ENTERED'    
	   or @NAME = 'LBL_MODIFIED_USER_ID'
	   or @NAME = 'LBL_DATE_MODIFIED'   
	   or @NAME = 'LBL_MODIFIED_BY'     
	   or @NAME = 'LBL_ASSIGNED_USER_ID'
	   or @NAME = 'LBL_ASSIGNED_TO'     
	   or @NAME = 'LBL_ASSIGNED_SET_ID'  
	   or @NAME = 'LBL_ASSIGNED_SET_NAME'
	   or @NAME = 'LBL_TEAM_ID'         
	   or @NAME = 'LBL_TEAM_NAME'       
	   or @NAME = 'LBL_TEAM_SET_ID'     
	   or @NAME = 'LBL_TEAM_SET_NAME'   
	   or @NAME = 'LBL_ID_C'            
	   or @NAME = 'LBL_LIST_ID'              
	   or @NAME = 'LBL_LIST_DELETED'         
	   or @NAME = 'LBL_LIST_CREATED_BY'      
	   or @NAME = 'LBL_LIST_CREATED_BY_ID'   
	   or @NAME = 'LBL_LIST_DATE_ENTERED'    
	   or @NAME = 'LBL_LIST_MODIFIED_USER_ID'
	   or @NAME = 'LBL_LIST_DATE_MODIFIED'   
	   or @NAME = 'LBL_LIST_MODIFIED_BY'     
	   or @NAME = 'LBL_LIST_ASSIGNED_USER_ID'
	   or @NAME = 'LBL_LIST_ASSIGNED_TO'     
	   or @NAME = 'LBL_LIST_ASSIGNED_SET_ID' 
	   or @NAME = 'LBL_LIST_ASSIGNED_SET_NAME'
	   or @NAME = 'LBL_LIST_TEAM_ID'         
	   or @NAME = 'LBL_LIST_TEAM_NAME'       
	   or @NAME = 'LBL_LIST_TEAM_SET_ID'     
	   or @NAME = 'LBL_LIST_TEAM_SET_NAME'   
	   or @NAME = 'LBL_LIST_ID_C'            
	begin -- then
		set @MODULE_NAME = null;
	end -- if;

	if @MODULE_NAME is null  begin -- then
		select @DISPLAY_NAME = DISPLAY_NAME
		  from dbo.TERMINOLOGY
		 where LANG        = @LANG
		   and NAME        = @NAME
		   and MODULE_NAME is null;
	end else begin
		select @DISPLAY_NAME = DISPLAY_NAME
		  from dbo.TERMINOLOGY
		 where LANG        = @LANG
		   and NAME        = @NAME
		   and MODULE_NAME = @MODULE_NAME;
	end -- if;
	return @DISPLAY_NAME;
  end
GO

Grant Execute on dbo.fnL10nTerm to public
GO

