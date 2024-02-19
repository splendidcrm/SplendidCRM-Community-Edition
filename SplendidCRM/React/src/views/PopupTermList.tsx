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
import { RouteComponentProps, withRouter }    from '../Router5'                   ;
import { Modal }                              from 'react-bootstrap'                    ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'     ;
// 2. Store and Types. 
import { EditComponent }                      from '../types/EditComponent'             ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                     ;
import L10n                                   from '../scripts/L10n'                    ;
import Credentials                            from '../scripts/Credentials'             ;
import { IsAuthenticated, LoginRedirect }     from '../scripts/Login'                   ;
import { Crm_Config, Crm_Modules }            from '../scripts/Crm'                     ;
import SplendidCache                          from '../scripts/SplendidCache'           ;
// 01/08/2020 Paul.  Importing DynamicLayout causes DynamicLayout_Module() to fail. 
// 04/24/2020 Paul.  Now that we have moved the babel compile to a separate file, we are able to import DynamicLayout. 
import { DynamicLayout_Module }               from '../scripts/DynamicLayout'           ;
import { UpdateModule }                       from '../scripts/ModuleUpdate'            ;
import { ListView_LoadModulePaginated }       from '../scripts/ListView'                ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'       ;
import SplendidGrid                           from '../components/SplendidGrid'         ;
import ListHeader                             from '../components/ListHeader'           ;
import EditView                               from '../views/EditView'                  ;
import SearchView                             from '../views/SearchView'                ;
import DynamicButtons                         from '../components/DynamicButtons'       ;

const MODULE_NAME: string = 'Terminology';

// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
interface IPopupViewProps extends RouteComponentProps<any>
{
	TITLE              : string;
	LIST_NAME          : string;
	rowDefaultSearch?  : any;
	callback           : Function;
	isOpen             : boolean;
	multiSelect?       : boolean;
	ClearDisabled?     : boolean;
	isSearchView?      : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IPopupViewState
{
	INLINE_EDIT_BUTTON : string;
	selectedItems?     : any;
	ACLACCESS          : number;
	showInlineCreate   : boolean;
	item?              : any;
	error?             : any;
	customView         : any;
}

class PopupTermList extends React.Component<IPopupViewProps, IPopupViewState>
{
	private _isMounted           = false;
	private searchView           = React.createRef<SearchView>();
	private splendidGrid         = React.createRef<SplendidGrid>();
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private editView             = React.createRef<EditView>();

	constructor(props: IPopupViewProps)
	{
		super(props);
		let INLINE_EDIT_BUTTON: string = '';
		let ACLACCESS         : number = -1;
		let item              : any    = null;
		let error             : any    = null;
		this.state =
		{
			INLINE_EDIT_BUTTON,
			ACLACCESS         ,
			showInlineCreate  : false,
			item              ,
			customView        : null,
			error             ,
		};
	}

