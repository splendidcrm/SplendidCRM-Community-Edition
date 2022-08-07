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
import { RouteComponentProps, withRouter }          from 'react-router-dom'                     ;
import { observer }                                 from 'mobx-react'                           ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'       ;
// 2. Store and Types. 
import MODULE                                       from '../../../types/MODULE'                ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'         ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                 ;
import L10n                                         from '../../../scripts/L10n'                ;
import Security                                     from '../../../scripts/Security'            ;
import Credentials                                  from '../../../scripts/Credentials'         ;
import SplendidCache                                from '../../../scripts/SplendidCache'       ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'     ;
import { EditView_LoadLayout }                      from '../../../scripts/EditView'            ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                 ;
import { Admin_GetReactState }                      from '../../../scripts/Application'         ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'               ;
import { ListView_LoadTablePaginated }              from '../../../scripts/ListView'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'     ;
// 4. Components and Views. 
import SplendidGrid                                 from '../../../components/SplendidGrid'     ;
import SearchTabs                                   from '../../../components/SearchTabs'       ;
import ErrorComponent                               from '../../../components/ErrorComponent'   ;
import SearchView                                   from '../../../views/SearchView'            ;
import DynamicMassUpdate                            from '../../../views/DynamicMassUpdate'     ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

interface IAdminListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	RELATED_MODULE?       : string;
	GRID_NAME?            : string;
	TABLE_NAME?           : string;
	SORT_FIELD?           : string;
	SORT_DIRECTION?       : string;
	callback?             : Function;
	rowRequiredSearch?    : any;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminListViewState
{
	searchLayout          : any;
	advancedLayout        : any;
	searchTabsEnabled     : boolean;
	duplicateSearchEnabled: boolean;
	searchMode            : string;
	showUpdatePanel       : boolean;
	enableMassUpdate      : boolean;
	selectedItems?        : any;
	error?                : any;
	UNDELETE_MODULE_NAME  : string;
	BACKGROUND_OPERATION  : boolean;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	showSearchView        : string;
}

@observer
class UndeleteListView extends React.Component<IAdminListViewProps, IAdminListViewState>
{
	private _isMounted = false;
	private searchView   = React.createRef<SearchView>();
	private splendidGrid = React.createRef<SplendidGrid>();
	private updatePanel  = React.createRef<DynamicMassUpdate>();
	private headerButtons = React.createRef<HeaderButtons>();

