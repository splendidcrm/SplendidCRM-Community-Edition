/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql               from '../../../../../../scripts/Sql' ;
import L10n              from '../../../../../../scripts/L10n';
import { BindArguments } from '../../../../../../scripts/utility';

var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var eventDefinitionHelper = require('bpmn-js-properties-panel/lib/helper/EventDefinitionHelper');
var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var forEach               = require('lodash/collection/forEach');

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

// 09/08/2021 Paul.  Include the eventBus
export default function(options, element, bpmnFactory, eventBus)
{
	let resource: any = new Object();
	resource.id            = options.id           ;
	resource.description   = options.description  ;
	resource.label         = options.label        ;
	resource.modelProperty = options.modelProperty;
	resource.module        = options.module       ;
	resource.get           = options.get          ;
	resource.set           = options.set          ;
	resource.validate      = options.validate     ;

	var label         = options.label || resource.id;
	var canBeShown    = !!options.show && typeof options.show === 'function';
	var expandable    = options.expandable;
	var canBeDisabled = !!options.disabled && typeof options.disabled === 'function';

	var resourceHtml = document.createElement('div');
	let lbl: any = document.createElement('label');
	resourceHtml.appendChild(lbl);
	lbl.for = 'camunda-' + resource.id;
	if ( canBeDisabled )
		lbl.setAttribute('data-show', 'isDisabled');  // isDisabled defined below. 
	else if ( canBeShown )
		lbl.setAttribute('data-show', 'isShown');
	lbl.appendChild(document.createTextNode(label));

	var pp = document.createElement('div');
	resourceHtml.appendChild(pp);
	pp.className = 'bpp-field-wrapper';
	if ( canBeDisabled )
		pp.setAttribute('data-show', 'isDisabled');  // isDisabled defined below. 
	else if ( canBeShown )
		pp.setAttribute('data-show', 'isShown');

	var divCamundaID = document.createElement('div');
	pp.appendChild(divCamundaID);
	divCamundaID.style.display = 'none';
	var txtCamundaID = document.createElement('input');
	divCamundaID.appendChild(txtCamundaID);
	txtCamundaID.id   = 'camunda-' + resource.id + 'ID';
	txtCamundaID.type = 'text';
	txtCamundaID.name = resource.modelProperty + 'ID';

	var divCamundaNAME = document.createElement('div');
	pp.appendChild(divCamundaNAME);
	divCamundaNAME.style.display = 'inline';
	var txtCamundaNAME = document.createElement('input');
	divCamundaNAME.appendChild(txtCamundaNAME);
	txtCamundaNAME.id   = 'camunda-' + resource.id + 'NAME';
	txtCamundaNAME.type = 'text';
	txtCamundaNAME.name = resource.modelProperty + 'NAME';
	txtCamundaNAME.className = '';
	// 07/09/2016 Paul.  ReadOnly flag is not working. 
	//txtCamundaNAME.readOnly  = true;
	//txtCamundaNAME.setAttribute('readonly', 'readonly');

	resource.html = resourceHtml;
	resource.cssClasses = ['bpp-textfield'];

	var btn = document.createElement('input');
	lbl.appendChild(btn);
	btn.type  = 'button';
	btn.value = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
	btn.style.marginLeft = '4px';
	btn.onclick = BindArguments(function()
	{
		var nWidth  = Math.floor(75 * $(window).width () / 100);
		var nHeight = Math.floor(75 * $(window).height() / 100);
		if ( nWidth < 1200 )
			nWidth = 1200;
		if ( nHeight < 700 )
			nHeight = 700;
		if ( nHeight > 900 )
			nHeight = 900;

		let txtCamundaID: any = document.getElementById('camunda-' + resource.id + 'ID');
		var sMODULE_TYPE = (( typeof resource.module === 'function') ? resource.module() : resource.module);
		eventBus.fire('Splendid.ModulePopup', 
		{
			MODULE_NAME: sMODULE_TYPE,
			callback: (status, message) =>
			{
				if ( status == 1 )
				{
					try
					{
						let txtCamundaID  : any = document.getElementById('camunda-' + resource.id + 'ID'  );
						let txtCamundaNAME: any = document.getElementById('camunda-' + resource.id + 'NAME');
						txtCamundaID  .value = message.ID  ;
						txtCamundaNAME.value = message.NAME;
						if ( document.createEvent )
						{
							var evt = document.createEvent('HTMLEvents');
							evt.initEvent('change', true, false);
							txtCamundaID  .dispatchEvent(evt);
							txtCamundaNAME.dispatchEvent(evt);
						}
						else if ( txtCamundaID.fireEvent )
						{
							txtCamundaID  .fireEvent('onChange');
							txtCamundaNAME.fireEvent('onChange');
						}
					}
					catch(e)
					{
						console.log('ModulePopupEntryFactory: ' + e.message);
					}
					// 02/21/2013 Paul.  Use close instead of destroy. 
					//$dialog.dialog('close');
				}
				else if ( status == -2 )
				{
					// 02/21/2013 Paul.  Use close instead of destroy. 
					//$dialog.dialog('close');
				}
				else if ( status == -1 )
				{
					alert(message);
				}
			}
		});
	});
	
	if ( canBeShown )
	{
		resource.isShown = function()
		{
			return options.show.apply(resource, arguments);
		};
	}
	resource.cssClasses = ['pp-textarea'];

	if ( resource.get === undefined )
	{
		resource.get = function(element)
		{
			var res = {};
			var prop = ensureNotNull(this.modelProperty + 'ID');
		
			// Get from child Message element. 
			var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
			res[prop] = messageEventDefinition.get(prop);

			prop = ensureNotNull(this.modelProperty + 'NAME');
			res[prop] = messageEventDefinition.get(prop);
			return res;
		};
	}

	if ( resource.set === undefined )
	{
		resource.set = function(element, values)
		{
			var res = {};
			var prop = ensureNotNull(this.modelProperty + 'ID');
			if ( values[prop] !== '' )
			{
				res[prop] = values[prop];
			}
			else
			{
				res[prop] = undefined;
			}
			prop = ensureNotNull(this.modelProperty + 'NAME');
			if ( values[prop] !== '' )
			{
				res[prop] = values[prop];
			}
			else
			{
				res[prop] = undefined;
			}
			// Set to child Message element. 
			var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
			return cmdHelper.updateBusinessObject(element, messageEventDefinition, res);
		};
	}

	if ( resource.validate === undefined )
	{
		resource.validate = function(element)
		{
			var value = this.get(element)[this.id + 'ID'];
			if ( Sql.ToString(value) == '' )
			{
				var err = new Object();
				err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
				err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
				return err;
			}
		};
	}

	if ( canBeDisabled )
	{
		resource.isDisabled = function()
		{
			return !options.disabled.apply(resource, arguments);
		};
	}
	return resource;
}

