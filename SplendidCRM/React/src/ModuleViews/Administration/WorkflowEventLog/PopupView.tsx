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
import { RouteComponentProps, withRouter }    from '../Router5'                  ;
import { Modal }                              from 'react-bootstrap'                   ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'    ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../../../scripts/Sql'              ;
import L10n                                   from '../../../scripts/L10n'             ;
import Credentials                            from '../../../scripts/Credentials'      ;
import SplendidCache                          from '../../../scripts/SplendidCache'    ;
import { AuthenticatedMethod, LoginRedirect } from '../../../scripts/Login'            ;
import { ListView_LoadTablePaginated }        from '../../../scripts/ListView'         ;
// 4. Components and Views. 
import ErrorComponent                         from '../../../components/ErrorComponent';
import SplendidGrid                           from '../../../components/SplendidGrid'  ;
import ListHeader                             from '../../../components/ListHeader'    ;

const MODULE_NAME: string = 'WorkflowEventLog';

interface IActivitiesPopupViewProps extends RouteComponentProps<any>
{
	WORKFLOW_INSTANCE_ID: string;
	callback            : Function;
	isOpen              : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?         : boolean;
	onComponentComplete?  : (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IActivitiesPopupViewState
{
	defaultSearch      : any;
	error?             : any;
}

export default class WorkflowEventPopupView extends React.Component<IActivitiesPopupViewProps, IActivitiesPopupViewState>
{
	private _isMounted   = false;
	private splendidGrid   = React.createRef<SplendidGrid>();

	constructor(props: IActivitiesPopupViewProps)
	{
		super(props);
		let defaultSearch: any = { };
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

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { WORKFLOW_INSTANCE_ID } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load');
		sFILTER = "WORKFLOW_INSTANCE_ID eq '" + WORKFLOW_INSTANCE_ID  + "'";
		let d = await ListView_LoadTablePaginated('vwWWF_INSTANCE_EVENTS', sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
		return d;
	}

	public renderBody = () =>
	{
		const { isOpen, callback } = this.props;
		const { defaultSearch, error } = this.state;
		let EDIT_NAME: string = MODULE_NAME + '.SearchPopup';
		let GRID_NAME: string = MODULE_NAME + '.PopupView'  ;
		return (<React.Fragment>
					<ListHeader TITLE='WorkflowEventLog.LBL_LIST_FORM_TITLE' />
					<ErrorComponent error={error} />
					<div>
						<button key={ 'btnCancel_' + EDIT_NAME }
							className='button'
							onClick={ this._onClose }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }
						</button>
					</div>
					<SplendidGrid
						MODULE_NAME={ MODULE_NAME }
						GRID_NAME={ GRID_NAME }
						ADMIN_MODE={ true }
						SORT_FIELD='EVENT_ORDER'
						SORT_DIRECTION='asc'
						isPopupView={ true }
						deferLoad={ false }
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

