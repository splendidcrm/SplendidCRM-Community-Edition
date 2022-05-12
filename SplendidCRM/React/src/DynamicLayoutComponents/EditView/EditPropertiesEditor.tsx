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

interface IEditPropertiesEditorProps
{
	layoutField               : any;
	moduleFields              : Array<any>;
	onEditComplete            : Function;
	MODULE_TERMINOLOGY        : string[];
	DATA_COLUMNS              : number;
}

interface IEditPropertiesEditorState
{
	FIELD_TYPES               : string[];
	MODULE_TYPES              : string[];
	LIST_NAMES                : string[];
	COLSPANS                  : number[];
	FIELD_VALIDATORS          : string[];
	DATA_LABEL_FREE_FORM      : boolean;
	DATA_FIELD_FREE_FORM      : boolean;

	FIELD_INDEX               : number;
	FIELD_TYPE                : string;
	DATA_LABEL                : string;
	DATA_FIELD                : string;
	DATA_FORMAT               : string;
	DISPLAY_FIELD             : string;
	CACHE_NAME                : string;
	DATA_REQUIRED             : boolean;
	UI_REQUIRED               : boolean;
	ONCLICK_SCRIPT            : string;
	FORMAT_SCRIPT             : string;
	FORMAT_TAB_INDEX          : number;
	FORMAT_MAX_LENGTH         : number;
	FORMAT_SIZE               : number;
	FORMAT_ROWS               : number;
	FORMAT_COLUMNS            : number;
	COLSPAN                   : string;
	ROWSPAN                   : number;
	FIELD_VALIDATOR_ID        : string;
	FIELD_VALIDATOR_MESSAGE   : string;
	MODULE_TYPE               : string;
	TOOL_TIP                  : string;
	RELATED_SOURCE_MODULE_NAME: string;
	RELATED_SOURCE_VIEW_NAME  : string;
	RELATED_SOURCE_ID_FIELD   : string;
	RELATED_SOURCE_NAME_FIELD : string;
	RELATED_VIEW_NAME         : string;
	RELATED_ID_FIELD          : string;
	RELATED_NAME_FIELD        : string;
	RELATED_JOIN_FIELD        : string;
	PARENT_FIELD              : string;
	error?                    : string;
}

export default class EditPropertiesEditor extends React.Component<IEditPropertiesEditorProps, IEditPropertiesEditorState>
{
	private _isMounted = false;

