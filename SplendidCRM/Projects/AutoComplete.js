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

function PROJECT_PROJECT_NAME_Changed(fldPROJECT_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	var userContext = fldPROJECT_NAME.id.substring(0, fldPROJECT_NAME.id.length - 'PROJECT_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'PROJECT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_PROJECT_NAME = document.getElementById(userContext + 'PREV_PROJECT_NAME');
	if ( fldPREV_PROJECT_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_PROJECT_NAME');
	}
	else if ( fldPREV_PROJECT_NAME.value != fldPROJECT_NAME.value )
	{
		if ( fldPROJECT_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Project.AutoComplete.PROJECT_PROJECT_NAME_Get(fldPROJECT_NAME.value, PROJECT_PROJECT_NAME_Changed_OnSucceededWithContext, PROJECT_PROJECT_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('PROJECT_PROJECT_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			PROJECT_PROJECT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function PROJECT_PROJECT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors        = document.getElementById(userContext + 'PROJECT_NAME_AjaxErrors');
		var fldPROJECT_ID        = document.getElementById(userContext + 'PROJECT_ID'       );
		var fldPROJECT_NAME      = document.getElementById(userContext + 'PROJECT_NAME'     );
		var fldPREV_PROJECT_NAME = document.getElementById(userContext + 'PREV_PROJECT_NAME');
		if ( fldPROJECT_ID        != null ) fldPROJECT_ID.value        = sID  ;
		if ( fldPROJECT_NAME      != null ) fldPROJECT_NAME.value      = sNAME;
		if ( fldPREV_PROJECT_NAME != null ) fldPREV_PROJECT_NAME.value = sNAME;
	}
	else
	{
		alert('result from Project.AutoComplete service is null');
	}
}

function PROJECT_PROJECT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'PROJECT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldPROJECT_ID        = document.getElementById(userContext + 'PROJECT_ID'       );
	var fldPROJECT_NAME      = document.getElementById(userContext + 'PROJECT_NAME'     );
	var fldPREV_PROJECT_NAME = document.getElementById(userContext + 'PREV_PROJECT_NAME');
	if ( fldPROJECT_ID        != null ) fldPROJECT_ID.value        = '';
	if ( fldPROJECT_NAME      != null ) fldPROJECT_NAME.value      = '';
	if ( fldPREV_PROJECT_NAME != null ) fldPREV_PROJECT_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


