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
import { RouteComponentProps }                      from '../Router5'                          ;
import moment                                       from 'moment'                                    ;
import { observer }                                 from 'mobx-react'                                ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import { EditComponent }                            from '../../types/EditComponent'                 ;
import { HeaderButtons }                            from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                         ;
import L10n                                         from '../../scripts/L10n'                        ;
import Security                                     from '../../scripts/Security'                    ;
import Credentials                                  from '../../scripts/Credentials'                 ;
import SplendidCache                                from '../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                     from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                  from '../../scripts/Crm'                         ;
import { ToJsonDate, FromJsonDate }                 from '../../scripts/Formatting'                  ;
import { AuthenticatedMethod, LoginRedirect }       from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                         from '../../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_ActivateTab, EditView_ConvertItem, EditView_UpdateREPEAT_TYPE } from '../../scripts/EditView';
import { UpdateModule }                             from '../../scripts/ModuleUpdate'                ;
import { GetInviteesActivities }                    from '../../scripts/CalendarView'                ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'             ;
import { jsonReactState }                           from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'           ;
import DumpSQL                                      from '../../components/DumpSQL'                  ;
import DynamicButtons                               from '../../components/DynamicButtons'           ;
import HeaderButtonsFactory                         from '../../ThemeComponents/HeaderButtonsFactory';
import SchedulingGrid                               from '../../components/SchedulingGrid'           ;
import InviteesView                                 from '../../views/InviteesView'                  ;
// 04/16/2022 Paul.  Add LayoutTabs to Pacific theme. 
import LayoutTabs                                   from '../../components/LayoutTabs'           ;

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
	DuplicateID?       : string;
	ConvertModule?     : string;
	ConvertID?         : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__total            : number;
	__sql              : string;
	__sqlInvitees      : string;
	item               : any;
	layout             : any;
	EDIT_NAME          : string;
	DUPLICATE          : boolean;
	LAST_DATE_MODIFIED : Date;
	SUB_TITLE          : any;
	editedItem         : any;
	dependents         : Record<string, Array<any>>;
	InviteesActivities : any[];
	error              : any;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class CallsEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private PARENT_ID    : string = null;
	private PARENT_TYPE  : string = null;

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
			__sqlInvitees     : null,
			item              ,
			layout            : null,
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			editedItem        : null,
			dependents        : {},
			InviteesActivities: [],
			error             : null
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
		const { MODULE_NAME, ID, DuplicateID, ConvertModule, ConvertID } = this.props;
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
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) && Sql.IsEmptyGuid(ConvertID) )
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
				// 06/03/2020 Paul.  Include self in invitee list. 
				rowDefaultSearch['INVITEE_LIST'    ] = Security.USER_ID()  ;
				rowDefaultSearch['DURATION_MINUTES'] = 15;
				rowDefaultSearch['DURATION_HOURS'  ] = 0;
				if ( !Sql.IsEmptyString(queryParams['DURATION_MINUTES']) )
				{
					let DURATION_MINUTES: number = parseInt(queryParams['DURATION_MINUTES']);
					if ( !isNaN(DURATION_MINUTES) )
					{
						rowDefaultSearch['DURATION_MINUTES'] = DURATION_MINUTES;
					}
				}
				if ( !Sql.IsEmptyString(queryParams['DURATION_HOURS']) )
				{
					let DURATION_HOURS: number = parseInt(queryParams['DURATION_HOURS']);
					if ( !isNaN(DURATION_HOURS) )
					{
						rowDefaultSearch['DURATION_HOURS'] = DURATION_HOURS;
					}
				}
				// 06/03/2020 Paul.  Set start date to around now. 
				let dtNow: Date = new Date();
				dtNow.setMinutes(Math.floor(dtNow.getMinutes() / 15) * 15);
				dtNow.setSeconds(0);
				dtNow.setMilliseconds(0);
				let dtDATE_START: moment.Moment = moment(dtNow       );
				let dtDATE_END  : moment.Moment = moment(dtDATE_START);
				dtDATE_END.add(rowDefaultSearch['DURATION_HOURS'  ], 'hours'  );
				dtDATE_END.add(rowDefaultSearch['DURATION_MINUTES'], 'minutes');
				rowDefaultSearch['DATE_START'      ] = ToJsonDate(dtDATE_START.toDate());
				rowDefaultSearch['DATE_END'        ] = ToJsonDate(dtDATE_END  .toDate());
				if ( !Sql.IsEmptyString(queryParams['DATE_START']) )
				{
					dtDATE_START = moment(queryParams['DATE_START']);
					dtDATE_END   = moment(dtDATE_START);
					dtDATE_END.add(rowDefaultSearch['DURATION_HOURS'  ], 'hours'  );
					dtDATE_END.add(rowDefaultSearch['DURATION_MINUTES'], 'minutes');
					rowDefaultSearch['DATE_START'] = ToJsonDate(dtDATE_START.toDate());
					rowDefaultSearch['DATE_END'  ] = ToJsonDate(dtDATE_END  .toDate());
				}
				if ( !Sql.IsEmptyString(queryParams['DIRECTION']) )
				{
					rowDefaultSearch['DIRECTION'] = queryParams['DIRECTION'];
				}
				if ( !Sql.IsEmptyString(queryParams['STATUS']) )
				{
					rowDefaultSearch['STATUS'] = queryParams['STATUS'];
				}
				rowDefaultSearch['SHOULD_REMIND'] = true;
			}
			let layout: any[] = EditView_LoadLayout(EDIT_NAME);
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
					layout: layout,
					item: (rowDefaultSearch ? rowDefaultSearch : null),
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
					await this.LoadItem(MODULE_NAME, DuplicateID, rowDefaultSearch);
				}
				else if ( !Sql.IsEmptyString(ConvertID) )
				{
					await this.ConvertItem(MODULE_NAME, ConvertModule, ConvertID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID, rowDefaultSearch);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private GetInviteesSchedule = async (dtDATE_START: Date, INVITEE_LIST: string) =>
	{
		let dtSCHEDULE_START: moment.Moment = moment(new Date(dtDATE_START.getFullYear(), dtDATE_START.getMonth(), dtDATE_START.getDate(), dtDATE_START.getHours(), 0, 0, 0));
		dtSCHEDULE_START.add(-4, 'hours');
		let dtSCHEDULE_END  : moment.Moment = moment(dtSCHEDULE_START);
		dtSCHEDULE_END  .add( 9, 'hours');
		let sSCHEDULE_START = ToJsonDate(dtSCHEDULE_START.toDate());
		let sSCHEDULE_END   = ToJsonDate(dtSCHEDULE_END  .toDate());
		const dInvitees = await GetInviteesActivities(sSCHEDULE_START, sSCHEDULE_END, INVITEE_LIST);
		return dInvitees;
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string, rowDefaultSearch: any) =>
	{
		const { callback, isSearchView, isUpdatePanel } = this.props;
		let { layout } = this.state;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				let d: any = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				let InviteesActivities: any[] = null;
				let __sqlInvitees     : string = null;
				if ( item != null )
				{
					// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
					if ( item['DATE_MODIFIED'] !== undefined )
					{
						LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					}
					let dtDATE_START: Date = FromJsonDate(item['DATE_START']);
					const dInvitees = await this.GetInviteesSchedule(dtDATE_START, item['INVITEE_LIST']);
					InviteesActivities = dInvitees.results;
					__sqlInvitees = dInvitees.__sql;
				}
				if ( this._isMounted )
				{
					// 05/03/2020 Paul.  Force lower case. 
					let queryParams: any = qs.parse(location.search.toLowerCase());
					if ( item != null && queryParams['status'] == 'close' )
					{
						item['STATUS'] = 'Held';
					}
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					// 03/18/2020 Paul.  Show/Hide recurrence fields based on the type. 
					let REPEAT_TYPE: string = (item ? item['REPEAT_TYPE'] : null);
					EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
					this.setState(
					{
						item              ,
						layout            ,
						InviteesActivities,
						SUB_TITLE         ,
						__sql             : d.__sql,
						__sqlInvitees     ,
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
			try
			{
				let item              : any = rowDefaultSearch;
				let InviteesActivities: any[] = null;
				let __sqlInvitees     : string = null;
				
				let dtDATE_START: Date = FromJsonDate(item['DATE_START']);
				const dInvitees = await this.GetInviteesSchedule(dtDATE_START, item['INVITEE_LIST']);
				InviteesActivities = dInvitees.results;
				__sqlInvitees = dInvitees.__sql;
				this.setState(
				{
					InviteesActivities,
					__sqlInvitees     ,
				});
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	private ConvertItem = async (sMODULE_NAME: string, sSOURCE_MODULE_NAME: string, sSOURCE_ID: string) =>
	{
		let { layout } = this.state;
		if ( !Sql.IsEmptyString(sSOURCE_ID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				let InviteesActivities: any[] = null;
				let __sqlInvitees     : string = null;
				if ( item != null )
				{
					let dtDATE_START: Date = FromJsonDate(item['DATE_START']);
					const dInvitees = await this.GetInviteesSchedule(dtDATE_START, item['INVITEE_LIST']);
					InviteesActivities = dInvitees.results;
					__sqlInvitees = dInvitees.__sql;
				}
				if ( this._isMounted )
				{
					let item: any = d.results;
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					// 03/18/2020 Paul.  Show/Hide recurrence fields based on the type. 
					let REPEAT_TYPE: string = (item ? item['REPEAT_TYPE'] : null);
					EditView_UpdateREPEAT_TYPE(layout, REPEAT_TYPE);
					this.setState(
					{
						item              ,
						layout            ,
						InviteesActivities,
						SUB_TITLE         ,
						__sql             : d.__sql,
						__sqlInvitees     ,
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
			// 10/13/2020 Paul.  Update DATE_END any time start date or duration changes. 
			if ( DATA_FIELD == 'ALL_DAY_EVENT' || DATA_FIELD == 'DURATION_MINUTES' || DATA_FIELD == 'DURATION_HOURS' || DATA_FIELD == 'DATE_START' )
			{
				let dtDATE_START: moment.Moment = moment(FromJsonDate(item['DATE_START']));
				let dtDATE_END  : moment.Moment = moment(dtDATE_START);
				dtDATE_END.add(item['DURATION_HOURS'  ], 'hours'  );
				dtDATE_END.add(item['DURATION_MINUTES'], 'minutes');
				item['DATE_END'] = ToJsonDate(dtDATE_END  .toDate());
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
		else if ( PARENT_FIELD == 'DATE_START' )
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let dtDATE_START: Date = FromJsonDate(DATA_VALUE);
			this.GetInviteesSchedule(dtDATE_START, currentItem['INVITEE_LIST']).then((d) =>
			{
				this.setState(
				{
					InviteesActivities: d.results,
					__sqlInvitees     : d.__sql
				});
			})
			.catch((error) =>
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
				this.setState({ error });
			});
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
				// 01/23/2021 Paul.  Add send invites button. 
				case 'Save.SendInvites':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						// 06/14/2020 Paul.  The invitee list is not part of the row data, so add manually. 
						row['INVITEE_LIST'] = this._getInviteeList().join(',');
						// 08/26/2019 Paul.  The layout field is DATE_START, but the stored procedure field is DATE_TIME.  Correct here. 
						row['DATE_TIME'] = row['DATE_START'];
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
									// 01/23/2021 Paul.  Update the last modified to prevent a concurrency error if the user tries to save again. 
									let LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
									this.setState({ item, LAST_DATE_MODIFIED });
									let res = await CreateSplendidRequest('Rest.svc/SendActivityInvites', 'POST', 'application/json; charset=utf-8', sBody);
									let json = await GetSplendidResult(res);
								}
							}
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

	private _getInviteeList = () =>
	{
		let { item, editedItem } = this.state;
		const currentItem = Object.assign({}, item, editedItem);
		let arrINVITEE_LIST: string[] = [];
		if ( !Sql.IsEmptyString(currentItem['INVITEE_LIST']) )
		{
			arrINVITEE_LIST = currentItem['INVITEE_LIST'].split(',');
		}
		return arrINVITEE_LIST;
	}

	private _onRemoveInvitee = (INVITEE_ID: string) =>
	{
		let { editedItem } = this.state;
		let arrINVITEE_LIST: string[] = this._getInviteeList();
		if ( arrINVITEE_LIST.indexOf(INVITEE_ID) >= 0 )
		{
			arrINVITEE_LIST.splice(arrINVITEE_LIST.indexOf(INVITEE_ID), 1);
		}
		let INVITEE_LIST: string = arrINVITEE_LIST.join(',');
		if ( editedItem == null )
			editedItem = {};
		editedItem['INVITEE_LIST'] = INVITEE_LIST;
		this.setState({ editedItem });
	}

	private _onAddInvitee = (INVITEE_ID: string) =>
	{
		let { item, editedItem } = this.state;
		const currentItem = Object.assign({}, item, editedItem);
		let arrINVITEE_LIST: string[] = this._getInviteeList();
		if ( arrINVITEE_LIST.indexOf(INVITEE_ID) < 0 )
		{
			arrINVITEE_LIST.push(INVITEE_ID);
		}
		let INVITEE_LIST: string = arrINVITEE_LIST.join(',');
		if ( editedItem == null )
			editedItem = {};
		editedItem['INVITEE_LIST'] = INVITEE_LIST;
		
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddInvitee', INVITEE_LIST);
		let dtDATE_START: Date = FromJsonDate(currentItem['DATE_START']);
		this.GetInviteesSchedule(dtDATE_START, INVITEE_LIST).then((d) =>
		{
			let InviteesActivities: any[] = d.results;
			this.setState(
			{
				editedItem        ,
				InviteesActivities,
				__sqlInvitees     : d.__sql
			});
		})
		.catch((error) =>
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddInvitee', error);
		});
	}

	// 04/16/2022 Paul.  Add LayoutTabs to Pacific theme. 
	private _onTabChange = (nActiveTabIndex) =>
	{
		let { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		EditView_ActivateTab(layout, nActiveTabIndex);
		this.setState({ layout });
	}

	public render()
	{
		const { MODULE_NAME, ID, DuplicateID, ConvertID, isSearchView, isUpdatePanel, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, InviteesActivities, error } = this.state;
		const { __total, __sql, __sqlInvitees } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		// 09/18/2019 Paul.  Include ConvertID. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID) || !Sql.IsEmptyString(ConvertID))) )
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
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<LayoutTabs layout={ layout } onTabChange={ this._onTabChange } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
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
				<SchedulingGrid
					DATE_START={ currentItem['DATE_START'] }
					DURATION_HOURS={ Sql.ToInteger(currentItem['DURATION_HOURS']) }
					DURATION_MINUTES={ Sql.ToInteger(currentItem['DURATION_MINUTES']) }
					INVITEE_LIST={ Sql.ToString(currentItem['INVITEE_LIST']) }
					InviteesActivities={ InviteesActivities }
					onRemoveInvitee={ this._onRemoveInvitee }
					__sql={ __sqlInvitees }
				/>
				<InviteesView
					MODULE_NAME={ MODULE_NAME }
					DATE_START={ currentItem['DATE_START'] }
					DURATION_HOURS={ Sql.ToInteger(currentItem['DURATION_HOURS']) }
					DURATION_MINUTES={ Sql.ToInteger(currentItem['DURATION_MINUTES']) }
					onAddInvitee={ this._onAddInvitee }
				/>
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

