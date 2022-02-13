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
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                   ;
import L10n                                         from '../../scripts/L10n'                  ;
import Credentials                                  from '../../scripts/Credentials'           ;
import SplendidCache                                from '../../scripts/SplendidCache'         ;
import { StartsWith, uuidFast }                     from '../../scripts/utility'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'       ;
// 4. Components and Views. 

interface ITerminologyLayoutEditorProps
{
	LayoutType      : string;
	ModuleName      : string;
	ViewName        : string;
	onEditComplete  : Function;
}

interface ITerminologyLayoutEditorState
{
	LANG              : string;
	moduleFields      : Array<any>;
	termType          : string;
	rows              : Array<any>;
	error?            : string;
}

export default class TerminologyLayoutEditor extends React.Component<ITerminologyLayoutEditorProps, ITerminologyLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: ITerminologyLayoutEditorProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let termType: string = (Sql.IsEmptyString(props.ModuleName) ? 'all' : 'fields');
		this.state =
		{
			LANG              : props.ViewName,
			moduleFields      : [],
			termType          ,
			rows              : [],
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

	async componentDidUpdate(prevProps: ITerminologyLayoutEditorProps)
	{
		if ( prevProps.ViewName != this.props.ViewName )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps.ViewName);
			let termType: string = (Sql.IsEmptyString(this.props.ModuleName) ? 'all' : 'fields');
			this.setState(
			{
				LANG              : this.props.ViewName,
				moduleFields      : [],
				termType          ,
				rows              : [],
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

	private loadLayout = async () =>
	{
		const { ModuleName, ViewName } = this.props;
		const { LANG } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadLayout');
		try
		{
			if ( this._isMounted )
			{
				let res  = null;
				if ( Sql.IsEmptyString(ModuleName) )
				{
					let filter: string = 'MODULE_NAME is null and LIST_NAME is null and LANG eq \'' + LANG + '\'';
					res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent(filter) , 'GET');
				}
				else
				{
					let filter: string = 'MODULE_NAME eq \'' + ModuleName + '\' and LANG eq \'' + LANG + '\'';
					res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent(filter) , 'GET');
				}
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let rows: Array<any> = json.d.results;
					let moduleFields: Array<any> = [];
					if ( !Sql.IsEmptyString(ModuleName) )
					{
						res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutModuleFields?ModuleName=' + ModuleName + '&LayoutType=DetailView&LayoutName=', 'GET');
						json = await GetSplendidResult(res);
						if ( this._isMounted )
						{
							moduleFields = json.d;
						}
					}
					this.setState(
					{
						moduleFields    ,
						rows            ,
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
		const { ModuleName } = this.props;
		let { rows } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let MODULE_NAME: string = (!Sql.IsEmptyString(ModuleName) ? ModuleName : '');
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
						layoutField.LANG         = rows[i].LANG        ;
						layoutField.MODULE_NAME  = rows[i].MODULE_NAME ;
						layoutField.LIST_NAME    = rows[i].LIST_NAME   ;
						layoutField.LIST_ORDER   = rows[i].LIST_ORDER  ;
						layoutField.DISPLAY_NAME = rows[i].DISPLAY_NAME;
						obj.TERMINOLOGY.push(layoutField);
						nTermsChanged++;
					}
				}
				if ( nTermsChanged > 0 )
				{
					let sBody: string = JSON.stringify(obj);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', obj);
					let res  = await CreateSplendidRequest('Administration/Rest.svc/UpdateAdminLayout?TableName=TERMINOLOGY&ViewName=' + MODULE_NAME, 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					
					for ( let i = 0; i < rows.length; i++ )
					{
						if ( rows[i].changed )
						{
							rows[i].changed = false;
							rows[i].created = false;
							if ( rows[i].LANG == Credentials.sUSER_LANG )
							{
								SplendidCache.SetTerm(ModuleName, rows[i].NAME, rows[i].DISPLAY_NAME)
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
		let { rows, LANG } = this.state;
		let layoutField: any = {};
		layoutField.ID           = uuidFast();
		layoutField.NAME         = null;
		layoutField.LANG         = LANG;
		layoutField.MODULE_NAME  = null;
		layoutField.LIST_NAME    = null;
		layoutField.LIST_ORDER   = null;
		layoutField.DISPLAY_NAME = null;
		layoutField.changed      = true;
		layoutField.created      = true;
		rows.unshift(layoutField);
		this.setState({ rows, termType: 'all' });
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

	private _onTermTypeChange = (e) =>
	{
		this.setState({ termType: e.target.value });
	}

	private isFieldTerm = (NAME) =>
	{
		const { moduleFields } = this.state;
		for ( let i = 0; i < moduleFields.length; i++ )
		{
			let field: any = moduleFields[i];
			if ( NAME == 'LBL_' + field.ColumnName || NAME == 'LBL_LIST_' + field.ColumnName )
			{
				return true;
			}
		}
		return false;
	}

	public render()
	{
		const { ModuleName } = this.props;
		const { rows, termType, LANG, error } = this.state;
		return (
		<React.Fragment>
			<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_LAYOUT') + ' - ' + ModuleName + ' ' + LANG }</h2>
					<div style={ {display: 'flex', width: '100%'} }>
						<div style={ {flex: '8 8 0', paddingLeft: '.5em', paddingRight: '.5em', whiteSpace: 'nowrap'} }>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave  }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel}>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
							<span className='error' style={ {paddingLeft: '10px'} }>{ error }</span>
						</div>
						<div style={ {flex: '2 2 0', paddingLeft: '.5em', paddingRight: '.5em', whiteSpace: 'nowrap', justifyContent: 'flex-end'} }>
							<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCreate}>{ L10n.Term('.LBL_CREATE_BUTTON_LABEL') }</button>
							<span style={ {paddingTop: '.5em'} }>
								<select
									value={ termType }
									onChange={ this._onTermTypeChange }
								>
									{ !Sql.IsEmptyString(ModuleName)
									? <option value='fields'>{ L10n.Term('DynamicLayout.LBL_FIELD_TERMS') }</option>
									: null
									}
									<option value='all'>{ L10n.Term('DynamicLayout.LBL_ALL_TERMS') }</option>
								</select>
							</span>
						</div>
					</div>
					<div style={{ padding: '.5em' }}>
						<table style={ {width: '100%', border: '1px solid black'} }>
						{ rows.map((row, rowIndex) => (
							<React.Fragment>
								{ termType == 'all' || this.isFieldTerm(row.NAME) || row.created
								? <tr>
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
								</tr>
								: null
								}
							</React.Fragment>
						))}
						</table>
					</div>
				</div>
			</div>
			<div style={{ flex: '4 4 0', border: '1px solid grey', margin: '0 .5em' }}>
			</div>
		</React.Fragment>
		);
	}
}


