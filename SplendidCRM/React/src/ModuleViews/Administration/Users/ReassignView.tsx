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
import { RouteComponentProps }                      from 'react-router-dom'                             ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'               ;
import { observer }                                 from 'mobx-react'                                   ;
// 2. Store and Types. 
import MODULE                                       from '../../../types/MODULE'                        ;
import { EditComponent }                            from '../../../types/EditComponent'                 ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                         ;
import L10n                                         from '../../../scripts/L10n'                        ;
import Security                                     from '../../../scripts/Security'                    ;
import Credentials                                  from '../../../scripts/Credentials'                 ;
import SplendidCache                                from '../../../scripts/SplendidCache'               ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'             ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView'    ;
import { EditView_LoadLayout }                      from '../../../scripts/EditView'                    ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                         ;
import { Admin_GetReactState }                      from '../../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                       ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'           ;
import ListHeader                                   from '../../../components/ListHeader'               ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

const MODULE_NAME: string = 'Users';

interface IListViewProps extends RouteComponentProps<any>
{
	LAYOUT_NAME?          : string;
	RELATED_MODULE?       : string;
	GRID_NAME?            : string;
	TABLE_NAME?           : string;
	SORT_FIELD?           : string;
	SORT_DIRECTION?       : string;
	callback?             : Function;
	rowRequiredSearch?    : any;
	cbCustomLoad?         : (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) => any;
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IListViewState
{
	wizardMode            : string;
	error?                : any;
	ASSIGNED_USER_LIST    : string[];
	USER_FROM_ID          : string;
	USER_TO_ID            : string;
	TEAM_LIST             : string[];
	TEAM_ID               : string;
	MODULE_LIST           : string[];
	SELECTED_MODULES      : string[];
	layouts               : any;
	filters               : any;
	preview               : any;
	results               : any;
}

@observer
export default class UsersReassignView extends React.Component<IListViewProps, IListViewState>
{
	private _isMounted         = false;
	private headerButtons      = React.createRef<HeaderButtons>();
	private refMaps            : any;

	constructor(props: IListViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', MODULE_NAME);
		let archiveView: boolean = false;
		let GRID_NAME  : string = (props.LAYOUT_NAME ? props.LAYOUT_NAME : props.GRID_NAME);
		this.state =
		{
			wizardMode            : 'SelectUser',
			error                 : null,
			ASSIGNED_USER_LIST    : null,
			USER_FROM_ID          : null,
			USER_TO_ID            : null,
			TEAM_LIST             : null,
			TEAM_ID               : null,
			MODULE_LIST           : null,
			SELECTED_MODULES      : [],
			layouts               : {},
			filters               : {},
			preview               : null,
			results               : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'list') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				document.title = L10n.Term(MODULE_NAME + ".LBL_REASSIGN_TITLE");
				window.scroll(0, 0);

			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
			let MODULE_LIST       : string[] = [];
			let ASSIGNED_USER_LIST: string[] = L10n.GetList('AssignedUser');
			let TEAM_LIST         : string[] = L10n.GetList('Teams'       );
			let USER_FROM_ID      : string = null;
			let USER_TO_ID        : string = null;
			let layouts           : any    = {};
			if ( ASSIGNED_USER_LIST != null && ASSIGNED_USER_LIST.length > 0 )
			{
				USER_FROM_ID = ASSIGNED_USER_LIST[0];
				USER_TO_ID   = ASSIGNED_USER_LIST[0];
			}
			if ( SplendidCache.MODULES )
			{
				for ( let sMODULE in SplendidCache.MODULES )
				{
					let module: MODULE = SplendidCache.MODULES[sMODULE];
					// 06/26/2021 Paul.  Exclude BusinessProcesses. 
					if ( module.IS_ASSIGNED )
					{
						if ( module.MODULE_NAME != 'Activities'
						  && module.MODULE_NAME != 'BusinessRules'
						  && module.MODULE_NAME != 'CallMarketing'
						  && module.MODULE_NAME != 'RulesWizard'
						  && module.MODULE_NAME != 'ReportRules'
						  && module.MODULE_NAME != 'WorkflowAlertShells'
						  && module.MODULE_NAME != 'BusinessProcesses'
						   )
						{
							MODULE_LIST.push(module.MODULE_NAME);
							let layout: any = EditView_LoadLayout(module.MODULE_NAME + '.Reassign', true);
							if ( layout != null )
							{
								layouts[module.MODULE_NAME] = layout;
							}
						}
					}
				}
				MODULE_LIST.sort((a, b) => a.localeCompare(b))
			}
			this.setState(
			{
				ASSIGNED_USER_LIST ,
				USER_FROM_ID       ,
				USER_TO_ID         ,
				TEAM_LIST          ,
				MODULE_LIST        ,
				layouts            ,
			}, () =>
			{
				if ( this.props.onComponentComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, null, null);
				}
			});
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

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
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

