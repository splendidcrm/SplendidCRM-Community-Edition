if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spNUMBER_SEQUENCES_Formatted' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spNUMBER_SEQUENCES_Formatted;
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
-- 08/19/2010 Paul.  We need to allow the alpha to be null. 
-- 06/21/2012 Paul.  We need to make sure that the Oracle table is locked between calls. 
-- http://bytes.com/topic/oracle/answers/65783-how-lock-row-over-select-followed-update
Create Procedure dbo.spNUMBER_SEQUENCES_Formatted
	( @NAME            nvarchar(60)
	, @SAVE_RESULT     bit
	, @CURRENT_NUMBER  nvarchar(30) output
	)
as
  begin
	set nocount on
	
	declare @ALPHA_PREFIX    nvarchar(10);
	declare @ALPHA_SUFFIX    nvarchar(10);
	declare @NUMERIC_PADDING int;
	declare @CURRENT_VALUE   int;

	select top 1
	       @ALPHA_PREFIX    = isnull(ALPHA_PREFIX, N'')
	     , @ALPHA_SUFFIX    = isnull(ALPHA_SUFFIX, N'')
	     , @NUMERIC_PADDING = NUMERIC_PADDING
	     , @CURRENT_VALUE   = CURRENT_VALUE + SEQUENCE_STEP
	  from vwNUMBER_SEQUENCES
	 where NAME             = @NAME;

	if @SAVE_RESULT = 1 begin -- then
-- #if SQL_Server /*
		update NUMBER_SEQUENCES
		   set CURRENT_VALUE = @CURRENT_VALUE
		 where NAME          = @NAME
		   and DELETED       = 0;
-- #endif SQL_Server */
	end -- if;

	set @CURRENT_NUMBER = cast(@CURRENT_VALUE as nvarchar(30));
	-- print @CURRENT_NUMBER;
	if @NUMERIC_PADDING > 0 and @NUMERIC_PADDING > len(@CURRENT_NUMBER) begin -- then
		if len(@ALPHA_PREFIX) + len(@CURRENT_NUMBER) + len(@ALPHA_SUFFIX) < 30 begin -- then
			set @CURRENT_NUMBER = replace(space(@NUMERIC_PADDING - len(@CURRENT_NUMBER)), N' ', N'0') + @CURRENT_NUMBER;
			-- print @CURRENT_NUMBER;
			if len(@ALPHA_PREFIX) + len(@CURRENT_NUMBER) + len(@ALPHA_SUFFIX) > 30 begin -- then
				set @CURRENT_NUMBER = substring(@CURRENT_NUMBER, len(@ALPHA_PREFIX) + len(@CURRENT_NUMBER) + len(@ALPHA_SUFFIX) + 1 - 30, 30);
				-- print @CURRENT_NUMBER;
			end -- if;
		end -- if;
	end -- if;
	set @CURRENT_NUMBER = @ALPHA_PREFIX + @CURRENT_NUMBER + @ALPHA_SUFFIX;
  end
GO

Grant Execute on dbo.spNUMBER_SEQUENCES_Formatted to public
GO

