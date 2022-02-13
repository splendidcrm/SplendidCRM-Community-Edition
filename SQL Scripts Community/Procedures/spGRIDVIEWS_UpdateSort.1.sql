if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spGRIDVIEWS_UpdateSort' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spGRIDVIEWS_UpdateSort;
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
-- 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
Create Procedure dbo.spGRIDVIEWS_UpdateSort
	( @MODIFIED_USER_ID    uniqueidentifier
	, @NAME                nvarchar(50)
	, @SORT_FIELD          nvarchar(50)
	, @SORT_DIRECTION      nvarchar(10)
	)
as
  begin
	-- BEGIN Oracle Exception
		update GRIDVIEWS
		   set MODIFIED_USER_ID    = @MODIFIED_USER_ID   
		     , DATE_MODIFIED       =  getdate()          
		     , DATE_MODIFIED_UTC   =  getutcdate()       
		     , SORT_FIELD          = @SORT_FIELD         
		     , SORT_DIRECTION      = @SORT_DIRECTION     
		 where NAME                = @NAME               
		   and DELETED             = 0                   ;
	-- END Oracle Exception
  end
GO
 
Grant Execute on dbo.spGRIDVIEWS_UpdateSort to public;
GO
 
