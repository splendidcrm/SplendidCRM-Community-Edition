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
import posed                                  from 'react-pose'                       ;
import { RouteComponentProps, withRouter }    from 'react-router-dom'                 ;
import { observer }                           from 'mobx-react'                       ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'   ;
import { Appear }                             from 'react-lifecycle-appear'           ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP               from '../../../types/DETAILVIEWS_RELATIONSHIP';
import RELATIONSHIPS                          from '../../../types/RELATIONSHIPS'           ;
import { SubPanelHeaderButtons }              from '../../../types/SubPanelHeaderButtons'   ;
// 3. Scripts. 
import Sql                                    from '../../../scripts/Sql'                   ;
import L10n                                   from '../../../scripts/L10n'                  ;
import Credentials                            from '../../../scripts/Credentials'           ;
import SplendidCache                          from '../../../scripts/SplendidCache'         ;
import { DynamicLayout_Module }               from '../../../scripts/DynamicLayout'         ;
import { AuthenticatedMethod, LoginRedirect } from '../../../scripts/Login'                 ;
import { Crm_Config, Crm_Modules }            from '../../../scripts/Crm'                   ;
import { EndsWith }                           from '../../../scripts/utility'               ;
import { UpdateModule, UpdateRelatedItem, UpdateRelatedValues, DeleteRelatedValue } from '../../../scripts/ModuleUpdate';
// 4. Components and Views. 
import ErrorComponent                         from '../../../components/ErrorComponent'    ;
import SplendidGrid                           from '../../../components/SplendidGrid'      ;
import DynamicButtons                         from '../../../components/DynamicButtons'    ;
import SearchView                             from '../../../views/SearchView'             ;
import PopupView                              from '../../../views/PopupTermList'          ;
import EditView                               from '../../../views/EditView'               ;
import SubPanelButtonsFactory                 from '../../../ThemeComponents/SubPanelButtonsFactory';

const Content = posed.div(
{
	open:
	{
		height: '100%'
	},
	closed:
	{
		height: 0
	}
});

interface ISubPanelViewProps extends RouteComponentProps<any>
{
	PARENT_TYPE      : string;
	row              : any;
	layout           : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME: string;
	disableView?     : boolean;
	disableEdit?     : boolean;
	disableRemove?   : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface ISubPanelViewState
{
	PARENT_ID        : string;
	RELATED_MODULE?  : string;
	GRID_NAME?       : string;
	TABLE_NAME?      : string;
	SORT_FIELD?      : string;
	SORT_DIRECTION?  : string;
	PRIMARY_FIELD?   : string;
	PRIMARY_ID?      : string;
	JOIN_TABLE       : string;
	PARENT_ID_FIELD  : string;
	showCancel       : boolean;
	showFullForm     : boolean;
	showTopButtons   : boolean;
	showBottomButtons: boolean;
	showSearch       : boolean;
	showInlineEdit   : boolean;
	multiSelect      : boolean;
	popupOpen        : boolean;
	archiveView      : boolean;
	item?            : any;
	rowInitialValues : any;
	dependents?      : Record<string, Array<any>>;
	error?           : any;
	open             : boolean;
	customView       : any;
	subPanelVisible  : boolean;
}

@observer
class RegionsCountries extends React.Component<ISubPanelViewProps, ISubPanelViewState>
{
	private _isMounted = false;

	private searchView           = React.createRef<SearchView>();
	private splendidGrid         = React.createRef<SplendidGrid>();
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private editView             = React.createRef<EditView>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();

	constructor(props: ISubPanelViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + props.PARENT_TYPE, props.layout);
		let archiveView: boolean = false;
		let GRID_NAME  : string = props.PARENT_TYPE + '.' + props.layout.CONTROL_NAME;
		if ( props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
			// 01/27/2020 Paul.  Contacts.Activities.History.ArchiveView is not correct.  We simplified to Contacts.Activities.ArchiveView. 
			if ( props.layout.CONTROL_NAME == 'Activities.History' )
			{
				GRID_NAME = props.PARENT_TYPE + '.Activities.ArchiveView';
			}
			else
			{
				GRID_NAME  += '.ArchiveView';
			}
		}
		let rowPARENT: any = props.row;
		let rowInitialValues: any = {};
		// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
		rowInitialValues['DetailViewRelationshipCreate'] = true;
		rowInitialValues['PARENT_ID'  ] = rowPARENT.ID  ;
		rowInitialValues['PARENT_NAME'] = rowPARENT.NAME;
		// 01/30/2013 Paul.  Include the parent type to make sure that the dropdown is set properly for an activity record. 
		rowInitialValues['PARENT_TYPE'] = props.PARENT_TYPE;

