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

var sTagSelectNameUserContext = '';
var sTagSelectNameUserSuffix  = '';
function ChangeTagSelect(sPARENT_ID, sPARENT_NAME)
{
	var fldTAG_NAME = document.getElementById(sTagSelectNameUserContext + 'TAG_NAME' + sTagSelectNameUserSuffix);
	if ( fldTAG_NAME != null )
	{
		fldTAG_NAME.value = sPARENT_NAME;
		try
		{
			TAGS_TAG_NAME_Changed(fldTAG_NAME);
		}
		catch(e)
		{
			alert('TAGSelect - ChangeTagSelect: ' + e.message);
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

function TagSelectPopup(fldSELECT_NAME)
{
	// 08/29/2009 Paul.  Use a different name for our TAGSelect callback to prevent a collision with the ModulePopup code. 
	ChangeTag = ChangeTagSelect;
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	//sTagSelectNameUserContext = fldSELECT_NAME.id.replace('SELECT_NAME', '');
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	sTagSelectNameUserContext = NamePrefix(fldSELECT_NAME.id, 'SELECT_NAME');
	sTagSelectNameUserSuffix  = NameSuffix(fldSELECT_NAME.id, 'SELECT_NAME');
	// 05/16/2010 Paul.  Make sure that our rootURL global javascript variable is always available. 
	// 01/27/2012 Paul.  Cannot use ASP.NET code here.  Must embed the string or use a public. 
	// 09/07/2013 Paul.  Change rootURL to sREMOTE_SERVER to match Survey module. 
	window.open(sREMOTE_SERVER + 'Administration/Tags/PopupMultiSelect.aspx', 'TagSelectPopup', 'width=900,height=900,resizable=1,scrollbars=1');
	return false;
}

function TAGS_TAG_NAME_ItemSelected(sender, e)
{
	TAGS_TAG_NAME_Changed(sender.get_element());
}

function TAGS_TAG_NAME_Changed(fldTAG_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain NAME in the text, so just get the length minus 4. 
	//var userContext = fldTAG_NAME.id.substring(0, fldTAG_NAME.id.length - 'TAG_NAME'.length)
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	var userContext = NamePrefix(fldTAG_NAME.id, 'TAG_NAME');
	var userSuffix  = NameSuffix(fldTAG_NAME.id, 'TAG_NAME');

	var fldAjaxErrors = document.getElementById(userContext + 'TAG_NAME_AjaxErrors' + userSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_TAG_NAME = document.getElementById(userContext + 'PREV_TAG_NAME' + userSuffix);
	if ( fldPREV_TAG_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_TAG_NAME');
	}
	else if ( fldPREV_TAG_NAME.value != fldTAG_NAME.value )
	{
		if ( fldTAG_NAME.value.length > 0 )
		{
			try
			{
				sTagSelectNameUserContext = userContext;
				sTagSelectNameUserSuffix  = userSuffix ;
				//SplendidCRM.Administration.Tags.AutoComplete.TAGS_TAG_NAME_Get(fldTAG_NAME.value, TAGS_TAG_NAME_Changed_OnSucceededWithContext, TAGS_TAG_NAME_Changed_OnFailed, userContext);
				SplendidCRM.Administration.Tags.AutoComplete.TAGS_TAG_NAME_MultiSelect(fldTAG_NAME.value, TAGS_TAG_NAME_Changed_OnSucceededWithContext, TAGS_TAG_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('TAGS_TAG_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			TAGS_TAG_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function TAGS_TAG_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( $.isArray(result) )
	{
		// 05/12/2016 Paul.  There is not an easy way to click update button for each array item, so combine into comma separated string and submit. 
		var arrNames = '';
		for ( var i = 0; i < result.length; i++ )
		{
			if ( arrNames.length > 0 )
				arrNames += ',';
			arrNames += result[i].NAME;
		}
		result      = new Object();
		result.ID   = null;
		result.NAME = arrNames;
	}
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
		var fldAjaxErrors     = document.getElementById(userContext + 'TAG_NAME_AjaxErrors' + sTagSelectNameUserSuffix);
		var fldTAG_ID        = document.getElementById(userContext + 'TAG_ID'        + sTagSelectNameUserSuffix);
		var fldTAG_NAME      = document.getElementById(userContext + 'TAG_NAME'      + sTagSelectNameUserSuffix);
		var fldPREV_TAG_NAME = document.getElementById(userContext + 'PREV_TAG_NAME' + sTagSelectNameUserSuffix);
		if ( fldTAG_ID        != null ) fldTAG_ID.value        = sID  ;
		if ( fldTAG_NAME      != null ) fldTAG_NAME.value      = sNAME;
		if ( fldPREV_TAG_NAME != null ) fldPREV_TAG_NAME.value = sNAME;
		
		// 08/31/2009 Paul.  We want to automatically click the update button. 
		// In order for this to work, we must define our own command buttons in the GridView. 
		var btnUpdate = document.getElementById(userContext + 'btnUpdate' + sTagSelectNameUserSuffix);
		if ( btnUpdate != null )
		{
			btnUpdate.click();
		}
	}
	else
	{
		alert('result from Tags.AutoComplete service is null');
	}
}

function TAGS_TAG_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	// 03/17/2011 Paul.  .NET 4.0 appends a row index to the field IDs. 
	var fldAjaxErrors = document.getElementById(userContext + 'TAG_NAME_AjaxErrors' + sTagSelectNameUserSuffix);
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldTAG_ID        = document.getElementById(userContext + 'TAG_ID'        + sTagSelectNameUserSuffix);
	var fldTAG_NAME      = document.getElementById(userContext + 'TAG_NAME'      + sTagSelectNameUserSuffix);
	var fldPREV_TAG_NAME = document.getElementById(userContext + 'PREV_TAG_NAME' + sTagSelectNameUserSuffix);
	if ( fldTAG_ID        != null ) fldTAG_ID.value        = '';
	if ( fldTAG_NAME      != null ) fldTAG_NAME.value      = '';
	if ( fldPREV_TAG_NAME != null ) fldPREV_TAG_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();

