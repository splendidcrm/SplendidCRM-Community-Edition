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

function createModuleFilter(element, modelProperty, values, extensionElements, moduleFilterList, bpmnFactory)
{
	if ( values[modelProperty + '_JSON'] !== undefined )
	{
		var update = {};
		var moduleFilter = elementHelper.createElement('crm:CrmModuleFilter', update, extensionElements, bpmnFactory);
		moduleFilter[modelProperty + '_JSON'] = values[modelProperty + '_JSON'] || '';
		moduleFilter[modelProperty + '_SQL' ] = values[modelProperty + '_SQL' ] || '';
		moduleFilterList.push(moduleFilter);
	}
}

// 09/08/2021 Paul.  Include the eventBus
export default function(options, element, bpmnFactory, eventBus)
{
	let resource: any = new Object();
	resource.id            = options.id           ;
	resource.description   = options.description  ;
	resource.label         = options.label        ;
	resource.modelProperty = options.modelProperty;

	var label      = options.label || resource.id;
	var canBeShown = !!options.show && typeof options.show === 'function';
	var expandable = options.expandable;

	var resourceHtml = document.createElement('div');
	let lbl: any = document.createElement('label');
	resourceHtml.appendChild(lbl);
	lbl.for = 'camunda-' + resource.id + '_JSON';
	if ( canBeShown )
		lbl.setAttribute('data-show', 'isShown');
	lbl.appendChild(document.createTextNode(label));

	var pp = document.createElement('div');
	resourceHtml.appendChild(pp);
	pp.className = 'pp-field-wrapper';
	if ( canBeShown )
		pp.setAttribute('data-show', 'isShown');

	//var txtEnglish = document.createElement('div');
	//pp.appendChild(txtEnglish);
	//txtEnglish.style.border          = 'solid 1px #cccccc';
	//txtEnglish.style.backgroundColor = 'white';
	//txtEnglish.style.marginBottom    = '2px';
	//txtEnglish.id   = resource.id + '_' + 'English';
	//var nbsp = document.createTextNode('\u00A0');
	//txtEnglish.appendChild(nbsp);

	let divCamunda: any = document.createElement('div');
	pp.appendChild(divCamunda);
	divCamunda.style.display = 'inline';

	let txtCamundaSQL: any = document.createElement('textarea');
	divCamunda.appendChild(txtCamundaSQL);
	txtCamundaSQL.id   = 'camunda-' + resource.id + '_SQL';
	txtCamundaSQL.name = resource.modelProperty + '_SQL';
	txtCamundaSQL.rows = 4;

	let txtCamundaJSON: any = document.createElement('textarea');
	divCamunda.appendChild(txtCamundaJSON);
	txtCamundaJSON.id   = 'camunda-' + resource.id + '_JSON';
	txtCamundaJSON.name = resource.modelProperty + '_JSON';
	txtCamundaJSON.rows = 10;
	txtCamundaJSON.style.display = 'none';

	resource.html = resourceHtml;

	var btn = document.createElement('input');
	lbl.appendChild(btn);
	btn.type  = 'button';
	btn.value = L10n.Term('.LBL_EDIT_BUTTON_LABEL');
	btn.style.marginLeft = '4px';
	btn.onclick = BindArguments(function()
	{
		//console.log('QueryEntryFactory txtCamundaJSON:', txtCamundaJSON.value);
		// 07/17/2016 Paul.  Allow the filter operator to be changed to a workflow version. 
		eventBus.fire('Splendid.ReportDesignerPopup', 
		{
			JSON: txtCamundaJSON.value,
			callback: (status, message) =>
			{
				if ( status == 1 )
				{
					try
					{
						let txtCamundaJSON: any = document.getElementById('camunda-' + resource.id + '_JSON');
						let txtCamundaSQL : any = document.getElementById('camunda-' + resource.id + '_SQL' );
						// 07/04/2016 Paul.  Change event is not firing.  Not sure why as CRON control is working as expected. 
						txtCamundaJSON.value = message.JSON;
						txtCamundaSQL .value = message.SQL ;
					
						// 07/04/2016 Paul.  jQuery change/trigger is not working. 
						//$('#' + txtCamundaJSON.id).change();
						//$('#' + txtCamundaJSON.id).trigger('change');
						if ( document.createEvent )
						{
							var evt = document.createEvent('HTMLEvents');
							evt.initEvent('change', true, false);
							txtCamundaJSON.dispatchEvent(evt);
						}
						else if ( txtCamundaJSON.fireEvent )
						{
							txtCamundaJSON.fireEvent('onChange');
						}
					}
					catch(e)
					{
						console.log('QueryEntryFactory: ' + e.message);
					}
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

	resource.get = function(element)
	{
		/*
		var res = {};
		var prop = ensureNotNull(this.modelProperty);
		
		var businessObject = getBusinessObject(element)
		var values = businessObject.get('documentation');
		if ( values != null )
		{
			res[prop] = (values.length > 0) ? values[0][prop] : '';
		}
		return res;
		*/
		var value = {};
		var prop = ensureNotNull(this.modelProperty);
		var bo = getBusinessObject(element)
		if ( !!bo.extensionElements )
		{
			var extensionElementsValues = getBusinessObject(element).extensionElements.values;
			forEach(extensionElementsValues, function(extensionElement)
			{
				if ( typeof extensionElement.$instanceOf === 'function' && is(extensionElement, 'crm:CrmModuleFilter') )
				{
					value[prop + '_JSON'] = extensionElement[prop + '_JSON'];
					value[prop + '_SQL' ] = extensionElement[prop + '_SQL' ];
					//console.log('QueryEntryFactory get ' + prop + '_JSON = ' + extensionElement[prop + '_JSON']);
					//console.log('QueryEntryFactory get ' + prop + '_SQL  = ' + extensionElement[prop + '_SQL' ]);
				}
			});
		}
		return value;
	};

	resource.set = function(element, values)
	{
		var res = {};
		var prop = ensureNotNull(this.modelProperty);
		if ( values[prop+ '_JSON'] !== '' )
		{
			res[prop + '_JSON'] = values[prop + '_JSON'];
			res[prop + '_SQL' ] = values[prop + '_SQL' ];
		}
		else
		{
			res[prop + '_JSON'] = undefined;
			res[prop + '_SQL' ] = undefined;
		}
		//console.log('QueryEntryFactory set ' + prop + '_JSON = ' + res[prop + '_JSON']);
		//console.log('QueryEntryFactory set ' + prop + '_SQL  = ' + res[prop + '_SQL' ]);
		
		//var businessObject = getBusinessObject(element);
		//var newObjectList  = [];
		//if ( typeof(res[prop]) !== 'undefined' && res[prop] !== '' )
		//{
		//	newObjectList.push(bpmnFactory.create('crm:crmModuleFilter', res));
		//}
		//return cmdHelper.setList(element, businessObject, 'documentation', newObjectList);
		var bo = getBusinessObject(element)
		var extensionElements = bo.extensionElements;
		var isExtensionElementsNew = false;
		if ( !extensionElements )
		{
			isExtensionElementsNew = true;
			extensionElements = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
		}

		var command;
		if ( isExtensionElementsNew )
		{
			var extensionValues = extensionElements.get('values');
			createModuleFilter(element, prop, values, extensionElements, extensionValues, bpmnFactory);
			command = cmdHelper.updateProperties(element, { extensionElements: extensionElements });
		}
		else
		{
			// remove all existing task listeners
			var objectsToRemove = [];
			forEach(extensionElements.get('values'), function(extensionElement)
			{
				if ( is(extensionElement, 'crm:CrmModuleFilter') )
				{
					objectsToRemove.push(extensionElement);
				}
			});
			// add all the listeners
			var objectsToAdd = [];
			createModuleFilter(element, prop, values, extensionElements, objectsToAdd, bpmnFactory);
			command = cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', objectsToAdd, objectsToRemove);
		}
		return command;
	};
	return resource;
};

