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
import { FontAwesomeIcon }           from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                           from '../scripts/Sql'                ;
import L10n                          from '../scripts/L10n'               ;
import Security                      from '../scripts/Security'           ;
import Credentials                   from '../scripts/Credentials'        ;
import SplendidCache                 from '../scripts/SplendidCache'      ;
import { formatDate, FromJsonDate }  from '../scripts/Formatting'         ;
import { Crm_Config }                from '../scripts/Crm'                ;
// 4. Components and Views. 
import DumpSQL                       from '../components/DumpSQL'         ;
import ListHeader                    from '../components/ListHeader'      ;

interface ISchedulingGridProps
{
	DATE_START        : any;
	DURATION_HOURS    : number;
	DURATION_MINUTES  : number;
	INVITEE_LIST      : string;
	InviteesActivities: any[];
	onRemoveInvitee   : (INVITEE_ID: string) => void;
	__sql?            : string;
}

interface ISchedulingGridState
{
	sLongDatePattern: string;
}

export default class SchedulingGrid extends React.Component<ISchedulingGridProps, ISchedulingGridState>
{
	private dtSCHEDULE_START: moment.Moment = moment();
	private dtSCHEDULE_END  : moment.Moment = moment();
	private dtDATE_START    : moment.Moment = null;
	private dtDATE_END      : moment.Moment = null;
	private themeURL        : string = null;
	private legacyIcons     : boolean = false;

	constructor(props: ISchedulingGridProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let sLongDatePattern  = L10n.Term('Calendar.LongDatePattern');
		sLongDatePattern  = sLongDatePattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
		sLongDatePattern  = sLongDatePattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
		if ( Sql.IsEmptyString(sLongDatePattern ) || sLongDatePattern  == 'Calendar.LongDatePattern' )
			sLongDatePattern  = 'dddd, MMMM dd, yyyy';

		this.UpdateScheduleTime(props);
		this.state =
		{
			sLongDatePattern
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	shouldComponentUpdate(nextProps: ISchedulingGridProps, nextState: ISchedulingGridState)
	{
		const { DATE_START, DURATION_HOURS, DURATION_MINUTES, INVITEE_LIST } = this.props;
		if ( nextProps.DATE_START != this.props.DATE_START || nextProps.DURATION_HOURS != this.props.DURATION_HOURS || nextProps.DURATION_MINUTES != this.props.DURATION_MINUTES )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate DATE_START', DATE_START, nextProps, nextState);
			this.UpdateScheduleTime(nextProps);
			return true;
		}
		else if ( nextProps.INVITEE_LIST != this.props.INVITEE_LIST || JSON.stringify(nextProps.InviteesActivities) != JSON.stringify(this.props.InviteesActivities) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate INVITEE_LIST', INVITEE_LIST, nextProps, nextState);
			return true;
		}
		return false;
	}

	// 06/14/2020 Paul.  Calling from shouldComponentUpdate will not use the correct props values, so pass them in. 
	private UpdateScheduleTime = (nextProps) =>
	{
		const { DATE_START, DURATION_HOURS, DURATION_MINUTES, INVITEE_LIST } = nextProps;
		this.dtSCHEDULE_START = moment();
		this.dtSCHEDULE_START.minutes(Math.floor(this.dtSCHEDULE_START.minutes()/15) * 15);
		this.dtSCHEDULE_START.seconds(0);
		this.dtSCHEDULE_START.milliseconds(0);
		this.dtSCHEDULE_END.add(9, 'hours');
		if ( DATE_START )
		{
			if ( typeof (DATE_START) == 'string' && DATE_START.substr(0, 7) === '\\/Date(' )
				this.dtDATE_START = moment(FromJsonDate(DATE_START));
			else
				this.dtDATE_START = moment(DATE_START);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateScheduleTime', this.dtDATE_START.toDate());

			this.dtDATE_END = moment(this.dtDATE_START);
			this.dtDATE_END.add(DURATION_HOURS, 'hours');
			this.dtDATE_END.add(DURATION_MINUTES, 'minutes');
			this.dtSCHEDULE_START = moment(this.dtDATE_START);
			this.dtSCHEDULE_START.subtract(4, 'hours');
			this.dtSCHEDULE_END = moment(this.dtSCHEDULE_START);
			this.dtSCHEDULE_END.add(9, 'hours');
		}
	}

	private _onRemoveInvitee = (INVITEE_ID) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemoveInvitee', INVITEE_ID);
		this.props.onRemoveInvitee(INVITEE_ID);
	}

