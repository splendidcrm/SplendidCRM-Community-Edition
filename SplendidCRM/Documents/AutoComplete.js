/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/

function DOCUMENTS_DOCUMENT_NAME_Changed(fldDOCUMENT_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain DOCUMENT_NAME in the text, so just get the length minus 4. 
	var userContext = fldDOCUMENT_NAME.id.substring(0, fldDOCUMENT_NAME.id.length - 'DOCUMENT_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'DOCUMENT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_DOCUMENT_NAME = document.getElementById(userContext + 'PREV_DOCUMENT_NAME');
	if ( fldPREV_DOCUMENT_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_DOCUMENT_NAME');
	}
	else if ( fldPREV_DOCUMENT_NAME.value != fldDOCUMENT_NAME.value )
	{
		if ( fldDOCUMENT_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Documents.AutoComplete.DOCUMENTS_DOCUMENT_NAME_Get(fldDOCUMENT_NAME.value, DOCUMENTS_DOCUMENT_NAME_Changed_OnSucceededWithContext, DOCUMENTS_DOCUMENT_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('DOCUMENTS_DOCUMENT_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'DOCUMENT_NAME' : '' };
			DOCUMENTS_DOCUMENT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function DOCUMENTS_DOCUMENT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sDOCUMENT_NAME = result.DOCUMENT_NAME;
		
		var fldAjaxErrors         = document.getElementById(userContext + 'DOCUMENT_NAME_AjaxErrors');
		var fldDOCUMENT_ID        = document.getElementById(userContext + 'DOCUMENT_ID'       );
		var fldDOCUMENT_NAME      = document.getElementById(userContext + 'DOCUMENT_NAME'     );
		var fldPREV_DOCUMENT_NAME = document.getElementById(userContext + 'PREV_DOCUMENT_NAME');
		if ( fldDOCUMENT_ID        != null ) fldDOCUMENT_ID.value        = sID           ;
		if ( fldDOCUMENT_NAME      != null ) fldDOCUMENT_NAME.value      = sDOCUMENT_NAME;
		if ( fldPREV_DOCUMENT_NAME != null ) fldPREV_DOCUMENT_NAME.value = sDOCUMENT_NAME;
	}
	else
	{
		alert('result from Documents.AutoComplete service is null');
	}
}

function DOCUMENTS_DOCUMENT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'DOCUMENT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldDOCUMENT_ID        = document.getElementById(userContext + 'DOCUMENT_ID'       );
	var fldDOCUMENT_NAME      = document.getElementById(userContext + 'DOCUMENT_NAME'     );
	var fldPREV_DOCUMENT_NAME = document.getElementById(userContext + 'PREV_DOCUMENT_NAME');
	if ( fldDOCUMENT_ID        != null ) fldDOCUMENT_ID.value        = '';
	if ( fldDOCUMENT_NAME      != null ) fldDOCUMENT_NAME.value      = '';
	if ( fldPREV_DOCUMENT_NAME != null ) fldPREV_DOCUMENT_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


