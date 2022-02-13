if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnHtmlXssFilter' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnHtmlXssFilter;
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
-- 01/06/2022 Paul.  We need a way to filter EMAILS.DESCRIPTION_HTML in the database. 
-- Ideally we would use the CONFIG.email_xss set, but that would be too slow, so manually code. 
Create Function dbo.fnHtmlXssFilter(@HTML nvarchar(max))
returns nvarchar(max)
as
  begin
	declare @VALUE nvarchar(max);
	set @VALUE = @HTML;
	if @VALUE is not null begin -- then
		-- 01/06/2022 Paul.  To be efficient, we are going to just disable the start tag and ignore the end tag. 
		set @VALUE = replace(@VALUE, '<html', '<xhtml');
		set @VALUE = replace(@VALUE, '<body', '<xbody');
		set @VALUE = replace(@VALUE, '<base', '<xbase');
		set @VALUE = replace(@VALUE, '<form', '<xform');
		set @VALUE = replace(@VALUE, '<meta', '<xmeta');
		set @VALUE = replace(@VALUE, '<style', '<xstyle');
		set @VALUE = replace(@VALUE, '<embed', '<xembed');
		set @VALUE = replace(@VALUE, '<object', '<xobject');
		set @VALUE = replace(@VALUE, '<script', '<xscript');
		set @VALUE = replace(@VALUE, '<iframe', '<xiframe');
	end -- if;
	return @VALUE;
  end
GO

Grant Execute on dbo.fnHtmlXssFilter to public
GO

