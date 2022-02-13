if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDETAILVIEWS_FIELDS_InsTags' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDETAILVIEWS_FIELDS_InsTags;
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
Create Procedure dbo.spDETAILVIEWS_FIELDS_InsTags
	( @DETAIL_NAME       nvarchar( 50)
	, @FIELD_INDEX       int
	, @COLSPAN           int
	)
as
  begin
	declare @TEMP_FIELD_INDEX int;	
	declare @ID               uniqueidentifier;
	declare @DATA_LABEL       nvarchar(150);
	declare @DATA_FIELD       nvarchar(1000);
	declare @DATA_FORMAT      nvarchar(max);

	set @DATA_LABEL       = N'.LBL_TAG_SET_NAME';
	set @DATA_FIELD       = N'TAG_SET_NAME';
	set @DATA_FORMAT      = N'{0}';
	set @TEMP_FIELD_INDEX = @FIELD_INDEX;
	if @FIELD_INDEX is null or @FIELD_INDEX = -1 begin -- then
		-- BEGIN Oracle Exception
			select @TEMP_FIELD_INDEX = isnull(max(FIELD_INDEX), 0) + 1
			  from DETAILVIEWS_FIELDS
			 where DETAIL_NAME  = @DETAIL_NAME
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
		-- BEGIN Oracle Exception
			select @ID = ID
			  from DETAILVIEWS_FIELDS
			 where DETAIL_NAME  = @DETAIL_NAME
			   and DATA_FIELD   = @DATA_FIELD
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
	end else begin
		-- BEGIN Oracle Exception
			select @ID = ID
			  from DETAILVIEWS_FIELDS
			 where DETAIL_NAME  = @DETAIL_NAME
			   and FIELD_INDEX  = @FIELD_INDEX
			   and DELETED      = 0            
			   and DEFAULT_VIEW = 0            ;
		-- END Oracle Exception
	end -- if;
	if dbo.fnIsEmptyGuid(@ID) = 1 begin -- then
		set @ID = newid();
		insert into DETAILVIEWS_FIELDS
			( ID               
			, CREATED_BY       
			, DATE_ENTERED     
			, MODIFIED_USER_ID 
			, DATE_MODIFIED    
			, DETAIL_NAME      
			, FIELD_INDEX      
			, FIELD_TYPE       
			, DATA_LABEL       
			, DATA_FIELD       
			, DATA_FORMAT      
			, COLSPAN          
			)
		values 
			( @ID               
			, null              
			,  getdate()        
			, null              
			,  getdate()        
			, @DETAIL_NAME      
			, @TEMP_FIELD_INDEX 
			, N'Tags'           
			, @DATA_LABEL       
			, @DATA_FIELD       
			, @DATA_FORMAT      
			, @COLSPAN          
			);
	end -- if;
  end
GO

Grant Execute on dbo.spDETAILVIEWS_FIELDS_InsTags to public;
GO

