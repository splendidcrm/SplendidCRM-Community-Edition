if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spSqlPrintByLine' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spSqlPrintByLine;
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
Create Procedure dbo.spSqlPrintByLine
	( @COMMAND nvarchar(max)
	)
as
  begin
	set nocount on

	declare @CurrentPosR  int;
	declare @NextPosR     int;
	declare @CRLF         nchar(2);
	declare @Line         nvarchar(4000);

	set @CRLF = char(13) + char(10);
	set @CurrentPosR = 1;
	while @CurrentPosR <= len(@COMMAND) begin -- do
		set @NextPosR = charindex(@CRLF, @COMMAND,  @CurrentPosR);
		if @NextPosR = 0 or @NextPosR is null begin -- then
			set @NextPosR = len(@COMMAND) + 1;
		end -- if;
		set @Line = substring(@COMMAND, @CurrentPosR, @NextPosR - @CurrentPosR);
		print @Line;
		set @CurrentPosR = @NextPosR + 2;
	end -- while;
  end
GO


Grant Execute on dbo.spSqlPrintByLine to public;
GO

