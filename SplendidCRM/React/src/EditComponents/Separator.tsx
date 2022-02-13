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
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
// 4. Components and Views. 

export default class Separator extends React.PureComponent<IEditComponentProps>
{
	public get data(): any
	{
		return null;
	}

	public validate(): boolean
	{
		return true;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
	}

	public clear(): void
	{
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render');
		return (<div>&nbsp;</div>);
	}
}