	constructor(props: IAdminListViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		// 04/09/2022 Paul.  Hide/show SearchView. 
		let showSearchView: string = 'show';
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			showSearchView = localStorage.getItem(this.constructor.name + '.showSearchView');
			if ( Sql.IsEmptyString(showSearchView) )
				showSearchView = 'hide';
		}
		this.state =
		{
			searchLayout          : null,
			advancedLayout        : null,
			searchTabsEnabled     : false,
			duplicateSearchEnabled: false,
			searchMode            : 'Basic',
			showUpdatePanel       : false,
			enableMassUpdate      : Crm_Modules.MassUpdate(props.MODULE_NAME),
			error                 : null,
			UNDELETE_MODULE_NAME  : null,
			BACKGROUND_OPERATION  : false,
			showSearchView        ,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'list') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				// 10/30/2019 Paul.  Must wait until we get the admin menu to get the module. 
				// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
				let searchLayout   : any = EditView_LoadLayout(MODULE_NAME + '.SearchBasic'     , true);
				let advancedLayout : any = EditView_LoadLayout(MODULE_NAME + '.SearchAdvanced'  , true);
				let duplicateLayout: any = EditView_LoadLayout(MODULE_NAME + '.SearchDuplicates', true);
				let module         : MODULE  = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.componentDidMount');
				let showUpdatePanel: boolean = false;
				if ( module == null )
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + MODULE_NAME + ' not found or accessible.');
				}
				// 11/22/2020 Paul.  Missing else. 
				else
				{
					showUpdatePanel = module.MASS_UPDATE_ENABLED;
				}
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				this.setState(
				{
					searchLayout          ,
					advancedLayout        ,
					searchTabsEnabled     : !!advancedLayout,
					duplicateSearchEnabled: !!duplicateLayout,
					showUpdatePanel
				});
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
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				let vwMain = null;
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data);
			}
		}
	}

	private _onSearchTabChange = (key) =>
	{
		// 04/09/2022 Paul.  Hide/show SearchView. 
		if ( key == 'Hide' )
		{
			let { showSearchView } = this.state;
			showSearchView = 'hide';
			localStorage.setItem(this.constructor.name + '.showSearchView', showSearchView);
			this.setState({ showSearchView });
		}
		else
		{
			// 11/03/2020 Paul.  When switching between tabs, re-apply the search as some advanced settings may not have been applied. 
			this.setState( {searchMode: key}, () =>
			{
				if ( this.searchView.current != null )
				{
					this.searchView.current.SubmitSearch();
				}
			});
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

	private _onSearchViewChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewChange ' + DATA_FIELD, DATA_VALUE);
		if ( DATA_FIELD == 'MODULE_NAME' )
		{
			this.setState({ UNDELETE_MODULE_NAME: DATA_VALUE });
			if ( this.searchView.current != null )
			{
				this.searchView.current.SubmitSearch();
			}
		}
		if ( DATA_FIELD == 'MODIFIED_USER_ID' )
		{
			if ( this.searchView.current != null )
			{
				this.searchView.current.SubmitSearch();
			}
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
		else if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private _onSelectionChanged = (value: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged', value);
		this.setState({ selectedItems: value }, () =>
		{
			if ( this.updatePanel.current != null )
			{
				this.updatePanel.current.SelectionChanged(value);
			}
		});
	}

	private _onUpdateComplete = (sCommandName) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdateComplete: ' + MODULE_NAME, sCommandName);
		if ( this.searchView.current != null )
		{
			// 04/26/2020 Paul.  Clear selection after update. 
			if ( sCommandName == 'MassDelete' || sCommandName == 'MassUpdate' )
			{
				if ( this.splendidGrid.current != null )
				{
					this.splendidGrid.current.onDeselectAll(null);
				}
			}
			this.searchView.current.SubmitSearch();
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID);
		if ( !Sql.IsEmptyString(URL) )
		{
			history.push(URL);
		}
		else
		{
			let admin: string = '';
			let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
			if ( module.IS_ADMIN )
			{
				admin = '/Administration';
			}
			history.push(`/Reset${admin}/${MODULE_NAME}/View/${ID}`);
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			// 04/09/2022 Paul.  Hide/show SearchView. 
			case 'toggleSearchView':
			{
				let showSearchView: string = (this.state.showSearchView == 'show' ? 'hide' : 'show');
				localStorage.setItem(this.constructor.name + '.showSearchView', showSearchView);
				this.setState({ showSearchView });
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

	private Grid_Command = async (sCommandName: string, sCommandArguments: any) =>
	{
		// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
		if ( sCommandName == 'sort' )
		{
			if ( this.searchView.current != null && sCommandArguments != null )
			{
				this.searchView.current.UpdateSortState(sCommandArguments.sortField, sCommandArguments.sortOrder);
			}
		}
		else if ( this.updatePanel.current != null )
		{
			this.updatePanel.current.Page_Command(sCommandName, sCommandArguments);
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', rowSEARCH_VALUES);
		let arrSELECT: string[] = sSELECT.split(',');
		if ( arrSELECT.indexOf('ID') < 0 )
		{
			arrSELECT.push('ID');
		}
		if ( arrSELECT.indexOf('AUDIT_ID') < 0 )
		{
			arrSELECT.push('AUDIT_ID');
		}
		sSELECT = arrSELECT.join(',');
		sMODULE_NAME = '';
		if ( rowSEARCH_VALUES === null )
			rowSEARCH_VALUES = {};
		if ( rowSEARCH_VALUES['MODULE_NAME'] )
		{
			sMODULE_NAME = rowSEARCH_VALUES.MODULE_NAME.value;
			delete rowSEARCH_VALUES['MODULE_NAME'];
			this.setState({ UNDELETE_MODULE_NAME: sMODULE_NAME });
		}
		rowSEARCH_VALUES['AUDIT_ACTION'] = { FIELD_TYPE: 'Hidden', value: -1 };
		if ( !Sql.IsEmptyString(sMODULE_NAME) )
		{
			let sTABLE_NAME: string = Crm_Modules.TableName(sMODULE_NAME);
			let d = await ListView_LoadTablePaginated(sTABLE_NAME + '_AUDIT', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			// 09/14/2021 Paul.  The Undelete procedure uses the AUDIT_ID, but the grid returns the ID. 
			for ( let i: number = 0; i < d.results.length; i++ )
			{
				let row: any = d.results[i];
				row['ITEM_ID'] = row['ID'      ];
				row['ID'     ] = row['AUDIT_ID'];
			}
			return d;
		}
		return { results: [] };
	}

	private _onCheckboxClick = (ev) =>
	{
		// 06/20/2022 Paul.  Correct issue with miss-spelled checked. 
		this.setState({ BACKGROUND_OPERATION: ev.target.checked });
	}

	private _onUndelete = async (e) =>
	{
		const { UNDELETE_MODULE_NAME, BACKGROUND_OPERATION, selectedItems } = this.state;
		try
		{
			let row: any = {};
			row.MODULE_NAME          = UNDELETE_MODULE_NAME;
			row.BACKGROUND_OPERATION = BACKGROUND_OPERATION;
			row.ID_LIST              = [];
			for ( let id in selectedItems )
			{
				row.ID_LIST.push(id);
			}
			
			let sBody = JSON.stringify(row);
			let res  = await CreateSplendidRequest('Administration/Rest.svc/UndeleteModule', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			if ( BACKGROUND_OPERATION )
			{
				this.setState({ error: L10n.Term("Undelete.LBL_UNDELETING"), selectedItems: {} }, () =>
				{
					if ( this.splendidGrid.current != null )
					{
						this.splendidGrid.current.onDeselectAll(null);
					}
					if ( this.searchView.current != null )
					{
						this.searchView.current.SubmitSearch();
					}
				});
			}
			else
			{
				let sStatus           : string = L10n.Term("Undelete.LBL_UNDELETE_COMPLETE");
				let sModuleDisplayName: string = (row.ID_LIST.length == 1) ? L10n.Term(".moduleListSingular." + row.MODULE_NAME) : L10n.Term(".moduleList." + row.MODULE_NAME);
				let error             : string = sStatus.replace('{0}', row.ID_LIST.length).replace('{1}', sModuleDisplayName);
				this.setState({ error, selectedItems: {} }, () =>
				{
					if ( this.splendidGrid.current != null )
					{
						this.splendidGrid.current.onDeselectAll(null);
					}
					if ( this.searchView.current != null )
					{
						this.searchView.current.SubmitSearch();
					}
				});
			}
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	public render()
	{
		const { MODULE_NAME, RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, rowRequiredSearch } = this.props;
		const { error, searchLayout, advancedLayout, searchTabsEnabled, duplicateSearchEnabled, searchMode, showUpdatePanel, enableMassUpdate, BACKGROUND_OPERATION, showSearchView } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = '.moduleList.Home';
			let HEADER_BUTTONS: string = '';
			if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			{
				HEADER_BUTTONS = MODULE_NAME + '.ListView';
			}
			let styCheckbox: any = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '12px', marginRight: '4px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '12px';
			}
			styCheckbox.justifyContent = 'center';
			return (
			<div>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ searchLayout != null || advancedLayout != null
				? <div style={ {display: (showSearchView == 'show' ? 'block' : 'none')} }>
					{ searchTabsEnabled
					? <SearchTabs
						searchMode={ searchMode }
						duplicateSearchEnabled={ duplicateSearchEnabled }
						onTabChange={ this._onSearchTabChange }
					/>
					: null
					}
					<SearchView
						key={ MODULE_NAME + '.Search' + searchMode }
						EDIT_NAME={ MODULE_NAME + '.Search' + searchMode }
						AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
						ShowSearchViews={ false }
						cbSearch={ this._onSearchViewCallback }
						onChange={ this._onSearchViewChange }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
				</div>
				: null
				}
				<table className='h3Row' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
					<tr>
						<td style={ {whiteSpace: 'nowrap'} }>
							<h3>
								<span style={ {paddingLeft: '4px'} }>{ L10n.Term(MODULE_NAME + '.LBL_LIST_FORM_TITLE') }</span>
							</h3>
						</td>
						<td style={ {textAlign: 'right', justifyContent: 'center'} }>
							<input type='checkbox'
								id='chkBACKGROUND_OPERATION'
								className='checkbox'
								style={ styCheckbox }
								checked={ BACKGROUND_OPERATION }
								onChange={ this._onCheckboxClick }
							/>
							<label htmlFor='chkBACKGROUND_OPERATION' className='lastView' style={ {cursor: 'pointer'} } >{ L10n.Term("Undelete.LBL_BACKGROUND_OPERATION") }</label>
							&nbsp;
							<input type='submit' className='button' onClick={ this._onUndelete } value={ L10n.Term('Undelete.LBL_UNDELETE_BUTTON_LABEL') } style={ {margin: 2} } />
						</td>
					</tr>
				</table>
				<SplendidGrid
					onLayoutLoaded={ this._onGridLayoutLoaded }
					MODULE_NAME={ MODULE_NAME }
					RELATED_MODULE={ RELATED_MODULE }
					GRID_NAME={ GRID_NAME }
					TABLE_NAME={ TABLE_NAME }
					SORT_FIELD={ SORT_FIELD }
					SORT_DIRECTION={ SORT_DIRECTION }
					ADMIN_MODE={ true }
					cbCustomLoad={ this.Load }
					AutoSaveSearch={ Credentials.bSAVE_QUERY && Crm_Config.ToBoolean('save_query') }
					deferLoad={ true }
					disableEdit={ true }
					disableView={ true }
					disableRemove={ true }
					enableSelection={ enableMassUpdate || SplendidCache.AdminUserAccess(MODULE_NAME, 'export', this.constructor.name + '.render') >= 0 }
					selectionChanged={ this._onSelectionChanged }
					hyperLinkCallback={ this._onHyperLinkCallback }
					enableMassUpdate={ enableMassUpdate }
					rowRequiredSearch={ rowRequiredSearch }
					onComponentComplete={ this._onComponentComplete }
					Page_Command={ this.Grid_Command }
					scrollable
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.splendidGrid }
				/>
				{ showUpdatePanel
				? <DynamicMassUpdate
					key={ MODULE_NAME + '.ModuleUpdate' }
					MODULE_NAME={ MODULE_NAME }
					onUpdateComplete={ this._onUpdateComplete }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.updatePanel }
					/>
				: null
				}
			</div>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
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

export default withRouter(UndeleteListView);
