if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spDETAILVIEWS_RELATIONSHIPS_UpdateInsight' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_UpdateInsight;
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
Create Procedure dbo.spDETAILVIEWS_RELATIONSHIPS_UpdateInsight
	( @MODIFIED_USER_ID     uniqueidentifier
	, @DETAIL_NAME          nvarchar(50)
	, @CONTROL_NAME         nvarchar(100)
	, @INSIGHT_LABEL        nvarchar(100)
	, @INSIGHT_VIEW         nvarchar(50)
	, @INSIGHT_OPERATOR     nvarchar(2000)
	)
as
  begin
	set nocount on

	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = @DETAIL_NAME and CONTROL_NAME = @CONTROL_NAME and DELETED = 0) begin -- then	
		-- BEGIN Oracle Exception
			update DETAILVIEWS_RELATIONSHIPS
			   set MODIFIED_USER_ID     = @MODIFIED_USER_ID 
			     , DATE_MODIFIED        =  getdate()        
			     , DATE_MODIFIED_UTC    =  getutcdate()     
			     , INSIGHT_LABEL        = @INSIGHT_LABEL
			     , INSIGHT_VIEW         = @INSIGHT_VIEW
			     , INSIGHT_OPERATOR     = @INSIGHT_OPERATOR
			 where DETAIL_NAME          = @DETAIL_NAME
			   and CONTROL_NAME         = @CONTROL_NAME
			   and DELETED              = 0;
		-- END Oracle Exception
	end -- if;
  end
GO

Grant Execute on dbo.spDETAILVIEWS_RELATIONSHIPS_UpdateInsight to public;
GO

