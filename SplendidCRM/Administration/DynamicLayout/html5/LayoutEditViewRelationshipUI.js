/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function LayoutEditViewRelationshipUI()
{
	this.MODULE_NAME        = null;
	this.EDIT_NAME          = null;
	this.LAYOUT             = null;
	this.divSelectedLayoutField = null;

	this.FIELDS = new Array();
	this.TABLE_FIELDS = new Array();
}

LayoutEditViewRelationshipUI.prototype.RebuildLayout = function()
{
	var layout = new Array();
	var nRELATIONSHIP_ORDER = 0;
	var tblLayout = document.getElementById('tblLayout');
	// 03/14/2016 Paul.  Use two passes so that we can put disabled at the top. 
	for ( var i = 0; i < tblLayout.rows.length; i++ )
	{
		var tr = tblLayout.rows[i];
		if ( tr.cells.length > 0 )
		{
			var td = tr.cells[0];
			if ( td.childNodes.length > 0 )
			{
				var div = td.childNodes[0];
				var lay = this.CreateLayoutObject(div);
				if ( !Sql.ToBoolean(lay.RELATIONSHIP_ENABLED) )
				{
					lay.RELATIONSHIP_ORDER = null;
					layout.push(lay);
				}
			}
		}
	}
	for ( var i = 0; i < tblLayout.rows.length; i++ )
	{
		var tr = tblLayout.rows[i];
		if ( tr.cells.length > 0 )
		{
			var td = tr.cells[0];
			if ( td.childNodes.length > 0 )
			{
				var div = td.childNodes[0];
				var lay = this.CreateLayoutObject(div);
				if ( Sql.ToBoolean(lay.RELATIONSHIP_ENABLED) )
				{
					lay.RELATIONSHIP_ORDER = nRELATIONSHIP_ORDER;
					nRELATIONSHIP_ORDER++;
					layout.push(lay);
				}
			}
		}
	}
	return layout;
}

LayoutEditViewRelationshipUI.prototype.PageCommand = function(sCommandName, sCommandArguments)
{
	SplendidError.SystemMessage('');
	if ( sCommandName == 'Save' )
	{
		try
		{
			var tblLayout = document.getElementById('tblLayout');
			var bgPage = chrome.extension.getBackgroundPage();
			var obj = new Object();
			obj.EDITVIEWS_RELATIONSHIPS = this.RebuildLayout();

			AdminLayout_Update('EDITVIEWS_RELATIONSHIPS', this.EDIT_NAME, obj, function(status, message)
			{
				if ( status == 1 )
				{
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
			SplendidError.SystemError(e, 'LayoutEditViewRelationshipUI.PageCommand');
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
			SplendidError.SystemError(e, 'LayoutEditViewRelationshipUI.PageCommand');
		}
	}
}

LayoutEditViewRelationshipUI.prototype.AddProperty = function(tblProperties, sFieldName, sFieldValue)
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

LayoutEditViewRelationshipUI.prototype.AddTextBoxProperty = function(tblProperties, sFieldName, sFieldValue, sWidth)
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

LayoutEditViewRelationshipUI.prototype.AddCheckBoxProperty = function(tblProperties, sFieldName, sFieldValue)
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
	var chk = document.createElement('input');
	chk.id        = 'tblProperties_' + sFieldName;
	chk.type      = 'checkbox';
	chk.className = 'checkbox';
	chk.checked   = Sql.ToBoolean(sFieldValue);
	tdField.appendChild(chk);
}

LayoutEditViewRelationshipUI.prototype.AddListBoxProperty = function(tblProperties, sFieldName, sFieldValue, sListName, bAllowNone)
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
				opt.setAttribute('selected', 'selected');
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
					opt.setAttribute('selected', 'selected');
			}
		}
	}
}

LayoutEditViewRelationshipUI.prototype.ShowProperty = function(sFieldName, bVisible)
{
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		tr.style.display = (bVisible ? 'table-row' : 'none');
}

