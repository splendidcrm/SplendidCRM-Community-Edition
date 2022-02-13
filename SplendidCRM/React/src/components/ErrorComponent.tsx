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
import { Alert } from 'react-bootstrap';
// 2. Store and Types. 
// 3. Scripts. 
// 4. Components and Views. 
interface IErrorComponentProps
{
	error?: any;
}

class ErrorComponent extends React.Component<IErrorComponentProps>
{
	constructor(props: IErrorComponentProps)
	{
		super(props);
	}

	public render()
	{
		const { error } = this.props;
		if ( error != undefined && error != null )
		{
			//console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			if (error)
			{
				let sError = error;
				if ( error.message !== undefined )
				{
					sError = error.message;
				}
				else if ( typeof(error) == 'string' )
				{
					sError = error;
				}
				else if ( typeof(error) == 'object' )
				{
					sError = JSON.stringify(error);
				}
				return <Alert variant='danger'>{sError}</Alert>;
			}
			return null;
		}
		else
		{
			return null;
		}
	}
}

export default ErrorComponent;
