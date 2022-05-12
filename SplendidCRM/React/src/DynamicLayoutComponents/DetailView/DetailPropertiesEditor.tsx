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

interface IDetailPropertiesEditorProps
{
	layoutField               : any;
	moduleFields              : Array<any>;
	onEditComplete            : Function;
	MODULE_TERMINOLOGY        : string[];
	DATA_COLUMNS              : number;
}

interface IDetailPropertiesEditorState
{
	FIELD_TYPES               : string[];
	MODULE_TYPES              : string[];
	LIST_NAMES                : string[];
	COLSPANS                  : number[];
	DATA_LABEL_FREE_FORM      : boolean;
	DATA_FIELD_FREE_FORM      : boolean;

	FIELD_INDEX               : number;
	FIELD_TYPE                : string;
	DATA_LABEL                : string;
	DATA_FIELD                : string;
	DATA_FORMAT               : string;
	URL_FIELD                 : string;
	URL_FORMAT                : string;
	URL_TARGET                : string;
	MODULE_TYPE               : string;
	LIST_NAME                 : string;
	COLSPAN                   : string;
	TOOL_TIP                  : string;
	PARENT_FIELD              : string;
	error?                    : string;
}

export default class DetailPropertiesEditor extends React.Component<IDetailPropertiesEditorProps, IDetailPropertiesEditorState>
{
	private _isMounted = false;

