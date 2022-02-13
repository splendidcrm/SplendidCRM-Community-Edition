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

interface IListPropertiesEditorProps
{
	layoutField               : any;
	moduleFields              : Array<any>;
	onEditComplete            : Function;
	MODULE_TERMINOLOGY        : string[];
}

interface IListPropertiesEditorState
{
	COLUMN_TYPES              : string[];
	MODULE_TYPES              : string[];
	LIST_NAMES                : string[];
	DATA_FORMATS              : string[];
	MODULE_FIELDS             : string[];
	HORIZONTAL_ALIGN          : string[];
	VERTICAL_ALIGN            : string[];

	COLUMN_INDEX              : number;
	COLUMN_TYPE               : string;
	DATA_FORMAT               : string;
	HEADER_TEXT               : string;
	DATA_FIELD                : string;
	SORT_EXPRESSION           : string;
	ITEMSTYLE_WIDTH           : string;
	ITEMSTYLE_CSSCLASS        : string;
	ITEMSTYLE_HORIZONTAL_ALIGN: string;
	ITEMSTYLE_VERTICAL_ALIGN  : string;
	ITEMSTYLE_WRAP            : boolean;
	URL_FIELD                 : string;
	URL_FORMAT                : string;
	URL_TARGET                : string;
	URL_MODULE                : string;
	URL_ASSIGNED_FIELD        : string;
	MODULE_TYPE               : string;
	LIST_NAME                 : string;
	PARENT_FIELD              : string;
	error?                    : string;
}

export default class ListPropertiesEditor extends React.Component<IListPropertiesEditorProps, IListPropertiesEditorState>
{
	private _isMounted = false;

