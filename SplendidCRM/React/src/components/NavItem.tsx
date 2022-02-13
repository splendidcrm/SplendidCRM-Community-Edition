/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import * as React from 'react';
import { NavDropdown, NavDropdownProps, Dropdown } from 'react-bootstrap';
import { ReplaceProps } from 'react-bootstrap/helpers';

interface INavItemState
{
	show: boolean;
}

class NavItem extends React.Component<ReplaceProps<typeof Dropdown, NavDropdownProps>, INavItemState>
{
	state =
	{
		show: false
	};

	render()
	{
		const { show } = this.state;
		const {  onMouseEnter, onMouseLeave  } = this.props;
		return (
			<NavDropdown {...this.props}
				show={show}
				onMouseEnter={ () => this.setState({ show: true  }) }
				onMouseLeave={ () => this.setState({ show: false }) }
				>
				{ this.props.children }
			</NavDropdown>
		)
	}
}

export default NavItem;
