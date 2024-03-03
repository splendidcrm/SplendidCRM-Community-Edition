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
import React from 'react';
import qs from 'query-string';
import { RouteComponentProps, withRouter }          from '../Router5'                       ;
import { Modal, ModalTitle }                        from 'react-bootstrap'                        ;
import { observer }                                 from 'mobx-react'                             ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'         ;
import * as XMLParser                               from 'fast-xml-parser'                        ;
// 2. Store and Types. 
import { EditComponent }                            from '../types/EditComponent'                 ;
import { HeaderButtons }                            from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                         ;
import L10n                                         from '../scripts/L10n'                        ;
import Security                                     from '../scripts/Security'                    ;
import Credentials                                  from '../scripts/Credentials'                 ;
import SplendidCache                                from '../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                     from '../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                  from '../scripts/Crm'                         ;
import { StartsWith, EndsWith }                     from '../scripts/utility'                     ;
import { AuthenticatedMethod, LoginRedirect }       from '../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                         from '../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout }   from '../scripts/EditView'                    ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'             ;
import { jsonReactState }                           from '../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent'           ;
import DumpSQL                                      from '../components/DumpSQL'                  ;
import DynamicButtons                               from '../components/DynamicButtons'           ;
import HeaderButtonsFactory                         from '../ThemeComponents/HeaderButtonsFactory';
import QueryDesigner                                from './QueryDesigner'                        ;
import ReportView                                   from '../views/ReportView'                    ;

let MODULE_NAME: string = 'Reports';

interface IEditViewProps extends RouteComponentProps<any>
{
	ID?                : string;
	LAYOUT_NAME?       : string;
	rowDefaultSearch?  : any;
	onLayoutLoaded?    : any;
	onSubmit?          : any;
	DuplicateID?       : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__sql              : string ;
	item               : any   ;
	layout             : any    ;
	EDIT_NAME          : string ;
	DUPLICATE          : boolean;
	LAST_DATE_MODIFIED : Date   ;
	SUB_TITLE          : any    ;
	editedItem         : any    ;
	dependents         : Record<string, Array<any>>;
	showReportPopup    : boolean;
	error              : any    ;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class ReportEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private queryDesigner = React.createRef<QueryDesigner>();