	constructor(props: IEditPropertiesEditorProps)
	{
		super(props);
		const { layoutField, moduleFields } = props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let FIELD_TYPES: string[] = [];
		FIELD_TYPES.push('TextBox'            );
		FIELD_TYPES.push('HtmlEditor'         );
		FIELD_TYPES.push('Label'              );
		FIELD_TYPES.push('ListBox'            );
		FIELD_TYPES.push('Radio'              );
		FIELD_TYPES.push('CheckBox'           );
		FIELD_TYPES.push('CheckBoxList'       );
		FIELD_TYPES.push('ChangeButton'       );
		FIELD_TYPES.push('ModulePopup'        );
		FIELD_TYPES.push('ModuleAutoComplete' );
		FIELD_TYPES.push('TeamSelect'         );
		FIELD_TYPES.push('UserSelect'         );
		FIELD_TYPES.push('TagSelect'          );
		FIELD_TYPES.push('NAICSCodeSelect'    );
		FIELD_TYPES.push('DatePicker'         );
		FIELD_TYPES.push('DateRange'          );
		FIELD_TYPES.push('DateTimeEdit'       );
		FIELD_TYPES.push('DateTimeNewRecord'  );
		FIELD_TYPES.push('DateTimePicker'     );
		FIELD_TYPES.push('Image'              );
		FIELD_TYPES.push('Picture'            );
		FIELD_TYPES.push('File'               );
		FIELD_TYPES.push('Password'           );
		FIELD_TYPES.push('AddressButtons'     );
		FIELD_TYPES.push('RelatedListBox'     );
		FIELD_TYPES.push('RelatedCheckBoxList');
		FIELD_TYPES.push('RelatedSelect'      );
		FIELD_TYPES.push('Hidden'             );
		FIELD_TYPES.push('Blank'              );
		FIELD_TYPES.push('Separator'          );
		FIELD_TYPES.push('Header'             );
		FIELD_TYPES.push('ZipCodePopup'       );
		// 03/02/2020 Paul.  Use slice so that we are modifying a copy. 
		let MODULE_TYPES    : string[] = L10n.GetList('ModuleTypes'         );
		let LIST_NAMES      : string[] = L10n.GetList('TerminologyPickLists');
		let FIELD_VALIDATORS: string[] = L10n.GetList('FieldValidators'     );
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
		// 12/17/2020 Paul.  Field validator is optional. 
		if ( FIELD_VALIDATORS != null )
		{
			FIELD_VALIDATORS = FIELD_VALIDATORS.slice();
			FIELD_VALIDATORS.unshift('');
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

		let DATA_LABEL_FREE_FORM      : boolean = false;
		let DATA_FIELD_FREE_FORM      : boolean = false;
		let FIELD_INDEX               : number  = null;
		let FIELD_TYPE                : string  = null;
		let DATA_LABEL                : string  = null;
		let DATA_FIELD                : string  = null;
		let DATA_FORMAT               : string  = null;
		let DISPLAY_FIELD             : string  = null;
		let CACHE_NAME                : string  = null;
		let DATA_REQUIRED             : boolean = false;
		let UI_REQUIRED               : boolean = false;
		let ONCLICK_SCRIPT            : string  = null;
		let FORMAT_SCRIPT             : string  = null;
		let FORMAT_TAB_INDEX          : number  = null;
		let FORMAT_MAX_LENGTH         : number  = null;
		let FORMAT_SIZE               : number  = null;
		let FORMAT_ROWS               : number  = null;
		let FORMAT_COLUMNS            : number  = null;
		let COLSPAN                   : string  = null;
		let ROWSPAN                   : number  = null;
		let FIELD_VALIDATOR_ID        : string  = null;
		let FIELD_VALIDATOR_MESSAGE   : string  = null;
		let MODULE_TYPE               : string  = null;
		let TOOL_TIP                  : string  = null;
		let RELATED_SOURCE_MODULE_NAME: string  = null;
		let RELATED_SOURCE_VIEW_NAME  : string  = null;
		let RELATED_SOURCE_ID_FIELD   : string  = null;
		let RELATED_SOURCE_NAME_FIELD : string  = null; 
		let RELATED_VIEW_NAME         : string  = null;
		let RELATED_ID_FIELD          : string  = null;
		let RELATED_NAME_FIELD        : string  = null;
		let RELATED_JOIN_FIELD        : string  = null;
		let PARENT_FIELD              : string  = null;

		if ( layoutField != null )
		{
			FIELD_INDEX                = layoutField.FIELD_INDEX               ;
			FIELD_TYPE                 = layoutField.FIELD_TYPE                ;
			DATA_LABEL                 = layoutField.DATA_LABEL                ;
			DATA_FIELD                 = layoutField.DATA_FIELD                ;
			DATA_FORMAT                = layoutField.DATA_FORMAT               ;
			DISPLAY_FIELD              = layoutField.DISPLAY_FIELD             ;
			CACHE_NAME                 = layoutField.CACHE_NAME                ;
			DATA_REQUIRED              = layoutField.DATA_REQUIRED             ;
			UI_REQUIRED                = layoutField.UI_REQUIRED               ;
			ONCLICK_SCRIPT             = layoutField.ONCLICK_SCRIPT            ;
			FORMAT_SCRIPT              = layoutField.FORMAT_SCRIPT             ;
			FORMAT_TAB_INDEX           = layoutField.FORMAT_TAB_INDEX          ;
			FORMAT_MAX_LENGTH          = layoutField.FORMAT_MAX_LENGTH         ;
			FORMAT_SIZE                = layoutField.FORMAT_SIZE               ;
			FORMAT_ROWS                = layoutField.FORMAT_ROWS               ;
			FORMAT_COLUMNS             = layoutField.FORMAT_COLUMNS            ;
			COLSPAN                    = layoutField.COLSPAN                   ;
			ROWSPAN                    = layoutField.ROWSPAN                   ;
			FIELD_VALIDATOR_ID         = layoutField.FIELD_VALIDATOR_ID        ;
			FIELD_VALIDATOR_MESSAGE    = layoutField.FIELD_VALIDATOR_MESSAGE   ;
			MODULE_TYPE                = layoutField.MODULE_TYPE               ;
			TOOL_TIP                   = layoutField.TOOL_TIP                  ;
			RELATED_SOURCE_MODULE_NAME = layoutField.RELATED_SOURCE_MODULE_NAME;
			RELATED_SOURCE_VIEW_NAME   = layoutField.RELATED_SOURCE_VIEW_NAME  ;
			RELATED_SOURCE_ID_FIELD    = layoutField.RELATED_SOURCE_ID_FIELD   ;
			RELATED_SOURCE_NAME_FIELD  = layoutField.RELATED_SOURCE_NAME_FIELD ;
			RELATED_VIEW_NAME          = layoutField.RELATED_VIEW_NAME         ;
			RELATED_ID_FIELD           = layoutField.RELATED_ID_FIELD          ;
			RELATED_NAME_FIELD         = layoutField.RELATED_NAME_FIELD        ;
			RELATED_JOIN_FIELD         = layoutField.RELATED_JOIN_FIELD        ;
			PARENT_FIELD               = layoutField.PARENT_FIELD              ;
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
			FIELD_TYPES               ,
			MODULE_TYPES              ,
			LIST_NAMES                ,
			COLSPANS                  ,
			FIELD_VALIDATORS          ,
			DATA_LABEL_FREE_FORM      ,
			DATA_FIELD_FREE_FORM      ,
			FIELD_INDEX               ,
			FIELD_TYPE                ,
			DATA_LABEL                ,
			DATA_FIELD                ,
			DATA_FORMAT               ,
			DISPLAY_FIELD             ,
			CACHE_NAME                ,
			DATA_REQUIRED             ,
			UI_REQUIRED               ,
			ONCLICK_SCRIPT            ,
			FORMAT_SCRIPT             ,
			FORMAT_TAB_INDEX          ,
			FORMAT_MAX_LENGTH         ,
			FORMAT_SIZE               ,
			FORMAT_ROWS               ,
			FORMAT_COLUMNS            ,
			COLSPAN                   ,
			ROWSPAN                   ,
			FIELD_VALIDATOR_ID        ,
			FIELD_VALIDATOR_MESSAGE   ,
			MODULE_TYPE               ,
			TOOL_TIP                  ,
			RELATED_SOURCE_MODULE_NAME,
			RELATED_SOURCE_VIEW_NAME  ,
			RELATED_SOURCE_ID_FIELD   ,
			RELATED_SOURCE_NAME_FIELD ,
			RELATED_VIEW_NAME         ,
			RELATED_ID_FIELD          ,
			RELATED_NAME_FIELD        ,
			RELATED_JOIN_FIELD        ,
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

 	async componentDidUpdate(prevProps: IEditPropertiesEditorProps)
	{
		const { layoutField, moduleFields } = this.props;
		if ( this.props.layoutField != prevProps.layoutField )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props);
			let DATA_LABEL_FREE_FORM      : boolean = false;
			let DATA_FIELD_FREE_FORM      : boolean = false;
			let FIELD_INDEX               : number  = null;
			let FIELD_TYPE                : string  = null;
			let DATA_LABEL                : string  = null;
			let DATA_FIELD                : string  = null;
			let DATA_FORMAT               : string  = null;
			let DISPLAY_FIELD             : string  = null;
			let CACHE_NAME                : string  = null;
			let DATA_REQUIRED             : boolean = false;
			let UI_REQUIRED               : boolean = false;
			let ONCLICK_SCRIPT            : string  = null;
			let FORMAT_SCRIPT             : string  = null;
			let FORMAT_TAB_INDEX          : number  = null;
			let FORMAT_MAX_LENGTH         : number  = null;
			let FORMAT_SIZE               : number  = null;
			let FORMAT_ROWS               : number  = null;
			let FORMAT_COLUMNS            : number  = null;
			let COLSPAN                   : string  = null;
			let ROWSPAN                   : number  = null;
			let FIELD_VALIDATOR_ID        : string  = null;
			let FIELD_VALIDATOR_MESSAGE   : string  = null;
			let MODULE_TYPE               : string  = null;
			let TOOL_TIP                  : string  = null;
			let RELATED_SOURCE_MODULE_NAME: string  = null;
			let RELATED_SOURCE_VIEW_NAME  : string  = null;
			let RELATED_SOURCE_ID_FIELD   : string  = null;
			let RELATED_SOURCE_NAME_FIELD : string  = null; 
			let RELATED_VIEW_NAME         : string  = null;
			let RELATED_ID_FIELD          : string  = null;
			let RELATED_NAME_FIELD        : string  = null;
			let RELATED_JOIN_FIELD        : string  = null;
			let PARENT_FIELD              : string  = null;
			if ( layoutField != null )
			{
				FIELD_INDEX                = layoutField.FIELD_INDEX               ;
				FIELD_TYPE                 = layoutField.FIELD_TYPE                ;
				DATA_LABEL                 = layoutField.DATA_LABEL                ;
				DATA_FIELD                 = layoutField.DATA_FIELD                ;
				DATA_FORMAT                = layoutField.DATA_FORMAT               ;
				DISPLAY_FIELD              = layoutField.DISPLAY_FIELD             ;
				CACHE_NAME                 = layoutField.CACHE_NAME                ;
				DATA_REQUIRED              = layoutField.DATA_REQUIRED             ;
				UI_REQUIRED                = layoutField.UI_REQUIRED               ;
				ONCLICK_SCRIPT             = layoutField.ONCLICK_SCRIPT            ;
				FORMAT_SCRIPT              = layoutField.FORMAT_SCRIPT             ;
				FORMAT_TAB_INDEX           = layoutField.FORMAT_TAB_INDEX          ;
				FORMAT_MAX_LENGTH          = layoutField.FORMAT_MAX_LENGTH         ;
				FORMAT_SIZE                = layoutField.FORMAT_SIZE               ;
				FORMAT_ROWS                = layoutField.FORMAT_ROWS               ;
				FORMAT_COLUMNS             = layoutField.FORMAT_COLUMNS            ;
				COLSPAN                    = layoutField.COLSPAN                   ;
				ROWSPAN                    = layoutField.ROWSPAN                   ;
				FIELD_VALIDATOR_ID         = layoutField.FIELD_VALIDATOR_ID        ;
				FIELD_VALIDATOR_MESSAGE    = layoutField.FIELD_VALIDATOR_MESSAGE   ;
				MODULE_TYPE                = layoutField.MODULE_TYPE               ;
				TOOL_TIP                   = layoutField.TOOL_TIP                  ;
				RELATED_SOURCE_MODULE_NAME = layoutField.RELATED_SOURCE_MODULE_NAME;
				RELATED_SOURCE_VIEW_NAME   = layoutField.RELATED_SOURCE_VIEW_NAME  ;
				RELATED_SOURCE_ID_FIELD    = layoutField.RELATED_SOURCE_ID_FIELD   ;
				RELATED_SOURCE_NAME_FIELD  = layoutField.RELATED_SOURCE_NAME_FIELD ;
				RELATED_VIEW_NAME          = layoutField.RELATED_VIEW_NAME         ;
				RELATED_ID_FIELD           = layoutField.RELATED_ID_FIELD          ;
				RELATED_NAME_FIELD         = layoutField.RELATED_NAME_FIELD        ;
				RELATED_JOIN_FIELD         = layoutField.RELATED_JOIN_FIELD        ;
				PARENT_FIELD               = layoutField.PARENT_FIELD              ;
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
				DATA_LABEL_FREE_FORM      ,
				DATA_FIELD_FREE_FORM      ,
				FIELD_INDEX               ,
				FIELD_TYPE                ,
				DATA_LABEL                ,
				DATA_FIELD                ,
				DATA_FORMAT               ,
				DISPLAY_FIELD             ,
				CACHE_NAME                ,
				DATA_REQUIRED             ,
				UI_REQUIRED               ,
				ONCLICK_SCRIPT            ,
				FORMAT_SCRIPT             ,
				FORMAT_TAB_INDEX          ,
				FORMAT_MAX_LENGTH         ,
				FORMAT_SIZE               ,
				FORMAT_ROWS               ,
				FORMAT_COLUMNS            ,
				COLSPAN                   ,
				ROWSPAN                   ,
				FIELD_VALIDATOR_ID        ,
				FIELD_VALIDATOR_MESSAGE   ,
				MODULE_TYPE               ,
				TOOL_TIP                  ,
				RELATED_SOURCE_MODULE_NAME,
				RELATED_SOURCE_VIEW_NAME  ,
				RELATED_SOURCE_ID_FIELD   ,
				RELATED_SOURCE_NAME_FIELD ,
				RELATED_VIEW_NAME         ,
				RELATED_ID_FIELD          ,
				RELATED_NAME_FIELD        ,
				RELATED_JOIN_FIELD        ,
				PARENT_FIELD              ,
			});
		}
	}

