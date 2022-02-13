/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function LayoutTerminologyUI()
{
	this.MODULE_NAME   = null;
	this.LANG          = null;
	this.LAYOUT        = null;
	this.MODULE_FIELDS = new Array();
}

LayoutTerminologyUI.prototype.PageCommand = function(sCommandName, sCommandArguments)
{
	SplendidError.SystemMessage('');
	if ( sCommandName == 'Save' )
	{
		try
		{
			var tblLayout = document.getElementById('tblLayout');
			var bgPage = chrome.extension.getBackgroundPage();
			var obj = new Object();
			obj.TERMINOLOGY = new Array();

			for ( var i = 0; i < this.LAYOUT.length; i++ )
			{
				var lay = this.LAYOUT[i];
				var spnChanged = document.getElementById('txtLayout_' + lay.NAME + '_Changed');
				// 03/14/2016 Paul.  Firefox does not support innerText. 
				if ( spnChanged != null && $(spnChanged).text() == '*' )
				{
					var txt = document.getElementById('txtLayout_' + lay.NAME);
					lay.DISPLAY_NAME = txt.value;
					obj.TERMINOLOGY.push(lay);
				}
			}
			if ( obj.TERMINOLOGY.length > 0 )
			{
				AdminLayout_Update('TERMINOLOGY', this.MODULE_NAME, obj, function(status, message)
				{
					if ( status == 1 )
					{
						for ( var i = 0; i < this.LAYOUT.length; i++ )
						{
							var lay = this.LAYOUT[i];
							var spnChanged = document.getElementById('txtLayout_' + lay.NAME + '_Changed');
							// 03/14/2016 Paul.  Firefox does not support innerText. 
							if ( spnChanged != null && $(spnChanged).text() == '*' )
							{
								$(spnChanged).text('');
							}
						}
						AdminLayoutMesasge(L10n.Term('DynamicLayout.LBL_SAVE_COMPLETE'));
					}
					else
					{
						SplendidError.SystemMessage(message);
					}
				}, this);
			}
			else
			{
				AdminLayoutMesasge(L10n.Term('DynamicLayout.LBL_NO_CHANGES'));
			}
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutTerminologyUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Cancel' )
	{
		try
		{
			AdminLayoutClear();
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutTerminologyUI.PageCommand');
		}
	}
}

LayoutTerminologyUI.prototype.LoadFromLayout = function()
{
	var tblLayout = document.getElementById('tblLayout');
	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var tr = null;
		var td = null;
		for ( var nLayoutIndex in this.LAYOUT )
		{
			var lay = this.LAYOUT[nLayoutIndex];
			tr = tblLayout.insertRow(-1);
			tr.id = 'trLayout_' + lay.NAME;
			// 02/17/2016 Paul.  Start with all rows hidden. 
			tr.style.display = 'none';
			this.BindRow(tblLayout, tr, lay);
		}
	}
	this.ShowAllChanged();
}

LayoutTerminologyUI.prototype.BindRow = function(tblLayout, tr, lay)
{
	var tdLABEL = tr.insertCell(-1);
	var tdTEXT  = tr.insertCell(-1);
	tdLABEL.width = '30%';
	tdTEXT .width = '70%';
	tdLABEL.align = 'right';
	tdLABEL.style.fontWeight = 'bold';
	$(tdLABEL).text(lay.NAME + ':');
	tr.appendChild(tdLABEL);
	tr.appendChild(tdTEXT );

	var txt  = document.createElement('textarea');
	tdTEXT.appendChild(txt);
	txt.id                 = 'txtLayout_' + lay.NAME;
	txt.style.height       = '14pt';
	txt.style.width        = '90%';
	txt.value              = lay.DISPLAY_NAME;
	// 02/17/2016 Paul.  onkeypress does not capture backspace or enter. Use onkeydown instead. 
	txt.onkeydown = function(e)
	{
		// e.key is only supported on IE.  e.keyIdentifier is only supported on Chrome. 
		// e.key == 'Backspace', e.keyCode = 8
		// e.key == 'Enter'    , e.keyCode = 13
		// e.key == 'Spacebar' , e.keyCode = 32
		// e.key == 'Del'      , e.keyCode = 46
		//alert(dumpObj(e, 'e'))
		switch ( e.keyCode )
		{
			case  12:  return;  // e.key == 'Clear'    , e.keyCode = 12
			case  16:  return;  // e.key == 'Shift'    , e.keyCode = 16
			case  17:  return;  // e.key == 'Control'  , e.keyCode = 17
			case  18:  return;  // e.key == 'Alt'      , e.keyCode = 18
			case  27:  return;  // e.key == 'Esc'      , e.keyCode = 27
			case  33:  return;  // e.key == 'PageUp'   , e.keyCode = 33
			case  34:  return;  // e.key == 'PageDown' , e.keyCode = 34
			case  35:  return;  // e.key == 'End'      , e.keyCode = 35
			case  36:  return;  // e.key == 'Home'     , e.keyCode = 36
			case  37:  return;  // e.key == 'Left'     , e.keyCode = 37
			case  38:  return;  // e.key == 'Up'       , e.keyCode = 38
			case  39:  return;  // e.key == 'Right'    , e.keyCode = 39
			case  40:  return;  // e.key == 'Down'     , e.keyCode = 40
			case  45:  return;  // e.key == 'Insert'   , e.keyCode = 45
			case 144:  return;  // e.key == 'NumLock'  , e.keyCode = 144
		}
		var spnChanged = document.getElementById(this.id + '_Changed')
		$(spnChanged).text(e.keyCode + ', ' + e.key);
		$(spnChanged).text('*');
	};
	var spnChanged = document.createElement('span');
	tdTEXT.appendChild(spnChanged);
	spnChanged.id               = txt.id + '_Changed';
	spnChanged.style.fontSize   = '20pt';
	spnChanged.style.color      = 'red';
	spnChanged.style.marginLeft = '2px';
}

LayoutTerminologyUI.prototype.LoadView = function()
{
	while ( divLayoutButtons.childNodes.length > 0 )
	{
		divLayoutButtons.removeChild(divLayoutButtons.firstChild);
	}
	
	var btnLayoutSave               = document.createElement('input');
	btnLayoutSave.id                = 'btnLayoutSave'  ;
	btnLayoutSave.type              = 'button';
	btnLayoutSave.className         = 'button';
	btnLayoutSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL');
	btnLayoutSave.style.cursor      = 'pointer';
	btnLayoutSave.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutSave  );
	btnLayoutSave.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Save', null);
	}, this.PageCommand, this);

	var btnLayoutCancel               = document.createElement('input');
	btnLayoutCancel.id                = 'btnLayoutCancel';
	btnLayoutCancel.type              = 'button';
	btnLayoutCancel.className         = 'button';
	btnLayoutCancel.value             = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
	btnLayoutCancel.style.cursor      = 'pointer';
	btnLayoutCancel.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutCancel);
	btnLayoutCancel.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Cancel', null);
	}, this.PageCommand, this);

	var spnError = document.createElement('span');
	spnError.id        = 'divLayoutButtons_Error';
	spnError.className = 'error';
	divLayoutButtons.appendChild(spnError);

	var lstShowAll = document.createElement('select');
	lstShowAll.id          = 'lstShowAll';
	lstShowAll.style.float = 'right';
	divLayoutButtons.appendChild(lstShowAll);
	var opt = null;
	if ( this.MODULE_FIELDS.length > 0 )
	{
		opt = document.createElement('option');
		opt.setAttribute('value', 'fields');
		$(opt).text(L10n.Term('DynamicLayout.LBL_FIELD_TERMS'));
		lstShowAll.appendChild(opt);
	}
	opt = document.createElement('option');
	opt.setAttribute('value', 'all');
	$(opt).text(L10n.Term('DynamicLayout.LBL_ALL_TERMS'));
	lstShowAll.appendChild(opt);
	
	lstShowAll.onchange = BindArguments(function(ShowAllChanged, context)
	{
		ShowAllChanged.call(context);
	}, this.ShowAllChanged, this);

	this.LoadFromLayout();
}