LayoutEditViewRelationshipUI.prototype.GetPropertyVisibility = function(sFieldName)
{
	var bVisible = false;
	var tr = document.getElementById('tblProperties_tr' + sFieldName);
	if ( tr != null )
		bVisible = (tr.style.display != 'none');
	return bVisible;
}

LayoutEditViewRelationshipUI.prototype.GetPropertyValue = function(sFieldName)
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

LayoutEditViewRelationshipUI.prototype.SaveProperties = function()
{
	if ( this.divSelectedLayoutField != null )
	{
		var OLD_RELATIONSHIP_ENABLED = this.divSelectedLayoutField.RELATIONSHIP_ENABLED;
		var obj = new Object();
		obj.ID                      = this.divSelectedLayoutField.ID                  ;
		obj.EDIT_NAME               = this.divSelectedLayoutField.EDIT_NAME           ;
		obj.MODULE_NAME             = this.divSelectedLayoutField.MODULE_NAME         ;
		obj.TITLE                   = this.GetPropertyValue('TITLE'                  );
		obj.CONTROL_NAME            = this.divSelectedLayoutField.CONTROL_NAME        ;
		obj.RELATIONSHIP_ENABLED    = this.GetPropertyValue('RELATIONSHIP_ENABLED'   );
		obj.NEW_RECORD_ENABLED      = this.GetPropertyValue('NEW_RECORD_ENABLED'     );
		obj.EXISTING_RECORD_ENABLED = this.GetPropertyValue('EXISTING_RECORD_ENABLED');
		obj.ALTERNATE_VIEW          = this.GetPropertyValue('ALTERNATE_VIEW'         );

		this.SetLayoutObject(this.divSelectedLayoutField, obj);
		// 03/14/2016 Paul.  If the enabled flag changed, then resort the list with disabled at the top. 
		if ( Sql.ToBoolean(obj.RELATIONSHIP_ENABLED) != Sql.ToBoolean(OLD_RELATIONSHIP_ENABLED) )
		{
			this.LAYOUT = this.RebuildLayout();
			this.LoadFromLayout();
		}
	}
	this.CancelProperties();
	return false;
}

LayoutEditViewRelationshipUI.prototype.CancelProperties = function()
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

LayoutEditViewRelationshipUI.prototype.LoadProperties = function(divLayoutField)
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
	//this.AddProperty        (tblProperties, 'ID'                     , Sql.ToString (divLayoutField.ID                     ));
	//this.AddProperty        (tblProperties, 'EDIT_NAME'              , Sql.ToString (divLayoutField.EDIT_NAME              ));
	this.AddProperty        (tblProperties, 'MODULE_NAME'            , Sql.ToString (divLayoutField.MODULE_NAME            ));
	this.AddProperty        (tblProperties, 'CONTROL_NAME'           , Sql.ToString (divLayoutField.CONTROL_NAME           ));
	//this.AddProperty        (tblProperties, 'TABLE_NAME'             , Sql.ToString (divLayoutField.TABLE_NAME             ));
	//this.AddProperty        (tblProperties, 'PRIMARY_FIELD'          , Sql.ToString (divLayoutField.PRIMARY_FIELD          ));
	this.AddTextBoxProperty (tblProperties, 'TITLE'                  , Sql.ToString (divLayoutField.TITLE                  ));
	this.AddCheckBoxProperty(tblProperties, 'RELATIONSHIP_ENABLED'   , Sql.ToBoolean(divLayoutField.RELATIONSHIP_ENABLED   ));
	this.AddCheckBoxProperty(tblProperties, 'NEW_RECORD_ENABLED'     , Sql.ToBoolean(divLayoutField.NEW_RECORD_ENABLED     ));
	this.AddCheckBoxProperty(tblProperties, 'EXISTING_RECORD_ENABLED', Sql.ToBoolean(divLayoutField.EXISTING_RECORD_ENABLED));
	this.AddProperty        (tblProperties, 'ALTERNATE_VIEW'         , Sql.ToString (divLayoutField.ALTERNATE_VIEW         ));
}

