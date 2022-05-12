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
// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
import PacificSubPanelHeaderButtons   from './Pacific/SubPanelHeaderButtons'  ;
import ArcticSubPanelHeaderButtons    from './Arctic/SubPanelHeaderButtons'   ;
import AtlanticSubPanelHeaderButtons  from './Atlantic/SubPanelHeaderButtons' ;
import SevenSubPanelHeaderButtons     from './Seven/SubPanelHeaderButtons'    ;
import SixSubPanelHeaderButtons       from './Six/SubPanelHeaderButtons'      ;
import SugarSubPanelHeaderButtons     from './Sugar/SubPanelHeaderButtons'    ;
import Sugar2006SubPanelHeaderButtons from './Sugar2006/SubPanelHeaderButtons';

export default function SubPanelButtonsFactory(sTHEME: string)
{
	let ctl: any = null;
	switch ( sTHEME )
	{
		// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
		case 'Pacific'  :  ctl = PacificSubPanelHeaderButtons  ;  break;
		case 'Arctic'   :  ctl = ArcticSubPanelHeaderButtons   ;  break;
		case 'Atlantic' :  ctl = AtlanticSubPanelHeaderButtons ;  break;
		case 'Mobile'   :  ctl = null                          ;  break;
		case 'Seven'    :  ctl = SevenSubPanelHeaderButtons    ;  break;
		case 'Six'      :  ctl = SixSubPanelHeaderButtons      ;  break;
		case 'Sugar'    :  ctl = SugarSubPanelHeaderButtons    ;  break;
		case 'Sugar2006':  ctl = Sugar2006SubPanelHeaderButtons;  break;
	}
	if ( ctl )
	{
		//console.log((new Date()).toISOString() + ' ' + 'SubPanelButtonsFactory found ' + sTHEME);
	}
	else
	{
		// 04/01/2022 Paul.  Add Pacific theme, derived from Arctic.
		ctl = PacificSubPanelHeaderButtons;
		//console.log((new Date()).toISOString() + ' ' + 'SubPanelButtonsFactory not found ' + sTHEME + ', using Arctic');
	}
	return ctl;
}

