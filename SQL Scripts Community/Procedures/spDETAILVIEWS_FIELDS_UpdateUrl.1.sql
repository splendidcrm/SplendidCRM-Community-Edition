if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDETAILVIEWS_FIELDS_UpdateUrl' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDETAILVIEWS_FIELDS_UpdateUrl;
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
-- 08/18/2010 Paul.  Fix problem with updating URL fields. 
-- 10/30/2013 Paul.  Increase size of URL_TARGET. 
-- 02/25/2015 Paul.  Increase size of DATA_FIELD and DATA_FORMAT for OfficeAddin. 
Create Procedure dbo.spDETAILVIEWS_FIELDS_UpdateUrl
	( @MODIFIED_USER_ID            uniqueidentifier
	, @DETAIL_NAME                 nvarchar(50)
	, @DATA_FIELD                  nvarchar(1000)
	, @URL_FIELD                   nvarchar(max)
	, @URL_FORMAT                  nvarchar(max)
	, @URL_TARGET                  nvarchar( 60)
	)
as
  begin
	update DETAILVIEWS_FIELDS
	   set MODIFIED_USER_ID  = @MODIFIED_USER_ID
	     , DATE_MODIFIED     =  getdate()   
	     , DATE_MODIFIED_UTC =  getutcdate()
	     , URL_FIELD         = @URL_FIELD   
	     , URL_FORMAT        = @URL_FORMAT  
	     , URL_TARGET        = @URL_TARGET  
	 where DETAIL_NAME       = @DETAIL_NAME 
	   and DATA_FIELD        = @DATA_FIELD  
	   and DELETED           = 0            
	   and DEFAULT_VIEW      = 0            ;
  end
GO
 
Grant Execute on dbo.spDETAILVIEWS_FIELDS_UpdateUrl to public;
GO
 