LayoutTerminologyUI.prototype.ShowAllChanged = function()
{
	var tblLayout  = document.getElementById('tblLayout');
	var lstShowAll = document.getElementById('lstShowAll');
	var sValue = lstShowAll.options[lstShowAll.options.selectedIndex].value;
	if ( sValue == 'fields' )
	{
		for ( var i = 0; i < tblLayout.rows.length; i++ )
		{
			tblLayout.rows[i].style.display = 'none';
		}
		for ( var i = 0; i < this.MODULE_FIELDS.length; i++ )
		{
			var sNAME = this.MODULE_FIELDS[i].ColumnName;
			var tr = document.getElementById('trLayout_LBL_' + sNAME);
			if ( tr != null )
				tr.style.display = '';
			tr = document.getElementById('trLayout_LBL_LIST_' + sNAME);
			if ( tr != null )
				tr.style.display = '';
		}
	}
	else
	{
		for ( var i = 0; i < tblLayout.rows.length; i++ )
		{
			tblLayout.rows[i].style.display = '';
		}
	}
}

LayoutTerminologyUI.prototype.LoadLayout = function(sMODULE_NAME, sLANG, callback, context)
{
	var xhr = null;
	if ( Sql.IsEmptyString(sMODULE_NAME) )
		xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('MODULE_NAME is null and LIST_NAME is null and LANG eq \'' + sLANG + '\''), 'GET');
	else
		xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('MODULE_NAME eq \'' + sMODULE_NAME + '\' and LANG eq \'' + sLANG + '\''), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							callback.call(context||this, 1, result.d.results);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'LayoutTerminologyUI.LoadLayout'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'LayoutTerminologyUI.LoadLayout'));
	}
}

