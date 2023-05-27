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
import * as qs from 'query-string';
import { RouteComponentProps, withRouter }        from 'react-router-dom'                          ;
import { observer }                               from 'mobx-react'                                ;
import { FontAwesomeIcon }                        from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import { EditComponent }                          from '../../types/EditComponent'                 ;
import { HeaderButtons }                          from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                        from '../../scripts/Sql'                         ;
import L10n                                       from '../../scripts/L10n'                        ;
import Security                                   from '../../scripts/Security'                    ;
import Credentials                                from '../../scripts/Credentials'                 ;
import SplendidCache                              from '../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                   from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                from '../../scripts/Crm'                         ;
import { base64ArrayBuffer, EndsWith }            from '../../scripts/utility'                     ;
import { AuthenticatedMethod, LoginRedirect }     from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                       from '../../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_ActivateTab } from '../../scripts/EditView';
import EDITVIEWS_FIELD                            from '../../types/EDITVIEWS_FIELD'               ;
import { ListView_LoadTable }                     from '../../scripts/ListView'                    ;
import { SystemSqlColumns }                       from '../../scripts/SystemCacheRequest'          ;
import { UpdateModule }                           from '../../scripts/ModuleUpdate'                ;
import { jsonReactState }                         from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                             from '../../components/ErrorComponent'           ;
import DumpSQL                                    from '../../components/DumpSQL'                  ;
import DynamicButtons                             from '../../components/DynamicButtons'           ;
import HeaderButtonsFactory                       from '../../ThemeComponents/HeaderButtonsFactory';
// 04/16/2022 Paul.  Add LayoutTabs to Pacific theme. 
import LayoutTabs                                 from '../../components/LayoutTabs'               ;
// 05/18/2023 Paul.  Allow insert of Survey module. 
import DynamicPopupView                           from '../../views/DynamicPopupView'              ;

