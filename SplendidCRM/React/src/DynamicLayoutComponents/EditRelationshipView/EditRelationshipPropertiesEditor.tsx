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
import Sql                                          from '../../scripts/Sql'                ;
import L10n                                         from '../../scripts/L10n'               ;
// 4. Components and Views. 

interface IEditRelationshipPropertiesEditorProps
{
	layoutField               : any;
	moduleFields              : Array<any>;
	onEditComplete            : Function;
}

interface IEditRelationshipPropertiesEditorState
{
	ID                        : string ;
	EDIT_NAME                 : string ;
	MODULE_NAME               : string ;
	CONTROL_NAME              : string ;
	RELATIONSHIP_ORDER        : number ;
	RELATIONSHIP_ENABLED      : boolean;
	NEW_RECORD_ENABLED        : boolean;
	EXISTING_RECORD_ENABLED   : boolean;
	TITLE                     : string ;
	ALTERNATE_VIEW            : string ;
	error?                    : string ;
}

export default class EditRelationshipPropertiesEditor extends React.Component<IEditRelationshipPropertiesEditorProps, IEditRelationshipPropertiesEditorState>
{
	private _isMounted = false;

	constructor(props: IEditRelationshipPropertiesEditorProps)
	{
		super(props);
		const { layoutField, moduleFields } = props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);

