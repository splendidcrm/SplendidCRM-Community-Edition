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
import { RouteComponentProps, withRouter } from '../Router5'              ;
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
import { Appear }                          from 'react-lifecycle-appear'        ;
// 2. Store and Types. 
import IDashletProps                       from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import L10n                                from '../scripts/L10n'               ;
// 4. Components and Views. 
import CalendarView                        from '../views/CalendarView'         ;

interface IMyCalendarProps extends IDashletProps
{
}

interface IMyCalendarState
{
	dashletVisible   : boolean;
}

export default class MyCalendar extends React.Component<IMyCalendarProps, IMyCalendarState>
{
	constructor(props: IMyCalendarProps)
	{
		super(props);
		this.state =
		{
			dashletVisible  : false,
		}
	}

	public render()
	{
		const { TITLE } = this.props;
		const { dashletVisible } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + MODULE_NAME, SETTINGS_EDITVIEW, DEFAULT_SETTINGS);
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.setState({ dashletVisible: true }) }>
					<div className="card-body DashletHeader">
						<h3 style={ {float: 'left'} }>{ L10n.Term(TITLE) }</h3>
					</div>
				</Appear>
				{ dashletVisible
				? <div style={ {clear: 'both'} }>
					<hr />
					<CalendarView
						disableModuleHeader={ true }
					/>
				</div>
				: null
				}
			</div>
		</div>);
	}
}