	constructor(props: IDetailPropertiesEditorProps)
	{
		super(props);
		const { layoutField, moduleFields } = props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let FIELD_TYPES: string[] = [];
		FIELD_TYPES.push('String'    );
		FIELD_TYPES.push('TextBox'   );
		FIELD_TYPES.push('HyperLink' );
		FIELD_TYPES.push('ModuleLink');
		FIELD_TYPES.push('CheckBox'  );
		FIELD_TYPES.push('Button'    );
		FIELD_TYPES.push('Image'     );
		FIELD_TYPES.push('File'      );
		FIELD_TYPES.push('Blank'     );
		FIELD_TYPES.push('Line'      );
		FIELD_TYPES.push('IFrame'    );
		FIELD_TYPES.push('JavaScript');
		FIELD_TYPES.push('Separator' );
		FIELD_TYPES.push('Header'    );
		FIELD_TYPES.push('Tags'      );
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
		let maxColumns: number = Sql.ToInteger(props.DATA_COLUMNS);
		if ( maxColumns == 0 )
		{
			maxColumns = 2;
		}
		let COLSPANS: number[] = [];
		COLSPANS.push(0);
		for ( var i = 1; i < maxColumns; i++ )
		{
			COLSPANS.push(2 * i + 1);
		}
		COLSPANS.push(-1);

		let DATA_LABEL_FREE_FORM: boolean = false;
		let DATA_FIELD_FREE_FORM: boolean = false;
		let FIELD_INDEX         : number = null;
		let FIELD_TYPE          : string = null;
		let DATA_LABEL          : string = null;
		let DATA_FIELD          : string = null;
		let DATA_FORMAT         : string = null;
		let URL_FIELD           : string = null;
		let URL_FORMAT          : string = null;
		let URL_TARGET          : string = null;
		let MODULE_TYPE         : string = null;
		let LIST_NAME           : string = null;
		let COLSPAN             : string = null;
		let TOOL_TIP            : string = null;
		let PARENT_FIELD        : string = null;
		if ( layoutField != null )
		{
			FIELD_INDEX  = layoutField.FIELD_INDEX ;
			FIELD_TYPE   = layoutField.FIELD_TYPE  ;
			DATA_LABEL   = layoutField.DATA_LABEL  ;
			DATA_FIELD   = layoutField.DATA_FIELD  ;
			DATA_FORMAT  = layoutField.DATA_FORMAT ;
			URL_FIELD    = layoutField.URL_FIELD   ;
			URL_FORMAT   = layoutField.URL_FORMAT  ;
			URL_TARGET   = layoutField.URL_TARGET  ;
			MODULE_TYPE  = layoutField.MODULE_TYPE ;
			LIST_NAME    = layoutField.LIST_NAME   ;
			COLSPAN      = layoutField.COLSPAN     ;
			TOOL_TIP     = layoutField.TOOL_TIP    ;
			PARENT_FIELD = layoutField.PARENT_FIELD;
		}
		if ( !Sql.IsEmptyString(DATA_LABEL) && props.MODULE_TERMINOLOGY && props.MODULE_TERMINOLOGY.indexOf(DATA_LABEL) < 0 )
		{
			DATA_LABEL_FREE_FORM = true;
		}
		if ( !Sql.IsEmptyString(DATA_FIELD) )
		{
			DATA_FIELD_FREE_FORM = true;
			for ( let i = 0; i < moduleFields.length; i++ )
			{
				let field: any = moduleFields[i];
				if ( DATA_FIELD == field.ColumnName )
				{
					DATA_FIELD_FREE_FORM = false;
					break;
				}
			}
		}
		this.state =
		{
			FIELD_TYPES         ,
			MODULE_TYPES        ,
			LIST_NAMES          ,
			COLSPANS            ,
			DATA_LABEL_FREE_FORM,
			DATA_FIELD_FREE_FORM,
			FIELD_INDEX         ,
			FIELD_TYPE          ,
			DATA_LABEL          ,
			DATA_FIELD          ,
			DATA_FORMAT         ,
			URL_FIELD           ,
			URL_FORMAT          ,
			URL_TARGET          ,
			MODULE_TYPE         ,
			LIST_NAME           ,
			COLSPAN             ,
			TOOL_TIP            ,
			PARENT_FIELD        ,
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

 	async componentDidUpdate(prevProps: IDetailPropertiesEditorProps)
	{
		const { layoutField, moduleFields } = this.props;
		if ( this.props.layoutField != prevProps.layoutField )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props);
			let DATA_LABEL_FREE_FORM: boolean = false;
			let DATA_FIELD_FREE_FORM: boolean = false;
			let FIELD_INDEX         : number = null;
			let FIELD_TYPE          : string = null;
			let DATA_LABEL          : string = null;
			let DATA_FIELD          : string = null;
			let DATA_FORMAT         : string = null;
			let URL_FIELD           : string = null;
			let URL_FORMAT          : string = null;
			let URL_TARGET          : string = null;
			let MODULE_TYPE         : string = null;
			let LIST_NAME           : string = null;
			let COLSPAN             : string = null;
			let TOOL_TIP            : string = null;
			let PARENT_FIELD        : string = null;
			if ( layoutField != null )
			{
				FIELD_INDEX  = layoutField.FIELD_INDEX ;
				FIELD_TYPE   = layoutField.FIELD_TYPE  ;
				DATA_LABEL   = layoutField.DATA_LABEL  ;
				DATA_FIELD   = layoutField.DATA_FIELD  ;
				DATA_FORMAT  = layoutField.DATA_FORMAT ;
				URL_FIELD    = layoutField.URL_FIELD   ;
				URL_FORMAT   = layoutField.URL_FORMAT  ;
				URL_TARGET   = layoutField.URL_TARGET  ;
				MODULE_TYPE  = layoutField.MODULE_TYPE ;
				LIST_NAME    = layoutField.LIST_NAME   ;
				COLSPAN      = layoutField.COLSPAN     ;
				TOOL_TIP     = layoutField.TOOL_TIP    ;
				PARENT_FIELD = layoutField.PARENT_FIELD;
			}
			if ( !Sql.IsEmptyString(DATA_LABEL) && this.props.MODULE_TERMINOLOGY.indexOf(DATA_LABEL) == -1 )
			{
				DATA_LABEL_FREE_FORM = true;
			}
			if ( !Sql.IsEmptyString(DATA_FIELD) )
			{
				DATA_FIELD_FREE_FORM = true;
				for ( let i = 0; i < moduleFields.length; i++ )
				{
					let field: any = moduleFields[i];
					if ( DATA_FIELD == field.ColumnName )
					{
						DATA_FIELD_FREE_FORM = false;
						break;
					}
				}
			}
			this.setState(
			{
				DATA_LABEL_FREE_FORM,
				DATA_FIELD_FREE_FORM,
				FIELD_INDEX         ,
				FIELD_TYPE          ,
				DATA_LABEL          ,
				DATA_FIELD          ,
				DATA_FORMAT         ,
				URL_FIELD           ,
				URL_FORMAT          ,
				URL_TARGET          ,
				MODULE_TYPE         ,
				LIST_NAME           ,
				COLSPAN             ,
				TOOL_TIP            ,
				PARENT_FIELD        ,
			});
		}
	}

