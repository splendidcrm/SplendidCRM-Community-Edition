/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function LayoutDetailViewUI()
{
	this.MODULE_NAME        = null;
	this.DETAIL_NAME        = null;
	this.LAYOUT             = null;
	this.DATA_COLUMNS       = 2;
	// 05/04/2016 Paul.  DETAILVIEWS fields to allow for layout copy. 
	this.VIEW_NAME          = '';
	this.LABEL_WIDTH        = '15%';
	this.FIELD_WIDTH        = '35%';
	this.EVENTS             = null;
	this.MODULE_FIELDS      = new Array();
	this.MODULE_TERMINOLOGY = new Array();
	this.divSelectedLayoutField = null;

	this.FIELD_TYPES = new Array();
	this.FIELD_TYPES.push("String"    );
	this.FIELD_TYPES.push("TextBox"   );
	this.FIELD_TYPES.push("HyperLink" );
	this.FIELD_TYPES.push("ModuleLink");
	this.FIELD_TYPES.push("CheckBox"  );
	this.FIELD_TYPES.push("Button"    );
	this.FIELD_TYPES.push("Image"     );
	// 05/27/2016 Paul.  File type should have been added in 2010 when first supported. 
	this.FIELD_TYPES.push("File"      );
	this.FIELD_TYPES.push("Blank"     );
	this.FIELD_TYPES.push("Line"      );
	this.FIELD_TYPES.push("IFrame"    );
	this.FIELD_TYPES.push("JavaScript");
	// 02/13/2016 Paul.  We are not going to allow a field to be changed to any of these special fields. 
	//this.FIELD_TYPES.push("Separator"          );
	// 02/14/2016 Paul.  Seems safe to allow to change to a header. 
	this.FIELD_TYPES.push("Header"    );
	// 05/14/2016 Paul.  Add Tags module. 
	this.FIELD_TYPES.push("Tags"      );
	this.COLSPANS = new Array();
}

LayoutDetailViewUI.prototype.UpdateLayout = function(message)
{
	this.LAYOUT = message;
	this.DATA_COLUMNS = 2;
	// 05/04/2016 Paul.  DETAILVIEWS fields to allow for layout copy. 
	this.VIEW_NAME    = '';
	this.LABEL_WIDTH  = '15%';
	this.FIELD_WIDTH  = '35%';
	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var lay = this.LAYOUT[0];
		this.DATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
		this.VIEW_NAME    = Sql.ToString (lay.VIEW_NAME   );
		this.LABEL_WIDTH  = Sql.ToString (lay.LABEL_WIDTH );
		this.FIELD_WIDTH  = Sql.ToString (lay.FIELD_WIDTH );
	}
	if ( Sql.ToInteger(this.DATA_COLUMNS) == 0 ) this.DATA_COLUMNS = 2;
	if ( Sql.IsEmptyString(this.VIEW_NAME    ) ) this.VIEW_NAME    = 'vw' + this.MODULE_NAME.toUpperCase();
	if ( Sql.IsEmptyString(this.LABEL_WIDTH  ) ) this.LABEL_WIDTH  = '15%';
	if ( Sql.IsEmptyString(this.FIELD_WIDTH  ) ) this.FIELD_WIDTH  = '35%';
	
	this.COLSPANS = new Array();
	this.COLSPANS.push(0);
	for ( var i = 1; i < this.DATA_COLUMNS; i++ )
	{
		this.COLSPANS.push(2 * i + 1);
	}
	this.COLSPANS.push(-1);
}

LayoutDetailViewUI.prototype.AllowDeleteLayout = function()
{
	var bAllowDelete = true;
	if      ( this.DETAIL_NAME == 'TabMenu'                   ) bAllowDelete = false;
	else if ( StartsWith(this.DETAIL_NAME, 'Users.') && EndsWith(this.DETAIL_NAME, 'Options') ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.DetailView'      ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.DetailView.Body' ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.DetailView.Left' ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.DetailView.Right') ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.SummaryView'     ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Preview'         ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.MailMerge'       ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Portal'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Mobile'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Template'        ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.PhoneSearch'     ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.UnifiedSearch'   ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Dashboard'       ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.ProductCatalog'  ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.ListView'        ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.RoiDetailView'   ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.OfficeAddin'     ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Gmail'           ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.iCloud'          ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.QuickBooks'      ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.QuickBooksOnline') ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.HubSpot'         ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.Marketo'         ) ) bAllowDelete = false;
	else if ( EndsWith(this.DETAIL_NAME, '.MailChimp'       ) ) bAllowDelete = false;
	return bAllowDelete;
}

