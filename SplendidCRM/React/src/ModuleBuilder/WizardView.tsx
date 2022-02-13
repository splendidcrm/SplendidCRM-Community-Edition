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
import { RouteComponentProps }                         from 'react-router-dom'                       ;
import { observer }                                    from 'mobx-react'                             ;
import { FontAwesomeIcon }                             from '@fortawesome/react-fontawesome'         ;
// 2. Store and Types. 
import MODULE                                          from '../types/MODULE'                        ;
import DETAILVIEWS_RELATIONSHIP                        from '../types/DETAILVIEWS_RELATIONSHIP'      ;
import { EditComponent }                               from '../types/EditComponent'                 ;
import { HeaderButtons }                               from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                             from '../scripts/Sql'                         ;
import L10n                                            from '../scripts/L10n'                        ;
import Credentials                                     from '../scripts/Credentials'                 ;
import SplendidCache                                   from '../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                        from '../scripts/SplendidDynamic_EditView'    ;
import { Trim }                                        from '../scripts/utility'                     ;
import { AuthenticatedMethod, LoginRedirect }          from '../scripts/Login'                       ;
import { EditView_LoadLayout }                         from '../scripts/EditView'                    ;
import { CreateSplendidRequest, GetSplendidResult }    from '../scripts/SplendidRequest'             ;
import { Admin_GetReactState, Application_ClearStore } from '../scripts/Application'                 ;
// 4. Components and Views. 
import HeaderButtonsFactory                            from '../ThemeComponents/HeaderButtonsFactory';
import TemplatePopupView                               from './TemplatePopupView'                    ;
// 5. Templates
import jsonAccounts                                    from './Templates/Accounts'                   ;
import jsonContacts                                    from './Templates/Contacts'                   ;
import jsonLeads                                       from './Templates/Leads'                      ;
import jsonOpportunities                               from './Templates/Opportunities'              ;

let MODULE_NAME: string = 'ModuleBuilder';

class MODULE_FIELD
{
	FIELD_NAME: string;
	EDIT_LABEL: string;
	LIST_LABEL: string;
	DATA_TYPE : string;
	MAX_SIZE  : number;
	REQUIRED  : boolean;

	constructor(FIELD_NAME: string, EDIT_LABEL: string, LIST_LABEL: string, DATA_TYPE: string, MAX_SIZE: number, REQUIRED: boolean)
	{
		this.FIELD_NAME = FIELD_NAME;
		this.EDIT_LABEL = EDIT_LABEL;
		this.LIST_LABEL = LIST_LABEL;
		this.DATA_TYPE  = DATA_TYPE ;
		this.MAX_SIZE   = MAX_SIZE  ;
		this.REQUIRED   = REQUIRED  ;
	}
}

interface IEditViewProps extends RouteComponentProps<any>
{
	ID?                 : string;
	LAYOUT_NAME         : string;
	rowDefaultSearch?   : any;
	onLayoutLoaded?     : any;
	onSubmit?           : any;
	DuplicateID?        : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__sql              : string ;
	item               : any    ;
	layout             : any    ;
	EDIT_NAME          : string ;
	DUPLICATE          : boolean;
	LAST_DATE_MODIFIED : Date   ;
	SUB_TITLE          : any    ;
	editedItem         : any    ;
	dependents         : Record<string, Array<any>>;
	error              : any    ;
	nWizardPanel       : number ;
	MODULE_LIST        : string[];
	fields             : MODULE_FIELD[];
	chkRelationships   : any    ;
	nFieldEditIndex    : number ;
	txtFIELD_NAME      : string ;
	txtEDIT_LABEL      : string ;
	txtLIST_LABEL      : string ;
	lstDATA_TYPE       : string ;
	txtMAX_SIZE        : string ;
	chkREQUIRED        : boolean;
	lblProgress        : string ;
	templateOpen       : boolean;
	changeKey          : number ;
}