LayoutTerminologyUI.prototype.Load = function()
{
	try
	{
		AdminLayoutClear();
		var tdLayoutFrameFieldList  = document.getElementById('tdLayoutFrameFieldList' );
		var tdLayoutFrameLayout     = document.getElementById('tdLayoutFrameLayout'    );
		tdLayoutFrameFieldList.style.display = 'none';
		tdLayoutFrameLayout.width = 550 + 230;
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 02/20/2016 Paul.  Global module will be empty. 
				if ( Sql.IsEmptyString(this.MODULE_NAME) )
				{
					this.MODULE_FIELDS = new Array();
					bgPage.Terminology_LoadModule(this.MODULE_NAME, function(status, message)
					{
						if ( status == 0 || status == 1 )
						{
							this.LoadLayout(this.MODULE_NAME, this.LANG, function(status, message)
							{
								if ( status == 1 )
								{
									this.LAYOUT = message;
									this.LoadView();
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}, this);
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					}, this);
				}
				else
				{
					// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
					// 04/12/2017 Paul.  LayoutName was not including in field list.  Send blank to use default. 
					AdminLayout_GetModuleFields(this.MODULE_NAME, 'DetailView', '', function(status, message)
					{
						if ( status == 0 || status == 1 )
						{
							this.MODULE_FIELDS = message;
							bgPage.Terminology_LoadModule(this.MODULE_NAME, function(status, message)
							{
								if ( status == 0 || status == 1 )
								{
									this.LoadLayout(this.MODULE_NAME, this.LANG, function(status, message)
									{
										if ( status == 1 )
										{
											this.LAYOUT = message;
											this.LoadView();
										}
										else
										{
											SplendidError.SystemMessage(message);
										}
									}, this);
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							}, this);
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					}, this);
				}
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutTerminologyUI.Load');
	}
}

