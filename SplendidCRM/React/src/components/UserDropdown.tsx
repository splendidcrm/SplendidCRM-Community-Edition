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
import { Modal, Alert }                    from 'react-bootstrap';
import { observer } from 'mobx-react';
// 2. Store and Types. 
// 3. Scripts. 
import Credentials from '../scripts/Credentials';
import SplendidCache from '../scripts/SplendidCache';
import { Logout } from '../scripts/Login';
import L10n from '../scripts/L10n'
// 4. Components and Views. 

const icon = require('../assets/img/SplendidCRM_Icon.gif');

interface IUserDropdownProps extends RouteComponentProps<any>
{
}

type State =
{
}

@observer
class UserDropdown extends React.Component<IUserDropdownProps, State>
{
	constructor(props: IUserDropdownProps)
	{
		super(props);
		this.state =
		{
		};
	}
	
	private AdminMode = () =>
	{
		this.props.history.push(`/Reset/Administration`);
	}

	private UserMode = () =>
	{
		Credentials.SetADMIN_MODE(false);
		this.props.history.push('/Home');
	}

	public render()
	{
		if ( SplendidCache.IsInitialized )
		{
			const menuIconProps =
			{
				className: "fas fas-image",
				src: Credentials.sPICTURE || icon
			};
			
			let menuProps =
			{
				shouldFocusOnMount: true,
				items:
				[
				]
			};
			if ( Credentials.ADMIN_MODE )
			{
				menuProps.items[menuProps.items.length] = 
				{
					key: 'usernmode',
					name: L10n.Term('Home.LBL_LIST_FORM_TITLE'),
					onClick: () => { this.UserMode(); }
				};
			}
			if ( Credentials.bIS_ADMIN || Credentials.bIS_ADMIN_DELEGATE )
			{
				menuProps.items[menuProps.items.length] = 
				{
					key: 'adminmode',
					name: L10n.Term('.LBL_ADMIN'),
					onClick: () => { this.AdminMode(); }
				};
			}
			menuProps.items[menuProps.items.length] = 
			{
				key: 'logout',
				name: 'logout',
				onClick: Logout
			};

			return (
				<div>
					<div style={{ flexGrow: 1 }} />
				</div>
			);
		}
		return null;
	}
}

export default withRouter(UserDropdown);
