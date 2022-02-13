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
import { Modal }                              from 'react-bootstrap'                    ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'     ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                     ;
import L10n                                   from '../scripts/L10n'                    ;
import Credentials                            from '../scripts/Credentials'             ;
import { Crm_Config }                         from '../scripts/Crm'                     ;
import { IsAuthenticated }                    from '../scripts/Login'                   ;
import SplendidCache                          from '../scripts/SplendidCache'           ;
// 4. Components and Views. 
import ListHeader                             from '../components/ListHeader'           ;
import QueryDesigner                          from './QueryDesigner'                    ;

interface IPopupViewProps
{
	JSON                        : string      ;
	isOpen                      : boolean     ;
	callback                    : Function    ;
	bReportDesignerWorkflowMode?: boolean     ;
}

interface IPopupViewState
{
	item?              : any;
	error?             : any;
}

export default class ReportDesignerPopupView extends React.Component<IPopupViewProps, IPopupViewState>
{
	private _isMounted           = false;
	private queryDesigner        = React.createRef<QueryDesigner>();

	constructor(props: IPopupViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let item : any = { SHOW_QUERY: Crm_Config.ToBoolean('show_sql') };
		let error: any = null;
		this.state =
		{
			item ,
			error,
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

	private _onSave = async () =>
	{
		const { callback } = this.props;
		const { item } = this.state
		try
		{
			callback({ Action: 'Save', JSON: item['ReportDesign'], SQL: item['SQL'] });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			this.setState({ error });
		}
	}

	private _onClose = () =>
	{
		const { callback } = this.props;
		if ( this._isMounted )
		{
		}
		callback({ Action: 'Close' });
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.item;
		if ( item == null )
			item = {};
		item['ReportDesign'] = DATA_VALUE   ;
		item['SQL'         ] = DISPLAY_VALUE;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	public render()
	{
		const { JSON, isOpen, bReportDesignerWorkflowMode } = this.props;
		if ( SplendidCache.IsInitialized )
		{
			const currentItem = Object.assign({}, this.state.item, {ReportDesign: JSON});
			return (
				<Modal show={ isOpen } onHide={ this._onClose }>
					<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
						<ListHeader TITLE='ReportDesigner.LBL_NEW_FORM_TITLE' />
						<div>
							<button className='button' onClick={ this._onSave  }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
							&nbsp;
							<button className='button' onClick={ this._onClose }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
						</div>
						<QueryDesigner row={ currentItem } DATA_FIELD='ReportDesign' onChanged={ this._onChange } bReportDesignerWorkflowMode={ bReportDesignerWorkflowMode } ref={ this.queryDesigner } />
					</Modal.Body>
					<Modal.Footer>
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


