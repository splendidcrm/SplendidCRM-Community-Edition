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
import { RouteComponentProps, withRouter }    from '../Router5'            ;
import { Modal }                              from 'react-bootstrap'             ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'              ;
import L10n                                   from '../scripts/L10n'             ;
import Credentials                            from '../scripts/Credentials'      ;
import SplendidCache                          from '../scripts/SplendidCache'    ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'            ;
import { ListView_LoadActivitiesPaginated }   from '../scripts/ListView'         ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent';
import SplendidGrid                           from '../components/SplendidGrid'  ;
import SearchView                             from '../views/SearchView'         ;

interface IActivitiesPopupViewProps extends RouteComponentProps<any>
{
	PARENT_TYPE        : string;
	PARENT_ID          : string;
	callback           : Function;
	isOpen             : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IActivitiesPopupViewState
{
	defaultSearch      : any;
	error?             : any;
}

class ActivitiesPopupView extends React.Component<IActivitiesPopupViewProps, IActivitiesPopupViewState>
{
	private _isMounted   = false;
	private searchView     = React.createRef<SearchView>();
	private splendidGrid   = React.createRef<SplendidGrid>();

	constructor(props: IActivitiesPopupViewProps)
	{
		super(props);
		let defaultSearch: any = { PARENT_TYPE: props.PARENT_TYPE, PARENT_ID: props.PARENT_ID };
		this.state =
		{
			defaultSearch     ,
		};
	}

	async componentDidMount()
	{
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

	public loadData = async (bIncludeRelationships: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData');
		// 08/29/2019 Paul.  This method does not seem necessary. 
	}

	private _onClose = () =>
	{
		const { callback } = this.props;
		callback({ Action: 'Close' });
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { callback } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', ID, NAME, URL);
		//callback({ Action: 'SingleSelect', ID, NAME });
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load');
		return await ListView_LoadActivitiesPaginated(this.props.PARENT_TYPE, this.props.PARENT_ID, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, archiveView);
	}

	public renderBody = () =>
	{
		const { isOpen, callback } = this.props;
		const { defaultSearch, error } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 08/30/2019 Paul.  The in the SYTEM_REST_TABLES, the module for the activities table is Calendar. 
		let EDIT_NAME: string = 'Activities.SearchPopup';
		let GRID_NAME: string = 'Activities.PopupView'  ;
		return (<React.Fragment>
					<ErrorComponent error={error} />
					<SearchView
						key={ EDIT_NAME }
						EDIT_NAME={ EDIT_NAME }
						IsPopupSearch={ true }
						rowDefaultSearch={ defaultSearch }
						cbSearch={ this._onSearchViewCallback }
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.searchView }
					/>
					<div>
						<button key={ 'btnCancel_' + EDIT_NAME }
							className='button'
							onClick={ this._onClose }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }
						</button>
					</div>
					<SplendidGrid
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME="Calendar"
						GRID_NAME={ GRID_NAME }
						ADMIN_MODE={ false }
						hyperLinkCallback={ this._onHyperLinkCallback }
						isPopupView={ true }
						deferLoad={ true }
						enableSelection={ false }
						onComponentComplete={ this._onComponentComplete }
						scrollable
						cbCustomLoad={ this.Load }
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

export default ActivitiesPopupView;