	private _onSave = async (e) =>
	{
		const { FIELD_INDEX, FIELD_TYPE, DATA_LABEL, DATA_FIELD, DATA_FORMAT, URL_FIELD, URL_FORMAT, URL_TARGET, MODULE_TYPE, LIST_NAME, COLSPAN, TOOL_TIP, PARENT_FIELD } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let layoutField: any = {};
				layoutField.FIELD_TYPE   = FIELD_TYPE  ;
				layoutField.DATA_LABEL   = (this.IsFieldVisible('DATA_LABEL'  ) ? DATA_LABEL             : null);
				layoutField.DATA_FIELD   = (this.IsFieldVisible('DATA_FIELD'  ) ? DATA_FIELD             : null);
				layoutField.DATA_FORMAT  = (this.IsFieldVisible('DATA_FORMAT' ) ? DATA_FORMAT            : null);
				layoutField.URL_FIELD    = (this.IsFieldVisible('URL_FIELD'   ) ? URL_FIELD              : null);
				layoutField.URL_FORMAT   = (this.IsFieldVisible('URL_FORMAT'  ) ? URL_FORMAT             : null);
				layoutField.URL_TARGET   = (this.IsFieldVisible('URL_TARGET'  ) ? URL_TARGET             : null);
				layoutField.MODULE_TYPE  = (this.IsFieldVisible('MODULE_TYPE' ) ? MODULE_TYPE            : null);
				layoutField.LIST_NAME    = (this.IsFieldVisible('LIST_NAME'   ) ? LIST_NAME              : null);
				layoutField.COLSPAN      = (this.IsFieldVisible('COLSPAN'     ) ? Sql.ToInteger(COLSPAN) : null);
				layoutField.TOOL_TIP     = (this.IsFieldVisible('TOOL_TIP'    ) ? TOOL_TIP               : null);
				layoutField.PARENT_FIELD = (this.IsFieldVisible('PARENT_FIELD') ? PARENT_FIELD           : null);
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
		const { MODULE_TERMINOLOGY } = this.props;
		const { DATA_LABEL } = this.state;
		// https://www.freecodecamp.org/news/get-pro-with-react-setstate-in-10-minutes-d38251d1c781/
		let newField: any = {};
		newField[name] = value;
		this.setState(newField);
		if ( name == 'DATA_LABEL_FREE_FORM' )
		{
			// 03/04/2020 Paul.  If turning off free form, then lookup existing value. 
			if ( !value )
			{
				if ( MODULE_TERMINOLOGY.indexOf(DATA_LABEL) < 0 )
				{
					this.setState({ DATA_LABEL: '' });
				}
			}
		}
	}

