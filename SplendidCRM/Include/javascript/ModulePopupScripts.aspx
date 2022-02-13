<%@ Page language="c#" Codebehind="ModulePopupScripts.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.JavaScript.ModulePopupScripts" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
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
// OutputCache Duration="86400" VaryByParam="none" 
// 10/24/2009 Paul.  We still can't use the standard page caching otherwise we risk getting an unauthenticated page cached, which would prevent all popups. 
// 10/24/2009 Paul.  ModulePopupScripts is a very popular file and we need to cache it as often as possible, yet still allow an invalidation for module changes. 
// 09/03/2009 Paul.  We should cache this entire page, but I noticed one instance where the results were incomplete, so it might not be worth the risk. 
// 05/17/2009 Paul.  We need to manage the Module Popups inside the same Parent Popup code so that we we can reuse the Change functions. 
// 05/17/2009 Paul.  We will be providing the full ClientID in the function parameters, so we don't need to prepend the parent client. 
// 01/13/2010 Paul.  Provide a way for the popup window options to be specified. 
</script>
<head visible="false" runat="server" />
var sCHANGE_MODULE_ID   = null;
var sCHANGE_MODULE_NAME = null;
var sCHANGE_QUERY       = null;
var bCHANGE_SUBMIT      = null;
var sCHANGE_CLICK_FIELD = null;

function ChangeAlert()
{
	alert('There was an error setting the Change callback.');
}

<%
if ( Security.IsAuthenticated() )
{
	foreach ( DataRowView row in vwModulePopups )
	{
		string sSINGULAR_NAME = Sql.ToString(row["SINGULAR_NAME"]);
		Response.Write("var Change" + sSINGULAR_NAME + " = ChangeAlert;\r\n");
	}
}
%>

function ChangeModule(sPARENT_ID, sPARENT_NAME)
{
	// 09/03/2009 Paul.  Also clear any error messages returned by AJAX. 
	var fldAjaxErrors = document.getElementById(sCHANGE_MODULE_NAME + '_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';

	var fldCHANGE_MODULE_ID   = document.getElementById(sCHANGE_MODULE_ID  );
	if ( sCHANGE_MODULE_NAME != null )
	{
		var fldCHANGE_MODULE_NAME = document.getElementById(sCHANGE_MODULE_NAME);
		if ( fldCHANGE_MODULE_NAME != null )
		{
			fldCHANGE_MODULE_NAME.value = sPARENT_NAME;
		}
	}
	if ( fldCHANGE_MODULE_ID != null )
	{
		fldCHANGE_MODULE_ID.value   = sPARENT_ID  ;
		if ( bCHANGE_SUBMIT )
			document.forms[0].submit();
		// 09/18/2010 Paul.  Add the CLICK_FIELD parameter so that an UpdatePanel can be submitted. 
		else if ( sCHANGE_CLICK_FIELD != null )
		{
			var fldCHANGE_CLICK_FIELD = document.getElementById(sCHANGE_CLICK_FIELD);
			if ( fldCHANGE_CLICK_FIELD != null )
				fldCHANGE_CLICK_FIELD.click();
		}
	}
	else
	{
		alert('Could not find ' + sCHANGE_MODULE_ID + ' in the form.');
	}
}

function ModuleTypePopup(sPopupURL, sPopupTitle)
{
	if ( sCHANGE_QUERY != null )
		sPopupURL += '?' + sCHANGE_QUERY;
	return window.open(sPopupURL, sPopupTitle, '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>');
}

// 09/18/2010 Paul.  Add the CLICK_FIELD parameter so that an UpdatePanel can be submitted. 
function ModulePopup(sMODULE_TYPE, sMODULE_ID, sMODULE_NAME, sQUERY, bSUBMIT, sPOPUP_FILE, sCLICK_FIELD)
{
	// 05/18/2009 Paul.  Simplify code.  Only assign change function specific to the task. 
	sCHANGE_MODULE_ID   = sMODULE_ID  ;
	sCHANGE_MODULE_NAME = sMODULE_NAME;
	sCHANGE_QUERY       = sQUERY      ;
	bCHANGE_SUBMIT      = bSUBMIT     ;
	sCHANGE_POPUP_FILE  = sPOPUP_FILE ;
	sCHANGE_CLICK_FIELD = sCLICK_FIELD;
	if ( sCHANGE_POPUP_FILE == null )
		sCHANGE_POPUP_FILE = 'Popup.aspx';
	switch(sMODULE_TYPE)
	{
<%
if ( Security.IsAuthenticated() )
{
	foreach ( DataRowView row in vwModulePopups )
	{
		string sMODULE_NAME   = Sql.ToString(row["MODULE_NAME"  ]);
		string sSINGULAR_NAME = Sql.ToString(row["SINGULAR_NAME"]);
		string sRELATIVE_PATH = Sql.ToString(row["RELATIVE_PATH"]);
		Response.Write("		case '" + sMODULE_NAME + "':  Change" + sSINGULAR_NAME + " = ChangeModule;  ModuleTypePopup('" + sRELATIVE_PATH + "' + sCHANGE_POPUP_FILE, '" + sSINGULAR_NAME + "Popup');  break;\r\n");
	}
}
%>
		default:
			alert('Unknown type. Add ' + sMODULE_TYPE + ' to Include/javascript/ModulePopupScripts.aspx');
			break;
	}
	return false;
}

// 07/27/2010 Paul.  Add the ability to submit after clear. 
function ClearModuleType(sMODULE_TYPE, sMODULE_ID, sMODULE_NAME, bSUBMIT)
{
	sCHANGE_MODULE_ID   = sMODULE_ID  ;
	sCHANGE_MODULE_NAME = sMODULE_NAME;
	bCHANGE_SUBMIT      = bSUBMIT     ;
	ChangeModule('', '');
	return false;
}

// 04/13/2016 Paul.  Add ZipCode lookup. 
var sCHANGE_ZIPCODE_POSTALCODE_ID = null;

function ZipCode_AddressPopup(sPOSTALCODE_ID)
{
	sCHANGE_ZIPCODE_POSTALCODE_ID = sPOSTALCODE_ID;
	return window.open('<%= Sql.ToString(Application["rootURL"]) + "Administration/ZipCodes/PopupAddress.aspx" %>', 'ZipCodePopup', '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>');
}

function ChangeZipCodeAddress(sPOSTALCODE, sCITY, sSTATE, sCOUNTRY)
{
	if ( sCHANGE_ZIPCODE_POSTALCODE_ID != null && sCHANGE_ZIPCODE_POSTALCODE_ID != '' )
	{
		var userContext = sCHANGE_ZIPCODE_POSTALCODE_ID.substring(0, sCHANGE_ZIPCODE_POSTALCODE_ID.length - 'POSTALCODE'.length)
		var fldPOSTALCODE      = document.getElementById(userContext + 'POSTALCODE'     );
		var fldCITY            = document.getElementById(userContext + 'CITY'           );
		var fldSTATE           = document.getElementById(userContext + 'STATE'          );
		var fldCOUNTRY         = document.getElementById(userContext + 'COUNTRY'        );
		if ( fldPOSTALCODE      != null ) fldPOSTALCODE     .value = sPOSTALCODE;
		if ( fldCITY            != null ) fldCITY           .value = sCITY      ;
		if ( fldSTATE           != null ) fldSTATE          .value = sSTATE     ;
		if ( fldCOUNTRY != null && !(sCOUNTRY == null || sCOUNTRY == '') )
			fldCOUNTRY        .value = sCOUNTRY   ;
	}
}

