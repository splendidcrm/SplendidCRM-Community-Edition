/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import L10n              from '../../../../../../scripts/L10n';

var getBusinessObject       = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var is                      = require('bpmn-js/lib/util/ModelUtil').is;
var elementHelper           = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var extensionElementsHelper = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper');
var cmdHelper               = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var utils                   = require('bpmn-js-properties-panel/lib/Utils');
var assign                  = require('lodash/object/assign');
var forEach                 = require('lodash/collection/forEach');
var find                    = require('lodash/collection/find');
import fieldTableEntryFactory from './FieldTableEntryFactory';

function generatePropertyId()
{
	return utils.nextId('Field_');
}

/**
 * Get all camunda:property objects for a specific business object
 * @param  {ModdleElement} parent
 * @return {Array<ModdleElement>} a list of camunda:property objects
 */
function getPropertyValues(parent)
{
	var properties = parent && getPropertiesElement(parent);
	if ( properties && properties.values )
	{
		return properties.values;
	}
	return [];
}

/**
 * Get all crm:CrmReadOnlyFields object for a specific business object
 * @param  {ModdleElement} parent
 * @return {ModdleElement} a crm:CrmReadOnlyFields object
 */
function getPropertiesElement(element)
{
	if ( !isExtensionElements(element) )
	{
		return element.properties;
	}
	else
	{
		return getPropertiesElementInsideExtensionElements(element);
	}
}

/**
 * Get first crm:CrmReadOnlyFields object for a specific bpmn:ExtensionElements
 * business object.
 * @param {ModdleElement} extensionElements
 * @return {ModdleElement} a crm:CrmReadOnlyFields object
 */
function getPropertiesElementInsideExtensionElements(extensionElements)
{
	return find(extensionElements.values, function(elem)
	{
		return is(elem, 'crm:CrmReadOnlyFields');
	});
}

/**
 * Returns true, if the given business object is a bpmn:ExtensionElements.
 * @param {ModdleElement} element
 * @return {boolean} a boolean value
 */
function isExtensionElements(element)
{
	return is(element, 'bpmn:ExtensionElements');
}

/**
 * Create a camunda:property entry using tableEntryFactory
 *
 * @param  {djs.model.Base} element
 * @param  {BpmnFactory} bpmnFactory
 * @param  {Object} options
 * @param  {string} options.id
 * @param  {Array<string>} options.modelProperties
 * @param  {Array<string>} options.labels
 * @param  {function} options.getParent Gets the parent business object
 * @param  {function} options.show Indicate when the entry will be shown, should return boolean
 */
export default function(element, bpmnFactory, options)
{
	var getParent       = options.getParent;
	var modelProperties = options.modelProperties;
	var createParent    = options.createParent;

	assign(options,
	{
		addLabel: L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_ADD_READ_ONLY_FIELD'),
		getElements: function(element, node)
		{
			var parent = getParent(element, node);
			return getPropertyValues(parent);
		},
		addElement: function(element, node)
		{
			var commands = [];
			var parent   = getParent(element, node);
			if ( !parent && typeof createParent === 'function' )
			{
				var result = createParent(element);
				parent = result.parent;
				commands.push(result.cmd);
			}
			var properties = getPropertiesElement(parent);
			if ( !properties )
			{
				properties = elementHelper.createElement('crm:CrmReadOnlyFields', {}, parent, bpmnFactory);
				if ( !isExtensionElements(parent) )
				{
					commands.push(cmdHelper.updateBusinessObject(element, parent, { 'properties': properties }));
				}
				else
				{
					commands.push(cmdHelper.addAndRemoveElementsFromList(element, parent, 'values', 'extensionElements', [ properties ], [] ));
				}
			}
		
			let propertyProps: any = {};
			forEach ( modelProperties, function(prop)
			{
				propertyProps[prop] = undefined;
			});
		
			// create id if necessary
			if ( modelProperties.indexOf('id') >= 0 )
			{
				propertyProps.id = generatePropertyId();
			}
		
			var property = elementHelper.createElement('camunda:Property', propertyProps, properties, bpmnFactory);
			commands.push(cmdHelper.addElementsTolist(element, properties, 'values', [ property ]));
			return commands;
		},
		updateElement: function(element, value, node, idx)
		{
			var parent   = getParent(element, node);
			var property = getPropertyValues(parent)[idx];
		
			forEach ( modelProperties, function(prop)
			{
				value[prop] = value[prop] || undefined;
			});
		
			return cmdHelper.updateBusinessObject(element, property, value);
		},
		validate: function(element, value, node, idx)
		{
			// validate id if necessary
			if (modelProperties.indexOf('id') >= 0)
			{
				var parent     = getParent(element, node);
				var properties = getPropertyValues(parent);
				var property   = properties[idx];
				if ( property )
				{
					// check if id is valid
					var validationError = utils.isIdValid(property, value.id);
					if ( validationError )
					{
						return { id: validationError };
					}
				}
			}
		},
		removeElement: function(element, node, idx)
		{
			var commands = [];
			var parent          = getParent(element, node);
			var properties      = getPropertiesElement(parent);
			var propertyValues  = getPropertyValues(parent);
			var currentProperty = propertyValues[idx];
		
			commands.push(cmdHelper.removeElementsFromList(element, properties, 'values', null, [ currentProperty ]));
			if ( propertyValues.length === 1 )
			{
				// remove crm:CrmReadOnlyFields if the last existing property has been removed
				if ( !isExtensionElements(parent) )
				{
					commands.push(cmdHelper.updateBusinessObject(element, parent, { properties: undefined }));
				}
				else
				{
					var bo = getBusinessObject(element);
					forEach ( parent.values, function(value)
					{
						if ( is(value, 'crm:CrmReadOnlyFields') )
						{
							commands.push(extensionElementsHelper.removeEntry(bo, element, value));
						}
					});
				}
			}
			return commands;
		}
	});
	return fieldTableEntryFactory(options);
};
