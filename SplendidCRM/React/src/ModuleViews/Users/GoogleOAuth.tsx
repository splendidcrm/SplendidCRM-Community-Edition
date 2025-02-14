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
import React from 'react';
import qs from 'query-string';
import { Link, RouteComponentProps, withRouter } from '../Router5';
// 2. Store and Types. 
// 3. Scripts. 
import Sql              from '../../scripts/Sql'          ;
import Security         from '../../scripts/Security'     ;
import SplendidCache    from '../../scripts/SplendidCache';
import { Crm_Config }   from '../../scripts/Crm'          ;
// 4. Components and Views. 

interface IGoogleOAuthProps extends RouteComponentProps<any>
{
}

interface IGoogleOAuthState
{
	error?          : any;
}

class GoogleOAuth extends React.Component<IGoogleOAuthProps, IGoogleOAuthState>
{
	constructor(props: IGoogleOAuthProps)
	{
		super(props);
		this.state =
		{
		};
	}

	async componentDidMount()
	{
		try
		{
			let queryParams: any    = qs.parse(location.search);
			let client_id  : string = Crm_Config.ToString('GoogleApps.ClientID')
			let code       : string = Sql.ToString(queryParams['code' ]);
			let error      : string = Sql.ToString(queryParams['error']);
			let ID         : string = Sql.ToString(queryParams['state']);
			let url        : string = '/Reload';
			if ( !Sql.IsEmptyGuid(ID) && ID.length == 36 && ID != Security.USER_ID() && SplendidCache.AdminUserAccess('Users', 'edit') >= 0 )
			{
				url += '/Administration/Users/Edit/' + ID;
			}
			else
			{
				url += '/Users/EditMyAccount';
			}
			url += '?oauth_host=GoogleApps&code=' + encodeURIComponent(code) + '&error=' + encodeURIComponent(error)
			this.props.history.push(url);
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	public render()
	{
		return null;
	}
}

export default withRouter(GoogleOAuth);
