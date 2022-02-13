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

function CASES_CASE_NAME_Changed(fldCASE_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	var userContext = fldCASE_NAME.id.substring(0, fldCASE_NAME.id.length - 'CASE_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'CASE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_CASE_NAME = document.getElementById(userContext + 'PREV_CASE_NAME');
	if ( fldPREV_CASE_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_CASE_NAME');
	}
	else if ( fldPREV_CASE_NAME.value != fldCASE_NAME.value )
	{
		if ( fldCASE_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Cases.AutoComplete.CASES_CASE_NAME_Get(fldCASE_NAME.value, CASES_CASE_NAME_Changed_OnSucceededWithContext, CASES_CASE_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('CASES_CASE_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			CASES_CASE_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function CASES_CASE_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors     = document.getElementById(userContext + 'CASE_NAME_AjaxErrors');
		var fldCASE_ID        = document.getElementById(userContext + 'CASE_ID'       );
		var fldCASE_NAME      = document.getElementById(userContext + 'CASE_NAME'     );
		var fldPREV_CASE_NAME = document.getElementById(userContext + 'PREV_CASE_NAME');
		if ( fldCASE_ID        != null ) fldCASE_ID.value        = sID  ;
		if ( fldCASE_NAME      != null ) fldCASE_NAME.value      = sNAME;
		if ( fldPREV_CASE_NAME != null ) fldPREV_CASE_NAME.value = sNAME;
	}
	else
	{
		alert('result from Cases.AutoComplete service is null');
	}
}

function CASES_CASE_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'CASE_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCASE_ID        = document.getElementById(userContext + 'CASE_ID'       );
	var fldCASE_NAME      = document.getElementById(userContext + 'CASE_NAME'     );
	var fldPREV_CASE_NAME = document.getElementById(userContext + 'PREV_CASE_NAME');
	if ( fldCASE_ID        != null ) fldCASE_ID.value        = '';
	if ( fldCASE_NAME      != null ) fldCASE_NAME.value      = '';
	if ( fldPREV_CASE_NAME != null ) fldPREV_CASE_NAME.value = '';
}

function CASES_CASE_NUMBER_Changed(fldCASE_NUMBER)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	var userContext = fldCASE_NUMBER.id.substring(0, fldCASE_NUMBER.id.length - 'CASE_NUMBER'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'CASE_NUMBER_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_CASE_NUMBER = document.getElementById(userContext + 'PREV_CASE_NUMBER');
	if ( fldPREV_CASE_NUMBER == null )
	{
		//alert('Could not find ' + userContext + 'PREV_CASE_NUMBER');
	}
	else if ( fldPREV_CASE_NUMBER.value != fldCASE_NUMBER.value )
	{
		if ( fldCASE_NUMBER.value.length > 0 )
		{
			try
			{
				SplendidCRM.Cases.AutoComplete.CASES_CASE_NUMBER_Get(fldCASE_NUMBER.value, CASES_CASE_NUMBER_Changed_OnSucceededWithContext, CASES_CASE_NUMBER_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('CASES_CASE_NUMBER_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			CASES_CASE_NUMBER_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function CASES_CASE_NUMBER_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors       = document.getElementById(userContext + 'CASE_NUMBER_AjaxErrors');
		var fldCASE_ID          = document.getElementById(userContext + 'CASE_ID'       );
		var fldCASE_NUMBER      = document.getElementById(userContext + 'CASE_NUMBER'     );
		var fldPREV_CASE_NUMBER = document.getElementById(userContext + 'PREV_CASE_NUMBER');
		if ( fldCASE_ID          != null ) fldCASE_ID.value          = sID  ;
		if ( fldCASE_NUMBER      != null ) fldCASE_NUMBER.value      = sNAME;
		if ( fldPREV_CASE_NUMBER != null ) fldPREV_CASE_NUMBER.value = sNAME;
	}
	else
	{
		alert('result from Cases.AutoComplete service is null');
	}
}

function CASES_CASE_NUMBER_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'CASE_NUMBER_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCASE_ID        = document.getElementById(userContext + 'CASE_ID'       );
	var fldCASE_NUMBER      = document.getElementById(userContext + 'CASE_NUMBER'     );
	var fldPREV_CASE_NUMBER = document.getElementById(userContext + 'PREV_CASE_NUMBER');
	if ( fldCASE_ID        != null ) fldCASE_ID.value        = '';
	if ( fldCASE_NUMBER      != null ) fldCASE_NUMBER.value      = '';
	if ( fldPREV_CASE_NUMBER != null ) fldPREV_CASE_NUMBER.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


