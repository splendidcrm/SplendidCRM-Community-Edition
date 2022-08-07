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
var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/Properties');
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
var forEach               = require('lodash/collection/forEach');
var assign                = require('lodash/object/assign');
import formHelper         from './factory/ReportHelper';

//var inputOutputProps      = require('bpmn-js-properties-panel/lib/provider/camunda/parts/InputOutputProps');
//var inputOutput           = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/InputOutput');
//var InputOutputParameterProps  = require('bpmn-js-properties-panel/lib/provider/camunda/parts/InputOutputParameterProps');
//var inputOutputParameter       = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/InputOutputParameter');
import inputOutput                from './factory/InputOutput';
import inputOutputParameter       from './factory/InputOutputParameter';

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( is(element, 'bpmn:BusinessRuleTask') )
	{
		group.entries.push(entryFactory.selectBox(
		{ 
			id            : 'BUSINESS_RULE_OPERATION',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_BUSINESS_RULE_OPERATION'),
			modelProperty : 'BUSINESS_RULE_OPERATION',
			selectOptions :
			[
				{ value: 'assign_activity'   , name: L10n.Term('.bpmn_business_rule_operation.assign_activity'   ) },
				{ value: 'switch_activity'   , name: L10n.Term('.bpmn_business_rule_operation.switch_activity'   ) },
				{ value: 'call_sql_procedure', name: L10n.Term('.bpmn_business_rule_operation.call_sql_procedure') },
				{ value: 'call_c#_activity'  , name: L10n.Term('.bpmn_business_rule_operation.call_c#_activity'  ) },
			],
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var commands = [];
				var bo = getBusinessObject(element);
				var oldBUSINESS_RULE_OPERATION = bo.get(this.id);
				if ( oldBUSINESS_RULE_OPERATION != values[prop] )
				{
					// 09/06/2016 Paul.  Also need to remove existing properties. 
					var extensionElements = bo.get('extensionElements');
					if ( extensionElements != null )
					{
						var objectsToRemove = [];
						forEach(extensionElements.get('values'), function(extensionElement)
						{
							if ( is(extensionElement, 'camunda:InputOutput') )
							{
								objectsToRemove.push(extensionElement);
							}
							else if ( is(extensionElement, 'camunda:Properties') )
							{
								objectsToRemove.push(extensionElement);
							}
						});
						var objectsToAdd = [];
						commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', objectsToAdd, objectsToRemove));
					}
				}
				commands.push(cmdHelper.updateProperties(element, res));
				return commands;
			},
		}));
		
		group.entries.push(entryFactory.textField(
		{
			id            : 'ACTIVITY_NAME',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ACTIVITY_NAME'),
			modelProperty : 'ACTIVITY_NAME',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return BUSINESS_RULE_OPERATION != 'call_c#_activity';
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'PROCEDURE_NAME',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_PROCEDURE_NAME'),
			modelProperty : 'PROCEDURE_NAME',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return BUSINESS_RULE_OPERATION != 'call_sql_procedure';
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'assign-field-name',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ASSIGN_FIELD'),
			modelProperty : 'ASSIGN_FIELD',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return !(BUSINESS_RULE_OPERATION == 'assign_activity' || BUSINESS_RULE_OPERATION == 'switch_activity');
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
			id            : 'assign-field-type',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ASSIGN_TYPE'),
			modelProperty : 'ASSIGN_TYPE',
			emptyParameter: false,
			selectOptions : arrVariableType,
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return !(BUSINESS_RULE_OPERATION == 'assign_activity' || BUSINESS_RULE_OPERATION == 'switch_activity');
			}
		}));

		// 05/10/2022 Paul.  Changed to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'assign-field-expression',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_EXPRESSION'),
			modelProperty : 'ASSIGN_EXPRESSION',
			minRows       : 8,
			expandable    : true,
			show: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return BUSINESS_RULE_OPERATION == 'assign_activity';
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'switch-field-name',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_SWITCH_FIELD'),
			modelProperty : 'SWITCH_FIELD',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return !(BUSINESS_RULE_OPERATION == 'switch_activity');
			}
		}));

		// [FormData] Properties label
		group.entries.push(entryFactory.label(
		{
			id: 'parameters-header',
			labelText: L10n.Term('BusinessProcesses.LBL_BPMN_PARAMETERS'),
			divider: true,
			showLabel: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return (BUSINESS_RULE_OPERATION == 'call_sql_procedure' || BUSINESS_RULE_OPERATION == 'call_c#_activity');
			}
		}));

		//var options = inputOutputProps(group, element, bpmnFactory);
		var options =
		{
			hideExtensionElements: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return (BUSINESS_RULE_OPERATION != 'call_sql_procedure' && BUSINESS_RULE_OPERATION != 'call_c#_activity');
			}
		}
		var inputOutputEntry = inputOutput(element, bpmnFactory, options);
		group.entries = group.entries.concat(inputOutputEntry.entries);

		var parameterOptions =
		{
			getSelectedParameter: inputOutputEntry.getSelectedParameter,
		};
		//InputOutputParameterProps(group, element, bpmnFactory, parameterOptions);
		group.entries = group.entries.concat(inputOutputParameter(element, bpmnFactory, assign({}, parameterOptions)));

		group.entries.push(properties(element, bpmnFactory,
		{
			id              : 'switch-properties',
			modelProperties : [ 'name', 'value' ],
			addLabel        : 'Add Swtich Key/Value',
			labels          :
			[	L10n.Term('BusinessProcesses.LBL_BPMN_SWITCH_KEY'  ),
				L10n.Term('BusinessProcesses.LBL_BPMN_SWITCH_VALUE')
			],
			getParent: function(element, node)
			{
				var bo = getBusinessObject(element);
				return bo.extensionElements;
			},
			createParent: function(element)
			{
				var bo = getBusinessObject(element);
				var parent = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
				var cmd = cmdHelper.updateProperties(element, { extensionElements: parent });
				return { cmd: cmd, parent: parent };
			},
			show: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return BUSINESS_RULE_OPERATION == 'switch_activity';
			}
		}));

		// 05/10/2022 Paul.  Changed to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'switch-field-default',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_SWITCH_DEFAULT'),
			modelProperty : 'SWITCH_DEFAULT',
			minRows       : 2,
			expandable    : true,
			show: function(element, node)
			{
				var bo = getBusinessObject(element);
				var BUSINESS_RULE_OPERATION = bo.get('BUSINESS_RULE_OPERATION');
				if ( Sql.IsEmptyString(BUSINESS_RULE_OPERATION) )
					BUSINESS_RULE_OPERATION = 'call_sql_procedure';
				return BUSINESS_RULE_OPERATION == 'switch_activity';
			}
		}));

	}
};
