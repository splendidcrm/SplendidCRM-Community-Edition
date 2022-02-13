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
import { Link, RouteComponentProps, withRouter } from 'react-router-dom';
// 2. Store and Types. 
// 3. Scripts. 
// 4. Components and Views. 

interface IPlaceholderViewProps extends RouteComponentProps<any>
{
	MODULE_NAME: string;
	SUB_TITLE  : string;
	ID         : string;
}

class PlaceholderView extends React.Component<IPlaceholderViewProps>
{
	constructor(props: IPlaceholderViewProps)
	{
		super(props);
		this.state =
		{
		}
	}

	public render() {
		const { MODULE_NAME, SUB_TITLE, ID } = this.props;
		return (
			<div>
				Placeholder
			</div>
		);
	}
}

export default withRouter(PlaceholderView);