LayoutDetailViewUI.prototype.PageCommand = function(sCommandName, sCommandArguments)
{
	SplendidError.SystemMessage('');
	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	if ( sCommandName == 'Copy' )
	{
		var txtCopyLayout    = document.getElementById('txtCopyLayout'   );
		var btnRoleSelect    = document.getElementById('btnRoleSelect'   );
		var btnDeleteLayout  = document.getElementById('btnDeleteLayout' );
		var btnLayoutRestore = document.getElementById('btnLayoutRestore');
		var btnLayoutExport  = document.getElementById('btnLayoutExport' );
		if ( txtCopyLayout.style.display == 'none' )
		{
			txtCopyLayout.LAYOUT_NAME      = this.DETAIL_NAME;
			txtCopyLayout.value            = this.DETAIL_NAME + '.Copy';
			txtCopyLayout.style.display    = 'inline';
			btnRoleSelect.style.display    = 'inline';
			btnDeleteLayout.style.display  = 'none'  ;
			btnLayoutRestore.style.display = 'none'  ;
			btnLayoutExport.style.display  = 'none'  ;
		}
		else
		{
			txtCopyLayout.value            = '';
			txtCopyLayout.style.display    = 'none'  ;
			btnRoleSelect.style.display    = 'none'  ;
			btnDeleteLayout.style.display  = (this.AllowDeleteLayout() ? 'inline' : 'none');
			btnLayoutRestore.style.display = 'inline';
			btnLayoutExport.style.display  = 'inline';
		}
	}
	else if ( sCommandName == 'Delete' )
	{
		try
		{
			var obj = new Object();
			AdminLayout_Delete('DETAILVIEWS_FIELDS', this.DETAIL_NAME, obj, function(status, message)
			{
				if ( status == 1 )
				{
					AdminLayoutDeleteView(this.MODULE_NAME, this.DETAIL_NAME);
					AdminLayoutClear();
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutListViewUI.PageCommand');
		}
	}
	else if ( sCommandName == 'Save' )
	{
		try
		{
			var tblLayout = document.getElementById('tblLayout');
			var bgPage = chrome.extension.getBackgroundPage();
			var obj = new Object();
			obj.DETAILVIEWS                     = new Object();
			// 05/04/2016 Paul.  EDITVIEWS fields to allow for layout copy. 
			obj.DETAILVIEWS.MODULE_NAME         = this.MODULE_NAME ;
			obj.DETAILVIEWS.VIEW_NAME           = this.VIEW_NAME   ;
			obj.DETAILVIEWS.LABEL_WIDTH         = this.LABEL_WIDTH ;
			obj.DETAILVIEWS.FIELD_WIDTH         = this.FIELD_WIDTH ;
			obj.DETAILVIEWS.DATA_COLUMNS        = this.DATA_COLUMNS;
			obj.DETAILVIEWS.PRE_LOAD_EVENT_ID   = document.getElementById('tblEvents_PRE_LOAD_EVENT_ID'  ).value;
			obj.DETAILVIEWS.POST_LOAD_EVENT_ID  = document.getElementById('tblEvents_POST_LOAD_EVENT_ID' ).value;
			obj.DETAILVIEWS.SCRIPT              = document.getElementById('tblEvents_SCRIPT'             ).value;
			obj.DETAILVIEWS_FIELDS = new Array();
			for ( var i = 0; i < tblLayout.rows.length; i++ )
			{
				var tr = tblLayout.rows[i];
				for ( var j = 0; j < tr.cells.length; j++ )
				{
					var td = tr.cells[j];
					for ( var k = 0; k < td.childNodes.length; k++ )
					{
						var div = td.childNodes[k];
						var lay = this.CreateLayoutObject(div);
						if ( !Sql.IsEmptyString(lay.FIELD_TYPE) )
						{
							lay.FIELD_INDEX = obj.DETAILVIEWS_FIELDS.length;
							obj.DETAILVIEWS_FIELDS.push(lay);
						}
					}
				}
			}
			// 05/04/2016 Paul.  Provide a way to save a layout copy. 
			var sVIEW_NAME = this.DETAIL_NAME;
			var txtCopyLayout = document.getElementById('txtCopyLayout');
			if ( txtCopyLayout.style.display == 'inline' )
			{
				txtCopyLayout.value = Trim(txtCopyLayout.value);
				if ( Sql.IsEmptyString(txtCopyLayout.value) || txtCopyLayout.value == sVIEW_NAME )
				{
					AdminLayoutMesasge(L10n.Term('DynamicLayout.ERR_NEW_LAYOUT_NAME'));
					return;
				}
				else
				{
					sVIEW_NAME = txtCopyLayout.value;
				}
			}
			AdminLayout_Update('DETAILVIEWS_FIELDS', sVIEW_NAME, obj, function(status, message)
			{
				if ( status == 1 )
				{
					// 05/04/2016 Paul.  Update view and hide copy on success. 
					if ( txtCopyLayout.style.display == 'inline' )
					{
						this.DETAIL_NAME = sVIEW_NAME;
						this.PageCommand('Copy', null);
						AdminLayoutAddView(this.MODULE_NAME, this.DETAIL_NAME, 'DetailView');
					}
					AdminLayoutMesasge(L10n.Term('DynamicLayout.LBL_SAVE_COMPLETE'));
					this.Reload(false);
				}
				else
				{
					SplendidError.SystemMessage(message);
				}
			}, this);
		}
		catch(e)
		{
			SplendidError.SystemError(e, 'LayoutDetailViewUI.PageCommand');
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
			SplendidError.SystemError(e, 'LayoutDetailViewUI.PageCommand');
		}
	}
}

LayoutDetailViewUI.prototype.AddProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	var spn = document.createElement('span');
	spn.id = 'tblProperties_' + sFieldName;
	$(spn).text(sFieldValue);
	tdField.appendChild(spn);
}

LayoutDetailViewUI.prototype.AddTextBoxProperty = function(tblProperties, sFieldName, sFieldValue, sWidth)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.id = 'tblProperties_' + sFieldName + '_LABEL';
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('input');
	txt.id    = 'tblProperties_' + sFieldName;
	txt.type  = 'text';
	txt.style.width = (sWidth === undefined ? '200px' : sWidth);
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

LayoutDetailViewUI.prototype.AddTextAreaProperty = function(tblProperties, sFieldName, sFieldValue)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var txt = document.createElement('textarea');
	txt.id           = 'tblProperties_' + sFieldName;
	txt.style.width  = '95%';
	txt.rows         = 3;
	txt.value = sFieldValue;
	tdField.appendChild(txt);
}

LayoutDetailViewUI.prototype.AddListBoxProperty = function(tblProperties, sFieldName, sFieldValue, sListName, bAllowNone)
{
	var tr = null;
	var tdLabel = null;
	var tdField = null;
	tr = tblProperties.insertRow(-1);
	tr.id = 'tblProperties_tr' + sFieldName;
	tdLabel = tr.insertCell(-1);
	tdField = tr.insertCell(-1);
	tdLabel.style.width = '35%';
	$(tdLabel).text(L10n.Term('DynamicLayout.LBL_' + sFieldName));
	//$(tdField).text(sFieldValue);
	var lst = document.createElement('select');
	lst.id      = 'tblProperties_' + sFieldName;
	tdField.appendChild(lst);
	// 04/10/2016 Paul.  Add item to list if not found. 
	var bFound = false;
	if ( sListName instanceof Array )
	{
		var arrLIST = sListName;
		var opt = document.createElement('option');
		if ( bAllowNone )
			lst.appendChild(opt);
		for ( var i = 0; i < arrLIST.length; i++ )
		{
			opt = document.createElement('option');
			lst.appendChild(opt);
			opt.setAttribute('value', arrLIST[i]);
			$(opt).text(arrLIST[i]);
			if ( sFieldValue != null && sFieldValue == arrLIST[i] )
			{
				opt.setAttribute('selected', 'selected');
				bFound = true;
			}
		}
	}
	else if ( typeof(sListName) == 'string' )
	{
		var arrLIST = L10n.GetList(sListName);
		if ( arrLIST != null && arrLIST instanceof Array )
		{
			var opt = document.createElement('option');
			if ( bAllowNone )
				lst.appendChild(opt);
			for ( var i = 0; i < arrLIST.length; i++ )
			{
				opt = document.createElement('option');
				lst.appendChild(opt);
				opt.setAttribute('value', arrLIST[i]);
				opt.innerHTML = L10n.ListTerm(sListName, arrLIST[i]);
				if ( sFieldValue != null && sFieldValue == arrLIST[i] )
				{
					opt.setAttribute('selected', 'selected');
					bFound = true;
				}
			}
		}
	}
	// 04/10/2016 Paul.  Add item to list if not found. 
	if ( !bFound && sFieldValue != null )
	{
		var opt = document.createElement('option');
		lst.appendChild(opt);
		opt.setAttribute('value', sFieldValue);
		opt.innerHTML = sFieldValue;
		opt.setAttribute('selected', 'selected');
	}
}

LayoutDetailViewUI.prototype.ShowProperty = function(sFieldName, bVisible)
{
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		tr.style.display = (bVisible ? 'table-row' : 'none');
}

LayoutDetailViewUI.prototype.GetPropertyVisibility = function(sFieldName)
{
	var bVisible = false;
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		bVisible = (tr.style.display != 'none');
	return bVisible;
}

LayoutDetailViewUI.prototype.GetPropertyValue = function(sFieldName)
{
	var sValue = '';
	if ( this.GetPropertyVisibility(sFieldName) )
	{
		var fld = document.getElementById('tblProperties_' + sFieldName);
		if ( fld != null )
		{
			var sTagName = fld.tagName.toLowerCase();
			if ( sTagName == 'input' )
			{
				if ( fld.type == 'checkbox' )
				{
					sValue = fld.checked.toString();
				}
				else
				{
					sValue = fld.value;
				}
			}
			else if ( sTagName == 'textarea' )
			{
				sValue = fld.value;
			}
			else if ( sTagName == 'span' )
			{
				// 03/14/2016 Paul.  Firefox does not support innerText. 
				sValue = $(fld).text();
			}
			else if ( sTagName == 'select' )
			{
				sValue = fld.options[fld.options.selectedIndex].value;
			}
		}
	}
	return sValue;
}

LayoutDetailViewUI.prototype.SaveProperties = function()
{
	if ( this.divSelectedLayoutField != null )
	{
//debugger;
		var obj = new Object();
		obj.FIELD_TYPE                 = this.GetPropertyValue('FIELD_TYPE'                );
		obj.DATA_LABEL                 = this.GetPropertyValue('DATA_LABEL'                );
		// 02/09/2016 Paul.  The Data Field is a read-only property. 
		//obj.DATA_FIELD                 = this.GetPropertyValue('DATA_FIELD'                );
		obj.DATA_FIELD                 = this.divSelectedLayoutField.DATA_FIELD;
		obj.DATA_FORMAT                = this.GetPropertyValue('DATA_FORMAT'               );
		obj.URL_FIELD                  = this.GetPropertyValue('URL_FIELD'                 );
		obj.URL_FORMAT                 = this.GetPropertyValue('URL_FORMAT'                );
		obj.URL_TARGET                 = this.GetPropertyValue('URL_TARGET'                );
		obj.LIST_NAME                  = this.GetPropertyValue('LIST_NAME'                 );
		obj.COLSPAN                    = this.GetPropertyValue('COLSPAN'                   );
		obj.TOOL_TIP                   = this.GetPropertyValue('TOOL_TIP'                  );
		obj.MODULE_TYPE                = this.GetPropertyValue('MODULE_TYPE'               );
		obj.PARENT_FIELD               = this.GetPropertyValue('PARENT_FIELD'              );
		// 05/30/2017 Paul.  We need to manually set the label for TeamSelect and TagSelect as they are not visible. 
		if ( obj.FIELD_TYPE == 'TeamSelect' )
		{
			obj.DATA_LABEL = '.LBL_TEAM_SET_NAME';
		}
		// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		else if ( obj.FIELD_TYPE == 'UserSelect' )
		{
			obj.DATA_LABEL = '.LBL_ASSIGNED_SET_NAME';
		}
		else if ( obj.FIELD_TYPE == 'TagSelect' )
		{
			obj.DATA_LABEL = '.LBL_TAG_SET_NAME';
		}
		// 06/07/2017 Paul.  Add NAICSCodes module. 
		else if ( obj.FIELD_TYPE == 'NAICSCodeSelect' )
		{
			obj.DATA_LABEL = 'NAICSCodes.LBL_NAICS_SET_NAME';
		}
		
		var sOLD_COLSPAN    = this.divSelectedLayoutField.COLSPAN   ;
		var sOLD_FIELD_TYPE = this.divSelectedLayoutField.FIELD_TYPE;
		this.SetLayoutObject(this.divSelectedLayoutField, obj);
		
		if ( obj.COLSPAN != sOLD_COLSPAN || obj.FIELD_TYPE != sOLD_FIELD_TYPE )
		{
			var NEW_LAYOUT = new Array();
			var tblLayout = document.getElementById('tblLayout');
			for ( var i = 0; i < tblLayout.rows.length; i++ )
			{
				var tr = tblLayout.rows[i];
				for ( var j = 0; j < tr.cells.length; j++ )
				{
					var td = tr.cells[j];
					for ( var k = 0; k < td.childNodes.length; k++ )
					{
						var div = td.childNodes[k];
						var lay = this.CreateLayoutObject(div);
						if ( !Sql.IsEmptyString(lay.FIELD_TYPE) )
						{
							lay.FIELD_INDEX = NEW_LAYOUT.length;
							NEW_LAYOUT.push(lay);
						}
					}
				}
			}
			this.LAYOUT = NEW_LAYOUT;
			this.LoadFromLayout();
		}
	}
	this.CancelProperties();
	return false;
}

LayoutDetailViewUI.prototype.CancelProperties = function()
{
	this.divSelectedLayoutField = null;
	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	divPropertiesButtons.style.display = 'none';
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}

	var tblProperties = document.getElementById('tblProperties');
	if ( tblProperties.rows != null )
	{
		while ( tblProperties.rows.length > 0 )
		{
			tblProperties.deleteRow(0);
		}
	}
	return false;
}