LayoutEditViewRelationshipUI.prototype.LoadFromLayout = function()
{
	var tblLayout = document.getElementById('tblLayout');
	while ( tblLayout.rows.length > 0 )
	{
		tblLayout.deleteRow(0);
	}

	if ( this.LAYOUT != null && this.LAYOUT.length > 0 )
	{
		var tr = null;
		var td = null;
		for ( var nLayoutIndex in this.LAYOUT )
		{
			var lay = this.LAYOUT[nLayoutIndex];

			tr = tblLayout.insertRow(-1);
			this.BindRow(tblLayout, tr, lay);
			td = tr.insertCell(-1);
			this.BindColumn(tblLayout, td, lay);
		}
	}
}

LayoutEditViewRelationshipUI.prototype.CreateLayoutObject = function(src)
{
	var obj = new Object();
	obj.ID                      = Sql.ToString (src.ID                     );
	obj.EDIT_NAME               = Sql.ToString (src.EDIT_NAME              );
	obj.MODULE_NAME             = Sql.ToString (src.MODULE_NAME            );
	obj.TITLE                   = Sql.ToString (src.TITLE                  );
	obj.CONTROL_NAME            = Sql.ToString (src.CONTROL_NAME           );
	obj.RELATIONSHIP_ORDER      = Sql.ToInteger(src.RELATIONSHIP_ORDER     );
	obj.RELATIONSHIP_ENABLED    = Sql.ToBoolean(src.RELATIONSHIP_ENABLED   );
	obj.NEW_RECORD_ENABLED      = Sql.ToBoolean(src.NEW_RECORD_ENABLED     );
	obj.EXISTING_RECORD_ENABLED = Sql.ToBoolean(src.EXISTING_RECORD_ENABLED);
	obj.ALTERNATE_VIEW          = Sql.ToString (src.ALTERNATE_VIEW         );
	return obj;
}

LayoutEditViewRelationshipUI.prototype.RenderField = function(div)
{
	while ( div.childNodes.length > 0 )
	{
		div.removeChild(div.firstChild);
	}
	var tbl = document.createElement('table');
	tbl.border = 0;
	tbl.width  = '100%';
	div.appendChild(tbl);
	var tbody = document.createElement('tbody');
	tbl.appendChild(tbody);

	var tr1 = document.createElement('tr');
	var tr2 = document.createElement('tr');
	tbody.appendChild(tr1);
	tbody.appendChild(tr2);

	var td1_1 = document.createElement('td');
	var td1_2 = document.createElement('td');
	var td1_3 = document.createElement('td');
	td1_1.width = '60%';
	td1_2.width = '39%';
	td1_2.align = 'left';
	td1_3.rowSpan = 2;
	td1_3.valign = 'top';
	tr1.appendChild(td1_1);
	tr1.appendChild(td1_2);
	tr1.appendChild(td1_3);

	var td2_1 = document.createElement('td');
	var td2_2 = document.createElement('td');
	td2_2.align = 'left';
	tr2.appendChild(td2_1);
	tr2.appendChild(td2_2);

	$(td1_1).text((div.MODULE_NAME != div.CONTROL_NAME ? div.MODULE_NAME : div.MODULE_NAME + ' (' + div.CONTROL_NAME + ')'));
	$(td2_1).text(L10n.Term(div.TITLE));
	$(td2_2).text(Sql.ToString(div.ALTERNATE_VIEW));

	var chkENABLED = document.createElement('input');
	chkENABLED.id        = 'chk' + div.MODULE_NAME + '_' + div.CONTROL_NAME + '_RELATIONSHIP_ENABLED';
	chkENABLED.type      = 'checkbox';
	chkENABLED.className = 'checkbox';
	chkENABLED.checked   = Sql.ToBoolean(div.RELATIONSHIP_ENABLED);
	td1_2.appendChild(chkENABLED);
	var lblENABLED = document.createElement('label');
	lblENABLED.style.cursor      = 'pointer';
	lblENABLED.style.marginLeft  = '2px';
	lblENABLED.style.marginRight = '2px';
	$(lblENABLED).attr('for', chkENABLED.id);
	$(lblENABLED).text((Sql.ToBoolean(div.RELATIONSHIP_ENABLED) ? L10n.Term('DynamicLayout.LBL_ENABLED') : L10n.Term('DynamicLayout.LBL_DISABLED')));
	td1_2.appendChild(lblENABLED);
	chkENABLED.onclick = BindArguments(function(context)
	{
		div.RELATIONSHIP_ENABLED = !Sql.ToBoolean(div.RELATIONSHIP_ENABLED);
		$(lblENABLED).text((Sql.ToBoolean(div.RELATIONSHIP_ENABLED) ? L10n.Term('DynamicLayout.LBL_ENABLED') : L10n.Term('DynamicLayout.LBL_DISABLED')));
		context.LAYOUT = context.RebuildLayout();
		context.LoadFromLayout();
	}, this);

	var imgEdit = document.createElement('img');
	// https://css-tricks.com/all-about-floats/
	imgEdit.style.cursor  = 'pointer';
	imgEdit.style.display = 'inline';
	imgEdit.style.padding = '0px';
	imgEdit.style.margin  = '0px';
	imgEdit.src           = sREMOTE_SERVER + 'App_Themes/Six/images/edit_inline.gif';
	td1_3.appendChild(imgEdit);
	imgEdit.onclick = BindArguments(function(context)
	{
		context.LoadProperties(div);
	}, this);
}

