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
import * as React from 'react';
// 2. Store and Types. 
// 3. Scripts. 
import { isMobileDevice, isTouchDevice, screenWidth } from '../scripts/utility'               ;
// 4. Components and Views. 
// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
import PacificTopNav                  from './Pacific/TopNav'                 ;
import ArcticTopNav                   from './Arctic/TopNav'                  ;
import AtlanticTopNav                 from './Atlantic/TopNav'                ;
import SevenTopNav                    from './Seven/TopNav'                   ;
import SixTopNav                      from './Six/TopNav'                     ;
import SugarTopNav                    from './Sugar/TopNav'                   ;
import Sugar2006TopNav                from './Sugar2006/TopNav'               ;
// 05/10/2021 Paul.  The new menu system leaves the menu up or pops up in the wrong location, so only use on mobile devices. 
import ArcticTopNav_Desktop           from './Arctic/TopNav_Desktop'          ;
import AtlanticTopNav_Desktop         from './Atlantic/TopNav_Desktop'        ;
import SevenTopNav_Desktop            from './Seven/TopNav_Desktop'           ;
import SixTopNav_Desktop              from './Six/TopNav_Desktop'             ;
import SugarTopNav_Desktop            from './Sugar/TopNav_Desktop'           ;
import Sugar2006TopNav_Desktop        from './Sugar2006/TopNav_Desktop'       ;

import ArcticSideBar                  from './Arctic/SideBar'                 ;
import Sugar2006SideBar               from './Sugar2006/SideBar'              ;

export function TopNavFactory(sTHEME: string)
{
	let ctl: any = null;
	// 05/10/2021 Paul.  The new menu system leaves the menu up or pops up in the wrong location, so only use on mobile devices. 
	let width : number = screenWidth();
	// 05/11/2021 Paul.  We are having issues with the more dropdown disappearing, so don't treat touch as mobile. 
	// 07/14/2021 Paul.  Now that we have time to test, always enable new menus. 
	if ( true || isMobileDevice() || width < 800 )
	{
		//console.log((new Date()).toISOString() + ' ' + 'TopNavFactory mobile ' + sTHEME);
		switch ( sTHEME )
		{
			case 'Mobile'   :  ctl = ArcticTopNav   ;  break;
			// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
			case 'Pacific'  :  ctl = PacificTopNav  ;  break;
			case 'Arctic'   :  ctl = ArcticTopNav   ;  break;
			case 'Atlantic' :  ctl = AtlanticTopNav ;  break;
			case 'Seven'    :  ctl = SevenTopNav    ;  break;
			case 'Six'      :  ctl = SixTopNav      ;  break;
			case 'Sugar'    :  ctl = SugarTopNav    ;  break;
			case 'Sugar2006':  ctl = Sugar2006TopNav;  break;
		}
	}
	else
	{
		//console.log((new Date()).toISOString() + ' ' + 'TopNavFactory desktop ' + sTHEME);
		switch ( sTHEME )
		{
			case 'Mobile'   :  ctl = ArcticTopNav_Desktop   ;  break;
			case 'Arctic'   :  ctl = ArcticTopNav_Desktop   ;  break;
			case 'Atlantic' :  ctl = AtlanticTopNav_Desktop ;  break;
			case 'Seven'    :  ctl = SevenTopNav_Desktop    ;  break;
			case 'Six'      :  ctl = SixTopNav_Desktop      ;  break;
			case 'Sugar'    :  ctl = SugarTopNav_Desktop    ;  break;
			case 'Sugar2006':  ctl = Sugar2006TopNav_Desktop;  break;
		}
	}
	if ( ctl )
	{
		//console.log((new Date()).toISOString() + ' ' + 'TopNavFactory found ' + sTHEME);
	}
	else
	{
		// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
		ctl = PacificTopNav;
		//console.log((new Date()).toISOString() + ' ' + 'TopNavFactory not found ' + sTHEME + ', using Arctic');
	}
	return ctl;
}

// 01/19/2020 Paul.  Moved HeaderButtonsFactory to separate file due to problem with DynamicLayout.ts not being able to find it. 
// 01/19/2020 Paul.  Moved SubPanelButtonsFactory to separate file due to problem with DynamicLayout.ts not being able to find it. 

export function SideBarFactory(sTHEME: string)
{
	let ctl: any = null;
	switch ( sTHEME )
	{
		case 'Arctic'   :  ctl = ArcticSideBar   ;  break;
		//case 'Sugar'    :  ctl = Sugar2006SideBar;  break;
		case 'Sugar2006':  ctl = Sugar2006SideBar;  break;
	}
	if ( ctl )
	{
		//console.log((new Date()).toISOString() + ' ' + 'SideBarFactory found ' + sTHEME);
	}
	return ctl;
}
