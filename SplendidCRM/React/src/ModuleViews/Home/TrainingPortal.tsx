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
import L10n           from '../../scripts/L10n'       ;
import Credentials    from '../../scripts/Credentials';
import { Crm_Config } from '../../scripts/Crm'        ;
// 4. Components and Views. 

interface ITrainingPortalProps extends RouteComponentProps<any>
{
}

class TrainingPortal extends React.Component<ITrainingPortalProps>
{
	constructor(props: ITrainingPortalProps)
	{
		super(props);

		Credentials.SetViewMode('HomeView');
	}

	async componentDidMount()
	{
		try
		{
			document.title = L10n.Term('.LBL_BROWSER_TITLE');
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	public render()
	{
		let sugar_university: string = Crm_Config.ToString('sugar_university');
		let sugar_version   : string = Crm_Config.ToString('sugar_version'   );
		let url             : string = sugar_university.replace('{0}', sugar_version).replace('{1}', Credentials.sUSER_LANG.replace('-', '_'));
		return (<span className='body'>
			<iframe width="100%" height={ 800 } frameBorder={ 0 } src={ url }></iframe>
		</span>
		);
	}
}

export default withRouter(TrainingPortal);
