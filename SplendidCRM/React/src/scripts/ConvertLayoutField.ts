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
// 2. Store and Types. 
import EDITVIEWS_FIELD             from '../types/EDITVIEWS_FIELD'            ;
import DETAILVIEWS_FIELD           from '../types/DETAILVIEWS_FIELD'          ;
// 3. Scripts. 
import Sql                         from '../scripts/Sql'                       ;
// 4. Components and Views. 

export function ConvertEditViewFieldToDetailViewField(MODULE_NAME: string, edit: EDITVIEWS_FIELD)
{
	let detail: DETAILVIEWS_FIELD = 
	{ ID           : edit.ID          
	, DELETED      : edit.DELETED     
	, DETAIL_NAME  : edit.EDIT_NAME   
	, FIELD_INDEX  : edit.FIELD_INDEX 
	, FIELD_TYPE   : edit.FIELD_TYPE  
	, DEFAULT_VIEW : edit.DEFAULT_VIEW
	, DATA_LABEL   : edit.DATA_LABEL  
	, DATA_FIELD   : edit.DATA_FIELD  
	, DATA_FORMAT  : edit.DATA_FORMAT 
	, URL_FIELD    : null // edit.URL_FIELD   
	, URL_FORMAT   : null // edit.URL_FORMAT  
	, URL_TARGET   : null // edit.URL_TARGET  
	, LIST_NAME    : edit.LIST_NAME   
	, COLSPAN      : edit.COLSPAN     
	, LABEL_WIDTH  : edit.LABEL_WIDTH 
	, FIELD_WIDTH  : edit.FIELD_WIDTH 
	, DATA_COLUMNS : edit.DATA_COLUMNS
	, VIEW_NAME    : edit.VIEW_NAME   
	, MODULE_NAME  : edit.MODULE_NAME 
	, TOOL_TIP     : edit.TOOL_TIP    
	, MODULE_TYPE  : edit.MODULE_TYPE 
	, PARENT_FIELD : edit.PARENT_FIELD
	, SCRIPT       : edit.SCRIPT      
	, hidden       : edit.hidden      
	}
	const { FIELD_TYPE } = detail;
	if ( FIELD_TYPE == 'Hidden' )
	{
	}
	else if ( FIELD_TYPE == 'ModuleAutoComplete' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
		detail.MODULE_TYPE = null;
	}
	else if ( FIELD_TYPE == 'ModulePopup' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
		// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
		if ( !Sql.IsEmptyString(edit.DISPLAY_FIELD) )
			detail.DATA_FIELD  = edit.DISPLAY_FIELD;
	}
	else if ( FIELD_TYPE == 'ChangeButton' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'TeamSelect' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
		detail.DATA_FIELD  = edit.DISPLAY_FIELD;
	}
	// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	else if ( FIELD_TYPE == 'UserSelect' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
		detail.DATA_FIELD  = edit.DISPLAY_FIELD;
	}
	// 05/14/2016 Paul.  Add Tags module. 
	else if ( FIELD_TYPE == 'TagSelect' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	// 06/07/2017 Paul.  Add NAICSCodes module. 
	else if ( FIELD_TYPE == 'NAICSCodeSelect' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'TextBox' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'HtmlEditor' )
	{
		detail.FIELD_TYPE  = 'TextBox';
		detail.DATA_FORMAT = '{0}';
	}
	// 04/14/2016 Paul.  Add ZipCode lookup. 
	else if ( FIELD_TYPE == 'ZipCodePopup' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'DatePicker' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0:d}';
	}
	else if ( FIELD_TYPE == 'DateTimeEdit' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'DateTimePicker' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'TimePicker' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'ListBox' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	// 08/01/2013 Paul.  Add support for CheckBoxList. 
	else if ( FIELD_TYPE == 'CheckBoxList' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	// 08/01/2013 Paul.  Add support for Radio. 
	else if ( FIELD_TYPE == 'Radio' )
	{
		detail.FIELD_TYPE  = 'ListBox';
		detail.DATA_FORMAT = '{0}';
	}
	else if ( FIELD_TYPE == 'CheckBox' )
	{
	}
	else if ( FIELD_TYPE == 'Label' )
	{
		detail.FIELD_TYPE  = 'String';
		detail.DATA_FORMAT = '{0}';
	}
	// 05/27/2016 Paul.  Add support for File type. 
	else if ( FIELD_TYPE == 'File' )
	{
	}
	// 11/04/2019 Paul.  Add support for Button type. 
	else if ( FIELD_TYPE == 'Button' )
	{
	}
	else
	{
		//08/31/2012 Paul.  Add debugging code. 
		console.warn((new Date()).toISOString() + ' ConvertEditViewFieldToDetailViewField: Unknown field type ' + FIELD_TYPE);
	}
	return detail;
}