	private IsFieldVisible = (sFieldName) =>
	{
		const { FIELD_TYPE } = this.state;
		let bShowField: boolean = true;
		switch ( FIELD_TYPE )
		{
			// 08/02/2010 Paul.  Show the URL fields for a string so that we can add a LinkedIn icon. 
			// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			case "String"    :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = true ;  break;
					case 'LIST_NAME'   :  bShowField = true ;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = true ;  break;
				}
				break;
			}
			// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
			case "ModuleLink":
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = true ;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "TextBox"   :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			// 05/14/2016 Paul.  Add Tags module. 
			case "Tags"      :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			// 04/20/2012 Paul.  Show the Module Type for a HyperLink. 
			case "HyperLink" :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = true ;  break;
					case 'URL_FORMAT'  :  bShowField = true ;  break;
					case 'URL_TARGET'  :  bShowField = true ;  break;
					case 'MODULE_TYPE' :  bShowField = true ;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "CheckBox"  :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "Button"    :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "Image"     :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					// 02/22/2022 Paul.  Allow image to be formatted. 
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			// 05/27/2016 Paul.  File type should have been added in 2010 when first supported. 
			case "File"      :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = true ;  break;
					case 'URL_FORMAT'  :  bShowField = true ;  break;
					case 'URL_TARGET'  :  bShowField = true ;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "Blank"     :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = false;  break;
					case 'DATA_FIELD'  :  bShowField = false;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = false;  break;
					case 'TOOL_TIP'    :  bShowField = false;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "Line"      :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = false;  break;
					case 'DATA_FIELD'  :  bShowField = false;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = false;  break;
					case 'TOOL_TIP'    :  bShowField = false;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "IFrame"    :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = true ;  break;
					case 'URL_FORMAT'  :  bShowField = true ;  break;
					case 'URL_TARGET'  :  bShowField = true ;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = true ;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
			case "JavaScript":
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = false;  break;
					case 'URL_FIELD'   :  bShowField = true ;  break;
					case 'URL_FORMAT'  :  bShowField = true ;  break;
					case 'URL_TARGET'  :  bShowField = true ;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = false;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			// 09/02/2012 Paul.  A separator is just like a blank. 
			// 09/16/2012 Paul.  The data field can be used as the table id. 
			// 09/20/2012 Paul.  Data Format will store initial visibility state. 
			case "Separator" :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = false;  break;
					case 'DATA_FIELD'  :  bShowField = true ;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = false;  break;
					case 'TOOL_TIP'    :  bShowField = false;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
			case "Header"    :
			{
				// 04/14/2022 Paul.  Header does not have Data Field.  Enable Data Format for Pacific theme. 
				switch ( sFieldName )
				{
					case 'DATA_LABEL'  :  bShowField = true ;  break;
					case 'DATA_FIELD'  :  bShowField = false;  break;
					case 'DATA_FORMAT' :  bShowField = true ;  break;
					case 'URL_FIELD'   :  bShowField = false;  break;
					case 'URL_FORMAT'  :  bShowField = false;  break;
					case 'URL_TARGET'  :  bShowField = false;  break;
					case 'MODULE_TYPE' :  bShowField = false;  break;
					case 'LIST_NAME'   :  bShowField = false;  break;
					case 'COLSPAN'     :  bShowField = true ;  break;
					case 'TOOL_TIP'    :  bShowField = false;  break;
					case 'PARENT_FIELD':  bShowField = false;  break;
				}
				break;
			}
		}
		return bShowField;
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

	public render()
	{
		const { layoutField, moduleFields, MODULE_TERMINOLOGY } = this.props;
		const { FIELD_TYPES, MODULE_TYPES, LIST_NAMES, COLSPANS, DATA_LABEL_FREE_FORM, DATA_FIELD_FREE_FORM } = this.state;
		const { FIELD_TYPE, DATA_LABEL, DATA_FIELD } = this.state;

		if ( layoutField )
		{
			return (
			<div style={ {lineHeight: '16px', padding: '.5em'} }>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave   }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
				<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
				<table cellPadding={ 3 } style={{ padding: '2px', border: '1px solid #cbcaca', marginTop: '4px' }}>
					{ this.IsFieldVisible('FIELD_TYPE')
					? <tr>
						<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
							<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_FIELD_TYPE') }</label>
						</td>
						<td>
							<select
								id='ctlNewRecord_FIELD_TYPE'
								style={ {width: 'auto', margin: 2} }
								value={ FIELD_TYPE }
								onChange={ (e) => this._onValue_Change('FIELD_TYPE', e.target.value) }
								>
								{
									FIELD_TYPES.map((item, index) => 
									{
										return (<option key={ 'ctlNewRecord_FIELD_TYPE_' + index.toString() } id={ 'ctlNewRecord_FIELD_TYPE' + index.toString() } value={ item }>{ item }</option>);
									})
								}
							</select>
						</td>
					</tr>
					: null
					}
					{ this.IsFieldVisible('DATA_LABEL')
					? <tr>
						<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
							<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_DATA_LABEL') }</label><br />
							(<input
								type='checkbox'
								checked={ DATA_LABEL_FREE_FORM }
								onChange={ (e) => this._onValue_Change('DATA_LABEL_FREE_FORM', e.target.checked) }
							/> { L10n.Term('DynamicLayout.LBL_FREE_FORM_DATA') }
							)
						</td>
						<td>
							{ DATA_LABEL_FREE_FORM
							? <input
								id='ctlNewRecord_DATA_LABEL'
								autoComplete='off'
								style={ {width: '95%'} }
								value={ DATA_LABEL }
								onChange={ (e) => this._onValue_Change('DATA_LABEL', e.target.value) }
							/>
							: <select
								id='ctlNewRecord_DATA_LABEL'
								style={ {width: 'auto', margin: 2} }
								value={ DATA_LABEL }
								onChange={ (e) => this._onValue_Change('DATA_LABEL', e.target.value) }
								>
								{
									MODULE_TERMINOLOGY
									? MODULE_TERMINOLOGY.map((item, index) => 
									{
										return (<option key={ 'ctlNewRecord_DATA_LABEL_' + index.toString() } id={ 'ctlNewRecord_DATA_LABEL' + '_' + index.toString() } value={ item }>{ item }</option>);
									})
									: null
								}
							</select>
							}
						</td>
					</tr>
					: null
					}
					{ this.IsFieldVisible('DATA_FIELD')
					? <tr>
						<td style={ {width: '35%', whiteSpace: 'nowrap'} }>
							<label style={{ flex: 1 }}>{ L10n.Term('DynamicLayout.LBL_DATA_FIELD') }</label>
							(<input
								type='checkbox'
								checked={ DATA_FIELD_FREE_FORM }
								onChange={ (e) => this._onValue_Change('DATA_FIELD_FREE_FORM', e.target.checked) }
							/> { L10n.Term('DynamicLayout.LBL_FREE_FORM_DATA') }
							)
						</td>
						<td>
							{ DATA_FIELD_FREE_FORM
							? <textarea 
								id='ctlNewRecord_DATA_FIELD'
								key='ctlNewRecord_DATA_FIELD'
								autoComplete='off'
								rows={ 3 }
								style={ {width: '95%'} }
								value={ DATA_FIELD }
								onChange={ (e) => this._onValue_Change('DATA_FIELD', e.target.value) }
							/>
							: <select
								id='ctlNewRecord_DATA_FIELD'
								style={ {width: 'auto', margin: 2} }
								value={ DATA_FIELD }
								onChange={ (e) => this._onValue_Change('DATA_FIELD', e.target.value) }
								>
								{
									moduleFields
									? moduleFields.map((field, index) => 
									{
										return (<option key={ 'ctlNewRecord_DATA_FIELD_' + field.ColumnName } id={ 'ctlNewRecord_DATA_FIELD' + '_' + field.ColumnName } value={ field.ColumnName }>{ field.ColumnName }</option>);
									})
									: null
								}
							</select>
							}
						</td>
					</tr>
					: null
					}
					{ this.AddTextAreaProperty('DATA_FORMAT' ) }
					{ this.AddTextBoxProperty ('URL_FIELD'   ) }
					{ this.AddTextBoxProperty ('URL_FORMAT'  ) }
					{ this.AddTextBoxProperty ('URL_TARGET'  ) }
					{ this.AddListBoxProperty ('MODULE_TYPE' , MODULE_TYPES) }
					{ this.AddListBoxProperty ('LIST_NAME'   , LIST_NAMES  ) }
					{ this.AddListBoxProperty ('COLSPAN'     , COLSPANS    ) }
					{ this.AddTextBoxProperty ('TOOL_TIP'    ) }
					{ this.AddTextBoxProperty ('PARENT_FIELD') }
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


