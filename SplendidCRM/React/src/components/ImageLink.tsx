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
import { RouteComponentProps, withRouter } from 'react-router-dom';
import { observer } from 'mobx-react';
// 2. Store and Types. 
// 3. Scripts. 
import Credentials from '../scripts/Credentials';
import { Crm_Modules } from '../scripts/Crm';
// 4. Components and Views. 

interface IImageLinkProps extends RouteComponentProps<any>
{
	ID  : string;
}

interface IImageLinkState
{
	NAME: string;
}

@observer
class ImageLink extends React.Component<IImageLinkProps, IImageLinkState>
{
	constructor(props: IImageLinkProps)
	{
		super(props);
		this.state =
		{
			NAME: ''
		}
	}

	async componentDidMount()
	{
		const { ID } = this.props;
		try
		{
			let value = await Crm_Modules.ItemName('Images', ID);
			this.setState({ NAME: value });
		}
		catch(error)
		{
			// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ NAME: error });
		}
	}

	public render()
	{
		const { ID } = this.props;
		const { NAME } = this.state;
		// 06/23/2019 Paul.  The server should always end with a slash. 
		let sURL = Credentials.RemoteServer + 'Images/Image.aspx?ID=' + ID;
		return (
			<div>
				<a href={sURL}>{NAME}</a>
			</div>
		)
	}
}

export default withRouter(ImageLink);
