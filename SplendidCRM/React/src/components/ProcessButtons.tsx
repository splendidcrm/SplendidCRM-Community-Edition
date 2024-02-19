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
import { RouteComponentProps, withRouter } from '../Router5'            ;
import { Modal }                           from 'react-bootstrap'             ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'              ;
import L10n                                from '../scripts/L10n'             ;
import Security                            from '../scripts/Security'         ;
import SplendidCache                       from '../scripts/SplendidCache'    ;
import { FromJsonDate }                    from '../scripts/Formatting'       ;
import { ProcessButtons_GetProcessStatus, ProcessButtons_ProcessAction, ProcessButtons_GetProcessHistory, ProcessButtons_GetProcessNotes, ProcessButtons_DeleteProcessNote, ProcessButtons_AddProcessNote } from '../scripts/ProcessButtons';
// 4. Components and Views. 
import ErrorComponent                      from '../components/ErrorComponent';
import PopupView                           from '../views/PopupView'          ;

const icon = require('../assets/img/SplendidCRM_Icon.gif');

interface IProcessButtonsProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID                : string;
	PENDING_PROCESS_ID: string;
}

interface IProcessButtonsState
{
	process           : any;
	popupOpen         : boolean;
	modalCommand      : string;
	showHistory       : boolean;
	history           : any[];
	historyTitle      : string;
	showNotes         : boolean;
	notes             : any[];
	notesTitle        : string;
	NOTE              : string;
	notesError?       : string;
	error?            : any;
}

class ProcessButtons extends React.Component<IProcessButtonsProps, IProcessButtonsState>
{
	private _isMounted           = false;

