if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTAG_SETS_UpdateNames' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTAG_SETS_UpdateNames;
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
Create Procedure dbo.spTAG_SETS_UpdateNames
	( @MODIFIED_USER_ID     uniqueidentifier
	, @TAG_ID               uniqueidentifier
	)
as
  begin
	set nocount on

	declare @BEAN_ID             uniqueidentifier;
	declare @NORMAL_TAG_SET_LIST varchar(851);
	declare @NORMAL_TAG_SET_NAME nvarchar(max);
-- #if SQL_Server /*
	declare @TEMP_TAGS table
		( ID           uniqueidentifier not null primary key
		, NAME         nvarchar(255) not null
		);
-- #endif SQL_Server */

	declare TAG_set_cursor cursor for
	select BEAN_ID
	  from TAG_BEAN_REL
	 where DELETED = 0
	   and TAG_ID = @TAG_ID;

/* -- #if IBM_DB2
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
-- #endif IBM_DB2 */
/* -- #if MySQL
	declare continue handler for not found
		set in_FETCH_STATUS = 1;
	set in_FETCH_STATUS = 0;
-- #endif MySQL */

	open TAG_set_cursor;
	fetch next from TAG_set_cursor into @BEAN_ID;
	while @@FETCH_STATUS = 0 and @@ERROR = 0 begin -- do
		insert into @TEMP_TAGS ( ID, NAME)
		select TAG_BEAN_REL.TAG_ID
		     , TAGS.NAME
		  from      TAG_BEAN_REL
		 inner join TAGS
		         on TAGS.ID      = TAG_BEAN_REL.TAG_ID
		        and TAGS.DELETED = 0
		 where TAG_BEAN_REL.BEAN_ID = @BEAN_ID
		   and TAG_BEAN_REL.DELETED = 0;
		
		set @NORMAL_TAG_SET_LIST =  '';
		set @NORMAL_TAG_SET_NAME = N'';
		-- 05/10/2016 Paul.  Order the ID list by the IDs of the TAGs.
		-- 05/10/2016 Paul.  There is no space separator after the comma as we want to be efficient with space. 
		select @NORMAL_TAG_SET_LIST = substring(@NORMAL_TAG_SET_LIST + (case when len(@NORMAL_TAG_SET_LIST) > 0 then  ',' else  '' end) + cast(ID as char(36)), 1, 851)
		  from @TEMP_TAGS
		 order by ID asc;
		
		-- 05/10/2016 Paul.  Order the set name by the names of the TAGs. 
		-- 05/10/2016 Paul.  Use a space after the comma so that the TAG names are readable in the GridView or DetailView. 
		-- 05/11/2016 Paul.  Don't need substring because set name is nvarchar(max). TEAM_SETS does have a size of 200. 
		select @NORMAL_TAG_SET_NAME = @NORMAL_TAG_SET_NAME + (case when len(@NORMAL_TAG_SET_NAME) > 0 then N', ' else N'' end) + NAME
		  from @TEMP_TAGS
		 order by NAME asc;
		
		update TAG_SETS
		   set TAG_SET_LIST      = @NORMAL_TAG_SET_LIST
		     , TAG_SET_NAME      = @NORMAL_TAG_SET_NAME
		     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where ID                = @BEAN_ID
		   and DELETED           = 0;
		
		delete from @TEMP_TAGS;
		
		fetch next from TAG_set_cursor into @BEAN_ID;
	end -- while;
	close TAG_set_cursor;

	deallocate TAG_set_cursor;
  end
GO

Grant Execute on dbo.spTAG_SETS_UpdateNames to public;
GO

