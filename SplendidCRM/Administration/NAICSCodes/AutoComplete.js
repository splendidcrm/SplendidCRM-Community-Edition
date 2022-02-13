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

// 05/06/2010 Paul.  Move the scripts using in NAICSCodeselect here so that they will be outside of the UpdatePanel. 
// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
var sNAICSCodeselectNameUserContext = '';
var sNAICSCodeselectNameUserSuffix  = '';
function ChangeNAICSCodeselect(sPARENT_ID, sPARENT_NAME)
{
	var fldNAICS_CODE_NAME = document.getElementById(sNAICSCodeselectNameUserContext + 'NAICS_CODE_NAME' + sNAICSCodeselectNameUserSuffix);
	if ( fldNAICS_CODE_NAME != null )
	{
		fldNAICS_CODE_NAME.value = sPARENT_NAME;
		try
		{
			NAICS_CODES_NAICS_CODE_NAME_Changed(fldNAICS_CODE_NAME);
		}
		catch(e)
		{
			alert('NAICSCodeselect - ChangeNAICSCodeselect: ' + e.message);
		}
	}
}

function NamePrefix(s, sSeparator)
{
	var nSeparatorIndex = s.lastIndexOf(sSeparator);
	if ( nSeparatorIndex > 0 )
	{
		return s.substring(0, nSeparatorIndex);
	}
}

function NameSuffix(s, sSeparator)
{
	var nSeparatorIndex = s.lastIndexOf(sSeparator);
	if ( nSeparatorIndex > 0 )
	{
		return s.substring(nSeparatorIndex + sSeparator.length, s.length);
	}
	return '';
}

function NAICSCodeSelectPopup(fldSELECT_NAME)
{
	// 08/29/2009 Paul.  Use a different name for our NAICSCodeselect callback to prevent a collision with the ModulePopup code. 
	ChangeNAICSCode = ChangeNAICSCodeselect;
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	//sNAICSCodeselectNameUserContext = fldSELECT_NAME.id.replace('SELECT_NAME', '');
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	sNAICSCodeselectNameUserContext = NamePrefix(fldSELECT_NAME.id, 'SELECT_NAME');
	sNAICSCodeselectNameUserSuffix  = NameSuffix(fldSELECT_NAME.id, 'SELECT_NAME');
	// 05/16/2010 Paul.  Make sure that our rootURL global javascript variable is always available. 
	// 01/27/2012 Paul.  Cannot use ASP.NET code here.  Must embed the string or use a public. 
	// 09/07/2013 Paul.  Change rootURL to sREMOTE_SERVER to match Survey module. 
	// 05/12/2016 Paul.  Increase default popup size. 
	window.open(sREMOTE_SERVER + 'Administration/NAICSCodes/Popup.aspx', 'NAICSCodeSelectPopup', 'width=900,height=900,resizable=1,scrollbars=1');
	return false;
}

function NAICS_CODES_NAICS_CODE_NAME_ItemSelected(sender, e)
{
	NAICS_CODES_NAICS_CODE_NAME_Changed(sender.get_element());
}

