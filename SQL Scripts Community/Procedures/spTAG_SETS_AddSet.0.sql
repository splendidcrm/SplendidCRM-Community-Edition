if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spTAG_SETS_AddSet' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spTAG_SETS_AddSet;
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
Create Procedure dbo.spTAG_SETS_AddSet
	( @MODIFIED_USER_ID     uniqueidentifier
	, @BEAN_ID              uniqueidentifier
	, @BEAN_MODULE          nvarchar(50)
	, @TAG_SET_NAME         nvarchar(4000)
	)
as
  begin
	set nocount on
	
	declare @TAG_SET_ID           uniqueidentifier;
	declare @NORMAL_TAG_SET_LIST  varchar(851);
	declare @NORMAL_TAG_SET_NAME  nvarchar(max);
	declare @TAG_ID               uniqueidentifier;
	declare @TAG_NAME             nvarchar(255);
	declare @CurrentPosR          int;
	declare @NextPosR             int;
-- #if SQL_Server /*
	declare @TEMP_TAGS table
		( ID           uniqueidentifier not null primary key
		, NAME         nvarchar(255) not null
		);
-- #endif SQL_Server */

	if @TAG_SET_NAME is not null and len(@TAG_SET_NAME) > 0 begin -- then
		set @CurrentPosR = 1;
		-- 05/10/2016 Paul.  Add any new TAGs to the relationship table. 
		while @CurrentPosR <= len(@TAG_SET_NAME) begin -- do
			set @NextPosR = charindex(',', @TAG_SET_NAME,  @CurrentPosR);
			if @NextPosR = 0 or @NextPosR is null begin -- then
				set @NextPosR = len(@TAG_SET_NAME) + 1;
			end -- if;
			set @TAG_NAME = rtrim(ltrim(substring(@TAG_SET_NAME, @CurrentPosR, @NextPosR - @CurrentPosR)));
			set @CurrentPosR = @NextPosR+1;
			
			-- 05/10/2016 Paul.  Prevent duplicates by inserting unique TAGs into the temp table. 
			if not exists(select * from @TEMP_TAGS where NAME = @TAG_NAME) begin -- then
				set @TAG_ID = null;
				-- BEGIN Oracle Exception
					select @TAG_ID = ID
					  from TAGS
					 where NAME       = @TAG_NAME
					   and DELETED    = 0;
				-- END Oracle Exception
				if @TAG_ID is not null begin -- then
					insert into @TEMP_TAGS  (  ID    ,  NAME     )
					                 values ( @TAG_ID, @TAG_NAME);
				end else begin
					set @TAG_ID = newid();
					insert into TAGS
						( ID                
						, CREATED_BY        
						, DATE_ENTERED      
						, MODIFIED_USER_ID  
						, DATE_MODIFIED     
						, DATE_MODIFIED_UTC 
						, NAME              
						, ASSIGNED_USER_ID  
						, SOURCE_ID         
						, SOURCE_TYPE       
						, SOURCE_META       
						, DESCRIPTION       
						)
					values 	( @TAG_ID            
						, @MODIFIED_USER_ID  
						,  getdate()         
						, @MODIFIED_USER_ID  
						,  getdate()         
						,  getutcdate()      
						, @TAG_NAME          
						, @MODIFIED_USER_ID  -- @ASSIGNED_USER_ID  
						, @BEAN_ID           -- @SOURCE_ID         
						, @BEAN_MODULE       -- @SOURCE_TYPE       
						, null               -- @SOURCE_META       
						, null               -- @DESCRIPTION       
						);
					insert into @TEMP_TAGS (  ID    ,  NAME    )
					                values ( @TAG_ID, @TAG_NAME);
				end -- if;
			end -- if;
		end -- while;
	end -- if;

	set @TAG_SET_ID = null;
	if exists(select * from @TEMP_TAGS) begin -- then
		set @NORMAL_TAG_SET_LIST =  '';
		set @NORMAL_TAG_SET_NAME = N'';
		
		insert into @TEMP_TAGS
			( ID
			, NAME
			)
		select TAG_ID
		     , TAG_NAME
		  from vwTAG_BEAN_REL
		 where BEAN_ID = @BEAN_ID
		   and TAG_ID not in (select ID from @TEMP_TAGS);
		
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

		-- 05/10/2016 Paul.  If a TAG set already exists with the same normalized list, then return it.
		-- The TAG set does not need to be identical, it just needs to have the same display list, so we use the id list as the key. 
		-- 05/10/2016 Paul.  We have to make sure to get the top item as there may be more than one entry. 
		-- As much as we would want to prevent this, it is possible for the offline client to create duplicate TAG sets. 
		-- BEGIN Oracle Exception
			select top 1 @TAG_SET_ID = ID
			  from TAG_SETS
			 where BEAN_ID       = @BEAN_ID
			   and DELETED       = 0
			  order by DATE_ENTERED;
		-- END Oracle Exception
		if @TAG_SET_ID is null begin -- then
			set @TAG_SET_ID = newid();
			insert into TAG_SETS
				( ID               
				, CREATED_BY       
				, DATE_ENTERED     
				, MODIFIED_USER_ID 
				, DATE_MODIFIED    
				, BEAN_ID           
				, BEAN_MODULE       
				, TAG_SET_LIST    
				, TAG_SET_NAME    
				)
			values
				( @TAG_SET_ID                  
				, @MODIFIED_USER_ID    
				,  getdate()           
				, @MODIFIED_USER_ID    
				,  getdate()           
				, @BEAN_ID           
				, @BEAN_MODULE       
				, @NORMAL_TAG_SET_LIST
				, @NORMAL_TAG_SET_NAME
				);
		end else begin
			update TAG_SETS
			   set TAG_SET_LIST      = @NORMAL_TAG_SET_LIST
			     , TAG_SET_NAME      = @NORMAL_TAG_SET_NAME
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where BEAN_ID           = @BEAN_ID
			   and DELETED           = 0;
		end -- if;
		
		-- 05/10/2016 Paul.  We would normally use a cursor to be common across platforms. 
		-- Instead, lets use insert into so that we are fast. 
		insert into TAG_BEAN_REL
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, TAG_ID           
			, BEAN_ID          
			, BEAN_MODULE      
			)
		select  newid()          
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     , @MODIFIED_USER_ID 
		     ,  getdate()        
		     ,  ID               
		     , @BEAN_ID          
		     , @BEAN_MODULE      
		  from @TEMP_TAGS
		 where ID not in (select TAG_ID from TAG_BEAN_REL where DELETED = 0 and BEAN_ID = @BEAN_ID);
	end -- if;
  end
GO

Grant Execute on dbo.spTAG_SETS_AddSet to public;
GO