	private _onSelectChange_FROM_USER = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let USER_FROM_ID: string = event.target.value;
		this.setState({ USER_FROM_ID });
	}

	private _onSelectChange_TO_USER = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let USER_TO_ID: string = event.target.value;
		this.setState({ USER_TO_ID });
	}

	private _onSelectChange_TEAM = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let TEAM_ID: string = event.target.value;
		this.setState({ TEAM_ID });
	}

	private _onSelectChange_MODULES = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		try
	{
			let selectedOptions = event.target.selectedOptions;
			let SELECTED_MODULES: any = [];
			for (let i = 0; i < selectedOptions.length; i++)
			{
				SELECTED_MODULES.push(selectedOptions[i].value);
			}
			this.setState({ SELECTED_MODULES });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange', error);
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
	}

	private _onFilterChange = (MODULE: string, DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + MODULE + '.' + DATA_FIELD, DATA_VALUE);
		let filters = this.state.filters;
		let item = filters[MODULE];
		if ( item == null || item === undefined )
		{
			item = {};
			filters[MODULE] = item;
		}
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ filters });
		}
	}

	private _onSubmit = async () =>
	{
		const { USER_FROM_ID, USER_TO_ID, TEAM_ID, SELECTED_MODULES, filters } = this.state;
		try
		{
			if ( SELECTED_MODULES.length == 0 )
			{
				throw(L10n.Term('Users.ERR_REASS_SELECT_MODULE'));
			}
			if ( USER_FROM_ID == USER_TO_ID )
			{
				throw(L10n.Term('Users.ERR_REASS_DIFF_USERS'));
			}
			this.setState(
			{
				error  : '', 
				preview: null,
				results: null
			});
			let obj: any =
			{
				USER_FROM_ID    ,
				USER_TO_ID      ,
				TEAM_ID         ,
				SELECTED_MODULES,
				filters         ,
			};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/ReassignRest.svc/PreviewRecordAssignments', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', json);
			this.setState(
			{
				wizardMode: 'Preview',
				preview   : json
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private _onClear = () =>
	{
		const { ASSIGNED_USER_LIST } = this.state;
		let USER_FROM_ID: string = '';
		let USER_TO_ID  : string = '';
		if ( ASSIGNED_USER_LIST != null && ASSIGNED_USER_LIST.length > 0 )
		{
			USER_FROM_ID = ASSIGNED_USER_LIST[0];
			USER_TO_ID   = ASSIGNED_USER_LIST[0];
		}
		this.setState(
		{
			wizardMode      : 'SelectUser',
			USER_FROM_ID    ,
			USER_TO_ID      ,
			TEAM_ID         : '',
			SELECTED_MODULES: [],
			filters         : {},
			preview         : null,
			results         : null
		});
	}

	private _onReassignContinue = async () =>
	{
		const { USER_FROM_ID, USER_TO_ID, TEAM_ID, SELECTED_MODULES, filters } = this.state;
		try
		{
			if ( SELECTED_MODULES.length == 0 )
			{
				throw(L10n.Term('Users.ERR_REASS_SELECT_MODULE'));
			}
			if ( USER_FROM_ID == USER_TO_ID )
			{
				throw(L10n.Term('Users.ERR_REASS_DIFF_USERS'));
			}
			this.setState(
			{
				error  : '', 
				preview: null,
				results: null
			});
			let obj: any =
			{
				USER_FROM_ID    ,
				USER_TO_ID      ,
				TEAM_ID         ,
				SELECTED_MODULES,
				filters         ,
			};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/ReassignRest.svc/ApplyRecordAssignments', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onReassignContinue', json);
			this.setState(
			{
				wizardMode: 'Results',
				results   : json
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onReassignContinue', error);
			this.setState({ error });
		}
	}

	private _onReassignGoBack = () =>
	{
		this.setState(
		{
			wizardMode: 'SelectUser',
			preview   : null,
			results   : null
		});
	}

	private _onReassignRestart = () =>
	{
		this._onClear();
	}

	private _onResultsReturn = () =>
	{
		this._onReassignGoBack();
	}

	public render()
	{
		const { wizardMode, layouts, filters, preview, results, error } = this.state;
		const { ASSIGNED_USER_LIST, USER_FROM_ID, USER_TO_ID, TEAM_LIST, TEAM_ID, MODULE_LIST, SELECTED_MODULES } = this.state;

		this.refMaps = {};
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', SplendidCache.IsInitialized);
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = 'Users.LBL_REASS_SCRIPT_TITLE';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			return (
			<div style={ {width: '100%'} }>
				<div id='divListView' style={ {width: '100%'} }>
					{ headerButtons
					? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error: null, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, showProcess: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
					: null
					}
				</div>
				<ErrorComponent error={ error } />
				{ wizardMode == 'SelectUser'
				? <div id='pnlSelectUser' style={ {width: '100%'} }>
					<div>{ L10n.Term('Users.LBL_REASS_DESC_PART1') }</div>
					<br />
					<table cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%;', border: 'none'} }>
						<tr>
							<td>
								<div>{ L10n.Term('Users.LBL_REASS_SELECT_USER') }</div>
								<table className="tabEditView" cellPadding={ 6 } style={ {border: 'none'} }>
									<tr>
										<td>
											<div>{ L10n.Term('Users.LBL_REASS_USER_FROM') }</div>
											<select
												id="ctlReassignView_lstFROM"
												value={ USER_FROM_ID }
												onChange={ this._onSelectChange_FROM_USER }
												>
												{ ASSIGNED_USER_LIST ?
													ASSIGNED_USER_LIST.map((item, index) =>
													{
														return (<option key={ 'from_' + item } value={ item }>{ L10n.ListTerm('AssignedUser', item) }</option>);
													})
												: null
												}
											</select>
										</td>
									</tr>
									<tr>
										<td>
											<div>{ L10n.Term('Users.LBL_REASS_USER_TO') }</div>
											<select
												id="ctlReassignView_lstTO"
												value={ USER_TO_ID }
												onChange={ this._onSelectChange_TO_USER }
												>
												{ ASSIGNED_USER_LIST ?
													ASSIGNED_USER_LIST.map((item, index) =>
													{
														return (<option key={ 'from_' + item } value={ item }>{ L10n.ListTerm('AssignedUser', item) }</option>);
													})
												: null
												}
											</select>
										</td>
									</tr>
									<tr id="ctl00_cntBody_ctlReassignView_trTeams">
										<td>
											<div>{ L10n.Term('Users.LBL_REASS_USER_TEAM') }</div>
											<select
												id="ctlReassignView_lstTEAM"
												value={ TEAM_ID }
												onChange={ this._onSelectChange_TEAM }
												>
													<option>{ L10n.Term('Users.LBL_REASS_NO_CHANGE') }</option>
												{ TEAM_LIST ?
													TEAM_LIST.map((item, index) =>
													{
														return (<option key={ 'from_' + item } value={ item }>{ L10n.ListTerm('Teams', item) }</option>);
													})
												: null
												}
											</select>
										</td>
									</tr>
									<tr>
										<td>
											<div>{ L10n.Term('Users.LBL_REASS_MOD_REASSIGN') }</div>
											<select
												id="ctlReassignView_lstMODULES"
												size={ 6 }
												multiple={ true }
												value={ SELECTED_MODULES }
												onChange={ this._onSelectChange_MODULES }
												>
												{ MODULE_LIST ?
													MODULE_LIST.map((item, index) =>
													{
														return (<option key={ 'from_' + item } value={ item }>{ L10n.ListTerm('moduleList', item) }</option>);
													})
												: null
												}
											</select>
										</td>
									</tr>
								</table>
								<br />
								<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_SUBMIT") } className="button" onClick={ this._onSubmit } />&nbsp;
								<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_CLEAR" ) } className="button" onClick={ this._onClear  } /><br />
							</td>
						</tr>
					</table>
				</div>
				: null
				}
				{ wizardMode == 'SelectUser'
				? <div id='pnlFilters' style={ {width: '100%'} }>
					{ SELECTED_MODULES ?
						SELECTED_MODULES.map((MODULE, index) =>
						{
							if ( layouts[MODULE] )
							{
								this.refMaps[MODULE] = {};
								return (<div>
									<div style={ {fontWeight: 'bold', marginTop: '4px'} }>{ L10n.Term('Users.LBL_REASS_FILTERS').replace('{0}', L10n.ListTerm('moduleList', MODULE)) }</div>
									<div className='tabSearchForm'>
										{ SplendidDynamic_EditView.AppendEditViewFields(filters[MODULE], layouts[MODULE], this.refMaps[MODULE], null, this._createDependency, null, (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => this._onFilterChange(MODULE, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE), this._onUpdate, null, null, this.Page_Command, true) }
									</div>
								</div>);
							}
							return null;
						})
					: null
					}
				</div>
				: null
				}
				{ wizardMode == 'Preview'
				? <div id='pnlReassignment' style={ {width: '100%'} }>
					<div>{ L10n.Term('Users.LBL_REASS_NOTES_TITLE') }</div>
					{ SELECTED_MODULES ?
						SELECTED_MODULES.map((MODULE, index) =>
						{
							if ( preview && preview[MODULE] )
							{
								return (<div>
									<h5>{ L10n.ListTerm('moduleList', MODULE) }</h5>
									<div className='tabDetailViewDF'>
										{ preview[MODULE].Updated
										? <div>{ preview[MODULE].Updated }</div>
										: null
										}
										{ preview[MODULE].Error
										? <div className='error'>{ preview[MODULE].Error }</div>
										: null
										}
										{ Crm_Config.ToBoolean('show_sql')
										? <pre>{ preview[MODULE].__sql }</pre>
										: null
										}
									</div>
								</div>);
							}
							return null;
						})
					: null
					}
					<br />
					<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_CONTINUE") } className="button" onClick={ this._onReassignContinue } />&nbsp;
					<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_GO_BACK" ) } className="button" onClick={ this._onReassignGoBack   } />&nbsp;
					<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_RESTART" ) } className="button" onClick={ this._onReassignRestart  } /><br />
				</div>
				: null
				}
				{ wizardMode == 'Results'
				? <div id='pnlResults' style={ {width: '100%'} }>
					{ SELECTED_MODULES ?
						SELECTED_MODULES.map((MODULE, index) =>
						{
							if ( results && results[MODULE] )
							{
								return (<div>
									<h5>{ L10n.ListTerm('moduleList', MODULE) }</h5>
									<div className='tabDetailViewDF'>
										{ results[MODULE].Updated
										? <div>{ results[MODULE].Updated }</div>
										: null
										}
										{ results[MODULE].Error
										? <div className='error'>{ results[MODULE].Error }</div>
										: null
										}
										{ Crm_Config.ToBoolean('show_sql')
										? <pre>{ results[MODULE].__sql }</pre>
										: null
										}
									</div>
								</div>);
							}
							return null;
						})
					: null
					}
					<br />
					<input type="submit" value={ L10n.Term("Users.LBL_REASS_BUTTON_RETURN" ) } className="button" onClick={ this._onResultsReturn } /><br />
				</div>
				: null
				}
			</div>
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}
