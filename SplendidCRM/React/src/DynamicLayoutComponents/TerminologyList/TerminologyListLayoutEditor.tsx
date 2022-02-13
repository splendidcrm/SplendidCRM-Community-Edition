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
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'      ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                   ;
import L10n                                         from '../../scripts/L10n'                  ;
import Credentials                                  from '../../scripts/Credentials'           ;
import SplendidCache                                from '../../scripts/SplendidCache'         ;
import { StartsWith, uuidFast }                     from '../../scripts/utility'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'       ;
// 4. Components and Views. 
import DraggableRow                                 from './DraggableRow'                      ;

interface ITerminologyListLayoutEditorProps
{
	LayoutType      : string;
	ModuleName      : string;
	ViewName        : string;
	onEditComplete  : Function;
}

interface ITerminologyListLayoutEditorState
{
	LANG              : string;
	LIST_NAME         : string;
	listStartIndex    : number;
	rows              : Array<any>;
	error?            : string;
}

export default class TerminologyListLayoutEditor extends React.Component<ITerminologyListLayoutEditorProps, ITerminologyListLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: ITerminologyListLayoutEditorProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.state =
		{
			LANG              : props.ModuleName,
			LIST_NAME         : props.ViewName,
			listStartIndex    : 0,
			rows              : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			await this.loadLayout();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error: error.message });
		}
	}

	async componentDidUpdate(prevProps: ITerminologyListLayoutEditorProps)
	{
		if ( prevProps.ModuleName != this.props.ModuleName || prevProps.ViewName != this.props.ViewName )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps.ViewName);
			
			this.setState(
			{
				LANG              : this.props.ModuleName,
				LIST_NAME         : this.props.ViewName,
				listStartIndex    : 0,
				rows              : null,
				error             : null,
			}, () =>
			{
				this.loadLayout().then(() =>
				{
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', error);
				});
			});
		}
	}

	private removeRow = (index: number) =>
	{
		let { listStartIndex, rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', index);
		if ( index != -1 )
		{
			rows.splice(index, 1);
			for ( let i = 0; i < rows.length; i++ )
			{
				if ( rows[i].LIST_ORDER != listStartIndex + i )
				{
					rows[i].LIST_ORDER = listStartIndex + i;
					rows[i].changed = true;
				}
			}
			if ( this._isMounted )
			{
				this.setState({ rows, error: null });
			}
		}
	}

	private moveDraggableRow = (dragIndex: number, hoverIndex: number) =>
	{
		let { listStartIndex, rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableRow', dragIndex, hoverIndex);
		const row = rows.splice(dragIndex, 1)[0];
		rows.splice(hoverIndex, 0, row);
		for ( let i = 0; i < rows.length; i++ )
		{
			if ( rows[i].LIST_ORDER != listStartIndex + i )
			{
				rows[i].LIST_ORDER = listStartIndex + i;
				rows[i].changed = true;
			}
		}
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
		}
	}

	private moveDraggableItem = (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem ' + id, hoverColIndex, hoverRowIndex);
	}

	private addSourceItem = (id: string, hoverColIndex: number, hoverRowIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceItem', id, hoverColIndex, hoverRowIndex);
	}

	private addSourceRow = (id: string, hoverIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceRow', id, hoverIndex);
	}

	private loadLayout = async () =>
	{
		const { LANG, LIST_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadLayout');
		try
		{
			if ( this._isMounted )
			{
				let filter: string = 'MODULE_NAME is null and LIST_NAME eq \'' + LIST_NAME + '\' and LANG eq \'' + LANG + '\'';
				let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=LIST_ORDER asc&$filter=' + encodeURIComponent(filter) , 'GET');
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let listStartIndex: number = 0;
					let rows: Array<any> = json.d.results;
					if ( rows.length > 0 )
					{
						listStartIndex = rows[0].LIST_ORDER;
					}
					this.setState(
					{
						listStartIndex,
						rows          ,
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.loadLayout', error);
			this.setState({ error: error.message });
		}
	}

	private _onSave = async (e) =>
	{
		const { LANG, LIST_NAME, listStartIndex, rows } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let nTermsChanged: number = 0;
				let obj: any = new Object();
				obj.TERMINOLOGY = new Array();
				for ( let i = 0; i < rows.length; i++ )
				{
					if ( rows[i].changed )
					{
						let layoutField: any = {};
						layoutField.ID           = rows[i].ID          ;
						layoutField.NAME         = rows[i].NAME        ;
						layoutField.LANG         = LANG                ;
						layoutField.MODULE_NAME  = null                ;
						layoutField.LIST_NAME    = LIST_NAME           ;
						layoutField.LIST_ORDER   = listStartIndex + i  ;
						layoutField.DISPLAY_NAME = rows[i].DISPLAY_NAME;
						obj.TERMINOLOGY.push(layoutField);
						nTermsChanged++;
					}
				}
				if ( nTermsChanged > 0 )
				{
					let sBody: string = JSON.stringify(obj);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', obj);
					let res  = await CreateSplendidRequest('Administration/Rest.svc/UpdateAdminLayout?TableName=TERMINOLOGY&ViewName=', 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					
					for ( let i = 0; i < rows.length; i++ )
					{
						if ( rows[i].changed )
						{
							rows[i].changed = false;
							rows[i].created = false;
							if ( rows[i].LANG == Credentials.sUSER_LANG )
							{
								SplendidCache.SetListTerm(LIST_NAME, rows[i].NAME, rows[i].DISPLAY_NAME)
							}
						}
					}
					//this.props.onEditComplete();
				}
				if( this._isMounted )
				{
					this.setState({ rows, error: L10n.Term('DynamicLayout.LBL_SAVE_COMPLETE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
			this.setState({ error: error.message });
		}
	}

	private _onCancel = (e) =>
	{
		if ( this._isMounted )
		{
			this.props.onEditComplete();
		}
	}

	private _onCreate = () =>
	{
		let { LANG, LIST_NAME, listStartIndex, rows } = this.state;
		let layoutField: any = {};
		layoutField.ID           = uuidFast();
		layoutField.NAME         = null;
		layoutField.LANG         = LANG;
		layoutField.MODULE_NAME  = null;
		layoutField.LIST_NAME    = LIST_NAME;
		layoutField.LIST_ORDER   = listStartIndex + rows.length;
		layoutField.DISPLAY_NAME = null;
		layoutField.changed      = true;
		layoutField.created      = true;
		rows.push(layoutField);
		this.setState({ rows });
	}

	private _onNameChange = (rowIndex, value) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onNameChange', value);
		if ( this._isMounted )
		{
			rows[rowIndex].NAME = value;
			this.setState({ rows, error: null });
		}
	}

	private _onTermChange = (rowIndex, NAME, value) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTermChange', NAME, value);
		if ( this._isMounted )
		{
			rows[rowIndex].changed = true;
			rows[rowIndex].DISPLAY_NAME = value;
			this.setState({ rows, error: null });
		}
	}

	public render()
	{
		const { LANG, LIST_NAME, rows, error } = this.state;
		return (
		<React.Fragment>
			<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ LANG + '.' + LIST_NAME }</h2>
					<div style={ {display: 'flex', width: '100%'} }>
						<div style={ {flex: '8 8 0', paddingLeft: '.5em', paddingRight: '.5em', whiteSpace: 'nowrap'} }>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave  }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel}>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
							<div className='error' style={ {paddingLeft: '10px'} }>{ error }</div>
						</div>
						<div style={ {flex: '2 2 0', paddingLeft: '.5em', paddingRight: '.5em', whiteSpace: 'nowrap', justifyContent: 'flex-end'} }>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCreate}>{ L10n.Term('.LBL_CREATE_BUTTON_LABEL') }</button>
						</div>
					</div>
					{ rows
					? <div style={{ padding: '.5em' }}>
						<table style={ {width: '100%', border: '1px solid black'} }>
						{ rows.map((row, rowIndex) => (
							<DraggableRow
								index={ rowIndex }
								id={ row.ID + '_row' }
								key={ row.ID + '_row' }
								moveDraggableRow={ this.moveDraggableRow }
								moveDraggableItem={ this.moveDraggableItem }
								addSourceItem={ this.addSourceItem }
								addSourceRow={ this.addSourceRow }
								removeRow={ this.removeRow } 
								length={ 1 }
							>
								<td style={ {width: '30%', textAlign: 'right', fontWeight: 'bold'} }>
									{ row.created
									? <input
										key={ row.ID }
										value={ row.NAME }
										onChange={ (e) => this._onNameChange(rowIndex, e.target.value) }
										style={ {width: '90%', height: '16pt'} }
									/>
									: row.NAME
									}
									&nbsp;:&nbsp;
								</td>
								<td style={ {width: '70%', paddingTop: '4px'} }>
									<textarea
										key={ row.ID }
										value={ row.DISPLAY_NAME }
										onChange={ (e) => this._onTermChange(rowIndex, row.NAME, e.target.value) }
										style={ {width: '90%', height: '16pt'} }
									/>
									<span style={ {fontSize: '20pt', color: 'red', marginLeft: '2px'} }>
										{ rows[rowIndex].changed ? '*' : null }
									</span>
								</td>
							</DraggableRow>
						))}
						</table>
					</div>
					: <div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
						<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
					</div>
					}
				</div>
			</div>
			<div style={{ flex: '4 4 0', border: '1px solid grey', margin: '0 .5em' }}>
			</div>
		</React.Fragment>
		);
	}
}


