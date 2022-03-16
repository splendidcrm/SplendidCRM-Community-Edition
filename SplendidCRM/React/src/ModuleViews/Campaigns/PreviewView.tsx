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
import { RouteComponentProps, withRouter }    from 'react-router-dom'                      ;
import { Modal }                              from 'react-bootstrap'                       ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'        ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../../scripts/Sql'                     ;
import L10n                                   from '../../scripts/L10n'                    ;
import Credentials                            from '../../scripts/Credentials'             ;
import { IsAuthenticated }                    from '../../scripts/Login'                   ;
import SplendidCache                          from '../../scripts/SplendidCache'           ;
import { DynamicLayout_Module }               from '../../scripts/DynamicLayout'           ;
import { ListView_LoadTablePaginated }        from '../../scripts/ListView'                ;
// 4. Components and Views. 
import ErrorComponent                         from '../../components/ErrorComponent'       ;
import SplendidGrid                           from '../../components/SplendidGrid'         ;
import ListHeader                             from '../../components/ListHeader'           ;
import EditView                               from '../../views/EditView'                  ;
import SearchView                             from '../../views/SearchView'                ;
import DynamicButtons                         from '../../components/DynamicButtons'       ;

interface IPopupViewProps extends RouteComponentProps<any>
{
	CAMPAIGN_ID        : string;
	MODULE_NAME        : string;
	rowDefaultSearch?  : any;
	callback           : Function;
	isOpen             : boolean;
	isSearchView?      : boolean;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	fromLayoutName?    : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IPopupViewState
{
	TITLE              : string;
	selectedItems?     : any;
	ACLACCESS          : number;
	showInlineCreate   : boolean;
	item?              : any;
	error?             : any;
	customView         : any;
	TEST               : boolean;
}

class CampaignPreviewView extends React.Component<IPopupViewProps, IPopupViewState>
{
	private _isMounted           = false;
	private searchView           = React.createRef<SearchView>();
	private splendidGrid         = React.createRef<SplendidGrid>();
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();

