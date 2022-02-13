/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var L10n = new Object();

L10n.GetList = function(sLIST_NAME)
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.TerminologyList(sLIST_NAME);
}

// 02/22/2013 Paul.  We need a way to get the list values, such as month names. 
L10n.GetListTerms = function(sLIST_NAME)
{
	var arrTerms = new Array();
	var bgPage   = chrome.extension.getBackgroundPage();
	var arrList  = bgPage.SplendidCache.TerminologyList(sLIST_NAME);
	if ( arrList != null )
	{
		for ( var i = 0; i < arrList.length; i++ )
		{
			var sEntryName = '.' + sLIST_NAME + '.' + arrList[i];
			var sTerm = bgPage.SplendidCache.Terminology(sEntryName);
			if ( sTerm == null )
				sTerm = '';
			arrTerms.push(sTerm);
		}
	}
	return arrTerms;
}

L10n.Term = function(sEntryName)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		var sTerm = bgPage.SplendidCache.Terminology(sEntryName);
		if ( sTerm == null )
		{
			if ( sEntryName != '+' )
				console.log('Term not found: ' + sEntryName);
			return sEntryName;
		}
		return sTerm;
	}
	catch(e)
	{
		// 12/31/2017 Paul.  Change from alert to error. 
		SplendidError.SystemError(e, 'L10n.Term ' + sEntryName);
	}
	return sEntryName;
}

// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
L10n.ListTerm = function(sLIST_NAME, sNAME)
{
	var sEntryName = '.' + sLIST_NAME + '.' + sNAME;
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		var sTerm = bgPage.SplendidCache.Terminology(sEntryName);
		if ( sTerm == null )
		{
			if ( !Sql.IsEmptyString(sNAME) )
			{
				console.log('Term not found: ' + sEntryName);
				return sEntryName;
			}
			else
			{
				sTerm = '';
			}
		}
		return sTerm;
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'L10n.ListTerm');
	}
	return sEntryName;
}

L10n.TableColumnName = function(sModule, sDISPLAY_NAME)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		// 05/16/2016 Paul.  Add Tags module. 
		// 08/20/2016 Paul.  PENDING_PROCESS_ID should be a global term. 
		// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
		if (  sDISPLAY_NAME == 'ID'              
			|| sDISPLAY_NAME == 'DELETED'         
			|| sDISPLAY_NAME == 'CREATED_BY'      
			|| sDISPLAY_NAME == 'CREATED_BY_ID'   
			|| sDISPLAY_NAME == 'CREATED_BY_NAME' 
			|| sDISPLAY_NAME == 'DATE_ENTERED'    
			|| sDISPLAY_NAME == 'MODIFIED_USER_ID'
			|| sDISPLAY_NAME == 'DATE_MODIFIED'   
			|| sDISPLAY_NAME == 'DATE_MODIFIED_UTC'
			|| sDISPLAY_NAME == 'MODIFIED_BY'     
			|| sDISPLAY_NAME == 'MODIFIED_USER_ID'
			|| sDISPLAY_NAME == 'MODIFIED_BY_NAME'
			|| sDISPLAY_NAME == 'ASSIGNED_USER_ID'
			|| sDISPLAY_NAME == 'ASSIGNED_TO'     
			|| sDISPLAY_NAME == 'ASSIGNED_TO_NAME'
			|| sDISPLAY_NAME == 'TEAM_ID'         
			|| sDISPLAY_NAME == 'TEAM_NAME'       
			|| sDISPLAY_NAME == 'TEAM_SET_ID'     
			|| sDISPLAY_NAME == 'TEAM_SET_NAME'   
			|| sDISPLAY_NAME == 'TEAM_SET_LIST'   
			|| sDISPLAY_NAME == 'ID_C'            
			|| sDISPLAY_NAME == 'AUDIT_ID'        
			|| sDISPLAY_NAME == 'AUDIT_ACTION'    
			|| sDISPLAY_NAME == 'AUDIT_DATE'      
			|| sDISPLAY_NAME == 'AUDIT_COLUMNS'   
			|| sDISPLAY_NAME == 'AUDIT_TABLE'     
			|| sDISPLAY_NAME == 'AUDIT_TOKEN'     
			|| sDISPLAY_NAME == 'LAST_ACTIVITY_DATE'
			|| sDISPLAY_NAME == 'TAG_SET_NAME'    
			|| sDISPLAY_NAME == 'PENDING_PROCESS_ID'
			)
		{
			if ( bgPage.SplendidCache.Terminology('.LBL_' + sDISPLAY_NAME) != null )
				sDISPLAY_NAME = bgPage.SplendidCache.Terminology('.LBL_' + sDISPLAY_NAME);
		}
		else
		{
			if ( bgPage.SplendidCache.Terminology(sModule + '.LBL_' + sDISPLAY_NAME) != null )
				sDISPLAY_NAME = bgPage.SplendidCache.Terminology(sModule + '.LBL_' + sDISPLAY_NAME);
		}
		return sDISPLAY_NAME;
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'L10n.TableColumnName');
	}
	// 05/13/2018 Paul.  sEntryName is incorrect. 
	return sDISPLAY_NAME;
}