		let JOIN_TABLE        = null;
		let PARENT_TABLE      = Crm_Modules.TableName(props.PARENT_TYPE);
		let PARENT_ID_FIELD   = Crm_Modules.SingularTableName(PARENT_TABLE) + '_ID'  ;
		let PARENT_NAME_FIELD = Crm_Modules.SingularTableName(PARENT_TABLE) + '_NAME';
		rowInitialValues[PARENT_ID_FIELD  ] = rowPARENT.ID  ;
		rowInitialValues[PARENT_NAME_FIELD] = rowPARENT.NAME;
		
		let multiSelect: boolean = true;
		// 11/10/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen        : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open           : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		// 11/05/2020 Paul.  Copy initial values so that we can reuse. 
		let item: any = Object.assign({}, rowInitialValues);
		this.state =
		{
			PARENT_ID        : props.row.ID,
			RELATED_MODULE   : props.layout.MODULE_NAME,
			GRID_NAME        ,
			TABLE_NAME       : props.layout.TABLE_NAME,
			SORT_FIELD       : props.layout.SORT_FIELD,
			SORT_DIRECTION   : props.layout.SORT_DIRECTION,
			PRIMARY_FIELD    : props.layout.PRIMARY_FIELD,
			PRIMARY_ID       : props.row.ID,
			JOIN_TABLE       ,
			PARENT_ID_FIELD  ,
			showCancel       : true,
			showFullForm     : true,
			showTopButtons   : true,
			showBottomButtons: true,
			showSearch       : false,
			showInlineEdit   : false,
			multiSelect      ,
			popupOpen        : false,
			archiveView      ,
			item             ,
			rowInitialValues ,
			dependents       : {},
			error            : null,
			open             ,
			customView       : null,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
		};
	}

