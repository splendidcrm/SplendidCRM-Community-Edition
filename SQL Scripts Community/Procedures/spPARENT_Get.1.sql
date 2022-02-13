if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spPARENT_Get' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spPARENT_Get;
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
-- 12/01/2011 Paul.  Add ordering by PARENT_TYPE so that Contacts get selected before Users. 
-- This is an issue when dealing with portal users where the Contact ID matches the User ID. 
Create Procedure dbo.spPARENT_Get
	( @ID                uniqueidentifier output
	, @MODULE            nvarchar( 25) output
	, @PARENT_TYPE       nvarchar( 25) output
	, @PARENT_NAME       nvarchar(150) output
	)
as
  begin
	set nocount on
	
	declare @PARENT_ID uniqueidentifier;
	select top 1 @PARENT_ID   = PARENT_ID
	     , @MODULE      = MODULE
	     , @PARENT_TYPE = PARENT_TYPE
	     , @PARENT_NAME = PARENT_NAME
	  from vwPARENTS
	 where PARENT_ID    = @ID
	 order by PARENT_TYPE;

	-- Return NULL if not found. 
	set @ID = @PARENT_ID;
  end
GO

Grant Execute on dbo.spPARENT_Get to public;
GO

