if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spEXCHANGE_USERS_Update' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spEXCHANGE_USERS_Update;
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
Create Procedure dbo.spEXCHANGE_USERS_Update
	( @ID                uniqueidentifier output
	, @MODIFIED_USER_ID  uniqueidentifier
	, @EXCHANGE_ALIAS    nvarchar(60)
	, @EXCHANGE_EMAIL    nvarchar(100)
	, @IMPERSONATED_TYPE nvarchar(25)
	, @ASSIGNED_USER_ID  uniqueidentifier
	)
as
  begin
	set nocount on

	-- 04/17/2018 Paul.  Exchange sync is not supported in Community Edition. 
  end
GO
 
Grant Execute on dbo.spEXCHANGE_USERS_Update to public;
GO
 
