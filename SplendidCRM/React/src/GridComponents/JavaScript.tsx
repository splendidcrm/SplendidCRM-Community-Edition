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
import ACL_FIELD_ACCESS from '../types/ACL_FIELD_ACCESS';
// 3. Scripts. 
import Sql              from '../scripts/Sql'           ;
import SplendidCache    from '../scripts/SplendidCache' ;
// 4. Components and Views. 

interface IJavaScriptProps
{
	row   : any;
	layout: any;
}

interface IJavaScriptState
{
	bIsReadable: boolean;
}

class JavaScript extends React.PureComponent<IJavaScriptProps, IJavaScriptState>
{
	constructor(props: IJavaScriptProps)
	{
		super(props);
		const { layout } = this.props;
		let bIsReadable: boolean = true;
		if ( layout != null )
		{
			let DATA_FIELD  : string = Sql.ToString(layout.DATA_FIELD);
			let MODULE_NAME : string = SplendidCache.GetGridModule(layout);
			if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
			{
				let gASSIGNED_USER_ID: string = null;
				let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
				bIsReadable  = acl.IsReadable();
			}
		}
		this.setState({ bIsReadable });
	}

	public render()
	{
		const { layout, row } = this.props;
		let DATA_FIELD = Sql.ToString(layout.DATA_FIELD);
		if ( layout == null )
		{
			return (<div>layout prop is null</div>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<div>DATA_FIELD is empty for FIELD_INDEX {layout.FIELD_INDEX}</div>);
		}
		else
		{
			// 11/03/2018 Paul.  JavaScript not supported at this time. 
			return null;
		}
	}
}

export default JavaScript;