function NAICS_CODES_NAICS_CODE_NAME_Changed(fldNAICS_CODE_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	//var userContext = fldNAICS_CODE_NAME.id.substring(0, fldNAICS_CODE_NAME.id.length - 'NAICS_CODE_NAME'.length)
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	var userContext = NamePrefix(fldNAICS_CODE_NAME.id, 'NAICS_CODE_NAME');
	var userSuffix  = NameSuffix(fldNAICS_CODE_NAME.id, 'NAICS_CODE_NAME');

	var fldAjaxErrors = document.getElementById(userContext + 'NAICS_CODE_NAME_AjaxErrors' + userSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_NAICS_CODE_NAME = document.getElementById(userContext + 'PREV_NAICS_CODE_NAME' + userSuffix);
	if ( fldPREV_NAICS_CODE_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_NAICS_CODE_NAME');
	}
	else if ( fldPREV_NAICS_CODE_NAME.value != fldNAICS_CODE_NAME.value )
	{
		if ( fldNAICS_CODE_NAME.value.length > 0 )
		{
			try
			{
				sNAICSCodeselectNameUserContext = userContext;
				sNAICSCodeselectNameUserSuffix  = userSuffix ;
				SplendidCRM.Administration.NAICSCodes.AutoComplete.NAICS_CODES_NAICS_CODE_NAME_Get(fldNAICS_CODE_NAME.value, NAICS_CODES_NAICS_CODE_NAME_Changed_OnSucceededWithContext, NAICS_CODES_NAICS_CODE_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('NAICS_CODES_NAICS_CODE_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			NAICS_CODES_NAICS_CODE_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function NAICS_CODES_NAICS_CODE_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
		var fldAjaxErrors     = document.getElementById(userContext + 'NAICS_CODE_NAME_AjaxErrors' + sNAICSCodeselectNameUserSuffix);
		var fldNAICS_CODE_ID        = document.getElementById(userContext + 'NAICS_CODE_ID'        + sNAICSCodeselectNameUserSuffix);
		var fldNAICS_CODE_NAME      = document.getElementById(userContext + 'NAICS_CODE_NAME'      + sNAICSCodeselectNameUserSuffix);
		var fldPREV_NAICS_CODE_NAME = document.getElementById(userContext + 'PREV_NAICS_CODE_NAME' + sNAICSCodeselectNameUserSuffix);
		if ( fldNAICS_CODE_ID        != null ) fldNAICS_CODE_ID.value        = sID  ;
		if ( fldNAICS_CODE_NAME      != null ) fldNAICS_CODE_NAME.value      = sNAME;
		if ( fldPREV_NAICS_CODE_NAME != null ) fldPREV_NAICS_CODE_NAME.value = sNAME;
		
		// 08/31/2009 Paul.  We want to automatically click the update button. 
		// In order for this to work, we must define our own command buttons in the GridView. 
		var btnUpdate = document.getElementById(userContext + 'btnUpdate' + sNAICSCodeselectNameUserSuffix);
		if ( btnUpdate != null )
		{
			btnUpdate.click();
		}
	}
	else
	{
		alert('result from NAICSCodes.AutoComplete service is null');
	}
}

function NAICS_CODES_NAICS_CODE_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	var fldAjaxErrors = document.getElementById(userContext + 'NAICS_CODE_NAME_AjaxErrors' + sNAICSCodeselectNameUserSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldNAICS_CODE_ID        = document.getElementById(userContext + 'NAICS_CODE_ID'        + sNAICSCodeselectNameUserSuffix);
	var fldNAICS_CODE_NAME      = document.getElementById(userContext + 'NAICS_CODE_NAME'      + sNAICSCodeselectNameUserSuffix);
	var fldPREV_NAICS_CODE_NAME = document.getElementById(userContext + 'PREV_NAICS_CODE_NAME' + sNAICSCodeselectNameUserSuffix);
	if ( fldNAICS_CODE_ID        != null ) fldNAICS_CODE_ID.value        = '';
	if ( fldNAICS_CODE_NAME      != null ) fldNAICS_CODE_NAME.value      = '';
	if ( fldPREV_NAICS_CODE_NAME != null ) fldPREV_NAICS_CODE_NAME.value = '';
}

function NAICS_CODES_PARENT_NAME_Changed(fldPARENT_NAME)
{
	var userContext = NamePrefix(fldPARENT_NAME.id, 'PARENT_NAME');
	var userSuffix  = NameSuffix(fldPARENT_NAME.id, 'PARENT_NAME');

	var fldAjaxErrors = document.getElementById(userContext + 'PARENT_NAME_AjaxErrors' + userSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_PARENT_NAME = document.getElementById(userContext + 'PREV_PARENT_NAME' + userSuffix);
	if ( fldPREV_PARENT_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_PARENT_NAME');
	}
	else if ( fldPREV_PARENT_NAME.value != fldPARENT_NAME.value )
	{
		if ( fldPARENT_NAME.value.length > 0 )
		{
			try
			{
				sNAICSCodeselectNameUserContext = userContext;
				sNAICSCodeselectNameUserSuffix  = userSuffix ;
				SplendidCRM.Administration.NAICSCodes.AutoComplete.NAICS_CODES_NAICS_CODE_NAME_Get(fldPARENT_NAME.value, NAICS_CODES_PARENT_NAME_Changed_OnSucceededWithContext, NAICS_CODES_PARENT_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('NAICS_CODES_PARENT_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			NAICS_CODES_PARENT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function NAICS_CODES_PARENT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
		var fldAjaxErrors       = document.getElementById(userContext + 'PARENT_NAME_AjaxErrors' + sNAICSCodeselectNameUserSuffix);
		var fldPARENT_ID        = document.getElementById(userContext + 'PARENT_ID'        + sNAICSCodeselectNameUserSuffix);
		var fldPARENT_NAME      = document.getElementById(userContext + 'PARENT_NAME'      + sNAICSCodeselectNameUserSuffix);
		var fldPREV_PARENT_NAME = document.getElementById(userContext + 'PREV_PARENT_NAME' + sNAICSCodeselectNameUserSuffix);
		if ( fldPARENT_ID        != null ) fldPARENT_ID.value        = sID  ;
		if ( fldPARENT_NAME      != null ) fldPARENT_NAME.value      = sNAME;
		if ( fldPREV_PARENT_NAME != null ) fldPREV_PARENT_NAME.value = sNAME;
		
		// 08/31/2009 Paul.  We want to automatically click the update button. 
		// In order for this to work, we must define our own command buttons in the GridView. 
		var btnUpdate = document.getElementById(userContext + 'btnUpdate' + sNAICSCodeselectNameUserSuffix);
		if ( btnUpdate != null )
		{
			btnUpdate.click();
		}
	}
	else
	{
		alert('result from NAICSCodes.AutoComplete service is null');
	}
}

function NAICS_CODES_PARENT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	var fldAjaxErrors = document.getElementById(userContext + 'PARENT_NAME_AjaxErrors' + sNAICSCodeselectNameUserSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldPARENT_ID        = document.getElementById(userContext + 'PARENT_ID'        + sNAICSCodeselectNameUserSuffix);
	var fldPARENT_NAME      = document.getElementById(userContext + 'PARENT_NAME'      + sNAICSCodeselectNameUserSuffix);
	var fldPREV_PARENT_NAME = document.getElementById(userContext + 'PREV_PARENT_NAME' + sNAICSCodeselectNameUserSuffix);
	if ( fldPARENT_ID        != null ) fldPARENT_ID.value        = '';
	if ( fldPARENT_NAME      != null ) fldPARENT_NAME.value      = '';
	if ( fldPREV_PARENT_NAME != null ) fldPREV_PARENT_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();

