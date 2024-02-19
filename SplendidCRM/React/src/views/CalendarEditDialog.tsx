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
import { RouteComponentProps, withRouter }          from '../Router5'                   ;
import { Modal }                                    from 'react-bootstrap'                    ;
// 2. Store and Types. 
import { EditComponent }                            from '../types/EditComponent'             ;
// 3. Scripts. 
import L10n                                         from '../scripts/L10n'                    ;
import Security                                     from '../scripts/Security'                ;
import SplendidDynamic_EditView                     from '../scripts/SplendidDynamic_EditView';
import { EditView_LoadLayout, EditView_UpdateREPEAT_TYPE, EditView_LoadItem } from '../scripts/EditView' ;
import { UpdateModule }                             from '../scripts/ModuleUpdate'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import DynamicButtons                               from '../components/DynamicButtons'       ;

interface ICalendarEditDialogProps extends RouteComponentProps<any>
{
	isOpen          : boolean;
	args            : any;
	callback?       : any;
}

interface ICalendarEditDialogState
{
	MODULE_NAME: string;
	item       : any;
	layout     : any;
	editedItem : any;
	dependents : Record<string, Array<any>>;
	error      : any;
}

class CalendarEditDialog extends React.Component<ICalendarEditDialogProps, ICalendarEditDialogState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<EditComponent<any, any>>>;
	private dynamicButtons = React.createRef<DynamicButtons>();

	constructor(props: ICalendarEditDialogProps)
	{
		super(props);
		this.state =
		{
			MODULE_NAME: 'Calls',
			item       : null,
			layout     : null,
			editedItem : null,
			dependents : {},
			error      : null
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			await this.load();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { args } = this.props;
		const { MODULE_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', args);
		try
		{
			let rowDefaultSearch: any = {};
			// 03/18/2020 Paul.  If we are providing defaults, then we need to provide user and team defaults. 
			rowDefaultSearch['ASSIGNED_SET_LIST'] = Security.USER_ID()  ;
			rowDefaultSearch['ASSIGNED_USER_ID'] = Security.USER_ID()  ;
			rowDefaultSearch['ASSIGNED_TO'     ] = Security.USER_NAME();
			rowDefaultSearch['ASSIGNED_TO_NAME'] = Security.FULL_NAME();
			rowDefaultSearch['TEAM_ID'         ] = Security.TEAM_ID()  ;
			rowDefaultSearch['TEAM_NAME'       ] = Security.TEAM_NAME();
			rowDefaultSearch['TEAM_SET_LIST'   ] = Security.TEAM_ID()  ;
			rowDefaultSearch['TEAM_SET_NAME'   ] = Security.TEAM_ID()  ;
			rowDefaultSearch['DURATION_MINUTES'] = 15;
			rowDefaultSearch['DURATION_HOURS'  ] = 0;
			rowDefaultSearch['SHOULD_REMIND'   ] = true;
			if ( args )
			{
				// 03/18/2020 Paul.  Start will be a moment.  
				rowDefaultSearch['DATE_START'      ] = args.start.toDate();
				if ( args.allDay )
				{
					rowDefaultSearch['DURATION_MINUTES'] = 0;
					rowDefaultSearch['DURATION_HOURS'  ] = 24;
					rowDefaultSearch['ALL_DAY_EVENT'   ] = true;

				}
				else
				{
					rowDefaultSearch['ALL_DAY_EVENT'   ] = false;
					let durationMinutes: number = ((args.end - args.start)/1000)/60;
					rowDefaultSearch['DURATION_MINUTES'] = durationMinutes % 60;
					rowDefaultSearch['DURATION_HOURS'  ] = Math.floor(durationMinutes / 60);
				}
			}
			let layout: any[] = EditView_LoadLayout(MODULE_NAME + '.EditView');
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				// 04/21/2020 Paul.  Show/Hide recurrence fields based on the type. 
				if ( rowDefaultSearch != null )
				{
					let REPEAT_TYPE: string = rowDefaultSearch['REPEAT_TYPE'];
					EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
				}
				this.setState(
				{
					layout    : layout,
					item      : rowDefaultSearch,
					editedItem: null
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			if ( DATA_FIELD == 'ALL_DAY_EVENT' && DATA_VALUE )
			{
				item['DURATION_MINUTES'] = 0;
				item['DURATION_HOURS'  ] = 24;
			}
			else if ( DATA_FIELD == 'DURATION_MINUTES' || DATA_FIELD == 'DURATION_HOURS' )
			{
				item['ALL_DAY_EVENT'] = false;
			}
			// 03/18/2020 Paul.  Show/Hide recurrence fields based on the type. 
			if ( DATA_FIELD == 'REPEAT_TYPE' )
			{
				let { layout } = this.state;
				let REPEAT_TYPE: string = DATA_VALUE;
				// 04/21/2020 Paul.  Show/Hide recurrence fields based on the type. 
				EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
				this.setState({ editedItem: item, layout });
			}
			else
			{
				this.setState({ editedItem: item });
			}
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				// 02/19/2021 Paul.  Use EditView buttons so that we can add send invites button. 
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				case 'Save.SendInvites':
				case 'NewRecord':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = { ID: null };
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						// 08/26/2019 Paul.  The layout field is DATE_START, but the stored procedure field is DATE_TIME.  Correct here. 
						row['DATE_TIME'] = row['DATE_START'];
						try
						{
							if ( this.dynamicButtons.current != null )
							{
								this.dynamicButtons.current.EnableButton(sCommandName, false);
							}
							row.ID = await UpdateModule(MODULE_NAME, row, null);
							// 01/23/2021 Paul.  Add send invites button. 
							if ( sCommandName == 'Save.SendInvites' )
							{
								let d: any = await EditView_LoadItem(MODULE_NAME, row.ID);
								let item: any = d.results;
								if ( item != null )
								{
									// 02/07/2021 Paul.  POST must send paramters in body. 
									let obj: any = { ModuleName: MODULE_NAME, ID: row.ID };
									let sBody: string = JSON.stringify(obj);
									let res = await CreateSplendidRequest('Rest.svc/SendActivityInvites', 'POST', 'application/json; charset=utf-8', sBody);
									let json = await GetSplendidResult(res);
								}
							}
							if ( this.dynamicButtons.current != null )
							{
								this.dynamicButtons.current.EnableButton(sCommandName, true);
							}
							this.props.callback(true);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this._isMounted )
							{
								if ( this.dynamicButtons.current != null )
								{
									this.dynamicButtons.current.EnableButton(sCommandName, true);
								}
								this.setState({ error });
							}
						}
					}
					break;
				}
				case 'Cancel':
				case 'NewRecord.Cancel':
				{
					this.props.callback(false);
					break;
				}
				default:
				{
					if ( this._isMounted )
					{
						this.setState( {error: sCommandName + ' is not supported at this time'} );
					}
					break;
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}
	private _onClose = () =>
	{
		this.props.callback();
	}

	private radScheduleCall_Checked = (e) =>
	{
		const { item } = this.state;
		let MODULE_NAME: string = 'Calls';
		let layout: any[] = EditView_LoadLayout(MODULE_NAME + '.EditView');
		// 04/21/2020 Paul.  Show/Hide recurrence fields based on the type. 
		let REPEAT_TYPE: string = item['REPEAT_TYPE'];
		EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
		this.setState({ MODULE_NAME, layout });
	}

	private radScheduleMeeting_Checked = (e) =>
	{
		const { item } = this.state;
		let MODULE_NAME: string = 'Meetings';
		let layout: any[] = EditView_LoadLayout(MODULE_NAME + '.EditView');
		// 04/21/2020 Paul.  Show/Hide recurrence fields based on the type. 
		let REPEAT_TYPE: string = item['REPEAT_TYPE'];
		EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
		this.setState({ MODULE_NAME, layout });
	}

	public render()
	{
		const { isOpen, args } = this.props;
		const { MODULE_NAME, item, layout, error } = this.state;

		let start  = '';
		let end    = '';
		let allDay = false;
		if ( args != null )
		{
			start  = args.start.toString();
			end    = args.end.toString();
			allDay = args.allDay.toString();
		}
		this.refMap = {};
		// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
		// 02/19/2021 Paul.  Use EditView buttons so that we can add send invites button. 
		return (
			<Modal show={ isOpen } onHide={ this._onClose }>
				<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
					<h2>{ L10n.Term(MODULE_NAME + '.LBL_NEW_FORM_TITLE') }</h2>
					<div>
						<DynamicButtons
							key={ MODULE_NAME + '.EditView' }
							ButtonStyle="EditHeader"
							VIEW_NAME={ MODULE_NAME + '.EditView' }
							row={ null }
							Page_Command={ this.Page_Command }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.dynamicButtons }
						/>
					</div>
					<div style={ {margin: '6px'} }>
						<input 
							id='divNewAppointmentPopup_radScheduleCall'
							key='divNewAppointmentPopup_radScheduleCall'
							type='radio'
							style={ {transform: 'scale(1.5', marginRight: '6px', marginTop: '2px', marginBottom: '6px'} }
							className='radio'
							checked={ MODULE_NAME == 'Calls' }
							onChange={ this.radScheduleCall_Checked }
						/>
						&nbsp;&nbsp;
						<label htmlFor='divNewAppointmentPopup_radScheduleCall'>{ L10n.Term('Calls.LNK_NEW_CALL') }</label>
						&nbsp; &nbsp;
						<input 
							id='divNewAppointmentPopup_radScheduleMeeting'
							key='divNewAppointmentPopup_radScheduleMeeting'
							type='radio'
							className='radio'
							style={ {transform: 'scale(1.5', marginRight: '6px', marginLeft: '12px', marginTop: '2px', marginBottom: '6px'} }
							checked={ MODULE_NAME == 'Meetings' }
							onChange={ this.radScheduleMeeting_Checked }
						/>
						&nbsp;&nbsp;
						<label htmlFor='divNewAppointmentPopup_radScheduleMeeting'>{ L10n.Term('Meetings.LNK_NEW_MEETING') }</label>
						&nbsp; &nbsp;
						<span className='error'>{ error }</span>
					</div>
					<div key={ 'divNewAppointmentPopup_' + MODULE_NAME }>
						{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, null, 'tabForm', this.Page_Command) }
					</div>
				</Modal.Body>
			</Modal>
		);
	}
}

export default withRouter(CalendarEditDialog);
