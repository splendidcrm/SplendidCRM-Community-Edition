/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 
import Sql from './Sql';

export function NormalizeDescription(DESCRIPTION: string): string
{
	DESCRIPTION = Sql.ToString(DESCRIPTION);
	// 06/04/2010 Paul.  Try and prevent excess blank lines. 
	DESCRIPTION = DESCRIPTION.replace(/\r\n/g     , '\n'         );
	DESCRIPTION = DESCRIPTION.replace(/\r/g       , '\n'         );
	DESCRIPTION = DESCRIPTION.replace(/<br \/>\n/g, '\n'         );
	DESCRIPTION = DESCRIPTION.replace(/<br\/>\n/g , '\n'         );
	DESCRIPTION = DESCRIPTION.replace(/<br>\n/g   , '\n'         );
	DESCRIPTION = DESCRIPTION.replace(/\n/g       , '<br \/>\r\n');
	return DESCRIPTION;
}

// Cross-Site Scripting (XSS) filter. 
// http://you.gotfoo.org/howto-anti-xss-w-aspnet-and-c/
export function XssFilter(sHTML: string, sXSSTags: string): string
{
	let regex = new RegExp("([a-z]*)[\\x00-\\x20]*=[\\x00-\\x20]*([\\`\\\'\\\\\"]*)[\\x00-\\x20]*j[\\x00-\\x20]*a[\\x00-\\x20]*v[\\x0" + "0-\\x20]*a[\\x00-\\x20]*s[\\x00-\\x20]*c[\\x00-\\x20]*r[\\x00-\\x20]*i[\\x00-\\x20]*p[\\x00-\\x20]*t[\\x00-\\x20]*", 'ig');
	let sResult: string = sHTML.replace(regex, '');
	if ( !Sql.IsEmptyString(sXSSTags) )
	{
		let unwantedTags: string = "</*(" + sXSSTags + ")[^>]*>"; 
		regex = new RegExp(unwantedTags, 'ig');
		sResult = sResult.replace(regex, '');
	}
	// 01/21/2017 Paul.  Exclude MS Word tags. 
	sResult = sResult.replace('<o:p>/g' , '');
	sResult = sResult.replace('</o:p>/g', '');
	return sResult;
}

export function FormatEmailDisplayName(sFROM_NAME: string, sFROM_ADDR: string): string
{
	let sDISPLAY_NAME: string = sFROM_NAME;
	if ( !Sql.IsEmptyString(sFROM_ADDR) )
	{
		if ( !Sql.IsEmptyString(sDISPLAY_NAME) )
			sDISPLAY_NAME += ' ';
		sDISPLAY_NAME += '<' + sFROM_ADDR + '>';
	}
	return sDISPLAY_NAME;
}

