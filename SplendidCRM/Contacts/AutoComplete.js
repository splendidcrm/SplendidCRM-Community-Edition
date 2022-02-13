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

function CONTACTS_CONTACT_LAST_NAME_Changed(fldCONTACT_LAST_NAME)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain LAST_NAME in the text, so just get the length minus 4. 
	var userContext = fldCONTACT_LAST_NAME.id.substring(0, fldCONTACT_LAST_NAME.id.length - 'CONTACT_LAST_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_LAST_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_CONTACT_LAST_NAME = document.getElementById(userContext + 'PREV_CONTACT_LAST_NAME');
	if ( fldPREV_CONTACT_LAST_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_CONTACT_LAST_NAME');
	}
	else if ( fldPREV_CONTACT_LAST_NAME.value != fldCONTACT_LAST_NAME.value )
	{
		if ( fldCONTACT_LAST_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Contacts.AutoComplete.CONTACTS_CONTACT_LAST_NAME_Get(fldCONTACT_LAST_NAME.value, CONTACTS_CONTACT_LAST_NAME_Changed_OnSucceededWithContext, CONTACTS_CONTACT_LAST_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('CONTACTS_CONTACT_LAST_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			CONTACTS_CONTACT_LAST_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function CONTACTS_CONTACT_LAST_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID        = result.ID  ;
		var sLAST_NAME = result.LAST_NAME;
		
		var fldAjaxErrors             = document.getElementById(userContext + 'CONTACT_LAST_NAME_AjaxErrors');
		var fldCONTACT_ID             = document.getElementById(userContext + 'CONTACT_ID'            );
		var fldCONTACT_LAST_NAME      = document.getElementById(userContext + 'CONTACT_LAST_NAME'     );
		var fldPREV_CONTACT_LAST_NAME = document.getElementById(userContext + 'PREV_CONTACT_LAST_NAME');
		if ( fldCONTACT_ID             != null ) fldCONTACT_ID.value             = sID       ;
		if ( fldCONTACT_LAST_NAME      != null ) fldCONTACT_LAST_NAME.value      = sLAST_NAME;
		if ( fldPREV_CONTACT_LAST_NAME != null ) fldPREV_CONTACT_LAST_NAME.value = sLAST_NAME;
	}
	else
	{
		alert('result from Contacts.AutoComplete service is null');
	}
}

function CONTACTS_CONTACT_LAST_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_LAST_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCONTACT_ID             = document.getElementById(userContext + 'CONTACT_ID'            );
	var fldCONTACT_LAST_NAME      = document.getElementById(userContext + 'CONTACT_LAST_NAME'     );
	var fldPREV_CONTACT_LAST_NAME = document.getElementById(userContext + 'PREV_CONTACT_LAST_NAME');
	if ( fldCONTACT_ID             != null ) fldCONTACT_ID.value             = '';
	if ( fldCONTACT_LAST_NAME      != null ) fldCONTACT_LAST_NAME.value      = '';
	if ( fldPREV_CONTACT_LAST_NAME != null ) fldPREV_CONTACT_LAST_NAME.value = '';
}

function CONTACTS_CONTACT_NAME_ItemSelected(sender, e)
{
	CONTACTS_CONTACT_NAME_Changed(sender.get_element());
}

function CONTACTS_CONTACT_NAME_Changed(fldCONTACT_NAME)
{
	if ( fldCONTACT_NAME != null )
	{
		var userContext = fldCONTACT_NAME.id.substring(0, fldCONTACT_NAME.id.length - 'CONTACT_NAME'.length)
		var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
		if ( fldAjaxErrors != null )
			fldAjaxErrors.innerHTML = '';
		
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
		if ( fldPREV_CONTACT_NAME == null )
		{
			//alert('Could not find ' + userContext + 'PREV_CONTACT_NAME');
		}
		else if ( fldPREV_CONTACT_NAME.value != fldCONTACT_NAME.value )
		{
			if ( fldCONTACT_NAME.value.length > 0 )
			{
				try
				{
					SplendidCRM.Contacts.AutoComplete.CONTACTS_CONTACT_NAME_Get(fldCONTACT_NAME.value, CONTACTS_CONTACT_NAME_Changed_OnSucceededWithContext, CONTACTS_CONTACT_NAME_Changed_OnFailed, userContext);
				}
				catch(e)
				{
					alert('CONTACTS_CONTACT_NAME_Changed: ' + e.message);
				}
			}
			else
			{
				// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
				var result = { 'ID' : '', 'NAME' : '' };
				CONTACTS_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
			}
		}
	}
}

function CONTACTS_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors        = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
		var fldCONTACT_ID        = document.getElementById(userContext + 'CONTACT_ID'  );
		var fldCONTACT_NAME      = document.getElementById(userContext + 'CONTACT_NAME');
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
		if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = sID  ;
		if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = sNAME;
		if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = sNAME;
		// 08/21/2010 Paul.  We typically submit the form when the account changes so that we can load the address. 
		// 08/21/2010 Paul.  If an Update button is available, then click it. 
		var fldCONTACT_UPDATE = document.getElementById(userContext + 'CONTACT_UPDATE');
		if ( fldCONTACT_UPDATE != null )
			fldCONTACT_UPDATE.click();
		// 09/16/2010 Paul.  We want to automatically click the update button in the RelatedSelect control. 
		// In order for this to work, we must define our own command buttons in the GridView. 
		var btnUpdate = document.getElementById(userContext + 'btnUpdate');
		if ( btnUpdate != null )
		{
			btnUpdate.click();
		}
	}
	else
	{
		alert('result from Contacts.AutoComplete service is null');
	}
}

