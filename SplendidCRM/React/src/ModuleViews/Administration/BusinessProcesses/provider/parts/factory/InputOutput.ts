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
var elementHelper           = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var extensionElementsHelper = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper');
var inputOutputHelper       = require('bpmn-js-properties-panel/lib/helper/InputOutputHelper');
var cmdHelper               = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var extensionElementsEntry  = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/ExtensionElements');


function getInputOutput(element, insideConnector)
{
	return inputOutputHelper.getInputOutput(element, insideConnector);
}

function getConnector(element)
{
	return inputOutputHelper.getConnector(element);
}

function getInputParameters(element, insideConnector)
{
	return inputOutputHelper.getInputParameters(element, insideConnector);
}

function getOutputParameters(element, insideConnector)
{
	return inputOutputHelper.getOutputParameters(element, insideConnector);
}

function getInputParameter(element, insideConnector, idx)
{
	return inputOutputHelper.getInputParameter(element, insideConnector, idx);
}

function getOutputParameter(element, insideConnector, idx)
{
	return inputOutputHelper.getOutputParameter(element, insideConnector, idx);
}


function createElement(type, parent, factory, properties)
{
	return elementHelper.createElement(type, properties, parent, factory);
}

function createInputOutput(parent, bpmnFactory, properties)
{
	return createElement('camunda:InputOutput', parent, bpmnFactory, properties);
}

function createParameter(type, parent, bpmnFactory, properties)
{
	return createElement(type, parent, bpmnFactory, properties);
}


function ensureInputOutputSupported(element, insideConnector?)
{
	return inputOutputHelper.isInputOutputSupported(element, insideConnector);
}

function ensureOutparameterSupported(element, insideConnector)
{
	return inputOutputHelper.areOutputParametersSupported(element, insideConnector);
}

/*
var TYPE_LABEL =
{
	'camunda:Map': 'Map',
	'camunda:List': 'List',
	'camunda:Script': 'Script'
};
*/

export default function(element, bpmnFactory, options)
{
	options = options || {};

	var insideConnector = !!options.insideConnector;
	var idPrefix        = options.idPrefix || '';

	var getSelected = function(element, node)
	{
		var selection = (inputEntry && inputEntry.getSelected(element, node)) || { idx: -1 };
		var parameter = getInputParameter(element, insideConnector, selection.idx);
		if ( !parameter && outputEntry )
		{
			selection = outputEntry.getSelected(element, node);
			parameter = getOutputParameter(element, insideConnector, selection.idx);
		}
		return parameter;
	};

	let result: any =
	{
		getSelectedParameter: getSelected
	};

	var entries = result.entries = [];

	if ( !ensureInputOutputSupported(element) )
	{
		return result;
	}

	var newElement = function(type, prop, factory?)
	{
		return function(element, extensionElements, value)
		{
			var commands = [];
			var inputOutput = getInputOutput(element, insideConnector);
			if ( !inputOutput )
			{
				var parent = !insideConnector ? extensionElements : getConnector(element);
				inputOutput = createInputOutput(parent, bpmnFactory,
				{
					inputParameters: [],
					outputParameters: []
				});

				if ( !insideConnector )
				{
					commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', [ inputOutput ], [] ));
				}
				else
				{
					commands.push(cmdHelper.updateBusinessObject(element, parent, { inputOutput: inputOutput }));
				}
			}
			var newElem = createParameter(type, inputOutput, bpmnFactory, { name: value });
			commands.push(cmdHelper.addElementsTolist(element, inputOutput, prop, [ newElem ]));
			return commands;
		};
	};

	var removeElement = function(getter, prop, otherProp)
	{
		return function(element, extensionElements, value, idx)
		{
			var inputOutput = getInputOutput(element, insideConnector);
			var parameter = getter(element, insideConnector, idx);
			var commands = [];
			commands.push(cmdHelper.removeElementsFromList(element, inputOutput, prop, null, [ parameter ]));

			var firstLength  = inputOutput.get(prop).length - 1;
			var secondLength = (inputOutput.get(otherProp) || []).length;

			if ( !firstLength && !secondLength )
			{
				if ( !insideConnector )
				{
					commands.push(extensionElementsHelper.removeEntry(getBusinessObject(element), element, inputOutput));
				}
				else
				{
					var connector = getConnector(element);
					commands.push(cmdHelper.updateBusinessObject(element, connector, { inputOutput: undefined }));
				}
			}
			return commands;
			};
	};

	var setOptionLabelValue = function(getter)
	{
		return function(element, node, option, property, value, idx)
		{
			// 08/15/2016 Paul.  We do not need to include the type as a suffix. 
			/*
			var parameter = getter(element, insideConnector, idx);
			var suffix = 'Text';
			var definition = parameter.get('definition');
			if ( typeof definition !== 'undefined' )
			{
				var type = definition.$type;
				suffix = TYPE_LABEL[type];
			}
			option.text = (value || '') + ' : ' + suffix;
			*/
			option.text = (value || '');
		};
	};

	// input parameters ///////////////////////////////////////////////////////////////
	var inputEntry = extensionElementsEntry(element, bpmnFactory,
	{
		id                     : idPrefix + 'inputs',
		label                  : L10n.Term('BusinessProcesses.LBL_BPMN_INPUT_PARAMETERS'),
		modelProperty          : 'name',
		prefix                 : 'Input',
		resizable              : true,
		createExtensionElement : newElement('camunda:InputParameter', 'inputParameters'),
		removeExtensionElement : removeElement(getInputParameter, 'inputParameters', 'outputParameters'),
		getExtensionElements   : function(element)
		{
			return getInputParameters(element, insideConnector);
		},
		onSelectionChange      : function(element, node, event, scope)
		{
			outputEntry && outputEntry.deselect(element, node);
		},
		setOptionLabelValue    : setOptionLabelValue(getInputParameter),
		hideExtensionElements  : options.hideExtensionElements
	});
	entries.push(inputEntry);

	// output parameters ///////////////////////////////////////////////////////
	if ( ensureOutparameterSupported(element, insideConnector) )
	{
		var outputEntry = extensionElementsEntry(element, bpmnFactory,
		{
			id                     : idPrefix + 'outputs',
			label                  : L10n.Term('BusinessProcesses.LBL_BPMN_OUTPUT_PARAMETERS'),
			modelProperty          : 'name',
			prefix                 : 'Output',
			resizable              : true,
			createExtensionElement : newElement('camunda:OutputParameter', 'outputParameters'),
			removeExtensionElement : removeElement(getOutputParameter, 'outputParameters', 'inputParameters'),
			getExtensionElements   : function(element)
			{
				return getOutputParameters(element, insideConnector);
			},
			onSelectionChange      : function(element, node, event, scope)
			{
				inputEntry.deselect(element, node);
			},
			setOptionLabelValue    : setOptionLabelValue(getOutputParameter),
			hideExtensionElements  : options.hideExtensionElements
		});
		entries.push(outputEntry);
	}
	return result;
};