	private BuildInviteesRow = () =>
	{
		const { INVITEE_LIST, InviteesActivities } = this.props;
		let tr: any[] = [];
		if ( !Sql.IsEmptyString(INVITEE_LIST) )
		{
			let themeURL: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let arrINVITEES: string[] = INVITEE_LIST.split(',');
			for ( let i: number = 0; i < arrINVITEES.length; i++ )
			{
				let invitee: any = null;
				for ( let j: number = 0; j < InviteesActivities.length; j++ )
				{
					if ( arrINVITEES[i] == InviteesActivities[j].ID )
					{
						invitee = InviteesActivities[j];
						break;
					}
				}
				let arrTimeRow: any[] = [];
				if ( invitee && invitee.Activities && invitee.Activities.length > 0 )
				{
					for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(15, 'minutes') )
					{
						let dtHOUR_END: moment.Moment  = moment(dtHOUR_START).add(15, 'minutes');
						let bOverlap: boolean = false;
						for ( let j: number = 0; j < invitee.Activities.length; j++ )
						{
							let activity: any = invitee.Activities[j];
							// vwMain.RowFilter = "   DATE_START >= #" + sHOUR_START_ServerTime + "# and DATE_START <  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
							//                  + "or DATE_END   >  #" + sHOUR_START_ServerTime + "# and DATE_END   <= #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
							//                  + "or DATE_START <  #" + sHOUR_START_ServerTime + "# and DATE_END   >  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf;
							if ( activity.dtDATE_START      >= dtHOUR_START && activity.dtDATE_START <  dtHOUR_END )
								bOverlap = true;
							else if ( activity.dtDATE_END   >  dtHOUR_START && activity.dtDATE_END   <= dtHOUR_END )
								bOverlap = true;
							else if ( activity.dtDATE_START <  dtHOUR_START && activity.dtDATE_END   >  dtHOUR_END )
								bOverlap = true;
						}
						let style: any = {};
						if ( bOverlap )
						{
							if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
								style.backgroundColor = '#aa4d4d';
							else
								style.backgroundColor = '#4d5eaa';
						}
						else
						{
							if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
								style.backgroundColor = '#ffffff';
						}
						if ( dtHOUR_START.isSame(this.dtDATE_END) )
							arrTimeRow.push(<td className='schedulerSlotCellEndTime'   style={ style }></td>);
						else if ( dtHOUR_START.isSame(this.dtDATE_START) )
							arrTimeRow.push(<td className='schedulerSlotCellStartTime' style={ style }></td>);
						else
							arrTimeRow.push(<td className='schedulerSlotCellHour'      style={ style }></td>);
					}
				}
				else
				{
					for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(15, 'minutes') )
					{
						let dtHOUR_END: moment.Moment  = moment(dtHOUR_START).add(15, 'minutes');
						let style: any = {};
						if ( dtHOUR_START >= this.dtDATE_START && dtHOUR_START < this.dtDATE_END )
							style.backgroundColor = '#ffffff';
						if ( dtHOUR_START.isSame(this.dtDATE_END) )
							arrTimeRow.push(<td className='schedulerSlotCellEndTime'   style={ style }></td>);
						else if ( dtHOUR_START.isSame(this.dtDATE_START) )
							arrTimeRow.push(<td className='schedulerSlotCellStartTime' style={ style }></td>);
						else
							arrTimeRow.push(<td className='schedulerSlotCellHour'      style={ style }></td>);
					}
				}
				tr.push(
				<tr className='schedulerAttendeeRow'>
					<td className='schedulerAttendeeCell'>
						<img src={ themeURL + 'Users.gif' } style={ {borderWidth: '0px', height: '16px', width: '16px'} } />
						{ invitee ? invitee.FULL_NAME : null }
					</td>
					{ arrTimeRow }
					<td className='schedulerAttendeeDeleteCell'>
						<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveInvitee(arrINVITEES[i]) }>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon='minus' size='lg' style={ {marginRight: '4px'} } />
							}
						</span>
						&nbsp;
						<a href='#' onClick={ (e) => { e.preventDefault(); this._onRemoveInvitee(arrINVITEES[i]); } }>{ L10n.Term('.LNK_REMOVE') }</a>
					</td>
				</tr>);
			}
		}
		return tr;
	}

	public render()
	{
		const { DATE_START, __sql } = this.props;
		const { sLongDatePattern } = this.state;
		if ( SplendidCache.IsInitialized  )
		{
			let arrTimeRow: any[] = [];
			if ( DATE_START )
			{
				for ( let dtHOUR_START = moment(this.dtSCHEDULE_START); dtHOUR_START < this.dtSCHEDULE_END; dtHOUR_START.add(1, 'hours') )
				{
					arrTimeRow.push(<td className='schedulerTimeCell' colSpan={ 4 }>{ formatDate(dtHOUR_START, Security.USER_TIME_FORMAT()) }</td>);
				}
			}
			let sDATE_TITLE: string = formatDate(this.dtDATE_START, sLongDatePattern);
			return (
			<React.Fragment>
				<ListHeader TITLE='Calls.LBL_SCHEDULING_FORM_TITLE'>
				</ListHeader>
				<DumpSQL SQL={ __sql } />
				<div className='schedulerDiv'>
					<table cellPadding={ 0 } cellSpacing={ 0 } className='schedulerTable' style={ {width: '100%', border: 'none'} }>
						<tr className='schedulerTopRow'>
							<td className='schedulerTopDateCell' colSpan={ arrTimeRow.length * 4 + 2 } style={ {textAlign: 'center', height: '20px'} }>
								{ sDATE_TITLE }
							</td>
						</tr>
						<tr>
							<td className='schedulerAttendeeHeaderCell' style={ {width: '10%'} }></td>
							{ this.dtDATE_START
							? arrTimeRow
							: null
							}
							<td className='schedulerDeleteHeaderCell'></td>
						</tr>
						{ this.BuildInviteesRow() }
					</table>
				</div>
				<br />
			</React.Fragment>
			);
		}
		else
		{
			return null;
		}
	}
}