@observer
export default class ModuleBuilderWizardView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private templateView  = React.createRef<TemplatePopupView>();

	public get data (): any
	{
		const { fields, chkRelationships, MODULE_LIST } = this.state;
		let row: any = {};
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 04/01/2020 Paul.  We need to include the ReportDesign, which may not have been edited, so could be in item, or editedItem. 
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row);
		currentItem.Fields        = fields;
		currentItem.Relationships = [];
		for ( let i: number = 0; i < MODULE_LIST.length; i++ )
		{
			if ( chkRelationships[MODULE_LIST[i]] )
			{
				currentItem.Relationships.push(MODULE_LIST[i]);
			}
		}
		return currentItem;
	}

	public validate(): boolean
	{
		let row: any = {};
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = MODULE_NAME + '.WizardView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}

		let fields: MODULE_FIELD[] = [];
		fields.push(new MODULE_FIELD("ID"               , L10n.Term(".LBL_ID"               ), L10n.Term(".LBL_LIST_ID"               ), "Guid"    , null, true ));
		fields.push(new MODULE_FIELD("DELETED"          , L10n.Term(".LBL_DELETED"          ), L10n.Term(".LBL_LIST_DELETED"          ), "Checkbox", null, true ));
		fields.push(new MODULE_FIELD("CREATED_BY"       , L10n.Term(".LBL_CREATED_BY"       ), L10n.Term(".LBL_LIST_CREATED_BY"       ), "Guid"    , null, false));
		fields.push(new MODULE_FIELD("DATE_ENTERED"     , L10n.Term(".LBL_DATE_ENTERED"     ), L10n.Term(".LBL_LIST_DATE_ENTERED"     ), "Date"    , null, true ));
		fields.push(new MODULE_FIELD("MODIFIED_USER_ID" , L10n.Term(".LBL_MODIFIED_USER_ID" ), L10n.Term(".LBL_LIST_MODIFIED_USER_ID" ), "Guid"    , null, false));
		fields.push(new MODULE_FIELD("DATE_MODIFIED"    , L10n.Term(".LBL_DATE_MODIFIED"    ), L10n.Term(".LBL_LIST_DATE_MODIFIED"    ), "Date"    , null, true ));
		fields.push(new MODULE_FIELD("DATE_MODIFIED_UTC", L10n.Term(".LBL_DATE_MODIFIED_UTC"), L10n.Term(".LBL_LIST_DATE_MODIFIED_UTC"), "Date"    , null, true ));
		fields.push(new MODULE_FIELD('NAME'             , 'Name'                             , 'Name:'                                 , "Text"    ,  150, true ));
		fields.push(new MODULE_FIELD(null               , null                               , null                                    , null      , null, false));
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
			error             : null,
			nWizardPanel      : 0,
			MODULE_LIST       : [],
			fields            ,
			chkRelationships  : {},
			nFieldEditIndex   : fields.length - 1,
			txtFIELD_NAME     : null,
			txtEDIT_LABEL     : null,
			txtLIST_LABEL     : null,
			lstDATA_TYPE      : null,
			txtMAX_SIZE       : null,
			chkREQUIRED       : null,
			lblProgress       : null,
			templateOpen      : false,
			changeKey         : 0,
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
				if ( SplendidCache.AdminMenu == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Admin_GetReactState');
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
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
		const { EDIT_NAME } = this.state;
		try
		{
			let rowDefaultSearch: any = 
			{
				REST_ENABLED            : true,
				INCLUDE_ASSIGNED_USER_ID: true,
				INCLUDE_TEAM_ID         : true,
				CREATE_CODE_BEHIND      : false,
				REACT_ONLY              : true,
			};
			const layout = EditView_LoadLayout(EDIT_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			let MODULE_LIST: string[] = [];
			let chkRelationships: any = {};
			for ( let sMODULE in SplendidCache.MODULES )
			{
				let module: MODULE = SplendidCache.MODULES[sMODULE];
				if ( Sql.ToBoolean(module.MODULE_ENABLED) && Sql.ToBoolean(module.CUSTOM_ENABLED) && Sql.ToBoolean(module.REPORT_ENABLED) && (!Sql.ToBoolean(module.IS_ADMIN) || module.MODULE_NAME == 'Users') )
				{
					MODULE_LIST.push(module.MODULE_NAME);
					chkRelationships[module.MODULE_NAME] = false;
				}
			}
			MODULE_LIST.sort((a, b) => a.localeCompare(b))
			if ( this._isMounted )
			{
				let SUB_TITLE: any = L10n.Term('ModuleBuilder.LBL_MODULEBUILDER');
				document.title = SUB_TITLE;
				window.scroll(0, 0);
				this.setState(
				{
					layout          : layout,
					item            : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem      : null,
					SUB_TITLE       ,
					MODULE_LIST     ,
					chkRelationships,
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load onLayoutLoaded');
						this.props.onLayoutLoaded();
					}
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

	private AddRemoveStandardField = (fields: MODULE_FIELD[], NAME: string, INCLUDE: boolean, index: number) =>
	{
		let nAddRemove: number = 0;
		let nExistingIndex: number = -1;
		for ( let i: number = 0; i < fields.length; i++ )
		{
			if ( fields[i].FIELD_NAME == NAME )
			{
				nExistingIndex = i;
			}
		}
		if ( INCLUDE )
		{
			if ( nExistingIndex < 0 )
			{
				fields.splice(index, 0, new MODULE_FIELD(NAME, L10n.Term(".LBL_" + NAME), L10n.Term(".LBL_LIST_" + NAME.replace('SET_ID', 'SET_NAME')), "Guid", null, false));
				nAddRemove++;
			}
		}
		else
		{
			if ( nExistingIndex >= 0 )
			{
				fields.splice(nExistingIndex, 1);
				nAddRemove--;
			}
		}
		return nAddRemove;
	}

	private UpdateDependancy(DATA_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any)
	{
		let ref = this.refMap[DATA_FIELD];
		if ( ref && ref.current )
		{
			ref.current.updateDependancy(null, DATA_VALUE, PROPERTY_NAME, item);
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		let { fields, nFieldEditIndex } = this.state;
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
		if ( PARENT_FIELD == 'DISPLAY_NAME' )
		{
			let MODULE_NAME: string = Sql.replaceAll(DATA_VALUE, ' ', '');
			let TABLE_NAME : string = Sql.replaceAll(Sql.replaceAll(DATA_VALUE, ' ', '_'), '-', '_').toUpperCase();
			this.UpdateDependancy('MODULE_NAME', MODULE_NAME, 'value');
			this.UpdateDependancy('TABLE_NAME' , TABLE_NAME , 'value');
		}
		else if ( PARENT_FIELD == 'INCLUDE_ASSIGNED_USER_ID' )
		{
			nFieldEditIndex += this.AddRemoveStandardField(fields, 'ASSIGNED_USER_ID', DATA_VALUE, 7);
			nFieldEditIndex += this.AddRemoveStandardField(fields, 'ASSIGNED_SET_ID' , DATA_VALUE, 8);
			this.setState({ fields, nFieldEditIndex });
		}
		else if ( PARENT_FIELD == 'INCLUDE_TEAM_ID' )
		{
			const currentItem: any = Object.assign({}, this.state.item, this.state.editedItem);
			let nTeamLocation: number = 7;
			if ( Sql.ToBoolean(currentItem['INCLUDE_ASSIGNED_USER_ID']) )
				nTeamLocation = 9;
			nFieldEditIndex += this.AddRemoveStandardField(fields, 'TEAM_ID'    , DATA_VALUE, nTeamLocation + 0);
			nFieldEditIndex += this.AddRemoveStandardField(fields, 'TEAM_SET_ID', DATA_VALUE, nTeamLocation + 1);
			this.setState({ fields, nFieldEditIndex });
		}
	}

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

	private UpdateButtons = (nWizardPanel: number) =>
	{
		this.headerButtons.current.ShowButton('SelectTemplate', nWizardPanel == 0);
		this.headerButtons.current.ShowButton('Back'          , nWizardPanel >  0);
		this.headerButtons.current.ShowButton('Next'          , nWizardPanel <  2);
		this.headerButtons.current.ShowButton('Generate'      , nWizardPanel >= 2);
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		const { MODULE_LIST } = this.state;
		let { error, nWizardPanel, editedItem } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'SelectTemplate':
				{
					this.setState({ templateOpen: true });
					break;
				}
				case 'Next':
				{
					const currentItem: any = Object.assign({}, this.state.item, this.state.editedItem);
					let nInvalidFields: number = 0;
					if ( nWizardPanel == 0 )
					{
						nInvalidFields = SplendidDynamic_EditView.Validate(this.refMap);
					}
					if ( nWizardPanel == 0 && nInvalidFields > 0 )
					{
						this.setState({ error: L10n.Term('.ERR_MISSING_REQUIRED_FIELDS') });
					}
					else
					{
						if ( error != null || error == '' )
						{
							this.setState({ error: '' });
						}
						if ( nWizardPanel < 2 )
						{
							nWizardPanel++;
							this.setState({ nWizardPanel });
						}
						this.UpdateButtons(nWizardPanel);
					}
					break;
				}
				case 'Back':
				{
					if ( nWizardPanel > 0 )
					{
						nWizardPanel--;
						this.setState({ nWizardPanel });
					}
					this.UpdateButtons(nWizardPanel);
					break;
				}
				case 'Generate':
				{
					if ( this.validate() )
					{
						if ( nWizardPanel < 3 )
						{
							nWizardPanel++;
							this.setState({ nWizardPanel });
						}
						row = this.data;
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							let sBody: string = JSON.stringify(row);
							let sUrl : string = 'Administration/ModuleBuilder/Rest.svc/GenerateModule';
							let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
							let json = await GetSplendidResult(res);
							let lblProgress: string = json.d;
							this.setState({ lblProgress });
							// 11/25/2021 Paul.  If module is created in database, then reload the state. 
							if ( !row.CREATE_CODE_BEHIND || row.REACT_ONLY )
							{
								await Application_ClearStore();
								await Admin_GetReactState(this.constructor.name + '.Page_Command ' + sCommandName);
							}
							
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
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
								this.setState({ error });
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					history.push(`/Reset/Administration`);
					break;
				}
				// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
				case 'AutoComplete':
				{
					if ( sCommandArguments.FIELD_NAME == 'DISPLAY_NAME' )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
						if ( sCommandArguments.FIELD_NAME == 'DISPLAY_NAME' )
						{
							let sMODULE: string = sCommandArguments.VALUE;
							let module: MODULE = SplendidCache.Module(sMODULE);
							if ( module )
							{
								let item: any = {};
								item['DISPLAY_NAME'            ] = module.DISPLAY_NAME            ;
								item['MODULE_NAME'             ] = module.MODULE_NAME             ;
								item['TABLE_NAME'              ] = module.TABLE_NAME              ;
								item['TAB_ENABLED'             ] = module.TAB_ENABLED             ;
								item['MOBILE_ENABLED'          ] = module.MOBILE_ENABLED          ;
								item['CUSTOM_ENABLED'          ] = module.CUSTOM_ENABLED          ;
								item['REPORT_ENABLED'          ] = module.REPORT_ENABLED          ;
								item['IMPORT_ENABLED'          ] = module.IMPORT_ENABLED          ;
								item['REST_ENABLED'            ] = module.REST_ENABLED            ;
								item['IS_ADMIN'                ] = module.IS_ADMIN                ;
								item['INCLUDE_ASSIGNED_USER_ID'] = module.IS_ASSIGNED             ;
								//editedItem['INCLUDE_TEAM_ID'         ] = module.INCLUDE_TEAM_ID         ;
								let chkRelationships: any = {};
								for ( let i: number = 0; i < MODULE_LIST.length; i++ )
								{
									chkRelationships[MODULE_LIST[i]] = false;
								}
								let arrRelationships: DETAILVIEWS_RELATIONSHIP[] = SplendidCache.DetailViewRelationships(sMODULE + '.DetailView');
								for ( let i: number = 0; i < arrRelationships.length; i++ )
								{
									chkRelationships[arrRelationships[i].MODULE_NAME] = true;
								}
								let fields: MODULE_FIELD[] = [];
								fields.push(new MODULE_FIELD("ID"               , L10n.Term(".LBL_ID"               ), L10n.Term(".LBL_LIST_ID"               ), "Guid"    , null, true ));
								fields.push(new MODULE_FIELD("DELETED"          , L10n.Term(".LBL_DELETED"          ), L10n.Term(".LBL_LIST_DELETED"          ), "Checkbox", null, true ));
								fields.push(new MODULE_FIELD("CREATED_BY"       , L10n.Term(".LBL_CREATED_BY"       ), L10n.Term(".LBL_LIST_CREATED_BY"       ), "Guid"    , null, false));
								fields.push(new MODULE_FIELD("DATE_ENTERED"     , L10n.Term(".LBL_DATE_ENTERED"     ), L10n.Term(".LBL_LIST_DATE_ENTERED"     ), "Date"    , null, true ));
								fields.push(new MODULE_FIELD("MODIFIED_USER_ID" , L10n.Term(".LBL_MODIFIED_USER_ID" ), L10n.Term(".LBL_LIST_MODIFIED_USER_ID" ), "Guid"    , null, false));
								fields.push(new MODULE_FIELD("DATE_MODIFIED"    , L10n.Term(".LBL_DATE_MODIFIED"    ), L10n.Term(".LBL_LIST_DATE_MODIFIED"    ), "Date"    , null, true ));
								fields.push(new MODULE_FIELD("DATE_MODIFIED_UTC", L10n.Term(".LBL_DATE_MODIFIED_UTC"), L10n.Term(".LBL_LIST_DATE_MODIFIED_UTC"), "Date"    , null, true ));
								
								let res  = await CreateSplendidRequest('Administration/ModuleBuilder/Rest.svc/GetModuleFields?ModuleName=' + sMODULE, 'GET');
								let json = await GetSplendidResult(res);
								if ( this._isMounted )
								{
									let moduleFields: Array<any> = json.d;
									for ( let i: number = 0; i < moduleFields.length; i++)
									{
										let field: any = moduleFields[i];
										if ( field.FIELD_NAME == "ID"               
										  || field.FIELD_NAME == "DELETED"          
										  || field.FIELD_NAME == "CREATED_BY"       
										  || field.FIELD_NAME == "DATE_ENTERED"     
										  || field.FIELD_NAME == "MODIFIED_USER_ID" 
										  || field.FIELD_NAME == "DATE_MODIFIED"    
										  || field.FIELD_NAME == "DATE_MODIFIED_UTC"
										   )
										{
											continue;
										}
										let MAX_SIZE: number = null;
										if ( field.DATA_TYPE == 'Text' || field.DATA_TYPE == 'Text Area' || field.DATA_TYPE == 'Dropdown' )
										{
											MAX_SIZE = field.MAX_SIZE;
										}
										fields.push(new MODULE_FIELD(field.FIELD_NAME, field.EDIT_LABEL, field.LIST_LABEL, field.DATA_TYPE, MAX_SIZE, field.REQUIRED));
									}
									fields.push(new MODULE_FIELD(null               , null                               , null                                    , null      , null, false));
									this.setState(
									{
										item            ,
										editedItem      : null,
										fields          ,
										chkRelationships,
										nFieldEditIndex : fields.length - 1,
										changeKey       : this.state.changeKey + 1,
									});
								}
							}
						}
					}
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

	private _onRelationship = (e, module) =>
	{
		let { chkRelationships } = this.state;
		chkRelationships[module] = e.target.checked;
		this.setState({ chkRelationships });
	}

	private _onButtonsLoaded = async () =>
	{
		const { nWizardPanel } = this.state;
		if ( this.headerButtons.current != null )
		{
			this.UpdateButtons(nWizardPanel);
		}
	}

	private _onFieldEdit = (index: number) =>
	{
		const { fields } = this.state;
		const currentItem: any = Object.assign({}, this.state.item, this.state.editedItem);
		let FIELD_NAME: string = fields[index].FIELD_NAME;
		if (  FIELD_NAME == "ID"              
		   || FIELD_NAME == "DELETED"         
		   || FIELD_NAME == "CREATED_BY"      
		   || FIELD_NAME == "DATE_ENTERED"    
		   || FIELD_NAME == "MODIFIED_USER_ID"
		   || FIELD_NAME == "DATE_MODIFIED"   
		   || FIELD_NAME == "DATE_MODIFIED_UTC"
		   || (FIELD_NAME == "ASSIGNED_USER_ID" && Sql.ToBoolean(currentItem['INCLUDE_ASSIGNED_USER_ID']))
		   || (FIELD_NAME == "ASSIGNED_SET_ID"  && Sql.ToBoolean(currentItem['INCLUDE_ASSIGNED_USER_ID']))
		   || (FIELD_NAME == "TEAM_ID"          && Sql.ToBoolean(currentItem['INCLUDE_TEAM_ID'         ]))
		   || (FIELD_NAME == "TEAM_SET_ID"      && Sql.ToBoolean(currentItem['INCLUDE_TEAM_ID'         ]))
		   )
		{
			this.setState({ error: 'This field cannot be edited.' });
		}
		else
		{
			let txtFIELD_NAME: string  = fields[index].FIELD_NAME;
			let txtEDIT_LABEL: string  = fields[index].EDIT_LABEL;
			let txtLIST_LABEL: string  = fields[index].LIST_LABEL;
			let lstDATA_TYPE : string  = fields[index].DATA_TYPE ;
			let txtMAX_SIZE  : string  = Sql.ToString(fields[index].MAX_SIZE);
			let chkREQUIRED  : boolean = fields[index].REQUIRED  ;
			if ( Sql.IsEmptyString(lstDATA_TYPE) )
			{
				lstDATA_TYPE = 'Text';
			}
			if ( lstDATA_TYPE == 'Text' && Sql.IsEmptyString(txtMAX_SIZE) || txtMAX_SIZE == '0' )
			{
				txtMAX_SIZE = '150';
			}
			this.setState(
			{
				nFieldEditIndex: index,
				txtFIELD_NAME  ,
				txtEDIT_LABEL  ,
				txtLIST_LABEL  ,
				lstDATA_TYPE   ,
				txtMAX_SIZE    ,
				chkREQUIRED    ,
			});
		}
	}

	private _onFieldDelete = (index: number) =>
	{
		let { fields } = this.state;
		const currentItem: any = Object.assign({}, this.state.item, this.state.editedItem);
		let FIELD_NAME: string = fields[index].FIELD_NAME;
		if (  FIELD_NAME == "ID"              
		   || FIELD_NAME == "DELETED"         
		   || FIELD_NAME == "CREATED_BY"      
		   || FIELD_NAME == "DATE_ENTERED"    
		   || FIELD_NAME == "MODIFIED_USER_ID"
		   || FIELD_NAME == "DATE_MODIFIED"   
		   || FIELD_NAME == "DATE_MODIFIED_UTC"
		   || (FIELD_NAME == "ASSIGNED_USER_ID" && Sql.ToBoolean(currentItem['INCLUDE_ASSIGNED_USER_ID']))
		   || (FIELD_NAME == "ASSIGNED_SET_ID"  && Sql.ToBoolean(currentItem['INCLUDE_ASSIGNED_USER_ID']))
		   || (FIELD_NAME == "TEAM_ID"          && Sql.ToBoolean(currentItem['INCLUDE_TEAM_ID'         ]))
		   || (FIELD_NAME == "TEAM_SET_ID"      && Sql.ToBoolean(currentItem['INCLUDE_TEAM_ID'         ]))
		   )
		{
			this.setState({ error: 'This field cannot be deleted.' });
		}
		else
		{
			fields.splice(index, 1);
			if ( fields.length == 0 || !Sql.IsEmptyString(fields[fields.length - 1].FIELD_NAME) )
			{
				fields.push(new MODULE_FIELD(null               , null                               , null                                    , null      , null, false));
			}
			this.setState(
			{
				fields,
				error : '',
			});
		}
	}

	private _onFieldUpdate = (index: number) =>
	{
		let { fields, txtFIELD_NAME, txtEDIT_LABEL, txtLIST_LABEL, lstDATA_TYPE, txtMAX_SIZE, chkREQUIRED } = this.state;
		if ( !Sql.IsEmptyString(Trim(txtFIELD_NAME)) )
		{
			fields[index].FIELD_NAME = Sql.replaceAll(Trim(txtFIELD_NAME), ' ', '_');
			fields[index].EDIT_LABEL = Trim(txtEDIT_LABEL);
			fields[index].LIST_LABEL = Trim(txtLIST_LABEL);
			fields[index].DATA_TYPE  = lstDATA_TYPE ;
			fields[index].MAX_SIZE   = Sql.ToInteger(txtMAX_SIZE);
			fields[index].REQUIRED   = Sql.ToBoolean(chkREQUIRED);
			if ( Sql.IsEmptyString(fields[index].DATA_TYPE) )
			{
				fields[index].DATA_TYPE = 'Text';
			}
			if ( fields[index].DATA_TYPE == 'Text' && fields[index].MAX_SIZE == 0 )
			{
				fields[index].MAX_SIZE = 150;
			}
			if ( fields.length == 0 || !Sql.IsEmptyString(fields[fields.length - 1].FIELD_NAME) )
			{
				fields.push(new MODULE_FIELD(null               , null                               , null                                    , null      , null, false));
			}
			this.setState({ fields, nFieldEditIndex: fields.length - 1, error: '' });
		}
		else
		{
			this.setState({ error: L10n.Term('.ERR_MISSING_REQUIRED_FIELDS') });
		}
	}

	private _onFieldCancel = (index: number) =>
	{
		const { fields } = this.state;
		let txtFIELD_NAME: string  = '';
		let txtEDIT_LABEL: string  = '';
		let txtLIST_LABEL: string  = '';
		let lstDATA_TYPE : string  = '';
		let txtMAX_SIZE  : string  = '';
		let chkREQUIRED  : boolean = false;
		this.setState(
		{
			nFieldEditIndex: fields.length - 1,
			txtFIELD_NAME  ,
			txtEDIT_LABEL  ,
			txtLIST_LABEL  ,
			lstDATA_TYPE   ,
			txtMAX_SIZE    ,
			chkREQUIRED    ,
			error          : '',
		});
	}

	private _onFieldTextChanged = (e: any, index: number, name: string) =>
	{
		let { fields, nFieldEditIndex, txtFIELD_NAME, txtEDIT_LABEL, txtLIST_LABEL, lstDATA_TYPE, txtMAX_SIZE } = this.state;
		switch ( name )
		{
			case 'FIELD_NAME':  txtFIELD_NAME = e.target.value;  break;
			case 'EDIT_LABEL':  txtEDIT_LABEL = e.target.value;  break;
			case 'LIST_LABEL':  txtLIST_LABEL = e.target.value;  break;
			case 'DATA_TYPE' :  lstDATA_TYPE  = e.target.value;  break;
			case 'MAX_SIZE'  :  txtMAX_SIZE   = e.target.value;  break;
		}
		if ( name == 'FIELD_NAME' )
		{
			txtFIELD_NAME = txtFIELD_NAME.toUpperCase();
			let sFIELD_NAME: string = Sql.replaceAll(Trim(txtFIELD_NAME), '_', ' ');
			if ( sFIELD_NAME.length > 0 )
			{
				let arrFIELD_NAME: string[] = sFIELD_NAME.split(' ');
				for ( let i: number = 0; i < arrFIELD_NAME.length; i++ )
				{
					if ( arrFIELD_NAME[i].toUpperCase() == 'ID' )
					{
						arrFIELD_NAME[i] = arrFIELD_NAME[i].toUpperCase();
					}
					else
					{
						arrFIELD_NAME[i] = arrFIELD_NAME[i].substr(0, 1).toUpperCase() + arrFIELD_NAME[i].substr(1).toLowerCase();
					}
				}
				sFIELD_NAME = arrFIELD_NAME.join(' ');
				if ( Sql.IsEmptyString(fields[nFieldEditIndex].EDIT_LABEL) )
				{
					txtEDIT_LABEL = sFIELD_NAME;
				}
				if ( Sql.IsEmptyString(fields[nFieldEditIndex].LIST_LABEL) )
				{
					txtLIST_LABEL = sFIELD_NAME + ':';
				}
			}
		}
		this.setState(
		{
			txtFIELD_NAME  ,
			txtEDIT_LABEL  ,
			txtLIST_LABEL  ,
			lstDATA_TYPE   ,
			txtMAX_SIZE    ,
		});
	}

	private _onFieldBooleanChanged = (e: any, index: number, name: string) =>
	{
		let { chkREQUIRED } = this.state;
		chkREQUIRED = e.target.checked;
		this.setState({ chkREQUIRED });
	}

	private LoadTemplate(template: any)
	{
		const { MODULE_LIST } = this.state;
		let item = {};
		item['DISPLAY_NAME'            ] = template.DISPLAY_NAME  ;
		item['MODULE_NAME'             ] = template.MODULE_NAME   ;
		item['TABLE_NAME'              ] = template.TABLE_NAME    ;
		item['TAB_ENABLED'             ] = template.TAB_ENABLED   ;
		item['MOBILE_ENABLED'          ] = template.MOBILE_ENABLED;
		item['CUSTOM_ENABLED'          ] = template.CUSTOM_ENABLED;
		item['REPORT_ENABLED'          ] = template.REPORT_ENABLED;
		item['IMPORT_ENABLED'          ] = template.IMPORT_ENABLED;
		item['REST_ENABLED'            ] = template.REST_ENABLED  ;
		item['IS_ADMIN'                ] = template.IS_ADMIN      ;
		item['INCLUDE_ASSIGNED_USER_ID'] = template.IS_ASSIGNED   ;
		let fields          : MODULE_FIELD[] = template.Fields;
		let chkRelationships: any = {};
		for ( let i: number = 0; i < MODULE_LIST.length; i++ )
		{
			chkRelationships[MODULE_LIST[i]] = false;
		}
		for ( let i: number = 0; i < template.Relationships.length; i++ )
		{
			chkRelationships[template.Relationships[i]] = true;
		}
		this.setState(
		{
			item            ,
			editedItem      : null,
			fields          ,
			chkRelationships,
			nFieldEditIndex : fields.length - 1,
			changeKey       : this.state.changeKey + 1,
		});
	}

	private _onTemplateSelect = (value: { Action: string, ID: string, NAME: string }) =>
	{
		if ( value.Action == 'SingleSelect' )
		{
			if ( this._isMounted )
			{
				this.setState({ templateOpen: false });
				switch ( value.NAME )
				{
					case 'Accounts'     :  this.LoadTemplate(jsonAccounts     );  break;
					case 'Contacts'     :  this.LoadTemplate(jsonContacts     );  break;
					case 'Leads'        :  this.LoadTemplate(jsonLeads        );  break;
					case 'Opportunities':  this.LoadTemplate(jsonOpportunities);  break;
				}
			}
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ templateOpen: false });
		}
	}

	public render()
	{
		const { ID } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error, __sql, nWizardPanel, MODULE_LIST, fields, chkRelationships, nFieldEditIndex, txtFIELD_NAME, txtEDIT_LABEL, txtLIST_LABEL, lstDATA_TYPE, txtMAX_SIZE, chkREQUIRED, lblProgress, templateOpen, changeKey } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, L10n.Term('ModuleBuilder.LBL_MODULEBUILDER'));
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			const currentItem: any = Object.assign({}, this.state.item, this.state.editedItem);
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div id='ModuleBuilderWizardView' key={ 'ctlWizardView' + changeKey }>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div style={ {display: (nWizardPanel == 0 ? null : 'none')} }>
					<h4>{ L10n.Term('ModuleBuilder.LBL_WIZARD_STEP1') }</h4>
					<TemplatePopupView
						isOpen={ templateOpen }
						callback={ this._onTemplateSelect }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.templateView }
					/>

					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
				</div>
				<div style={ {display: (nWizardPanel == 1 ? null : 'none')} }>
					<h4>{ L10n.Term('ModuleBuilder.LBL_WIZARD_STEP2') }</h4>
					<table id="ctl00_cntBody_ctlListView_grdMain" style={ {width: '100%', borderCollapse: 'collapse'} } cellSpacing={ 0 } cellPadding={ 4 }>
						<tbody>
							<tr className="listViewThS1">
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_FIELD_NAME') }</th>
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_EDIT_LABEL') }</th>
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_LIST_LABEL') }</th>
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_DATA_TYPE' ) }</th>
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_MAX_SIZE'  ) }</th>
								<th style={ {whiteSpace: 'nowrap', width: '20%'} }>{ L10n.Term('ModuleBuilder.LBL_LIST_REQUIRED'  ) }</th>
								<th>&nbsp;</th>
							</tr>
							{ fields.map((field, index) => 
								{
									if ( index != nFieldEditIndex )
									{
										return (
							<tr className="oddListRowS1" style={ {verticalAlign: 'top'} }>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>{ field.FIELD_NAME }</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>{ field.EDIT_LABEL }</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>{ field.LIST_LABEL }</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>{ field.DATA_TYPE  }</td>
								<td style={ {width: '10%', border: 'solid gray 1px'} }>{ field.MAX_SIZE   }</td>
								<td style={ {width: '10%', border: 'solid gray 1px'} }>{ Sql.ToString(field.REQUIRED) }</td>
								<td style={ {width: '10%', border: 'solid gray 1px', whiteSpace: 'nowrap'} }>
									<input className="button" onClick={ (e) => this._onFieldEdit(index) } type="button" value={ L10n.Term('.LBL_EDIT_BUTTON_LABEL') } />
									&nbsp;
									<input className="button" onClick={ (e) => this._onFieldDelete(index) } type="button" value={ L10n.Term('.LBL_DELETE_BUTTON_LABEL') } />
								</td>
							</tr>
										);
									}
									else
									{
										return (
							<tr className="evenListRowS1" style={ {verticalAlign: 'top'} }>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>
									<input id="PREVIOUS_NAME" type="hidden" />
									<input id="FIELD_NAME" style={ {width: '150px'} } value={ txtFIELD_NAME } onChange={ (e) => this._onFieldTextChanged(e, index, 'FIELD_NAME') } type="text" maxLength={ 30 } autoComplete="off" />
								</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>
									<input id="EDIT_LABEL" style={ {width: '150px'} } value={ txtEDIT_LABEL } onChange={ (e) => this._onFieldTextChanged(e, index, 'EDIT_LABEL') } type="text" maxLength={ 50 } autoComplete="off" />
								</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>
									<input id="LIST_LABEL" style={ {width: '150px'} } value={ txtLIST_LABEL } onChange={ (e) => this._onFieldTextChanged(e, index, 'LIST_LABEL') } type="text" maxLength={ 50 } autoComplete="off" />
								</td>
								<td style={ {width: '20%', border: 'solid gray 1px'} }>
									<select id="DATA_TYPE" value={ lstDATA_TYPE } onChange={ (e) => this._onFieldTextChanged(e, index, 'DATA_TYPE') }>
										<option value="Text"     >Text</option>
										<option value="Text Area">Text Area</option>
										<option value="Integer"  >Integer</option>
										<option value="Decimal"  >Decimal</option>
										<option value="Money"    >Money</option>
										<option value="Checkbox" >Checkbox</option>
										<option value="Date"     >Date</option>
										<option value="Dropdown" >Dropdown</option>
										<option value="Guid"     >Guid</option>
										<option value="byte[]"   >Byte Array</option>
									</select>
								</td>
								<td style={ {width: '10%', border: 'solid gray 1px'} }>
									<input id="MAX_SIZE" style={ {width: '60px'} } value={ txtMAX_SIZE } onChange={ (e) => this._onFieldTextChanged(e, index, 'MAX_SIZE') } type="text" maxLength={ 10 } autoComplete="off" />
								</td>
								<td style={ {width: '10%', border: 'solid gray 1px'} }>
									<span className="checkbox">
										<input id="REQUIRED" type="checkbox" checked={ chkREQUIRED } onChange={ (e) => this._onFieldBooleanChanged(e, index, 'REQUIRED') } />
									</span>
								</td>
								<td style={ {width: '10%', border: 'solid gray 1px', whiteSpace: 'nowrap'} }>
									<input name="ctl00$cntBody$ctlListView$grdMain$ctl09$ctl00" className="button" onClick={ (e) => this._onFieldUpdate(index) } type="submit" value={ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') } />
									&nbsp;
									<input className="button" onClick={ (e) => this._onFieldCancel(index) } type="button" value={ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') } />
								</td>
							</tr>
										);
									}
								})
							}
						</tbody>
					</table>
				</div>
				<div style={ {display: (nWizardPanel == 2 ? null : 'none')} }>
					<h4>{ L10n.Term('ModuleBuilder.LBL_WIZARD_STEP3') }</h4>
					{ MODULE_LIST ?
						MODULE_LIST.map((item, index) =>
						{
							return (
							<div style={ {padding: '3px'} }>
								<input type='checkbox' className='checkbox' id={ 'chkRelationships_' + item } key={ 'chkRelationships_' + item } checked={ chkRelationships[item] } onChange={ (e) => this._onRelationship(e, item) } />
								&nbsp;
								<label htmlFor={ 'chkRelationships_' + item }>{ L10n.ListTerm('moduleList', item) }</label>
							</div>);
						})
					: null
					}
				</div>
				<div style={ {display: (nWizardPanel == 3 ? null : 'none')} }>
					<h4>{ L10n.Term('ModuleBuilder.LBL_WIZARD_STEP4') }</h4>
					<div dangerouslySetInnerHTML={ { __html: lblProgress || '' } }></div>
				</div>
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

