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

function LEADS_LEAD_LAST_NAME_Changed(fldLEAD_LAST_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain LAST_NAME in the text, so just get the length minus 4. 
	var userContext = fldLEAD_LAST_NAME.id.substring(0, fldLEAD_LAST_NAME.id.length - 'LEAD_LAST_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'LEAD_LAST_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_LEAD_LAST_NAME = document.getElementById(userContext + 'PREV_LEAD_LAST_NAME');
	if ( fldPREV_LEAD_LAST_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_LEAD_LAST_NAME');
	}
	else if ( fldPREV_LEAD_LAST_NAME.value != fldLEAD_LAST_NAME.value )
	{
		if ( fldLEAD_LAST_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Leads.AutoComplete.LEADS_LEAD_LAST_NAME_Get(fldLEAD_LAST_NAME.value, LEADS_LEAD_LAST_NAME_Changed_OnSucceededWithContext, LEADS_LEAD_LAST_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('LEADS_LEAD_LAST_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			LEADS_LEAD_LAST_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function LEADS_LEAD_LAST_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sLAST_NAME = result.LAST_NAME;
		
		var fldAjaxErrors          = document.getElementById(userContext + 'LEAD_LAST_NAME_AjaxErrors');
		var fldLEAD_ID             = document.getElementById(userContext + 'LEAD_ID'            );
		var fldLEAD_LAST_NAME      = document.getElementById(userContext + 'LEAD_LAST_NAME'     );
		var fldPREV_LEAD_LAST_NAME = document.getElementById(userContext + 'PREV_LEAD_LAST_NAME');
		if ( fldLEAD_ID             != null ) fldLEAD_ID.value             = sID       ;
		if ( fldLEAD_LAST_NAME      != null ) fldLEAD_LAST_NAME.value      = sLAST_NAME;
		if ( fldPREV_LEAD_LAST_NAME != null ) fldPREV_LEAD_LAST_NAME.value = sLAST_NAME;
	}
	else
	{
		alert('result from Leads.AutoComplete service is null');
	}
}

function LEADS_LEAD_LAST_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'LEAD_LAST_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldLEAD_ID        = document.getElementById(userContext + 'LEAD_ID'       );
	var fldLEAD_LAST_NAME      = document.getElementById(userContext + 'LEAD_LAST_NAME'     );
	var fldPREV_LEAD_LAST_NAME = document.getElementById(userContext + 'PREV_LEAD_LAST_NAME');
	if ( fldLEAD_ID        != null ) fldLEAD_ID.value        = '';
	if ( fldLEAD_LAST_NAME      != null ) fldLEAD_LAST_NAME.value      = '';
	if ( fldPREV_LEAD_LAST_NAME != null ) fldPREV_LEAD_LAST_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


