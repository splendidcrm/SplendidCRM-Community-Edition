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

function SplendidCRM_ChangeFavorites(fld, sMODULE, gID)
{
	var fldAdd = document.getElementsByName('favAdd_' + gID);
	var fldRem = document.getElementsByName('favRem_' + gID);
	if ( fldAdd[0].style.display == 'none' )
		SplendidCRM_RemoveFromFavorites(fld, sMODULE, gID);
	else
		SplendidCRM_AddToFavorites(fld, sMODULE, gID);
}

function SplendidCRM_AddToFavorites(fld, sMODULE, gID)
{
	var userContext = gID;
	try
	{
		SplendidCRM.Utilities.Modules.AddToFavorites(sMODULE, gID, SplendidCRM_AddToFavorites_OnSucceededWithContext, SplendidCRM_AddToFavorites_OnFailed, userContext);
	}
	catch(e)
	{
		alert('SplendidCRM_AddToFavorites: ' + e.message);
	}
	return false;
}

function SplendidCRM_AddToFavorites_OnSucceededWithContext(result, userContext)
{
	if ( result )
	{
		var fldAdd = document.getElementsByName('favAdd_' + userContext);
		var fldRem = document.getElementsByName('favRem_' + userContext);
		fldAdd[0].style.display = 'none'  ;
		fldRem[0].style.display = 'inline';
	}
}

function SplendidCRM_AddToFavorites_OnFailed(error, userContext)
{
	alert('SplendidCRM_AddToFavorites_OnFailed: ' + error.Message);
}

function SplendidCRM_RemoveFromFavorites(fld, sMODULE, gID)
{
	var userContext = gID;
	try
	{
		SplendidCRM.Utilities.Modules.RemoveFromFavorites(sMODULE, gID, SplendidCRM_RemoveFromFavorites_OnSucceededWithContext, SplendidCRM_RemoveFromFavorites_OnFailed, userContext);
	}
	catch(e)
	{
		alert('SplendidCRM_RemoveFromFavorites: ' + e.message);
	}
	return false;
}

function SplendidCRM_RemoveFromFavorites_OnSucceededWithContext(result, userContext)
{
	if ( result )
	{
		var fldAdd = document.getElementsByName('favAdd_' + userContext);
		var fldRem = document.getElementsByName('favRem_' + userContext);
		fldAdd[0].style.display = 'inline';
		fldRem[0].style.display = 'none'  ;
	}
}

function SplendidCRM_RemoveFromFavorites_OnFailed(error, userContext)
{
	alert('SplendidCRM_RemoveFromFavorites_OnFailed: ' + error.Message);
}

// 10/09/2015 Paul.  Add methods to manage subscriptions. 
function SplendidCRM_ChangeFollowing(fld, sMODULE, gID)
{
	var fldAdd = document.getElementsByName('follow_'    + gID);
	var fldRem = document.getElementsByName('following_' + gID);
	if ( fldAdd[0].style.display == 'none' )
		SplendidCRM_RemoveSubscription(fld, sMODULE, gID);
	else
		SplendidCRM_AddSubscription(fld, sMODULE, gID);
}

function SplendidCRM_AddSubscription(fld, sMODULE, gID)
{
	var userContext = gID;
	try
	{
		SplendidCRM.Utilities.Modules.AddSubscription(sMODULE, gID, SplendidCRM_AddSubscription_OnSucceededWithContext, SplendidCRM_AddSubscription_OnFailed, userContext);
	}
	catch(e)
	{
		alert('SplendidCRM_AddSubscription: ' + e.message);
	}
	return false;
}

function SplendidCRM_AddSubscription_OnSucceededWithContext(result, userContext)
{
	if ( result )
	{
		var fldAdd = document.getElementsByName('follow_'    + userContext);
		var fldRem = document.getElementsByName('following_' + userContext);
		fldAdd[0].style.display = 'none'  ;
		fldRem[0].style.display = 'inline';
	}
}

function SplendidCRM_AddSubscription_OnFailed(error, userContext)
{
	alert('SplendidCRM_AddSubscription_OnFailed: ' + error.Message);
}

function SplendidCRM_RemoveSubscription(fld, sMODULE, gID)
{
	var userContext = gID;
	try
	{
		SplendidCRM.Utilities.Modules.RemoveSubscription(sMODULE, gID, SplendidCRM_RemoveSubscription_OnSucceededWithContext, SplendidCRM_RemoveSubscription_OnFailed, userContext);
	}
	catch(e)
	{
		alert('SplendidCRM_RemoveSubscription: ' + e.message);
	}
	return false;
}

function SplendidCRM_RemoveSubscription_OnSucceededWithContext(result, userContext)
{
	if ( result )
	{
		var fldAdd = document.getElementsByName('follow_' + userContext);
		var fldRem = document.getElementsByName('following_' + userContext);
		fldAdd[0].style.display = 'inline';
		fldRem[0].style.display = 'none'  ;
	}
}

function SplendidCRM_RemoveSubscription_OnFailed(error, userContext)
{
	alert('SplendidCRM_RemoveSubscription_OnFailed: ' + error.Message);
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