	async componentDidMount()
	{
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
				case 'NewRecord':
				{
					await this.Save();
					break;
				}
				case 'NewRecord.Cancel':
				{
					if ( this._isMounted )
					{
						this.setState( {showInlineCreate: false} );
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

	private Save = async () =>
	{
		const { callback } = this.props;
		try
		{
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + MODULE_NAME, row);
				try
				{
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
					let ID = await UpdateModule(MODULE_NAME, row, null);
					if ( this._isMounted )
					{
						this.setState({ showInlineCreate: false });
						//if ( this.searchView.current != null )
						//{
						//	this.searchView.current.SubmitSearch();
						//}
						// 08/10/2019 Paul.  After creation, get the name and select the new record. 
						let NAME: string = await Crm_Modules.ItemName(MODULE_NAME, ID);
						callback({ Action: 'SingleSelect', ID, NAME });
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

	private _onClose = () =>
	{
		const { callback } = this.props;
		if ( this._isMounted )
		{
			this.setState( {showInlineCreate: false} );
		}
		callback({ Action: 'Close' });
	}

	private _onClear = (value: any) =>
	{
		const { callback } = this.props;
		if ( this._isMounted )
		{
			this.setState( {showInlineCreate: false} );
		}
		callback({ Action: 'SingleSelect', ID: '', NAME: '' });
	}

	private _onSelectionChanged = (value: any) =>
	{
		const { callback, multiSelect } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		let DATA_FIELD = 'DISPLAY_NAME';
		let DATA_VALUE = value['NAME'];
		let DISPLAY_VALUE = value[DATA_FIELD];
		if ( multiSelect )
		{
			this.setState({ selectedItems: value });
		}
		else
		{
			callback({ Action: 'SingleSelect', ID: DATA_VALUE, NAME: DISPLAY_VALUE });
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { callback } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', ID, NAME, URL);
		callback({ Action: 'SingleSelect', ID, NAME });
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

	private _onSelectMultiple = () =>
	{
		const { callback } = this.props;
		const { selectedItems } = this.state;
		callback({ Action: 'MultipleSelect', selectedItems: selectedItems });
	}

	private _onShowInlineEdit = () =>
	{
		let { showInlineCreate } = this.state;
		if ( this._isMounted )
		{
			this.setState( {showInlineCreate: !showInlineCreate} );
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { LIST_NAME } = this.props;
		if ( rowSEARCH_VALUES == null )
		{
			rowSEARCH_VALUES = {};
		}
		rowSEARCH_VALUES.LIST_NAME = LIST_NAME;
		rowSEARCH_VALUES.LANG      = Credentials.sUSER_LANG;
		let d = await ListView_LoadModulePaginated(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		if ( d.results )
		{
			// 10/17/2020 Paul.  The SplendidGrid requires an ID field, but a term list just uses the name. 
			for ( let i: number = 0; i < d.results.length; i++ )
			{
				let row: any = d.results[i];
				row['ID'] = row['NAME'];
			}
		}
		return d;
	}

	public render()
	{
		const { TITLE, isOpen, rowDefaultSearch, multiSelect, ClearDisabled } = this.props;
		const { INLINE_EDIT_BUTTON, item, ACLACCESS, showInlineCreate, error, customView } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		let EDIT_NAME: string = MODULE_NAME + '.SearchPopup';
		let GRID_NAME: string = MODULE_NAME + '.PopupView'  ;
		if ( SplendidCache.IsInitialized )
		{
			return (
			<Modal show={ isOpen } onHide={ this._onClose }>
				<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
					<ErrorComponent error={error} />
					<SearchView
						key={ EDIT_NAME }
						EDIT_NAME={ EDIT_NAME }
						IsPopupSearch={ true }
						cbSearch={ this._onSearchViewCallback }
						rowDefaultSearch={ rowDefaultSearch }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
					<ListHeader TITLE={ TITLE } />
					<div>
						{ multiSelect
						? <button
							key={ 'btnSelect_' + EDIT_NAME }
							className='button'
							onClick={ this._onSelectMultiple }
							style={ {marginBottom: '.2em'} }>
							{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }
						</button>
						: null
						}
						{ !ClearDisabled
						? <button
							key={ 'btnClear_'  + EDIT_NAME }
							className='button'
							onClick={ this._onClear }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL' ) }
						</button>
						: null
						}
						<button
							key={ 'btnCancel_' + EDIT_NAME }
							className='button'
							onClick={ this._onClose }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }
						</button>
					</div>
					<div>
						{ ACLACCESS >= 0 && !showInlineCreate
						? <button
							key={ 'btnCreate_'  + EDIT_NAME }
							className='button'
							onClick={ this._onShowInlineEdit }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term(INLINE_EDIT_BUTTON) }
						</button>
						: null
						}
					</div>
					{ ACLACCESS >= 0 && showInlineCreate
					? <div>
						<DynamicButtons
							ButtonStyle="EditHeader"
							VIEW_NAME="NewRecord.WithCancel"
							row={ null }
							Page_Command={ this.Page_Command }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.dynamicButtonsTop }
						/>
						{ customView
						? React.createElement(customView, 
							{
								key             : MODULE_NAME + '.PopupView.Inline', 
								MODULE_NAME     , 
								LAYOUT_NAME     : MODULE_NAME + '.PopupView.Inline', 
								rowDefaultSearch: item, 
								callback        : this.editViewCallback, 
								history         : this.props.history, 
								location        : this.props.location, 
								match           : this.props.match, 
								ref             : this.editView
							})
						: <EditView
							key={ MODULE_NAME + '.PopupView.Inline' }
							MODULE_NAME={ MODULE_NAME }
							LAYOUT_NAME={ MODULE_NAME + '.PopupView.Inline' }
							rowDefaultSearch={ item }
							callback={ this.editViewCallback }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.editView }
						/>
						}
						<DynamicButtons
							ButtonStyle="EditHeader"
							VIEW_NAME="NewRecord.WithCancel"
							row={ null }
							Page_Command={ this.Page_Command }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.dynamicButtonsBottom }
						/>
					</div>
					: null
					}
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ MODULE_NAME }
						GRID_NAME={ GRID_NAME }
						ADMIN_MODE={ false }
						selectionChanged={ this._onSelectionChanged }
						hyperLinkCallback={ this._onHyperLinkCallback }
						isPopupView={ true }
						deferLoad={ true }
						cbCustomLoad={ this.Load }
						enableSelection={ multiSelect }
						onComponentComplete={ this._onComponentComplete }
						scrollable
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidGrid }
					/>
				</Modal.Body>
				<Modal.Footer>
					<button className='button' onClick={ this._onClose }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
				</Modal.Footer>
			</Modal>
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

export default withRouter(PopupTermList);