	private _onSave = async (e) =>
	{
		const { FIELD_TYPE, DATA_LABEL, DATA_FIELD, DATA_FORMAT, DISPLAY_FIELD, CACHE_NAME, DATA_REQUIRED, UI_REQUIRED, ONCLICK_SCRIPT, FORMAT_SCRIPT, FORMAT_TAB_INDEX, FORMAT_MAX_LENGTH, FORMAT_SIZE, FORMAT_ROWS, FORMAT_COLUMNS, COLSPAN, ROWSPAN, FIELD_VALIDATOR_ID, FIELD_VALIDATOR_MESSAGE, MODULE_TYPE, TOOL_TIP, RELATED_SOURCE_MODULE_NAME, RELATED_SOURCE_VIEW_NAME, RELATED_SOURCE_ID_FIELD, RELATED_SOURCE_NAME_FIELD, RELATED_VIEW_NAME, RELATED_ID_FIELD, RELATED_NAME_FIELD, RELATED_JOIN_FIELD, PARENT_FIELD } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let layoutField: any = {};
				layoutField.FIELD_TYPE                 = FIELD_TYPE  ;
				layoutField.DATA_LABEL                 = (this.IsFieldVisible('DATA_LABEL'                ) ? DATA_LABEL                : null);
				layoutField.DATA_FIELD                 = (this.IsFieldVisible('DATA_FIELD'                ) ? DATA_FIELD                : null);
				layoutField.DATA_FORMAT                = (this.IsFieldVisible('DATA_FORMAT'               ) ? DATA_FORMAT               : null);
				layoutField.DISPLAY_FIELD              = (this.IsFieldVisible('DISPLAY_FIELD'             ) ? DISPLAY_FIELD             : null);
				layoutField.CACHE_NAME                 = (this.IsFieldVisible('CACHE_NAME'                ) ? CACHE_NAME                : null);
				layoutField.DATA_REQUIRED              = (this.IsFieldVisible('DATA_REQUIRED'             ) ? DATA_REQUIRED             : null);
				layoutField.UI_REQUIRED                = (this.IsFieldVisible('UI_REQUIRED'               ) ? UI_REQUIRED               : null);
				layoutField.ONCLICK_SCRIPT             = (this.IsFieldVisible('ONCLICK_SCRIPT'            ) ? ONCLICK_SCRIPT            : null);
				layoutField.FORMAT_SCRIPT              = (this.IsFieldVisible('FORMAT_SCRIPT'             ) ? FORMAT_SCRIPT             : null);
				layoutField.FORMAT_TAB_INDEX           = (this.IsFieldVisible('FORMAT_TAB_INDEX'          ) ? FORMAT_TAB_INDEX          : null);
				layoutField.FORMAT_MAX_LENGTH          = (this.IsFieldVisible('FORMAT_MAX_LENGTH'         ) ? FORMAT_MAX_LENGTH         : null);
				layoutField.FORMAT_SIZE                = (this.IsFieldVisible('FORMAT_SIZE'               ) ? FORMAT_SIZE               : null);
				layoutField.FORMAT_ROWS                = (this.IsFieldVisible('FORMAT_ROWS'               ) ? FORMAT_ROWS               : null);
				layoutField.FORMAT_COLUMNS             = (this.IsFieldVisible('FORMAT_COLUMNS'            ) ? FORMAT_COLUMNS            : null);
				layoutField.COLSPAN                    = (this.IsFieldVisible('COLSPAN'                   ) ? Sql.ToInteger(COLSPAN)    : null);
				layoutField.ROWSPAN                    = (this.IsFieldVisible('ROWSPAN'                   ) ? ROWSPAN                   : null);
				layoutField.FIELD_VALIDATOR_ID         = (this.IsFieldVisible('FIELD_VALIDATOR_ID'        ) ? FIELD_VALIDATOR_ID        : null);
				layoutField.FIELD_VALIDATOR_MESSAGE    = (this.IsFieldVisible('FIELD_VALIDATOR_MESSAGE'   ) ? FIELD_VALIDATOR_MESSAGE   : null);
				layoutField.MODULE_TYPE                = (this.IsFieldVisible('MODULE_TYPE'               ) ? MODULE_TYPE               : null);
				layoutField.TOOL_TIP                   = (this.IsFieldVisible('TOOL_TIP'                  ) ? TOOL_TIP                  : null);
				layoutField.RELATED_SOURCE_MODULE_NAME = (this.IsFieldVisible('RELATED_SOURCE_MODULE_NAME') ? RELATED_SOURCE_MODULE_NAME: null);
				layoutField.RELATED_SOURCE_VIEW_NAME   = (this.IsFieldVisible('RELATED_SOURCE_VIEW_NAME'  ) ? RELATED_SOURCE_VIEW_NAME  : null);
				layoutField.RELATED_SOURCE_ID_FIELD    = (this.IsFieldVisible('RELATED_SOURCE_ID_FIELD'   ) ? RELATED_SOURCE_ID_FIELD   : null);
				layoutField.RELATED_SOURCE_NAME_FIELD  = (this.IsFieldVisible('RELATED_SOURCE_NAME_FIELD' ) ? RELATED_SOURCE_NAME_FIELD : null);
				layoutField.RELATED_VIEW_NAME          = (this.IsFieldVisible('RELATED_VIEW_NAME'         ) ? RELATED_VIEW_NAME         : null);
				layoutField.RELATED_ID_FIELD           = (this.IsFieldVisible('RELATED_ID_FIELD'          ) ? RELATED_ID_FIELD          : null);
				layoutField.RELATED_NAME_FIELD         = (this.IsFieldVisible('RELATED_NAME_FIELD'        ) ? RELATED_NAME_FIELD        : null);
				layoutField.RELATED_JOIN_FIELD         = (this.IsFieldVisible('RELATED_JOIN_FIELD'        ) ? RELATED_JOIN_FIELD        : null);
				layoutField.PARENT_FIELD               = (this.IsFieldVisible('PARENT_FIELD'              ) ? PARENT_FIELD              : null);
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
		// 04/14/2022 Paul.  Correct name is FIELD_VALIDATOR_ID. 
		else if ( name == 'FIELD_VALIDATOR_ID' )
		{
			let sDISPLAY_NAME: string = L10n.ListTerm('FieldValidators', value);
			let FIELD_VALIDATOR_MESSAGE: string = null;
			switch ( sDISPLAY_NAME )
			{
				case ''                            :  FIELD_VALIDATOR_MESSAGE = null                                  ;  break;
				case 'Phone Number'                :  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_PHONE_NUMBER'           ;  break;
				case 'Email Address'               :  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_EMAIL_ADDRESS'          ;  break;
				case 'Positive Decimal'            :  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_POSITIVE_DECIMAL'       ;  break;
				case 'URL'                         :  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_URL'                    ;  break;
				// 07/06/2017 Paul.  Add missing validator messages. 
				case 'Integer'                     :  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_INTEGER'                ;  break;
				case 'Positive Decimal with Commas':  FIELD_VALIDATOR_MESSAGE = '.ERR_INVALID_POSITIVE_DECIMAL_COMMAS';  break;
				case 'Twitter Message'             :  FIELD_VALIDATOR_MESSAGE = '.ERR_TWITTER_MESSAGE'                ;  break;
				case 'Twitter Track'               :  FIELD_VALIDATOR_MESSAGE = '.ERR_TWITTER_TRACK'                  ;  break;
			}
			this.setState({ FIELD_VALIDATOR_MESSAGE });
		}
	}