	constructor(props: IListPropertiesEditorProps)
	{
		super(props);
		const { layoutField, moduleFields } = props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let COLUMN_TYPES: string[] = [];
		COLUMN_TYPES.push('BoundColumn'    );
		COLUMN_TYPES.push('TemplateColumn' );
		COLUMN_TYPES.push('HyperLinkColumn');
		// 03/02/2020 Paul.  Use slice so that we are modifying a copy. 
		let MODULE_TYPES: string[] = L10n.GetList('ModuleTypes'         );
		let LIST_NAMES  : string[] = L10n.GetList('TerminologyPickLists');
		if ( MODULE_TYPES != null )
		{
			MODULE_TYPES = MODULE_TYPES.slice();
			MODULE_TYPES.unshift('');
		}
		if ( LIST_NAMES != null )
		{
			LIST_NAMES = LIST_NAMES.slice();
			LIST_NAMES.unshift('');
		}
		let DATA_FORMATS: string[] = [];
		DATA_FORMATS.push('');
		DATA_FORMATS.push('HyperLink'  );
		DATA_FORMATS.push('Date'       );
		DATA_FORMATS.push('DateTime'   );
		DATA_FORMATS.push('Currency'   );
		DATA_FORMATS.push('Image'      );
		DATA_FORMATS.push('Hover'      );
		DATA_FORMATS.push('JavaScript' );
		DATA_FORMATS.push('JavaImage'  );
		DATA_FORMATS.push('ImageButton');
		DATA_FORMATS.push('Hidden'     );
		// 05/15/2016 Paul.  
		DATA_FORMATS.push('Tags'       );
		let MODULE_FIELDS   : string[] = [];
		for ( let i = 0; i < moduleFields.length; i++ )
		{
			MODULE_FIELDS.push(moduleFields[i].ColumnName);
		}
		let HORIZONTAL_ALIGN: string[] = [];
		HORIZONTAL_ALIGN.push('');
		HORIZONTAL_ALIGN.push('Left'   );
		HORIZONTAL_ALIGN.push('Center' );
		HORIZONTAL_ALIGN.push('Right'  );
		HORIZONTAL_ALIGN.push('Justify');
		let VERTICAL_ALIGN  : string[] = [];
		VERTICAL_ALIGN.push('');
		VERTICAL_ALIGN.push('Bottom');
		VERTICAL_ALIGN.push('Middle');
		VERTICAL_ALIGN.push('Top'   );

		let COLUMN_INDEX               : number = null;
		let COLUMN_TYPE                : string = null;
		let DATA_FORMAT                : string = null;
		let HEADER_TEXT                : string = null;
		let DATA_FIELD                 : string = null;
		let SORT_EXPRESSION            : string = null;
		let ITEMSTYLE_WIDTH            : string = null;
		let ITEMSTYLE_CSSCLASS         : string = null;
		let ITEMSTYLE_HORIZONTAL_ALIGN : string = null;
		let ITEMSTYLE_VERTICAL_ALIGN   : string = null;
		let ITEMSTYLE_WRAP             : boolean = null;
		let URL_FIELD                  : string = null;
		let URL_FORMAT                 : string = null;
		let URL_TARGET                 : string = null;
		let URL_MODULE                 : string = null;
		let URL_ASSIGNED_FIELD         : string = null;
		let MODULE_TYPE                : string = null;
		let LIST_NAME                  : string = null;
		let PARENT_FIELD               : string = null;
		if ( layoutField != null )
		{
			COLUMN_INDEX               = layoutField.COLUMN_INDEX              ;
			COLUMN_TYPE                = layoutField.COLUMN_TYPE               ;
			DATA_FORMAT                = layoutField.DATA_FORMAT               ;
			HEADER_TEXT                = layoutField.HEADER_TEXT               ;
			DATA_FIELD                 = layoutField.DATA_FIELD                ;
			SORT_EXPRESSION            = layoutField.SORT_EXPRESSION           ;
			ITEMSTYLE_WIDTH            = layoutField.ITEMSTYLE_WIDTH           ;
			ITEMSTYLE_CSSCLASS         = layoutField.ITEMSTYLE_CSSCLASS        ;
			ITEMSTYLE_HORIZONTAL_ALIGN = layoutField.ITEMSTYLE_HORIZONTAL_ALIGN;
			ITEMSTYLE_VERTICAL_ALIGN   = layoutField.ITEMSTYLE_VERTICAL_ALIGN  ;
			ITEMSTYLE_WRAP             = layoutField.ITEMSTYLE_WRAP            ;
			URL_FIELD                  = layoutField.URL_FIELD                 ;
			URL_FORMAT                 = layoutField.URL_FORMAT                ;
			URL_TARGET                 = layoutField.URL_TARGET                ;
			URL_MODULE                 = layoutField.URL_MODULE                ;
			URL_ASSIGNED_FIELD         = layoutField.URL_ASSIGNED_FIELD        ;
			MODULE_TYPE                = layoutField.MODULE_TYPE               ;
			LIST_NAME                  = layoutField.LIST_NAME                 ;
			PARENT_FIELD               = layoutField.PARENT_FIELD              ;
		}
		this.state =
		{
			COLUMN_TYPES              ,
			MODULE_TYPES              ,
			LIST_NAMES                ,
			DATA_FORMATS              ,
			MODULE_FIELDS             ,
			HORIZONTAL_ALIGN          ,
			VERTICAL_ALIGN            ,
			COLUMN_INDEX              ,
			COLUMN_TYPE               ,
			DATA_FORMAT               ,
			HEADER_TEXT               ,
			DATA_FIELD                ,
			SORT_EXPRESSION           ,
			ITEMSTYLE_WIDTH           ,
			ITEMSTYLE_CSSCLASS        ,
			ITEMSTYLE_HORIZONTAL_ALIGN,
			ITEMSTYLE_VERTICAL_ALIGN  ,
			ITEMSTYLE_WRAP            ,
			URL_FIELD                 ,
			URL_FORMAT                ,
			URL_TARGET                ,
			URL_MODULE                ,
			URL_ASSIGNED_FIELD        ,
			MODULE_TYPE               ,
			LIST_NAME                 ,
			PARENT_FIELD              ,
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

 	async componentDidUpdate(prevProps: IListPropertiesEditorProps)
	{
		const { layoutField, moduleFields } = this.props;
		if ( this.props.layoutField != prevProps.layoutField )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props);
			let COLUMN_INDEX               : number = null;
			let COLUMN_TYPE                : string = null;
			let DATA_FORMAT                : string = null;
			let HEADER_TEXT                : string = null;
			let DATA_FIELD                 : string = null;
			let SORT_EXPRESSION            : string = null;
			let ITEMSTYLE_WIDTH            : string = null;
			let ITEMSTYLE_CSSCLASS         : string = null;
			let ITEMSTYLE_HORIZONTAL_ALIGN : string = null;
			let ITEMSTYLE_VERTICAL_ALIGN   : string = null;
			let ITEMSTYLE_WRAP             : boolean = null;
			let URL_FIELD                  : string = null;
			let URL_FORMAT                 : string = null;
			let URL_TARGET                 : string = null;
			let URL_MODULE                 : string = null;
			let URL_ASSIGNED_FIELD         : string = null;
			let MODULE_TYPE                : string = null;
			let LIST_NAME                  : string = null;
			let PARENT_FIELD               : string = null;
			if ( layoutField != null )
			{
				COLUMN_INDEX               = layoutField.COLUMN_INDEX              ;
				COLUMN_TYPE                = layoutField.COLUMN_TYPE               ;
				DATA_FORMAT                = layoutField.DATA_FORMAT               ;
				HEADER_TEXT                = layoutField.HEADER_TEXT               ;
				DATA_FIELD                 = layoutField.DATA_FIELD                ;
				SORT_EXPRESSION            = layoutField.SORT_EXPRESSION           ;
				ITEMSTYLE_WIDTH            = layoutField.ITEMSTYLE_WIDTH           ;
				ITEMSTYLE_CSSCLASS         = layoutField.ITEMSTYLE_CSSCLASS        ;
				ITEMSTYLE_HORIZONTAL_ALIGN = layoutField.ITEMSTYLE_HORIZONTAL_ALIGN;
				ITEMSTYLE_VERTICAL_ALIGN   = layoutField.ITEMSTYLE_VERTICAL_ALIGN  ;
				ITEMSTYLE_WRAP             = layoutField.ITEMSTYLE_WRAP            ;
				URL_FIELD                  = layoutField.URL_FIELD                 ;
				URL_FORMAT                 = layoutField.URL_FORMAT                ;
				URL_TARGET                 = layoutField.URL_TARGET                ;
				URL_MODULE                 = layoutField.URL_MODULE                ;
				URL_ASSIGNED_FIELD         = layoutField.URL_ASSIGNED_FIELD        ;
				MODULE_TYPE                = layoutField.MODULE_TYPE               ;
				LIST_NAME                  = layoutField.LIST_NAME                 ;
				PARENT_FIELD               = layoutField.PARENT_FIELD              ;
			}
			this.setState(
			{
				COLUMN_INDEX              ,
				COLUMN_TYPE               ,
				DATA_FORMAT               ,
				HEADER_TEXT               ,
				DATA_FIELD                ,
				SORT_EXPRESSION           ,
				ITEMSTYLE_WIDTH           ,
				ITEMSTYLE_CSSCLASS        ,
				ITEMSTYLE_HORIZONTAL_ALIGN,
				ITEMSTYLE_VERTICAL_ALIGN  ,
				ITEMSTYLE_WRAP            ,
				URL_FIELD                 ,
				URL_FORMAT                ,
				URL_TARGET                ,
				URL_MODULE                ,
				URL_ASSIGNED_FIELD        ,
				MODULE_TYPE               ,
				LIST_NAME                 ,
				PARENT_FIELD              ,
			});
		}
	}