LayoutDetailViewUI.prototype.LoadProperties = function(divLayoutField)
{
	this.divSelectedLayoutField = divLayoutField;

	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	divPropertiesButtons.style.display = 'block';
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}

	var btnPropertiesSave   = document.createElement('input');
	btnPropertiesSave.id                = 'btnPropertiesSave';
	btnPropertiesSave.type              = 'button';
	btnPropertiesSave.className         = 'button';
	btnPropertiesSave.value             = L10n.Term('.LBL_SAVE_BUTTON_LABEL'  );
	btnPropertiesSave.style.cursor      = 'pointer';
	btnPropertiesSave.style.marginRight = '3px';
	divPropertiesButtons.appendChild(btnPropertiesSave  );
	btnPropertiesSave.onclick     = BindArguments(function(context)
	{
		context.SaveProperties();
	}, this);

	var btnPropertiesCancel = document.createElement('input');
	divPropertiesButtons.appendChild(btnPropertiesCancel);
	btnPropertiesCancel.id                = 'btnPropertiesCancel';
	btnPropertiesCancel.type              = 'button';
	btnPropertiesCancel.className         = 'button';
	btnPropertiesCancel.value             = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
	btnPropertiesCancel.style.cursor      = 'pointer';
	btnPropertiesCancel.style.marginRight = '3px';
	btnPropertiesCancel.onclick   = BindArguments(function(context)
	{
		context.CancelProperties();
	}, this);

	var tblProperties = document.getElementById('tblProperties');
	if ( tblProperties.rows != null )
	{
		while ( tblProperties.rows.length > 0 )
		{
			tblProperties.deleteRow(0);
		}
	}
	// 02/25/2016 Paul.  DATA_FIELD and DATA_FORMAT should be text area. 
	this.AddListBoxProperty (tblProperties, "FIELD_TYPE"                , Sql.ToString (divLayoutField.FIELD_TYPE                ), this.FIELD_TYPES       , false);
	this.AddListBoxProperty (tblProperties, "DATA_LABEL"                , Sql.ToString (divLayoutField.DATA_LABEL                ), this.MODULE_TERMINOLOGY, true );
	this.AddTextAreaProperty(tblProperties, "DATA_FIELD"                , Sql.ToString (divLayoutField.DATA_FIELD                ));
	this.AddTextAreaProperty(tblProperties, "DATA_FORMAT"               , Sql.ToString (divLayoutField.DATA_FORMAT               ));
	this.AddTextAreaProperty(tblProperties, "URL_FIELD"                 , Sql.ToString (divLayoutField.URL_FIELD                 ));
	this.AddTextAreaProperty(tblProperties, "URL_FORMAT"                , Sql.ToString (divLayoutField.URL_FORMAT                ));
	this.AddTextBoxProperty (tblProperties, "URL_TARGET"                , Sql.ToString (divLayoutField.URL_TARGET                ));
	this.AddListBoxProperty (tblProperties, "MODULE_TYPE"               , Sql.ToString (divLayoutField.MODULE_TYPE               ), TERMINOLOGY_LISTS['MODULE_TYPES'], true );
	this.AddListBoxProperty (tblProperties, "LIST_NAME"                 , Sql.ToString (divLayoutField.LIST_NAME                 ), TERMINOLOGY_LISTS['vwTERMINOLOGY_PickList'], true );
	this.AddListBoxProperty (tblProperties, "COLSPAN"                   , Sql.ToInteger(divLayoutField.COLSPAN                   ), this.COLSPANS          , false);
	this.AddTextBoxProperty (tblProperties, "TOOL_TIP"                  , Sql.ToString (divLayoutField.TOOL_TIP                  ));
	this.AddTextBoxProperty (tblProperties, "PARENT_FIELD"              , Sql.ToString (divLayoutField.PARENT_FIELD              ));
	var lstFIELD_TYPE = document.getElementById('tblProperties_FIELD_TYPE');
	lstFIELD_TYPE.onchange = BindArguments(function(context)
	{
		context.FieldTypeChanged();
	}, this);
	this.FieldTypeChanged();
}

LayoutDetailViewUI.prototype.FieldTypeChanged = function()
{
	var lstFIELD_TYPE = document.getElementById('tblProperties_FIELD_TYPE');
	var sFIELD_TYPE = lstFIELD_TYPE.options[lstFIELD_TYPE.options.selectedIndex].value;
	switch ( sFIELD_TYPE )
	{
		// 08/02/2010 Paul.  Show the URL fields for a string so that we can add a LinkedIn icon. 
		// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
		// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
		case "String"    :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', true );  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', true );  this.ShowProperty('PARENT_FIELD', true );  break;
		// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
		case "ModuleLink":  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', true );  this.ShowProperty('PARENT_FIELD', false);  break;
		case "TextBox"   :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 05/14/2016 Paul.  Add Tags module. 
		case "Tags"      :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 04/20/2012 Paul.  Show the Module Type for a HyperLink. 
		case "HyperLink" :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', true );  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', true );  this.ShowProperty('PARENT_FIELD', false);  break;
		case "CheckBox"  :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		case "Button"    :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 02/22/2022 Paul.  Allow image to be formatted. 
		case "Image"     :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 05/27/2016 Paul.  File type should have been added in 2010 when first supported. 
		case "File"      :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		case "Blank"     :  this.ShowProperty('DATA_LABEL', false);  this.ShowProperty('DATA_FIELD', false);  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', false);  this.ShowProperty('TOOL_TIP', false);  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		case "Line"      :  this.ShowProperty('DATA_LABEL', false);  this.ShowProperty('DATA_FIELD', false);  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', false);  this.ShowProperty('TOOL_TIP', false);  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		case "IFrame"    :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', true );  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', true );  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
		case "JavaScript":  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', true );  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', false);  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		// 09/02/2012 Paul.  A separator is just like a blank. 
		// 09/16/2012 Paul.  The data field can be used as the table id. 
		// 09/20/2012 Paul.  Data Format will store initial visibility state. 
		case "Separator" :  this.ShowProperty('DATA_LABEL', false);  this.ShowProperty('DATA_FIELD', true );  this.ShowProperty('DATA_FORMAT', true );  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', false);  this.ShowProperty('TOOL_TIP', false);  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
		case "Header"    :  this.ShowProperty('DATA_LABEL', true );  this.ShowProperty('DATA_FIELD', false);  this.ShowProperty('DATA_FORMAT', false);  this.ShowProperty('URL_FIELD', false);  this.ShowProperty('URL_FORMAT', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('URL_TARGET', this.GetPropertyVisibility('URL_FIELD'));  this.ShowProperty('LIST_NAME', false);  this.ShowProperty('COLSPAN', true );  this.ShowProperty('TOOL_TIP', false);  this.ShowProperty('MODULE_TYPE', false);  this.ShowProperty('PARENT_FIELD', false);  break;
	}
	// 08/02/2010 Paul.  Not sure why, but there are times when we set the Visible flag to true, but it rejects the setting and stays false. 
	//trDATA_FIELD.Visible = trDATA_LABEL.Visible;
	// 09/12/2009 Paul.  Set default format. 
	if ( sFIELD_TYPE == "String" && Sql.IsEmptyString(this.GetPropertyValue('DATA_FORMAT')) )
	{
		var txtDATA_FORMAT = document.getElementById('tblProperties_DATA_FORMAT');
		txtDATA_FORMAT.value = '{0}';
	}
	var lblURL_TARGET = document.getElementById('tblProperties_URL_TARGET_LABEL');
	var txtURL_TARGET = document.getElementById('tblProperties_URL_TARGET');
	if ( sFIELD_TYPE == 'IFrame' )
	{
		$(lblURL_TARGET).text(L10n.Term('DynamicLayout.LBL_IFRAME_HEIGHT'));
		// 06/16/2010 Paul.  Set the default height to 200. 
		if ( Sql.ToInteger(txtURL_TARGET.value) == 0 )
			txtURL_TARGET.value = '200';
	}
	else
	{
		txtURL_TARGET.value = L10n.Term('DynamicLayout.LBL_URL_TARGET');
		// 08/02/2010 Paul.  Don't clear the target.  It is also being used by JavaScript. 
		//txtURL_TARGET.Text = "";
	}
}

