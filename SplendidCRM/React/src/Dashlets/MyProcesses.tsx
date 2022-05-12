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
import moment from 'moment';
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
import { Appear }                             from 'react-lifecycle-appear'        ;
// 2. Store and Types. 
import IDashletProps                          from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                ;
import L10n                                   from '../scripts/L10n'               ;
import Security                               from '../scripts/Security'           ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { Crm_Config }                         from '../scripts/Crm'                ;
import { FromJsonDate, formatDate }           from '../scripts/Formatting'         ;
import { EditView_LoadLayout }                from '../scripts/EditView'           ;
import { LoadProcessPaginated }               from '../scripts/ProcessButtons'     ;
// 4. Components and Views. 
import DumpSQL                                from '../components/DumpSQL'         ;
import SplendidGrid                           from '../components/SplendidGrid'    ;
import SearchView                             from '../views/SearchView'           ;
import ErrorComponent                         from '../components/ErrorComponent'  ;

const MODULE_NAME   : string = 'Processes';
const SORT_FIELD    : string = 'DATE_ENTERED';
const SORT_DIRECTION: string = 'asc';

interface IMyProcessesState
{
	DEFAULT_SETTINGS    : any;
	myProcesses         : any[];
	selfServiceProcesses: any[];
	activeTab           : number;
	error?              : any;
	__sql?              : any;
}

export default class MyProcesses extends React.Component<IDashletProps, IMyProcessesState>
{
	private _isMounted = false;
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private themeURL   : string  = null;
	private legacyIcons: boolean = false;

	constructor(props: IDashletProps)
	{
		super(props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if ( objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null )
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.ASSIGNED_USER_ID = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_TO = Security.USER_NAME();
			objDEFAULT_SETTINGS.ASSIGNED_SET_LIST = Security.USER_ID();
			objDEFAULT_SETTINGS.ASSIGNED_SET_NAME = Security.USER_NAME();
		}
		let layout = null;
		if ( !Sql.IsEmptyString(props.SETTINGS_EDITVIEW) )
		{
			layout = EditView_LoadLayout(props.SETTINGS_EDITVIEW);
		}
		this.state =
		{
			DEFAULT_SETTINGS    : objDEFAULT_SETTINGS,
			myProcesses         : [],
			selfServiceProcesses: [],
			activeTab           : 0,
		}
	}

	async componentDidMount()
	{
		this._isMounted = true;
		// 07/30/2021 Paul.  Loaded when panel appears. 
		//await this.load();
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private _onRefresh = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRefresh');
		await this.load();
	}

