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
import { RouteComponentProps, withRouter } from '../Router5'               ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../../scripts/Sql'              ;
import {  Crm_Modules }                    from '../../scripts/Crm'              ;
import { EditView_LoadItem }               from '../../scripts/EditView'         ;
// 4. Components and Views. 
import ErrorComponent                      from '../../components/ErrorComponent';

interface IEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
	ID?                : string;
}

interface IEditViewState
{
	error              : any;
}

class ActivitiesEditView extends React.Component<IEditViewProps, IEditViewState>
{
	constructor(props: IEditViewProps)
	{
		super(props);
		this.state =
		{
			error           : null,
		};
	}

	async componentDidMount()
	{
		const { history, ID } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', ID);
		try
		{
			const d = await EditView_LoadItem('Activities', ID, false);
			let item: any = d.results;
			
			let ACTIVITY_TYPE: string = item['ACTIVITY_TYPE'];
			if ( !Sql.IsEmptyString(ACTIVITY_TYPE) )
			{
				let sRedirectUrl: string = '/Reset/' + ACTIVITY_TYPE + '/Edit/' + ID;
				// 08/09/2019 Paul.  Try and replace the /Reset so that the back button will work properly. 
				history.replace(sRedirectUrl);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { history, location } = this.props;
		const { error } = this.state;
		if ( error )
		{
			return (<ErrorComponent error={error} />);
		}
		return (<div>{ location.pathname + location.search }</div>);
	}
}

export default withRouter(ActivitiesEditView);