	private _onSave = async (e) =>
	{
		const { COLUMN_TYPE, DATA_FORMAT, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH, ITEMSTYLE_CSSCLASS, ITEMSTYLE_HORIZONTAL_ALIGN, ITEMSTYLE_VERTICAL_ALIGN, ITEMSTYLE_WRAP, URL_FIELD, URL_FORMAT, URL_TARGET, URL_MODULE, URL_ASSIGNED_FIELD, MODULE_TYPE, LIST_NAME, PARENT_FIELD } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let layoutField: any = {};
				layoutField.COLUMN_TYPE                = COLUMN_TYPE;
				layoutField.DATA_FORMAT                = (this.IsFieldVisible('DATA_FORMAT'               ) ? DATA_FORMAT                : null);;
				layoutField.HEADER_TEXT                = (this.IsFieldVisible('HEADER_TEXT'               ) ? HEADER_TEXT                : null);;
				layoutField.DATA_FIELD                 = (this.IsFieldVisible('DATA_FIELD'                ) ? DATA_FIELD                 : null);;
				layoutField.SORT_EXPRESSION            = (this.IsFieldVisible('SORT_EXPRESSION'           ) ? SORT_EXPRESSION            : null);;
				layoutField.ITEMSTYLE_WIDTH            = (this.IsFieldVisible('ITEMSTYLE_WIDTH'           ) ? ITEMSTYLE_WIDTH            : null);;
				layoutField.ITEMSTYLE_CSSCLASS         = (this.IsFieldVisible('ITEMSTYLE_CSSCLASS'        ) ? ITEMSTYLE_CSSCLASS         : null);;
				layoutField.ITEMSTYLE_HORIZONTAL_ALIGN = (this.IsFieldVisible('ITEMSTYLE_HORIZONTAL_ALIGN') ? ITEMSTYLE_HORIZONTAL_ALIGN : null);;
				layoutField.ITEMSTYLE_VERTICAL_ALIGN   = (this.IsFieldVisible('ITEMSTYLE_VERTICAL_ALIGN'  ) ? ITEMSTYLE_VERTICAL_ALIGN   : null);;
				layoutField.ITEMSTYLE_WRAP             = (this.IsFieldVisible('ITEMSTYLE_WRAP'            ) ? ITEMSTYLE_WRAP             : null);;
				layoutField.URL_FIELD                  = (this.IsFieldVisible('URL_FIELD'                 ) ? URL_FIELD                  : null);;
				layoutField.URL_FORMAT                 = (this.IsFieldVisible('URL_FORMAT'                ) ? URL_FORMAT                 : null);;
				layoutField.URL_TARGET                 = (this.IsFieldVisible('URL_TARGET'                ) ? URL_TARGET                 : null);;
				layoutField.URL_MODULE                 = (this.IsFieldVisible('URL_MODULE'                ) ? URL_MODULE                 : null);;
				layoutField.URL_ASSIGNED_FIELD         = (this.IsFieldVisible('URL_ASSIGNED_FIELD'        ) ? URL_ASSIGNED_FIELD         : null);;
				layoutField.MODULE_TYPE                = (this.IsFieldVisible('MODULE_TYPE'               ) ? MODULE_TYPE                : null);;
				layoutField.LIST_NAME                  = (this.IsFieldVisible('LIST_NAME'                 ) ? LIST_NAME                  : null);;
				layoutField.PARENT_FIELD               = (this.IsFieldVisible('PARENT_FIELD'              ) ? PARENT_FIELD               : null);;

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

	private IsFieldVisible = (sFieldName) =>
	{
		// 03/12/2020 Paul.  All fields area always displayed. 
		return true;
	}

	private AddTextAreaProperty = (sFieldName) =>
	{
		return(
			this.IsFieldVisible(sFieldName)
			? <tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<textarea 
						id={ 'ctlNewRecord_' + sFieldName }
						key={ 'ctlNewRecord_' + sFieldName }
						autoComplete='off'
						rows={ 3 }
						style={ {width: '95%'} }
						value={ this.state[sFieldName] }
						onChange={ (e) => this._onValue_Change(sFieldName, e.target.value) }
					/>
				</td>
			</tr>
			: null
		);
	}

	private AddTextBoxProperty = (sFieldName) =>
	{
		return(
			this.IsFieldVisible(sFieldName)
			? <tr>
				<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
					<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_' + sFieldName) }</label>
				</td>
				<td>
					<input 
						id={ 'ctlNewRecord_' + sFieldName }
						key={ 'ctlNewRecord_' + sFieldName }
						autoComplete='off'
						value={ this.state[sFieldName] }
						onChange={ (e) => this._onValue_Change(sFieldName, e.target.value) }
					/>
				</td>
			</tr>
			: null
		);
	}

	private AddReadOnlyProperty = (sFieldName) =>
	{
		return(
			this.IsFieldVisible(sFieldName)
			? <tr>
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
			: null
		);
	}

	// 11/21/2021 Paul.  Add error log to location customer reported issue. 
	private AddListBoxProperty = (sFieldName, arrLIST) =>
	{
		return(
			this.IsFieldVisible(sFieldName)
			? <tr>
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
						{ arrLIST
						? arrLIST.map((item, index) => 
							{
								return (<option key={ 'ctlNewRecord_' + sFieldName + '_' + index.toString() } id={ 'ctlNewRecord_' + sFieldName + '_' + + index.toString() } value={ item }>{ item }</option>);
							})
						: console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AddListBoxProperty', 'arrLIST is null for ' + sFieldName)
						}
					</select>
				</td>
			</tr>
			: null
		);
	}

	private AddCheckBoxProperty = (sFieldName) =>
	{
		return(
			this.IsFieldVisible(sFieldName)
			? <tr>
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
			: null
		);
	}

	public render()
	{
		const { layoutField, MODULE_TERMINOLOGY } = this.props;
		const { COLUMN_TYPES, MODULE_TYPES, LIST_NAMES, DATA_FORMATS, MODULE_FIELDS, HORIZONTAL_ALIGN, VERTICAL_ALIGN } = this.state;

		if ( layoutField )
		{
			return (
			<div style={ {lineHeight: '16px', padding: '.5em'} }>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave   }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
				<table cellPadding={ 3 } style={{ padding: '2px', border: '1px solid #cbcaca', marginTop: '4px' }}>
					{ this.AddListBoxProperty ('COLUMN_TYPE'               , COLUMN_TYPES      ) }
					{ this.AddListBoxProperty ('DATA_FORMAT'               , DATA_FORMATS      ) }
					{ this.AddListBoxProperty ('HEADER_TEXT'               , MODULE_TERMINOLOGY) }
					{ this.AddReadOnlyProperty('DATA_FIELD'                ) }
					{ this.AddListBoxProperty ('SORT_EXPRESSION'           , MODULE_FIELDS     ) }
					{ this.AddTextBoxProperty ('ITEMSTYLE_WIDTH'           ) }
					{ this.AddTextBoxProperty ('ITEMSTYLE_CSSCLASS'        ) }
					{ this.AddListBoxProperty ('ITEMSTYLE_HORIZONTAL_ALIGN', HORIZONTAL_ALIGN  ) }
					{ this.AddListBoxProperty ('ITEMSTYLE_VERTICAL_ALIGN'  , VERTICAL_ALIGN    ) }
					{ this.AddCheckBoxProperty('ITEMSTYLE_WRAP'            ) }
					{ this.AddTextAreaProperty('URL_FIELD'                 ) }
					{ this.AddTextAreaProperty('URL_FORMAT'                ) }
					{ this.AddTextBoxProperty ('URL_TARGET'                ) }
					{ this.AddTextBoxProperty ('URL_MODULE'                ) }
					{ this.AddTextBoxProperty ('URL_ASSIGNED_FIELD'        ) }
					{ this.AddListBoxProperty ('MODULE_TYPE'               , MODULE_TYPES      ) }
					{ this.AddListBoxProperty ('LIST_NAME'                 , LIST_NAMES        ) }
					{ this.AddTextBoxProperty ('PARENT_FIELD'              ) }
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