		let ID                        : string  = null;
		let EDIT_NAME                 : string  = null;
		let MODULE_NAME               : string  = null;
		let CONTROL_NAME              : string  = null;
		let RELATIONSHIP_ORDER        : number  = null;
		let RELATIONSHIP_ENABLED      : boolean = null;
		let NEW_RECORD_ENABLED        : boolean = null;
		let EXISTING_RECORD_ENABLED   : boolean = null;
		let TITLE                     : string  = null;
		let ALTERNATE_VIEW            : string  = null;
		if ( layoutField != null )
		{
			ID                      = layoutField.ID                     ;
			EDIT_NAME               = layoutField.EDIT_NAME              ;
			MODULE_NAME             = layoutField.MODULE_NAME            ;
			CONTROL_NAME            = layoutField.CONTROL_NAME           ;
			RELATIONSHIP_ORDER      = layoutField.RELATIONSHIP_ORDER     ;
			RELATIONSHIP_ENABLED    = layoutField.RELATIONSHIP_ENABLED   ;
			NEW_RECORD_ENABLED      = layoutField.NEW_RECORD_ENABLED     ;
			EXISTING_RECORD_ENABLED = layoutField.EXISTING_RECORD_ENABLED;
			TITLE                   = layoutField.TITLE                  ;
			ALTERNATE_VIEW          = layoutField.ALTERNATE_VIEW         ;
		}
		this.state =
		{
			ID                     ,
			EDIT_NAME              ,
			MODULE_NAME            ,
			CONTROL_NAME           ,
			RELATIONSHIP_ORDER     ,
			RELATIONSHIP_ENABLED   ,
			NEW_RECORD_ENABLED     ,
			EXISTING_RECORD_ENABLED,
			TITLE                  ,
			ALTERNATE_VIEW         ,
			error               : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error: error.message });
		}
	}

 	async componentDidUpdate(prevProps: IEditRelationshipPropertiesEditorProps)
	{
		const { layoutField } = this.props;
		if ( this.props.layoutField != prevProps.layoutField )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props);
			let ID                        : string  = null;
			let EDIT_NAME                 : string  = null;
			let MODULE_NAME               : string  = null;
			let CONTROL_NAME              : string  = null;
			let RELATIONSHIP_ORDER        : number  = null;
			let RELATIONSHIP_ENABLED      : boolean = null;
			let NEW_RECORD_ENABLED        : boolean = null;
			let EXISTING_RECORD_ENABLED   : boolean = null;
			let TITLE                     : string  = null;
			let ALTERNATE_VIEW            : string  = null;
			if ( layoutField != null )
			{
				ID                      = layoutField.ID                     ;
				EDIT_NAME               = layoutField.EDIT_NAME              ;
				MODULE_NAME             = layoutField.MODULE_NAME            ;
				CONTROL_NAME            = layoutField.CONTROL_NAME           ;
				RELATIONSHIP_ORDER      = layoutField.RELATIONSHIP_ORDER     ;
				RELATIONSHIP_ENABLED    = layoutField.RELATIONSHIP_ENABLED   ;
				NEW_RECORD_ENABLED      = layoutField.NEW_RECORD_ENABLED     ;
				EXISTING_RECORD_ENABLED = layoutField.EXISTING_RECORD_ENABLED;
				TITLE                   = layoutField.TITLE                  ;
				ALTERNATE_VIEW          = layoutField.ALTERNATE_VIEW         ;
			}
			this.setState(
			{
				ID                     ,
				EDIT_NAME              ,
				MODULE_NAME            ,
				CONTROL_NAME           ,
				RELATIONSHIP_ORDER     ,
				RELATIONSHIP_ENABLED   ,
				NEW_RECORD_ENABLED     ,
				EXISTING_RECORD_ENABLED,
				TITLE                  ,
				ALTERNATE_VIEW         ,
				error               : null,
			});
		}
	}

	private _onSave = async (e) =>
	{
		const { ID, EDIT_NAME, MODULE_NAME, CONTROL_NAME, RELATIONSHIP_ORDER, RELATIONSHIP_ENABLED, NEW_RECORD_ENABLED, EXISTING_RECORD_ENABLED, TITLE, ALTERNATE_VIEW } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let layoutField: any = {};
				layoutField.ID                      = ID                     ;
				layoutField.EDIT_NAME               = EDIT_NAME              ;
				layoutField.MODULE_NAME             = MODULE_NAME            ;
				layoutField.CONTROL_NAME            = CONTROL_NAME           ;
				layoutField.RELATIONSHIP_ORDER      = RELATIONSHIP_ORDER     ;
				layoutField.RELATIONSHIP_ENABLED    = RELATIONSHIP_ENABLED   ;
				layoutField.NEW_RECORD_ENABLED      = NEW_RECORD_ENABLED     ;
				layoutField.EXISTING_RECORD_ENABLED = EXISTING_RECORD_ENABLED;
				layoutField.TITLE                   = TITLE                  ;
				layoutField.ALTERNATE_VIEW          = ALTERNATE_VIEW         ;

				this.props.onEditComplete(layoutField);
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
				this.props.onEditComplete(null);
		}
	}

	private _onValue_Change = (name: string, value: any) =>
	{
		// https://www.freecodecamp.org/news/get-pro-with-react-setstate-in-10-minutes-d38251d1c781/
		let newField: any = {};
		newField[name] = value;
		this.setState(newField);
	}

	private AddTextBoxProperty = (sFieldName) =>
	{
		return(
			<tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<input 
						id={ 'ctlNewRecord_' + sFieldName }
						key={ 'ctlNewRecord_' + sFieldName }
						style={ {width: '100%'} }
						autoComplete='off'
						value={ this.state[sFieldName] }
						onChange={ (e) => this._onValue_Change(sFieldName, e.target.value) }
					/>
				</td>
			</tr>
		);
	}

	private AddReadOnlyProperty = (sFieldName) =>
	{
		return(
			<tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<span 
						id={ 'ctlNewRecord_' + sFieldName }
						key={ 'ctlNewRecord_' + sFieldName }
					>
						{ this.state[sFieldName] }
					</span>
				</td>
			</tr>
		);
	}

	private AddListBoxProperty = (sFieldName, arrLIST) =>
	{
		return(
			<tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<select
						id={ 'ctlNewRecord_' + sFieldName }
						style={ {width: 'auto', margin: 2} }
						value={ this.state[sFieldName] }
						onChange={ (e) => this._onValue_Change(sFieldName, e.target.value) }
						>
						{
							arrLIST.map((item, index) => 
							{
								return (<option key={ 'ctlNewRecord_' + sFieldName + '_' + index.toString() } id={ 'ctlNewRecord_' + sFieldName + '_' + + index.toString() } value={ item }>{ item }</option>);
							})
						}
					</select>
				</td>
			</tr>
		);
	}

	private AddCheckBoxProperty = (sFieldName) =>
	{
		return(
			<tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<input 
						id={ 'ctlNewRecord_' + sFieldName }
						key={ 'ctlNewRecord_' + sFieldName }
						type='checkbox'
						checked={ this.state[sFieldName] }
						onChange={ (e) => this._onValue_Change(sFieldName, e.target.checked) }
					/>
				</td>
			</tr>
		);
	}

	public render()
	{
		const { layoutField } = this.props;
		const { ID, EDIT_NAME, MODULE_NAME, CONTROL_NAME, RELATIONSHIP_ORDER, RELATIONSHIP_ENABLED, NEW_RECORD_ENABLED, EXISTING_RECORD_ENABLED, TITLE, ALTERNATE_VIEW } = this.state;

		if ( layoutField )
		{
			return (
			<div style={ {lineHeight: '16px', padding: '.5em'} }>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave   }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
				<table cellPadding={ 3 } style={{ padding: '2px', border: '1px solid #cbcaca', marginTop: '4px' }}>
					{ this.AddReadOnlyProperty('MODULE_NAME'            ) }
					{ this.AddReadOnlyProperty('CONTROL_NAME'           ) }
					{ this.AddTextBoxProperty ('TITLE'                  ) }
					{ this.AddTextBoxProperty ('ALTERNATE_VIEW'         ) }
					{ this.AddCheckBoxProperty('RELATIONSHIP_ENABLED'   ) }
					{ this.AddCheckBoxProperty('NEW_RECORD_ENABLED'     ) }
					{ this.AddCheckBoxProperty('EXISTING_RECORD_ENABLED') }
				</table>
			</div>
			);
		}
		else
		{
			return null;
		}
	}
}


