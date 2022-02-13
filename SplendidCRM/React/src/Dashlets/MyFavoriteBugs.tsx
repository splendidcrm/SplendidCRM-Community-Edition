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
import IDashletProps                       from '../types/IDashletProps'        ;
// 3. Scripts. 
// 4. Components and Views. 
import BaseMyFavoriteDashlet               from './BaseMyFavoriteDashlet'       ;

const MODULE_NAME   : string = 'Bugs';
const SORT_FIELD    : string = 'DATE_ENTERED';
const SORT_DIRECTION: string = 'desc';

export default class MyFavoriteBugs extends React.Component<IDashletProps>
{
	public render()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', SETTINGS_EDITVIEW, DEFAULT_SETTINGS);
		return (
			<BaseMyFavoriteDashlet
				{ ...this.props }
				MODULE_NAME={ MODULE_NAME }
				SORT_FIELD={ SORT_FIELD }
				SORT_DIRECTION={ SORT_DIRECTION }
			/>
		)
	}
}