	constructor(props: IPopupViewProps)
	{
		super(props);
		let TITLE             : string = '';
		let ACLACCESS         : number = -1;
		let item              : any    = null;
		let error             : any    = null;
		// 08/24/2019 Paul.  The module name will be null when handling the popup for the parent edit field. 
		if ( !Sql.IsEmptyString(props.MODULE_NAME) )
		{
			// 11/02/2020 Paul.  Admin modules use search, primary modules use List
			TITLE = L10n.Term(props.MODULE_NAME + '.LBL_SEARCH_FORM_TITLE');
			if ( TITLE == props.MODULE_NAME + '.LBL_SEARCH_FORM_TITLE' )
			{
				TITLE = props.MODULE_NAME + '.LBL_LIST_FORM_TITLE';
			}
			else
			{
				TITLE = props.MODULE_NAME + '.LBL_SEARCH_FORM_TITLE';
			}
		}
		this.state =
		{
			TITLE             ,
			ACLACCESS         ,
			showInlineCreate  : false,
			item              ,
			customView        : null,
			error             ,
			TEST              : false,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
		try
		{
			// 10/12/2019 Paul.  PopupView will not redirect if not authenticated. 
			let bAuthenticated: boolean = await IsAuthenticated(this.constructor.name + '.componentDidMount');
			if ( bAuthenticated )
			{
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				// 01/08/2020 Paul.  First check for an Inline specific view, then fallback to a regular view. 
				// 01/08/2020 Paul.  Importing DynamicLayout causes DynamicLayout_Module() to fail. 
				// 04/24/2020 Paul.  Now that we have moved the babel compile to a separate file, we are able to import DynamicLayout. 
				let customView = await DynamicLayout_Module(MODULE_NAME, 'EditViews', 'PopupView.Inline');
				//let customView = SplendidCache.CompiledCustomViews(MODULE_NAME, 'EditViews', 'PopupView.Inline');
				if ( this._isMounted && customView )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount found custom ' + MODULE_NAME + '.PopupView.Inline');
					this.setState({ customView });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
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

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		try
		{
			switch (sCommandName)
			{
				case 'Preview.Production':
				{
					this.setState({ TEST: false });
					if ( this.searchView.current != null )
					{
						this.searchView.current.SubmitSearch();
					}
					break;
				}
				case 'Preview.Test':
				{
					this.setState({ TEST: true });
					if ( this.searchView.current != null )
					{
						this.searchView.current.SubmitSearch();
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

	private _onClose = () =>
	{
		const { callback } = this.props;
		if ( this._isMounted )
		{
			this.setState( {showInlineCreate: false} );
		}
		callback({ Action: 'Close' });
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

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { CAMPAIGN_ID } = this.props;
		const { TEST } = this.state;
		rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
		if ( rowSEARCH_VALUES == null )
		{
			rowSEARCH_VALUES = {};
		}
		rowSEARCH_VALUES['CAMPAIGN_ID'] = { FIELD_TYPE: 'Hidden', value: CAMPAIGN_ID };
		rowSEARCH_VALUES['TEST'       ] = { FIELD_TYPE: 'Hidden', value: (TEST ? 1 : 0)};
		let d = await ListView_LoadTablePaginated('vwCAMPAIGNS_Send', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		if ( d.results )
		{
			for ( let i: number = 0; i < d.results.length; i++ )
			{
				// 05/28/2020 Paul.  The SplendidGrid needs an ID fields to enable the Remove link. 
				d.results[i]['ID'] = L10n.Term(d.results[i]['USER_ID']);
			}
		}
		return d;
	}

	public renderBody = () =>
	{
		// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
		const { isOpen, MODULE_NAME, rowDefaultSearch, fromLayoutName } = this.props;
		const { TITLE, error } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		let EDIT_NAME: string = MODULE_NAME + '.SearchPreview';
		let GRID_NAME: string = MODULE_NAME + '.PreviewView'  ;
		return (<React.Fragment>
					<ErrorComponent error={error} />
					<ListHeader TITLE={ TITLE } />
					<SearchView
						key={ EDIT_NAME }
						EDIT_NAME={ EDIT_NAME }
						IsPopupSearch={ true }
						fromLayoutName={ fromLayoutName }
						cbSearch={ this._onSearchViewCallback }
						rowDefaultSearch={ rowDefaultSearch }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
					<ListHeader MODULE_NAME={ MODULE_NAME } />
					<div style={ {display: 'flex', flexDirection: 'row'} }>
						<DynamicButtons
							ButtonStyle="ListHeader"
							VIEW_NAME={ GRID_NAME }
							row={ null }
							Page_Command={ this.Page_Command }
							ref={ this.dynamicButtonsTop }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
						/>
						<div className='button-panel' style={ {marginTop: '6px', marginBottom: '2px'} }>
							<button
								key={ 'btnClose_' + EDIT_NAME }
								className='button'
								onClick={ this._onClose }
								style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
								{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }
							</button>
						</div>
					</div>
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						GRID_NAME={ GRID_NAME }
						ADMIN_MODE={ false }
						isPopupView={ true }
						deferLoad={ true }
						enableSelection={ false }
						cbCustomLoad={ this.Load }
						onComponentComplete={ this._onComponentComplete }
						scrollable
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidGrid }
					/>
		</React.Fragment>);
	}

	public render()
	{
		const { isOpen, isPrecompile } = this.props;
		if ( SplendidCache.IsInitialized )
		{
			// 04/12/2021 Paul.  Move the rendering to a separate function so that we can skip the modal during Precompile. 
			if ( isPrecompile )
			{
				return this.renderBody();
			}
			else
			{
				return (
					<Modal show={ isOpen } onHide={ this._onClose }>
						<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
							{ this.renderBody() }
						</Modal.Body>
						<Modal.Footer>
							<button className='button' onClick={ this._onClose }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
						</Modal.Footer>
					</Modal>
				);
			}
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

export default withRouter(CampaignPreviewView);
