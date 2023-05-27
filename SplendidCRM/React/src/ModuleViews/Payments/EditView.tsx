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
import { RouteComponentProps, withRouter }          from 'react-router-dom'                      ;
import moment                                       from 'moment'                                ;
import { observer }                                 from 'mobx-react'                            ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'        ;
// 2. Store and Types. 
import { EditComponent }                            from '../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../types/HeaderButtons'             ;
import EDITVIEWS_FIELD                              from '../../types/EDITVIEWS_FIELD'           ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                     ;
import L10n                                         from '../../scripts/L10n'                    ;
import Security                                     from '../../scripts/Security'                ;
import Credentials                                  from '../../scripts/Credentials'             ;
import SplendidCache                                from '../../scripts/SplendidCache'           ;
import SplendidDynamic_EditView                     from '../../scripts/SplendidDynamic_EditView';
import { Crm_Config, Crm_Modules }                  from '../../scripts/Crm'                     ;
import { formatCurrency, formatNumber }             from '../../scripts/Formatting'              ;
import { ToJsonDate, FromJsonDate }                 from '../../scripts/Formatting'              ;
import { AuthenticatedMethod, LoginRedirect }       from '../../scripts/Login'                   ;
import { sPLATFORM_LAYOUT }                         from '../../scripts/SplendidInitUI'          ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_ConvertItem, EditView_HideField } from '../../scripts/EditView';
import { UpdateModule }                             from '../../scripts/ModuleUpdate'            ;
import { jsonReactState }                           from '../../scripts/Application'             ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'       ;
import DumpSQL                                      from '../../components/DumpSQL'              ;
import DynamicButtons                               from '../../components/DynamicButtons'       ;
import HeaderButtonsFactory                         from '../../ThemeComponents/HeaderButtonsFactory';
// 10/09/2022 Paul.  Add Payments.SummaryView. 
import PaymentsLineItems                            from './PaymentsLineItems'                       ;

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
	item               : any;
	layout             : any;
	EDIT_NAME          : string;
	DUPLICATE          : boolean;
	LAST_DATE_MODIFIED : Date;
	SUB_TITLE          : any;
	editedItem         : any;
	dependents         : Record<string, Array<any>>;
	error              : any;
}