LayoutDetailViewUI.prototype.LoadFromLayout = function()
{
	var divFieldList = document.getElementById('divFieldList');
	var tblLayout = document.getElementById('tblLayout');
	while ( tblLayout.rows.length > 0 )
	{
		tblLayout.deleteRow(0);
	}

	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var tr = null;
		var td = null;
		var nColIndex = 0;
		for ( var nLayoutIndex in this.LAYOUT )
		{
			var lay = this.LAYOUT[nLayoutIndex];
			var sFIELD_TYPE   = Sql.ToString (lay.FIELD_TYPE  );
			var nCOLSPAN      = Sql.ToInteger(lay.COLSPAN     );

			if ( sFIELD_TYPE == 'Separator' )
			{
				if ( nColIndex > 0 )
				{
					// 02/11/2016 Paul.  Separator always starts on new row, but we need to pad end of previous row. 
					while ( nColIndex < this.DATA_COLUMNS )
					{
						td = tr.insertCell(-1);
						this.BindColumn(tblLayout, td, null);
						nColIndex++;
					}
				}
				tr = tblLayout.insertRow(-1);
				this.BindRow(tblLayout, tr);
				td = tr.insertCell(0);
				td.colSpan = this.DATA_COLUMNS;
				this.BindColumn(tblLayout, td, lay);
				nColIndex = 0;
				tr = null;
				continue;
			}
			else if ( sFIELD_TYPE == 'Hidden' || sFIELD_TYPE == 'JavaScript' )
			{
				nCOLSPAN = -1;
			}
			if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null )
			{
				tr = tblLayout.insertRow(-1);
				this.BindRow(tblLayout, tr, lay);
			}
			if ( sFIELD_TYPE == 'Blank' )
			{
				td = tr.insertCell(-1);
				this.BindColumn(tblLayout, td, lay);
			}
			else if ( sFIELD_TYPE == 'Header' )
			{
				td = tr.insertCell(-1);
				this.BindColumn(tblLayout, td, lay);
			}
			else
			{
				if ( nCOLSPAN == -1 )
				{
					if ( tr.cells.length > 0 )
					{
						td = tr.cells[tr.cells.length - 1];
					}
					else
					{
						td = tr.insertCell(-1);
					}
				}
				else
				{
					td = tr.insertCell(-1);
				}
				this.BindColumn(tblLayout, td, lay);
				if ( nCOLSPAN == -1 && td.childNodes.length > 1 )
				{
					for ( var i = 0; i < td.childNodes.length; i++ )
					{
						var div = td.childNodes[i];
						div.style.width = (nFieldListWidth / 2).toString() + 'px';
						div.style.display = 'inline-block';
					}
				}
			}
			if ( nCOLSPAN > 0 )
				nColIndex += nCOLSPAN;
			else if ( nCOLSPAN == 0 )
				nColIndex++;
			if ( nColIndex >= this.DATA_COLUMNS )
				nColIndex = 0;
		}
		// 02/11/2016 Paul.  We need to pad the final row, otherwise user will not be able to drop on final cell. 
		if ( nColIndex > 0 )
		{
			while ( nColIndex < this.DATA_COLUMNS )
			{
				td = tr.insertCell(-1);
				this.BindColumn(tblLayout, td, null);
				nColIndex++;
			}
		}
	}
	// 05/16/2017 Paul.  If the list is empty, then add a blank row. 
	else
	{
		var tr = tblLayout.insertRow(-1);
		this.BindRow(tblLayout, tr);

		for ( var i = 0; i < this.DATA_COLUMNS; i++ )
		{
			var td = tr.insertCell(i);
			this.BindColumn(tblLayout, td, null);
		}
	}
}

LayoutDetailViewUI.prototype.CreateLayoutObject = function(src)
{
	var obj = new Object();
	obj.FIELD_TYPE                 = Sql.ToString (src.FIELD_TYPE                );
	obj.DATA_LABEL                 = Sql.ToString (src.DATA_LABEL                );
	obj.DATA_FIELD                 = Sql.ToString (src.DATA_FIELD                );
	obj.DATA_FORMAT                = Sql.ToString (src.DATA_FORMAT               );
	obj.URL_FIELD                  = Sql.ToString (src.URL_FIELD                 );
	obj.URL_FORMAT                 = Sql.ToString (src.URL_FORMAT                );
	obj.URL_TARGET                 = Sql.ToString (src.URL_TARGET                );
	obj.LIST_NAME                  = Sql.ToString (src.LIST_NAME                 );
	// 04/06/2016 Paul.  We don't store zero in these fields as that means use default behavior. 
	obj.COLSPAN                    = (Sql.ToInteger(src.COLSPAN) >= -1 ? Sql.ToInteger(src.COLSPAN) : '');
	obj.TOOL_TIP                   = Sql.ToString (src.TOOL_TIP                  );
	obj.MODULE_TYPE                = Sql.ToString (src.MODULE_TYPE               );
	obj.PARENT_FIELD               = Sql.ToString (src.PARENT_FIELD              );
	return obj;
}

LayoutDetailViewUI.prototype.RenderField = function(div)
{
	while ( div.childNodes.length > 0 )
	{
		div.removeChild(div.firstChild);
	}
	
	var divDATA_FIELD = document.createElement('div');
	var divDATA_LABEL = document.createElement('div');
	div.appendChild(divDATA_FIELD);
	div.appendChild(divDATA_LABEL);
	if ( div.FIELD_TYPE == 'Header' )
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_HEADER_TYPE'));
	else
		$(divDATA_FIELD).text(div.DATA_FIELD);
	$(divDATA_LABEL).text(L10n.Term(div.DATA_LABEL));
	if ( Sql.IsEmptyString(div.DATA_LABEL) )
	{
		var nbsp = String.fromCharCode(160);
		$(divDATA_LABEL).text(nbsp);
	}
	// 03/13/2016 Paul.  Display the list name to make it easier to confirm the change. 
	if ( !Sql.IsEmptyString(div.LIST_NAME) )
	{
		var nbsp = String.fromCharCode(160);
		$(divDATA_LABEL).text($(divDATA_LABEL).text() + nbsp + div.LIST_NAME);
	}
	// 03/13/2016 Paul.  Display the module type to make it easier to confirm the change. 
	if ( !Sql.IsEmptyString(div.MODULE_TYPE) )
	{
		var nbsp = String.fromCharCode(160);
		$(divDATA_LABEL).text($(divDATA_LABEL).text() + nbsp + div.MODULE_TYPE);
	}
	// 04/06/2016 Paul.  Blank field should not have edit icon. 
	if (div.FIELD_TYPE == 'Blank')
	{
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BLANK_TYPE'));
		$(divDATA_LABEL).text(String.fromCharCode(160));
	}
	else
	{
		var imgEdit = document.createElement('img');
		// https://css-tricks.com/all-about-floats/
		imgEdit.style.cursor  = 'pointer';
		imgEdit.style.float   = 'right';
		imgEdit.style.display = 'inline';
		imgEdit.style.padding = '0px';
		imgEdit.style.margin  = '0px';
		imgEdit.src           = sREMOTE_SERVER + 'App_Themes/Six/images/edit_inline.gif';
		divDATA_FIELD.appendChild(imgEdit);
		imgEdit.onclick = BindArguments(function(context)
		{
			context.LoadProperties(div);
		}, this);
	}
}

