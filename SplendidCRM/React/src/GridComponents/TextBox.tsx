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
// 3. Scripts. 
import Sql              from '../scripts/Sql'    ;
// 4. Components and Views. 

interface ITextBoxProps
{
	baseId: string;
	row   : any;
	layout: any;
}

class TextBox extends React.PureComponent<ITextBoxProps>
{
	constructor(props: ITextBoxProps)
	{
		super(props);
	}

	public render()
	{
		const { baseId, layout, row } = this.props;
		let DATA_FIELD = Sql.ToString(layout.DATA_FIELD);
		let sKEY = baseId + '_' + DATA_FIELD;
		if ( layout == null )
		{
			return (<div>layout prop is null</div>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', layout, row);
			return (<div>DATA_FIELD is empty for FIELD_INDEX {layout.FIELD_INDEX}</div>);
		}
		else
		{
			var sVALUE = (row ? Sql.ToString(row[DATA_FIELD]) : '');
			return (<div id={sKEY} key={sKEY}>{sVALUE}</div>);
		}
	}
}

export default TextBox;
