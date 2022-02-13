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

function NOTES_NOTE_NAME_Changed(fldNOTE_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	var userContext = fldNOTE_NAME.id.substring(0, fldNOTE_NAME.id.length - 'NOTE_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'NOTE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_NOTE_NAME = document.getElementById(userContext + 'PREV_NOTE_NAME');
	if ( fldPREV_NOTE_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_NOTE_NAME');
	}
	else if ( fldPREV_NOTE_NAME.value != fldNOTE_NAME.value )
	{
		if ( fldNOTE_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Notes.AutoComplete.NOTES_NOTE_NAME_Get(fldNOTE_NAME.value, NOTES_NOTE_NAME_Changed_OnSucceededWithContext, NOTES_NOTE_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('NOTES_NOTE_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			NOTES_NOTE_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function NOTES_NOTE_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors     = document.getElementById(userContext + 'NOTE_NAME_AjaxErrors');
		var fldNOTE_ID        = document.getElementById(userContext + 'NOTE_ID'       );
		var fldNOTE_NAME      = document.getElementById(userContext + 'NOTE_NAME'     );
		var fldPREV_NOTE_NAME = document.getElementById(userContext + 'PREV_NOTE_NAME');
		if ( fldNOTE_ID        != null ) fldNOTE_ID.value        = sID  ;
		if ( fldNOTE_NAME      != null ) fldNOTE_NAME.value      = sNAME;
		if ( fldPREV_NOTE_NAME != null ) fldPREV_NOTE_NAME.value = sNAME;
	}
	else
	{
		alert('result from Notes.AutoComplete service is null');
	}
}

function NOTES_NOTE_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'NOTE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldNOTE_ID        = document.getElementById(userContext + 'NOTE_ID'       );
	var fldNOTE_NAME      = document.getElementById(userContext + 'NOTE_NAME'     );
	var fldPREV_NOTE_NAME = document.getElementById(userContext + 'PREV_NOTE_NAME');
	if ( fldNOTE_ID        != null ) fldNOTE_ID.value        = '';
	if ( fldNOTE_NAME      != null ) fldNOTE_NAME.value      = '';
	if ( fldPREV_NOTE_NAME != null ) fldPREV_NOTE_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