	constructor(props: IProcessButtonsProps)
	{
		super(props);
		this.state =
		{
			process     : null,
			popupOpen   : false,
			modalCommand: null,
			showHistory : false,
			history     : null,
			historyTitle: null,
			showNotes   : false,
			notes       : null,
			notesTitle  : null,
			NOTE        : null,
			notesError  : null,
			error       : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		await this.Load();
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private Load = async () =>
	{
		const { PENDING_PROCESS_ID } = this.props;
		if ( !Sql.IsEmptyGuid(PENDING_PROCESS_ID) )
		{
			try
			{
				let message = await ProcessButtons_GetProcessStatus(PENDING_PROCESS_ID);
				if ( message != null && message.length > 0 )
				{
					this.setState({ process: message[0] });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load ', error);
				this.setState({ error: error });
			}
		}
	}

	private CreateButton = (sKEY: string, sCONTROL_TYPE: string, sMODULE_NAME: string, sCONTROL_TEXT: string, sCONTROL_TOOLTIP: string, sCONTROL_CSSCLASS: string, sTEXT_FIELD: string, sARGUMENT_FIELD: string, sCOMMAND_NAME: string, sURL_FORMAT: string, sURL_TARGET: string, ONCLICK_SCRIPT: string, bHIDDEN: boolean, nMODULE_ACLACCESS: number, nTARGET_ACLACCESS: number) =>
	{
		let oARGUMENT_VALUE = new Object();
		let btnProps: any = { key: sKEY, type: 'submit', style: { marginRight: '2px', marginBottom: '2px', whiteSpace: 'nowrap' } };
		btnProps.style.display = (bHIDDEN ? 'none' : 'inline');
		btnProps.className = 'button ' + sCONTROL_CSSCLASS;
		btnProps.onClick = () =>
		{
			this.Page_Command(sCOMMAND_NAME, oARGUMENT_VALUE);
		};
		let btn = React.createElement('buton', btnProps, L10n.Term(sCONTROL_TEXT));
		return btn;
	}

	private LoadButtons = () =>
	{
		const { MODULE_NAME, ID, } = this.props;
		const { process } = this.state;
		let style : any = {};
		let sCONTROL_CSSCLASS: string = '';
		let sTheme: string  = SplendidCache.UserTheme;
		if ( sTheme == 'Pacific' )
		{
			style.textAlign = 'right';
		}
		let pnlProcessButtonsChildren = [];
		let pnlProcessButtons         = React.createElement('div', { id: 'pnlProcessButtons', key: 'pnlProcessButtons', className: 'button-panel', style }, pnlProcessButtonsChildren);

		try
		{
			let PENDING_PROCESS_ID: string  = Sql.ToGuid   (process['PENDING_PROCESS_ID']);
			let ProcessStatus     : string  = Sql.ToString (process['ProcessStatus'     ]);
			let ShowApprove       : boolean = Sql.ToBoolean(process['ShowApprove'       ]);
			let ShowReject        : boolean = Sql.ToBoolean(process['ShowReject'        ]);
			let ShowRoute         : boolean = Sql.ToBoolean(process['ShowRoute'         ]);
			let ShowClaim         : boolean = Sql.ToBoolean(process['ShowClaim'         ]);
			let USER_TASK_TYPE    : string  = Sql.ToString (process['USER_TASK_TYPE'    ]);
			let PROCESS_USER_ID   : string  = Sql.ToGuid   (process['PROCESS_USER_ID'   ]);
			let ASSIGNED_TEAM_ID  : string  = Sql.ToGuid   (process['ASSIGNED_TEAM_ID'  ]);
			let PROCESS_TEAM_ID   : string  = Sql.ToGuid   (process['PROCESS_TEAM_ID'   ]);

			let sVIEW_NAME = 'Processes.DetailView';
			if ( USER_TASK_TYPE == 'Route' )
			{
				sVIEW_NAME = 'Processes.DetailView.Route';
			}
			if ( Sql.IsEmptyGuid(PROCESS_USER_ID) )
			{
				sVIEW_NAME = 'Processes.DetailView.Claim';
			}

			let bEditHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
				bEditHIDDEN = false;
			let btnEdit = this.CreateButton(
				'pnlProcessButtons_btnEdit' // sKEY: string
				, 'ButtonLink'              // sCONTROL_TYPE: string
				, MODULE_NAME               // sMODULE_NAME: string
				, '.LBL_EDIT_BUTTON_LABEL'  // sCONTROL_TEXT: string
				, '.LBL_EDIT_BUTTON_TITLE'  // sCONTROL_TOOLTIP: string
				, ''                        // sCONTROL_CSSCLASS: string
				, 'ID'                      // sTEXT_FIELD: string
				, null                      // sARGUMENT_FIELD: string
				, 'Edit'                    // sCOMMAND_NAME: string
				, null                      // sURL_FORMAT: string
				, null                      // sURL_TARGET: string
				, null                      // ONCLICK_SCRIPT: string
				, bEditHIDDEN               // bHIDDEN: boolean
				, 0                         // nMODULE_ACLACCESS: number
				, 0                         // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnEdit);

			let bCancelHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView.Claim')
				bCancelHIDDEN = false;
			let btnCancel = this.CreateButton(
				'pnlProcessButtons_btnCancel' // sKEY: string
				, 'ButtonLink'                // sCONTROL_TYPE: string
				, MODULE_NAME                 // sMODULE_NAME: string
				, '.LBL_CANCEL_BUTTON_LABEL'  // sCONTROL_TEXT: string
				, '.LBL_CANCEL_BUTTON_TITLE'  // sCONTROL_TOOLTIP: string
				, ''                          // sCONTROL_CSSCLASS: string
				, 'ID'                        // sTEXT_FIELD: string
				, null                        // sARGUMENT_FIELD: string
				, 'Cancel'                    // sCOMMAND_NAME: string
				, null                        // sURL_FORMAT: string
				, null                        // sURL_TARGET: string
				, null                        // ONCLICK_SCRIPT: string
				, bCancelHIDDEN               // bHIDDEN: boolean
				, 0                           // nMODULE_ACLACCESS: number
				, 0                           // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnCancel);

			let bShowHistoryHIDDEN = false;
			let btnShowHistory = this.CreateButton(
				'pnlProcessButtons_btnShowHistory' // sKEY: string
				, 'Button'                         // sCONTROL_TYPE: string
				, MODULE_NAME                      // sMODULE_NAME: string
				, 'Processes.LBL_HISTORY'          // sCONTROL_TEXT: string
				, 'Processes.LBL_HISTORY'          // sCONTROL_TOOLTIP: string
				, ''                               // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'             // sTEXT_FIELD: string
				, null                             // sARGUMENT_FIELD: string
				, 'Processes.ShowHistory'          // sCOMMAND_NAME: string
				, null                             // sURL_FORMAT: string
				, null                             // sURL_TARGET: string
				, null                             // ONCLICK_SCRIPT: string
				, bShowHistoryHIDDEN               // bHIDDEN: boolean
				, 0                                // nMODULE_ACLACCESS: number
				, 0                                // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnShowHistory);

			let bShowNotesHIDDEN = false;
			let btnShowNotes = this.CreateButton(
				'pnlProcessButtons_btnShowNotes' // sKEY: string
				, 'Button'                       // sCONTROL_TYPE: string
				, MODULE_NAME                    // sMODULE_NAME: string
				, 'Processes.LBL_NOTES'          // sCONTROL_TEXT: string
				, 'Processes.LBL_NOTES'          // sCONTROL_TOOLTIP: string
				, ''                             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'           // sTEXT_FIELD: string
				, null                           // sARGUMENT_FIELD: string
				, 'Processes.ShowNotes'          // sCOMMAND_NAME: string
				, null                           // sURL_FORMAT: string
				, null                           // sURL_TARGET: string
				, null                           // ONCLICK_SCRIPT: string
				, bShowNotesHIDDEN               // bHIDDEN: boolean
				, 0                              // nMODULE_ACLACCESS: number
				, 0                              // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnShowNotes);

			let bSelectAssignedUserHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
			{
				bSelectAssignedUserHIDDEN = (!Sql.IsEmptyGuid(ASSIGNED_TEAM_ID) && PROCESS_USER_ID == Security.USER_ID() ? false : true);
			}
			let btnSelectAssignedUser = this.CreateButton(
				'pnlProcessButtons_btnSelectAssignedUser' // sKEY: string
				, 'Button'                                // sCONTROL_TYPE: string
				, MODULE_NAME                             // sMODULE_NAME: string
				, 'Processes.LBL_CHANGE_ASSIGNED_USER'    // sCONTROL_TEXT: string
				, 'Processes.LBL_CHANGE_ASSIGNED_USER'    // sCONTROL_TOOLTIP: string
				, ''                                      // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'                    // sTEXT_FIELD: string
				, null                                    // sARGUMENT_FIELD: string
				, 'Processes.SelectAssignedUser'          // sCOMMAND_NAME: string
				, null                                    // sURL_FORMAT: string
				, null                                    // sURL_TARGET: string
				, null                                    // ONCLICK_SCRIPT: string
				, bSelectAssignedUserHIDDEN               // bHIDDEN: boolean
				, 0                                       // nMODULE_ACLACCESS: number
				, 0                                       // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnSelectAssignedUser);

			let bSelectProcessUserHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
			{
				bSelectProcessUserHIDDEN = (!Sql.IsEmptyGuid(PROCESS_TEAM_ID) && PROCESS_USER_ID == Security.USER_ID() ? false : true);
			}
			let btnSelectProcessUser = this.CreateButton(
				'pnlProcessButtons_btnSelectProcessUser' // sKEY: string
				, 'Button'                               // sCONTROL_TYPE: string
				, MODULE_NAME                            // sMODULE_NAME: string
				, 'Processes.LBL_CHANGE_PROCESS_USER'    // sCONTROL_TEXT: string
				, 'Processes.LBL_CHANGE_PROCESS_USER'    // sCONTROL_TOOLTIP: string
				, ''                                     // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'                   // sTEXT_FIELD: string
				, null                                   // sARGUMENT_FIELD: string
				, 'Processes.SelectProcessUser'          // sCOMMAND_NAME: string
				, null                                   // sURL_FORMAT: string
				, null                                   // sURL_TARGET: string
				, null                                   // ONCLICK_SCRIPT: string
				, bSelectProcessUserHIDDEN               // bHIDDEN: boolean
				, 0                                      // nMODULE_ACLACCESS: number
				, 0                                      // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnSelectProcessUser);

			let bApproveHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bApproveHIDDEN = (ShowApprove ? false : true);
			}
			let btnApprove = this.CreateButton(
				'pnlProcessButtons_btnApprove' // sKEY: string
				, 'Button'                     // sCONTROL_TYPE: string
				, MODULE_NAME                  // sMODULE_NAME: string
				, 'Processes.LBL_APPROVE'      // sCONTROL_TEXT: string
				, 'Processes.LBL_APPROVE'      // sCONTROL_TOOLTIP: string
				, 'ProcessApprove'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'         // sTEXT_FIELD: string
				, null                         // sARGUMENT_FIELD: string
				, 'Processes.Approve'          // sCOMMAND_NAME: string
				, null                         // sURL_FORMAT: string
				, null                         // sURL_TARGET: string
				, null                         // ONCLICK_SCRIPT: string
				, bApproveHIDDEN               // bHIDDEN: boolean
				, 0                            // nMODULE_ACLACCESS: number
				, 0                            // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnApprove);

			let bRejectHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bRejectHIDDEN = (ShowReject ? false : true);
			}
			let btnReject = this.CreateButton(
				'pnlProcessButtons_btnReject' // sKEY: string
				, 'Button'                    // sCONTROL_TYPE: string
				, MODULE_NAME                 // sMODULE_NAME: string
				, 'Processes.LBL_REJECT'      // sCONTROL_TEXT: string
				, 'Processes.LBL_REJECT'      // sCONTROL_TOOLTIP: string
				, 'ProcessReject'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'        // sTEXT_FIELD: string
				, null                        // sARGUMENT_FIELD: string
				, 'Processes.Reject'          // sCOMMAND_NAME: string
				, null                        // sURL_FORMAT: string
				, null                        // sURL_TARGET: string
				, null                        // ONCLICK_SCRIPT: string
				, bRejectHIDDEN               // bHIDDEN: boolean
				, 0                           // nMODULE_ACLACCESS: number
				, 0                           // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnReject);

			let bRouteHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bRouteHIDDEN = (ShowRoute ? false : true);
			}
			let btnRoute = this.CreateButton(
				'pnlProcessButtons_btnRoute' // sKEY: string
				, 'Button'                   // sCONTROL_TYPE: string
				, MODULE_NAME                // sMODULE_NAME: string
				, 'Processes.LBL_ROUTE'      // sCONTROL_TEXT: string
				, 'Processes.LBL_ROUTE'      // sCONTROL_TOOLTIP: string
				, 'ProcessRoute'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'       // sTEXT_FIELD: string
				, null                       // sARGUMENT_FIELD: string
				, 'Processes.Route'          // sCOMMAND_NAME: string
				, null                       // sURL_FORMAT: string
				, null                       // sURL_TARGET: string
				, null                       // ONCLICK_SCRIPT: string
				, bRouteHIDDEN               // bHIDDEN: boolean
				, 0                          // nMODULE_ACLACCESS: number
				, 0                          // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnRoute);

			let bClaimHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bClaimHIDDEN = (ShowClaim ? false : true);
			}
			let btnClaim = this.CreateButton(
				'pnlProcessButtons_btnClaim' // sKEY: string
				, 'Button'                   // sCONTROL_TYPE: string
				, MODULE_NAME                // sMODULE_NAME: string
				, 'Processes.LBL_CLAIM'      // sCONTROL_TEXT: string
				, 'Processes.LBL_CLAIM'      // sCONTROL_TOOLTIP: string
				, 'ProcessClaim'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'       // sTEXT_FIELD: string
				, null                       // sARGUMENT_FIELD: string
				, 'Processes.Claim'          // sCOMMAND_NAME: string
				, null                       // sURL_FORMAT: string
				, null                       // sURL_TARGET: string
				, null                       // ONCLICK_SCRIPT: string
				, bClaimHIDDEN               // bHIDDEN: boolean
				, 0                          // nMODULE_ACLACCESS: number
				, 0                          // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnClaim);

			// 08/20/2016 Paul.  Change to a span so that it can be placed side-by-side with another button panel. 
			// 06/15/2017 Paul.  Use Bootstrap for responsive design.
			//if ( !SplendidDynamic.BootstrapLayout() )
			//	pnlProcessButtons.style.display = 'inline-block';
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ProcessStatus', ProcessStatus);
			let txtProcessStatus = React.createElement('div', { key: this.constructor.name + '.ProcessStatus', className: 'ProcessStatus', style: {display: 'block', width: '100%'}, dangerouslySetInnerHTML: {__html: ProcessStatus} });
			pnlProcessButtonsChildren.push(txtProcessStatus);
			// 04/19/2017 Paul.  The status will include HTML formatting. 
			//txtProcessStatus.appendChild(document.createTextNode(this.ProcessStatus));
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadButtons ', error);
		}
		return pnlProcessButtons;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, ID, PENDING_PROCESS_ID, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments)
		if ( sCommandName == 'Edit' )
		{
			history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
		}
		else if ( sCommandName == 'Cancel' )
		{
			history.push(`/Reset/${MODULE_NAME}/List`);
		}
		else if ( sCommandName == 'Processes.Approve' )
		{
			await ProcessButtons_ProcessAction('Approve', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Reject' )
		{
			await ProcessButtons_ProcessAction('Reject', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Route' )
		{
			await ProcessButtons_ProcessAction('Route', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Claim' )
		{
			await ProcessButtons_ProcessAction('Claim', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Cancel' )
		{
			await ProcessButtons_ProcessAction('Cancel', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.SelectProcessUser' )
		{
			this.setState({ popupOpen: true, modalCommand: sCommandName });
		}
		else if ( sCommandName == 'Processes.SelectAssignedUser' )
		{
			this.setState({ popupOpen: true, modalCommand: sCommandName });
		}
		else if ( sCommandName == 'Processes.ShowHistory' )
		{
			try
			{
				let d = await ProcessButtons_GetProcessHistory(PENDING_PROCESS_ID);
				this.setState({ showHistory: true, history: d.results, historyTitle: d.__title });
			}
			catch(error)
			{
				this.setState({ error });
			}
		}
		else if ( sCommandName == 'Processes.ShowNotes' )
		{
			try
			{
				let d = await ProcessButtons_GetProcessNotes(PENDING_PROCESS_ID);
				this.setState({ showNotes: true, notes: d.results, notesTitle: d.__title });
			}
			catch(error)
			{
				this.setState({ error });
			}
		}
		else
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command Unknown command', sCommandName)
			this.setState({ error: sCommandName + ' not supported' });
		}
	}

	private _onSelect = (value: { Action: string, ID: string, NAME: string, PROCESS_NOTES: string }) =>
	{
		const { PENDING_PROCESS_ID } = this.props;
		const { modalCommand } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', value);
		if ( value.Action == 'SingleSelect' )
		{
			let sCommandName = modalCommand;
			this.setState({ popupOpen: false, modalCommand: null }, async () =>
			{
				try
				{
					if ( sCommandName == 'Processes.SelectProcessUser' )
					{
						await ProcessButtons_ProcessAction('ChangeProcessUser', PENDING_PROCESS_ID, value.ID, value.PROCESS_NOTES);
						await this.Load();
					}
					else if ( sCommandName == 'Processes.SelectAssignedUser' )
					{
						await ProcessButtons_ProcessAction('ChangeAssignedUser', PENDING_PROCESS_ID, value.ID, value.PROCESS_NOTES);
						await this.Load();
					}
				}
				catch(error)
				{
					this.setState({ error: error });
				}
			});
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onCloseHistory = () =>
	{
		if ( this._isMounted )
		{
			this.setState( {showHistory: false} );
		}
	}

	private _onCloseNotes = () =>
	{
		if ( this._isMounted )
		{
			this.setState( {showNotes: false} );
		}
	}

	private _onChangeNote = (NOTE) =>
	{
		if ( this._isMounted )
		{
			this.setState({ NOTE });
		}
	}

	private _onDeleteNote = async (PROCESS_NOTE_ID) =>
	{
		try
		{
			await ProcessButtons_DeleteProcessNote(PROCESS_NOTE_ID);
			await this.Page_Command('Processes.ShowNotes', null);
		}
		catch(error)
		{
			this.setState({ notesError: error });
		}
		return false;
	}

	private _onAddNote = async () =>
	{
		const { PENDING_PROCESS_ID } = this.props;
		const { NOTE } = this.state;
		try
		{
			await ProcessButtons_AddProcessNote(PENDING_PROCESS_ID, NOTE);
			await this.Page_Command('Processes.ShowNotes', null);
			this.setState({ NOTE: '' });
		}
		catch(error)
		{
			this.setState({ notesError: error });
		}
	}

	public render()
	{
		const { process, error, popupOpen, showHistory, history, historyTitle, showNotes, notes, notesTitle, NOTE, notesError } = this.state;
		return process && (
			<div>
				{ this.LoadButtons() }
				<ErrorComponent error={ error } />
				<PopupView
					isOpen={ popupOpen }
					callback={ this._onSelect }
					MODULE_NAME='Users'
					showProcessNotes={ true }
				/>
				<Modal show={ showHistory } onHide={ this._onCloseHistory }>
					<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
					{ showHistory && history
					? <div>
						<h3>{ historyTitle }</h3>
						{ history.map((item, index) => 
							{
								return (
								<div style={ {display: 'table-row'} }>
									<div style={ { display: 'table-cell', width: '1%', verticalAlign: 'top', paddingTop: '6px', paddingRight: '4px'} }>
										{ !Sql.IsEmptyString(item['PICTURE']) && !Sql.IsEmptyGuid(item['CREATED_BY_ID'])
										? <img src={ item['PICTURE'] } style={ {width: '36px', height: '36px', borderRadius: '4px'} } />
										: null
										}
										{ Sql.IsEmptyString(item['PICTURE']) && !Sql.IsEmptyGuid(item['CREATED_BY_ID'])
										? <img src={ icon } style={ {width: '36px', height: '36px', borderRadius: '4px'} } />
										: null
										}
										{ Sql.IsEmptyGuid(item['CREATED_BY_ID'])
										? <div className='ModuleHeaderModule ModuleHeaderModuleBusinessProcesses ListHeaderModule'>BP</div>
										: null
										}
									</div>
									<div style={ {display: 'table-cell', width: '85%', verticalAlign: 'top', paddingTop: '6px', paddingRight: '4px'} }>
										<div dangerouslySetInnerHTML={ {__html: item['DESCRIPTION']} }></div>
										<div style={ {color: '#777', paddingTop: '4px'} }>{ FromJsonDate(item['DATE_ENTERED'], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT()) }</div>
									</div>
									<div style={ {display: 'table-cell', width: '14%', verticalAlign: 'top', paddingTop: '6px'} }>
										<div>{ item['TIME_FROM_NOW'] }</div>
									</div>
								</div>
								);
							})
						}
					</div>
					: null
					}
					</Modal.Body>
					<Modal.Footer>
						<button className='button' onClick={ this._onCloseHistory }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
					</Modal.Footer>
				</Modal>
				<Modal show={ showNotes } onHide={ this._onCloseNotes }>
					<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
					{ showNotes && notes
					? <div>
						<h3>{ notesTitle }</h3>
						<div style={ {display: 'table', width: '100%'} }>
							<div style={ {display: 'table-row'} }>
								<div style={ {display: 'table-cell', width: '85%'} }>
									<textarea value={ NOTE } onChange={ (e) => this._onChangeNote(e.target.value) } rows={ 2 } style={ {width: '98%'} } autoComplete='off' />
								</div>
								<div style={ {display: 'table-cell', width: '15%', textAlign: 'left', verticalAlign: 'middle'} }>
									<input onClick={ this._onAddNote } type='submit' value={ L10n.Term('Processes.LBL_ADD_NOTES') } className='ProcessAddNotes' />
								</div>
							</div>
						</div>
						<ErrorComponent error={ notesError } />
						<br />
						{ notes.map((item, index) => 
							{
								return (
								<div style={ {display: 'table-row'} }>
									<div style={ { display: 'table-cell', width: '1%', verticalAlign: 'top', paddingTop: '6px', paddingRight: '4px'} }>
										{ !Sql.IsEmptyString(item['PICTURE'])
										? <img src={ item['PICTURE'] } style={ {width: '36px', height: '36px', borderRadius: '4px'} } />
										: null
										}
										{ Sql.IsEmptyString(item['PICTURE'])
										? <img src={ icon } style={ {width: '36px', height: '36px', borderRadius: '4px'} } />
										: null
										}
									</div>
									<div style={ {display: 'table-cell', width: '85%', verticalAlign: 'top', paddingTop: '6px', paddingRight: '4px'} }>
										<div><b>{ item['CREATED_BY_NAME'] }</b> -<span dangerouslySetInnerHTML={ {__html: item['DESCRIPTION']} }></span></div>
										<div style={ {color: '#777', paddingTop: '4px'} }>{ FromJsonDate(item['DATE_ENTERED'], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT()) }</div>
									</div>
									<div style={ {display: 'table-cell', width: '14%', verticalAlign: 'top', paddingTop: '6px'} }>
										<div>{ item['TIME_FROM_NOW'] }</div>
										<div>
											<a href='#' onClick={ (e) => { e.preventDefault(); return this._onDeleteNote(item['ID']); } } type='button' className='listViewTdToolsS1'>{ L10n.Term('.LBL_DELETE_BUTTON_LABEL') }</a>
										</div>
									</div>
								</div>
								);
							})
						}
					</div>
					: null
					}
					</Modal.Body>
					<Modal.Footer>
						<button className='button' onClick={ this._onCloseNotes }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
					</Modal.Footer>
				</Modal>
			</div>
		);
	}
}

export default withRouter(ProcessButtons);