LayoutDetailViewUI.prototype.SetLayoutObject = function(div, src)
{
	div.FIELD_TYPE                 = Sql.ToString (src.FIELD_TYPE                );
	div.DATA_LABEL                 = Sql.ToString (src.DATA_LABEL                );
	div.DATA_FIELD                 = Sql.ToString (src.DATA_FIELD                );
	div.DATA_FORMAT                = Sql.ToString (src.DATA_FORMAT               );
	div.URL_FIELD                  = Sql.ToString (src.URL_FIELD                 );
	div.URL_FORMAT                 = Sql.ToString (src.URL_FORMAT                );
	div.URL_TARGET                 = Sql.ToString (src.URL_TARGET                );
	div.LIST_NAME                  = Sql.ToString (src.LIST_NAME                 );
	div.COLSPAN                    = Sql.ToInteger(src.COLSPAN                   );
	div.TOOL_TIP                   = Sql.ToString (src.TOOL_TIP                  );
	div.MODULE_TYPE                = Sql.ToString (src.MODULE_TYPE               );
	div.PARENT_FIELD               = Sql.ToString (src.PARENT_FIELD              );
	this.RenderField(div);
}

LayoutDetailViewUI.prototype.LayoutAddField = function(jDropTarget, jDragged)
{
	//alert(jDropTarget    instanceof jQuery);
	//alert(jDragged instanceof jQuery);
	//alert(jDropTarget   .attr('data-id-group'))
	//alert(jDragged.attr('data-id-group'))
	if ( jDragged.attr('data-id-group') == 'FieldList' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' && jDropTarget[0].childNodes.length > 0 )
		{
			var jExistingField = $(jDropTarget[0].childNodes[0]);
			if ( jExistingField.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jExistingField.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
			// 04/24/2016 Paul.  Set default format value. 
			div.DATA_FORMAT = '{0}';
		}
		else if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
		{
			if ( jDropTarget.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jDropTarget.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			jDragged[0].style.display = 'none';
			
			var lay = this.CreateLayoutObject(jDragged[0]);
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
			// 04/24/2016 Paul.  Set default format value. 
			div.DATA_FORMAT = '{0}';
		}
	}
	else if ( jDragged.attr('data-id-group') == 'LayoutField' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutCell' && jDropTarget[0].childNodes.length > 0 )
		{
		}
		else if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
		{
			if ( jDragged[0] != jDropTarget[0] )
			{
				//console.log('Swap two layout fields');
				var objDragged    = this.CreateLayoutObject(jDragged[0]);
				var objDropTarget = this.CreateLayoutObject(jDropTarget[0]);
				var lay = objDragged;
				var div = jDropTarget[0];
				this.SetLayoutObject(div, lay);
				
				lay = objDropTarget;
				div = jDragged[0];
				this.SetLayoutObject(div, lay);
			}
		}
	}
	else if ( jDragged.attr('data-id-group') == 'NewHeader' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
		{
			if ( jDropTarget.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jDropTarget.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			var lay = this.CreateLayoutObject(jDragged[0]);
			lay.FIELD_TYPE   = 'Header';
			var div = jDropTarget[0];
			this.SetLayoutObject(div, lay);
		}
	}
	else if ( jDragged.attr('data-id-group') == 'NewBlank' )
	{
		if ( jDropTarget.attr('data-id-group') == 'LayoutField' )
		{
			if ( jDropTarget.prop('DATA_FIELD') != '' )
			{
				var divField = document.getElementById('divFieldList_' + jDropTarget.prop('DATA_FIELD'));
				if ( divField != null )
					divField.style.display = 'block';
			}
			var div = jDropTarget[0];
			while ( div.childNodes.length > 0 )
			{
				div.removeChild(div.firstChild);
			}
			var divDATA_FIELD = document.createElement('div');
			var divDATA_LABEL = document.createElement('div');
			div.appendChild(divDATA_FIELD);
			div.appendChild(divDATA_LABEL);
			$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BLANK_TYPE'));
			$(divDATA_LABEL).text(String.fromCharCode(160));
		}
	}
}

LayoutDetailViewUI.prototype.LayoutRemoveField = function(jDragged)
{
	if ( jDragged.attr('data-id-group') == 'LayoutField' )
	{
		// 04/06/2016 Paul.  DATA_FIELD is a property, not an attribute. 
		if (jDragged.prop('DATA_FIELD') != '')
		{
			var divField = document.getElementById('divFieldList_' + jDragged.prop('DATA_FIELD'));
			if ( divField != null )
				divField.style.display = 'block';
		}
		jDragged.prop('DATA_FIELD', '');
		var div = jDragged[0];
		// 04/06/2016 Paul.  If this is a colspan field, we need to correct the sibling. 
		if ( div.COLSPAN < 0 )
		{
			var parent = div.parentNode;
			parent.removeChild(div);
			if ( parent.childNodes.length >= 2 )
			{
				// 04/06/2016 Paul.  The last item is a drag-drop item. 
				for ( var i = 0; i < parent.childNodes.length - 1; i++ )
				{
					var div = parent.childNodes[i];
					if ( parent.childNodes.length > 2 )
					{
						div.style.width   = (nFieldListWidth / 2).toString() + 'px';
						div.style.display = 'inline-block';
					}
					else
					{
						div.style.width   = nFieldListWidth.toString() + 'px';
						div.style.display = '';
					}
				}
			}
		}
		else
		{
			// 04/06/2016 Paul.  We need to reset all fields when removing. 
			var lay = new Object();
			lay.FIELD_TYPE = 'Blank';
			this.SetLayoutObject(div, lay);
		}
	}
}

LayoutDetailViewUI.prototype.BindRow = function(tblLayout, tr)
{
	var context = this;
	tr.className             = 'grab';
	tr.style.backgroundColor = '#ddd';
	$(tr).attr('data-id-group', 'LayoutRow');
	$(tr).draggable(
	{ containment: '#tblLayoutFrame'
	//, hoverClass: 'ui-state-hover'
	, cursor: 'move'
	, helper: function()
		{
			var tblLayout = document.getElementById('tblLayout');
			var sHeight   = $(tr).height().toString() + 'px';
			var sWidth    = $(tr).width().toString()  + 'px';
			return $("<div style='border: 1px solid red; height: " + sHeight + "; width: " + sWidth + ";'>&nbsp;</div>");
		}
	, start: function(event, ui)
		{
			context.CancelProperties();
		}
	});
	// http://api.jqueryui.com/droppable/#event-drop
	$(tr).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on row');
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'NewRow' )
				context.LayoutAddRow(this.rowIndex + 1);
			else if ( sDataIdGroup == 'NewSeparator' )
				context.LayoutAddSeparator(this.rowIndex + 1);
			else if ( sDataIdGroup == 'LayoutRow' && this != ui.draggable[0] )
			{
				// 03/02/2016 Paul.  Change before or after based on direction. 
				if ( ui.draggable[0].rowIndex > this.rowIndex )
					ui.draggable.insertBefore(this);
				else
					ui.draggable.insertAfter(this);
			}
			else if ( sDataIdGroup == 'DeletedRow' )
			{
				//console.log('Ignore deleted row');
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			// 02/07/2016 Paul.  Included deleted row so that a highlighted row will get cleared. 
			return (sDataIdGroup == 'NewRow') || (sDataIdGroup == 'NewSeparator') || (sDataIdGroup == 'LayoutRow') || (sDataIdGroup == 'DeletedRow');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
}

LayoutDetailViewUI.prototype.BindColumn = function(tblLayout, td, lay)
{
	var context = this;
	$(td).attr('data-id-group'   , 'LayoutCell');
	/*
	$(td).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'FieldList') || (sDataIdGroup == 'LayoutField');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
	*/
	
	var div = document.createElement('div');
	td.appendChild(div);
	div.className             = 'grab';
	div.style.border          = '1px solid black';
	div.style.padding         = '2px';
	div.style.margin          = '2px';
	div.style.backgroundColor = '#eee';
	div.style.overflow        = 'hidden';
	div.style.width           = nFieldListWidth.toString() + 'px';
	$(div).attr('data-id-group'   , 'LayoutField');
	$(div).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});
	$(div).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			context.LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'FieldList') || (sDataIdGroup == 'LayoutField') || (sDataIdGroup == 'NewHeader') || (sDataIdGroup == 'NewBlank');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});

	if ( lay !== undefined && lay != null )
	{
		var sFIELD_TYPE = lay.FIELD_TYPE;
		if ( lay == null || sFIELD_TYPE == 'Blank' )
		{
			div.FIELD_TYPE = lay.FIELD_TYPE;
			div.COLSPAN    = lay.COLSPAN   ;
			var divDATA_FIELD = document.createElement('div');
			var divDATA_LABEL = document.createElement('div');
			div.appendChild(divDATA_FIELD);
			div.appendChild(divDATA_LABEL);
			$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BLANK_TYPE'));
			$(divDATA_LABEL).text(String.fromCharCode(160));
		}
		else if ( sFIELD_TYPE == 'Separator' )
		{
			td.colSpan = this.DATA_COLUMNS;
			td.style.backgroundColor = 'white';
			div.style.width = (this.DATA_COLUMNS * nFieldListWidth).toString() + 'px';
			div.FIELD_TYPE = lay.FIELD_TYPE;
			div.COLSPAN    = 0             ;
			$(div).text(L10n.Term('DynamicLayout.LBL_SEPARATOR_TYPE'));
		}
		else if ( sFIELD_TYPE == 'Hidden' )
		{
			div.style.width = nFieldListWidth.toString() + 'px';
			div.FIELD_TYPE = lay.FIELD_TYPE;
			div.COLSPAN    = -1            ;
			$(div).text(L10n.Term('DynamicLayout.LBL_HIDDEN_TYPE'));
		}
		else if ( sFIELD_TYPE == 'Header' )
		{
			div.style.width = nFieldListWidth.toString() + 'px';
			div.FIELD_TYPE = lay.FIELD_TYPE;
			div.DATA_LABEL = lay.DATA_LABEL;
			div.COLSPAN    = lay.COLSPAN   ;
			if ( lay.COLSPAN > 0 )
			{
				td.colSpan = this.DATA_COLUMNS;
				div.style.width = (this.DATA_COLUMNS * nFieldListWidth).toString() + 'px';
			}
			this.RenderField(div);
		}
		else
		{
			var divField = document.getElementById('divFieldList_' + lay.DATA_FIELD);
			if ( divField != null )
				divField.style.display = 'none';
			
			div.FIELD_TYPE                 = lay.FIELD_TYPE                      ;
			div.DATA_LABEL                 = lay.DATA_LABEL                      ;
			div.DATA_FIELD                 = lay.DATA_FIELD                      ;
			div.DATA_FORMAT                = lay.DATA_FORMAT                     ;
			div.URL_FIELD                  = lay.URL_FIELD                       ;
			div.URL_FORMAT                 = lay.URL_FORMAT                      ;
			div.URL_TARGET                 = lay.URL_TARGET                      ;
			div.LIST_NAME                  = lay.LIST_NAME                       ;
			div.COLSPAN                    = lay.COLSPAN                         ;
			div.TOOL_TIP                   = lay.TOOL_TIP                        ;
			div.MODULE_TYPE                = lay.MODULE_TYPE                     ;
			div.PARENT_FIELD               = lay.PARENT_FIELD                    ;
			if ( lay.COLSPAN > 0 )
			{
				td.colSpan = this.DATA_COLUMNS;
				div.style.width = (this.DATA_COLUMNS * nFieldListWidth).toString() + 'px';
			}
			this.RenderField(div);
		}
	}
	else
	{
		// 03/21/2016 Paul.  $().attr() must be used consistently as it is different then direct field access. 
		//$(div).attr('FIELD_TYPE', 'Blank');
		//$(div).attr('DATA_FIELD', ''     );
		div.FIELD_TYPE = 'Blank';
		div.DATA_FIELD = ''     ;
		var divDATA_FIELD = document.createElement('div');
		var divDATA_LABEL = document.createElement('div');
		div.appendChild(divDATA_FIELD);
		div.appendChild(divDATA_LABEL);
		$(divDATA_FIELD).text(L10n.Term('DynamicLayout.LBL_BLANK_TYPE'));
		$(divDATA_LABEL).text(String.fromCharCode(160));
	}
}

