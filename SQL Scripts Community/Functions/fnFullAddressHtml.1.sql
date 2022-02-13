if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnFullAddressHtml' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnFullAddressHtml;
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
-- 02/14/2014 Kevin.  Convert CRLF to <br /> so that street will display as multiple lines. 
-- 04/25/2016 Paul.  Convert 2-letter country code using contries_dom. 
Create Function dbo.fnFullAddressHtml
	( @ADDRESS_STREET     nvarchar(150)
	, @ADDRESS_CITY       nvarchar(100)
	, @ADDRESS_STATE      nvarchar(100)
	, @ADDRESS_POSTALCODE nvarchar(20)
	, @ADDRESS_COUNTRY    nvarchar(100)
	)
returns nvarchar(500)
as
  begin
	declare @FULL_ADDRESS nvarchar(500);
	if len(@ADDRESS_COUNTRY) = 2 begin -- then
		set @ADDRESS_COUNTRY = dbo.fnTERMINOLOGY_Lookup(@ADDRESS_COUNTRY, N'en-US', null, N'countries_dom');
	end -- if;
	set @FULL_ADDRESS = isnull(replace(@ADDRESS_STREET, char(13) + char(10), N'<br />'), N'') + N'<br>' 
	                  + isnull(@ADDRESS_CITY      , N'') + N' ' 
	                  + isnull(@ADDRESS_STATE     , N'') + N' &nbsp;&nbsp;' 
	                  + isnull(@ADDRESS_POSTALCODE, N'') + N'<br>' 
	                  + isnull(@ADDRESS_COUNTRY   , N'') + N' ';
	return @FULL_ADDRESS;
  end
GO

Grant Execute on dbo.fnFullAddressHtml to public
GO

