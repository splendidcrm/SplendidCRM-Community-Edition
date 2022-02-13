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

function EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed(fldEMAIL_TEMPLATE_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	var userContext = fldEMAIL_TEMPLATE_NAME.id.substring(0, fldEMAIL_TEMPLATE_NAME.id.length - 'EMAIL_TEMPLATE_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'EMAIL_TEMPLATE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_EMAIL_TEMPLATE_NAME = document.getElementById(userContext + 'PREV_EMAIL_TEMPLATE_NAME');
	if ( fldPREV_EMAIL_TEMPLATE_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_EMAIL_TEMPLATE_NAME');
	}
	else if ( fldPREV_EMAIL_TEMPLATE_NAME.value != fldEMAIL_TEMPLATE_NAME.value )
	{
		if ( fldEMAIL_TEMPLATE_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.EmailTemplates.AutoComplete.EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Get(fldEMAIL_TEMPLATE_NAME.value, EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed_OnSucceededWithContext, EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors               = document.getElementById(userContext + 'EMAIL_TEMPLATE_NAME_AjaxErrors');
		var fldEMAIL_TEMPLATE_ID        = document.getElementById(userContext + 'EMAIL_TEMPLATE_ID'       );
		var fldEMAIL_TEMPLATE_NAME      = document.getElementById(userContext + 'EMAIL_TEMPLATE_NAME'     );
		var fldPREV_EMAIL_TEMPLATE_NAME = document.getElementById(userContext + 'PREV_EMAIL_TEMPLATE_NAME');
		if ( fldEMAIL_TEMPLATE_ID        != null ) fldEMAIL_TEMPLATE_ID.value        = sID  ;
		if ( fldEMAIL_TEMPLATE_NAME      != null ) fldEMAIL_TEMPLATE_NAME.value      = sNAME;
		if ( fldPREV_EMAIL_TEMPLATE_NAME != null ) fldPREV_EMAIL_TEMPLATE_NAME.value = sNAME;
	}
	else
	{
		alert('result from EmailTemplates.AutoComplete service is null');
	}
}

function EMAIL_TEMPLATES_EMAIL_TEMPLATE_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'EMAIL_TEMPLATE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldEMAIL_TEMPLATE_ID        = document.getElementById(userContext + 'EMAIL_TEMPLATE_ID'       );
	var fldEMAIL_TEMPLATE_NAME      = document.getElementById(userContext + 'EMAIL_TEMPLATE_NAME'     );
	var fldPREV_EMAIL_TEMPLATE_NAME = document.getElementById(userContext + 'PREV_EMAIL_TEMPLATE_NAME');
	if ( fldEMAIL_TEMPLATE_ID        != null ) fldEMAIL_TEMPLATE_ID.value        = '';
	if ( fldEMAIL_TEMPLATE_NAME      != null ) fldEMAIL_TEMPLATE_NAME.value      = '';
	if ( fldPREV_EMAIL_TEMPLATE_NAME != null ) fldPREV_EMAIL_TEMPLATE_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