LayoutDetailViewUI.prototype.LayoutAddRow = function(nPosition)
{
	var divFieldList = document.getElementById('divFieldList');
	var tblLayout = document.getElementById('tblLayout');
	var tr = tblLayout.insertRow(nPosition);
	this.BindRow(tblLayout, tr);

	for ( var i = 0; i < this.DATA_COLUMNS; i++ )
	{
		var td = tr.insertCell(i);
		this.BindColumn(tblLayout, td, null);
	}
}

LayoutDetailViewUI.prototype.LayoutAddSeparator = function(nPosition)
{
	var divFieldList = document.getElementById('divFieldList');
	var tblLayout = document.getElementById('tblLayout');
	var tr = tblLayout.insertRow(nPosition);
	this.BindRow(tblLayout, tr);

	var lay = new Object();
	lay.FIELD_TYPE   = 'Separator';
	var td = tr.insertCell(0);
	this.BindColumn(tblLayout, td, lay);
}

LayoutDetailViewUI.prototype.AddBusinessRulePopup = function(tblEvents, sFieldName, sFieldID, sFieldValue)
{
	var tr = tblEvents.insertRow(-1);
	var tdLabel = tr.insertCell(-1);
	var tdField = tr.insertCell(-1);
	tdLabel.style.padding = '2px';
	tdField.style.padding = '2px';
	tdLabel.style.width   = '25%';
	tdField.style.width   = '75%';
	$(tdLabel).text(L10n.Term('BusinessRules.LBL_' + sFieldName + '_NAME'));
	var txt = document.createElement('input');
	txt.id    = 'tblEvents_' + sFieldName + '_NAME';
	txt.type  = 'text';
	txt.value = sFieldValue;
	txt.style.width = '200px';
	txt.style.marginRight = '3px';
	tdField.appendChild(txt);
	var hid = document.createElement('input');
	hid.id    = 'tblEvents_' + sFieldName + '_ID';
	hid.type  = 'hidden';
	hid.value = sFieldID;
	tdField.appendChild(hid);

	var btnEventSelect               = document.createElement('input');
	btnEventSelect.id                = 'btnEventSelect_' + sFieldName;
	btnEventSelect.type              = 'button';
	btnEventSelect.className         = 'button';
	btnEventSelect.value             = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
	btnEventSelect.style.marginRight = '3px';
	tdField.appendChild(btnEventSelect);
	btnEventSelect.onclick = BindArguments(function(txt, hid, context)
	{
		sRULE_CHANGE_NAME = txt.id;
		sRULE_CHANGE_ID   = hid.id;
		return window.open('../../BusinessRules/Popup.aspx?Module=' + context.MODULE_NAME, 'BusinessRulesPopup', sPopupWindowOptions);
	}, txt, hid, this);

	var btnEventClear               = document.createElement('input');
	btnEventClear.id                = 'btnLayoutCancel_' + sFieldName;
	btnEventClear.type              = 'button';
	btnEventClear.className         = 'button';
	btnEventClear.value             = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
	btnEventClear.style.marginRight = '3px';
	tdField.appendChild(btnEventClear);
	btnEventClear.onclick = BindArguments(function(txt, hid, context)
	{
		txt.value = '';
		hid.value = '';
	}, txt, hid, this);
}

