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
// 4. Components and Views. 

import ArcticHeaderButtons            from './Arctic/HeaderButtons'           ;
import AtlanticHeaderButtons          from './Atlantic/HeaderButtons'         ;
import SevenHeaderButtons             from './Seven/HeaderButtons'            ;
import SixHeaderButtons               from './Six/HeaderButtons'              ;
import SugarHeaderButtons             from './Sugar/HeaderButtons'            ;
import Sugar2006HeaderButtons         from './Sugar2006/HeaderButtons'        ;

export default function HeaderButtonsFactory(sTHEME: string)
{
	let ctl: any = null;
	switch ( sTHEME )
	{
		case 'Arctic'   :  ctl = ArcticHeaderButtons   ;  break;
		case 'Atlantic' :  ctl = AtlanticHeaderButtons ;  break;
		case 'Mobile'   :  ctl = null                  ;  break;
		case 'Seven'    :  ctl = SevenHeaderButtons    ;  break;
		case 'Six'      :  ctl = SixHeaderButtons      ;  break;
		case 'Sugar'    :  ctl = SugarHeaderButtons    ;  break;
		case 'Sugar2006':  ctl = Sugar2006HeaderButtons;  break;
	}
	if ( ctl )
	{
		//console.log((new Date()).toISOString() + ' ' + 'HeaderButtonsFactory found ' + sTHEME);
	}
	else
	{
		ctl = ArcticHeaderButtons;
		//console.log((new Date()).toISOString() + ' ' + 'HeaderButtonsFactory not found ' + sTHEME + ', using Arctic');
	}
	return ctl;
}

