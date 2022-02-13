/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql  from '../../../../../scripts/Sql' ;
import L10n from '../../../../../scripts/L10n';

var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var getExtensionElements  = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper').getExtensionElements;
var extensionElements     = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/ExtensionElements');
//var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts//implementation/Properties');
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var utils                 = require('bpmn-js-properties-panel/lib/Utils');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
var forEach               = require('lodash/collection/forEach');
var assign                = require('lodash/object/assign');
//import formHelper         from './factory/ModuleHelper';
//var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts/PropertiesProps');
import properties         from './factory/ModuleProperties';
import popupEntryFactory  from './factory/ModulePopupEntryFactory';

function generateVariableId()
{
	return utils.nextId('Variable_');
}

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

let formHelper: any = {};
/**
 * Return all form fields existing in the business object, and an empty array if none exist.
 * @param  {djs.model.Base} element
 * @return {Array} a list of form field objects
 */
formHelper.getFormFields = function(element)
{
	var bo = getBusinessObject(element);
	var formData = getExtensionElements(bo, 'crm:CrmProcessVariables');

	if (typeof formData !== 'undefined')
	{
		return formData[0].values;
	}
	else
	{
		return [];
	}
};

/**
 * Get a form field from the business object at given index
 * @param {djs.model.Base} element
 * @param {number} idx
 * @return {ModdleElement} the form field
 */
formHelper.getFormField = function(element, idx)
{
	var formFields = this.getFormFields(element);
	// 09/07/2016 Paul.  It is hard to catch these bugs, so throw to the debugger. 
	if ( formFields === undefined )
	{
		console.log('formHelper.getFormField: formFields is undefined');
		// 06/23/2017 Paul.  Should have disabled debugger before production build. 
		//debugger;
	}
	return formFields[idx];
};

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	// 09/28/2016 Paul.  Move to top of function. 
	// SCRIPT1047: In strict mode, function declarations cannot be nested inside a statement or block. They may only appear at the top level or directly inside a function body. 
	function getSelectedFormField(element, node)
	{
		var selected = formFieldsEntry.getSelected(element, node.parentNode);
		if ( selected.idx === -1 || selected.idx === undefined )
		{
			return;
		}
		return formHelper.getFormField(element, selected.idx);
	}

	if ( is(element, 'bpmn:Process') )
	{
		var formFieldsEntry = extensionElements(element, bpmnFactory, 
		{
			id           : 'module-variables',
			label        : L10n.Term('BusinessProcesses.LBL_BPMN_ADD_VARIABLE'),
			modelProperty: 'id',
			prefix       : 'Variable',
			setOptionLabelValue: function (element, node, option, property, value, idx)
			{
				var formFields = formHelper.getFormField(element, idx);
				// 07/16/2016 Paul.  Change the name in the listbox to the field name. 
				if ( formFields.VARIABLE_NAME !== undefined )
					node.text = formFields.VARIABLE_NAME + ' [' + formFields.VARIABLE_TYPE + ']';
				else
					node.text = value;
			},
			createExtensionElement: function(element, extensionElements, value)
			{
				var commands = [];
				var bo = getBusinessObject(element);
				var formData = null;
				var formDataExt = getExtensionElements(bo, 'crm:CrmProcessVariables');
				if ( formDataExt != null )
				{
					formData = formDataExt[0];
				}
				else
				{
					var extensionElements = bo.get('extensionElements');
					if ( !extensionElements )
					{
						extensionElements = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
						commands.push(cmdHelper.updateProperties(element, { extensionElements: extensionElements }));
					}
					formData = elementHelper.createElement('crm:CrmProcessVariables', { values: [] }, extensionElements, bpmnFactory);
					commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', [ formData ], [] ));
				}
				
				var field = elementHelper.createElement('crm:CrmVariable', { VARIABLE_NAME: generateVariableId(), VARIABLE_TYPE: 'string', VARIABLE_DEFAULT: '' }, formData, bpmnFactory);
				if ( typeof formData.values !== 'undefined' )
				{
					commands.push(cmdHelper.addElementsTolist(element, formData, 'values', [ field ]));
				}
				else
				{
					commands.push(cmdHelper.updateBusinessObject(element, formData, { values: [ field ] }));
				}
				return commands;
			},
			removeExtensionElement: function(element, extensionElements, value, idx)
			{
				var formData = getExtensionElements(getBusinessObject(element), 'crm:CrmProcessVariables')[0];
				var entry = formData.values[idx];
				return cmdHelper.removeElementsFromList(element, formData, 'values', null, [ entry ]);
			},
			getExtensionElements: function(element)
			{
				return formHelper.getFormFields(element);
			},
			hideExtensionElements: function(element, node)
			{
				return false;
			}
		});
		group.entries.push(formFieldsEntry);

		group.entries.push(entryFactory.textField(
		{
			id            : 'module-variable-name',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_VARIABLE'),
			modelProperty : 'VARIABLE_NAME',
			get: function(element, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				if ( selectedFormField )
				{
					return { VARIABLE_NAME: selectedFormField.VARIABLE_NAME };
				}
				else
				{
					return {};
				}
			},
			set: function(element, values, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				var commands = [];
				commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
				return commands;
			},
			/*
			validate: function(element, node)
			{
				if ( node !== undefined )
				{
					var value = node[this.id];
					if ( Sql.ToString(value) == '' )
					{
						var err = new Object();
						err[this.id] = L10n.Term('.ERR_REQUIRED_FIELD');
						return err;
					}
				}
			},
			*/
			disabled: function(element, node)
			{
				return !getSelectedFormField(element, node);
			}
		}));

		var bpmn_variable_type = L10n.GetList('bpmn_variable_type');
		var arrVariableType = new Array();
		for ( var i = 0; i < bpmn_variable_type.length; i++ )
		{
			let type: any = new Object();
			arrVariableType.push(type);
			type.value = bpmn_variable_type[i];
			type.name  = L10n.Term('.bpmn_variable_type.' + bpmn_variable_type[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'module-variable-type',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_VARIABLE_TYPE'),
			modelProperty : 'VARIABLE_TYPE',
			emptyParameter: false,
			selectOptions : arrVariableType,
			get: function(element, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				if ( selectedFormField )
				{
					return { VARIABLE_TYPE: selectedFormField.VARIABLE_TYPE };
				}
				else
				{
					return {};
				}
			},
			set: function(element, values, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				var commands = [];
				commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
				return commands;
			},
			disabled: function(element, node)
			{
				return !getSelectedFormField(element, node);
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'module-variable-default',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_VARIABLE_DEFAULT'),
			modelProperty : 'VARIABLE_DEFAULT',
			get: function(element, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				if ( selectedFormField )
				{
					return { VARIABLE_DEFAULT: selectedFormField.VARIABLE_DEFAULT };
				}
				else
				{
					return {};
				}
			},
			set: function(element, values, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				var commands = [];
				commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
				return commands;
			},
			disabled: function(element, node)
			{
				return !getSelectedFormField(element, node);
			}
		}));

	}
};