LayoutDetailViewUI.prototype.LoadView = function()
{
	var context = this;
	var divFieldList = document.getElementById('divFieldList');
	var sMODULE_TERMS = this.MODULE_NAME + '.LBL_';
	this.MODULE_TERMINOLOGY = new Array();
	// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
	for ( var sTerm in TERMINOLOGY )
	{
		if (  sTerm == ".LBL_ID"                 // || sTerm == ".LBL_LIST_ID"              
		   || sTerm == ".LBL_DELETED"            // || sTerm == ".LBL_LIST_DELETED"         
		   || sTerm == ".LBL_CREATED_BY"         // || sTerm == ".LBL_LIST_CREATED_BY"      
		   || sTerm == ".LBL_CREATED_BY_ID"      // || sTerm == ".LBL_LIST_CREATED_BY_ID"   
		   || sTerm == ".LBL_CREATED_BY_NAME"    // || sTerm == ".LBL_LIST_CREATED_BY_NAME" 
		   || sTerm == ".LBL_DATE_ENTERED"       // || sTerm == ".LBL_LIST_DATE_ENTERED"    
		   || sTerm == ".LBL_MODIFIED_USER_ID"   // || sTerm == ".LBL_LIST_MODIFIED_USER_ID"
		   || sTerm == ".LBL_DATE_MODIFIED"      // || sTerm == ".LBL_LIST_DATE_MODIFIED"   
		   || sTerm == ".LBL_DATE_MODIFIED_UTC"  // || sTerm == ".LBL_LIST_DATE_MODIFIED_UTC"
		   || sTerm == ".LBL_MODIFIED_BY"        // || sTerm == ".LBL_LIST_MODIFIED_BY"     
		   || sTerm == ".LBL_MODIFIED_USER_ID"   // || sTerm == ".LBL_LIST_MODIFIED_USER_ID"
		   || sTerm == ".LBL_MODIFIED_BY_NAME"   // || sTerm == ".LBL_LIST_MODIFIED_BY_NAME"
		   || sTerm == ".LBL_ASSIGNED_USER_ID"   // || sTerm == ".LBL_LIST_ASSIGNED_USER_ID"
		   || sTerm == ".LBL_ASSIGNED_TO"        // || sTerm == ".LBL_LIST_ASSIGNED_TO"     
		   || sTerm == ".LBL_ASSIGNED_TO_NAME"   // || sTerm == ".LBL_LIST_ASSIGNED_TO_NAME"
		   || sTerm == ".LBL_TEAM_ID"            // || sTerm == ".LBL_LIST_TEAM_ID"         
		   || sTerm == ".LBL_TEAM_NAME"          // || sTerm == ".LBL_LIST_TEAM_NAME"       
		   || sTerm == ".LBL_TEAM_SET_ID"        // || sTerm == ".LBL_LIST_TEAM_SET_ID"     
		   || sTerm == ".LBL_TEAM_SET_NAME"      // || sTerm == ".LBL_LIST_TEAM_SET_NAME"   
		   || sTerm == ".LBL_ID_C"               // || sTerm == ".LBL_LIST_ID_C"            
		   || sTerm == ".LBL_LAST_ACTIVITY_DATE" // || sTerm == ".LBL_LIST_LAST_ACTIVITY_DATE"
		// 05/13/2016 Paul.  LBL_TAG_SET_NAME should be global. 
		   || sTerm == ".LBL_TAG_SET_NAME"       // || sTerm == ".LBL_LIST_TAG_SET_NAME"    
		// 07/18/2018 Paul.  Add Archive terms. 
		   || sTerm == ".LBL_ARCHIVE_BY"         // || sTerm == ".LBL_LIST_ARCHIVE_BY"       
		   || sTerm == ".LBL_ARCHIVE_BY_NAME"    // || sTerm == ".LBL_LIST_ARCHIVE_BY_NAME"  
		   || sTerm == ".LBL_ARCHIVE_DATE_UTC"   // || sTerm == ".LBL_LIST_ARCHIVE_DATE_UTC" 
		   || sTerm == ".LBL_ARCHIVE_USER_ID"    // || sTerm == ".LBL_LIST_ARCHIVE_USER_ID"  
		   || sTerm == ".LBL_ARCHIVE_VIEW"       // || sTerm == ".LBL_LIST_ARCHIVE_VIEW"     
		// 07/18/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		   || sTerm == ".LBL_ASSIGNED_SET_ID"    // || sTerm == ".LBL_LIST_ASSIGNED_SET_ID"  
		   || sTerm == ".LBL_ASSIGNED_SET_NAME"  // || sTerm == ".LBL_LIST_ASSIGNED_SET_NAME"
		   )
		{
			this.MODULE_TERMINOLOGY.push(sTerm);
		}
		else if ( StartsWith(sTerm, sMODULE_TERMS) )
		{
			this.MODULE_TERMINOLOGY.push(sTerm);
		}
	}
	
	var nbsp = String.fromCharCode(160);
	var imgDelete = document.createElement('img');
	imgDelete.id           = 'divFieldList_Delete';
	imgDelete.style.border = '1px solid white';
	imgDelete.style.width  = '48px';
	imgDelete.style.height = '48px';
	imgDelete.alt          = L10n.Term('.LBL_DELETE');
	// http://www.iconarchive.com/show/windows-8-icons-by-icons8/Industry-Trash-icon.html
	imgDelete.src          = '../../../App_Themes/Six/images/Industry-Trash-icon.png';
	$(imgDelete).attr('data-id-group', 'Delete');
	divFieldList.appendChild(imgDelete);
	// http://api.jqueryui.com/droppable/#event-drop
	$(imgDelete).droppable(
	{ hoverClass: 'ui-state-hover'
	, tolerance: 'touch'
	, greedy: true
	, drop: function(event, ui)
		{
			//console.log('Drop on delete');
			$(this).removeClass('ui-state-hover');
			var sDataIdGroup = ui.draggable.attr('data-id-group');
			if ( sDataIdGroup == 'LayoutRow' )
			{
				for ( var i = 0; i < ui.draggable[0].cells.length; i++ )
				{
					var cell = ui.draggable[0].cells[i];
					for ( var j = 0; j < cell.childNodes.length; j++ )
					{
						// 02/07/2016 Paul.  Remove each field first so that it will get enabled in the field list. 
						var div = cell.childNodes[j];
						context.LayoutRemoveField($(div));
					}
				}
				var tblLayout = document.getElementById('tblLayout');
				tblLayout.deleteRow(ui.draggable[0].rowIndex);
				if ( tblLayout.rows.length == 0 )
					context.LayoutAddRow(-1);
				// 02/07/2016 Paul.  Mark the row as deleted so that it will not also be treated as a row drop due to overlap. 
				ui.draggable.attr('data-id-group', 'DeletedRow');
			}
			else ( sDataIdGroup == 'LayoutField' )
			{
				context.LayoutRemoveField(ui.draggable);
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'LayoutField' || sDataIdGroup == 'LayoutRow');
		}
	, over: function (event, ui)
		{
			$(this).addClass('ui-state-hover');
		}
	, out: function (event, ui)
		{
			$(this).removeClass('ui-state-hover');
		}
	});
	
	var divField = document.createElement('div');
	$(divField).text(nbsp);
	divFieldList.appendChild(divField);

	divField = document.createElement('div');
	divField.id                    = 'divFieldList_NewRow';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px'    ;
	divField.style.margin          = '2px'    ;
	divField.style.backgroundColor = '#eee'   ;
	divField.style.width           = nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_ROW'));
	$(divField).attr('data-id-group', 'NewRow');
	divFieldList.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});
	
	divField = document.createElement('div');
	divField.id                    = 'divFieldList_NewSeparator';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px' ;
	divField.style.margin          = '2px' ;
	divField.style.backgroundColor = '#eee';
	divField.style.width           = nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_SEPARATOR'));
	$(divField).attr('data-id-group', 'NewSeparator');
	divFieldList.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});

	divField = document.createElement('div');
	divField.id                    = 'divFieldList_NewHeader';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px' ;
	divField.style.margin          = '2px' ;
	divField.style.backgroundColor = '#eee';
	divField.style.width           = nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_HEADER'));
	$(divField).attr('data-id-group', 'NewHeader');
	divFieldList.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});

	divField = document.createElement('div');
	divField.id                    = 'divFieldList_NewBlank';
	divField.className             = 'grab';
	divField.style.border          = '1px solid black';
	divField.style.padding         = '2px' ;
	divField.style.margin          = '2px' ;
	divField.style.backgroundColor = '#eee';
	divField.style.width           = nFieldListWidth.toString() + 'px';
	$(divField).text(L10n.Term('DynamicLayout.LBL_NEW_BLANK'));
	$(divField).attr('data-id-group', 'NewBlank');
	divFieldList.appendChild(divField);
	$(divField).draggable(
	{ containment: '#tblLayoutFrame'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});

	divField = document.createElement('div');
	$(divField).text(nbsp);
	divFieldList.appendChild(divField);

	for ( var i = 0; i < this.MODULE_FIELDS.length; i++ )
	{
		var lay = this.MODULE_FIELDS[i];
		var div = document.createElement('div');
		div.id                         = 'divFieldList_' + lay.DATA_FIELD;
		div.className                  = 'grab';
		div.style.border               = '1px solid black';
		div.style.padding              = '2px' ;
		div.style.margin               = '2px' ;
		div.style.backgroundColor      = '#eee';
		div.style.width                = nFieldListWidth.toString() + 'px';
		div.FIELD_TYPE                 = lay.FIELD_TYPE                      ;
		div.DATA_LABEL                 = lay.DATA_LABEL                      ;
		div.DATA_FIELD                 = lay.DATA_FIELD                      ;
		div.DATA_FORMAT                = null;  // lay.DATA_FORMAT                  ;
		div.URL_FIELD                  = null;  // lay.URL_FIELD                    ;
		div.URL_FORMAT                 = null;  // lay.URL_FORMAT                   ;
		div.URL_TARGET                 = null;  // lay.URL_TARGET                   ;
		div.LIST_NAME                  = null;  // lay.LIST_NAME                    ;
		div.COLSPAN                    = null;  // lay.COLSPAN                      ;
		div.TOOL_TIP                   = null;  // lay.TOOL_TIP                     ;
		div.MODULE_TYPE                = null;  // lay.MODULE_TYPE                  ;
		div.PARENT_FIELD               = null;  // lay.PARENT_FIELD                 ;

		$(div).attr('data-id-group', 'FieldList');
		divFieldList.appendChild(div);
		$(div).draggable(
		{ containment: '#tblLayoutFrame'
		, helper: 'clone'
		, cursor: 'move'
		, drop: function(e)
			{
				alert('dropped on ' + e.target.id);
			}
		, start: function( event, ui )
			{
				context.CancelProperties();
			}
		});
		
		var divDATA_FIELD = document.createElement('div');
		var divDATA_LABEL = document.createElement('div');
		div.appendChild(divDATA_FIELD);
		div.appendChild(divDATA_LABEL);
		$(divDATA_FIELD).text(lay.DATA_FIELD);
		$(divDATA_LABEL).text(L10n.Term(lay.DATA_LABEL));
		if ( Sql.IsEmptyString(lay.DATA_LABEL) )
		{
			var nbsp = String.fromCharCode(160);
			$(divDATA_LABEL).text(nbsp);
		}
	}

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

	// 05/04/2016 Paul.  Provide a way to save a layout copy. 
	var btnCopyLayout               = document.createElement('input');
	btnCopyLayout.id                = 'btnCopyLayout';
	btnCopyLayout.type              = 'button';
	btnCopyLayout.className         = 'button';
	btnCopyLayout.value             = L10n.Term('DynamicLayout.LBL_COPY_BUTTON_TITLE');
	btnCopyLayout.style.cursor      = 'pointer';
	btnCopyLayout.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnCopyLayout);
	btnCopyLayout.onclick = BindArguments(function(PageCommand, context)
	{
		PageCommand.call(context, 'Copy', null);
	}, this.PageCommand, this);
	var txtCopyLayout               = document.createElement('input');
	txtCopyLayout.id                = 'txtCopyLayout';
	txtCopyLayout.type              = 'text';
	txtCopyLayout.style.width       = '200px';
	txtCopyLayout.style.marginRight = '3px';
	txtCopyLayout.style.display     = 'none';
	divLayoutButtons.appendChild(txtCopyLayout);

	var btnRoleSelect               = document.createElement('input');
	btnRoleSelect.id                = 'btnRoleSelect';
	btnRoleSelect.type              = 'button';
	btnRoleSelect.className         = 'button';
	btnRoleSelect.value             = L10n.Term('DynamicLayout.LBL_SELECT_ROLE');
	btnRoleSelect.style.marginRight = '3px';
	btnRoleSelect.style.display     = 'none';
	divLayoutButtons.appendChild(btnRoleSelect);
	btnRoleSelect.onclick = BindArguments(function(context)
	{
		return window.open('../../ACLRoles/PopupMultiSelect.aspx?SingleSelection=1', 'ACLRolessPopup', sPopupWindowOptions);
	}, this);

	// 05/05/2016 Paul.  Provide a way to delete a layout. 
	var btnDeleteLayout               = document.createElement('input');
	btnDeleteLayout.id                = 'btnDeleteLayout';
	btnDeleteLayout.type              = 'button';
	btnDeleteLayout.className         = 'button';
	btnDeleteLayout.value             = L10n.Term('DynamicLayout.LBL_DELETE_BUTTON_TITLE');
	btnDeleteLayout.style.cursor      = 'pointer';
	btnDeleteLayout.style.marginRight = '3px';
	btnDeleteLayout.style.display     = (this.AllowDeleteLayout() ? 'inline' : 'none');
	divLayoutButtons.appendChild(btnDeleteLayout);
	btnDeleteLayout.onclick = BindArguments(function(PageCommand, context)
	{
		if ( confirm(L10n.Term('DynamicLayout.ERR_DELETE_CONFIRM')) )
		{
			PageCommand.call(context, 'Delete', null);
		}
	}, this.PageCommand, this);

	// 03/13/2016 Paul.  Restore Defaults. 
	var btnLayoutRestore               = document.createElement('input');
	btnLayoutRestore.id                = 'btnLayoutRestore';
	btnLayoutRestore.type              = 'button';
	btnLayoutRestore.className         = 'button';
	btnLayoutRestore.value             = L10n.Term('.LBL_DEFAULTS_BUTTON_LABEL');
	btnLayoutRestore.style.cursor      = 'pointer';
	btnLayoutRestore.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutRestore);
	btnLayoutRestore.onclick = BindArguments(function(PageCommand, context)
	{
		context.CancelProperties();
		context.Reload(true);
	}, this.PageCommand, this);

	var btnLayoutExport               = document.createElement('input');
	btnLayoutExport.id                = 'btnLayoutExport';
	btnLayoutExport.type              = 'button';
	btnLayoutExport.className         = 'button';
	btnLayoutExport.value             = L10n.Term('.LBL_EXPORT_BUTTON_LABEL');
	btnLayoutExport.style.cursor      = 'pointer';
	btnLayoutExport.style.marginRight = '3px';
	divLayoutButtons.appendChild(btnLayoutExport);
	btnLayoutExport.onclick = BindArguments(function(PageCommand, context)
	{
		window.location.href = '../DetailViews/export.aspx?NAME=' + context.DETAIL_NAME;
	}, this.PageCommand, this);

	var spnError = document.createElement('span');
	spnError.id        = 'divLayoutButtons_Error';
	spnError.className = 'error';
	divLayoutButtons.appendChild(spnError);

	this.LoadFromLayout();

	if ( this.EVENTS != null )
	{
		var spnEvents = document.createElement('span');
		spnEvents.style.float   = 'right';
		spnEvents.style.cursor  = 'pointer';
		divLayoutButtons.appendChild(spnEvents);
		$(spnEvents).text(L10n.Term('DynamicLayout.LBL_EVENTS'));
		var imgEventsExpand = document.createElement('img');
		imgEventsExpand.id                = 'imgEventsExpand';
		imgEventsExpand.style.cursor      = 'pointer';
		imgEventsExpand.style.marginLeft  = '3px';
		imgEventsExpand.style.marginRight = '3px';
		imgEventsExpand.src               = sREMOTE_SERVER + 'App_Themes/Six/images/advanced_search.gif';
		spnEvents.appendChild(imgEventsExpand);
		spnEvents.onclick = function()
		{
			var tblEvents       = document.getElementById('tblEvents');
			var imgEventsExpand = document.getElementById('imgEventsExpand');
			if ( tblEvents.style.display == 'none' )
			{
				tblEvents.style.display = 'block';
				imgEventsExpand.src = sREMOTE_SERVER + 'App_Themes/Six/images/basic_search.gif';
			}
			else
			{
				tblEvents.style.display = 'none';
				imgEventsExpand.src = sREMOTE_SERVER + 'App_Themes/Six/images/advanced_search.gif';
			}
		};

		var tblEvents = document.getElementById('tblEvents');
		tblEvents.style.display = 'none';
		// 07/13/2016 Paul.  Make sure values are not null.  
		this.AddBusinessRulePopup(tblEvents, 'PRE_LOAD_EVENT'  , Sql.ToString(this.EVENTS.PRE_LOAD_EVENT_ID  ), Sql.ToString(this.EVENTS.PRE_LOAD_EVENT_NAME  ));
		this.AddBusinessRulePopup(tblEvents, 'POST_LOAD_EVENT' , Sql.ToString(this.EVENTS.POST_LOAD_EVENT_ID ), Sql.ToString(this.EVENTS.POST_LOAD_EVENT_NAME ));
		tr = tblEvents.insertRow(-1);
		tdLabel             = tr.insertCell(-1);
		tdField             = tr.insertCell(-1);
		tdLabel.style.padding = '2px';
		tdField.style.padding = '2px';
		tdLabel.style.width   = '15%';
		tdField.style.width   = '85%';
		tdLabel.style.verticalAlign = 'top';
		$(tdLabel).text(L10n.Term('BusinessRules.LBL_SCRIPT'));
		txt = document.createElement('textarea');
		txt.id           = 'tblEvents_SCRIPT';
		txt.type         = 'text';
		txt.style.width  = '350px';
		txt.rows         = 3;
		txt.value        = Sql.ToString(this.EVENTS.SCRIPT);
		tdField.appendChild(txt);
	}
}