function CONTACTS_CONTACT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCONTACT_ID        = document.getElementById(userContext + 'CONTACT_ID'       );
	var fldCONTACT_NAME      = document.getElementById(userContext + 'CONTACT_NAME'     );
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
	if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = '';
	if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = '';
	if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = '';
}

// 07/27/2010 Paul.  Allow Contact lookup from Quotes, Orders or Invoices. 
// 07/27/2010 Paul.  Since we are using the ContextKey for the AutoComplete, we need to also use it with the Get. 
function CONTACTS_BILLING_CONTACT_NAME_Changed(fldCONTACT_NAME)
{
	var userContext = fldCONTACT_NAME.id.substring(0, fldCONTACT_NAME.id.length - 'BILLING_CONTACT_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'BILLING_CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var sACCOUNT_NAME = '';
	var fldBILLING_ACCOUNT_NAME = document.getElementById(userContext + 'BILLING_ACCOUNT_NAME');
	if ( fldBILLING_ACCOUNT_NAME != null )
	{
		sACCOUNT_NAME = fldBILLING_ACCOUNT_NAME.value;
	}
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_BILLING_CONTACT_NAME');
	if ( fldPREV_CONTACT_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_CONTACT_NAME');
	}
	else if ( fldPREV_CONTACT_NAME.value != fldCONTACT_NAME.value )
	{
		if ( fldCONTACT_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Contacts.AutoComplete.CONTACTS_BILLING_CONTACT_NAME_Get(fldCONTACT_NAME.value, sACCOUNT_NAME, CONTACTS_BILLING_CONTACT_NAME_Changed_OnSucceededWithContext, CONTACTS_BILLING_CONTACT_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('CONTACTS_BILLING_CONTACT_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			CONTACTS_BILLING_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function CONTACTS_BILLING_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors        = document.getElementById(userContext + 'BILLING_CONTACT_NAME_AjaxErrors');
		var fldCONTACT_ID        = document.getElementById(userContext + 'BILLING_CONTACT_ID'  );
		var fldCONTACT_NAME      = document.getElementById(userContext + 'BILLING_CONTACT_NAME');
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_BILLING_CONTACT');
		if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = sID  ;
		if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = sNAME;
		if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = sNAME;
		// 08/21/2010 Paul.  We typically submit the form when the account changes so that we can load the address. 
		// 08/21/2010 Paul.  If an Update button is available, then click it. 
		var fldBILLING_CONTACT_UPDATE = document.getElementById(userContext + 'BILLING_CONTACT_UPDATE');
		if ( fldBILLING_CONTACT_UPDATE != null )
			fldBILLING_CONTACT_UPDATE.click();
	}
	else
	{
		alert('result from Contacts.AutoComplete service is null');
	}
}

function CONTACTS_BILLING_CONTACT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'BILLING_CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCONTACT_ID        = document.getElementById(userContext + 'BILLING_CONTACT_ID'       );
	var fldCONTACT_NAME      = document.getElementById(userContext + 'BILLING_CONTACT_NAME'     );
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_BILLING_CONTACT_NAME');
	if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = '';
	if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = '';
	if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = '';
}

function CONTACTS_SHIPPING_CONTACT_NAME_Changed(fldCONTACT_NAME)
{
	var userContext = fldCONTACT_NAME.id.substring(0, fldCONTACT_NAME.id.length - 'SHIPPING_CONTACT_NAME'.length)
	var fldAjaxErrors = document.getElementById(userContext + 'SHIPPING_CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var sACCOUNT_NAME = '';
	var fldSHIPPING_ACCOUNT_NAME = document.getElementById(userContext + 'SHIPPING_ACCOUNT_NAME');
	if ( fldSHIPPING_ACCOUNT_NAME != null )
	{
		sACCOUNT_NAME = fldSHIPPING_ACCOUNT_NAME.value;
	}
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_SHIPPING_CONTACT_NAME');
	if ( fldPREV_CONTACT_NAME == null )
	{
		//alert('Could not find ' + userContext + 'PREV_CONTACT_NAME');
	}
	else if ( fldPREV_CONTACT_NAME.value != fldCONTACT_NAME.value )
	{
		if ( fldCONTACT_NAME.value.length > 0 )
		{
			try
			{
				SplendidCRM.Contacts.AutoComplete.CONTACTS_BILLING_CONTACT_NAME_Get(fldCONTACT_NAME.value, sACCOUNT_NAME, CONTACTS_SHIPPING_CONTACT_NAME_Changed_OnSucceededWithContext, CONTACTS_SHIPPING_CONTACT_NAME_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('CONTACTS_SHIPPING_CONTACT_NAME_Changed: ' + e.message);
			}
		}
		else
		{
			// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
			var result = { 'ID' : '', 'NAME' : '' };
			CONTACTS_SHIPPING_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function CONTACTS_SHIPPING_CONTACT_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors        = document.getElementById(userContext + 'SHIPPING_CONTACT_NAME_AjaxErrors');
		var fldCONTACT_ID        = document.getElementById(userContext + 'SHIPPING_CONTACT_ID'  );
		var fldCONTACT_NAME      = document.getElementById(userContext + 'SHIPPING_CONTACT_NAME');
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_SHIPPING_CONTACT');
		if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = sID  ;
		if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = sNAME;
		if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = sNAME;
		// 08/21/2010 Paul.  We typically submit the form when the account changes so that we can load the address. 
		// 08/21/2010 Paul.  If an Update button is available, then click it. 
		var fldSHIPPING_CONTACT_UPDATE = document.getElementById(userContext + 'SHIPPING_CONTACT_UPDATE');
		if ( fldSHIPPING_CONTACT_UPDATE != null )
			fldSHIPPING_CONTACT_UPDATE.click();
	}
	else
	{
		alert('result from Contacts.AutoComplete service is null');
	}
}

function CONTACTS_SHIPPING_CONTACT_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'SHIPPING_CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCONTACT_ID        = document.getElementById(userContext + 'SHIPPING_CONTACT_ID'       );
	var fldCONTACT_NAME      = document.getElementById(userContext + 'SHIPPING_CONTACT_NAME'     );
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_SHIPPING_CONTACT_NAME');
	if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = '';
	if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = '';
	if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = '';
}

		// 03/10/2016 Paul.  Missing lookup for Reports To Name. 
function CONTACTS_REPORTS_TO_NAME_Changed(fldCONTACT_NAME)
{
	if ( fldCONTACT_NAME != null )
	{
		var userContext = fldCONTACT_NAME.id.substring(0, fldCONTACT_NAME.id.length - 'CONTACT_NAME'.length)
		var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
		if ( fldAjaxErrors != null )
			fldAjaxErrors.innerHTML = '';
		
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
		if ( fldPREV_CONTACT_NAME == null )
		{
			//alert('Could not find ' + userContext + 'PREV_CONTACT_NAME');
		}
		else if ( fldPREV_CONTACT_NAME.value != fldCONTACT_NAME.value )
		{
			if ( fldCONTACT_NAME.value.length > 0 )
			{
				try
				{
					SplendidCRM.Contacts.AutoComplete.CONTACTS_REPORTS_TO_NAME_Get(fldCONTACT_NAME.value, CONTACTS_REPORTS_TO_NAME_Changed_OnSucceededWithContext, CONTACTS_REPORTS_TO_NAME_Changed_OnFailed, userContext);
				}
				catch(e)
				{
					alert('CONTACTS_REPORTS_TO_NAME_Changed: ' + e.message);
				}
			}
			else
			{
				// 08/30/2010 Paul.  If the name was cleared, then we must also clear the hidden ID field. 
				var result = { 'ID' : '', 'NAME' : '' };
				CONTACTS_REPORTS_TO_NAME_Changed_OnSucceededWithContext(result, userContext, null);
			}
		}
	}
}

function CONTACTS_REPORTS_TO_NAME_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var sNAME = result.NAME;
		
		var fldAjaxErrors        = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
		var fldCONTACT_ID        = document.getElementById(userContext + 'CONTACT_ID'  );
		var fldCONTACT_NAME      = document.getElementById(userContext + 'CONTACT_NAME');
		var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
		if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = sID  ;
		if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = sNAME;
		if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = sNAME;
		// 08/21/2010 Paul.  We typically submit the form when the account changes so that we can load the address. 
		// 08/21/2010 Paul.  If an Update button is available, then click it. 
		var fldCONTACT_UPDATE = document.getElementById(userContext + 'CONTACT_UPDATE');
		if ( fldCONTACT_UPDATE != null )
			fldCONTACT_UPDATE.click();
		// 09/16/2010 Paul.  We want to automatically click the update button in the RelatedSelect control. 
		// In order for this to work, we must define our own command buttons in the GridView. 
		var btnUpdate = document.getElementById(userContext + 'btnUpdate');
		if ( btnUpdate != null )
		{
			btnUpdate.click();
		}
	}
	else
	{
		alert('result from Contacts.AutoComplete service is null');
	}
}

function CONTACTS_REPORTS_TO_NAME_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + 'CONTACT_NAME_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fldCONTACT_ID        = document.getElementById(userContext + 'CONTACT_ID'       );
	var fldCONTACT_NAME      = document.getElementById(userContext + 'CONTACT_NAME'     );
	var fldPREV_CONTACT_NAME = document.getElementById(userContext + 'PREV_CONTACT_NAME');
	if ( fldCONTACT_ID        != null ) fldCONTACT_ID.value        = '';
	if ( fldCONTACT_NAME      != null ) fldCONTACT_NAME.value      = '';
	if ( fldPREV_CONTACT_NAME != null ) fldPREV_CONTACT_NAME.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


