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

function ZIPCODES_POSTALCODE_Changed(fldPOSTALCODE)
{
	var userContext = fldPOSTALCODE.id.substring(0, fldPOSTALCODE.id.length - 'POSTALCODE'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'POSTALCODE_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_POSTALCODE = document.getElementById(userContext + 'POSTALCODE_PREV');
	if ( fldPREV_POSTALCODE == null )
	{
		//alert('Could not find ' + userContext + 'PREV_POSTALCODE');
	}
	else if ( fldPREV_POSTALCODE.value != fldPOSTALCODE.value )
	{
		if ( fldPOSTALCODE.value.length > 0 )
		{
			try
			{
				var fldCOUNTRY = document.getElementById(userContext + 'COUNTRY');
				var sCOUNTRY = '';
				// 11/19/2017 Paul.  Field will be null, not undefined. 
				if ( fldCOUNTRY != null )
				{
					if ( fldCOUNTRY.options !== undefined )
						sCOUNTRY = fldCOUNTRY.options[fldCOUNTRY.selectedIndex].value;
					else
						sCOUNTRY = fldCOUNTRY.value;
				}
				SplendidCRM.Administration.ZipCodes.AutoComplete.ZIPCODES_POSTALCODE_Get(fldPOSTALCODE.value, sCOUNTRY, ZIPCODES_POSTALCODE_Changed_OnSucceededWithContext, ZIPCODES_POSTALCODE_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('ZIPCODES_POSTALCODE_Changed: ' + e.message);
			}
		}
		else
		{
			fldPREV_POSTALCODE.value = '';
		}
	}
}

function ZIPCODES_POSTALCODE_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sPOSTALCODE = result.POSTALCODE;
		var sCITY       = result.CITY      ;
		var sSTATE      = result.STATE     ;
		var sCOUNTRY    = result.COUNTRY   ;
		
		var fldAjaxErrors      = document.getElementById(userContext + 'POSTALCODE_AjaxErrors');
		var fldPOSTALCODE      = document.getElementById(userContext + 'POSTALCODE'     );
		var fldCITY            = document.getElementById(userContext + 'CITY'           );
		var fldSTATE           = document.getElementById(userContext + 'STATE'          );
		var fldCOUNTRY         = document.getElementById(userContext + 'COUNTRY'        );
		var fldPREV_POSTALCODE = document.getElementById(userContext + 'POSTALCODE_PREV');
		if ( fldPOSTALCODE      != null ) fldPOSTALCODE     .value = sPOSTALCODE;
		if ( fldCITY            != null ) fldCITY           .value = sCITY      ;
		if ( fldSTATE           != null ) fldSTATE          .value = sSTATE     ;
		if ( fldCOUNTRY         != null ) fldCOUNTRY        .value = sCOUNTRY   ;
		if ( fldPREV_POSTALCODE != null ) fldPREV_POSTALCODE.value = sPOSTALCODE;
	}
	else
	{
		alert('result from ZipCodes.AutoComplete service is null');
	}
}

function ZIPCODES_POSTALCODE_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'POSTALCODE_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	// 04/13/2016 Paul.  If postal code not found, then do nothing.  Don't clear any field. 
	//var fldPOSTALCODE      = document.getElementById(userContext + 'POSTALCODE'     );
	//var fldPREV_POSTALCODE = document.getElementById(userContext + 'POSTALCODE_PREV');
	//if ( fldPOSTALCODE      != null ) fldPOSTALCODE.value      = '';
	//if ( fldPREV_POSTALCODE != null ) fldPREV_POSTALCODE.value = '';
}

function ZipCodes_SetContextKey(sEXTENDER_ID, sPOSTALCODE_ID)
{
	try
	{
		var userContext = sPOSTALCODE_ID.substring(0, sPOSTALCODE_ID.length - 'POSTALCODE'.length)
		var fldCOUNTRY = document.getElementById(userContext + 'COUNTRY');
		if ( fldCOUNTRY != null )
		{
			fldCOUNTRY.onkeyup = function()
			{
				var sCOUNTRY = '';
				if ( fldCOUNTRY.options !== undefined )
					sCOUNTRY = fldCOUNTRY.options[fldCOUNTRY.selectedIndex].value;
				else
					sCOUNTRY = fldCOUNTRY.value;
				var fldPOSTALCODE = document.getElementById(sPOSTALCODE_ID);
				if ( fldPOSTALCODE != null )
				{
					$find(sEXTENDER_ID).set_contextKey(sCOUNTRY);
				}
			}
		}
	}
	catch(e)
	{
		console.log('ZipCodes_SetContextKey: ' + e.message);
	}
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();

