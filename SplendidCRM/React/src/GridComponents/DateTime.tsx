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
import Sql              from '../scripts/Sql';
import Security         from '../scripts/Security';
import { FromJsonDate } from '../scripts/Formatting';
// 4. Components and Views. 

interface IDateTimeProps
{
	row     : any;
	layout  : any;
	dateOnly: boolean;
}

class DateTime extends React.PureComponent<IDateTimeProps>
{
	public render()
	{
		const { layout, row, dateOnly } = this.props;
		let DATA_VALUE = '';
		let DATA_FIELD = Sql.ToString(layout.DATA_FIELD);
		if ( dateOnly )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Render Date ' + DATA_FIELD, row);
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Render DateTime ' + DATA_FIELD, row);
		}
		if ( layout == null )
		{
			return (<div>layout prop is null</div>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<div>DATA_FIELD is empty for FIELD_INDEX { layout.FIELD_INDEX }</div>);
		}
		else
		{
			let sVALUE = (row ? Sql.ToString(row[DATA_FIELD]) : '');
			if ( row )
			{
				DATA_VALUE = row[DATA_FIELD];
				if ( dateOnly )
				{
					DATA_VALUE = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT());
				}
				else
				{
					DATA_VALUE = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
				}
			}
			return (<div>{ DATA_VALUE }</div>);
		}
	}
}

export default DateTime;