	private _onFIELD_TYPE_Change = (value: any) =>
	{
		if ( value == 'TeamSelect' )
		{
			this.setState({ FIELD_TYPE: value, DATA_LABEL: '.LBL_TEAM_SET_NAME', DATA_FIELD: 'TEAM_SET_NAME', MODULE_TYPE: null });
		}
		else if ( value == 'UserSelect' )
		{
			this.setState({ FIELD_TYPE: value, DATA_LABEL: '.LBL_ASSIGNED_SET_NAME', DATA_FIELD: 'ASSIGNED_SET_NAME', MODULE_TYPE: null });
		}
		else if ( value == 'TagSelect' )
		{
			this.setState({ FIELD_TYPE: value, DATA_LABEL: '.LBL_TAG_SET_NAME', DATA_FIELD: 'TAG_SET_NAME' });
		}
		else if ( value == 'NAICSCodeSelect' )
		{
			this.setState({ FIELD_TYPE: value, DATA_LABEL: 'NAICSCodes.LBL_NAICS_SET_NAME', DATA_FIELD: 'NAICS_SET_NAME' });
		}
		else
		{
			this.setState({ FIELD_TYPE: value });
		}
	}

	private IsFieldVisible = (sFieldName) =>
	{
		const { FIELD_TYPE } = this.state;
		let bShowField: boolean = true;
		switch ( FIELD_TYPE )
		{
			case 'TextBox'            :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = true ;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
			case 'HtmlEditor'         :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 10/07/2010 Paul.  Allow a format for a label.  Also show module type. 
			case 'Label'              :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = true ;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
			case 'ListBox'            :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = true ;  break;
				}
				break;
			}
			// 06/16/2010 Paul.  Radio is just like a ListBox, except for the UI. 
			case 'Radio'              :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 06/16/2010 Paul.  CheckBoxList is just like a ListBox, except for the UI. 
			// 01/06/2018 Paul.  DATA_FORMAT is visible for CheckBoxList. 
			case 'CheckBoxList'       :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 09/20/2010 Paul.  Related are just like CheckBoxList. 
			case 'RelatedListBox'     :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = true ;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = true ;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = true ;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = true ;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = true ;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = true ;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = true ;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'RelatedCheckBoxList':
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = true ;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = true ;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = true ;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = true ;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = true ;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = true ;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = true ;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'RelatedSelect'      :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = true ;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = true ;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = true ;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = true ;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = true ;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = true ;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = true ;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = true ;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'CheckBox'           :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'ChangeButton'       :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = true ;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					// 11/18/2021 Paul.  Old layouts do not specify MODULE_TYPE.  React layouts will use MODULE_TYPE. 
					case 'MODULE_TYPE'               :  bShowField = true ;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 05/17/2009 Paul.  Add support for a generic module popup. 
			// 08/04/2010 Paul.  DATA_FORMAT is used to store AutoComplete and UseContextKey flags. 
			case 'ModulePopup'        :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = true ;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = true ;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = true ;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 09/02/2009 Paul.  Add support for ModuleAutoComplete. 
			case 'ModuleAutoComplete' :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = true ;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 08/26/2009 Paul.  Add support for dynamic teams. 
			case 'TeamSelect'         :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			case 'UserSelect'         :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 05/12/2016 Paul.  Add Tags module. 
			case 'TagSelect'          :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 06/07/2017 Paul.  Add NAICSCodes module. 
			case 'NAICSCodeSelect'    :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'DatePicker'         :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'DateRange'          :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'DateTimeEdit'       :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 06/20/2009 Paul.  Add DateTimeNewRecord so that the NewRecord forms can use the Dynamic rendering. 
			case 'DateTimeNewRecord'  :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'DateTimePicker'     :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'Image'              :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 07/02/2020 Paul.  Add support for Picture type. 
			case 'Picture'              :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'File'               :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'Password'           :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'AddressButtons'     :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'Blank'              :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = false;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 02/28/2008 Paul.  Hidden field only shows general fields. 
			case 'Hidden'             :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = false;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = false;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 09/02/2012 Paul.  A separator is just like a blank. 
			// 09/16/2012 Paul.  The data field can be used as the table id. 
			// 09/20/2012 Paul.  Data Format will store initial visibility state. 
			case 'Separator'          :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = false;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = false;  break;
					case 'ROWSPAN'                   :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = false;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			case 'Header'             :
			{
				// 04/14/2022 Paul.  Header does not need Tab Index or Tool Tip. 
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = false;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = false;  break;
					case 'UI_REQUIRED'               :  bShowField = false;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = false;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = false;  break;
					case 'FORMAT_SIZE'               :  bShowField = false;  break;
					case 'FORMAT_ROWS'               :  bShowField = false;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = false;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = false;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = false;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = false;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
				}
				break;
			}
			// 04/13/2016 Paul.  Add ZipCode lookup. 
			case 'ZipCodePopup'       :
			{
				switch ( sFieldName )
				{
					case 'DATA_LABEL'                :  bShowField = true ;  break;
					case 'DATA_FIELD'                :  bShowField = true ;  break;
					case 'DATA_FORMAT'               :  bShowField = true ;  break;
					case 'DISPLAY_FIELD'             :  bShowField = false;  break;
					case 'CACHE_NAME'                :  bShowField = false;  break;
					case 'DATA_REQUIRED'             :  bShowField = true ;  break;
					case 'UI_REQUIRED'               :  bShowField = true ;  break;
					case 'ONCLICK_SCRIPT'            :  bShowField = false;  break;
					case 'FORMAT_SCRIPT'             :  bShowField = false;  break;
					case 'FORMAT_TAB_INDEX'          :  bShowField = true ;  break;
					case 'FORMAT_MAX_LENGTH'         :  bShowField = true ;  break;
					case 'FORMAT_SIZE'               :  bShowField = true ;  break;
					case 'FORMAT_ROWS'               :  bShowField = true ;  break;
					case 'FORMAT_COLUMNS'            :  bShowField = true ;  break;
					case 'COLSPAN'                   :  bShowField = true ;  break;
					case 'ROWSPAN'                   :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_ID'        :  bShowField = true ;  break;
					case 'FIELD_VALIDATOR_MESSAGE'   :  bShowField = true ;  break;
					case 'MODULE_TYPE'               :  bShowField = false;  break;
					case 'TOOL_TIP'                  :  bShowField = true ;  break;
					case 'RELATED_SOURCE_MODULE_NAME':  bShowField = false;  break;
					case 'RELATED_SOURCE_VIEW_NAME'  :  bShowField = false;  break;
					case 'RELATED_SOURCE_ID_FIELD'   :  bShowField = false;  break;
					case 'RELATED_SOURCE_NAME_FIELD' :  bShowField = false;  break;
					case 'RELATED_VIEW_NAME'         :  bShowField = false;  break;
					case 'RELATED_ID_FIELD'          :  bShowField = false;  break;
					case 'RELATED_NAME_FIELD'        :  bShowField = false;  break;
					case 'RELATED_JOIN_FIELD'        :  bShowField = false;  break;
					case 'PARENT_FIELD'              :  bShowField = false;  break;
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
		// 04/14/2022 Paul.  Correct names are CACHE_NAME and FIELD_VALIDATOR_ID. 
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
								let sDISPLAY_NAME: string = (sFieldName == 'FIELD_VALIDATOR_ID' ? L10n.ListTerm('FieldValidators', item) : item);
								return (<option key={ 'ctlNewRecord_' + sFieldName + '_' + index.toString() } id={ 'ctlNewRecord_' + sFieldName + '_' + + index.toString() } value={ item }>{ sDISPLAY_NAME }</option>);
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
		const { layoutField, moduleFields, MODULE_TERMINOLOGY } = this.props;
		const { FIELD_TYPES, MODULE_TYPES, LIST_NAMES, COLSPANS, FIELD_VALIDATORS, DATA_LABEL_FREE_FORM, DATA_FIELD_FREE_FORM } = this.state;
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
								onChange={ (e) => this._onFIELD_TYPE_Change(e.target.value) }
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
					{ this.AddTextBoxProperty ('DATA_FORMAT'               ) }
					{ this.AddCheckBoxProperty('DATA_REQUIRED'             ) }
					{ this.AddCheckBoxProperty('UI_REQUIRED'               ) }
					{ this.AddTextBoxProperty ('DISPLAY_FIELD'             ) }
					{ this.AddTextAreaProperty('ONCLICK_SCRIPT'            ) }
					{ this.AddListBoxProperty ('MODULE_TYPE'               , MODULE_TYPES    ) }
					{ this.AddTextAreaProperty('FORMAT_SCRIPT'             ) }
					{ this.AddTextBoxProperty ('FORMAT_MAX_LENGTH'         ) }
					{ this.AddTextBoxProperty ('FORMAT_SIZE'               ) }
					{ this.AddTextBoxProperty ('FORMAT_COLUMNS'            ) }
					{ this.AddTextBoxProperty ('FORMAT_ROWS'               ) }
					{ this.AddListBoxProperty ('CACHE_NAME'                , LIST_NAMES      ) }
					{ this.AddTextBoxProperty ('FORMAT_TAB_INDEX'          ) }
					{ this.AddListBoxProperty ('COLSPAN'                   , COLSPANS        ) }
					{ this.AddTextBoxProperty ('ROWSPAN'                   ) }
					{ this.AddTextBoxProperty ('TOOL_TIP'                  ) }
					{ this.AddListBoxProperty ('FIELD_VALIDATOR_ID'        , FIELD_VALIDATORS) }
					{ this.AddTextBoxProperty ('FIELD_VALIDATOR_MESSAGE'   ) }
					{ this.AddTextBoxProperty ('RELATED_SOURCE_MODULE_NAME') }
					{ this.AddTextBoxProperty ('RELATED_SOURCE_VIEW_NAME'  ) }
					{ this.AddTextBoxProperty ('RELATED_SOURCE_ID_FIELD'   ) }
					{ this.AddTextBoxProperty ('RELATED_SOURCE_NAME_FIELD' ) }
					{ this.AddTextBoxProperty ('RELATED_VIEW_NAME'         ) }
					{ this.AddTextBoxProperty ('RELATED_ID_FIELD'          ) }
					{ this.AddTextBoxProperty ('RELATED_NAME_FIELD'        ) }
					{ this.AddTextBoxProperty ('RELATED_JOIN_FIELD'        ) }
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


