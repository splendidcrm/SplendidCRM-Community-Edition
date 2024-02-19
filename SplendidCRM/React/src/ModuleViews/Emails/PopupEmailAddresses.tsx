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
import { RouteComponentProps, withRouter }    from '../Router5'                      ;
import { Modal }                              from 'react-bootstrap'                       ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'        ;
// 2. Store and Types. 
// 3. Scripts. 
import L10n                                   from '../../scripts/L10n'                    ;
import SplendidCache                          from '../../scripts/SplendidCache'           ;
import { ListView_LoadTablePaginated }        from '../../scripts/ListView'                ;
// 4. Components and Views. 
import ErrorComponent                         from '../../components/ErrorComponent'       ;
import SplendidGrid                           from '../../components/SplendidGrid'         ;
import ListHeader                             from '../../components/ListHeader'           ;
import SearchView                             from '../../views/SearchView'                ;

// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
interface IPopupViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
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
	TITLE              : string;
	vwMain?            : any[];
	selectedItems?     : any;
	item?              : any;
	error?             : any;
}

class PopupEmailAddresses extends React.Component<IPopupViewProps, IPopupViewState>
{
	private _isMounted           = false;
	private searchView           = React.createRef<SearchView>();
	private splendidGrid         = React.createRef<SplendidGrid>();

	constructor(props: IPopupViewProps)
	{
		super(props);
		// 04/11/2022 Paul.  Add title to match other PopupViews. 
		let TITLE: string = L10n.Term('Contacts.LBL_LIST_FORM_TITLE');
		this.state =
		{
			TITLE             ,
			item              : null,
			error             : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
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

	private _onClose = () =>
	{
		const { callback } = this.props;
		callback({ Action: 'Close' });
	}

	private _onClear = (value: any) =>
	{
		const { callback } = this.props;
		callback({ Action: 'SingleSelect', ID: '', NAME: '', EMAIL: '' });
	}

	private _onSelectionChanged = (value: any) =>
	{
		const { MODULE_NAME, callback, multiSelect } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		let DATA_FIELD = 'NAME';
		if ( MODULE_NAME == 'Users' )
		{
			DATA_FIELD = 'USER_NAME';
		}
		else if ( MODULE_NAME == 'Documents' )
		{
			DATA_FIELD = 'DOCUMENT_NAME';
		}
		let DATA_VALUE = value['ID'];
		let DISPLAY_VALUE = value[DATA_FIELD];
		/*if (value.NAME === undefined)
		{
			if (MODULE_NAME == 'Users')
				sNAME = value.USER_NAME;
		}*/
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
		const { vwMain } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', ID, NAME, URL);
		let EMAIL: string = null;
		if ( vwMain )
		{
			for ( let i: number = 0; i < vwMain.length; i++ )
			{
				let row: any = vwMain[i];
				if ( row['ID'] == ID )
				{
					EMAIL = row['EMAIL1'];
					break;
				}
			}
		}
		callback({ Action: 'SingleSelect', ID, NAME, EMAIL });
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

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		let d: any = { __total: 0, __sql: '', results: [] };
		let arrSELECT: string[] = sSELECT.split(',');
		for ( let i: number = 0; i < arrSELECT.length; i++ )
		{
			if ( arrSELECT[i] == 'ADDRESS_TYPE' )
			{
				delete arrSELECT[i];
				break;
			}
		}
		sSELECT = arrSELECT.join(',');
		if ( SplendidCache.GetUserAccess('Contacts', 'list', this.constructor.name + '.Load') >= 0 )
		{
			let dContacts = await ListView_LoadTablePaginated('vwCONTACTS_EmailList', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			d.__total += dContacts.__total;
			d.__sql   += dContacts.__sql + ';';
			if ( dContacts.results != null )
			{
				for ( let i: number = 0; i < dContacts.results.length; i++ )
				{
					dContacts.results[i]['ADDRESS_TYPE'] = 'Contacts';
					d.results.push(dContacts.results[i]);
				}
			}
		}
		if ( SplendidCache.GetUserAccess('Leads', 'list', this.constructor.name + '.Load') >= 0 )
		{
			let dLeads = await ListView_LoadTablePaginated('vwLEADS_EmailList', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			d.__total += dLeads.__total;
			d.__sql   += dLeads.__sql + ';';
			if ( dLeads.results != null )
			{
				for ( let i: number = 0; i < dLeads.results.length; i++ )
				{
					dLeads.results[i]['ADDRESS_TYPE'] = 'Leads';
					d.results.push(dLeads.results[i]);
				}
			}
		}
		if ( SplendidCache.GetUserAccess('Prospects', 'list', this.constructor.name + '.Load') >= 0 )
		{
			let dProspects = await ListView_LoadTablePaginated('vwPROSPECTS_EmailList', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			d.__total += dProspects.__total;
			d.__sql   += dProspects.__sql + ';';
			if ( dProspects.results != null )
			{
				for ( let i: number = 0; i < dProspects.results.length; i++ )
				{
					dProspects.results[i]['ADDRESS_TYPE'] = 'Prospects';
					d.results.push(dProspects.results[i]);
				}
			}
		}
		if ( SplendidCache.GetUserAccess('Accounts', 'list', this.constructor.name + '.Load') >= 0 )
		{
			let dProspects = await ListView_LoadTablePaginated('vwACCOUNTS_EmailList', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			d.__total += dProspects.__total;
			d.__sql   += dProspects.__sql + ';';
			if ( dProspects.results != null )
			{
				for ( let i: number = 0; i < dProspects.results.length; i++ )
				{
					dProspects.results[i]['ADDRESS_TYPE'] = 'Accounts';
					d.results.push(dProspects.results[i]);
				}
			}
		}
		this.setState({ vwMain: d.results });
		return d;
	}

	public render()
	{
		const { isOpen, MODULE_NAME, rowDefaultSearch, multiSelect, ClearDisabled } = this.props;
		const { TITLE, error } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		let EDIT_NAME: string = MODULE_NAME + '.SearchPopup';
		if ( SplendidCache.IsInitialized )
		{
			// 02/25/2021 Paul.  Contacts module may be disabled, so use global Add Recipients label. 
			return (
			<Modal show={isOpen} onHide={ this._onClose }>
				<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
					<ErrorComponent error={error} />
					<ListHeader TITLE={ TITLE } />
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
					<ListHeader TITLE='.LBL_ADD_RECIPIENT' />
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
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME='Contacts'
						GRID_NAME='Emails.PopupEmailAddresses'
						ADMIN_MODE={ false }
						selectionChanged={ this._onSelectionChanged }
						hyperLinkCallback={ this._onHyperLinkCallback }
						isPopupView={ true }
						deferLoad={ true }
						enableSelection={ multiSelect }
						onComponentComplete={ this._onComponentComplete }
						scrollable
						cbCustomLoad={ this.Load }
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

export default withRouter(PopupEmailAddresses);
