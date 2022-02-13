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
import { Modal }                                    from 'react-bootstrap'               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent'  ;
import DumpSQL                                      from '../components/DumpSQL'         ;
import Security from '../scripts/Security';

interface IHelpViewProps
{
	MODULE_NAME: string;
	helpName   : string;
	callback   : Function;
	isOpen     : boolean;
}

interface IHelpViewState
{
	item   : any;
	error  : any;
	__sql  : string;
}

export default class HelpView extends React.Component<IHelpViewProps, IHelpViewState>
{
	private _isMounted   = false;

	constructor(props: IHelpViewProps)
	{
		super(props);
		this.state =
		{
			item   : {},
			error  : null,
			__sql  : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		// 04/28/2021 Paul.  Defer load until after open. 
		//await this.loadData();
	}

	shouldComponentUpdate(nextProps: IHelpViewProps, nextState: IHelpViewState)
	{
		// 03/11/2021 Paul.  Defer load until after open. 
		if ( this.props.isOpen != nextProps.isOpen )
		{
			if ( nextProps.isOpen && this.state.item == null )
			{
				this.loadData();
			}
		}
		return true;
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private _onClose = () =>
	{
		const { callback } = this.props;
		callback();
	}

	public loadData = async () =>
	{
		const { MODULE_NAME, helpName } = this.props;
		try
		{
			let obj = new Object();
			obj['TableName'    ] = 'TERMINOLOGY_HELP';
			obj['$orderby'     ] = 'NAME asc';
			obj['$select'      ] = '*';
			obj['$filter'      ] = 'LANG eq \'' + Security.USER_LANG() + '\' and MODULE_NAME eq \'' + MODULE_NAME + '\' and NAME eq \'' + helpName + '\'';
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			if ( json.d.results != null )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData', json.d);
				let item: any = {};
				if ( json.d.results.length > 0 )
				{
					item = json.d.results[0];
					if ( !Sql.IsEmptyString(item['DISPLAY_TEXT']) )
					{
						item['DISPLAY_TEXT'] = item['DISPLAY_TEXT'].replace(/<script/g, '<!--script');
						item['DISPLAY_TEXT'] = item['DISPLAY_TEXT'].replace(/<\/script>/g, '<\/script--!>');
					}
				}
				this.setState({ item, __sql: json.__sql });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	private rowClasses = (row, rowIndex) =>
	{
		return (rowIndex % 2 ? 'evenListRowS1' : 'oddListRowS1');
	}

	public render()
	{
		const { isOpen } = this.props;
		const { item, error, __sql } = this.state;
		if ( SplendidCache.IsInitialized  )
		{
			return (
			<Modal show={ isOpen } onHide={ this._onClose }>
				<Modal.Body style={ {minHeight: '80vh', minWidth: '80vw'} }>
					<ErrorComponent error={ error } />
					<div>
						<button
							key={ 'btnCancel_HelpView' }
							className='button'
							onClick={ this._onClose }
							style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
							{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }
						</button>
					</div>
					<DumpSQL SQL={ __sql } />
					{ item
					? <div dangerouslySetInnerHTML={ { __html: item['DISPLAY_TEXT'] } }></div>
					: null
					}
				</Modal.Body>
				<Modal.Footer>
					<button className='button' onClick={ this._onClose }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
				</Modal.Footer>
			</Modal>
			);
		}
		// 11/03/2019 Paul.  Make sure to only show spinner when open, otherwise it would always get displayed. 
		else if ( isOpen )
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
		else
		{
			// 11/03/2019 Paul.  Must return null, otherwise we getn an invariant error. 
			return null;
		}
	}
}