LayoutEditViewRelationshipUI.prototype.SetLayoutObject = function(div, src)
{
	div.ID                      = Sql.ToString (src.ID                     );
	div.EDIT_NAME               = Sql.ToString (src.EDIT_NAME              );
	div.MODULE_NAME             = Sql.ToString (src.MODULE_NAME            );
	div.TITLE                   = Sql.ToString (src.TITLE                  );
	div.CONTROL_NAME            = Sql.ToString (src.CONTROL_NAME           );
	div.RELATIONSHIP_ORDER      = Sql.ToInteger(src.RELATIONSHIP_ORDER     );
	div.RELATIONSHIP_ENABLED    = Sql.ToBoolean(src.RELATIONSHIP_ENABLED   );
	div.NEW_RECORD_ENABLED      = Sql.ToBoolean(src.NEW_RECORD_ENABLED     );
	div.EXISTING_RECORD_ENABLED = Sql.ToBoolean(src.EXISTING_RECORD_ENABLED);
	div.ALTERNATE_VIEW          = Sql.ToString (src.ALTERNATE_VIEW         );
	this.RenderField(div);
}

LayoutEditViewRelationshipUI.prototype.LayoutAddField = function(jDropTarget, jDragged)
{
	//alert(jDropTarget    instanceof jQuery);
	//alert(jDragged instanceof jQuery);
	//alert(jDropTarget   .attr('data-id-group'))
	//alert(jDragged.attr('data-id-group'))
	if ( jDragged.attr('data-id-group') == 'LayoutField' )
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
}

LayoutEditViewRelationshipUI.prototype.BindRow = function(tblLayout, tr)
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
			return $("<div style='border: 1px solid red; height: " + sHeight + "; width: " + sWidth + ";'></div>");
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
			
			var jDragged = ui.draggable;
			if ( sDataIdGroup == 'LayoutRow' && this != ui.draggable[0] )
			{
				// 03/02/2016 Paul.  Change before or after based on direction. 
				if ( ui.draggable[0].rowIndex > this.rowIndex )
					ui.draggable.insertBefore(this);
				else
					ui.draggable.insertAfter(this);
			}
			else if ( this.cells[0] != jDragged[0].parentNode )
			{
				var lay = context.CreateLayoutObject(jDragged[0]);
				context.LayoutAddRow(this.rowIndex, lay);
				var tblLayout = document.getElementById('tblLayout');
				tblLayout.deleteRow(jDragged[0].parentNode.parentNode.rowIndex);
			}
			else
			{
				console.log('Dropped onself.')
			}
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'LayoutField') || (sDataIdGroup == 'LayoutRow');
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

