if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnConvertXmlToList' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnConvertXmlToList;
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
Create Function dbo.fnConvertXmlToList(@XML nvarchar(max))
returns nvarchar(max)
as
  begin
	declare @VALUE nvarchar(max);
	set @VALUE = replace(@XML  , '<?xml version="1.0" encoding="UTF-8"?>', '');
	set @VALUE = replace(@VALUE, '</Value><Value>'  , ', ');
	set @VALUE = replace(@VALUE, '<Values><Value>'  , '');
	set @VALUE = replace(@VALUE, '</Value></Values>', '');
	return @VALUE;
  end
GO

Grant Execute on dbo.fnConvertXmlToList to public
GO