interface IEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
	ID?                : string;
	LAYOUT_NAME        : string;
	callback?          : any;
	rowDefaultSearch?  : any;
	onLayoutLoaded?    : any;
	onSubmit?          : any;
	isSearchView?      : boolean;
	isUpdatePanel?     : boolean;
	isQuickCreate?     : boolean;
	DuplicateID?       : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__total            : number;
	__sql              : string;
	item               : any;
	layout             : any;
	EDIT_NAME          : string;
	DUPLICATE          : boolean;
	LAST_DATE_MODIFIED : Date;
	SUB_TITLE          : any;
	ATTACHMENTS?         : any[];
	editedItem         : any;
	dependents         : Record<string, Array<any>>;
	error              : any;
	popupOpen          : boolean;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class EmailTemplatesEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private PARENT_ID    : string = null;
	private PARENT_TYPE  : string = null;
	private CAMPAIGN_ID  : string = null;

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 08/26/2019 Paul.  There does not seem to be a need to save date in DATE_TIME field here as this is used for search views. 
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
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
		let EDIT_NAME = props.MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total           : 0,
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
			popupOpen         : false
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { isSearchView } = this.props;
		this._isMounted = true;
		try
		{
			// 05/29/2019 Paul.  In search mode, EditView will not redirect to login. 
			if ( Sql.ToBoolean(isSearchView) )
			{
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( Credentials.bIsAuthenticated )
				{
					await this.load();
				}
			}
			else
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
				const { MODULE_NAME, ID } = this.props;
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
		const { MODULE_NAME, ID, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			let queryParams: any = qs.parse(location.search);
			// 10/13/2020 Paul.  Correct parent found condition. 
			let bParentFound: boolean = (rowDefaultSearch !== undefined && rowDefaultSearch != null);
			if ( !Sql.IsEmptyGuid(queryParams['PARENT_ID']) )
			{
				this.PARENT_ID   = queryParams['PARENT_ID'];
				this.PARENT_TYPE = await Crm_Modules.ParentModule(this.PARENT_ID);
				if ( !Sql.IsEmptyString(this.PARENT_TYPE) )
				{
					rowDefaultSearch = await Crm_Modules.LoadParent(this.PARENT_TYPE, this.PARENT_ID);
					bParentFound = true;
				}
				else
				{
					this.setState( {error: 'Parent ID [' + this.PARENT_ID + '] was not found.'} );
				}
			}
			let sMODULE_NAME  : string = 'Accounts';
			let sSINGULAR_NAME: string = Crm_Modules.SingularModuleName(sMODULE_NAME).toLowerCase();
			let LIST_NAME     : string = 'SqlColumns.' + sMODULE_NAME + '.edit';
			let arrLIST       : string[] = L10n.GetList(LIST_NAME);
			if ( !arrLIST )
			{
				let d = await SystemSqlColumns('Accounts', 'edit');
				if ( d != null && d.results != null && d.results.length > 0 )
				{
					let columns: string[] = [];
					for ( let i: number = 0; i < d.results.length; i++ )
					{
						let row: any = d.results[i];
						let NAME        : string = row['NAME'        ];
						let DISPLAY_NAME: string = row['DISPLAY_NAME'];
						NAME         = sSINGULAR_NAME + '_' + NAME.toLowerCase();
						DISPLAY_NAME = L10n.Term(L10n.BuildTermName('Accounts', DISPLAY_NAME));
						columns.push(NAME);
						SplendidCache.SetTerminology('.' + LIST_NAME + '.' + NAME, DISPLAY_NAME);
					}
					SplendidCache.SetTerminologyList(LIST_NAME, columns);
				}
			}
			sMODULE_NAME   = 'Contacts';
			sSINGULAR_NAME = Crm_Modules.SingularModuleName(sMODULE_NAME).toLowerCase();
			LIST_NAME      = 'SqlColumns.' + sMODULE_NAME + '.edit';
			arrLIST        = L10n.GetList(LIST_NAME);
			if ( !arrLIST )
			{
				let d = await SystemSqlColumns('Contacts', 'edit');
				if ( d != null && d.results != null && d.results.length > 0 )
				{
					let columns: string[] = [];
					for ( let i: number = 0; i < d.results.length; i++ )
					{
						let row: any = d.results[i];
						let NAME        : string = row['NAME'        ];
						let DISPLAY_NAME: string = row['DISPLAY_NAME'];
						NAME         = sSINGULAR_NAME + '_' + NAME.toLowerCase();
						DISPLAY_NAME = L10n.Term(L10n.BuildTermName('Contacts', DISPLAY_NAME));
						columns.push(NAME);
						SplendidCache.SetTerminology('.' + LIST_NAME + '.' + NAME, DISPLAY_NAME);
					}
					SplendidCache.SetTerminologyList(LIST_NAME, columns);
				}
			}
			
			if ( !Sql.IsEmptyGuid(queryParams['CAMPAIGN_ID']) )
			{
				this.CAMPAIGN_ID = queryParams['CAMPAIGN_ID'];
				let sFILTER: string = 'CAMPAIGN_ID eq \'' + this.CAMPAIGN_ID + '\'';
				let d = await ListView_LoadTable('vwCAMPAIGNS_CAMPAIGN_TRKRS', 'NAME', 'asc', 'TRACKER_NAME,TRACKER_URL', sFILTER, null, false);
				if ( d != null && d.results != null && d.results.length > 0 )
				{
					LIST_NAME = 'CampaignTrackers.' + this.CAMPAIGN_ID;
					let campaignTrackers: string[] = [];
					for ( let i: number = 0; i < d.results.length; i++ )
					{
						let row: any = d.results[i];
						let TRACKER_NAME: string = row['TRACKER_NAME'];
						let TRACKER_URL : string = row['TRACKER_URL' ];
						campaignTrackers.push(TRACKER_NAME);
						SplendidCache.SetTerminology('.' + LIST_NAME + '.' + TRACKER_NAME, TRACKER_NAME + ': ' + TRACKER_URL);
					}
					SplendidCache.SetTerminologyList(LIST_NAME, campaignTrackers);
				}
			}
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) )
			{
				// 03/19/2020 Paul.  If we initialize rowDefaultSearch, then we need to set assigned and team values. 
				// 10/13/2020 Paul.  Make the condition more explicit. 
				if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
				{
					rowDefaultSearch = {};
				}
				// 08/10/2020 Paul.  Parent may not initialize user and team fields. 
				if ( !bParentFound || !Crm_Config.ToBoolean('inherit_assigned_user') )
				{
					rowDefaultSearch['ASSIGNED_SET_LIST'] = Security.USER_ID()  ;
					rowDefaultSearch['ASSIGNED_USER_ID' ] = Security.USER_ID()  ;
					rowDefaultSearch['ASSIGNED_TO'      ] = Security.USER_NAME();
					rowDefaultSearch['ASSIGNED_TO_NAME' ] = Security.FULL_NAME();
				}
				if ( !bParentFound || !Crm_Config.ToBoolean('inherit_team') )
				{
					rowDefaultSearch['TEAM_ID'          ] = Security.TEAM_ID()  ;
					rowDefaultSearch['TEAM_NAME'        ] = Security.TEAM_NAME();
					rowDefaultSearch['TEAM_SET_LIST'    ] = Security.TEAM_ID()  ;
					rowDefaultSearch['TEAM_SET_NAME'    ] = Security.TEAM_ID()  ;
				}
				// 03/12/2021 Paul.  Variable lists should be required, so we need to set the default values. 
				rowDefaultSearch['VariableModule'   ] = 'Accounts'   ;
				rowDefaultSearch['VariableName'     ] = 'ID'         ;
				rowDefaultSearch['VariableText'     ] = '$account_id';
			}
			const layout = EditView_LoadLayout(EDIT_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				if ( layout.length > 0 )
				{
					let nSUBJECT_Index: number = -1;
					for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
					{
						let lay = layout[nLayoutIndex];
						let DATA_FIELD = lay.DATA_FIELD;
						switch ( DATA_FIELD )
						{
							case 'TrackerName'  :
								lay.hidden = Sql.IsEmptyGuid(this.CAMPAIGN_ID);
								if ( !Sql.IsEmptyGuid(this.CAMPAIGN_ID) )
									lay.LIST_NAME = 'CampaignTrackers.' + this.CAMPAIGN_ID;
								break;
							case 'TrackerText'  :
								lay.hidden = Sql.IsEmptyGuid(this.CAMPAIGN_ID);
								break;
							case 'TrackerButton':
								lay.hidden = Sql.IsEmptyGuid(this.CAMPAIGN_ID);
								break;
							case 'VariableName':
								lay.LIST_NAME = 'SqlColumns.Accounts.edit';
								break;
							case 'SUBJECT':
								nSUBJECT_Index = nLayoutIndex;
								break;
						}
					}
					// 05/18/2023 Paul.  Allow insert of Survey module. 
					let nACLACCESS_Archive: number = SplendidCache.GetUserAccess('Surveys', 'view', this.constructor.name + '.render');
					if ( nACLACCESS_Archive > 0 && nSUBJECT_Index > 0 )
					{
						let INSERT_SURVEY: any = 
						{
							hidden          : false,
							EDIT_NAME       : layout[nSUBJECT_Index].EDIT_NAME,
							FIELD_INDEX     : nSUBJECT_Index,
							FIELD_TYPE      : 'Label',
							DATA_LABEL      : 'EmailTemplates.LBL_INSERT_SURVEY',
							DATA_FIELD      : '.',
							DATA_FORMAT     : null,
							FORMAT_TAB_INDEX: 1,
							COLSPAN         : 0,
							LABEL_WIDTH     : layout[nSUBJECT_Index].LABEL_WIDTH,
							FIELD_WIDTH     : layout[nSUBJECT_Index].FIELD_WIDTH,
						};
						let SELECT_SURVEY: any = 
						{
							hidden          : false,
							EDIT_NAME       : layout[nSUBJECT_Index].EDIT_NAME,
							FIELD_INDEX     : nSUBJECT_Index,
							FIELD_TYPE      : 'Button',
							DATA_LABEL      : 'EmailTemplates.LBL_SELECT_SURVEY',
							DATA_FIELD      : 'SurveyButton',
							DATA_FORMAT     : 'InsertSurvey',  // This will be the Page_Command. 
							FORMAT_TAB_INDEX: 1,
							COLSPAN         : -1,
							LABEL_WIDTH     : layout[nSUBJECT_Index].LABEL_WIDTH,
							FIELD_WIDTH     : layout[nSUBJECT_Index].FIELD_WIDTH,
						};
						let INCLUDE_CONTACT: any = 
						{
							hidden          : false,
							EDIT_NAME       : layout[nSUBJECT_Index].EDIT_NAME,
							FIELD_INDEX     : nSUBJECT_Index + 1,
							FIELD_TYPE      : 'CheckBox',
							DATA_LABEL      : 'EmailTemplates.LBL_INCLUDE_CONTACT',
							DATA_FIELD      : 'SURVEY_CONTACT',
							DATA_FORMAT     : null,
							FORMAT_TAB_INDEX: 1,
							COLSPAN         : -1,
							LABEL_WIDTH     : layout[nSUBJECT_Index].LABEL_WIDTH,
							FIELD_WIDTH     : layout[nSUBJECT_Index].FIELD_WIDTH,
						};
						let CONTACT_LABEL: any = 
						{
							hidden          : false,
							EDIT_NAME       : layout[nSUBJECT_Index].EDIT_NAME,
							FIELD_INDEX     : nSUBJECT_Index + 1,
							FIELD_TYPE      : 'Label',
							DATA_LABEL      : null,
							DATA_FIELD      : 'EmailTemplates.LBL_INCLUDE_CONTACT',
							DATA_FORMAT     : null,
							FORMAT_TAB_INDEX: 1,
							COLSPAN         : -1,
							LABEL_WIDTH     : layout[nSUBJECT_Index].LABEL_WIDTH,
							FIELD_WIDTH     : layout[nSUBJECT_Index].FIELD_WIDTH,
						};
						let BLANK: any = 
						{
							hidden          : false,
							EDIT_NAME       : layout[nSUBJECT_Index].EDIT_NAME,
							FIELD_INDEX     : nSUBJECT_Index + 2,
							FIELD_TYPE      : 'Blank',
							DATA_LABEL      : null,
							DATA_FIELD      : null,
							DATA_FORMAT     : null,
							FORMAT_TAB_INDEX: null,
							COLSPAN         : null,
							LABEL_WIDTH     : layout[nSUBJECT_Index].LABEL_WIDTH,
							FIELD_WIDTH     : layout[nSUBJECT_Index].FIELD_WIDTH,
						};
						layout.splice(nSUBJECT_Index + 0, 0, INSERT_SURVEY  );
						layout.splice(nSUBJECT_Index + 1, 0, SELECT_SURVEY  );
						layout.splice(nSUBJECT_Index + 2, 0, INCLUDE_CONTACT);
						layout.splice(nSUBJECT_Index + 3, 0, CONTACT_LABEL  );
						layout.splice(nSUBJECT_Index + 4, 0, BLANK          );
					}
				}
				this.setState(
				{
					layout    : layout,
					item      : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem: null,
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
		const { callback, isSearchView, isUpdatePanel } = this.props;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let ATTACHMENTS       : any[] = null;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				if ( item != null )
				{
					// 03/12/2021 Paul.  Variable lists should be required, so we need to set the default values. 
					item['VariableModule'   ] = 'Accounts'   ;
					item['VariableName'     ] = 'ID'         ;
					item['VariableText'     ] = '$account_id';
					ATTACHMENTS = item.ATTACHMENTS;
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						SUB_TITLE         ,
						ATTACHMENTS      ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
		else if ( !callback && !isSearchView && !isUpdatePanel )
		{
			Sql.SetPageTitle(sMODULE_NAME, null, null);
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		let item = this.state.editedItem;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE, item);
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
		const { editedItem } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE, editedItem);
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
		if ( PARENT_FIELD == 'TrackerName' )
		{
			let ref = this.refMap['TrackerText'];
			if ( ref )
			{
				if ( !Sql.IsEmptyString(DATA_VALUE) )
				{
					DATA_VALUE = '{' + DATA_VALUE + '}';
				}
				ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, 'value', item);
				this._onChange('TrackerText', DATA_VALUE);
			}
		}
		else if ( PARENT_FIELD == 'VariableModule' )
		{
			let ref = this.refMap['VariableName'];
			if ( ref )
			{
				DATA_VALUE = 'SqlColumns.' + DATA_VALUE + '.edit';
				ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, 'list', item);
			}
		}
		else if ( PARENT_FIELD == 'VariableName' )
		{
			let ref = this.refMap['VariableText'];
			if ( ref )
			{
				if ( !Sql.IsEmptyString(DATA_VALUE) )
				{
					DATA_VALUE = '$' + DATA_VALUE;
					DATA_VALUE = DATA_VALUE.toLowerCase();
				}
				ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, 'value', item);
				this._onChange('VariableText', DATA_VALUE);
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

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED, item, editedItem } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, editedItem)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( this.state.ATTACHMENTS && this.state.ATTACHMENTS.length > 0 )
						{
							row.ATTACHMENTS = this.state.ATTACHMENTS;
						}
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
							row.ID = await UpdateModule(MODULE_NAME, row, isDuplicate ? null : ID);
							// 10/15/2019 Paul.  Redirect to parent if provided. 
							if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
							{
								history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
							}
							else
							{
								history.push(`/Reset/${MODULE_NAME}/View/` + row.ID);
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
				case 'Cancel':
				{
					// 10/15/2019 Paul.  Redirect to parent if provided. 
					if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
					{
						history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
					}
					break;
				}
				case 'InsertVariable':
				{
					const currentItem = Object.assign({}, item, editedItem);
					let sVariableText: string = Sql.ToString(currentItem['VariableText']);
					if ( !Sql.IsEmptyString(sVariableText) )
					{
						let ref = this.refMap['BODY_HTML'];
						if ( ref )
						{
							ref.current.updateDependancy('VariableText', sVariableText, 'insert', null);
						}
					}
					break;
				}
				case 'InsertTracker':
				{
					let sTrackerText: string = Sql.ToString(editedItem['TrackerText']);
					if ( !Sql.IsEmptyString(sTrackerText) )
					{
						let ref = this.refMap['BODY_HTML'];
						if ( ref )
						{
							ref.current.updateDependancy('TrackerText', sTrackerText, 'insert', null);
						}
					}
					break;
				}
				// 05/18/2023 Paul.  Allow insert of Survey module. 
				case 'InsertSurvey':
				{
					this.setState({ popupOpen: true });
					break;
				}
				case 'SelectSurvey':
				{
					let sPARENT_ID  : string = sCommandArguments['ID'  ];
					let sPARENT_NAME: string = sCommandArguments['NAME'];
					var sURL = this.GetSurveySiteURL() + 'run.aspx?ID=' + sPARENT_ID;
					if ( editedItem && Sql.ToBoolean(editedItem['SURVEY_CONTACT']) )
						sURL += '&PARENT_ID=$contact_id';
					var sSurveyURL = '<a href="' + sURL + '">' + sPARENT_NAME + '</a>';

					if ( !Sql.IsEmptyString(sPARENT_ID) )
					{
						let ref = this.refMap['BODY_HTML'];
						if ( ref )
						{
							ref.current.updateDependancy('SelectSurvey', sSurveyURL, 'insert', null);
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

	protected GetSurveySiteURL = () =>
	{
		let sSurveySiteURL: string = Crm_Config.ToString('Surveys.SurveySiteURL');
		if ( Sql.IsEmptyString(sSurveySiteURL) )
			sSurveySiteURL = Crm_Config.SiteURL() + 'Surveys';
		if ( !EndsWith(sSurveySiteURL, '/') )
			sSurveySiteURL += "/";
		return sSurveySiteURL;
	}

	private _onAddAttachment = () =>
	{
		let { ATTACHMENTS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddAttachment');
		if ( !ATTACHMENTS )
		{
			ATTACHMENTS = [];
		}
		ATTACHMENTS.push({});
		this.setState({ ATTACHMENTS });
	}

	private _onAttachment = (e, index) =>
	{
		let { ATTACHMENTS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachment', index);
		try
		{
			let FILE_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
				if ( file.size > nMaxSize )
				{
					let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
					this.setState({ error });
				}
				else
				{
					// http://www.javascripture.com/FileReader
					let reader = new FileReader();
					reader.onload = () =>
					{
						let arrayBuffer = reader.result;
						let NAME     : string = file.name;
						let TYPE     : string = file.type;
						let DATA     : string = base64ArrayBuffer(arrayBuffer);
						
						let image: any = new Object();
						let arrFileParts = NAME.split('.');
						image.FILENAME       = NAME;
						image.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
						image.FILE_MIME_TYPE = TYPE;
						image.FILE_DATA      = DATA;
						ATTACHMENTS[index] = image;
						this.setState({ ATTACHMENTS });
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachment', error);
		}
	}

	private _onRemoveAttachment = (e, index) =>
	{
		let { ATTACHMENTS } = this.state;
		if ( ATTACHMENTS && index < ATTACHMENTS.length )
		{
			if ( ATTACHMENTS[index].ID )
			{
				ATTACHMENTS[index].deleted = true;
			}
			else
			{
				ATTACHMENTS.splice(index, 1);
			}
			this.setState({ ATTACHMENTS });
		}
	}

	// 04/16/2022 Paul.  Add LayoutTabs to Pacific theme. 
	private _onTabChange = (nActiveTabIndex) =>
	{
		let { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		EditView_ActivateTab(layout, nActiveTabIndex);
		this.setState({ layout });
	}

	// 05/18/2023 Paul.  Allow insert of Survey module. 
	private _onSelectSurvey = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + PARENT_TYPE, value);
		if ( value.Action == 'SingleSelect' )
		{
			this.Page_Command('SelectSurvey', value);
			this.setState({ error: null, popupOpen: false });
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, LAYOUT_NAME, DuplicateID, isSearchView, isUpdatePanel, isQuickCreate, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, ATTACHMENTS, error, popupOpen } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID) )) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
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
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				<DynamicPopupView
					isOpen={ popupOpen }
					callback={ this._onSelectSurvey }
					MODULE_NAME='Surveys'
					multiSelect={ false }
					ClearDisabled={ true }
				/>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ LAYOUT_NAME && LAYOUT_NAME.indexOf('.MassUpdate') < 0
				? <DumpSQL SQL={ __sql } />
				: null
				}
				<LayoutTabs layout={ layout } onTabChange={ this._onTabChange } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command, isSearchView) }
				<div className='tabForm'>
					<div className='tabEditView' style={ {display: 'flex', flexFlow: 'row wrap', width: '100%'} }>
						<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 100%'} }>
							<div id='ctlEditView_Emails_EditView_ATTACHMENTS_LABEL' className='dataLabel' style={ {width: '15%'} }>
								{ L10n.Term('Emails.LBL_ATTACHMENTS') }
							</div>
							<div id='ctlEditView_Emails_EditView_ATTACHMENTS' className='dataField' style={ {width: '85%'} }>
								{ ATTACHMENTS
								? ATTACHMENTS.map((attachment, index) => 
								{
									if ( attachment.deleted )
									{
										return null;
									}
									else if ( attachment.NOTE_ATTACHMENT_ID )
									{
										return (
										<div>
											<a
												id={ attachment.NOTE_ATTACHMENT_ID }
												key={ attachment.NOTE_ATTACHMENT_ID }
												href={ Credentials.RemoteServer + 'Notes/Attachment.aspx?ID=' + attachment.NOTE_ATTACHMENT_ID }
												target='_blank'
											>
												{ attachment.FILENAME }
											</a>
											<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveAttachment(e, index) }>
												<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
											</span>
										</div>);
									}
									else if ( attachment.FILENAME === undefined )
									{
										return (
										<div>
											<input
												type='file'
												onChange={ (e) => this._onAttachment(e, index) }
											/>
										</div>);
									}
									else
									{
										return (
										<div>
											<span
												id={ 'newAttachment_' + index }
												key={ 'newAttachment_' + index }
											>
												{ attachment.FILENAME }
											</span>
											<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveAttachment(e, index) }>
												<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
											</span>
										</div>);
									}
								})
								: null
								}
								<div>
									<button className='button' onClick={ this._onAddAttachment }>{ L10n.Term('Emails.LBL_ADD_FILE') }</button>
								</div>
							</div>
						</div>
					</div>
				</div>
				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
				: null
				}
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