LayoutDetailViewUI.prototype.Load = function()
{
	try
	{
		AdminLayoutClear();
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				// 05/09/2016 Paul.  Specify LayoutType. 
				// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
				AdminLayout_GetModuleFields(this.MODULE_NAME, 'DetailView', this.DETAIL_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						this.MODULE_FIELDS = message;
						bgPage.Terminology_LoadModule(this.MODULE_NAME, function(status, message)
						{
							if ( status == 0 || status == 1 )
							{
								AdminLayout_GetDetailViewFields(this.DETAIL_NAME, false, function(status, message)
								{
									if ( status == 1 )
									{
										this.UpdateLayout(message);
										AdminLayout_GetDetailViewEvents(this.DETAIL_NAME, function(status, message)
										{
											if ( status == 1 )
											{
												if ( message instanceof Array && message.length > 0 )
													this.EVENTS = message[0];
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
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutDetailViewUI.Load');
	}
}

LayoutDetailViewUI.prototype.Reload = function(bDEFAULT_VIEW)
{
	try
	{
		AdminLayout_GetDetailViewFields(this.DETAIL_NAME, bDEFAULT_VIEW, function(status, message)
		{
			if ( status == 1 )
			{
				this.UpdateLayout(message);
				this.LoadFromLayout();
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutDetailViewUI.Reload');
	}
}