	public get data (): any
	{
		let row: any = {};
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 04/01/2020 Paul.  We need to include the ReportDesign, which may not have been edited, so could be in item, or editedItem. 
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row);
		return currentItem;
	}

	public validate(): boolean
	{
		let row: any = {};
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row);
		let sPAGE_WIDTH      : string  = Sql.ToString(currentItem['PAGE_WIDTH' ]).toLowerCase();
		let sPAGE_HEIGHT     : string  = Sql.ToString(currentItem['PAGE_HEIGHT']).toLowerCase();
		let bValidWidthUnits : boolean = false;
		let bValidHeightUnits: boolean = false;
		if ( !Sql.IsEmptyString(sPAGE_WIDTH) && (EndsWith(sPAGE_WIDTH, 'in') || EndsWith(sPAGE_WIDTH, 'cm') || EndsWith(sPAGE_WIDTH, 'mm') || EndsWith(sPAGE_WIDTH, 'pt') || EndsWith(sPAGE_WIDTH, 'pc')) )
		{
			bValidWidthUnits = true;
		}
		if ( !Sql.IsEmptyString(sPAGE_HEIGHT) && (EndsWith(sPAGE_HEIGHT, 'in') || EndsWith(sPAGE_HEIGHT, 'cm') || EndsWith(sPAGE_HEIGHT, 'mm') || EndsWith(sPAGE_HEIGHT, 'pt') || EndsWith(sPAGE_HEIGHT, 'pc')) )
		{
			bValidHeightUnits = true;
		}
		if ( !bValidWidthUnits || !bValidHeightUnits )
		{
			nInvalidFields++;
			this.setState({ error: L10n.Term('ReportDesigner.ERR_INVALID_REPORT_UNITS') })
		}
		else if ( this.queryDesigner.current != null && !this.queryDesigner.current.validate() )
		{
			this.setState({ error: this.queryDesigner.current.error() });
		}
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IEditViewProps)
	{
		super(props);
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__sql             : null,
			item              ,
			layout            : null,
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			editedItem        : null,
			dependents        : {},
			showReportPopup   : false,
			error             : null
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
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				await this.load();
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset ' + this.state.EDIT_NAME, this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { ID, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) )
			{
				// 03/19/2020 Paul.  If we initialize rowDefaultSearch, then we need to set assigned and team values. 
				rowDefaultSearch = {};
				rowDefaultSearch['ASSIGNED_SET_LIST'] = Security.USER_ID()  ;
				rowDefaultSearch['ASSIGNED_USER_ID'] = Security.USER_ID()  ;
				rowDefaultSearch['ASSIGNED_TO'     ] = Security.USER_NAME();
				rowDefaultSearch['ASSIGNED_TO_NAME'] = Security.FULL_NAME();
				rowDefaultSearch['TEAM_ID'         ] = Security.TEAM_ID()  ;
				rowDefaultSearch['TEAM_NAME'       ] = Security.TEAM_NAME();
				rowDefaultSearch['TEAM_SET_LIST'   ] = Security.TEAM_ID()  ;
				rowDefaultSearch['TEAM_SET_NAME'   ] = Security.TEAM_ID()  ;
				rowDefaultSearch['SHOW_QUERY'      ] = Crm_Config.ToBoolean('show_sql');
				// 04/21/2020 Paul.  Set default name and dimensions. 
				rowDefaultSearch['NAME'            ] = 'untitled';
				rowDefaultSearch['PAGE_WIDTH'      ] = '8.5in';
				rowDefaultSearch['PAGE_HEIGHT'     ] = '11in';
			}
			const layout = EditView_LoadLayout(EDIT_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout    : layout,
					item      : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem: null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load onLayoutLoaded');
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(MODULE_NAME, DuplicateID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				if ( item != null )
				{
					let res  = await CreateSplendidRequest('ReportDesigner/Rest.svc/GetReportDesign?ID=' + sID, 'GET');
					let json = await GetSplendidResult(res);
					item['ReportDesign'] = json;
					item['SHOW_QUERY'  ] = Crm_Config.ToBoolean('show_sql');
					// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
					if ( item['DATE_MODIFIED'] !== undefined )
					{
						LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					}
					let sRDL: string = Sql.ToString(item['RDL']);
					if ( !Sql.IsEmptyString(sRDL) && StartsWith(sRDL, '<?xml') )
					{
						let xml: any = XMLParser.parse(sRDL);
						if ( xml.Report != null )
						{
							item['PAGE_WIDTH' ] = Sql.ToString(xml.Report.PageWidth );
							item['PAGE_HEIGHT'] = Sql.ToString(xml.Report.PageHeight);
						}
					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState({ item, SUB_TITLE, __sql: d.__sql, LAST_DATE_MODIFIED });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
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
			this.setState({ editedItem: item });
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

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private UpdateModule = async (row: any, sID: string) =>
	{
		let sMODULE_NAME: string = 'Reports';
		if ( !Credentials.ValidateCredentials )
		{
			throw new Error('Invalid connection information.');
		}
		else if ( row == null )
		{
			throw new Error(this.constructor.name + '.UpdateModule: row is invalid.');
		}
		else
		{
			let sBody: string = JSON.stringify(row);
			let sUrl : string = 'ReportDesigner/Rest.svc/UpdateModule';
			let res = await CreateSplendidRequest(sUrl + '?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			sID = json.d;
		}
		return sID;
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				case 'Print':
				{
					if ( this.validate() )
					{
						let isDuplicate = location.pathname.includes('Duplicate');
						// 04/01/2020 Paul.  We need to include the ReportDesign, which may not have been edited, so could be in item, or editedItem. 
						row = this.data;
						row.ID = (isDuplicate ? null : ID);
						// 01/09/2024 Paul.  Must set the report type in order to allow editing. 
						if ( !row.REPORT_TYPE )
						{
							row.REPORT_TYPE = 'Tabular';
						}
						delete row['SHOW_QUERY'];
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							row.ID = await this.UpdateModule(row, isDuplicate ? null : ID);
							if ( sCommandName == 'Print' )
							{
								if ( this.headerButtons.current != null )
								{
									this.headerButtons.current.NotBusy();
								}
								let URL: string = Credentials.RemoteServer + 'Reports/render.aspx?ID=' + row.ID;
								window.location.href = URL;
							}
							else
							{
								//history.push(`/Reset/${MODULE_NAME}/View/` + row.ID);
								history.push(`/Reset/${MODULE_NAME}/List`);
							}
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
							}
							if ( this._isMounted )
							{
								if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveDuplicate', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveConcurrency', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else
								{
									this.setState({ error });
								}
							}
						}
					}
					break;
				}
				case 'Attachment'      :
				case 'Attachment-PDF'  :
				case 'Attachment-Excel':
				case 'Attachment-Word' :
				case 'Attachment-Image':
				{
					let sUrl : string = 'ReportDesigner/Rest.svc/CreateAttachment';
					let res = await CreateSplendidRequest(sUrl + '?ID=' + this.props.ID + '&AttachmentType=' + sCommandName, 'GET');
					let json = await GetSplendidResult(res);
					let sNOTE_ID = json.d;
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, sNOTE_ID);
					history.push(`/Reset/Emails/Edit?NOTE_ID=` + sNOTE_ID);
					break;
				}
				case 'Cancel':
				{
					if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						//history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
						// 04/01/2020 Paul.  We typically return to list instead of running reoprt. 
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					break;
				}
				case 'Run':
				{
					this.setState({ showReportPopup: true });
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

	private _onCloseReportPopup = () =>
	{
		this.setState({ showReportPopup: false });
	}

	public render()
	{
		const { ID, DuplicateID } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, showReportPopup, error, __sql } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={ error } />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
				<QueryDesigner row={ currentItem } DATA_FIELD='ReportDesign' onChanged={ this._onChange } ref={ this.queryDesigner } />
				<Modal show={ showReportPopup } onHide={ this._onCloseReportPopup }>
					<ModalTitle>
						<div className='h3Row' style={ {width: '100%'} }>
							<h3 style={ {paddingLeft: '10px'} }>
								{ L10n.Term('Reports.LBL_NEW_FORM_TITLE') }
								<span style={ {paddingLeft: '10px', paddingRight: '10px'} } ><FontAwesomeIcon icon="angle-double-right" /></span>
								{ currentItem['NAME'] }
								<button className='button' style={ {float: 'right'} } onClick={ this._onCloseReportPopup }>
									<FontAwesomeIcon icon='window-close' size='2x' />
								</button>
							</h3>
						</div>
					</ModalTitle>
					<Modal.Body style={{ minHeight: '70vh', minWidth: '100vw' }}>
						<ReportView ReportDesign={ currentItem['ReportDesign'] } NAME={ currentItem['NAME'] } />
					</Modal.Body>
					<Modal.Footer>
						<button className='button' onClick={ this._onCloseReportPopup }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
					</Modal.Footer>
				</Modal>
			</React.Fragment>
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

// 07/18/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

