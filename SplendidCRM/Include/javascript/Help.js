var arrPendingFields = new Array();

function HelpSetValue(sModule, sLayoutView, sName, sValue)
{
	var fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_' + sName);
	// 01/29/2011 Paul.  Dynamic Teams may be enabled,
	if ( fld == null && (sName == 'TEAM_NAME' || sName == 'TEAM_ID') )
	{
		fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_TEAM_SET_NAME_grdMain');
		if ( fld != null )
		{
			for ( var i = 1; i < fld.rows.length; i++ )
			{
				if ( fld.rows[i].cells.length > 0 )
				{
					if ( fld.rows[i].cells[0].childNodes.length > 1 )
					{
						var fldTEAM = opener.document.getElementById(fld.id + '_ctl0' + (i+1).toString() + '_' + sName);
						if ( fldTEAM != null && (fldTEAM.type == 'text' || fldTEAM.type == 'hidden') )
						{
							fldTEAM.value = sValue;
						}
					}
				}
			}
		}
	}
	else if ( typeof fld == 'object' && fld != null )
	{
		try
		{
			if ( fld.type == 'select-one' )
			{
				for ( var i = 0; i < fld.options.length; i++ )
				{
					if ( fld.options[i].value == sValue || fld.options[i].text == sValue )
					{
						fld.options[i].selected = true;
						break;
					}
				}
			}
			else if ( fld.type == 'checkbox' )
			{
				fld.checked = (sValue == 1 || sValue == 'true');
			}
			else if ( fld.type == 'text' || fld.type == 'textarea' || fld.type == 'hidden' )
			{
				fld.value = sValue;
			}
			//else
			//	alert(sName + ' ' + fld.type + ' ' + fld.tagName);
		}
		catch(e)
		{
			alert(sName + ' Set error:' + e.message);
		}
	}
	// 01/29/2011 Paul.  The EXCHANGE_FOLDER field is not always enabled. 
	else if ( sName != "EXCHANGE_FOLDER" )
	{
		alert('Could not find ' + sModule + '.' + sName + ' in ' + sLayoutView + '.  Make sure that the parent window is in ' + sModule + ' ' + sLayoutView);
	}
}
function HelpGetValue(sModule, sLayoutView, sName)
{
	var sValue = '';
	var fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_' + sName);
	// 01/29/2011 Paul.  Dynamic Teams may be enabled,
	if ( fld == null && (sName == 'TEAM_NAME' || sName == 'TEAM_ID') )
	{
		fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_TEAM_SET_NAME_grdMain');
		if ( fld != null )
		{
			for ( var i = 1; i < fld.rows.length; i++ )
			{
				if ( fld.rows[i].cells.length > 0 )
				{
					if ( fld.rows[i].cells[0].childNodes.length == 1 )
					{
						sValue += fld.rows[i].cells[0].innerHTML + ';';
					}
				}
			}
			return sValue;
		}
	}
	else if ( typeof fld == 'object' && fld != null )
	{
		try
		{
			if ( fld.type == 'select-one' )
			{
				for ( var i = 0; i < fld.options.length; i++ )
				{
					if ( fld.options[i].selected )
					{
						sValue = fld.options[i].text;
						break;
					}
				}
			}
			else if ( fld.type == 'checkbox' )
			{
				sValue = fld.checked;
			}
			else if ( fld.type == 'text' || fld.type == 'textarea' || fld.type == 'hidden' )
			{
				sValue = fld.value;
			}
			//else
			//	alert(sName + ' ' + fld.type + ' ' + fld.tagName);
		}
		catch(e)
		{
			alert(sName + ' Get error:' + e.message);
		}
	}
	return sValue;
}
function HelpClickButton(sModule, sLayoutView, sName)
{
	var fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_' + sName);
	if ( typeof fld == 'object' && fld != null )
	{
		try
		{
			if ( fld.type == 'submit' )
			{
				fld.click();
			}
		}
		catch(e)
		{
			alert(sName + ' Click error:' + e.message);
		}
	}
}
function HelpChangeText(sModule, sLayoutView, sName)
{
	var fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_' + sName);
	if ( fld == null && (sName == 'TEAM_NAME' || sName == 'TEAM_ID') )
	{
		fld = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_TEAM_SET_NAME_grdMain');
		if ( fld != null )
		{
			for ( var i = 1; i < fld.rows.length; i++ )
			{
				if ( fld.rows[i].cells.length > 0 )
				{
					if ( fld.rows[i].cells[0].childNodes.length > 1 )
					{
						var fldTEAM = opener.document.getElementById(fld.id + '_ctl0' + (i+1).toString() + '_' + sName);
						if ( fldTEAM != null && (fldTEAM.type == 'text' || fldTEAM.type == 'hidden') )
						{
							fldTEAM.onblur();
						}
					}
				}
			}
		}
	}
	else if ( typeof fld == 'object' && fld != null )
	{
		try
		{
			if ( fld.type == 'text' )
			{
				// 01/29/2011 Paul.  If there is a PREV_ field, then clear it before calling blur as the Change event will likely check for changes. 
				var fldPREV = opener.document.getElementById('ctl00_cntBody_ctl' + sLayoutView + '_PREV_' + sName);
				if ( fldPREV != null )
					fldPREV.value = '';
				// 01/29/2011 Paul.  SplendidCRM uses the onblur for ModulePopup and ModuleAutoComplete. 
				fld.onblur();
			}
		}
		catch(e)
		{
			alert(sName + ' Change error:' + e.message);
		}
	}
	else
	{
		alert('Could not find ' + sModule + '.' + sName + ' in ' + sLayoutView + '.');
	}
}
function HelpAddPending(sModule, sLayoutView, sName)
{
	arrPendingFields[arrPendingFields.length] = new Object();
	arrPendingFields[arrPendingFields.length-1].Module     = sModule    ;
	arrPendingFields[arrPendingFields.length-1].LayoutView = sLayoutView;
	arrPendingFields[arrPendingFields.length-1].Name       = sName      ;
}
function HelpGotoParentPage(sPage)
{
	var sNewUrl= sApplicationSiteURL + sPage;
	opener.location.href = sNewUrl;
}
function HelpGotoHelpPage(sPage)
{
	var sNewUrl= sApplicationSiteURL+ sPage;
	location.href = sNewUrl;
}