	async componentDidMount()
	{
		const { RELATED_MODULE } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		const { CONTROL_VIEW_NAME } = this.props;
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, CONTROL_VIEW_NAME, data);
			}
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(sFILTER, row, oSORT);
		}
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { showSearch, showInlineEdit } = this.state;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
				{
					let RELATED_MODULE: string = null;
					if ( sCommandName.indexOf('.') >= 0 )
					{
						RELATED_MODULE = sCommandName.split('.')[0];
					}
					let customView = await DynamicLayout_Module(RELATED_MODULE, 'EditViews', 'EditView.Inline');
					if ( customView )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command found ' + RELATED_MODULE + '.EditView.Inline');
					}
					this.setState({ showSearch: false, showInlineEdit: true, RELATED_MODULE, customView });
				}
				else if ( sCommandName == 'Select' || EndsWith(sCommandName, '.Select') )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command show Select');
					this.setState({ popupOpen: true });
				}
				// 10/15/2020 Paul.  There are currently 5 multi-selects, Regions, Roles, Teams, Users and ZipCodes. 
				else if ( sCommandName == 'MultiSelect' || EndsWith(sCommandName, 'MultiSelect();') )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command show Select');
					this.setState({ popupOpen: true, multiSelect: true });
				}
				// 04/20/2020 Paul.  SearchOpen and SearchHistory are on the Activities panels. 
				else if ( sCommandName == 'Search' || EndsWith(sCommandName, '.Search') || EndsWith(sCommandName, '.SearchOpen') || EndsWith(sCommandName, '.SearchHistory') )
				{
					this.setState({ showSearch: !showSearch, showInlineEdit: false });
				}
				else if ( sCommandName == 'NewRecord' )
				{
					await this.Save();
				}
				else if ( sCommandName == 'NewRecord.Cancel' )
				{
					this.setState({ showInlineEdit: false, customView: null });
				}
				else if ( sCommandName == 'NewRecord.FullForm' )
				{
					// 06/28/2019 Paul.  Reset to new edit view with parent ID. 
					// 10/12/2019 Paul.  Support Full Form. 
					this.props.history.push(`/Reset/${RELATED_MODULE}/Edit?PARENT_ID=${PARENT_ID}`);
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command: Unknown command ' + sCommandName);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private Save = async () =>
	{
		const { PARENT_TYPE } = this.props;
		const { PARENT_ID, RELATED_MODULE, JOIN_TABLE, PARENT_ID_FIELD } = this.state;
		try
		{
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + PARENT_TYPE, row);
				try
				{
					// 01/08/2020 Paul.  Disable buttons before update. 
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', false);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.Busy();
					}
					if ( this.dynamicButtonsBottom.current != null )
					{
						this.dynamicButtonsBottom.current.EnableButton('NewRecord', false);
					}
					let sID = await UpdateModule(RELATED_MODULE, row, null);
					// 04/20/2020 Paul.  Notes is special in that it uses the parent to establish the relationship. 
					// 10/12/2020 Paul.  All the activity tables use parent to establish relationship.  So only manually relate if there is a join table. 
					if ( !Sql.IsEmptyString(JOIN_TABLE) && PARENT_ID_FIELD != 'parent_id' )
					{
						let sPRIMARY_MODULE = PARENT_TYPE   ;
						let sPRIMARY_ID     = PARENT_ID     ;
						let sRELATED_MODULE = RELATED_MODULE;
						let sRELATED_ID     = sID           ;
						await UpdateRelatedItem(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_MODULE, sRELATED_ID);
					}
					if ( this._isMounted )
					{
						// 07/18/2019 Paul.  We also need to clear the input fields. 
						if ( this.editView.current != null )
						{
							this.editView.current.clear();
						}
						// 07/13/2019 Paul.  Call SubmitSearch directly. 
						if ( this.searchView.current != null )
						{
							this.searchView.current.SubmitSearch();
						}
						// 03/17/2020 Paul.  Set the state after clearing the form, otherwise this.editView.current will be null. 
						// 03/17/2020 Paul.  Clear the local item as well. 
						// 11/05/2020 Paul.  Copy initial values so that we can reuse. 
						let item: any = Object.assign({}, this.state.rowInitialValues);
						this.setState({ showInlineEdit: false, item });
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
					if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
					{
						if ( this.dynamicButtonsTop.current != null )
						{
							this.dynamicButtonsTop.current.ShowButton('SaveDuplicate', true);
						}
						if ( this.dynamicButtonsBottom.current != null )
						{
							this.dynamicButtonsBottom.current.ShowButton('SaveDuplicate', true);
						}
						this.setState( {error: L10n.Term(error.message) } );
					}
					else
					{
						this.setState({ error });
					}
				}
				finally
				{
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', true);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.NotBusy();
					}
					if ( this.dynamicButtonsBottom.current != null )
					{
						this.dynamicButtonsBottom.current.EnableButton('NewRecord', true);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			this.setState({ error });
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	private _onSelect = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		const { PARENT_TYPE } = this.props;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + PARENT_TYPE, value);
		if ( value.Action == 'SingleSelect' )
		{
			try
			{
				let sPRIMARY_MODULE = PARENT_TYPE   ;
				let sPRIMARY_ID     = PARENT_ID     ;
				let sRELATED_TABLE  = 'COUNTRIES'   ;
				let arrRELATED_VALUES = [];
				// 10/17/2020 Paul.  ID is lower case, so use NAME. 
				arrRELATED_VALUES.push(value.NAME);
				await UpdateRelatedValues(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_TABLE, arrRELATED_VALUES);
				if ( this._isMounted )
				{
					this.setState({ popupOpen: false }, () =>
					{
						// 07/13/2019 Paul.  Call SubmitSearch directly. 
						if ( this.searchView.current != null )
						{
							this.searchView.current.SubmitSearch();
						}
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
				// 07/07/2020 Paul.  Make sure to close the popup on error. 
				this.setState({ error, popupOpen: false });
			}
		}
		else if ( value.Action == 'MultipleSelect' )
		{
			try
			{
				let sPRIMARY_MODULE   = PARENT_TYPE   ;
				let sPRIMARY_ID       = PARENT_ID     ;
				let sRELATED_TABLE    = 'COUNTRIES'   ;
				let arrRELATED_VALUES = [];
				for ( let sRELATED_VALUE in value.selectedItems )
				{
					arrRELATED_VALUES.push(sRELATED_VALUE);
				}
				// 07/09/2019 Paul.  UpdateRelatedValues is identical to UpdateRelatedItem but accepts an array. 
				await UpdateRelatedValues(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_TABLE, arrRELATED_VALUES);
				if ( this._isMounted )
				{
					this.setState({ popupOpen: false }, () =>
					{
						// 07/13/2019 Paul.  Call SubmitSearch directly. 
						if ( this.searchView.current != null )
						{
							this.searchView.current.SubmitSearch();
						}
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
				// 07/07/2020 Paul.  Make sure to close the popup on error. 
				this.setState({ error, popupOpen: false });
			}
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onRemove = async (row) =>
	{
		const { PARENT_TYPE, layout } = this.props;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemove ' + PARENT_TYPE, row);
		try
		{
			// 10/12/2020 Paul.  Confirm remove. 
			if ( window.confirm(L10n.Term('.NTC_REMOVE_CONFIRMATION')) )
			{
				let sPRIMARY_MODULE = PARENT_TYPE   ;
				let sPRIMARY_ID     = PARENT_ID     ;
				let sRELATED_TABLE  = 'COUNTRIES'   ;
				let sRELATED_VALUE  = row.COUNTRY   ;
				await DeleteRelatedValue(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_TABLE, sRELATED_VALUE);
				if ( this._isMounted )
				{
					this.setState({ popupOpen: false }, () =>
					{
						// 07/13/2019 Paul.  Call SubmitSearch directly. 
						if ( this.searchView.current != null )
						{
							this.searchView.current.SubmitSearch();
						}
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemove', error);
			this.setState({ error });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME } = this.props;
		this.setState({ open }, () =>
		{
			if ( open )
			{
				localStorage.setItem(CONTROL_VIEW_NAME, 'true');
			}
			else
			{
				// 11/10/2020 Paul.  Save false instead of remove so that config value default_subpanel_open will work properly. 
				//localStorage.removeItem(CONTROL_VIEW_NAME);
				localStorage.setItem(CONTROL_VIEW_NAME, 'false');
			}
		});
	}

	private _onButtonsLoaded = async () =>
	{
		if ( this.dynamicButtonsTop.current != null )
		{
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
		}
	}

	public render()
	{
		const { PARENT_TYPE, row, layout, CONTROL_VIEW_NAME, disableView, disableEdit, disableRemove } = this.props;
		const { RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, PRIMARY_FIELD, PRIMARY_ID, error, showCancel, showFullForm, showTopButtons, showBottomButtons, showSearch, showInlineEdit, item, popupOpen, multiSelect, archiveView, open, customView, subPanelVisible } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/06/2019 Paul.  The trick to having the SearchView change with the tabs is to change the key. 
		// 06/25/2019 Paul.  The SplendidGrid is getting a componentDidUpdate event instead of componentDidMount, so try specifying a key. 
		let sNewRecordButtons: string = "NewRecord." + (showFullForm ? "FullForm" : (showCancel ? "WithCancel" : "SaveOnly"));
		// 06/29/2019 Paul.  The search panel must always be rendered so that it can fire the first search event to the ListView. 
		let cssSearch = { display: (showSearch ? 'inline' : 'none') };
		if ( SplendidCache.IsInitialized  )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_NAME      : string = RELATED_MODULE;
			let MODULE_TITLE     : string = L10n.Term(layout.TITLE);
			let EDIT_NAME        : string = MODULE_NAME + '.SearchSubpanel';
			// 04/20/2020 Paul.  ActivitiesOpen and ActivitiesHistory need to have a different EDIT_NAME as it is used in the ID. 
			// Most relationship panels have both Open and History, so we need to ensure that unqiue IDs are generated. 
			if ( EDIT_NAME == 'Activities.SearchSubpanel' )
			{
				if ( this.props.CONTROL_VIEW_NAME.indexOf('ActivitiesHistory') > 0 )
				{
					EDIT_NAME = 'Activities.SearchSubpanelHistory';
				}
			}
			// 07/30/2021 Paul.  Load when the panel appears. 
			return (
				<React.Fragment>
					<PopupView
						isOpen={ popupOpen }
						callback={ this._onSelect }
						TITLE='Regions.LBL_COUNTRIES'
						LIST_NAME='countries_dom'
						multiSelect={ multiSelect }
						ClearDisabled={ true }
					/>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: GRID_NAME, row: item, Page_Command: this.Page_Command, showButtons: !showInlineEdit, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
							<div style={ cssSearch }>
								<div className="card" style={{marginBottom: '0.5rem'}}>
									<div className="card-body">
										<SearchView
											key={ EDIT_NAME }
											EDIT_NAME={ EDIT_NAME }
											AutoSaveSearch={ false }
											ShowSearchViews={ false }
											cbSearch={ this._onSearchViewCallback }
											history={ this.props.history }
											location={ this.props.location }
											match={ this.props.match }
											ref={ this.searchView }
										/>
									</div>
								</div> 
							</div>
							{ showInlineEdit
							? <div>
								{ showTopButtons
								? <div>
									<DynamicButtons
										ButtonStyle="EditHeader"
										VIEW_NAME={ sNewRecordButtons }
										row={ row }
										Page_Command={ this.Page_Command }
										onLayoutLoaded={ this._onButtonsLoaded }
										history={ this.props.history }
										location={ this.props.location }
										match={ this.props.match }
										ref={ this.dynamicButtonsTop }
									/>
									<ErrorComponent error={error} />
								</div>
								: null
								}
								{ customView
								? React.createElement(customView, 
									{
										key             : MODULE_NAME + '.EditView.Inline', 
										MODULE_NAME     , 
										LAYOUT_NAME     : MODULE_NAME + '.EditView.Inline', 
										rowDefaultSearch: item, 
										callback        : this.editViewCallback, 
										history         : this.props.history, 
										location        : this.props.location, 
										match           : this.props.match, 
										ref             : this.editView
									})
								: <EditView
									key={ MODULE_NAME + '.EditView.Inline' }
									MODULE_NAME={ MODULE_NAME }
									LAYOUT_NAME={ MODULE_NAME + '.EditView.Inline' }
									rowDefaultSearch={ item }
									callback={ this.editViewCallback }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.editView }
								/>
								}
								{ showBottomButtons
								? <DynamicButtons
									ButtonStyle="EditHeader"
									VIEW_NAME={ sNewRecordButtons }
									row={ row }
									Page_Command={ this.Page_Command }
									onLayoutLoaded={ this._onButtonsLoaded }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.dynamicButtonsBottom }
								/>
								: null
								}
							</div>
							: null
							}
							<SplendidGrid
								onLayoutLoaded={ this._onGridLayoutLoaded }
								MODULE_NAME={ PARENT_TYPE }
								RELATED_MODULE={ RELATED_MODULE }
								GRID_NAME={ GRID_NAME }
								TABLE_NAME={ TABLE_NAME }
								SORT_FIELD={ SORT_FIELD }
								SORT_DIRECTION={ SORT_DIRECTION }
								PRIMARY_FIELD={ PRIMARY_FIELD }
								PRIMARY_ID={ PRIMARY_ID }
								ADMIN_MODE={ false }
								deleteRelated={ layout.MODULE_NAME == 'Activities' }
								archiveView={ archiveView }
								deferLoad={ true }
								disableView={ true }
								disableEdit={ true }
								disableRemove={ false }
								cbRemove={ this._onRemove }
								onComponentComplete={ this._onComponentComplete }
								scrollable
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.splendidGrid }
							/>
						</React.Fragment>
						: null
						}
					</Content>
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

export default withRouter(RegionsCountries);
