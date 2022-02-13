if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spAUDIT_EVENTS_Rebuild' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spAUDIT_EVENTS_Rebuild;
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
Create Procedure dbo.spAUDIT_EVENTS_Rebuild
as
  begin
	set nocount on

	declare @COMMAND    nvarchar(1000);
	declare @TABLE_NAME nvarchar(50);
	declare module_cursor cursor for
	select TABLE_NAME
	  from vwMODULES
	 where TABLE_NAME is not null
	   and MODULE_ENABLED = 1
	 order by MODULE_NAME;
	
	open module_cursor;
	fetch next from module_cursor into @TABLE_NAME;
	while @@FETCH_STATUS = 0 begin -- do
		if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @TABLE_NAME + '_AUDIT') begin -- then
			print @TABLE_NAME;
			select @COMMAND = 'insert into dbo.AUDIT_EVENTS
				( ID               
				, DELETED          
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, AUDIT_ID         
				, AUDIT_TABLE      
				, AUDIT_TOKEN      
				, AUDIT_ACTION     
				, AUDIT_PARENT_ID  
				)
			select	  AUDIT_ID               
				, 0                
				, CREATED_BY       
				, AUDIT_DATE       
				, MODIFIED_USER_ID 
				, AUDIT_DATE       
				, AUDIT_ID         
				, ''' + @TABLE_NAME + '_AUDIT''
				, AUDIT_TOKEN      
				, AUDIT_ACTION     
				, ID
			  from dbo.' + @TABLE_NAME + '_AUDIT
			 where AUDIT_ID not in (select ID from AUDIT_EVENTS)';
			exec(@COMMAND);
		end -- if;
		fetch next from module_cursor into @TABLE_NAME;
	end -- while;
	close module_cursor;
	
	deallocate module_cursor;
  end
GO


-- exec spAUDIT_EVENTS_Rebuild ;

Grant Execute on dbo.spAUDIT_EVENTS_Rebuild to public;
GO