LayoutEditViewRelationshipUI.prototype.BindColumn = function(tblLayout, td, lay)
{
	var context = this;
	$(td).attr('data-id-group'   , 'LayoutCell');
	
	var div = document.createElement('div');
	td.appendChild(div);
	div.className             = 'grab';
	div.style.border          = '1px solid black';
	div.style.padding         = '2px';
	div.style.margin          = '2px';
	div.style.backgroundColor = '#eee';
	div.style.overflow        = 'hidden';
	div.style.width           = (2 * nFieldListWidth).toString() + 'px';
	$(div).attr('data-id-group'   , 'LayoutField');
	$(div).draggable(
	{ containment: '#tblLayout'
	, helper: 'clone'
	, cursor: 'move'
	, start: function( event, ui )
		{
			context.CancelProperties();
		}
	});
	/*
	$(div).droppable(
	{ greedy: true
	, drop: function(event, ui)
		{
			console.log('Drop on column');
			$(this).removeClass('ui-state-hover');
			context.LayoutAddField($(this), ui.draggable);
		}
	, accept: function(dragitem)
		{
			var sDataIdGroup = $(dragitem).attr('data-id-group');
			return (sDataIdGroup == 'LayoutField');
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

	if ( lay !== undefined && lay != null )
	{
		div.ID                      = lay.ID                     ;
		div.EDIT_NAME               = lay.EDIT_NAME              ;
		div.MODULE_NAME             = lay.MODULE_NAME            ;
		div.TITLE                   = lay.TITLE                  ;
		div.CONTROL_NAME            = lay.CONTROL_NAME           ;
		div.RELATIONSHIP_ORDER      = lay.RELATIONSHIP_ORDER     ;
		div.RELATIONSHIP_ENABLED    = lay.RELATIONSHIP_ENABLED   ;
		div.NEW_RECORD_ENABLED      = lay.NEW_RECORD_ENABLED     ;
		div.EXISTING_RECORD_ENABLED = lay.EXISTING_RECORD_ENABLED;
		div.ALTERNATE_VIEW          = lay.ALTERNATE_VIEW         
		this.RenderField(div);
	}
}

LayoutEditViewRelationshipUI.prototype.LayoutAddRow = function(nPosition, lay)
{
	var tblLayout = document.getElementById('tblLayout');
	var tr = tblLayout.insertRow(nPosition);
	this.BindRow(tblLayout, tr);

	var td = tr.insertCell(0);
	this.BindColumn(tblLayout, td, lay);
}

LayoutEditViewRelationshipUI.prototype.LoadView = function()
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

	// 08/17/2024 Paul.  Allow Export of EditView Relationships. 
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
		window.location.href = '../EditRelationships/export.aspx?NAME=' + context.DETAIL_NAME;
	}, this.PageCommand, this);

	var spnError = document.createElement('span');
	spnError.id        = 'divLayoutButtons_Error';
	spnError.className = 'error';
	divLayoutButtons.appendChild(spnError);

	this.LoadFromLayout();
}

LayoutEditViewRelationshipUI.prototype.Load = function()
{
	try
	{
		AdminLayoutClear();
		
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule(this.MODULE_NAME, function(status, message)
				{
					if ( status == 0 || status == 1 )
					{
						AdminLayout_GetEditViewRelationships(this.EDIT_NAME, function(status, message)
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
	catch(e)
	{
		SplendidError.SystemError(e, 'LayoutEditViewRelationshipUI.Load');
	}
}

LayoutEditViewRelationshipUI.prototype.Reload = function()
{
	try
	{
		AdminLayout_GetEditViewRelationships(this.EDIT_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				this.LAYOUT = message;
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
		SplendidError.SystemError(e, 'LayoutEditViewRelationshipUI.Load');
	}
}

