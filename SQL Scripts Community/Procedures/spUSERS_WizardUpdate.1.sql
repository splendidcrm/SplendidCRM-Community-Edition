if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spUSERS_WizardUpdate' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spUSERS_WizardUpdate;
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
-- 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
Create Procedure dbo.spUSERS_WizardUpdate
	( @ID               uniqueidentifier
	, @MODIFIED_USER_ID uniqueidentifier
	, @DATE_FORMAT      nvarchar(25)
	, @TIME_FORMAT      nvarchar(25)
	, @LANG             nvarchar(10)
	, @CURRENCY_ID      uniqueidentifier
	, @TIMEZONE_ID      uniqueidentifier
	)
as
  begin
	set nocount on

	update USERS
	   set DATE_FORMAT      = @DATE_FORMAT              
	     , TIME_FORMAT      = @TIME_FORMAT              
	     , LANG             = @LANG                     
	     , CURRENCY_ID      = @CURRENCY_ID              
	     , TIMEZONE_ID      = @TIMEZONE_ID              
	     , DATE_MODIFIED    = getdate()
	     , DATE_MODIFIED_UTC= getutcdate()
	     , MODIFIED_USER_ID = @MODIFIED_USER_ID
	 where ID               = @ID
	   and DELETED          = 0;
  end
GO

Grant Execute on dbo.spUSERS_WizardUpdate to public;
GO