@observer
export default class PaymentsEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted    : boolean = false;
	private refMap        : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private lineItems     = React.createRef<PaymentsLineItems>();
	private PARENT_ID     : string = null;
	private PARENT_TYPE   : string = null;

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME: string = props.MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
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
			// 10/15/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			let queryParams: any = qs.parse(location.search);
			// 10/13/2020 Paul.  Correct parent found condition. 
			let bParentFound: boolean = (rowDefaultSearch !== undefined && rowDefaultSearch != null);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', queryParams);
			let PARENT_ID: string = queryParams['PARENT_ID'];
			// 11/18/2021 Paul.  When used inline, the parent will be defined in rowDefaultSearch
			if ( Sql.IsEmptyGuid(PARENT_ID) && bParentFound )
			{
				PARENT_ID = rowDefaultSearch['PARENT_ID'];
			}
			if ( !Sql.IsEmptyGuid(PARENT_ID) )
			{
				this.PARENT_ID   = PARENT_ID;
				this.PARENT_TYPE = await Crm_Modules.ParentModule(this.PARENT_ID);
				if ( !Sql.IsEmptyString(this.PARENT_TYPE) )
				{
					rowDefaultSearch = await this.LoadParent(this.PARENT_TYPE, this.PARENT_ID);
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
				rowDefaultSearch['BANK_FEE'        ] = '0.00';
				// 05/06/2022 Paul.  Default Payment Date to today. 
				let dtNow: Date = new Date();
				let dtPAYMENT_DATE: moment.Moment = moment(dtNow);
				rowDefaultSearch['PAYMENT_DATE'    ] = ToJsonDate(dtPAYMENT_DATE.toDate());
			}
			const layout = EditView_LoadLayout(EDIT_NAME);
			// 05/06/2022 Paul.  Hide CREDIT_CARD_ID if not Credit Card payment type. 
			let PAYMENT_TYPE: string = null;
			let lstPAYMENT_TYPE: any[] = L10n.GetList('payment_type_dom')
			if ( lstPAYMENT_TYPE != null && lstPAYMENT_TYPE.length > 0 )
				PAYMENT_TYPE= lstPAYMENT_TYPE[0];
			this.PAYMENT_TYPE_Changed(layout, PAYMENT_TYPE);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout    ,
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
				else if ( !Sql.IsEmptyString(ConvertID) )
				{
					await this.ConvertItem(MODULE_NAME, ConvertModule, ConvertID);
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
		const { callback, isSearchView, isUpdatePanel, DuplicateID } = this.props;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					this.PAYMENT_TYPE_Changed(this.state.layout, item['PAYMENT_TYPE']);
				}
				if ( this._isMounted )
				{
					// 10/02/2017 Paul.  We needed to make sure that the number gets reset when copying a record. 
					if ( item != null && !Sql.IsEmptyString(DuplicateID) )
					{
						item['PAYMENT_NUM'] = null;
					}
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
		else if ( !callback && !isSearchView && !isUpdatePanel )
		{
			Sql.SetPageTitle(sMODULE_NAME, null, null);
		}
	}

	private ConvertItem = async (sMODULE_NAME: string, sSOURCE_MODULE_NAME: string, sSOURCE_ID: string) =>
	{
		if ( !Sql.IsEmptyString(sSOURCE_ID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID);
				let LAST_DATE_MODIFIED: Date = null;
				if ( this._isMounted )
				{
					let item: any = d.results;
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

	private LoadParent = async (sPARENT_TYPE: string, sID: string) =>
	{
		let rowDefaultSearch: any = null;
		if ( !Sql.IsEmptyString(sPARENT_TYPE) && !Sql.IsEmptyString(sID) )
		{
			let oNumberFormat = Security.NumberFormatInfo();
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sPARENT_TYPE, sID);
				let item: any = d.results;
				if ( this._isMounted && item != null )
				{
					rowDefaultSearch = {};
					if ( sPARENT_TYPE == 'Accounts' )
					{
						rowDefaultSearch['ACCOUNT_ID'       ] = item['ID'               ];
						rowDefaultSearch['ACCOUNT_NAME'     ] = item['NAME'             ];
					}
					else if ( sPARENT_TYPE == 'Contacts' )
					{
						rowDefaultSearch['B2C_CONTACT_ID'   ] = item['ID'               ];
						rowDefaultSearch['B2C_CONTACT_NAME' ] = item['NAME'             ];
					}
					else if ( sPARENT_TYPE == 'Invoices' )
					{
						rowDefaultSearch['ACCOUNT_ID'         ] = item['BILLING_ACCOUNT_ID'  ];
						rowDefaultSearch['ACCOUNT_NAME'       ] = item['BILLING_ACCOUNT_NAME'];
						rowDefaultSearch['B2C_CONTACT_ID'     ] = item['BILLING_CONTACT_ID'  ];
						rowDefaultSearch['B2C_CONTACT_NAME'   ] = item['BILLING_CONTACT_NAME'];
						rowDefaultSearch['AMOUNT'             ] = formatNumber(item['AMOUNT_DUE'         ], oNumberFormat);
						rowDefaultSearch['AMOUNT_USDOLLAR'    ] = Sql.ToDecimal(item['AMOUNT_DUE_USDOLLAR']);
						rowDefaultSearch['TOTAL'              ] = formatNumber(item['AMOUNT_DUE'         ], oNumberFormat);
						rowDefaultSearch['TOTAL_USDOLLAR'     ] = Sql.ToDecimal(item['AMOUNT_DUE_USDOLLAR']);

						// 10/09/2022 Paul.  Add Payments.SummaryView. 
						let LineItems: any[] = [];
						let line: any = {};
						line['INVOICE_NAME'       ] = Sql.ToString (item['NAME'               ]);
						line['INVOICE_ID'         ] = Sql.ToGuid   (item['ID'                 ]);
						line['AMOUNT_DUE'         ] = formatNumber(item['AMOUNT_DUE'         ], oNumberFormat);
						line['AMOUNT_DUE_USDOLLAR'] = Sql.ToDecimal(item['AMOUNT_DUE_USDOLLAR']);
						line['AMOUNT'             ] = formatNumber(item['AMOUNT_DUE'         ], oNumberFormat);
						line['AMOUNT_USDOLLAR'    ] = Sql.ToDecimal(item['AMOUNT_DUE_USDOLLAR']);
						// 02/25/2008 Paul.  If AMOUNT_DUE has not been computed, then use the TOTAL. 
						if ( item['AMOUNT_DUE'] == null )
						{
							line['AMOUNT_DUE'         ] = formatNumber(item['TOTAL'         ], oNumberFormat);
							line['AMOUNT_DUE_USDOLLAR'] = Sql.ToDecimal(item['TOTAL_USDOLLAR']);
							line['AMOUNT'             ] = formatNumber(item['TOTAL'         ], oNumberFormat);
							line['AMOUNT_USDOLLAR'    ] = Sql.ToDecimal(item['TOTAL_USDOLLAR']);
						}
						LineItems.push(line);
						rowDefaultSearch['LineItems'] = LineItems;
					}
					if ( Crm_Config.ToBoolean('inherit_assigned_user') )
					{
						rowDefaultSearch['ASSIGNED_USER_ID' ] = item['ASSIGNED_USER_ID' ];
						rowDefaultSearch['ASSIGNED_TO'      ] = item['ASSIGNED_TO'      ];
						rowDefaultSearch['ASSIGNED_TO_NAME' ] = item['ASSIGNED_TO_NAME' ];
						rowDefaultSearch['ASSIGNED_SET_ID'  ] = item['ASSIGNED_SET_ID'  ];
						rowDefaultSearch['ASSIGNED_SET_LIST'] = item['ASSIGNED_SET_LIST'];
						rowDefaultSearch['ASSIGNED_SET_NAME'] = item['ASSIGNED_SET_NAME'];
					}
					else
					{
						// 10/12/2019 Paul.  If we are providing defaults, then we need to provide user and team defaults. 
						rowDefaultSearch['ASSIGNED_USER_ID' ]  = Security.USER_ID()  ;
						rowDefaultSearch['ASSIGNED_TO'      ]  = Security.USER_NAME();
						rowDefaultSearch['ASSIGNED_TO_NAME' ]  = Security.FULL_NAME();
					}
					if ( Crm_Config.ToBoolean('inherit_team') )
					{
						rowDefaultSearch['TEAM_ID'          ] = item['TEAM_ID'      ];
						rowDefaultSearch['TEAM_NAME'        ] = item['TEAM_NAME'    ];
						rowDefaultSearch['TEAM_SET_ID'      ] = item['TEAM_SET_ID'  ];
						rowDefaultSearch['TEAM_SET_LIST'    ] = item['TEAM_SET_LIST'];
						rowDefaultSearch['TEAM_SET_NAME'    ] = item['TEAM_SET_NAME'];
					}
					else
					{
						// 10/12/2019 Paul.  If we are providing defaults, then we need to provide user and team defaults. 
						rowDefaultSearch['TEAM_ID'          ] = Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_NAME'        ] = Security.TEAM_NAME();
						rowDefaultSearch['TEAM_SET_LIST'    ] = Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_SET_NAME'    ] = Security.TEAM_ID()  ;
					}
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadParent', error);
				this.setState({ error });
			}
		}
		return rowDefaultSearch;
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
			if ( DATA_FIELD == 'AMOUNT' )
				this.UpdateDependancy(DATA_FIELD, DATA_VALUE);
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

	// 11/18/2021 Paul.  The Credit Card ChangeButton requires the ACCOUNT_ID. 
	private UpdateDependancy(DATA_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any)
	{
		let ref = this.refMap[DATA_FIELD];
		if ( ref && ref.current )
		{
			ref.current.updateDependancy(null, DATA_VALUE, PROPERTY_NAME, item);
		}
	}

	private _onUpdate = async (PARENT_FIELD: string, DATA_VALUE: any, item?: any) =>
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
		// 11/18/2021 Paul.  The Credit Card ChangeButton requires the ACCOUNT_ID. 
		if ( PARENT_FIELD == 'ACCOUNT_ID' && item != null )
		{
			const d = await EditView_LoadItem('Accounts', item.ID);
			let account: any = d.results;
			if ( this._isMounted && account != null )
			{
				let rowDefaultSearch: any =
				{
					ACCOUNT_ID     : account['ID'  ],
					ACCOUNT_NAME   : account['NAME'],
				};
				this.UpdateDependancy('CREDIT_CARD_ID', rowDefaultSearch, 'rowDefaultSearch', null);
			}
		}
		else if ( PARENT_FIELD == 'PAYMENT_TYPE' )
		{
			this.PAYMENT_TYPE_Changed(this.state.layout, DATA_VALUE);
		}
	}

	private PAYMENT_TYPE_Changed = (layout: EDITVIEWS_FIELD[], PAYMENT_TYPE: string) =>
	{
		EditView_HideField(layout, 'CREDIT_CARD_ID', !(PAYMENT_TYPE == 'Credit Card'));
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Charge', (PAYMENT_TYPE == 'Credit Card'));
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Charge', (PAYMENT_TYPE == 'Credit Card'));
		}
	}

	// 11/18/2021 Paul.  The Credit Card ChangeButton requires the ACCOUNT_ID. 
	private _onFieldDidMount = (DATA_FIELD: string, component: any): void =>
	{
		const { DuplicateID } = this.props;
		const { item } = this.state;
		let { layout } = this.state;
		try
		{
			if ( item )
			{
				if ( DATA_FIELD == 'CREDIT_CARD_ID' )
				{
					let rowDefaultSearch: any =
					{
						ACCOUNT_ID     : item['ACCOUNT_ID'  ],
						ACCOUNT_NAME   : item['ACCOUNT_NAME'],
					};
					this.UpdateDependancy('CREDIT_CARD_ID', rowDefaultSearch, 'rowDefaultSearch', null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount ' + DATA_FIELD, error.message);
			this.setState({ error });
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
				case 'Charge':
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 05/06/2022 Paul.  When PARENT_ID is provided, spINVOICES_PAYMENTS_Update gets called. 
					if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
					{
						row.PARENT_ID = this.PARENT_ID;
					}
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( Sql.IsEmptyString(row['PAYMENT_DATE']) || sCommandName == 'Charge' )
						{
							let dtNow: Date = new Date();
							let dtPAYMENT_DATE: moment.Moment = moment(dtNow);
							row['PAYMENT_DATE'] = ToJsonDate(dtPAYMENT_DATE.toDate());
						}
						// 10/09/2022 Paul.  Add Payments.SummaryView. 
						Object.assign(row, this.lineItems.current.data);
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
							// 05/08/2022 Paul.   Charge after saving. 
							if ( sCommandName == 'Charge' )
							{
								let res = await CreateSplendidRequest('Payments/Rest.svc/Charge?ID=' + ID, 'POST', 'application/octet-stream', null);
								let json = await GetSplendidResult(res);
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

	private _onButtonsLoaded = async () =>
	{
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		// 05/06/2022 Paul.  PAYMENT_TYPE controls display of Charge Now. 
		let PAYMENT_TYPE: string = currentItem['PAYMENT_TYPE'];
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Charge', (PAYMENT_TYPE == 'Credit Card'));
			// 05/06/2022 Paul.  No customers are using multiple payment gateways, so just disable. 
			this.headerButtons.current.ShowButton('SelectGateway', false);
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Charge', (PAYMENT_TYPE == 'Credit Card'));
			// 05/06/2022 Paul.  No customers are using multiple payment gateways, so just disable. 
			this.dynamicButtonsBottom.current.ShowButton('SelectGateway', false);
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, DuplicateID, ConvertID, isSearchView, isUpdatePanel, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { __total, __sql } = this.state;
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
		if ( SplendidCache.IsInitialized )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			// 10/09/2022 Paul.  Add Payments.SummaryView. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div style={ {width: '100%'} }>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, (isSearchView ? null : 'tabForm'), this.Page_Command) }
				<PaymentsLineItems ID={ ID } row={ item } onChanged={ this._onChange } ref={ this.lineItems } />
				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					onLayoutLoaded={ this._onButtonsLoaded }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
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

// 07/18/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

