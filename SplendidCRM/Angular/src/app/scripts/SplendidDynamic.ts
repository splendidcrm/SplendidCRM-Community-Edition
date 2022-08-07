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
import { EndsWith } from '../scripts/utility';

export default class SplendidDynamic
{
	// 06/18/2015 Paul.  Add support for Seven theme. 
	static StackedLayout(sTheme: string, sViewName?: string): boolean
	{
		if (sViewName === undefined || sViewName == null)
			sViewName = '';
		// 04/02/2022 Paul.  Pacific uses stacked action menus. 
		return (sTheme === 'Seven' || sTheme === 'Pacific') && !EndsWith(sViewName, '.Preview');
	}

	// 04/08/2017 Paul.  Use Bootstrap for responsive design.
	static BootstrapLayout(): boolean
	{
		// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
		//return !bDESKTOP_LAYOUT && sPLATFORM_LAYOUT != '.OfficeAddin';
		return true;
	}
}

