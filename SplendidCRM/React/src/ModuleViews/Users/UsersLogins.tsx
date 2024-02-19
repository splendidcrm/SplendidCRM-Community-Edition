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
import { RouteComponentProps, withRouter } from '../Router5'                    ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP            from '../../types/DETAILVIEWS_RELATIONSHIP';
// 3. Scripts. 
// 4. Components and Views. 
import SubPanelView                        from '../../views/SubPanelView'            ;

interface IUsersLoginsProps extends RouteComponentProps<any>
{
	PARENT_TYPE      : string;
	row              : any;
	layout           : DETAILVIEWS_RELATIONSHIP;
}

class UsersLogins extends React.Component<IUsersLoginsProps>
{
	constructor(props: IUsersLoginsProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + props.PARENT_TYPE, props.layout);
	}

	public render()
	{
		return <SubPanelView { ...this.props } disableView={ true } disableEdit={ true } disableRemove={ true } CONTROL_VIEW_NAME='Users.Logins' />;
	}
}

export default withRouter(UsersLogins);