	private load = async () =>
	{
		try
		{
			let d: any = await LoadProcessPaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, null, null, null, 0, 0, true);
			let myProcesses         : any[] = [];
			let selfServiceProcesses: any[] = [];
			if ( d.results != null )
			{
				for ( let i = 0; i < d.results.length; i++ )
				{
					let item: any = d.results[i];
					if ( item['PROCESS_USER_ID'] != null )
					{
						item['OverdueMessage'] = this.OverdueMessage(FromJsonDate(item['DATE_ENTERED']), item['DURATION_UNITS'], Sql.ToInteger(item['DURATION_VALUE']));
						myProcesses.push(item);
					}
					else
					{
						item['OverdueMessage'] = this.OverdueMessage(FromJsonDate(item['DATE_ENTERED']), item['DURATION_UNITS'], Sql.ToInteger(item['DURATION_VALUE']));
						selfServiceProcesses.push(item);
					}
				}
			}
			this.setState(
			{
				myProcesses         ,
				selfServiceProcesses,
				error               : null,
				__sql               : d.__sql
			});
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	private OverdueMessage =(dtDATE_ENTERED, sDURATION_UNITS, nDURATION_VALUE) =>
	{
		let sProcessStatus = null;
		if ( !Sql.IsEmptyString(sDURATION_UNITS) && nDURATION_VALUE > 0 )
		{
			let dtDUE_DATE: moment.Moment = moment(dtDATE_ENTERED);
			switch ( sDURATION_UNITS )
			{
				case 'hour'   :  dtDUE_DATE = dtDUE_DATE.add(    nDURATION_VALUE, 'hours'   );  break;
				case 'day'    :  dtDUE_DATE = dtDUE_DATE.add(    nDURATION_VALUE, 'days'    );  break;
				case 'week'   :  dtDUE_DATE = dtDUE_DATE.add(7 * nDURATION_VALUE, 'weeks'   );  break;
				case 'month'  :  dtDUE_DATE = dtDUE_DATE.add(    nDURATION_VALUE, 'months'  );  break;
				case 'quarter':  dtDUE_DATE = dtDUE_DATE.add(3 * nDURATION_VALUE, 'quarters');  break;
				case 'year'   :  dtDUE_DATE = dtDUE_DATE.add(    nDURATION_VALUE, 'years'   );  break;
			}
			if ( dtDUE_DATE <= moment() )
			{
				let sDUE_DATE = formatDate(dtDUE_DATE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
				sProcessStatus = L10n.Term('Processes.LBL_OVERDUE_FORMAT').replace('{0}', sDUE_DATE);
			}
		}
		return sProcessStatus;
	}

	private setActiveTab = (tab) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.setActiveTab', tab);
		this.setState({ activeTab: tab });
	}

	public render()
	{
		const { TITLE } = this.props;
		const { myProcesses, selfServiceProcesses, activeTab, error, __sql } = this.state;
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.load() }>
					<div className="card-body DashletHeader">
						<h3 style={ {float: 'left'} }>{ L10n.Term(TITLE) }</h3>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ (e) => this._onRefresh(e) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'refresh.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="sync" size="lg" />
							}
						</span>
					</div>
				</Appear>
				<div style={ {clear: 'both'} }>
					<hr />
					<DumpSQL SQL={ __sql } />
					<div style={ {display: 'flex'} }>
						<div className={ activeTab == 0 ? 'MyProcessActiveTab' : 'MyProcessInactiveTab' } style={ {width: '50%', justifyContent: 'center'} } onClick={ (e) => this.setActiveTab(0) } >
							<div className='MyProcessCount'     >{ myProcesses.length }</div>
							<div className='MyProcessCountLabel'>{ L10n.Term('Processes.LBL_MY_PROCESSES') }</div>
						</div>
						<div className={ activeTab == 1 ? 'MyProcessActiveTab' : 'MyProcessInactiveTab' } style={ {width: '50%', justifyContent: 'center'} } onClick={ (e) => this.setActiveTab(1) } >
							<div className='MyProcessCount'     >{ selfServiceProcesses.length }</div>
							<div className='MyProcessCountLabel'>{ L10n.Term('Processes.LBL_SELF_SERVICE_PROCESSES') }</div>
						</div>
					</div>
					<ErrorComponent error={ error } />
					{ activeTab == 0
					? myProcesses.map((item, index) =>
						{
							return (<div className='MyProcessFrame'>
								<div>
									<a onClick={ (e) => this.props.history.push('/' + item['PARENT_TYPE'] + '/View/' + item['PARENT_ID']) } title={ item['PARENT_NAME'] } style={ {cursor: 'pointer'} }>
										<span className='MyProcessName'>{ L10n.Term('Processes.LBL_MY_PROCESSES_NAME_FORMAT').replace('{0}', item['PROCESS_NUMBER']).replace('{1}', item['PARENT_NAME']) }</span>
									</a>
								</div>
								{ item['OverdueMessage']
								? <div className='MyProcessOverdue'>
									[ <span className='ProcessOverdue'>{ item['OverdueMessage'] }</span> ]
								</div>
								: null
								}
								<div>
									<span className='MyProcessAssignedUser'>{ item['ASSIGNED_FULL_NAME'] }</span>&nbsp;
									<span className='MyProcessActivityName'>{ item['ACTIVITY_NAME'] }</span>
								</div>
								<div className='MyProcessBusinessProcessName'>
									<span>{ item['BUSINESS_PROCESS_NAME'] }</span>
								</div>
							</div>);
						})
					: null
					}
					{ activeTab == 1
					? selfServiceProcesses.map((item, index) =>
						{
							return (<div className='MyProcessFrame'>
								<div>
									<a onClick={ (e) => this.props.history.push('/' + item['PARENT_TYPE'] + '/View/' + item['PARENT_ID']) } title={ item['PARENT_NAME'] } style={ {cursor: 'pointer'} }>
										<span className='MyProcessName'>{ L10n.Term('Processes.LBL_MY_PROCESSES_NAME_FORMAT').replace('{0}', item['PROCESS_NUMBER']).replace('{1}', item['PARENT_NAME']) }</span>
									</a>
								</div>
								{ item['OverdueMessage']
								? <div className='MyProcessOverdue'>
									[ <span className='ProcessOverdue'>{ item['OverdueMessage'] }</span> ]
								</div>
								: null
								}
								<div>
									<span className='MyProcessAssignedUser'>{ item['ASSIGNED_FULL_NAME'] }</span>&nbsp;
									<span className='MyProcessActivityName'>{ item['ACTIVITY_NAME'] }</span>
								</div>
								<div className='MyProcessBusinessProcessName'>
									<span>{ item['BUSINESS_PROCESS_NAME'] }</span>
								</div>
							</div>);
						})
					: null
					}
				</div>
			</div>
		</div>);
	}
}
