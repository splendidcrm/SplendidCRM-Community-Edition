if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDETAILVIEWS_RELATIONSHIPS_InsertOnly' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly;
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
-- 09/08/2007 Paul.  We need a title when we migrate to WebParts. 
-- 12/16/2007 Paul.  Make the title optional to reduce problems during upgrade. 
-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
-- 03/05/2011 Paul.  If @RELATIONSHIP_ORDER is null, then add control to the bottom. 
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- 03/01/2013 Paul.  Sort Field and Sort Direction may be invalid. Correct for this. 
-- 03/20/2016 Paul.  Increase PRIMARY_FIELD size to 255 to support OfficeAddin. 
Create Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly
	( @DETAIL_NAME         nvarchar(50)
	, @MODULE_NAME         nvarchar(50)
	, @CONTROL_NAME        nvarchar(100)
	, @RELATIONSHIP_ORDER  int
	, @TITLE               nvarchar(100) = null
	, @TABLE_NAME          nvarchar(50) = null
	, @PRIMARY_FIELD       nvarchar(255) = null
	, @SORT_FIELD          nvarchar(50) = null
	, @SORT_DIRECTION      nvarchar(10) = null
	)
as
  begin

	declare @TEMP_RELATIONSHIP_ORDER  int;
	declare @TEMP_SORT_FIELD          nvarchar(50);
	declare @TEMP_SORT_DIRECTION      nvarchar(10);
	set @TEMP_RELATIONSHIP_ORDER = @RELATIONSHIP_ORDER;
	set @TEMP_SORT_FIELD         = @SORT_FIELD;
	set @TEMP_SORT_DIRECTION     = @SORT_DIRECTION;
	if @RELATIONSHIP_ORDER is null or @RELATIONSHIP_ORDER = -1 begin -- then
		-- 09/09/2012 Paul.  Only include enabled relationships. 
		-- BEGIN Oracle Exception
			select @TEMP_RELATIONSHIP_ORDER = isnull(max(RELATIONSHIP_ORDER), 0) + 1
			  from DETAILVIEWS_RELATIONSHIPS
			 where DETAIL_NAME          = @DETAIL_NAME
			   and RELATIONSHIP_ENABLED = 1
			   and DELETED              = 0;
		-- END Oracle Exception
	end -- if;
	-- 03/01/2013 Paul.  Sort Field and Sort Direction may be invalid. Correct for this. 
	if @TABLE_NAME is not null and @TEMP_SORT_FIELD is not null begin -- then
		if not exists(select * from vwSqlColumns where ObjectName = @TABLE_NAME and ColumnName = @SORT_FIELD) begin -- then
			set @TEMP_SORT_FIELD     = null;
			set @TEMP_SORT_DIRECTION = null;
		end -- if;
	end -- if;
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = @DETAIL_NAME and CONTROL_NAME = @CONTROL_NAME and DELETED = 0) begin -- then
		insert into DETAILVIEWS_RELATIONSHIPS
			( ID                 
			, CREATED_BY         
			, DATE_ENTERED       
			, MODIFIED_USER_ID   
			, DATE_MODIFIED      
			, DETAIL_NAME        
			, MODULE_NAME        
			, CONTROL_NAME       
			, RELATIONSHIP_ORDER 
			, TITLE              
			, TABLE_NAME         
			, PRIMARY_FIELD      
			, SORT_FIELD         
			, SORT_DIRECTION     
			)
		values 
			( newid()                 
			, null                    
			,  getdate()              
			, null                    
			,  getdate()              
			, @DETAIL_NAME            
			, @MODULE_NAME            
			, @CONTROL_NAME           
			, @TEMP_RELATIONSHIP_ORDER
			, @TITLE                  
			, @TABLE_NAME             
			, @PRIMARY_FIELD          
			, @TEMP_SORT_FIELD        
			, @TEMP_SORT_DIRECTION    
			);
	end else begin
		-- 03/01/2013 Paul.  If this is an old entry, make sure that it has an updated sort field. 
		if @TABLE_NAME is not null and @TEMP_SORT_FIELD is not null begin -- then
			if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = @DETAIL_NAME and CONTROL_NAME = @CONTROL_NAME and TABLE_NAME is null and SORT_FIELD is null and DELETED = 0) begin -- then
				update DETAILVIEWS_RELATIONSHIPS
				   set TABLE_NAME        = @TABLE_NAME
				     , SORT_FIELD        = @TEMP_SORT_FIELD
				     , SORT_DIRECTION    = @TEMP_SORT_DIRECTION
				     , DATE_MODIFIED     = getdate()
				     , DATE_MODIFIED_UTC = getutcdate()
				     , MODIFIED_USER_ID  = null
				 where DETAIL_NAME       = @DETAIL_NAME
				   and CONTROL_NAME      = @CONTROL_NAME
				   and TABLE_NAME        is null 
				   and SORT_FIELD        is null
				   and DELETED           = 0;
			end -- if;
		end -- if;
	end -- if;
  end
GO
 
Grant Execute on dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly to public;
GO
 
